
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
    IsUIShown2: Fusion.Value<boolean>,

    Quests: Fusion.Value<{ StringValue }>,
    NPCs: Fusion.Value<{ Model }>,
    CharPosition: Fusion.Value<Vector3>,

    COLORS: { [string]: Color3 }
}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end

    local char = self.char :: Model
    local plr = self.plr :: Player

    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(true)
    self.IsUIShown2 = Value(true)

    local quests = FusionComponents.useChildren(scope, plr:WaitForChild("Quests", 999))
    local npcs = FusionComponents.useTagged(scope, "NPCEntity")

    self.Quests = quests
    self.NPCs = npcs

    self.CharPosition = Value(Vector3.zero)


    self.COLORS = {
        Main = Color3.fromHex('#2ed573'),
        Side = Color3.fromHex('#fdcb6e'),
        Town = Color3.fromHex('#a29bfe')
    }


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))
    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))


    --// track char position
    table.insert(scope, RunService.Heartbeat:Connect(function()
        if not ClientLib:IsModelValid(char) then return end

        self.CharPosition:set(char.PrimaryPart.Position)
    end))
end