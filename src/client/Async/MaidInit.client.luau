local ReplicatedStorage = game:GetService("ReplicatedStorage")


repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

require(ReplicatedStorage.HarukaShared.Shared.Maid):Init()