
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local Events = require(RepS.HarukaShared.Library.Events)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown: Fusion.Value<boolean>,
    IsUIShown2: Fusion.Value<boolean>,

    Enemies: Fusion.Value<{ Instance }>,
    EnemiesOverworld: Fusion.Value<{ Instance }>,
    TargetingList: Fusion.Value<{ Instance }>,
    TargetingEnemy: Fusion.Value<Instance>,
    TargetArrowPos: Fusion.Value<UDim2>,

    SwitchTargetFunc: () -> nil,
    ForceSwitchTargetFunc: (target: Model) -> nil,
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    local char = self.char

    self.Enemies = FusionComponents.useTagged(scope, "EnemyEntity_Combat")
    self.EnemiesOverworld = FusionComponents.useTagged(scope, "EnemyEntity")

    self.TargetingList = FusionComponents.useChildren(scope, char:WaitForChild("TargetingList", 999))
    self.TargetingEnemy = FusionComponents.useValue(scope, char:WaitForChild("TargetingEnemy", 999))


    self.IsUIShown = Value(true)

    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))


    --// handle arrow position

    local targetArrowTweenSymbol = Instance.new("Frame")
    targetArrowTweenSymbol.Name = "TargetArrowTween"
    targetArrowTweenSymbol.Position = UDim2.fromScale(-0.24, 0.4)
    targetArrowTweenSymbol.Parent = game:GetService("ServerStorage")
    table.insert(scope, targetArrowTweenSymbol)


    self.TargetArrowPos = Value(targetArrowTweenSymbol.Position)


    table.insert(scope, HarukaLib:Hydrate(targetArrowTweenSymbol, {
        ["Prop-Position"] = function(pos: UDim2)
            self.TargetArrowPos:set(pos)
        end
    }))

    local arrowTween = HarukaLib:CreateTween(targetArrowTweenSymbol, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, math.huge - 1, true, 0), {
        Position = UDim2.fromScale(-0.3, 0.4)
    })
    table.insert(scope, arrowTween)

    arrowTween:Play()


    --// switch target
    self.SwitchTargetFunc = function()
        local targetingEnemies = char:FindFirstChild("TargetingList")
        if not targetingEnemies then return end

        local enemySymbols = targetingEnemies:GetChildren() :: { ObjectValue }
        if #enemySymbols <= 0 then return end

        SoundService.SFXs.MobSelect:Play()

        local curTarget = char.TargetingEnemy.Value

        local enemies = {}
        for _, symbol in enemySymbols do
            table.insert(enemies, symbol.Value)
        end
        local curIndex = table.find(enemies, curTarget) or 0

        curIndex += 1
        if curIndex > #enemies then
            curIndex = 1
        end

        local nextTarget = enemies[curIndex]
        if curTarget == nextTarget then return end


        Events.SwitchTargetEnemy_C.Fire(nextTarget)
    end
    self.ForceSwitchTargetFunc = function(target: Model)
        local curTarget = char.TargetingEnemy.Value
        if curTarget == target then return end

        Events.SwitchTargetEnemy_C.Fire(target)
    end
    table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj, gpe)
        if gpe then return end

        local isGamepad = string.find(inputObj.UserInputType.Name, "Gamepad")
        local isKeyboard = string.find(inputObj.UserInputType.Name, "Keyboard")
        if not isGamepad and not isKeyboard then return end


        if isGamepad then
            if inputObj.KeyCode == KeybindsBook.Console.TargetSwitch then
                self.SwitchTargetFunc()
            end
        elseif isKeyboard then
            if inputObj.KeyCode == KeybindsBook.PC.TargetSwitch then
                self.SwitchTargetFunc()
            end
        end
    end))


    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))
end