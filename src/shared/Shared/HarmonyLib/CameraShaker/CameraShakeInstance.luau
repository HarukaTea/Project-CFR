-- Camera Shake Instance
-- @Author: Stephen Leitnick, Modified by HarukaTea
-- February 26, 2018, Modified in Jan 12, 2026

export type CameraShakeInstanceClass = {
	__index: CameraShakeInstanceClass,

	new: (magnitude: number, roughness: number, fadeInTime: number?, fadeOutTime: number?) -> CameraShakeInstanceClass,

	CameraShakeState: { FadingIn: number, FadingOut: number, Sustained: number, Inactive: number },

	Magnitude: number,
	Roughness: number,
	PositionInfluence: Vector3,
	RotationInfluence: Vector3,
	DeleteOnInactive: boolean,
	RoughMod: number,
	MagnMod: number,
	FadeOutDuration: number,
	FadeInDuration: number,
	IsSustain: boolean,
	CurrentFadeTime: number,
	Tick: number,
	IsCameraShakeInstanceType: boolean,

	UpdateShake: (self: CameraShakeInstanceClass, dt: number) -> Vector3,
	StartFadeOut: (self: CameraShakeInstanceClass, fadeOutTime: number) -> nil,
	StartFadeIn: (self: CameraShakeInstanceClass, fadeInTime: number?) -> nil,
	IsShaking: (self: CameraShakeInstanceClass) -> boolean,
	IsFadingOut: (self: CameraShakeInstanceClass) -> boolean,
	IsFadingIn: (self: CameraShakeInstanceClass) -> boolean,
	GetState: (self: CameraShakeInstanceClass) -> number,
}

local CameraShakeInstance = {}
CameraShakeInstance.__index = CameraShakeInstance

CameraShakeInstance.CameraShakeState = {
	FadingIn = 0,
	FadingOut = 1,
	Sustained = 2,
	Inactive = 3,
}

function CameraShakeInstance.new(magnitude: number, roughness: number, fadeInTime: number?, fadeOutTime: number?)
	fadeInTime = fadeInTime or 0
	fadeOutTime = fadeOutTime or 0

	local self = setmetatable({}, CameraShakeInstance)

	self.Magnitude = magnitude
	self.Roughness = roughness
	self.PositionInfluence = Vector3.zero
	self.RotationInfluence = Vector3.zero
	self.DeleteOnInactive = true
	self.RoughMod = 1
	self.MagnMod = 1
	self.FadeOutDuration = fadeOutTime
	self.FadeInDuration = fadeInTime
	self.IsSustain = (fadeInTime > 0)
	self.CurrentFadeTime = (fadeInTime > 0 and 0 or 1)
	self.Tick = Random.new():NextNumber(-100, 100)
	self.IsCameraShakeInstanceType = true

	return self
end

function CameraShakeInstance:UpdateShake(dt)
	local cTick = self.Tick
	local currentFadeTime = self.CurrentFadeTime

	local offset = Vector3.new(
		math.noise(cTick, 0) * 0.5,
		math.noise(0, cTick) * 0.5,
		math.noise(cTick, cTick) * 0.5
	)

	if self.FadeInDuration > 0 and self.IsSustain then
		if currentFadeTime < 1 then
			currentFadeTime += (dt / self.FadeInDuration)
		elseif self.FadeOutDuration > 0 then
			self.IsSustain = false
		end
	end

	if not self.IsSustain then
		currentFadeTime -= (dt / self.FadeOutDuration)
	end

	if self.IsSustain then
		self.Tick = cTick + (dt * self.Roughness * self.RoughMod)
	else
		self.Tick = cTick + (dt * self.Roughness * self.RoughMod * currentFadeTime)
	end
	self.CurrentFadeTime = currentFadeTime

	return offset * self.Magnitude * self.MagnMod * currentFadeTime
end

function CameraShakeInstance:StartFadeOut(fadeOutTime)
	if fadeOutTime == 0 then
		self.CurrentFadeTime = 0
	end
	self.FadeOutDuration = fadeOutTime
	self.FadeInDuration = 0
	self.IsSustain = false
end

function CameraShakeInstance:StartFadeIn(fadeInTime)
	if fadeInTime == 0 then
		self.CurrentFadeTime = 1
	end
	self.FadeInDuration = fadeInTime or self.FadeInDuration
	self.FadeOutDuration = 0
	self.IsSustain = true
end

function CameraShakeInstance:IsShaking()
	return (self.CurrentFadeTime > 0 or self.IsSustain)
end
function CameraShakeInstance:IsFadingOut()
	return ((not self.IsSustain) and self.CurrentFadeTime > 0)
end
function CameraShakeInstance:IsFadingIn()
	return (self.CurrentFadeTime < 1 and self.IsSustain and self.FadeInDuration > 0)
end

function CameraShakeInstance:GetState()
	if self:IsFadingIn() then
		return CameraShakeInstance.CameraShakeState.FadingIn
	elseif self:IsFadingOut() then
		return CameraShakeInstance.CameraShakeState.FadingOut
	elseif self:IsShaking() then
		return CameraShakeInstance.CameraShakeState.Sustained
	else
		return CameraShakeInstance.CameraShakeState.Inactive
	end
end

return CameraShakeInstance
