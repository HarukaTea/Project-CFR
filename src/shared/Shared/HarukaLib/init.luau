
local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Tween = require(script.HarukaTween)
local TableUtils = require(script.HarukaTableUtils)

local HarukaLib = {}

--[[
	Helper function to convert a number to a string with a suffix.

    **Example:**
    ``````lua
    HarukaLib:ShortifyNumber(1000, 2) --- 1.00K
    ``````
]]
function HarukaLib:ShortifyNumber(number: number, decimalPlaces: number) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = math.floor(math.floor(math.log10(number)) / 3)

	decimalPlaces = decimalPlaces or 2
    local outputType = "%.".. tostring(decimalPlaces).. "f"

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return string.format(outputType, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		end
	end

	return tostring(number)
end

--[[
    Get the device type
]]
function HarukaLib:GetDevice() : "PC" | "Mobile" | "Console" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then device = "Console" end
	if UIS.TouchEnabled then device = "Mobile" end
	if UIS.VREnabled then device = "VR" end

	return device
end

--[[
    Get the accurate device type
]]
function HarukaLib:GetAccurateDevice() : "PC" | "Xbox" | "PlayStation" | "Phone" | "Tablet" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then
		local key = Enum.KeyCode.ButtonA

		if UIS:GetStringForKeyCode(key) == "ButtonA" then device = "Xbox" end
		if UIS:GetStringForKeyCode(key) == "ButtonCross" then device = "PlayStation" end
	end
	if UIS.TouchEnabled then
		local screenSize = workspace.CurrentCamera.ViewportSize

		if screenSize.X < screenSize.Y then
			if screenSize.X < 600 then device = "Phone" else device = "Tablet" end

		elseif screenSize.X > screenSize.Y then
			if screenSize.Y < 600 then device = "Phone" else device = "Tablet" end
		end
	end
	if UIS.VREnabled then device = "VR" end

	return device
end

--[[
	Increase attribute value for an instance.
	It will not work if attribute is not a number.

	But it will create a default value (0) if attribute is not exist.

	**Example:**
	``````lua
	obj.Health = 0
	HarukaLib:AddAttr(obj, "Health", 10) --- obj.Health = 10
	``````
]]
function HarukaLib:AddAttr(obj: Instance, attribute: string, val: number)
	if obj:GetAttribute(attribute) == nil then
		obj:SetAttribute(attribute, 0)
	end
	if typeof(obj:GetAttribute(attribute)) ~= "number" then
		return
	end

	local attrVal = obj:GetAttribute(attribute) :: number
	obj:SetAttribute(attribute, attrVal + val)
end

--[[
	The same as `obj:ClearAllChildren()`, but it applies for attributes
]]
function HarukaLib:ClearAllAttributes(obj: Instance)
	for attribute: string, _ in obj:GetAttributes() do
		obj:SetAttribute(attribute, nil)
	end
end

--[[
	Detect if the given position is inside any of the given regions.
]]
function HarukaLib:IsInRegion(position: Vector3, regions: { BasePart }) : BasePart?
	for _, child: BasePart in regions do
		if child == nil then continue end
		if not child:IsA("BasePart") then continue end

		local point = child.CFrame:PointToObjectSpace(position)
		local size = child.Size

		local sx, sy, sz = size.X / 2, size.Y / 2, size.Z / 2

		if math.abs(point.X) <= sx + 0.01
			and math.abs(point.Y) <= sy + 0.01
			and math.abs(point.Z) <= sz + 0.01 then

			return child
		end
	end

	return nil
end

local COLOR_LIST = {
	["<blue>"] = [[<font color="#80c0ff">]],
	["<purple>"] = [[<font color="#ffacff">]],
	["<red>"] = [[<font color="#ff5e41">]],
	["<orange>"] = [[<font color="#ff9999">]],
	["<yellow>"] = [[<font color="#ffe699">]],
	["<green>"] = [[<font color="#99ff88">]],
	["<cyan>"] = [[<font color="#80ffd7">]],
	["<white>"] = [[<font color="#ffffff">]],
	["<black>"] = [[<font color="#2d3436">]],
	["<pink>"] = [[<font color="#ffacff">]],
	["<gray>"] = [[<font color="#747d8c">]],
	["<grey>"] = [[<font color="#747d8c">]],

	["</blue>"] = [[</font>]],
	["</purple>"] = [[</font>]],
	["</red>"] = [[</font>]],
	["</orange>"] = [[</font>]],
	["</yellow>"] = [[</font>]],
	["</green>"] = [[</font>]],
	["</cyan>"] = [[</font>]],
	["</white>"] = [[</font>]],
	["</black>"] = [[</font>]],
	["</pink>"] = [[</font>]],
	["</gray>"] = [[</font>]],
	["</grey>"] = [[</font>]],
} :: { [string]: string }

--[[
	Transform a plain text to rich text, it will only work when `RichText = true`

	**Example:**
	``````lua
	HarukaLib:RichTextify("<blue>Hello</font>,<red>World</font>!")
	``````
]]
function HarukaLib:RichTextify(text: string) : string
	if not text then return "" end

	for oriTag: string, rbxColorTag: string in COLOR_LIST do
		text = string.gsub(text, oriTag, rbxColorTag)
	end

	return text
end

--[[
	Serialize and deserialize roblox types to a table.
	It only supports `CFrame`, `Vector3`, and `Color3`.
]]
function HarukaLib:PackData(method: "Pack" | "Unpack", val: any) : any
	local valType = typeof(val)

	if method == "Pack" then
		if valType == "CFrame" then
			return { "CFrame", val:GetComponents() }

		elseif valType == "Vector3" then
			return { "Vector3", math.floor(val.X), math.floor(val.Y), math.floor(val.Z) }

		elseif valType == "Color3" then
			return { "Color3", val.R, val.G, val.B }
		else
			return val
		end

	elseif method == "Unpack" then
		if valType ~= "table" then return val end

		local valType: string = val[1]
		if valType == "CFrame" then
			return CFrame.new(unpack(val, 2, #val))

		elseif valType == "Vector3" then
			return Vector3.new(unpack(val, 2, #val))

		elseif valType == "Color3" then
			return Color3.fromRGB(unpack(val, 2, #val))
		else
			return val
		end
	end

	return val
end

--[[
	Inspired by `Fusion.Hydrate`, it will add a tracker to the given props/attrs,
	and call it funcs when the value of the prop/attr is changed.

	Return a function to destroy the tracker.
]]
function HarukaLib:Hydrate(obj: Instance, props: { [string]: (val: any) -> nil }) : () -> nil
	local Add, Empty = HarukaLib.Bin()

	for prop: string, func: (val: any) -> nil in props do
		if string.find(prop, "Attr") then
			local _, endPos = string.find(prop, "Attr")
			local attr = string.sub(prop, endPos + 2)

			local success, err = pcall(function()
				task.spawn(func, obj:GetAttribute(attr))
			end)
			if not success and RunService:IsStudio() then
				warn(err)
			end

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif string.find(prop, "Prop") then
			local _, endPos = string.find(prop, "Prop")
			local propName = string.sub(prop, endPos + 2)

			local success, err = pcall(function()
				task.spawn(func, obj[propName])
			end)
			if not success and RunService:IsStudio() then
				warn(err)
			end

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	return Empty
end

--[[
	Inspired by `Janitor`, and `Fusion.doCleanup`, you can add anything to the bin.

	Return a function to destroy the items inside the bin, bin can reused.
]]
function HarukaLib.Bin()
	local bin = {}

	local function doCleanup(item: any)
		if typeof(item) == "Instance" then
			item:Destroy()

		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()

		elseif typeof(item) == "function" then
			pcall(item)

		elseif typeof(item) == "thread" then
			if item then task.cancel(item) end

		elseif typeof(item) == "table" then
			if typeof(item.destroy) == "function" then
				item:destroy()

			elseif typeof(item.Destroy) == "function" then
				item:Destroy()

			elseif typeof(item.Cancel) == "function" then
				item:Cancel()

			elseif typeof(item.cancel) == "function" then
				item:cancel()

			--- cancel any exist promises
			elseif getmetatable(item) then
				if item.prototype then item:cancel() end

			elseif item[1] ~= nil then
				for index = #item, 1, -1 do
					doCleanup(item[index])

					item[index] = nil
				end
			end
		end
	end

	return function (item: any)
		table.insert(bin, item)

		return item

	end, function()
		pcall(doCleanup, bin)

		table.clear(bin)
	end
end

--[[
	Inspired by `Timer`, just like `window.setInterval` in javascript
]]
function HarukaLib.Clock(tickTime: number, func: () -> (), runInstantly: boolean?)
	local nowTime = 0
	local dropTime = tickTime * 10

	if runInstantly then
		local success, err = pcall(func)
		if not success then
			warn(err)
		end
	end

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		nowTime += deltaTime

		if nowTime > dropTime then
			nowTime = 0
			func()

		elseif nowTime > tickTime then
			nowTime -= tickTime

			func()
		end
	end)

	return function ()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

--[[
	Inspired by `AdvancedTweenV2`, it can tween any property of any instance.

	Return a signal class, it will fire when the tween is completed.
]]
function HarukaLib:Tween(obj: Instance, style: TweenInfo, goal: { [string]: any }, needSignal: boolean?) : BindableEvent
	return Tween(obj, style, goal, needSignal)
end

--[[
	Inspired by `t`, it can typecheck any value in runtime
]]
function HarukaLib:TypeCheck(checkTask: string, val: any, props: {
	Min: number?,
	Max: number?
}?) : boolean

	local props = props or {
		Min = 0,
		Max = 0
	}
	local success = pcall(function()
		if checkTask == "Integer" then
			assert(type(val) == "number")
			assert(val % 1 == 0)

		elseif checkTask == "Min" then
			assert(type(val) == "number")
			assert(val >= props.Min)

		elseif checkTask == "Max" then
			assert(type(val) == "number")
			assert(val <= props.Max)

		elseif checkTask == "MinMax" then
			assert(type(val) == "number")
			assert(val >= props.Min)
			assert(val <= props.Max)
		end
	end)

	return success
end

--[[
	Inspired by `Sol's RNG`, basically it will roll a thing depends on the weight you give

	**Example:**
	``````lua
	HarukaLib:RollLoot({
		["Gold"] = 50,
		["Diamond"] = 30,
		["Silver"] = 20
	})
	``````

	return a tuple of `(item, weight, entry)`
]]
function HarukaLib:RollLoot(loots: { [string]: number }, luck: number?) : (string, number, number)
	luck = luck or 1

	local items = {}
	local totalEffectiveWeight = 0

	for name, weight in pairs(loots) do
		if weight > 0 then
			local effective = weight ^ (1 / luck)
			table.insert(items, {
				Name = name,
				Weight = weight,
				Effective = effective,
			})

			totalEffectiveWeight += effective
		end
	end

	local r = Random.new():NextNumber() * totalEffectiveWeight
	local cumulative = 0

	for index, item in ipairs(items) do
		cumulative += item.Effective
		if r <= cumulative then
			return item.Name, item.Weight, index
		end
	end

	local last = items[#items]
	return last.Name, last.Weight, #items
end

--[[
	It will freeze/unfreeze player controls
]]
function HarukaLib:FreezePlayerControls(action: "Freeze" | "Unfreeze")
    if action == "Freeze" then
        UIS.ModalEnabled = true

        CAS:BindActionAtPriority("FreezeControl", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, unpack(Enum.PlayerActions:GetEnumItems()))
    else
        UIS.ModalEnabled = false

        CAS:UnbindAction("FreezeControl")
    end
end

--[[
	Helper function to set the collision group of an object and its children
]]
function HarukaLib:SetCollisionGroup(obj: any, group: string)
	if HarukaLib:IsBasePartType(obj) then obj.CollisionGroup = group end

	for _, child in obj:GetChildren() do
		HarukaLib:SetCollisionGroup(child, group)
	end
end

--[[
	Helper function to combine id with the prefix `"rbxassetid://"`
]]
function HarukaLib:CombineRbxId(id: string | number)
    if not id then
        return "rbxassetid://0"
    end

    return "rbxassetid://".. id
end

--[[
	Helper function to ban a player, Server-Side ONLY
]]
function HarukaLib:BanPlayerByUserId(userId: number, properties: {
	Duration: number,
	DisplayReason: string,
	PrivateReason: string,
	ExcludeAltAccounts: boolean,
})
	local config = {
		UserIds = { userId },
		Duration = properties.Duration,
		DisplayReason = properties.DisplayReason,
		PrivateReason = properties.PrivateReason,
		ExcludeAltAccounts = properties.ExcludeAltAccounts,
		ApplyToUniverse = true
	}

	local success, err = pcall(function()
		return Players:BanAsync(config)
	end)
	if not success then
		warn(err)
	end
end

--[[
	Helper function to unban a player, Server-Side ONLY
]]
function HarukaLib:UnbanPlayerByUserId(userId: number)
	local config = {
		UserIds = { userId },
		ApplyToUniverse = true
	}

	local success, err = pcall(function()
		return Players:UnbanAsync(config)
	end)
	if not success then
		warn(err)
	end
end

--[[
	Helper function to tween the transparency of a UI element
]]
function HarukaLib:UITween(ui: GuiObject, style: "In" | "Out", props: {
	DelayTime: number?,
	TweenTime: number?,

	SetOriPropsWhenOut: boolean?,
	FollowOriPropsWhenIn: boolean?,
	TweenCallback: nil | (clonedTweenOutUI: GuiObject) -> nil,

	PosTweenStyle: string?,
	PosTweenBaseElement: GuiObject?,
	PosTweenOffset: number?
})
	props = props or {
		DelayTime = nil,
		TweenTime = nil,
		SetOriPropsWhenOut = nil,
		FollowOriPropsWhenIn = nil,
		TweenCallback = nil,
		PosTweenStyle = nil,
		PosTweenBaseElement = nil,
		PosTweenOffset = nil
	}

	if props.TweenCallback and style == "Out" then
		local clonedTweenOutUI = ui:Clone()
		clonedTweenOutUI.Parent = ui.Parent
		Debris:AddItem(clonedTweenOutUI, 1)

		ui = clonedTweenOutUI

		pcall(props.TweenCallback, clonedTweenOutUI)

	elseif props.TweenCallback and style == "In" then
		pcall(props.TweenCallback, ui)
	end

	props.DelayTime = props.DelayTime or 0
	props.TweenTime = props.TweenTime or 0.2

	local tweenInfo = TweenInfo.new(props.TweenTime,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out
	)
	local tweenObjs = ui:QueryDescendants("Frame,TextLabel,TextButton,ImageLabel,ImageButton,ScrollingFrame,CanvasGroup,UIStroke")
	local tweenObjs: { GuiObject } = tweenObjs

	table.insert(tweenObjs, ui)

	local function _tweenGoal(obj: GuiObject, attr: string, tweenProps: { [string]: any })
		if not obj then return end
		if not obj.Parent then return end

		pcall(function()
			local original = obj[attr] :: number?
			local attrOriginal = obj:GetAttribute("HarukaUITween_Ori_"..attr) :: number?

			if style == "In" then
				obj[attr] = 1

				if original ~= 1 then tweenProps[attr] = original end
				if props.FollowOriPropsWhenIn and attrOriginal and attrOriginal ~= 1 then
					tweenProps[attr] = attrOriginal
				end

			elseif style == "Out" then
				if obj[attr] then
					tweenProps[attr] = 1

					if props.SetOriPropsWhenOut and obj:GetAttribute("HarukaUITween_Ori_"..attr) == nil then
						obj:SetAttribute("HarukaUITween_Ori_"..attr, original)
					end
				end
			end
		end)
		pcall(function()
			obj.Interactable = false
		end)
	end
	local function _startTween(obj: GuiObject, tweenProps: { [string]: any })
		if not obj then return end
		if not obj.Parent then return end

		pcall(function()
			HarukaLib:CreateTween(obj, tweenInfo, tweenProps):Play()
		end)
		pcall(function()
			obj.Interactable = true
		end)
	end

	for _, obj in tweenObjs do
		local tweenProps = {}

		if not obj then continue end
		if not obj.Parent then continue end

		if obj:IsA("Frame") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)

		elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)
			_tweenGoal(obj, "TextTransparency", tweenProps)
			_tweenGoal(obj, "TextStrokeTransparency", tweenProps)

		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "ImageTransparency", tweenProps)
			_tweenGoal(obj, "BackgroundTransparency", tweenProps)

		elseif obj:IsA("ScrollingFrame") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)
			_tweenGoal(obj, "ScrollBarImageTransparency", tweenProps)

		elseif obj:IsA("CanvasGroup") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "GroupTransparency", tweenProps)

		elseif obj:IsA("UIStroke") then
			if not obj.Enabled then continue end

			_tweenGoal(obj, "Transparency", tweenProps)
		else
			continue
		end

		if props.DelayTime > 0 then
			task.delay(props.DelayTime, _startTween, obj, tweenProps)
		else
			_startTween(obj, tweenProps)
		end
	end

	if props.PosTweenStyle and props.PosTweenBaseElement then
		local nowPos = props.PosTweenBaseElement.Position
		local goalPos = nowPos

		local offset = props.PosTweenOffset or 15.99 / 2
		local fixFactor = if style == "In" then 1 else -1

		if props.PosTweenStyle == "FromB2T" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset, nowPos.Y.Scale, nowPos.Y.Offset + offset * fixFactor)

		elseif props.PosTweenStyle == "FromT2B" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset, nowPos.Y.Scale, nowPos.Y.Offset - offset * fixFactor)

		elseif props.PosTweenStyle == "FromL2R" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset - offset * fixFactor, nowPos.Y.Scale, nowPos.Y.Offset)

		elseif props.PosTweenStyle == "FromR2L" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset + offset * fixFactor, nowPos.Y.Scale, nowPos.Y.Offset)
		end

		if style == "Out" then
			goalPos, nowPos = nowPos, goalPos
		end

		local function _tweenPosition()
			props.PosTweenBaseElement.Position = goalPos

			local tween = TweenService:Create(props.PosTweenBaseElement, tweenInfo, {
				Position = nowPos
			})
			tween.Completed:Once(function()
				props.PosTweenBaseElement.Position = if style == "In" then nowPos else goalPos

				tween:Destroy()
			end)
			tween:Play()
		end

		if props.DelayTime > 0 then
			task.delay(props.DelayTime, _tweenPosition)
		else
			_tweenPosition()
		end
	end
end

--[[
	Helper function to fix the correct result of `CFrame.lookAt` in RPG series
]]
function HarukaLib:CFLookAt(pos1: Vector3, pos2: Vector3) : CFrame
	local finalCFrame = CFrame.identity
	local lookAt = CFrame.lookAt(pos1, pos2)

	if lookAt == lookAt then
		finalCFrame = CFrame.new(pos1) * lookAt.Rotation

		local _, ry, _ = finalCFrame:ToOrientation()
		finalCFrame = CFrame.new(finalCFrame.Position) * CFrame.Angles(0, ry, 0).Rotation
	end

	return finalCFrame
end

--[[
	Helper function to format a number with comma separator

	**Example:**
	``````lua
	HarukaLib:CommaifyNumber(123456789) -- "123,456,789"
	``````
]]
function HarukaLib:CommaifyNumber(num: number) : string
	if not num then return "" end

	local formatted = tostring(math.floor(num))
	while true do
		local newFormatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = newFormatted

		if k == 0 then break end
	end

	return formatted
end

--[[
	Helper function to format a number of seconds into a string of time format

	**Example:**
	``````lua
	HarukaLib:TimeifyNumber(123) -- "02:03"
	``````
]]
function HarukaLib:TimeifyNumber(seconds: number, shouldScaleToMs: boolean?) : string
	if seconds == nil then return "??:??" end
	if seconds <= 0 then return "00:00" end

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	if not shouldScaleToMs then
		return string.format("%02d:%02d", minutes, secs)
	else
		local ms = seconds * 1000
		minutes = math.floor(ms / 60000)

		ms %= 60000
		seconds = math.floor(ms / 1000)

		ms %= 1000

		return string.format("%d:%02d.%03d", minutes, seconds, ms)
	end
end

--[[
	A quick shortcut to `string.sub(UUID, 1, 8)`

	Example Output: `123e4567-e89b-12d3-a456-426655440000`
]]
function HarukaLib:GenerateUUID() : string
	return string.sub(HttpService:GenerateGUID(false), 1, 8)
end

--[[
	A simple function of Queue
]]
export type HarukaQueue = {
	IsEmpty: (self: HarukaQueue) -> boolean,
	GetItemsInQueue: (self: HarukaQueue) -> number,
	IsLocked: (self: HarukaQueue) -> boolean,

	Push: (self: HarukaQueue, value: any) -> nil,
	Pop: (self: HarukaQueue) -> any?,
	Destroy: (self: HarukaQueue) -> nil,

	SpawnMutex: (self: HarukaQueue, delay: number) -> nil,

	RefreshSignal: BindableEvent,
}
function HarukaLib.Queue() : HarukaQueue
	local Queue = {} :: HarukaQueue
	Queue.__index = Queue

	function Queue.new() : HarukaQueue
		local self = setmetatable({}, Queue)

		self.First = 0
		self.Last = -1
		self.Queue = {}
		self.Locked = false

		self.RefreshSignal = Instance.new("BindableEvent")

		return self
	end

	function Queue:IsEmpty() : boolean
		return self.First > self.Last
	end
	function Queue:GetItemsInQueue() : number
		return #self.Queue
	end

	function Queue:SpawnMutex(delay: number)
		self.Locked = true

		task.delay(delay, function()
			self.Locked = false
			self.RefreshSignal:Fire()
		end)
	end
	function Queue:IsLocked() : boolean
		return self.Locked
	end

	function Queue:Push(value: any)
		local last = self.Last + 1
		self.Last = last
		self.Queue[last] = value

		if not self.Locked then
			self.RefreshSignal:Fire()
		end
	end
	function Queue:Pop() : any?
		if self:IsEmpty() then
			return nil
		end

		local first = self.First
		local value = self.Queue[first]
		self.Queue[first] = nil
		self.First = first + 1

		return value
	end

	function Queue:Destroy()
		self.RefreshSignal:Destroy()
	end

	return Queue.new()
end

--[[
	A list of helper functions to manipulate table
]]
HarukaLib.TableUtils = TableUtils

--[[
	A quick helper function to emit particles
]]
function HarukaLib:EmitParticles(obj: Instance, childrenOnly: boolean?)
	if childrenOnly then
		for _, child in obj:GetChildren() do
			if not child:IsA("ParticleEmitter") then continue end

			child:Emit(child:GetAttribute("EmitCount") or 0)
		end
	else
		for _, child in obj:QueryDescendants("ParticleEmitter") do
			child:Emit(child:GetAttribute("EmitCount") or 0)
		end
	end
end

--[[
	Quickly judge if it's a part
]]
function HarukaLib:IsBasePartType(obj: Instance) : boolean
	return obj:IsA("BasePart") or obj:IsA("UnionOperation") or obj:IsA("CornerWedgePart")
end
HarukaLib.BasePartSelector = "BasePart,UnionOperation,CornerWedgePart"

--[[
	Quickly return an empty part for mocking
]]
function HarukaLib:CreateMockPart() : BasePart
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = "MockPart"
	part.Size = Vector3.one
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.CanQuery = false
	part.Massless = true
	part.EnableFluidForces = false
	part.CollisionGroup = "NoCollision"

	return part
end

--[[
	Quickly return an empty part for mocking
]]
function HarukaLib:CreateMockModel() : BasePart
	local model = Instance.new("Model")
	model.Name = "MockModel"

	local part = HarukaLib:CreateMockPart()
	part.Parent = model

	model.PrimaryPart = part

	return model
end

--[[
	Quickly set all particles of an object to a state
]]
function HarukaLib:SetParticleState(obj: Instance, state: boolean, childrenOnly: boolean?)
	if childrenOnly then
		for _, child in obj:GetChildren() do
			if not child:IsA("ParticleEmitter") then continue end

			child.Enabled = state
		end
	else
		for _, child in obj:QueryDescendants("ParticleEmitter") do
			child.Enabled = state
		end
	end
end

--[[
	template for creating a new `Tween`, and destroying it after it's done
]]
function HarukaLib:CreateTween(instance: Instance, tweenInfo: TweenInfo, tweenProperties: { [string]: any })
	local tweenObj = TweenService:Create(instance, tweenInfo, tweenProperties)

	tweenObj.Completed:Once(function()
		tweenObj:Destroy()
	end)

	return tweenObj
end

--[[
	Toggles the Enabled property ParticleEmitters (and Beams if IncludeBeams is true)
	in (Parent) to (Value), or reverses the value if (Switch)
]]
function HarukaLib:ZonitoToggleParticles(instance: Instance, val: boolean, reverse: boolean, includeBeams: boolean, childrenOnly: boolean?)
	if childrenOnly then
		for _, v in instance:GetChildren() do
			if v:IsA("ParticleEmitter") then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
			if includeBeams and (v:IsA("Beam")) or (v:IsA("Trail")) then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
		end
	else
		for _, v in instance:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
			if includeBeams and (v:IsA("Beam")) or (v:IsA("Trail")) then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
		end
	end
end

-- Note: Yields
function HarukaLib.TryUntil(pCallback: () -> (boolean, any), waitTime: number, successCallback: nil | () -> nil) : any
	local result = nil

	for _ = 1, math.huge do
		local success, pcallResult = pcall(pCallback)
		if success then
			result = pcallResult
			break
		else
			if RunService:IsStudio() then
				warn(pcallResult)
			end
		end

		task.wait(waitTime)
	end

	return result
end

return HarukaLib