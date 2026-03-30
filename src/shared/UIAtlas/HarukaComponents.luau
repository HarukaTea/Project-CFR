
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local fusionBlendUtility = require(RepS.HarukaShared.Shared.Fusion.Utility.blend)

local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local CriRPGColorLab = {}

CriRPGColorLab.BLACK_COLOR = Color3.fromHex('#111111')
CriRPGColorLab.WHITE_COLOR = Color3.fromHex('#e8e2dd')
CriRPGColorLab.RED_COLOR = Color3.fromHex('#ff7675')
CriRPGColorLab.GREEN_COLOR = Color3.fromHex('#7bd99f')
CriRPGColorLab.GREY_COLOR = Color3.fromHex('#25292f')
CriRPGColorLab.BLUE_COLOR = Color3.fromHex('#7ce4f8')

local HarukaComponents = {}
HarukaComponents.FusionComponents = FusionComponents

local DESIGN_VP_SIZE = Vector2.new(1172, 456.8)
HarukaComponents.DESIGN_VP_SIZE = DESIGN_VP_SIZE

local UIASPECT_RATIO = 25.628

local WHITE_BG_COLOR = CriRPGColorLab.WHITE_COLOR
local BLACK_BG_COLOR = CriRPGColorLab.BLACK_COLOR

--// legacy references
HarukaComponents.BLACK_COLOR = CriRPGColorLab.BLACK_COLOR
HarukaComponents.WHITE_COLOR = CriRPGColorLab.WHITE_COLOR
HarukaComponents.RED_COLOR = CriRPGColorLab.RED_COLOR
HarukaComponents.GREEN_COLOR = CriRPGColorLab.GREEN_COLOR
HarukaComponents.GREY_COLOR = CriRPGColorLab.GREY_COLOR
HarukaComponents.BLUE_COLOR = CriRPGColorLab.BLUE_COLOR

HarukaComponents.TweenInfos = AssetBook.TweenInfos
HarukaComponents.DefaultTween = HarukaComponents.TweenInfos.twiceHalf

HarukaComponents.UIAtlas = RepS.Packages.UIAtlas :: Folder

export type FusionPropsEntry = { [string | Fusion.SpecialKey]: any }
export type FusionChildrenEntry = { Instance | Fusion.Computed<Instance?> }

--// Init once only
local Children = Fusion.Children

--// Helper functions

local function _reconcileProps(default: FusionPropsEntry, props: FusionPropsEntry)
	local hasChildrenInDefault = false
	for k, v in props do
		local keyType = fusionBlendUtility.xtypeof(k)
		if keyType == "SpecialKey" and k.kind == "Children" then
			for k2, v2 in default do
				local keyType2 = fusionBlendUtility.xtypeof(k2)
				if keyType2 == "SpecialKey" and k2.kind == "Children" then
					table.insert(v2, v)
					hasChildrenInDefault = true
				end
			end
			if hasChildrenInDefault then continue end
		end
		default[k] = v
	end
end
local function _createNewCompoent(scope: Fusion.Scope, props: FusionPropsEntry, uiType: string, default: FusionPropsEntry) : any
	_reconcileProps(default, props or {})

	local instance = Fusion.New(scope, uiType)(default) :: GuiObject
	return instance
end
HarukaComponents._reconcileProps = _reconcileProps
HarukaComponents._createNewCompoent = _createNewCompoent

function HarukaComponents:RefUI(
	uiId: string,
	keepAll: boolean?,
	keepUIObjOnly: boolean?,
	whiteList: { string }?
) : Instance?
	local obj = RepS.Packages.UIAtlas:FindFirstChild(uiId, true) :: Instance
	if obj == nil then
		warn("Failed to find UI element with ID: "..uiId)
		return nil
	end

	obj = obj:Clone()
	obj.Name = string.match(obj.Name, "^([^_]+)")

	whiteList = whiteList or {}

	if not keepAll and not keepUIObjOnly then
		for _, child: Instance in obj:GetChildren() do
			if not table.find(whiteList, child.Name) then
				child:Destroy()
			end
		end
	end
	if keepUIObjOnly then
		for _, child: Instance in obj:GetChildren() do
			if not string.find(child.ClassName, "UI") and not table.find(whiteList, child.Name) then
				child:Destroy()
			end
		end
	end

	return obj
end

function HarukaComponents.HarukaScreenGui(scope: Fusion.Scope, guiProps: FusionPropsEntry, childProps: {
	TopProps: FusionPropsEntry?,
	CenterProps: FusionPropsEntry?,
	BottomProps: FusionPropsEntry?,
	FullProps: FusionPropsEntry?,

	TopChildren: FusionChildrenEntry?,
	CenterChildren: FusionChildrenEntry?,
	BottomChildren: FusionChildrenEntry?,
	FullChildren: FusionChildrenEntry?
}?) : ScreenGui

	guiProps = guiProps or {}
	childProps = childProps or {}

	local function createSection(
		name: string,
		defaultProps: FusionPropsEntry,
		userProps: FusionPropsEntry?,
		userChildren: FusionChildrenEntry?
	)
		userProps = userProps or {}
		userChildren = userChildren or {}

		local hasProps = HarukaLib.TableUtils.IsEmpty(userProps) == false
		local hasChildren = #userChildren > 0 or HarukaLib.TableUtils.IsEmpty(userChildren) == false
		if not hasProps and not hasChildren then return nil end

		local hasChildrenInProps = false
		for k, v in userProps do
			local keyType = fusionBlendUtility.xtypeof(k)
			if keyType == "SpecialKey" and k.kind == "Children" then
				hasChildrenInProps = true
				break
			end
		end
		if not hasChildrenInProps then
			userProps[Children] = userChildren
		end

		_reconcileProps(defaultProps, userProps)
		if name == "Full" then
			return HarukaComponents.Frame(scope, defaultProps)
		else
			return HarukaComponents.HarukaFrame(scope, defaultProps)
		end
	end

	local defaultPropsTop = {
		Name = "Top",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0)
	}
	local defaultPropsCenter = {
		Name = "Center"
	}
	local defaultPropsBottom = {
		Name = "Bottom",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1)
	}
	local defaultPropsFull = {
		Name = "Full"
	}
	local top = createSection("Top", defaultPropsTop, childProps.TopProps, childProps.TopChildren)
	local center = createSection("Center", defaultPropsCenter, childProps.CenterProps, childProps.CenterChildren)
	local bottom = createSection("Bottom", defaultPropsBottom, childProps.BottomProps, childProps.BottomChildren)
	local full = createSection("Full", defaultPropsFull, childProps.FullProps, childProps.FullChildren)

	return _createNewCompoent(scope, guiProps, "ScreenGui", {
		ClipToDeviceSafeArea = false,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true,

		[Children] = {
			top, center, bottom, full
		}
	})
end

function HarukaComponents.Frame(scope: Fusion.Scope, props: FusionPropsEntry) : Frame
	return _createNewCompoent(scope, props, "Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BLACK_BG_COLOR,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Selectable = false,
		SelectionOrder = -1
	})
end

function HarukaComponents.ScrollingFrame(scope: Fusion.Scope, props: FusionPropsEntry, listProps: FusionPropsEntry) : ScrollingFrame
	local absSize = Fusion.Value(scope, Vector2.zero)
	local absContentSize = Fusion.Value(scope, Vector2.zero)
	local VPSize = FusionComponents.useViewportSize(scope)

	listProps = listProps or {}

	props = props or {}
	props.ScrollingDirection = props.ScrollingDirection or Enum.ScrollingDirection.Y

	props[Children] = props[Children] or {}

	local isListLayout = listProps.Padding ~= nil
	local isGridLayout = listProps.CellPadding ~= nil
	if isListLayout or isGridLayout then
		listProps[Fusion.Out("AbsoluteContentSize")] = absContentSize
	end

	if isListLayout then --- UIListLayout
		listProps.FillDirection = listProps.FillDirection or Enum.FillDirection.Vertical

		local device = HarukaLib:GetAccurateDevice()
		if device == "Phone" or device == "Tablet" then
			local originalPadding = listProps.Padding
			local isVertical = (listProps.FillDirection == Enum.FillDirection.Vertical)

			listProps.Padding = Fusion.Computed(scope, function(use: Fusion.Use, _)
				local vpSize = use(VPSize)
				local axis = if isVertical then "Y" else "X"
				local designSize = if isVertical then DESIGN_VP_SIZE.Y else DESIGN_VP_SIZE.X
				local scaled = vpSize[axis] / (designSize / originalPadding.Offset)

				return UDim.new(0, math.min(originalPadding.Offset, scaled))
			end)
		end

		table.insert(props[Children], 1, HarukaComponents.UIListLayout(scope, listProps))

	elseif isGridLayout then --- UIGridLayout
		table.insert(props[Children], 1, HarukaComponents.UIGridLayout(scope, listProps))
	end

	local scrollAxis = props.ScrollingDirection.Name
	return _createNewCompoent(scope, props, "ScrollingFrame", {
		BackgroundColor3 = BLACK_BG_COLOR,
		BackgroundTransparency = 1,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Color3.new(1, 1, 1),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),

		CanvasSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
			local contentSize = use(absContentSize)[scrollAxis]
			local frameSize = use(absSize)[scrollAxis]
			if contentSize > frameSize then
				local offset = contentSize + 8
				return if scrollAxis == "Y" then UDim2.fromOffset(0, offset) else UDim2.fromOffset(offset, 0)
			end

			return UDim2.fromOffset(0, 0)
		end),
		ScrollingEnabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
			return use(absContentSize)[scrollAxis] > use(absSize)[scrollAxis]
		end),

		[Fusion.Out("AbsoluteSize")] = absSize,
		[Children] = {}
	})
end

function HarukaComponents.TextLabel(scope: Fusion.Scope, props: FusionPropsEntry) : TextLabel
	return _createNewCompoent(scope, props, "TextLabel", {
		BackgroundColor3 = BLACK_BG_COLOR,
		BackgroundTransparency = 1,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextScaled = true,
		TextColor3 = WHITE_BG_COLOR,
		TextStrokeColor3 = Color3.new(),
		TextStrokeTransparency = 1,
		TextSize = 100,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		SelectionOrder = -1,
		Text = ""
	})
end

function HarukaComponents.TextBox(scope: Fusion.Scope, props: FusionPropsEntry) : TextBox
	return _createNewCompoent(scope, props, "TextBox", {
		BackgroundColor3 = BLACK_BG_COLOR,
		ClearTextOnFocus = false,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		PlaceholderText = "",
		PlaceholderColor3 = Color3.fromRGB(159, 159, 159),
		Text = "",
		TextColor3 = WHITE_BG_COLOR,
		TextScaled = true,
		TextSize = 100,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
end

function HarukaComponents.ImageLabel(scope: Fusion.Scope, props: FusionPropsEntry) : ImageLabel
	return _createNewCompoent(scope, props, "ImageLabel", {
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		Image = "",
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		SelectionOrder = -1,
		AutoLocalize = false
	})
end

function HarukaComponents.IconImageLabel(scope: Fusion.Scope, props: FusionPropsEntry) : ImageLabel
	local defaultProps = {
		Name = "Icon",
		BackgroundTransparency = 0,
		Image = "",
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Selectable = false,
		SelectionOrder = -1,

		[Children] = {
			HarukaComponents.RoundUICorner(scope)
		}
	}
	_reconcileProps(defaultProps, props or {})

	return HarukaComponents.ImageLabel(scope, defaultProps)
end

function HarukaComponents.HoverImageButton(scope: Fusion.Scope, props: FusionPropsEntry) : ImageButton
	local data = fusionBlendUtility._readSpecialKey(props)
	local hoverFunc, leaveFunc, clickFunc = data.HoverFunc, data.LeaveFunc, data.ClickFunc

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
	})

	fusionBlendUtility._trackButtonEvents(scope, button, hoverFunc, leaveFunc, clickFunc)

	return button
end

function HarukaComponents.TextButton(scope: Fusion.Scope, props: FusionPropsEntry) : TextButton
	local data = fusionBlendUtility._readSpecialKey(props)
	local hoverFunc, leaveFunc, clickFunc = data.HoverFunc, data.LeaveFunc, data.ClickFunc

	local button = _createNewCompoent(scope, props, "TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = BLACK_BG_COLOR,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextColor3 = WHITE_BG_COLOR,
		TextScaled = true,
		BorderSizePixel = 0,
		TextStrokeColor3 = BLACK_BG_COLOR,
		TextStrokeTransparency = 1,
		TextSize = 100,
		Size = UDim2.fromScale(1, 1),
		Text = "",
	})

	fusionBlendUtility._trackButtonEvents(scope, button, hoverFunc, leaveFunc, clickFunc)

	return button
end

--@deprecated, use ScaledUIStroke instead
function HarukaComponents.UIStroke(scope: Fusion.Scope, props: FusionPropsEntry) : UIStroke
	warn("You are using deprecated UIStroke, use ScaledUIStroke instead")

	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = WHITE_BG_COLOR,
		Transparency = 0,
	})
end

function HarukaComponents.ScaledUIStroke(scope: Fusion.Scope, props: FusionPropsEntry) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = WHITE_BG_COLOR,
		Transparency = 0,

		--// Nov 2025 update: roblox added ScaledThickness
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = 0.015
	})
end

--@deprecated, use ScaledTextUIStroke instead
function HarukaComponents.TextUIStroke(scope: Fusion.Scope, props: FusionPropsEntry) : UIStroke
	warn("You are using deprecated TextUIStroke, use ScaledTextUIStroke instead")

	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		Transparency = 0,
	})
end

function HarukaComponents.ScaledTextUIStroke(scope: Fusion.Scope, props: FusionPropsEntry, isBillboard: boolean?) : UIStroke
	local defaultThickness = 0.1159
	if isBillboard then
		defaultThickness = 0.05
	end

	return _createNewCompoent(scope, props, "UIStroke", {
		Transparency = 0,

		--// Nov 2025 update: roblox added ScaledThickness
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = defaultThickness
	})
end

function HarukaComponents.UICorner(scope: Fusion.Scope, props: FusionPropsEntry) : UICorner
	return _createNewCompoent(scope, props, "UICorner", {
		CornerRadius = UDim.new(0.5, 0)
	})
end

function HarukaComponents.RoundUICorner(scope: Fusion.Scope) : UICorner
	return HarukaComponents.UICorner(scope, {})
end

function HarukaComponents.UIPadding(scope: Fusion.Scope, props: FusionPropsEntry) : UIPadding
	return _createNewCompoent(scope, props, "UIPadding", {
		PaddingTop = UDim.new(0.1, 0),
		PaddingBottom = UDim.new(0.1, 0),
		PaddingLeft = UDim.new(0.1, 0),
		PaddingRight = UDim.new(0.1, 0)
	})
end

function HarukaComponents.UIAspectRatioConstraint(scope: Fusion.Scope, aspect: number?) : UIAspectRatioConstraint
	return _createNewCompoent(scope, { AspectRatio = aspect or UIASPECT_RATIO }, "UIAspectRatioConstraint", {
		AspectRatio = UIASPECT_RATIO
	})
end

function HarukaComponents.UIListLayout(scope: Fusion.Scope, props: FusionPropsEntry) : UIListLayout
	return _createNewCompoent(scope, props, "UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 0)
	})
end

function HarukaComponents.UIGridLayout(scope: Fusion.Scope, props: FusionPropsEntry) : UIGridLayout
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

function HarukaComponents.HarukaFrame(scope: Fusion.Scope, props: FusionPropsEntry) : Frame
	table.insert(props[Children], 1, HarukaComponents.UIAspectRatioConstraint(scope))

	props.Size = UDim2.fromScale(1, 0.1)

	return HarukaComponents.Frame(scope, props)
end

function HarukaComponents.BillboardGui(scope: Fusion.Scope, props: FusionPropsEntry) : BillboardGui
	return _createNewCompoent(scope, props, "BillboardGui", {
		LightInfluence = 0,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ClipsDescendants = false,
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		Active = true
	})
end

function HarukaComponents.BlurFS(scope: Fusion.Scope, props: FusionPropsEntry) : BlurEffect
	return _createNewCompoent(scope, props, "BlurEffect", {
		Enabled = true,
		Name = "UIBlur"
	})
end

function HarukaComponents.ViewportFrame(scope: Fusion.Scope, props: FusionPropsEntry) : ViewportFrame
	return _createNewCompoent(scope, props, "ViewportFrame", {
		Ambient = WHITE_BG_COLOR,
		LightColor = WHITE_BG_COLOR,
		LightDirection = Vector3.xAxis * -1,
		BackgroundColor3 = BLACK_BG_COLOR,
		BackgroundTransparency = 1,
		Selectable = false,
		SelectionOrder = -1
	})
end

function HarukaComponents.UIScale(scope: Fusion.Scope, props: FusionPropsEntry) : UIScale
	props = props or {}
	props.Scale = props.Scale or 1
	props.Scale *= workspace:GetAttribute("UIScaleFactor") or 1

	local baseScale = props.Scale

	return _createNewCompoent(scope, props, "UIScale", {
		Scale = props.Scale,

		[Fusion.Attribute("BaseScale")] = baseScale
	})
end

function HarukaComponents.UITextSizeConstraint(scope: Fusion.Scope, props: FusionPropsEntry) : UITextSizeConstraint
	return _createNewCompoent(scope, props, "UITextSizeConstraint", {
		MaxTextSize = 36,
		MinTextSize = 1
	})
end

function HarukaComponents.UIGradient(scope: Fusion.Scope, props: FusionPropsEntry) : UIGradient
	return _createNewCompoent(scope, props, "UIGradient", {})
end

function HarukaComponents.ConnectSelectEvents(isSelecting: Fusion.Value<boolean>) : {
	[Fusion.SpecialKey]: () -> nil
}
	return {
		type = "nestedSpecialKey",
		applys = {
			[Fusion.OnEvent("MouseEnter")] = function()
				isSelecting:set(true)
			end,
			[Fusion.OnEvent("MouseLeave")] = function()
				isSelecting:set(false)
			end,
		}
	}
end

function HarukaComponents:CreateConfirmPrompt(data: {
	Hint: string,
	ConfirmText: string,
	CancelText: string,
	ConfirmUniqueId: string
}) : BindableEvent
	local scope = Fusion.scoped()
	local waitSignal = Instance.new("BindableEvent")
	table.insert(scope, waitSignal)

	table.insert(scope, Bindables.ConfirmPromptChosen.Event:Connect(function(
		uniqueId: string,
		result: "YES" | "NO"
	)
		if uniqueId ~= data.ConfirmUniqueId then return end

		waitSignal:Fire(result)

		Fusion.doCleanup(scope)
	end))

	Bindables.CreateConfirmPrompt:Fire(data)

	return waitSignal
end

return HarukaComponents