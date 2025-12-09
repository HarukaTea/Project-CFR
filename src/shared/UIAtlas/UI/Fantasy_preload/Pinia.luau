
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local Promise = require(RepS.HarukaShared.Shared.Promise)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    SlotUISignal: Signal.SignalClass,
    CutsceneUISignal: Signal.SignalClass,

    CharVals: { Fusion.Value<Model?> },
}


return function (self: Self)
	local scope = self.scope :: Fusion.Scope


	self.SlotUISignal = Signal.new()
    self.CutsceneUISignal = Signal.new()
    table.insert(scope, self.SlotUISignal)
    table.insert(scope, self.CutsceneUISignal)

    self.CharVals = {}

    for _ = 1, 3 do
        table.insert(self.CharVals, Fusion.Value(scope, nil))
    end


    --// Rigging
    do
        local r6Char = RepS.Packages.Unloads.DummyH:Clone() :: Model
        local r6CharHumanoid = r6Char.Humanoid :: Humanoid

        r6Char.Name = "Rig"
        r6Char.PrimaryPart = r6CharHumanoid.RootPart

        r6CharHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        r6CharHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

        r6Char.Animate:Destroy()
        r6Char.Parent = workspace.MapComponents.Titlescreen

        for _, val in self.CharVals do
            local clonedChar = r6Char:Clone()
            clonedChar:PivotTo(workspace.MapComponents.Titlescreen.CharPreviewLocator.CFrame)
            clonedChar.Parent = workspace.MapComponents.Titlescreen

            val:set(clonedChar)
        end
    end
end