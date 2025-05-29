--!nocheck

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local wait = task.wait


return function (self: table)
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end
	local scope = self.scope :: Fusion.Scope


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
	promptSymbolContainer.Name = "HARUKA_PromptSymbols"
	promptSymbolContainer.Parent = game:GetService("ServerStorage")
	table.insert(scope, promptSymbolContainer)

	self.PromptList = FusionComponents.useFolder(scope, promptSymbolContainer)


	--// track prompts
	local mapComponents = workspace:WaitForChild("MapComponents", 999) :: Folder

	local function _updatePrompt(prompt: ProximityPrompt)
		if not prompt:IsA("ProximityPrompt") then return end


		local part = prompt.Parent :: BasePart
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


		promptNodes[prompt] = part.Position
	end
	for _, child: Instance in mapComponents:GetDescendants() do
		_updatePrompt(child)
	end
	mapComponents.DescendantAdded:Connect(_updatePrompt)



	table.insert(scope, task.spawn(function()
		while wait(0.1599) do
			if not ClientLib:IsCharValid(self.char) then break end

			local nearbyPrompts = {}
			for prompt: ProximityPrompt, position in promptNodes do
				if not prompt then continue end
				if not prompt.Parent then continue end

				local distance = self.plr:DistanceFromCharacter(position)
				if distance > 0 and distance <= 15.99 then
					table.insert(nearbyPrompts, prompt)
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



	table.insert(scope, PPS.PromptTriggered:Connect(function(thatPrompt: ProximityPrompt, thatPlayer: Player)
		if thatPlayer ~= self.plr then return end

		SoundService.SFXs.ChatNext:Play()

		Bindables.ChangePromptState:Fire(thatPrompt)
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


	--// track index
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


	--// activate
	table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj, gpe)
		if gpe then return end

		if inputObj.KeyCode == Enum.KeyCode.F then
			if not Fusion.peek(self.IsUIShown) then return end
			if #Fusion.peek(self.PromptList) <= 0 then return end

			local currentPromptIndex = Fusion.peek(self.CurrentPromptIndex) :: number
			local currentPromptSymbol = Fusion.peek(self.PromptList)[currentPromptIndex] :: ObjectValue
			if currentPromptSymbol == nil then return end

			local currentPrompt = currentPromptSymbol.Value :: ProximityPrompt
			if currentPrompt == nil then return end

			if self.plr:FindFirstChild("PromptInputHoldBeginCD") then return end


			local cdSymbol = Instance.new("BoolValue")
			cdSymbol.Name = "PromptInputHoldBeginCD"
			cdSymbol.Value = true
			cdSymbol.Parent = self.plr
			Debris:AddItem(cdSymbol, 0.2)


			currentPrompt:InputHoldBegin()
		end
	end))
end
