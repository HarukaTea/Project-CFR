
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,

    IsUIShown: Fusion.Value<boolean>,
    Quests: Fusion.Value<{ StringValue }>,
    NPCs: Fusion.Value<{ Model }>,
    StoryLocators: Fusion.Value<{ BasePart }>,
    CharPosition: Fusion.Value<Vector3>,
}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end

    local char = self.char :: Model
    local plr = self.plr :: Player

    local scope = self.scope :: Fusion.Scope<any>

    self.IsUIShown = Value(true)

    local quests = FusionComponents.useChildren(scope, plr:WaitForChild("Quests", 999))
    local npcs = FusionComponents.useTagged(scope, "NPCEntity")
    local storyLocators = FusionComponents.useTagged(scope, "StoryLocatorEntity")

    self.Quests = quests
    self.NPCs = npcs
    self.StoryLocators = storyLocators

    self.CharPosition = Value(Vector3.zero)


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))


    --// track char position
    table.insert(scope, RunService.Heartbeat:Connect(function()
        if not ClientLib.IsModelValid(char) then return end

        self.CharPosition:set(char.PrimaryPart.Position)
    end))
end