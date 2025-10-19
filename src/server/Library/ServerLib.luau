--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ServerLib = {}


local RNG = Random.new()


local terrainParams = RaycastParams.new()
terrainParams.IgnoreWater = true
terrainParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
terrainParams.FilterType = Enum.RaycastFilterType.Include

local rawTerrainParams = RaycastParams.new()
rawTerrainParams.IgnoreWater = true
rawTerrainParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
rawTerrainParams.FilterType = Enum.RaycastFilterType.Include


CollectionService:GetInstanceAddedSignal("TerrainPart"):Connect(function()
	terrainParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
	rawTerrainParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
end)
CollectionService:GetInstanceAddedSignal("CombatBorderServer"):Connect(function(ins: Instance)
	terrainParams:AddToFilter(ins:GetDescendants())
end)


--// Helper functions

function ServerLib.WeldModel(part: BasePart, welded: Model)
	ClientLib.WeldModel(part, welded)
end

function ServerLib.FindGroundByRay(givenPos: Vector3)
	return ClientLib.FindGroundByRay(givenPos)
end

function ServerLib.FindGroundByRayForOrb(givenPos: Vector3)
	return ClientLib.FindGroundByRayForOrb(givenPos)
end

function ServerLib.WeldWeapon(weapon: Model, char: Model)
	ClientLib.WeldWeapon(weapon, char)
end

function ServerLib.IsModelValid(model: Model)
	return ClientLib.IsModelValid(model)
end

function ServerLib.IsCharValid(char: Model)
	return ClientLib.IsCharValid(char)
end

function ServerLib.GetPlayerByUniqueId(uniqueId: string)
	return ClientLib.GetPlayerByUniqueId(uniqueId)
end

function ServerLib.PlayWorldSound(sound: Sound, pos: Vector3)
	ClientLib.PlayWorldSound(sound, pos)
end

function ServerLib.FindGroundByRayForCombatLocation(givenPos: Vector3) : Vector3
	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 15, -Vector3.yAxis * 159, rawTerrainParams)
	if rayResult then return rayResult.Position end

	return givenPos
end


function ServerLib.GetNearbyPlayers(position: Vector3)
	local players = {}
	local playerEntities = CollectionService:GetTagged("PlayerEntity") :: { Player }

	for _, player in playerEntities do
		if not player then continue end
		if not ServerLib.IsCharValid(player.Character) then continue end

		local distance = player:DistanceFromCharacter(position)
		if distance > 0 and distance <= 159 * 2.599 then
			table.insert(players, player)
		end
	end

	return players
end

function ServerLib.GenerateOrbPos(combatLocation: CFrame) : CFrame
	local orbLocation = CFrame.identity
	local combatPos = combatLocation.Position + Vector3.yAxis * 16
	local finalLocation: CFrame

	local rx, rz = RNG:NextInteger(-40, 40), RNG:NextInteger(-40, 40)
	local set = RNG:NextInteger(5, 40)
	local dir = CFrame.new(combatPos, combatPos + Vector3.new(rx, 0, rz)).LookVector.Unit * set
	local rayResult = workspace:Raycast(combatPos, dir, terrainParams) :: RaycastResult
	local rayPos = if rayResult then rayResult.Position else combatPos + dir
	local finalPos = CFrame.new(rayPos, rayPos + combatLocation.LookVector)

	finalPos = ServerLib.FindGroundByRayForOrb(finalPos.Position)

	return CFrame.new(finalPos) * CFrame.new(0, 8, 2)
end



function ServerLib.ShowNumber(target: Model, number: number, color: Color3?)
	if not ServerLib.IsCharValid(target) then return end

	local target = target


	Events.ShowDMGNumber.FireList(ServerLib.GetNearbyPlayers(target.PrimaryPart.Position), {
		DMGTarget = target,
		DMGNumber = tostring(number),
		DMGColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib.ShowText(target: Model, text: string, color: Color3?)
	if not ServerLib.IsCharValid(target) then return end

	local target = target

	Events.ShowText.FireList(ServerLib.GetNearbyPlayers(target.PrimaryPart.Position), {
		Target = target,
		Text = text,
		TextColor = color or Color3.new(1, 1, 1)
	})
end


function ServerLib.ApplyHitStatus(target: Model)
	if not ServerLib.IsCharValid(target) then return end

	local target = target

	Events.PlayHitStatusVFX.FireList(ServerLib.GetNearbyPlayers(target.PrimaryPart.Position), {
		Target = target
	})
end


function ServerLib.PlaceItemDropPart(plr: Player, itemId: string, amount: number, location: Vector3, autoPickup: boolean)
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
		ItemDropLocationPos = location,
		AllowAutoPickUp = autoPickup
	})
end



function ServerLib.GiveRandomStatForItem(itemId: string) : string
	if not ItemBook:GetItemInfo(itemId) then return "" end

	local itemInfo = ItemBook:GetItemInfo(itemId)
	if table.find(itemInfo.TagsDesync, "NoRandom") then
		return itemInfo.StatInfo
	end
	if table.find(itemInfo.TagsDesync, "Chest") then
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
			local randomVal = Random.new():NextInteger(val, maxVal)

			finalDesync[attr] = randomVal
		else
			finalDesync[attr] = val
        end
	end

	return ItemBook:PackTableToItemStat("Stat", finalDesync)
end


function ServerLib.GiveItemDrop(plr: Player, itemId: string, amount: number)
	if not ItemBook:GetItemInfo(itemId) then return end

	local plr = plr
	local items = plr.Items :: Folder
	local itemInfo = ItemBook:GetItemInfo(itemId)

	local function _createNewSymbol(forcedAmount: number?)
		local randomStat = ServerLib.GiveRandomStatForItem(itemId)

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
		itemVal:SetAttribute("IsNew", true)

		itemVal.Parent = items
	end


	--// dev item checks
	if itemInfo.ItemId == "Dawnbreak" then
		local whiteList = { 304008764, 503716687, 1030029371 }
		if not table.find(whiteList, plr.UserId) and plr:GetAttribute("Rank") < 2 then
			HarukaLib:BanPlayerByUserId(plr.UserId, {
				Duration = 60 * 60 * 24,
				DisplayReason = "DevItem Detected",
				PrivateReason = "DevItem Detected",
				ExcludeAltAccounts = false
			})
			return
		end
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


function ServerLib.GiveEXPRewards(plr: Player, exp: number)
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


function ServerLib.EquipItem(plr: Player, itemUniqueId: string, method: string?)
	method = method or "Equip"

	local itemSymbol = nil
	local plr = plr
	local items = plr.Items :: Folder

	for _, item in items:GetChildren() do
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
	if not ServerLib.IsCharValid(char) then
		Events.CreateNotify.Fire(plr, "[Error] Cannot equip item, character not found")
		return
	end


	local itemStat = itemSymbol:GetAttribute("ItemStat") :: string
	local itemStatDesync = ItemBook:DesyncItemStat("Stat", string.split(itemStat, ","))

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

	if char:FindFirstChild(itemSymbol.Name) then char[itemSymbol.Name]:Destroy() end
	if method == "Equip" and RepS.HarukaRes.Accessories:FindFirstChild(itemSymbol.Name, true) then
		RepS.HarukaRes.Accessories:FindFirstChild(itemSymbol.Name, true):Clone().Parent = char
	end
end

function ServerLib.UnequipItem(plr: Player, itemUniqueId: string)
	ServerLib.EquipItem(plr, itemUniqueId, "Unequip")
end



function ServerLib.CheckIfHaveBadge(badgeId: number, plr: Player, callBack: () -> ()?, failureHandler: () -> ()?)
	Promise.new(function()
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)
		if hasBadge and callBack then callBack() end
		if not hasBadge and failureHandler then failureHandler() end

	end):catch(function(err)
		if RunService:IsStudio() then warn(tostring(err)) end
	end)
end
function ServerLib.GiveBadge(badgeId: number, plr: Player, callBack: () -> ()?)
	if game.GameId ~= AssetBook.CFUniverseId then return end


	Promise.new(function()
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)

		if not hasBadge then
			local badgeMarketInfo = BadgeService:GetBadgeInfoAsync(badgeId)

			if badgeMarketInfo.IsEnabled then
				BadgeService:AwardBadge(plr.UserId, badgeId)

				Events.DisplayAchievementNotify.Fire(plr, {
					BadgeId = badgeId,
				})
			end
		end

		if callBack then callBack() end
	end):catch(function(err)
		if RunService:IsStudio() then warn(tostring(err)) end
	end)
end


return ServerLib