
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ReverberationPK = require(script.Parent.Components.ReverberationPK)

local Pinia = require(script.Parent.Pinia)

return function (UI: ScreenGui, self: Pinia.Self)
    local scope = self.scope
    local bottom = UI.Bottom :: Frame

    --// reverb
    table.insert(scope, Events.Class_ReverberationSupport.On(function(num: number)
        if not bottom then return end
        if not bottom:FindFirstChild("ClassAbilityDiv_Bottom") then return end
        if not bottom.ClassAbilityDiv_Bottom:FindFirstChild("ReverberationStyle") then return end

        local newScope = Fusion.scoped()

        local pk = ReverberationPK(newScope, {
            Num = num
        })
        pk.Parent = bottom.ClassAbilityDiv_Bottom.ReverberationStyle

        Debris:AddItem(pk, 2.5)

        Promise.delay(2.5):andThen(function()
            Fusion.doCleanup(newScope)
        end):catch(function() end)

        HarukaLib:UITween(pk, "Out", { TweenTime = 0.5, DelayTime = 2 })

        SoundService.SFXs.DiceRoll:Play()
    end))
    table.insert(scope, Events.Class_ReverberationEnemySupport.On(function(data)
        local enemy = data.Enemy
        if not ClientLib:IsCharValid(enemy) then return end

        repeat task.wait(0.5) until enemy:FindFirstChild("Head")

        local pointUI = RepS.Packages.ClassAttacks.ClassUIs.ReverberationStyle.ReverberationStyle:Clone() :: BillboardGui
        pointUI.Adornee = enemy.Head
        pointUI.Frame.Text.Text = data.Num
        pointUI.Parent = enemy.Head

        table.insert(scope, pointUI)
    end))
end