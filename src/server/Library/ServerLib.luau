
local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local PassiveLib = require(SSS.HarukaServer.Library.PassiveLib)
local ServerTable = require(SSS.HarukaServer.Library.ServerTable)

local ServerLib = {}



local terrainParams = RaycastParams.new()
terrainParams.IgnoreWater = true
terrainParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPartEntity")
terrainParams.FilterType = Enum.RaycastFilterType.Include

CollectionService:GetInstanceAddedSignal("TerrainPartEntity"):Connect(function(part)
	terrainParams:AddToFilter(part)
end)


--// Helper functions

function ServerLib:WeldModel(part: BasePart, welded: Model)
	ClientLib:WeldModel(part, welded)
end

function ServerLib:FindGroundByRay(givenPos: Vector3)
	return ClientLib:FindGroundByRay(givenPos)
end

function ServerLib:FindGroundByRayForOrb(givenPos: Vector3)
	return ClientLib:FindGroundByRayForOrb(givenPos)
end

function ServerLib:WeldWeapon(weapon: Model, char: Model) : Model
	return ClientLib:WeldWeapon(weapon, char)
end

function ServerLib:IsModelValid(model: Model)
	return ClientLib:IsModelValid(model)
end

function ServerLib:IsCharValid(char: Model)
	return ClientLib:IsCharValid(char)
end

function ServerLib:GetPlayerByUniqueId(uniqueId: string)
	return ClientLib:GetPlayerByUniqueId(uniqueId)
end

function ServerLib:PlayWorldSound(sound: Sound, pos: Vector3)
	ClientLib:PlayWorldSound(sound, pos)
end

function ServerLib:FindGroundByRayForCombatLocation(givenPos: Vector3) : Vector3
	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 15, -Vector3.yAxis * 159, terrainParams)
	if rayResult then return rayResult.Position end

	return givenPos
end


function ServerLib:GetNearbyPlayers(position: Vector3, distance: number?)
	local players = {}
	local playerEntities = CollectionService:GetTagged("PlayerEntity") :: { Player }

	distance = distance or 200

	for _, player in playerEntities do
		if not player then continue end
		if not ServerLib:IsCharValid(player.Character) then continue end

		local thatDistance = player:DistanceFromCharacter(position)
		if thatDistance > 0 and thatDistance <= distance then
			table.insert(players, player)
		end
	end

	return players
end

function ServerLib:GenerateOrbPos(combatLocation: CFrame) : CFrame
	local orbLocation = CFrame.identity
	local MAGNITUDE = 30

	Promise.new(function(resolve)
		local repeatedTimes = 0

		local rng = Random.new()
		local rX, rZ = rng:NextInteger(-MAGNITUDE, MAGNITUDE), rng:NextInteger(-MAGNITUDE, MAGNITUDE)
		local pos = ServerLib:FindGroundByRayForOrb(combatLocation.Position + Vector3.new(rX, 0, rZ))

		while repeatedTimes <= 15 do
			-- we gonna try to find a valid position, if we can't, we'll try again
			local isTheSame = pos:FuzzyEq(combatLocation.Position, 1)
			local isInsidePart = HarukaLib:IsInRegion(pos + Vector3.yAxis, CollectionService:GetTagged("TerrainPartEntity"))
			local isInsidePart2 = HarukaLib:IsInRegion(pos + Vector3.new(0, 8, 0), CollectionService:GetTagged("TerrainPartEntity"))

			if not isTheSame and not isInsidePart and not isInsidePart2 then
				break
			end

			rng = Random.new()
			rX, rZ = rng:NextInteger(-MAGNITUDE, MAGNITUDE), rng:NextInteger(-MAGNITUDE, MAGNITUDE)
			pos = ServerLib:FindGroundByRayForOrb(combatLocation.Position + Vector3.new(rX, 0, rZ))

			repeatedTimes += 1
		end

		resolve(pos)

	end):andThen(function(pos: Vector3)
		orbLocation = CFrame.new(pos) * CFrame.new(0, math.random(7, 8), 2)

	end):catch(function(err)
		warn(tostring(err))
	end):await()


	return orbLocation
end



function ServerLib:ShowNumber(target: Model, number: number, color: Color3?)
	if not ServerLib:IsCharValid(target) then return end

	local pos = target.PrimaryPart.Position

	Events.ShowDMGNumber_S.FireList(ServerLib:GetNearbyPlayers(pos), {
		Target = target,
		DMGNumber = tostring(number),
		DMGColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib:ShowText(target: Model, text: string, color: Color3?)
	if not ServerLib:IsCharValid(target) then return end

	local pos = target.PrimaryPart.Position

	Events.ShowText_S.FireList(ServerLib:GetNearbyPlayers(pos), {
		Target = target,
		Text = text,
		TextColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib:ApplyHitStatus(target: Model)
	if not ServerLib:IsCharValid(target) then return end


	Events.PlayVFXStatusToEntity_S.FireList(ServerLib:GetNearbyPlayers(target.PrimaryPart.Position), {
		StatusId = "Hit",
		Entity = target
	})
end


function ServerLib:PlaceItemDropPart(plr: Player, itemId: string, amount: number, location: Vector3, autoPickup: boolean)
	local itemUniqueId = HttpService:GenerateGUID(false)

	ServerTable.ItemDropSymbols[itemUniqueId] = {
		UniqueId = itemUniqueId,
		ItemId = itemId,
		Amount = amount,
		Receiver = plr
	}
	ServerTable:AddItem(ServerTable.ItemDropSymbols, itemUniqueId, 30)

	Events.SpawnItemDrop_S.Fire(plr, {
		ItemUniqueId = itemUniqueId,
		ItemId = itemId,
		ItemAmount = amount,
		ItemDropLocationPos = location,
		AllowAutoPickUp = autoPickup
	})
end


function ServerLib:RollStat(attr: string, val: any)
	if typeof(val) == "number" then
		local maxVal = FormulaBook.ItemUpgradeCurveCal(val)
		if val > maxVal then
			maxVal, val = val, maxVal
		end
		return Random.new():NextInteger(val, maxVal)
	else
		return val
	end
end


function ServerLib:GiveRandomStatForItem(itemId: string) : string
	if not ItemBook:GetItemInfo(itemId) then return "" end

	local itemInfo = ItemBook:GetItemInfo(itemId)
	if table.find(itemInfo.TagsDesync, "NoRandom") or table.find(itemInfo.TagsDesync, "Chest") or table.find(itemInfo.TagsDesync, "Statue") then
		return itemInfo.StatInfo
	end
	local statInfoDesync = itemInfo.StatInfoDesync
	local finalDesync = {}

	for attr: string, val: any in statInfoDesync do
		finalDesync[attr] = ServerLib:RollStat(attr, val)
	end

	return ItemBook:BuildItemStat("Stat", finalDesync)
end


function ServerLib:GiveItemDrop(plr: Player, itemId: string, amount: number)
	if not ItemBook:GetItemInfo(itemId) then return end


	local items = plr.Items :: Folder
	local itemInfo = ItemBook:GetItemInfo(itemId)

	local function _createNewSymbol(forcedAmount: number?)
		local randomStat = ServerLib:GiveRandomStatForItem(itemId)

		local itemVal = Instance.new("IntConstrainedValue")
		itemVal.MinValue = 0

		local itemType = itemInfo.Type
		local maxVal = FormulaBook.MAX_ITEM_LIMIT
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
		itemVal:SetAttribute("IsNew", true)

		itemVal.Parent = items
	end


	local stackableList = AssetBook.StackableItemTypes
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


	Events.PlayItemDropFX_S.Fire(plr, {
		ItemId = itemId,
		Amount = amount
	})
end


function ServerLib:GiveEXPRewards(plr: Player, exp: number, classEXP: number)
	exp = exp or 0
	if exp <= 0 then return end

	classEXP = classEXP or 0

	exp *= FormulaBook.EXPEvent
	exp = math.clamp(exp, 0, FormulaBook.FAIRLY_BIG_NUMBER)
	exp = math.floor(exp)

	classEXP = math.clamp(classEXP, 0, FormulaBook.FAIRLY_BIG_NUMBER)
	classEXP = math.floor(classEXP)


	Promise.delay(1):andThen(function()
		local class = plr:GetAttribute("Class") or "Chain"

		HarukaLib:AddAttr(plr, "EXP", exp)
		HarukaLib:AddAttr(plr, "ClassEXP_"..class, classEXP)

		Events.OpenEXPAwardBar_S.Fire(plr, {
			EXPGained = exp,
			ClassEXPGained = classEXP
		})
	end)
end


function ServerLib:EquipItem(plr: Player, itemUniqueId: string, method: string?)
	method = method or "Equip"

	local itemSymbol = nil
	local items = plr.Items :: Folder

	for _, item in items:GetChildren() do
		if item:GetAttribute("HarukaUniqueId") == itemUniqueId then
			itemSymbol = item
			break
		end
	end
	if not itemSymbol then return end

	local char = plr.Character :: Model
	if not ServerLib:IsCharValid(char) then return end

	local itemInfo = ItemBook:GetItemInfo(itemSymbol.Name)
	if not itemInfo then return end

	local whiteList = { "Active", "Accessory", "Passive", "Weapon" }
	if not table.find(whiteList, itemInfo.Type) then return end


	local itemStat = itemSymbol:GetAttribute("ItemStat") :: string
	local itemStatDesync = ItemBook:ParseItemStat("Stat", string.split(itemStat, ","))

	for attr: string, val: any in itemStatDesync do
		local value = val
		if type(val) == "number" and method == "Unequip" then
			value = -val
		elseif type(val) == "boolean" and method == "Unequip" then
			value = false
		end

		if string.find(attr, "Can") then
			char:SetAttribute(attr, value)
		elseif string.find(attr, "ForClass") then
			--// do nothing
		elseif attr == "ATK" then
			local calMethod = math.floor
			if method == "Unequip" then
				calMethod = math.ceil
			end
			HarukaLib:AddAttr(char, "MinDMGEx", calMethod(value * 0.85))
			HarukaLib:AddAttr(char, "MaxDMGEx", calMethod(value * 1.25))
		else
			HarukaLib:AddAttr(char, attr, value)
		end
	end

	if char:FindFirstChild(itemSymbol.Name) then
		local itemScript = char[itemSymbol.Name] :: Script
		local itemId = itemScript.Name
		local needsDestroying = itemScript:GetAttribute("ReqDestroyingEvent")

		char[itemSymbol.Name]:Destroy()

		if needsDestroying then
			if PassiveLib[itemId] then PassiveLib[itemId](char) end
		end
	end
	if method == "Equip" and RepS.HarukaRes.Accessories:FindFirstChild(itemSymbol.Name, true) then
		RepS.HarukaRes.Accessories:FindFirstChild(itemSymbol.Name, true):Clone().Parent = char
	end
end

function ServerLib:UnequipItem(plr: Player, itemUniqueId: string)
	ServerLib:EquipItem(plr, itemUniqueId, "Unequip")
end


local function _refresh(plr: Player)
	local refreshSymbol = Instance.new("StringValue")
	refreshSymbol.Name = "_NULL"
	refreshSymbol.Value = "_NULL"
	refreshSymbol:SetAttribute("HarukaUniqueId", "1599mkk40")
	refreshSymbol.Parent = plr.EquippingItems

	Debris:AddItem(refreshSymbol, 1)
end
function ServerLib:ChangeWeapon(plr: Player, itemId: string, itemUniqueId: string)
	local weapon1Symbol = plr.EquippingItems:FindFirstChild("Weapon1") :: StringValue
	if not weapon1Symbol then
		weapon1Symbol = Instance.new("StringValue")
		weapon1Symbol.Name = "Weapon1"
	end

	ServerLib:UnequipItem(plr, weapon1Symbol:GetAttribute("HarukaUniqueId"))

	weapon1Symbol:SetAttribute("HarukaUniqueId", itemUniqueId)
	weapon1Symbol.Value = itemId
	weapon1Symbol.Parent = plr.EquippingItems

	_refresh(plr)
	ServerLib:EquipItem(plr, itemUniqueId)

	Events.PlaySound_S.Fire(plr, SoundService.SFXs.EXP)
end


function ServerLib:EquipArmor(char: Model, armorId: string)
	if not ServerLib:IsCharValid(char) then return end
	if not armorId then return end

	if char:FindFirstChild(armorId) then char[armorId]:Destroy() end

	local armor = RepS.Packages.Cosmetics[armorId]:Clone() :: Model
	local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "Extra" }

	--- wait character fully loads
	for _, part: string in equipList do
		if part == "Extra" then continue end
		char:WaitForChild(part, 999)
	end
	for _, part: string in equipList do
		if not armor:FindFirstChild(part) then continue end

		local weapon = ServerLib:WeldWeapon(armor[part], char)
		weapon.Parent = armor
	end
	armor.Parent = char
end
function ServerLib:UnequipArmor(char: Model, armorId: string)
	if not ServerLib:IsCharValid(char) then return end
	if not armorId then return end

	if char:FindFirstChild(armorId) then char[armorId]:Destroy() end
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
	if game.GameId ~= AssetBook.CFUniverseId_Main then return end


	Promise.new(function()
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)

		if not hasBadge then
			local badgeMarketInfo = BadgeService:GetBadgeInfoAsync(badgeId)

			if badgeMarketInfo.IsEnabled then
				BadgeService:AwardBadgeAsync(plr.UserId, badgeId)

				ServerBindables.RToCheckPlayerBadges:Fire(plr)
				Events.PlayBadgeNotify_S.Fire(plr, tostring(badgeId))
			end
		end

		if callBack then callBack() end
	end):catch(function(err)
		if RunService:IsStudio() then warn(tostring(err)) end
	end)
end


return ServerLib