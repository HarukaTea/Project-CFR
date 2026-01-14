
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Classbook = require(RepS.HarukaShared.Library.ClassBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    LoadingText: Fusion.Value<string>,
})
    local UI = Components.HarukaScreenGui(scope, {
        Name = "LoadScreen",
        DisplayOrder = UIPriorityBook.Highest - 2,
        Parent = Players.LocalPlayer.PlayerGui,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Full_LoadView1_1", true))({}),
        }

    }, {
        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("AllClasses_LoadView1_1", true))({
                [Children] = {
                    Fusion.ForPairs(scope, Classbook, function(_, scope: Fusion.Scope, classId: string, classInfo: Classbook.ClassJSON)
                        if classInfo.DevClass then return classId, nil end

                        return classId, Components.IconImageLabel(scope, {
                            Name = "GGG_"..classId,
                            Image = classInfo.Icon,
                            ImageColor3 = classInfo.Color
                        })
                    end)
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Emblem_LoadView1_1", true))({}),

            Fusion.Hydrate(scope, Components:RefUI("LoadingText_LoadView1_1"))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    return use(props.LoadingText)
                end)
            })
        }
    })

    local tween = HarukaLib:CreateTween(UI.Full.CAPatternTexFrame, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 999, true, 0), {
        Position = UDim2.new(0.5, 1500 / 1.5, 0.5, 1500 / 1.5),
        Size = UDim2.new(1, 1500 * 2, 1, 1500 * 2)
    })
    table.insert(scope, function()
        tween:Cancel()
    end)
    tween:Play()

    return UI
end