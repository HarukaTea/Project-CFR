
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig", true) :: Configuration
if not worldConfig then return end

local galleonConfig = worldConfig:GetAttribute("CanSkyGalleon") :: boolean
if not galleonConfig then return end

local ClientLib = require(ReplicatedStorage.HarukaShared.Controllers.ClientLib)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local currentGalleon: Model? = nil

repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")

ClientLib:TrackCharDiedEvent({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})

Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-SeatPart"] = function(part: BasePart)
        if part == nil then
            currentGalleon = nil
        else
            if part.Parent and part.Parent.Name == "SkyDriveGalleon" then
                currentGalleon = part.Parent
            end
        end
    end
}))

local ControlsModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")) :: {
    GetControls: (self: any) -> {
        GetMoveVector: (self: any) -> Vector3
    }
}
ControlsModule = ControlsModule:GetControls()

Add(RunService.Heartbeat:Connect(function()
    if not currentGalleon then return end

    Events.DriveSkyGalleon_C.Fire(ControlsModule:GetMoveVector())
end))