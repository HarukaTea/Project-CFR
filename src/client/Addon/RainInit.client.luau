--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Particles = require(RepS.HarukaShared.Shared.Ambient.RainParticle).new()
local Splash = require(RepS.HarukaShared.Shared.Ambient.RainSplash).new()

--// Variables

local rainSound = SoundService.Environment.RainSound :: Sound
rainSound.Playing = true
rainSound.Volume = 0


--// Private functions

local function adjustRain(rainLevel: number)
	if rainLevel <= 0 then
		Particles:Disable()
		Particles:SetRainCastParticleRate(0)

		Splash:Disable()

		TS:Create(rainSound, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()

		return
	end

	Particles:Enable()
	Particles:SetRainCastParticleRate(rainLevel * 15)


	Splash:Enable()
	Splash:SetSplashRate(rainLevel * 5 + 5)

    HarukaLib:CreateTween(rainSound, AssetBook.TweenInfos.half, {
        Volume = math.clamp(rainLevel * 0.25, 0, 1.15)
    }):Play()
end


--// Listeners

HarukaLib:Hydrate(Lighting, {
	["Attr-RainLevel"] = function(newLevel: number)
		if not newLevel then return end

		adjustRain(newLevel)
	end
})


--// Init

Lighting:SetAttribute("RainLevel", 0)
