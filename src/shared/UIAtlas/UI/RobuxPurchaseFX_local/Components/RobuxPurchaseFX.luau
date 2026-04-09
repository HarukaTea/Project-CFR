
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)


return function (scope: Fusion.Scope)
    local ui = Components.HarukaScreenGui(scope, {
        Name = "RobuxPurchaseFX",
        ScreenInsets = Enum.ScreenInsets.None,
        DisplayOrder = UIPriorityBook.Highest,

    }, {
        FullProps = {
            BackgroundTransparency = 0.2,
        }
    })


    table.insert(scope, task.spawn(function()
        while ui and ui:FindFirstChild("Full") do
            local frame = Components.Frame(scope, {
                Name = "RobuxPurchaseFrame",
                Rotation = 45,
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Fusion.Children] = {
                    Components.ScaledUIStroke(scope, {
                        Thickness = 0.04,
                        Transparency = 0.6
                    })
                }
            })
            Debris:AddItem(frame, 2)


            HarukaLib:CreateTween(frame, tweenInfo, {
                Size = UDim2.fromScale(1, 1)
            }):Play()
            HarukaLib:CreateTween(frame.UIStroke, tweenInfo2, {
                Transparency = 1
            }):Play()

            frame.Parent = ui.Full
            task.wait(tweenInfo.Time + 0.5)
        end
    end))


    return ui
end