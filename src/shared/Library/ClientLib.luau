--!nocheck

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local Maid = require(RepS.HarukaShared.Shared.Maid)

local ClientLib = {}


function ClientLib:WeldModel(part: Part, welded: Model)
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

	local h = welded:GetDescendants()
	for _, child: BasePart in h do
		if HarukaLib:IsBasePartType(child) then child.Anchored = false end
	end
end


function ClientLib:FindGroundByRay(givenPos: Vector3) : Vector3
	local rParams = RaycastParams.new()
	rParams.RespectCanCollide = false
	rParams.IgnoreWater = true
	rParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
	rParams.FilterType = Enum.RaycastFilterType.Include


	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 35, -Vector3.yAxis * 159, rParams)

	rParams = nil --// I assume it needs to be destroyed
	if rayResult then return rayResult.Position end

	return givenPos
end


function ClientLib:FindGroundByRayForOrb(givenPos: Vector3) : Vector3
	local rParams = RaycastParams.new()
	rParams.RespectCanCollide = false
	rParams.IgnoreWater = true
	rParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
	rParams.FilterType = Enum.RaycastFilterType.Include


	local rayResult = workspace:Raycast(givenPos + Vector3.yAxis * 7, -Vector3.yAxis * (26 + 7), rParams)

	rParams = nil --// I assume it needs to be destroyed
	if rayResult then return rayResult.Position end

	return givenPos
end


function ClientLib:IsModelValid(model: Model) : boolean
	if not model then return false end
    if not model.Parent then return false end
    if not model.PrimaryPart then return false end

    return true
end


function ClientLib:IsCharValid(char: Model) : boolean
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
	GuiContainer: GuiObject,
}) : Fusion.Value

	local EffectSlot = require(RepS.HarukaShared.UIAtlas.Components.EffectSlot)


	local effectListContainer = Instance.new("Folder")
	effectListContainer.Name = "EffectListSymbols"
	effectListContainer.Parent = props.Target
	table.insert(props.Scope, effectListContainer)

	local effectListEnemy = FusionComponents.useFolder(props.Scope, props.Target.EffectList)

	Fusion.Observer(props.Scope, effectListEnemy):onBind(function()
		local list = Fusion.peek(effectListEnemy) :: { StringValue }

		for _, effectObj: StringValue in list do
			local uniqueId = effectObj:GetAttribute("TaskUniqueId")

			if effectListContainer:FindFirstChild(uniqueId) then continue end

			local symbol = Instance.new("StringValue")
			symbol.Name = uniqueId
			symbol.Value = effectObj.Value

			local endClock = effectObj:GetAttribute("EndClock") :: number
			local nowClock = DateTime.now().UnixTimestamp

			symbol:SetAttribute("EndClock", endClock)
			symbol:SetAttribute("Power", effectObj:GetAttribute("ExPower"))
			symbol:SetAttribute("Ex", effectObj:GetAttribute("Ex"))

			symbol.Parent = effectListContainer
			Maid:AddItem(symbol, endClock - nowClock)

			local effectUI = EffectSlot(props.Scope, symbol)
			effectUI.Parent = props.GuiContainer.EffectList
			Maid:AddItem(effectUI, endClock - nowClock)


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

	return effectListEnemy
end


function ClientLib:TrackInputTextbox(props: {
	Scope: Fusion.Scope,
	TextBox: TextBox,

	Callback: (amountVal: Fusion.Value) -> nil
}): Fusion.Value

	local amount = Fusion.Value(props.Scope, 1)

	props.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if tostring(Fusion.peek(amount)) == props.TextBox.Text then return end --- infinite loop prevention

		local text = props.TextBox.Text :: string
		local input = tonumber(text)

		if input == nil then input = 1 end
		if input ~= input then input = 1 end

		input = math.floor(input)
		input = math.clamp(input, 1, 99)

		amount:set(input)

		props.TextBox.Text = tostring(input)
	end)

	Fusion.Observer(props.Scope, amount):onBind(function()
		props.TextBox.Text = tostring(Fusion.peek(amount))
		props.Callback(amount)
	end)

	return amount
end


return ClientLib
