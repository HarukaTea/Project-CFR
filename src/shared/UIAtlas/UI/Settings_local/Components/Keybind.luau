
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children


local KEY_NAMES = {
    PromptTrigger = "Prompt Trigger",
    Backpack = "Backpack",
    CharSelfView = "Character Stats",
    Settings = "Settings",
    Guild = "Guild",
    Store = "Donation Store",
    PerkTree = "Perk Tree",
    Achievements = "Achievements",
    TutorialBook = "Tutorial Book",
    ClassUlt = "Class Ultimate",
    Active1 = "Active Skill 1",
    Active2 = "Active Skill 2",
    Active3 = "Active Skill 3",
    Dash = "Dash",
}


return function(scope: Fusion.Scope, props: {
    Platfrom: string,
	KeybindId: string,
    KeybindVal: Enum.KeyCode,

    KeybindModeVal: Fusion.Value<boolean>,
    KeybindBegan: RBXScriptSignal
})
	local isSelecting = Fusion.Value(scope, false)
    local isSelectingKey = Fusion.Value(scope, false)


    local textColor = Fusion.Value(scope, Color3.new(1, 1, 1))
    local text = Fusion.Value(scope, props.KeybindVal.Name)



    local buttonText = Components.TextLabel(scope, {
        Name = "ButtonText",

        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(text)
        end),
        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(textColor)
        end),

        [Children] = {
            Components.UIPadding(scope, {})
        }
    })


	return Components.Frame(scope, {
		Name = props.KeybindId,
		Size = UDim2.fromScale(0.9, 0.09),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),

		[Children] = {
            Components.UIAspectRatioConstraint(scope, 23.723),

            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 2,

                Transparency = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then 0 else 1
                end)
            }),

			Components.TextLabel(scope, {
				Name = "Title",
				Size = UDim2.fromScale(0.35, 1),
				Text = KEY_NAMES[props.KeybindId] or "_UNKNOWN",
				TextXAlignment = Enum.TextXAlignment.Left,

				[Children] = {
					Components.UIPadding(scope, {})
				}
			}),


            Components.Frame(scope, {
                Name = "KeybindButton",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.fromScale(0.22, 1),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.HoverImageButton(scope, {
                        ZIndex = 10,

                        [Fusion.OnEvent("MouseEnter")] = function()
                            isSelectingKey:set(true)
                        end,
                        [Fusion.OnEvent("MouseLeave")] = function()
                            isSelectingKey:set(false)
                        end,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            text:set("PRESS A KEY")
                            textColor:set(Color3.fromRGB(159, 159, 159))

                            props.KeybindModeVal:set(true)

                            local validKeyName = props.KeybindBegan:Wait()

                            if validKeyName then
                                props.KeybindModeVal:set(false)

                                text:set(validKeyName)
                                textColor:set(Color3.fromRGB(255, 255, 255))

                                KeybindsBook[props.Platfrom][props.KeybindId] = Enum.KeyCode[validKeyName]

                                Events.RequestToSaveSettings.Fire({
                                    SettingId = "KEYBIND_"..props.Platfrom.."_"..props.KeybindId,
                                    SettingValue = validKeyName
                                })

                                KeybindsBook.OnKeybindChanged:Fire(true)
                            end
                        end
                    }),

                    Components.UIStroke(scope, {
                        Thickness = 2.5,

                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
                            return use(isSelectingKey)
                        end)
                    }),

                    buttonText
                }
            }),

			Components.Frame(scope, {
                Name = "Hover",

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
			})
		}
	})
end