--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    LoadingText: Fusion.Value | string,
})
    return Components.HarukaScreenGui(scope, {
        Name = "LoadScreen",
        DisplayOrder = UIPriorityBook.Highest,
        Parent = Players.LocalPlayer.PlayerGui,

    }, {
        FullProps = {
            ZIndex = 0,
            BackgroundTransparency = 0,
        },

        BottomProps = {
            [Children] = {
                Components.TextLabel(scope, {
                    Name = "LoadingText",
                    Position = UDim2.fromScale(0, -0.3),
                    Size = UDim2.fromScale(1, 0.5),

                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(props.LoadingText)
                    end)
                })
            }
        }
    })
end
