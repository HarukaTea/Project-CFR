--!nocheck

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local HarukaComponents = {}


local WHITE_COLOR = Color3.fromRGB(236, 229, 216)
local BLACK_COLOR = Color3.fromRGB(28, 28, 37)

local DESIGN_VP_SIZE = Vector2.new(1172, 471.2)

HarukaComponents.BLACK_COLOR = BLACK_COLOR
HarukaComponents.WHITE_COLOR = WHITE_COLOR

--// Init once only
local existingButtonElements = {}

local wait = task.wait

--// Helper functions

local function _reconcileProps(default: table, props: table)
	for prop: string, val: any in props do
		if prop == Fusion.Children and default[Fusion.Children] then
			table.insert(default[Fusion.Children], val)
			continue
		end

		default[prop] = val
	end
end
local function _createNewCompoent(scope: Fusion.Scope, props: table, uiType: string, default: table) : GuiObject
	_reconcileProps(default, props or {})

	return Fusion.New(scope, uiType)(default)
end


function HarukaComponents.HarukaScreenGui(scope: Fusion.Scope, guiProps: table?, childProps: {
	TopProps: table?,
	CenterProps: table?,
	BottomProps: table?,
	FullProps: table?
}?) : ScreenGui

	childProps = childProps or {}

	local defaultTopProps = {
		Name = "Top",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),

		[Fusion.Children] = {}
	}
	local defaultCenterProps = {
		Name = "Center",

		[Fusion.Children] = {}
	}
	local defaultBottomProps = {
		Name = "Bottom",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),

		[Fusion.Children] = {}
	}
	local defaultFSProps = {
		Name = "Full",

		[Fusion.Children] = {}
	}
	_reconcileProps(defaultTopProps, childProps.TopProps or {})
	_reconcileProps(defaultCenterProps, childProps.CenterProps or {})
	_reconcileProps(defaultBottomProps, childProps.BottomProps or {})
	_reconcileProps(defaultFSProps, childProps.FullProps or {})


	local top, center, bottom, full = nil, nil, nil, nil
	if childProps.TopProps then
		top = HarukaComponents.HarukaFrame(scope, defaultTopProps)
	end
	if childProps.CenterProps then
		center = HarukaComponents.HarukaFrame(scope, defaultCenterProps)
	end
	if childProps.BottomProps then
		bottom = HarukaComponents.HarukaFrame(scope, defaultBottomProps)
	end
	if childProps.FullProps then
		full = HarukaComponents.Frame(scope, defaultFSProps)
	end


	return _createNewCompoent(scope, guiProps or {}, "ScreenGui", {
		ClipToDeviceSafeArea = false,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true,

		[Fusion.Children] = {
			top, center, bottom, full
		}
	})
end


function HarukaComponents.Frame(scope: Fusion.Scope, props: table) : Frame
	return _createNewCompoent(scope, props, "Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BLACK_COLOR,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Selectable = false,
		SelectionOrder = -1
	})
end


function HarukaComponents.ScrollingFrame(scope: Fusion.Scope, props: table, listProps: table) : ScrollingFrame
	local absSize = Fusion.Value(scope, Vector2.zero)
	local absContentSize = Fusion.Value(scope, Vector2.zero)
	local VPSize = FusionComponents.useViewportSize(scope)

	listProps = listProps or {
		Padding = UDim.new(0, 0),
	}

	if listProps.Padding ~= nil then --- UIListLayout
		listProps[Fusion.Out("AbsoluteContentSize")] = absContentSize
		listProps.FillDirection = listProps.FillDirection or Enum.FillDirection.Vertical

		local originalPadding = listProps.Padding
		local fillDirection = listProps.FillDirection.Name or "Vertical"

		listProps.Padding = Fusion.Computed(scope, function(use: Fusion.Use, _)
			if fillDirection == "Vertical" then
				local Y = use(VPSize).Y
				local finalY = Y / (DESIGN_VP_SIZE.Y / originalPadding.Offset)

				finalY = math.min(originalPadding.Offset, finalY)

				return UDim.new(0, finalY)
			elseif fillDirection == "Horizontal" then
				local X = use(VPSize).X
				local finalX = X / (DESIGN_VP_SIZE.X / originalPadding.Offset)

				finalX = math.min(originalPadding.Offset, finalX)

				return UDim.new(0, finalX)
			end
		end)

		table.insert(props[Fusion.Children], 1, HarukaComponents.UIListLayout(scope, listProps))

	elseif listProps.CellPadding ~= nil then --- UIGridLayout
		listProps[Fusion.Out("AbsoluteContentSize")] = absContentSize

		table.insert(props[Fusion.Children], 1, HarukaComponents.UIGridLayout(scope, listProps))
	end

	return _createNewCompoent(scope, props, "ScrollingFrame", {
		BackgroundColor3 = BLACK_COLOR,
		BackgroundTransparency = 1,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		SelectionOrder = -1,

		CanvasSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
			return if use(absContentSize).Y > use(absSize).Y then UDim2.fromOffset(0, use(absContentSize).Y + 15.99) else UDim2.fromOffset(0, 0)
		end),
		ScrollingEnabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
			return if use(absContentSize).Y > use(absSize).Y then true else false
		end),

		[Fusion.Out("AbsoluteSize")] = absSize,
		[Fusion.Children] = {}
	})
end


function HarukaComponents.TextLabel(scope: Fusion.Scope, props: table) : TextLabel
	return _createNewCompoent(scope, props, "TextLabel", {
		BackgroundColor3 = BLACK_COLOR,
		BackgroundTransparency = 1,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextScaled = true,
		TextColor3 = WHITE_COLOR,
		TextStrokeColor3 = Color3.new(),
		TextStrokeTransparency = 1,
		TextSize = 100,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		SelectionOrder = -1
	})
end


function HarukaComponents.TextBox(scope: Fusion.Scope, props: table) : TextBox
	return _createNewCompoent(scope, props, "TextBox", {
		BackgroundColor3 = BLACK_COLOR,
		ClearTextOnFocus = false,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		PlaceholderText = "",
		PlaceholderColor3 = Color3.fromRGB(159, 159, 159),
		Text = "",
		TextColor3 = WHITE_COLOR,
		TextScaled = true,
		TextSize = 100,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
end


function HarukaComponents.ImageLabel(scope: Fusion.Scope, props: table) : ImageLabel
	return _createNewCompoent(scope, props, "ImageLabel", {
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		Image = "",
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		SelectionOrder = -1
	})
end


function HarukaComponents.IconImageLabel(scope: Fusion.Scope, props: table) : ImageLabel
	local defaultProps = {
		Name = "Icon",
		BackgroundTransparency = 0,
		Image = "",
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Selectable = false,
		SelectionOrder = -1,

		[Fusion.Children] = {
			HarukaComponents.RoundUICorner(scope)
		}
	}
	_reconcileProps(defaultProps, props or {})


	return HarukaComponents.ImageLabel(scope, defaultProps)
end


function HarukaComponents.HoverImageButton(scope: Fusion.Scope, props: table) : ImageButton
	local hoverFunc, leaveFunc, clickFunc =
		props[Fusion.OnEvent("MouseEnter")], props[Fusion.OnEvent("MouseLeave")], props[Fusion.OnEvent("MouseButton1Click")]


	props[Fusion.OnEvent("MouseButton1Click")] = nil
	props[Fusion.OnEvent("MouseEnter")] = nil
	props[Fusion.OnEvent("MouseLeave")] = nil


	local uniqueId = HttpService:GenerateGUID(false)
	local button = _createNewCompoent(scope, props, "ImageButton", {
		Name = "Hover",
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = "",
		BorderSizePixel = 0,
		AutoButtonColor = false,

		[Fusion.Attribute("HarukaUniqueId")] = uniqueId
	})

	HarukaComponents:TrackButtonEvents(scope, button, hoverFunc, leaveFunc, clickFunc)

	table.insert(scope, existingButtonElements[uniqueId])
	table.insert(scope, function()
		existingButtonElements[uniqueId] = nil
	end)

	return button
end


function HarukaComponents.TextButton(scope: Fusion.Scope, props: table) : TextButton
	local hoverFunc, leaveFunc, clickFunc =
		props[Fusion.OnEvent("MouseEnter")], props[Fusion.OnEvent("MouseLeave")], props[Fusion.OnEvent("MouseButton1Click")]


	props[Fusion.OnEvent("MouseButton1Click")] = nil
	props[Fusion.OnEvent("MouseEnter")] = nil
	props[Fusion.OnEvent("MouseLeave")] = nil

	local uniqueId = HttpService:GenerateGUID(false)
	local button = _createNewCompoent(scope, props, "TextButton", {
		AutoButtonColor = true,
		BackgroundColor3 = BLACK_COLOR,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextColor3 = WHITE_COLOR,
		TextScaled = true,
		BorderSizePixel = 0,
		TextStrokeColor3 = BLACK_COLOR,
		TextStrokeTransparency = 1,
		TextSize = 100,
		Size = UDim2.fromScale(1, 1),

		[Fusion.Attribute("HarukaUniqueId")] = uniqueId
	})

	HarukaComponents:TrackButtonEvents(scope, button, hoverFunc, leaveFunc, clickFunc)

	table.insert(scope, existingButtonElements[uniqueId])
	table.insert(scope, function()
		existingButtonElements[uniqueId] = nil
	end)

	return button
end


function HarukaComponents.UIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = WHITE_COLOR,
		Transparency = 0
	})
end


function HarukaComponents.TextUIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		Transparency = 0,
	})
end


function HarukaComponents.UICorner(scope: Fusion.Scope, props: table) : UICorner
	return _createNewCompoent(scope, props, "UICorner", {
		CornerRadius = UDim.new(0.5, 0)
	})
end


function HarukaComponents.RoundUICorner(scope: Fusion.Scope) : UICorner
	return HarukaComponents.UICorner(scope, {})
end


function HarukaComponents.UIPadding(scope: Fusion.Scope, props: table) : UIPadding
	return _createNewCompoent(scope, props, "UIPadding", {
		PaddingTop = UDim.new(0.1, 0),
		PaddingBottom = UDim.new(0.1, 0),
		PaddingLeft = UDim.new(0.1, 0),
		PaddingRight = UDim.new(0.1, 0)
	})
end


function HarukaComponents.UIAspectRatioConstraint(scope: Fusion.Scope, aspect: number?) : UIAspectRatioConstraint
	return _createNewCompoent(scope, { AspectRatio = aspect or 25.627 }, "UIAspectRatioConstraint", {
		AspectRatio = 25.627
	})
end


function HarukaComponents.UIListLayout(scope: Fusion.Scope, props: table) : UIListLayout
	return _createNewCompoent(scope, props, "UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 0)
	})
end


function HarukaComponents.UIGridLayout(scope: Fusion.Scope, props: table) : UIGridLayout
	return _createNewCompoent(scope, props, "UIGridLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		StartCorner = Enum.StartCorner.TopLeft,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})
end



function HarukaComponents.PaddingFrame(scope: Fusion.Scope, name: string) : Frame
	return HarukaComponents.Frame(scope, {
		Name = name.."_"..name,
		Size = UDim2.fromOffset(1, 1),
		LayoutOrder = if name == "AAA" then -9999 else 9999,
	})
end


function HarukaComponents.HarukaFrame(scope: Fusion.Scope, props: table) : Frame
	table.insert(props[Fusion.Children], 1, HarukaComponents.UIAspectRatioConstraint(scope))

	props.Size = UDim2.fromScale(1, 0.1)

	return HarukaComponents.Frame(scope, props)
end


function HarukaComponents.BillboardGui(scope: Fusion.Scope, props: table) : BillboardGui
	return _createNewCompoent(scope, props, "BillboardGui", {
		LightInfluence = 0,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ClipsDescendants = false,
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		Active = true
	})
end


function HarukaComponents.BlurFS(scope: Fusion.Scope, props: table) : BlurEffect
	return _createNewCompoent(scope, props, "BlurEffect", {
		Enabled = true,
		Name = "UIBlur"
	})
end



function HarukaComponents.ViewportFrame(scope: Fusion.Scope, props: table) : ViewportFrame
	return _createNewCompoent(scope, props, "ViewportFrame", {
		Ambient = WHITE_COLOR,
		LightColor = WHITE_COLOR,
		LightDirection = Vector3.xAxis * -1,
		BackgroundColor3 = BLACK_COLOR,
		BackgroundTransparency = 1,
		Selectable = false,
		SelectionOrder = -1
	})
end



function HarukaComponents.UIScale(scope: Fusion.Scope, props: table?) : UIScale
	props = props or {}

	props.Scale = props.Scale or 1
	props.Scale *= workspace:GetAttribute("UIScaleFactor") or 1

	local baseScale = props.Scale

	return _createNewCompoent(scope, props, "UIScale", {
		Scale = props.Scale,

		[Fusion.Attribute("BaseScale")] = baseScale
	})
end


function HarukaComponents.UITextSizeConstraint(scope: Fusion.Scope, props: table) : UITextSizeConstraint
	return _createNewCompoent(scope, props, "UITextSizeConstraint", {
		MaxTextSize = 36,
		MinTextSize = 1
	})
end


function HarukaComponents.UIGradient(scope: Fusion.Scope, props: table) : UIGradient
	return _createNewCompoent(scope, props, "UIGradient", {})
end



function HarukaComponents:CreateConfirmPrompt(scope: Fusion.Scope, data: {
	Hint: string,
	ConfirmText: string,
	CancelText: string,

	ConfirmUniqueId: string
})
	local innerScope = Fusion.innerScope(scope)
	local waitSignal = Signal.new()
	table.insert(innerScope, waitSignal)

	table.insert(innerScope, Bindables.ConfirmPromptChosen:Connect(function(uniqueId: string, result: "YES" | "NO")
		if uniqueId ~= data.ConfirmUniqueId then return end

		waitSignal:Fire(result)

		Fusion.doCleanup(innerScope)
	end))

	Bindables.CreateConfirmPrompt:Fire(data)

	return waitSignal
end


function HarukaComponents:TrackButtonEvents(scope: Fusion.Scope, button: GuiObject, hoverFunc: () -> nil, leaveFunc: () -> nil, clickFunc: () -> nil)
	local function _isButtonValid(screenGui: ScreenGui?) : boolean
		if not screenGui then return false end
		if not button.Visible then return false end

		return true
	end


	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")

	local mouseLeave = nil
	if leaveFunc then
		mouseLeave = Signal.new()
	end
	table.insert(scope, task.spawn(function()
		repeat wait() until button:FindFirstAncestorOfClass("ScreenGui")

		screenGui = button:FindFirstAncestorOfClass("ScreenGui")
		existingButtonElements[button:GetAttribute("HarukaUniqueId")].ScreenGuiObj = screenGui

		if leaveFunc then
			table.insert(scope, HarukaLib:Hydrate(screenGui, {
				["Prop-Enabled"] = function(state: boolean)
					if state == false then
						mouseLeave:Fire()
					end
				end
			}))
		end
	end))


	existingButtonElements[button:GetAttribute("HarukaUniqueId")] = {
		UIObj = button,
		ScreenGuiObj = screenGui,
	}


	if leaveFunc then
		mouseLeave:Connect(function()
			if not _isButtonValid(screenGui) then return end
			if leaveFunc then leaveFunc() end
		end)
		button.MouseLeave:Connect(function()
			if not _isButtonValid(screenGui) then return end
			if leaveFunc then leaveFunc() end
		end)
		button.SelectionLost:Connect(function()
			if not _isButtonValid(screenGui) then return end
			if leaveFunc then leaveFunc() end
		end)
	end
	if hoverFunc then
		button.MouseEnter:Connect(function()
			if not _isButtonValid(screenGui) then return end
			if hoverFunc then hoverFunc() end
		end)
		button.SelectionGained:Connect(function()
			if not _isButtonValid(screenGui) then return end
			if hoverFunc then hoverFunc() end
		end)
	end
	if clickFunc then
		button.MouseButton1Click:Connect(function()
			if not screenGui or not screenGui.Enabled then return false end
			if not button.Visible then return false end

			if clickFunc then clickFunc() end
		end)
	end
end



return HarukaComponents
