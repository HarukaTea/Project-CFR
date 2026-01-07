
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Types = require(script.Parent.Parent.Types)


return function (self: Types.VFXSceneLib)
    local VFXSceneLib = self

    VFXSceneLib.ChainCombo = function(char: Model)
        local targetingEnemy = char.TargetingEnemy.Value

        local comboEff = ReplicatedStorage.Packages.Effects.PlayerCommon.ComboEffect.Attachment:Clone() :: Attachment
        comboEff.Parent = targetingEnemy.PrimaryPart

        Debris:AddItem(comboEff, 1)
    end
end