--!nocheck

local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ServerLib = {}

--// Helper functions

ServerLib.WeldModel = function(_, part: Part, welded: Model)
	ClientLib:WeldModel(part, welded)
end

ServerLib.FindGroundByRay = function(_, givenPos: Vector3)
	return ClientLib:FindGroundByRay(givenPos)
end

ServerLib.FindGroundByRayForOrb = function(_, givenPos: Vector3)
	return ClientLib:FindGroundByRayForOrb(givenPos)
end


function ServerLib:FindGroundByRayForCombatLocation(givenPos: Vector3) : Vector3
	local rParams = RaycastParams.new()
	rParams.RespectCanCollide = false
	rParams.IgnoreWater = true
	rParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
	rParams.FilterType = Enum.RaycastFilterType.Include


	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 15, -Vector3.yAxis * (159 + 15), rParams)

	rParams = nil --// I assume it needs to be destroyed
	if rayResult then return rayResult.Position end

	return givenPos
end


ServerLib.IsModelValid = function(_, model: Model)
	return ClientLib:IsModelValid(model)
end

ServerLib.IsCharValid = function(_, char: Model)
	return ClientLib:IsCharValid(char)
end

ServerLib.GetPlayerByUniqueId = function(_, uniqueId: string)
	return ClientLib:GetPlayerByUniqueId(uniqueId)
end

ServerLib.PlayWorldSound = function(_, sound: Sound, pos: Vector3)
	ClientLib:PlayWorldSound(sound, pos)
end


function ServerLib:GetNearbyPlayers(position: Vector3)
	local players = {}

	for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
		if not player then continue end
		if not ServerLib:IsCharValid(player.Character) then continue end

		local distance = player:DistanceFromCharacter(position)
		if distance > 0 and distance <= 159 * 2.599 then
			table.insert(players, player)
		end
	end

	return players
end


function ServerLib:WeldWeapon(weapon: Model, char: Model)
	local motor6D = weapon:FindFirstChildOfClass("Motor6D")
	local weldTarget = weapon.Handle:GetAttribute("Weld") :: string

	if not motor6D then warn("No Motor6D found on weapon") return end
	if not weldTarget then warn("Cannot weld weapon, no target specified") return end

	weldTarget = char:FindFirstChild(weldTarget)
	if not weldTarget then warn("Cannot weld weapon, target not found") return end

	motor6D.Part0 = weldTarget

	ServerLib:WeldModel(weapon.Handle, weapon)

	weapon.Parent = char
end


function ServerLib:GenerateOrbPos(combatLocation: CFrame) : CFrame
	local orbLocation = CFrame.identity
	local MAGNITUDE = 28

	local random = Random.new()

	Promise.new(function(resolve)
		local repeatedTimes = 0
		local pos = ServerLib:FindGroundByRayForOrb(combatLocation.Position + Vector3.new(random:NextInteger(-MAGNITUDE, MAGNITUDE), 0, random:NextInteger(-MAGNITUDE, MAGNITUDE)))

		while repeatedTimes <= 15 do
			-- we gonna try to find a valid position, if we can't, we'll try again
			if not HarukaLib:IsInRegion(pos + Vector3.yAxis, CollectionService:GetTagged("TerrainPart")) then
				break
			end

			pos = ServerLib:FindGroundByRayForOrb(combatLocation.Position + Vector3.new(random:NextInteger(-MAGNITUDE, MAGNITUDE), 0, random:NextInteger(-MAGNITUDE, MAGNITUDE)))
			repeatedTimes += 1
		end

		resolve(pos)

	end):andThen(function(pos: Vector3)
		orbLocation = CFrame.new(pos) * CFrame.new(0, 11.15, 0)

	end):catch(function(err)
		warn(tostring(err))
	end):await()

	random = nil

	return orbLocation
end



function ServerLib:ShowNumber(target: Model, number: number, color: Color3?)
	if not ServerLib:IsCharValid(target) then return end


	Events.ShowDMGNumber.FireList(ServerLib:GetNearbyPlayers(target.PrimaryPart.Position), {
		DMGTarget = target,
		DMGNumber = tostring(number),
		DMGColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib:ShowText(target: Model, text: string, color: Color3?)
	if not ServerLib:IsCharValid(target) then return end


	Events.ShowText.FireList(ServerLib:GetNearbyPlayers(target.PrimaryPart.Position), {
		Target = target,
		Text = text,
		TextColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib:ApplyHitStatus(target: Model)
	if not ServerLib:IsCharValid(target) then return end


	Events.PlayHitStatusVFX.FireList(ServerLib:GetNearbyPlayers(target.PrimaryPart.Position), {
		Target = target
	})
end


function ServerLib:PlaceItemDropPart(plr: Player, itemId: string, amount: number, location: Vector3)
	local itemUniqueId = HttpService:GenerateGUID(false)
	local container = ServerStorage.ItemSphereSymbolContainer :: Folder

	local symbol = Instance.new("IntValue")
	symbol.Name = itemUniqueId
	symbol.Value = amount
	symbol.Parent = container

	symbol:SetAttribute("ItemId", itemId)
	symbol:SetAttribute("Receiver", plr.Name)


	Events.SpawnItemDrop.Fire(plr, {
		ItemUniqueId = itemUniqueId,
		ItemId = itemId,
		ItemAmount = amount,
		ItemDropLocationPos = location
	})
end



function ServerLib:GiveRandomStatForItem(itemId: string) : string
	if not ItemLib:GetItemInfo(itemId) then return "" end

	local itemInfo = ItemLib:GetItemInfo(itemId)
	if table.find(itemInfo.TagsDesync, "NoRandom") then
		return itemInfo.StatInfo
	end
	local statInfoDesync = itemInfo.StatInfoDesync
	local finalDesync = {}

	for attr: string, val: any in statInfoDesync do
		if typeof(val) == "number" then
			local maxVal = FormulaBook.ItemUpgradeCurveCal({
				Level = itemInfo.Level,
				Stat = attr,
				Val = val
			})
			if val > maxVal then
				maxVal, val = val, maxVal
			end

			local random = Random.new()
			local randomVal = random:NextInteger(val, maxVal)

			random = nil

			finalDesync[attr] = randomVal
		else
			finalDesync[attr] = val
        end
	end

	return ItemLib:PackTableToItemStat("Stat", finalDesync)
end


function ServerLib:GiveItemDrop(plr: Player, itemId: string, amount: number)
	if not ItemLib:GetItemInfo(itemId) then return end


	local items = plr.Items :: Folder
	local itemInfo = ItemLib:GetItemInfo(itemId)

	local function _createNewSymbol(forcedAmount: number?)
		local randomStat = ServerLib:GiveRandomStatForItem(itemId)

		local itemVal = Instance.new("IntConstrainedValue")
		itemVal.MinValue = 0

		local itemType = itemInfo.Type
		local maxVal = 999
		if itemType == "Active" or itemType == "Passive" then
			maxVal = 1
		end
		if itemType == "Accessory" or itemType == "Weapon" then
			maxVal = 1
		end

		itemVal.MaxValue = maxVal
		itemVal.Value = forcedAmount or amount

		local exAmount = (forcedAmount or amount) - maxVal
		if exAmount > 0 then
			HarukaLib:AddAttr(plr, "Gold", itemInfo.Price * exAmount)
		end

		itemVal.Name = itemId

		itemVal:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))
		itemVal:SetAttribute("ItemStat", randomStat)
		itemVal:SetAttribute("Level", itemInfo.Level)

		itemVal.Parent = items
	end

	local stackableList = { "Accessory", "Weapon" }
	if table.find(stackableList, itemInfo.Type) then
		for _ = 1, amount do
			_createNewSymbol(1)
		end
	else
		local symbol = items:FindFirstChild(itemId) :: IntConstrainedValue

		if symbol then
			symbol.Value += amount

			local exAmount = amount - symbol.MaxValue
			if exAmount > 0 then
				HarukaLib:AddAttr(plr, "Gold", itemInfo.Price * exAmount)
			end
		else
			_createNewSymbol()
		end
	end


	Events.PlayItemDropFX.Fire(plr, {
		ItemId = itemId,
		Amount = amount
	})
	Events.PlaySound.Fire(plr, SoundService.SFXs.ItemAcquired)
end


function ServerLib:GiveEXPRewards(plr: Player, exp: number)
	exp = exp or 0
	if exp <= 0 then return end


	exp *= FormulaBook.EXPEvent

	Promise.delay(1.5):andThen(function()
		HarukaLib:AddAttr(plr, "EXP", exp)

		Events.OpenEXPAwardBar.Fire(plr, {
			EXPGained = exp
		})
	end)
end


function ServerLib:EquipItem(plr: Player, itemUniqueId: string, method: string?)
	method = method or "Equip"

	local itemSymbol = nil

	for _, item: IntConstrainedValue in plr.Items:GetChildren() do
		if item:GetAttribute("HarukaUniqueId") == itemUniqueId then
			itemSymbol = item
			break
		end
	end
	if not itemSymbol then
		Events.CreateNotify.Fire(plr, "[Error] Cannot equip item, item not found")
		return
	end

	local char = plr.Character :: Model
	if not ServerLib:IsCharValid(char) then
		Events.CreateNotify.Fire(plr, "[Error] Cannot equip item, character not found")
		return
	end


	local itemStat = itemSymbol:GetAttribute("ItemStat") :: string
	local itemStatDesync = ItemLib:DesyncItemStat("Stat", string.split(itemStat, ","))

	for attr: string, val: any in itemStatDesync do
		local value = val
		if type(val) == "number" and method == "Unequip" then
			value = -val
		elseif type(val) == "boolean" and method == "Unequip" then
			value = false
		end

		if string.find(attr, "Can") then
			char:SetAttribute(attr, value)
		elseif string.find(attr, "ForClass") or string.find(attr, "ForVariant") then
			--// do nothing
		elseif attr == "ATK" then
			HarukaLib:AddAttr(char, "MinDMGEx", value)
			HarukaLib:AddAttr(char, "MaxDMGEx", value)
		else
			HarukaLib:AddAttr(char, attr, value)
		end
	end
end

function ServerLib:UnequipItem(plr: Player, itemUniqueId: string)
	ServerLib:EquipItem(plr, itemUniqueId, "Unequip")
end



function ServerLib:CheckIfHaveBadge(badgeId: number, plr: Player, callBack: () -> ()?, failureHandler: () -> ()?)
	Promise.new(function()
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)
		if hasBadge and callBack then callBack() end
		if not hasBadge and failureHandler then failureHandler() end

	end):catch(function(err)
		if RunService:IsStudio() then warn(tostring(err)) end
	end)
end
function ServerLib:GiveBadge(badgeId: number, plr: Player, callBack: () -> ()?)
	Promise.new(function()
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)

		if not hasBadge then
			local badgeMarketInfo = BadgeService:GetBadgeInfoAsync(badgeId)

			if badgeMarketInfo.IsEnabled then BadgeService:AwardBadge(plr.UserId, badgeId) end
		end

		if callBack then callBack() end
	end):catch(function(err)
		if RunService:IsStudio() then warn(tostring(err)) end
	end)
end

return ServerLib
