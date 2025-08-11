--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CircleFX = require(script.Parent.Components.CircleFX)
local RevPKSlot = require(script.Parent.Components.GlobalClassPBars.ReverberationPK)

local wait = task.wait


return function (UI: ScreenGui, self: { any })
    local scope = self.scope :: Fusion.Scope
    local bottom = UI.Bottom :: Frame


    --// cd anim
    table.insert(scope, Bindables.CDEndTimeReached:Connect(function(slotId: number)
        local slot = bottom:FindFirstChild(slotId, true) :: Frame?
        if not slot then return end

        local circle = CircleFX(scope)
        Debris:AddItem(circle, 2)

        circle.Parent = slot

        HarukaLib:CreateTween(circle, AssetBook.TweenInfos.onceHalf, { Size = UDim2.fromScale(2, 2) }):Play()
        HarukaLib:UITween(circle, "Out", { DelayTime = 0.2 })
    end))


    --// track effect list
    ClientLib.TrackEffectListToUI({
        Target = self.char,
        Scope = scope,
        GuiContainer = bottom.CharacterStats.Div.Main
    })



    ---// track class: reverberation mechanic
    table.insert(scope, Events.CLASS_RollNewResonateNumForPlayer.On(function(data)
        if not self.UI then return end
        if not self.UI:FindFirstChild("Center") then return end
        if not self.UI.Center:FindFirstChild("GlobalClassAbilityDiv") then return end
        if not self.UI.Center.GlobalClassAbilityDiv:FindFirstChild("ReverberationStyle") then return end


        local ReverberationPKSlot = RevPKSlot(scope, {
            Num = data.ResonateNum
        })
        ReverberationPKSlot.Parent = self.UI.Center.GlobalClassAbilityDiv.ReverberationStyle
        Debris:AddItem(ReverberationPKSlot, 2)


        HarukaLib:UITween(ReverberationPKSlot, "In")
        HarukaLib:UITween(ReverberationPKSlot, "Out", { DelayTime = 1.5, TweenTime = 0.5 })

        SoundService.SFXs.DiceRoll:Play()
    end))
end
