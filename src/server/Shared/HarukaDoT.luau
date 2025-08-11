local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local HarukaDoT = {}
HarukaDoT.__index = HarukaDoT


local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)
local GlobalTimer = require(ServerScriptService.HarukaServer.Shared.GlobalTimer)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local StatusLib = require(ServerScriptService.HarukaServer.Library.StatusLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


HarukaDoT.OnEffectActivated = Signal.new()
HarukaDoT.OnEffectCancelled = Signal.new()


local allDoTObjs = {}


--// Constructor
function HarukaDoT.new(info: {
    Target: Model,
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
})
    local self = setmetatable({}, HarukaDoT)

    self.Target = info.Target
    self.Type = info.Type
    self.Creator = info.Creator
    self.Power = info.Power
    self.Duration = info.Duration

    self.UniqueId = HttpService:GenerateGUID(false)
    self.Cancelled = false

    allDoTObjs[self.UniqueId] = self

    return self
end


function HarukaDoT:Activate()
    if not ServerLib.IsCharValid(self.Target) then return end

    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = "EffectSymbol"
    effectSymbol.Value = self.Type.."Debuff"

    effectSymbol:SetAttribute("Ex", 0)
    effectSymbol:SetAttribute("ExPower", self.Power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + self.Duration)

    effectSymbol:SetAttribute("IsDebuff", true)
    effectSymbol:SetAttribute("TaskUniqueId", self.UniqueId)

    effectSymbol.Parent = self.Target.EffectList
    Debris:AddItem(effectSymbol, self.Duration)

    self.EffectSymbol = effectSymbol


    local effectParticle = ReplicatedStorage.Packages.Effects.Status:FindFirstChild(self.Type, true) :: BasePart
    if effectParticle then
        effectParticle = effectParticle.Attachment:Clone()
        effectParticle.Parent = self.Target.PrimaryPart
        Debris:AddItem(effectParticle, self.Duration)

        self.EffectParticle = effectParticle
    end


    HarukaDoT.OnEffectActivated:Fire(self)

    self.Tasks = {}

    for i = 1, self.Duration do
        table.insert(self.Tasks, GlobalTimer:AddTask(i, function()
            if not ServerLib.IsCharValid(self.Target) then return end

            if StatusLib[self.Type] then
                StatusLib[self.Type](StatusLib, self.Target, self)
            end
        end))
    end
    Promise.delay(self.Duration + 0.1):andThenCall(self.Cancel, self):catch(function() end)
end


function HarukaDoT:Cancel()
    if self.Cancelled then return end

    self.Cancelled = true


    for _, taskId: string in self.Tasks do
        GlobalTimer:CancelTaskImmediately(taskId)
    end
    self.Tasks = nil

    if self.EffectSymbol then
        self.EffectSymbol:Destroy()
        self.EffectSymbol = nil
    end
    if self.EffectParticle then
        self.EffectParticle:Destroy()
        self.EffectParticle = nil
    end


    HarukaDoT.OnEffectCancelled:Fire(self)


    allDoTObjs[self.UniqueId] = nil
end


function HarukaDoT:GetEffectsByTarget(target: Model)
    local objs = {}

    for _, thatObj in allDoTObjs do
        if thatObj.Target == target then
            table.insert(objs, thatObj)
            break
        end
    end

    return objs
end


function HarukaDoT:GetAffectedTargetsByEffectId(effectId: string)
    local objs = {}

    for _, thatObj in allDoTObjs do
        if thatObj.Type == effectId then
            table.insert(objs, thatObj)
        end
    end

    return objs
end


return HarukaDoT
