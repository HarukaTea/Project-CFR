--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end

    local char = self.char :: Model

    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(true)
    self.Quests = FusionComponents.useFolder(scope, self.plr:WaitForChild("Quests", 999))
    self.NPCs = FusionComponents.useTagged(scope, "NPCEntity")

    self.StoryLocators = FusionComponents.useTagged(scope, "StoryLocatorEntity")

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