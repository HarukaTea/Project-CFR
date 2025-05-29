--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ViewShownValue: Fusion.Value

}) : Frame

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = "Tab",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.02),

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.015, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }),

            Components.PaddingFrame(scope, "ZZZ"),

            Components.Frame(scope, {
                Name = "Close",
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    Components.ImageLabel(scope, {
                        Name = "Icon",
                        Image = "rbxassetid://82804434423267",

                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return if use(isSelecting) then Color3.fromRGB(255, 255, 0) else Color3.new(1, 1, 1)
                        end)
                    }),
                    Components.HoverImageButton(scope, {
                        [Fusion.OnEvent("MouseEnter")] = function()
                            isSelecting:set(true)
                        end,
                        [Fusion.OnEvent("MouseLeave")] = function()
                            isSelecting:set(false)
                        end,


                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            props.ViewShownValue:set(false)
                            isSelecting:set(false)

                            Players.LocalPlayer:SetAttribute("CurrentUIGroup", "None")

                            HarukaLib:FreezePlayerControls("Unfreeze")
                        end
                    })
                }
            })
        }
    })
end