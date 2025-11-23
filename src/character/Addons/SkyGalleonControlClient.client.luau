
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local currentGalleon: Model? = nil


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		Empty()
	end
end))
Add(script.Destroying:Connect(Empty))
Add(char.Humanoid.HealthChanged:Connect(function(health: number)
    if health <= 0 then
        Empty()
    end
end))
Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
    local newParent = char
    if newParent then
        if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
            Empty()
            return
        end
    else
        Empty()
    end
end))
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