
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local ClientLib = {}

type Dict = { [string]: any }

local terrainPartRaycastParams = RaycastParams.new()
terrainPartRaycastParams.FilterType = Enum.RaycastFilterType.Include
terrainPartRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPartEntity")
terrainPartRaycastParams.IgnoreWater = true

CollectionService:GetInstanceAddedSignal("TerrainPartEntity"):Connect(function(part)
	terrainPartRaycastParams:AddToFilter(part)
end)

function ClientLib:WeldCATypeModel(part: BasePart, welded: Model)
	local target = welded:FindFirstChild("Middle") or welded:FindFirstChild("Base") or welded:FindFirstChild("HumanoidRootPart") or welded:FindFirstChild("Handle")
	local C = welded:GetChildren()
	if welded:FindFirstChild("Meshes") then
		C = welded.Meshes:GetChildren()
	end

	if target == nil then
		warn("Lacking of target part in welded model!")
		return
	end

	for i = 1, #C do
		if HarukaLib:IsBasePartType(C[i]) then
			local W = Instance.new("Weld")
			W.Part0 = target
			W.Part1 = C[i]

			local CJ = CFrame.new(target.Position)
			W.C0 = target.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = target
		end

		local Y = Instance.new("Weld")
		Y.Part0 = part
		Y.Part1 = target
		Y.C0 = CFrame.identity
		Y.Parent = Y.Part0
	end

	local h = welded:QueryDescendants(HarukaLib.BasePartSelector)
	for _, child: BasePart in h do
		child.Anchored = false
	end
end

function ClientLib:FindGroundByRay(givenPos: Vector3) : Vector3
	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 35, -Vector3.yAxis * 159, terrainPartRaycastParams)
	if rayResult then return rayResult.Position end

	return givenPos
end

function ClientLib:WeldWeapon(weapon: Model, char: Model) : Model
	local motor6D = weapon:FindFirstChildOfClass("Motor6D")
	local weldTarget = weapon.Handle:GetAttribute("Weld") :: string

	if not motor6D then warn("No Motor6D found on weapon") return end
	if not weldTarget then warn("Cannot weld weapon, no target specified") return end

	weldTarget = char:FindFirstChild(weldTarget)
	if not weldTarget then warn("Cannot weld weapon, target not found") return end

	motor6D.Part0 = weldTarget
	weapon.Parent = char

	return weapon
end

function ClientLib:FindGroundByRayForOrb(givenPos: Vector3) : Vector3
	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 5, -Vector3.yAxis * 30, terrainPartRaycastParams)
	if rayResult then return rayResult.Position end

	return givenPos
end

function ClientLib:IsModelValid(model: Instance?) : boolean
	if not model then return false end
    if not model.Parent then return false end
    if not model.PrimaryPart then return false end

    return true
end

function ClientLib:IsCharValid(char: Instance?) : boolean
	if not ClientLib:IsModelValid(char) then return false end

	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return false end

	if humanoid.Health <= 0 then return false end

	return true
end

function ClientLib:GetPlayerByUniqueId(uniqueId: string) : Player?
	local player: Player = nil

	for _, thatPlayer: Player in CollectionService:GetTagged("PlayerEntity") do
		if thatPlayer:GetAttribute("HarukaUniqueId") then
			if thatPlayer:GetAttribute("HarukaUniqueId") == uniqueId then
				player = thatPlayer
				break
			end
		end
	end

	return player
end

function ClientLib:PlayWorldSound(sound: Sound, pos: Vector3)
	local part = HarukaLib:CreateMockPart()
	part.Name = "WorldSound_"..sound.Name
	part.CFrame = CFrame.new(pos)

	sound = sound:Clone()
	sound.Volume *= 3
	sound.Parent = part

	part.Parent = workspace.Terrain

	task.wait()
	sound:Play()

	Debris:AddItem(part, sound.TimeLength + 0.5)
end

function ClientLib:TrackEffectListToUI(props: {
	Target: Model,
	Scope: Fusion.Scope,
	GuiContainer: GuiObject
})
	local effectContainer = props.GuiContainer

	local EffectSlot = require(RepS.HarukaShared.UIAtlas.Components.EffectSlot)

	local effectListContainer = Instance.new("Folder")
	effectListContainer.Name = "EffectListSymbols"
	effectListContainer.Parent = props.Target
	table.insert(props.Scope, effectListContainer)

	local effectListEnemy = FusionComponents.useChildren(props.Scope, props.Target.EffectList)
	local containerVal = FusionComponents.useChildren(props.Scope, effectListContainer)

	Fusion.Observer(props.Scope, containerVal):onBind(function()
		local children = #effectListContainer:GetChildren()

		props.GuiContainer.Visible = children > 0
	end)
	Fusion.Observer(props.Scope, effectListEnemy):onBind(function()
		local list = Fusion.peek(effectListEnemy) :: { StringValue }

		for _, effectObj: StringValue in list do
			local uniqueId = effectObj:GetAttribute("TaskUniqueId")

			if effectListContainer:FindFirstChild(uniqueId) then continue end

			local playerOnly = effectObj:GetAttribute("PlayerOnly") :: string
			if playerOnly and playerOnly ~= Players.LocalPlayer.Name then continue end

			local symbol = Instance.new("StringValue")
			symbol.Name = uniqueId
			symbol.Value = effectObj.Value

			local endClock = effectObj:GetAttribute("EndClock") :: number
			local nowClock = DateTime.now().UnixTimestamp

			symbol:SetAttribute("EndClock", endClock)
			symbol:SetAttribute("Power", effectObj:GetAttribute("ExPower"))
			symbol:SetAttribute("Ex", effectObj:GetAttribute("Ex"))

			symbol.Parent = effectListContainer
			Debris:AddItem(symbol, endClock - nowClock)

			local newScope = Fusion.scoped()

			local effectUI = EffectSlot(newScope, symbol)
			effectUI.Parent = effectContainer
			Debris:AddItem(effectUI, endClock - nowClock)

			Promise.delay(endClock - nowClock):andThen(function()
				Fusion.doCleanup(newScope)
			end):catch(function() end)

			local effectUISymbol = Instance.new("ObjectValue")
			effectUISymbol.Name = "EffectUI"
			effectUISymbol.Value = effectUI
			effectUISymbol.Parent = symbol
		end
		for _, effectSymbol: StringValue in effectListContainer:GetChildren() do
			local found = false
			for _, effectObj: StringValue in list do
				if effectObj:GetAttribute("TaskUniqueId") == effectSymbol.Name then
					found = true
					break
				end
			end

			if not found then
				local copy = effectSymbol:Clone()
				Debris:AddItem(copy, 5)

				effectSymbol:Destroy()
				effectSymbol = copy

				local effectUISymbol = effectSymbol:FindFirstChild("EffectUI") :: ObjectValue
				if not effectUISymbol then continue end

				local effectUI = effectUISymbol.Value :: GuiObject
				if not effectUI then continue end

				effectUI:Destroy()
			end
		end
	end)
end

function ClientLib:TrackInputTextbox(props: {
	Scope: Fusion.Scope,
	TextBox: TextBox,

	Callback: (amountVal: Fusion.Value<number>) -> nil
}): Fusion.Value<number>

	local amount = Fusion.Value(props.Scope, 1)

	props.TextBox.FocusLost:Connect(function()
		if tostring(Fusion.peek(amount)) == props.TextBox.Text then return end --- infinite loop prevention

		local text = props.TextBox.Text :: string
		local input = tonumber(text)

		if input == nil then input = 1 end
		if input ~= input then input = 1 end

		input = math.floor(input)
		input = math.clamp(input, 1, 999)

		amount:set(input)

		props.TextBox.Text = tostring(input)
	end)

	Fusion.Observer(props.Scope, amount):onBind(function()
		props.TextBox.Text = tostring(Fusion.peek(amount))
		props.Callback(amount)
	end)

	return amount
end

function ClientLib:LoadLightingPreset(presetId: string)
	local lightingPresets = RepS.Packages.LightingPresets :: Folder

	if not lightingPresets:FindFirstChild(presetId) then
		warn("Invalid lighting preset id: "..presetId)
		return
	end

	local config = lightingPresets[presetId]:FindFirstChild("Configuration") :: Configuration

	for _, eff: Instance in Lighting:GetChildren() do
		if not eff:HasTag("VFXEffect") then
			eff:Destroy()
		end
	end

	for _, preset: Instance in lightingPresets[presetId]:GetChildren() do
		preset:Clone().Parent = Lighting
	end
	if config then
		config = require(config.Config)

		for attr: string, value: any in config do
			Lighting[attr] = value
		end

		local cloudsConfig = lightingPresets[presetId].Configuration:FindFirstChild("CloudConfig") :: ModuleScript
		if cloudsConfig then
			local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
			if clouds then
				for attr: string, value: any in require(cloudsConfig) do
					clouds[attr] = value
				end
			end
		end
	end
end

function ClientLib:TrackCharDiedEvent(props: {
	Add: (item: any) -> any,
	Empty: () -> nil,

	Char: Model,
	Player: Player,
})
	local Add, Empty = props.Add, props.Empty
	local char = props.Char
	local plr = props.Player

	Add(plr.CharacterRemoving:Connect(function()
		Empty()
	end))
	Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			Empty()
		end
	end))
	Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function(newParent)
		if newParent and newParent:IsA("Model") then
			if newParent.PrimaryPart == nil and not newParent:FindFirstChildOfClass("Humanoid") then
				Empty()
				return
			end
		else
			Empty()
		end
	end))
end

function ClientLib:InitUIFramework(t: Dict, plr: Player, uiId: string, withoutChar: boolean?)
	t.plr = plr
	if not withoutChar then
		t.char = plr.Character
	end
	t.scope = Fusion.scoped()

	if plr.PlayerGui:FindFirstChild(uiId) then
		plr.PlayerGui[uiId]:Destroy()
    end
end

return ClientLib