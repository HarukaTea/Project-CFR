--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")


repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")


local BoneWave = require(ReplicatedStorage.HarukaShared.Shared.Ambient.BoneWave)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

BoneWave:SetEnabled(true)


HarukaLib:Hydrate(workspace, {
	["Attr-WaveEffectEnabled"] = function(state: boolean)
		state = state or false

		BoneWave:SetEnabled(state)
	end,
})

workspace:SetAttribute("WaveEffectEnabled", true)