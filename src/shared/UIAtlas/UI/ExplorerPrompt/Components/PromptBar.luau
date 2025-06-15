--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)

local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale

return function (scope: Fusion.Scope, props: {
    PromptObject: ProximityPrompt,
    LayoutOrder: number,
    CurrentPromptIndex: Fusion.Value,

}) : Frame
    if props.PromptObject == nil then return nil end


    props.Platform = HarukaLib:GetDevice()

    local isPC = props.Platform == "PC" or props.Platform == "Console"


    local promptType = props.PromptObject.Name :: string
    if not AssetBook.PromptIcons[promptType] then
        promptType = "Default"
    end

    local isMaterialGiver = props.PromptObject.Name == "Material"
    local materialId = "None"
    if isMaterialGiver then
        local material = props.PromptObject:FindFirstAncestorOfClass("Model")
        if not material then return nil end

        materialId = material.Name
    end


    local isClassGiver = props.PromptObject.Name == "Class"
    local classId = "None"
    if isClassGiver then
        local statue = props.PromptObject:FindFirstAncestorOfClass("Model")
        if not statue then return nil end

        classId = statue.Name
    end


    local lastInput = FusionComponents.useXboxControllerHotInput(scope)
    local keyOrIcon = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string

        if input == "Keyboard" then
            return Components.TextLabel(scope, {
                Name = "Key",
                Position = UDim2.fromScale(-0.18, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 0,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                BackgroundColor3 = Components.WHITE_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentPromptIndex) == props.LayoutOrder
                end),
                Text = "F",

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        elseif input == "Controller" then
            return Components.TextLabel(scope, {
                Name = "Key",
                Position = UDim2.fromScale(-0.18, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 0,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                BackgroundColor3 = AssetBook.XboxControllerColors.Y,
                TextColor3 = Components.BLACK_COLOR,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentPromptIndex) == props.LayoutOrder
                end),
                Text = "Y",

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        else
            return nil
        end
    end)


    local itemIconOrNomalIcon = nil
    if isMaterialGiver then
        itemIconOrNomalIcon = Components.IconImageLabel(scope, {
            Name = "Icon",
            Position = UDim2.fromScale(0.05, 0.5),
            Size = UDim2.fromScale(0.7, 0.7),
            AnchorPoint = Vector2.new(0, 0.5),

            Image = Fusion.Computed(scope, function()
                local info = ItemLib:GetItemInfo(materialId)

                if info == nil then return AssetBook.ExtraIcons.Unknown end

                return info.Icon
            end),
        })
    elseif isClassGiver then
        itemIconOrNomalIcon = Components.IconImageLabel(scope, {
            Name = "Icon",
            Position = UDim2.fromScale(0.05, 0.5),
            Size = UDim2.fromScale(0.7, 0.7),
            AnchorPoint = Vector2.new(0, 0.5),

            Image = Fusion.Computed(scope, function()
                local classInfo = ClassBook[classId]
                if classInfo == nil then
                    return AssetBook.ExtraIcons.Unknown
                end

                return classInfo.Icon
            end),
            ImageColor3 = Fusion.Computed(scope, function()
                local classInfo = ClassBook[classId]
                if classInfo == nil then
                    return Color3.new(1, 1, 1)
                end

                return classInfo.Color
            end)
        })
    else
        itemIconOrNomalIcon = Components.ImageLabel(scope, {
            Name = "Icon",
            Position = UDim2.fromScale(0.05, 0.5),
            Size = UDim2.fromScale(0.7, 0.7),
            AnchorPoint = Vector2.new(0, 0.5),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,

            Image = AssetBook.PromptIcons[promptType],

            ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return if use(props.CurrentPromptIndex) == props.LayoutOrder and isPC then Components.BLACK_COLOR else Components.WHITE_COLOR
            end),
        })
    end


    return Components.Frame(scope, {
        Name = "Prompt",
        BackgroundTransparency = 0,
        Size = fromScale(0.18, 0.9),
        LayoutOrder = props.LayoutOrder,


        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.CurrentPromptIndex) == props.LayoutOrder and isPC then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            Components.RoundUICorner(scope),

			Components.UIGradient(scope, {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),

            itemIconOrNomalIcon,


            Components.TextLabel(scope, {
                Name = "PromptText",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.19, 0.5),
                Size = fromScale(0.77, 0.7),
                Text = props.PromptObject.ActionText,
		        TextXAlignment = Enum.TextXAlignment.Left,

                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.CurrentPromptIndex) == props.LayoutOrder and isPC then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            }),


            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    props.CurrentPromptIndex:set(props.LayoutOrder)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.PromptObject:InputHoldBegin()
                end
            }),

            keyOrIcon
        }
    })
end
