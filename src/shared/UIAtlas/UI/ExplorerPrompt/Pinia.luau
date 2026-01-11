
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local wait = task.wait

export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,
    UI: ScreenGui,

	CurrentPromptIndex: Fusion.Value<number>,
	IsUIShown: Fusion.Value<boolean>,
	PromptList: Fusion.Value<{ ObjectValue }>,
}

return function (self: Self)
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end
	local scope = self.scope :: Fusion.Scope

	local char = self.char :: Model

	self.CurrentPromptIndex = Value(1)
	self.IsUIShown = Value(true)

	local promptNodes = {}

	--// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))

	local promptSymbolContainer = Instance.new("Folder")
	promptSymbolContainer.Name = "UI_PromptSymbols"
	promptSymbolContainer.Parent = game:GetService("ServerStorage")
	table.insert(scope, promptSymbolContainer)

	local promptSymbols = FusionComponents.useChildren(scope, promptSymbolContainer)
	self.PromptList = promptSymbols

	--// track prompts
	local function _updatePrompt(prompt: ProximityPrompt)
		if not prompt:IsA("ProximityPrompt") then return end

		local part = prompt.Parent :: BasePart
		if not part then return end
		if not part.Parent then return end

		if not part:IsA("BasePart") then
			warn("Invalid prompt parent object")
			return
		end

		prompt:SetAttribute("PromptUniqueId", HttpService:GenerateGUID(false))
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
		prompt.Style = Enum.ProximityPromptStyle.Custom
		prompt.KeyboardKeyCode = Enum.KeyCode.Home
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 15.99

		promptNodes[prompt] = part
	end
	for _, child: ProximityPrompt in CollectionService:GetTagged("PromptEntity") do
		_updatePrompt(child)
	end
	CollectionService:GetInstanceAddedSignal("PromptEntity"):Connect(_updatePrompt)

	table.insert(scope, task.spawn(function()
		while wait(0.1599) do
			local isAlive = ClientLib:IsCharValid(char)
			local sitting = char.Humanoid.SeatPart

			local nearbyPrompts = {}
			if sitting == nil and isAlive then
				for prompt: ProximityPrompt, part in promptNodes do
					if not prompt then continue end
					if not prompt.Parent then continue end
					if not part then continue end
					if not part.Parent then continue end

					local distance = self.plr:DistanceFromCharacter(part.Position)
					if distance > 0 and distance <= 15.99 then
						table.insert(nearbyPrompts, prompt)
					end
				end
			end
			local uniqueIdList = {}

			for _, prompt: ProximityPrompt in nearbyPrompts do
				if not prompt.Enabled then continue end
				if not prompt:IsDescendantOf(workspace) then continue end

				local uniqueId = prompt:GetAttribute("PromptUniqueId") :: string
				table.insert(uniqueIdList, uniqueId)

				if promptSymbolContainer:FindFirstChild(uniqueId) then continue end

				local symbol = Instance.new("ObjectValue")
				symbol.Name = uniqueId
				symbol.Value = prompt
				symbol.Parent = promptSymbolContainer
			end
			for _, child: Instance in promptSymbolContainer:GetChildren() do
				if not child:IsA("ObjectValue") then continue end

				if not table.find(uniqueIdList, child.Name) then
					child:Destroy()
				end
			end
		end
	end))

	table.insert(scope, Bindables.PromptTriggered.Event:Connect(function(thatPrompt: ProximityPrompt)
		SoundService.SFXs.ChatNext:Play()

		thatPrompt.Enabled = false
		if thatPrompt.Name == "Chest" then
			wait(1.5)
			local chest = thatPrompt:FindFirstAncestorOfClass("Model")
			if not chest then return end

			if chest:GetAttribute("Receiver_"..self.plr.Name) then return end
		elseif thatPrompt.Name == "Gift" or thatPrompt.Name == "Climb" then
			--// do nothing
			return
		else
			wait(0.5)
		end
		thatPrompt.Enabled = true
	end))
	table.insert(scope, PPS.PromptHidden:Connect(function(prompt: ProximityPrompt)
		if prompt.Enabled then return end

		local uniqueId = prompt:GetAttribute("PromptUniqueId") :: string

		if promptSymbolContainer:FindFirstChild(uniqueId) then
			promptSymbolContainer[uniqueId]:Destroy()
		end
	end))

	--// track prompts list
	local promptListObserver = Fusion.Observer(scope, self.PromptList)
	promptListObserver:onBind(function()
		local totalPrompts = #Fusion.peek(self.PromptList)
		local validIndex = Fusion.peek(self.CurrentPromptIndex)

		totalPrompts = math.clamp(totalPrompts, 1, 999)
		validIndex = math.clamp(validIndex, 1, totalPrompts)

		self.CurrentPromptIndex:set(validIndex)
	end)

	--// track index for both PC and controller
	local mouse = self.plr:GetMouse() :: Mouse
	local function _setIndex(nextIndex: number)
		local totalPrompts = #Fusion.peek(self.PromptList)

		totalPrompts = math.clamp(totalPrompts, 1, 999)
		nextIndex = math.clamp(nextIndex, 1, totalPrompts)

		self.CurrentPromptIndex:set(nextIndex)
	end
	table.insert(scope, mouse.WheelBackward:Connect(function()
		_setIndex(Fusion.peek(self.CurrentPromptIndex) + 1)
	end))
	table.insert(scope, mouse.WheelForward:Connect(function()
		_setIndex(Fusion.peek(self.CurrentPromptIndex) - 1)
	end))
	table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		local isGamepad = string.find(input.UserInputType.Name, "Gamepad")
        if not isGamepad then return end

		if input.KeyCode == Enum.KeyCode.DPadUp then
			_setIndex(Fusion.peek(self.CurrentPromptIndex) - 1)
		elseif input.KeyCode == Enum.KeyCode.DPadDown then
			_setIndex(Fusion.peek(self.CurrentPromptIndex) + 1)
		end
	end))

	--// activate
	table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj, gpe)
		if gpe then return end

		if inputObj.KeyCode == KeybindsBook.PC.PromptTrigger or inputObj.KeyCode == KeybindsBook.Console.PromptTrigger then
			if not Fusion.peek(self.IsUIShown) then return end
			if #Fusion.peek(self.PromptList) <= 0 then return end

			local currentPromptIndex = Fusion.peek(self.CurrentPromptIndex) :: number
			local currentPromptSymbol = Fusion.peek(self.PromptList)[currentPromptIndex] :: ObjectValue
			if currentPromptSymbol == nil then return end

			local currentPrompt = currentPromptSymbol.Value :: ProximityPrompt
			if currentPrompt == nil then return end

			if self.plr:FindFirstChild("PromptTriggerCD") then return end

			local cdSymbol = Instance.new("BoolValue")
			cdSymbol.Name = "PromptTriggerCD"
			cdSymbol.Value = true
			cdSymbol.Parent = self.plr
			Debris:AddItem(cdSymbol, 0.2)

			Bindables.PromptTriggered:Fire(currentPrompt)
			Events.PromptTriggered_C.Fire(currentPrompt)
		end
	end))
end