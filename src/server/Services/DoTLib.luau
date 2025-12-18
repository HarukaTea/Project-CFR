
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")



export type DoTInfo = {
    Target: Model,
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
}

export type DoTLibClass = {
    __index: DoTLibClass,

    new: (info: DoTInfo) -> DoTLibClass,

    UniqueId: string,
    Cancelled: boolean,
    Activated: boolean,

    Activate: (self: DoTLibClass) -> nil,
    Cancel: (self: DoTLibClass) -> nil,
    StackCancel: (self: DoTLibClass) -> nil,
    Calulate: (self: DoTLibClass) -> nil,

    StartTime: number,

    GetEffectsByTarget: (self: DoTLibClass, target: Model, effectId: string?) -> { DoTLibClass },
    GetAffectedTargetsByEffectId: (self: DoTLibClass, effectId: string) -> { DoTLibClass },
} & DoTInfo


local DoTLib = {} :: DoTLibClass
DoTLib.__index = DoTLib

local GlobalTimer = require(ServerScriptService.HarukaServer.Shared.GlobalTimer)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local StatusLib = require(ServerScriptService.HarukaServer.Library.StatusLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)


local allDoTObjs = {} :: { [string]: DoTLibClass }


--// Constructor
function DoTLib.new(info: DoTInfo)
    local self = setmetatable({}, DoTLib) :: DoTLibClass

    self.Target = info.Target
    self.Type = info.Type
    self.Creator = info.Creator
    self.Power = info.Power
    self.Duration = info.Duration

    self.UniqueId = HttpService:GenerateGUID(false)
    self.Cancelled = false

    self.StartTime = DateTime.now().UnixTimestamp
    self:Calulate()

    allDoTObjs[self.UniqueId] = self

    return self
end


function DoTLib:Calulate()
    local existing = self:GetEffectsByTarget(self.Target, self.Type)
    if #existing > 0 then
        local oldRemaining = 0

        for _, thatObj in existing do
            local startTime = thatObj.StartTime
            local timePassed = DateTime.now().UnixTimestamp - startTime
            local progress = math.clamp(timePassed / thatObj.Duration, 0, 1)

            local remainingDMG = thatObj.Power * thatObj.Duration * (1 - progress)
            oldRemaining += remainingDMG

            thatObj:StackCancel()
        end

        local newTotalDMG = oldRemaining + (self.Power * self.Duration)
        self.Power = newTotalDMG / self.Duration
    end
end


function DoTLib:Activate()
    if self.Activated then return end

    self.Activated = true
    if not ServerLib:IsCharValid(self.Target) then return end

    local effectSymbol = Instance.new("StringValue")
    effectSymbol.Name = self.Type.."Debuff"
    effectSymbol.Value = self.Type.."Debuff"

    effectSymbol:SetAttribute("Ex", 0)
    effectSymbol:SetAttribute("ExPower", self.Power)
    effectSymbol:SetAttribute("EndClock", DateTime.now().UnixTimestamp + self.Duration)

    effectSymbol:SetAttribute("IsDebuff", true)
    effectSymbol:SetAttribute("TaskUniqueId", self.UniqueId)

    effectSymbol.Parent = self.Target.EffectList
    Debris:AddItem(effectSymbol, self.Duration)

    self.EffectSymbol = effectSymbol


    Events.DoT_PlayVFXEff_S.FireList(ServerLib:GetNearbyPlayers(self.Target.WorldPivot.Position), {
        StatusId = self.Type,
        Entity = self.Target,

        UniqueId = self.UniqueId,
        Duration = self.Duration,
    })

    self.Tasks = {}

    for i = 1, self.Duration do
        table.insert(self.Tasks, GlobalTimer:AddTask(i, function()
            if not ServerLib:IsCharValid(self.Target) then return end

            if StatusLib.DoT[self.Type] then
                StatusLib.DoT[self.Type](self.Target, self)
            end
        end))
    end
    Promise.delay(self.Duration + 0.1):andThenCall(self.Cancel, self):catch(function() end)


    --// fire char bindable
    if Players:GetPlayerFromCharacter(self.Creator) and self.Target:HasTag("EnemyEntity") then
        local char = self.Creator :: Model

        for _, bindable: BindableEvent in char:QueryDescendants("BindableEvent#EnemyStatusApplied") do
            bindable:Fire(self.Target, char, {
                Target = self.Target,
                Type = self.Type,
                Creator = char,
                Power = self.Power,
                Duration = self.Duration,
            })
        end
    end
end


function DoTLib:StackCancel()
    allDoTObjs[self.UniqueId] = nil

    if self.EffectSymbol then
        self.EffectSymbol:Destroy()
        self.EffectSymbol = nil
    end

    for _, taskId: string in self.Tasks do
        GlobalTimer:CancelTaskImmediately(taskId)
    end
    self.Tasks = nil

    Events.DoT_PlayVFXEff_S.FireList(ServerLib:GetNearbyPlayers(self.Target.WorldPivot.Position), {
        Duration = 0,
        StatusId = "Clear",
        Entity = self.Target,
        UniqueId = self.UniqueId,
    })
end


function DoTLib:Cancel()
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
    Events.DoT_PlayVFXEff_S.FireList(ServerLib:GetNearbyPlayers(self.Target.WorldPivot.Position), {
        Duration = 0,
        StatusId = "Clear",
        Entity = self.Target,
        UniqueId = self.UniqueId,
    })


    allDoTObjs[self.UniqueId] = nil


    --// fire char bindable
    if Players:GetPlayerFromCharacter(self.Creator) and self.Target:HasTag("EnemyEntity") then
        local char = self.Creator :: Model

        for _, bindable: BindableEvent in char:QueryDescendants("BindableEvent#EnemyStatusRemoved") do
            bindable:Fire(self.Target, char, {
                Target = self.Target,
                Type = self.Type,
                Creator = char,
                Power = self.Power,
                Duration = self.Duration,
            })
        end
    end
end




function DoTLib:GetEffectsByTarget(target: Model, effectId: string?)
    local objs = {} :: { DoTLibClass }
    local realObjs = {} :: { DoTLibClass }

    for _, thatObj in allDoTObjs do
        if thatObj.Target == target then
            table.insert(objs, thatObj)
            break
        end
    end
    if effectId then
        for _, thatObj in objs do
            if thatObj.Type == effectId then
                table.insert(realObjs, thatObj)
            end
        end
    else
        realObjs = objs
    end


    return realObjs
end


function DoTLib:GetAffectedTargetsByEffectId(effectId: string)
    local objs = {} :: { DoTLibClass }

    for _, thatObj in allDoTObjs do
        if thatObj.Type == effectId then
            table.insert(objs, thatObj)
        end
    end

    return objs
end


return DoTLib