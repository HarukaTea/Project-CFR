
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)

local Children = Fusion.Children

local ICON_TYPES = {
	Default = "Default",
	Market = "CAIcon",
	Chest = "Default",
	Crafting = "CAIcon",
}

return function (scope: Fusion.Scope, props: {
    PromptObject: ProximityPrompt,
    LayoutOrder: number,
    CurrentPromptIndex: Fusion.Value<number>,

    Platform: string?

}) : Frame?
    if props.PromptObject == nil then return nil end

    props.Platform = HarukaLib:GetDevice()

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

    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged.Event:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))

    local keyOrIcon = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean) :: boolean

        boolean = boolean

        if input == "Keyboard" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC.PromptTrigger.Name]
                or KeybindsBook.PC.PromptTrigger.Name

            return Fusion.Hydrate(scope, Components:RefUI("Key_Prompt1_1", true))({
                BackgroundColor3 = Components.WHITE_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentPromptIndex) == props.LayoutOrder
                end),
                Text = keybind
            })
        elseif input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console.PromptTrigger.Name] or KeybindsBook.Console.PromptTrigger.Name

            return Fusion.Hydrate(scope, Components:RefUI("Key_Prompt1_1", true))({
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then Color3.new() else Color3.new(1, 1, 1),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentPromptIndex) == props.LayoutOrder
                end),
                Text = keybind,
            })
        else
            return Fusion.Hydrate(scope, Components:RefUI("PressIcon_Prompt1_1"))({})
        end
    end)

    local itemIconOrNomalIcon = nil
    if isMaterialGiver then
        itemIconOrNomalIcon = Fusion.Hydrate(scope, Components:RefUI("Icon_Prompt2_2", true))({
            BackgroundTransparency = 0,

            Image = Fusion.Computed(scope, function()
                local info = ItemBook:GetItemInfo(materialId)
                if info == nil then return AssetBook.ExtraIcons.Unknown end

                return info.Icon
            end),
        })

    elseif isClassGiver then
        local classInfo = ClassBook[classId]
        local icon, color = classInfo.Icon, classInfo.Color

        icon = icon or AssetBook.ExtraIcons.Unknown
        color = color or Color3.new(1, 1, 1)

        itemIconOrNomalIcon = Fusion.Hydrate(scope, Components:RefUI("Icon_Prompt2_2", true))({
            BackgroundTransparency = 0,

            Image = icon,
            ImageColor3 = color
        })
    else
        local iconType = ICON_TYPES[promptType]
        iconType = iconType or "Default"

        if iconType == "CAIcon" then
            itemIconOrNomalIcon = Fusion.Hydrate(scope, Components:RefUI("Icon_Prompt2_2", true))({
                BackgroundTransparency = 0,

                Image = AssetBook.PromptIcons[promptType],
            })
        else
            itemIconOrNomalIcon = Fusion.Hydrate(scope, Components:RefUI("Icon_Prompt2_2", true))({
                Image = AssetBook.PromptIcons[promptType],

                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.CurrentPromptIndex) == props.LayoutOrder then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            })
        end
    end

    return Fusion.Hydrate(scope, Components:RefUI("Prompt_EPrompt2_1", false, true, {
        "EmblemClip"
    }))({
        LayoutOrder = props.LayoutOrder,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.CurrentPromptIndex) == props.LayoutOrder then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            CFEmblemTex(scope, {
                Transparency = 0.92,
                Position = UDim2.fromScale(0.42, 0.5),
                Size = UDim2.fromScale(4, 4),

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.CurrentPromptIndex) == props.LayoutOrder then Components.BLACK_COLOR else Components.WHITE_COLOR
                end)
            }),

            itemIconOrNomalIcon,

            Fusion.Hydrate(scope, Components:RefUI("PromptText_Prompt1_1"))({
                Text = props.PromptObject.ActionText,
                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.CurrentPromptIndex) == props.LayoutOrder then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    props.CurrentPromptIndex:set(props.LayoutOrder)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    Bindables.PromptTriggered:Fire(props.PromptObject)
                    Events.PromptTriggered_C.Fire(props.PromptObject)
                end
            }),

            keyOrIcon
        }
    })
end