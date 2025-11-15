
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Pinia = require(script.Parent.Parent.Pinia)

local Children = Fusion.Children


return function(scope: Fusion.Scope, levelId: string, self: Pinia.Self)
    return { Components.Frame(scope, {
        Name = "LevelStarter_"..levelId,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 1.5),
        ZIndex = 5,

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            if levelId == "Abyss" then
                return use(self.AbyssId) and use(self.AbyssStarted) == false

            elseif levelId == "Dungeon" then
                return use(self.DungeonId) and use(self.DungeonStarted) == false
            end

            return false
        end),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 1
            }),
            Components.UIListLayout(scope, {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Components.TextButton(scope, {
                Name = "StarterBtn",
                Size = UDim2.fromScale(0.15, 0.65),
                Text = "START",
                BackgroundTransparency = 0,
                BackgroundColor3 = Components.BLUE_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_StartAbyss_C.Fire()

                    elseif levelId == "Dungeon" then

                    end
                end,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        }
    }),
    Components.Frame(scope, {
        Name = "LevelEndActions_"..levelId,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 1.5),
        ZIndex = 5,

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            if levelId == "Abyss" then
                return use(self.AbyssId) and use(self.AbyssStarted) and use(self.AbyssFinished) and use(self.AbyssEndActionsClicked) == false
            elseif levelId == "Dungeon" then
                return use(self.DungeonId) and use(self.DungeonStarted) and use(self.DungeonFinished) and use(self.DungeonEndActionsClicked) == false
            end

            return false
        end),


        [Children] = {
            Components.UIScale(scope, {
                Scale = 1
            }),
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.5, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Components.TextButton(scope, {
                Name = "RestarterBtn",
                Size = UDim2.fromScale(0.2, 0.65),
                Text = "RESTART",
                BackgroundTransparency = 0,
                BackgroundColor3 = Components.BLUE_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_AfterEndAction_S.Fire("Restart")

                        self.AbyssEndActionsClicked:set(true)

                    elseif levelId == "Dungeon" then

                    end
                end,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            }),
            Components.TextButton(scope, {
                Name = "LeaveBtn",
                Size = UDim2.fromScale(0.2, 0.65),
                Text = "BACK TO INITUS",
                BackgroundTransparency = 0,
                BackgroundColor3 = Components.RED_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_AfterEndAction_S.Fire("Leave")
                        self.AbyssEndActionsClicked:set(true)

                    elseif levelId == "Dungeon" then

                    end
                end,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        }
    })
}
end
