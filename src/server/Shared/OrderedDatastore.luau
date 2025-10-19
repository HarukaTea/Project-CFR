--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

-------
-- Made by: core @corehimself
-- Created: 9/18/2023
-------

local OrderedDatastore = {}
OrderedDatastore.__index = OrderedDatastore

-- Utils
local datastoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)

-- Constants
local CACHE_EXPIRATION_TIME = 90
local dataCache = {}

local function retrieveFromCache(PlayerUserID: number?, dName: string)
	if dataCache[PlayerUserID] then
		return Promise.resolve(dataCache[PlayerUserID])
	else
		return Promise.reject("Failed to retrieve data from OrderedDataStore: " .. dName)
	end
end
local function pagesToTable(pages)
	local items = {}

	while true do
		table.insert(items, pages:GetCurrentPage())

		if pages.IsFinished then
			break
		end

		pages:AdvanceToNextPageAsync()
	end
	return items
end
local function waitForRequestBudget(requestType)
	local currentBudget = datastoreService:GetRequestBudgetForRequestType(requestType)

	while currentBudget < 1 do
		currentBudget = datastoreService:GetRequestBudgetForRequestType(requestType)
		task.wait(5)
	end
end
local function safeCall(func, self, requestType, ...)
	local success, ret

	repeat
		if requestType then
			waitForRequestBudget(requestType)
		end
		success, ret = pcall(func, self, ...)

		if not success then
			print("[OrderedDatastore] Error: " .. ret)
			if string.find(ret, "501") or string.find(ret, "504") then
				return
			end
		end
	until success

	return success, ret
end
local function retryOperation(maxRetries, retryDelay, operation)
	local retries = 0
	local success, result

	repeat
		success, result = operation()
		if not success then
			retries = retries + 1
			if retries < maxRetries then
				task.wait(retryDelay)
			else
				print("[OrderedDatastore] Max retries reached")
				return nil
			end
		end
	until success

	return result
end

--[[
	-- Retrieves the position of a specified key within an ordered data store.

	@param Key (string | number): The key to search for within the ordered data store. It can be either a string or a number varying on the convertUserIdToString boolean.
	@param Descending (boolean): Determines the ascending order when searching for the key. Set to true to search in descending order or false for ascending order.
]]
function OrderedDatastore:GetOrderedPositionAsync(Key: string | number, Descending: boolean)
	return Promise.new(function(Resolve, Reject)
		if not self.convertUserIdToString and typeof(Key) ~= 'string' then
			return error('Invalid string type, expected: string, got: ' .. Key )
		else
			if typeof(Key) == 'number' then
				Key = tostring(Key)
			end
		end
		local function getOperation()
			local success, pages = safeCall(self.orderedDataStore.GetSortedAsync, self.orderedDataStore, Enum.DataStoreRequestType.GetSortedAsync, false, 100, 0, 10 ^ 21)
			return success, pages
		end

		local sortDirection = not Descending and true or false
		local Results = self.orderedDataStore:GetSortedAsync(sortDirection, 100, 0, 10 ^ 21)

		local Position = 0
		local positionIsFound = false

		local function processPage()
			local orderedPages = retryOperation(3, 5, getOperation)


			if not orderedPages then
				retrieveFromCache(tonumber(Key), self.dataName)
				return
			end

			local newPages = pagesToTable(orderedPages)

			for i = 1, #newPages do
				local currentPage = newPages[i]
				for j = 1, #currentPage do
					local currentEntry = currentPage[j]
					Position = Position + 1

					if currentEntry.key == Key then
						positionIsFound = currentEntry
						break
					end
				end

				if positionIsFound then
					break
				end
			end

			if positionIsFound or Results.IsFinished then
				Resolve({Position, positionIsFound} or nil)
			else
				Results:AdvanceToNextPageAsync()
					:andThen(processPage)
					:catch(function(err)
						Reject("Error advancing to the next page: " .. err)
					end)
			end
		end

		processPage()
	end)
end

--[[
	-- Asynchronously updates data for a Player in the Datastore

	@param Key (string): The key associated with the player's data. Should be a string.
	@param Value (number): The new numeric value to update for the player.
]]
function OrderedDatastore:UpdateAsync(Key: string, Value: number)
	if not self.convertUserIdToString and typeof(Key) ~= 'string' then
		return error('Invalid string type, expected: string, got: ' .. Key )
	else
		if typeof(Key) == 'number' then
			Key = tostring(Key)
		end
	end
	if typeof(Value) ~= 'number' then
		return error('Invalid Value type, expected: number, got: ' .. Value)
	end
	return Promise.new(function(_Resolve, Reject)
		task.spawn(function()
			local function getOrderedSetOperation()
				local succ, _orderedResult = safeCall(self.orderedDataStore.UpdateAsync, self.orderedDataStore, Enum.DataStoreRequestType.UpdateAsync, Key, function(_oldData)
					return Value
				end)

				return succ, _orderedResult
			end
			local Success = retryOperation(3, 5, getOrderedSetOperation)

			if not Success then
				Reject("Error ")
			end
		end)
	end)
end

--[[
	-- Returns a new OrderedDatastore object

	@param OrderedDatastoreName (string): The name of the provided Ordered Datastore
	@param ConvertUserIdToString (boolean): Indicates whether user IDs should be converted to strings when interacting with the data store.
	@constructor OrderedDatastore.new(OrderedDatastoreName: string, ConvertUserIdToString: boolean)
]]
function OrderedDatastore.new(OrderedDatastoreName: string, ConvertUserIdToString: boolean)
	local Info = {
		dataName = OrderedDatastoreName,
		convertUserIdToString = ConvertUserIdToString,
		orderedDataStore = datastoreService:GetOrderedDataStore(OrderedDatastoreName),
	}

	return setmetatable(Info, OrderedDatastore)
end

return OrderedDatastore