-- Camera Shaker
-- @Author: Stephen Leitnick, Modified by HarukaTea
-- February 26, 2018, Modified in Jan 12, 2026

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local CameraShakeInstance = require(script.CameraShakeInstance)
local CameraShakeState = CameraShakeInstance.CameraShakeState

export type CameraShakerClass = {
    __index: CameraShakerClass,

    new: (renderPriority: number, callback: (cf: CFrame) -> nil) -> CameraShakerClass,

    Running: boolean,
    RenderName: string,
    RenderPriority: number,
    PosAddShake: Vector3,
    RotAddShake: Vector3,
    CamShakeInstances: { CameraShakeInstance.CameraShakeInstanceClass },
    RemoveInstances: { CameraShakeInstance.CameraShakeInstanceClass },
    Callback: (cf: CFrame) -> nil,

    Start: (self: CameraShakerClass) -> nil,
    Stop: (self: CameraShakerClass) -> nil,
    StopSustained: (self: CameraShakerClass, duration: number?) -> nil,
    Update: (self: CameraShakerClass, dt: number) -> CFrame,
    Shake: (self: CameraShakerClass, shakeInstance: CameraShakeInstance.CameraShakeInstanceClass) -> CameraShakeInstance.CameraShakeInstanceClass,
    ShakeSustain: (self: CameraShakerClass, shakeInstance: CameraShakeInstance.CameraShakeInstanceClass) -> CameraShakeInstance.CameraShakeInstanceClass,

    Presets: { [string]: () -> CameraShakeInstance.CameraShakeInstanceClass }
}

local CameraShaker = {} :: CameraShakerClass
CameraShaker.__index = CameraShaker

CameraShaker.Presets = require(script.CameraShakePresets)
CameraShaker.CameraShakeInstance = CameraShakeInstance

function CameraShaker.new(renderPriority: number, callback: () -> nil)
	local self = setmetatable({}, CameraShaker)

    self.Running = false
    self.RenderName = "CameraShaker_"..HttpService:GenerateGUID(false)
    self.RenderPriority = renderPriority
    self.PosAddShake = Vector3.zero
    self.RotAddShake = Vector3.zero
    self.CamShakeInstances = {}
    self.RemoveInstances = {}
    self.Callback = callback

	return self
end

function CameraShaker:Start()
    if self.Running then return end
    self.Running = true

    RunService:BindToRenderStep(self.RenderName, self.RenderPriority, function(dt)
        local cf = self:Update(dt)
        self.Callback(cf)
    end)
end

function CameraShaker:Stop()
    if not self.Running then return end

    RunService:UnbindFromRenderStep(self.RenderName)
    self.Running = false
end

function CameraShaker:StopSustained(duration: number?)
	for _, c in self.CamShakeInstances do
		if c.FadeOutDuration == 0 then
			c:StartFadeOut(duration or c.FadeInDuration)
		end
	end
end

function CameraShaker:Update(dt: number)
	local posAddShake = Vector3.zero
	local rotAddShake = Vector3.zero

	local instances = self.CamShakeInstances

	-- Update all instances:
	for i = 1, #instances do
		local c = instances[i]
		local state = c:GetState()

		if state == CameraShakeState.Inactive and c.DeleteOnInactive then
            table.insert(self.RemoveInstances, i)

		elseif state ~= CameraShakeState.Inactive then
			local shake = c:UpdateShake(dt)
			posAddShake = posAddShake + (shake * c.PositionInfluence)
			rotAddShake = rotAddShake + (shake * c.RotationInfluence)
		end
	end

	-- Remove dead instances:
	for i = #self.RemoveInstances, 1, -1 do
		local instIndex = self.RemoveInstances[i]
		table.remove(instances, instIndex)
		self.RemoveInstances[i] = nil
	end

	return CFrame.new(posAddShake)
        * CFrame.Angles(0, math.rad(rotAddShake.Y), 0)
        * CFrame.Angles(math.rad(rotAddShake.X), 0, math.rad(rotAddShake.Z))
end

function CameraShaker:Shake(shakeInstance: CameraShakeInstance.CameraShakeInstanceClass)
    table.insert(self.CamShakeInstances, shakeInstance)
	return shakeInstance
end

function CameraShaker:ShakeSustain(shakeInstance: CameraShakeInstance.CameraShakeInstanceClass)
    table.insert(self.CamShakeInstances, shakeInstance)

    shakeInstance:StartFadeIn(shakeInstance.FadeInDuration)
	return shakeInstance
end

return CameraShaker
