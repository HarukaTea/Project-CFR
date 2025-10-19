--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait



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

    table.insert(scope, task.spawn(function()
        Promise.new(function(resolve)
            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId)
            local r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)

            resolve(r6Char)

        end):andThen(function(r6Char: Model)
            local r6Char = r6Char :: Model
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

        end):catch(function() end)
    end))


    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-Titlescreen_TempClass"] = function(class: string)
            class = class or "Chain"

            if not workspace:GetAttribute("Titlescreen_ClassSelectionState") then return end

            local cameraLocator = workspace.MapComponents.Titlescreen["CameraLocator2_"..class] :: BasePart

            workspace.MapComponents.Titlescreen.CameraLocator.Value = cameraLocator
        end
    }))
end