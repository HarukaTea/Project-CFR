
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown: Fusion.Value<boolean>,


}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end

    local char = self.char :: Model
    local plr = self.plr :: Player

    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(true)


end