
repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")

local RepS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Particles = require(RepS.HarukaShared.Controllers.RainParticle).new()

--// Variables

local rainSound = SoundService.Environment.RainSound :: Sound
rainSound.Playing = true
rainSound.Volume = 0

--// Private functions

local function adjustRain(rainLevel: number)
	rainLevel = rainLevel or 0
	rainLevel = math.clamp(rainLevel, 0, 5)

	if rainLevel <= 0 or not workspace:GetAttribute("RainEffectEnabled") then
		Particles:Disable()

		HarukaLib:CreateTween(rainSound, AssetBook.TweenInfos.half, {
			Volume = 0
		}):Play()
		return
	end

	Particles:Enable()
	Particles:SetRainCastParticleRate(rainLevel * 15)

    HarukaLib:CreateTween(rainSound, AssetBook.TweenInfos.half, {
        Volume = math.clamp(rainLevel * 0.15, 0, 1)
    }):Play()
end

--// Listeners

adjustRain(0)

HarukaLib:Hydrate(Lighting, {
	["Attr-RainLevel"] = adjustRain,
})
HarukaLib:Hydrate(workspace, {
	["Attr-RainEffectEnabled"] = function(state: boolean)
		state = state or false

		adjustRain(Lighting:GetAttribute("RainLevel") or 0)
	end,
})

workspace:SetAttribute("RainEffectEnabled", true)