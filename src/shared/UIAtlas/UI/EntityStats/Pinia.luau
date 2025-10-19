--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown2: Fusion.Value<boolean>,
    Enemies: Fusion.Value<{ Instance }>,
    EnemiesOverworld: Fusion.Value<{ Instance }>,
    TargetingList: Fusion.Value<{ Instance }>,
    TargetingEnemy: Fusion.Value<Instance>,
    TargetArrowPos: Fusion.Value<UDim2>,
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.Enemies = FusionComponents.useTagged(scope, "EnemyEntity_Combat")
    self.EnemiesOverworld = FusionComponents.useTagged(scope, "EnemyEntity")

    self.TargetingList = FusionComponents.useFolder(scope, (self.char :: any):WaitForChild("TargetingList", 999))
    self.TargetingEnemy = FusionComponents.useValue(scope, self.char:WaitForChild("TargetingEnemy", 999))


    local targetArrowTweenSymbol = Instance.new("Frame")
    targetArrowTweenSymbol.Name = "TargetArrowTween"
    targetArrowTweenSymbol.Position = UDim2.fromScale(-0.2, 0.4)
    targetArrowTweenSymbol.Parent = game:GetService("ServerStorage")
    table.insert(scope, targetArrowTweenSymbol)


    self.TargetArrowPos = Value(targetArrowTweenSymbol.Position)


    table.insert(scope, HarukaLib:Hydrate(targetArrowTweenSymbol, {
        ["Prop-Position"] = function(pos: UDim2)
            self.TargetArrowPos:set(pos)
        end
    }))
    HarukaLib:CreateTween(targetArrowTweenSymbol, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, math.huge - 1, true, 0), {
        Position = UDim2.fromScale(-0.26, 0.4)
    }):Play()


    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))
end