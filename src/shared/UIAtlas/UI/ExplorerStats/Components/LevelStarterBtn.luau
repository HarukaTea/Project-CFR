
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Pinia = require(script.Parent.Parent.Pinia)

local Children = Fusion.Children

return function(scope: Fusion.Scope, levelId: string, self: Pinia.Self)
    return { Fusion.Hydrate(scope, Components:RefUI("LevelStarterAbyss_PStat1_1", false, true))({
        Name = "LevelStarter_"..levelId,
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
            Fusion.Hydrate(scope, Components:RefUI("StarterBtn_LSAPStat1_2", true))({
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_StartAbyss_C.Fire()

                    elseif levelId == "Dungeon" then

                    end
                end
            })
        }
    }),
    Fusion.Hydrate(scope, Components:RefUI("LevelEndActionsAbyss_PStats1_1", false, true))({
        Name = "LevelEndActions_"..levelId,
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
            Fusion.Hydrate(scope, Components:RefUI("RestartBtn_LEAPStats1_1", true))({
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_AfterEndAction_S.Fire("Restart")
                        self.AbyssEndActionsClicked:set(true)
                        task.delay(5, function()
                            self.AbyssEndActionsClicked:set(false)
                        end)

                    elseif levelId == "Dungeon" then

                    end
                end
            }),
            Fusion.Hydrate(scope, Components:RefUI("LeaveBtn_LEAPStats1_1", true))({
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if levelId == "Abyss" then
                        Events.Abyss_AfterEndAction_S.Fire("Leave")
                        self.AbyssEndActionsClicked:set(true)
                        task.delay(5, function()
                            self.AbyssEndActionsClicked:set(false)
                        end)

                    elseif levelId == "Dungeon" then

                    end
                end
            })
        }
    })
}
end
