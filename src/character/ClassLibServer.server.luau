local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local ClassMechanicLib = {}



local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait


repeat wait() until char:GetAttribute("Haruka_CharServerInited")

local ClassAdd, ClassEmpty = HarukaLib.Bin()
local Add, Empty = HarukaLib.Bin()


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		ClassMechanicLib:Destroy()
	end
end))



function ClassMechanicLib:Init()
    for funcId: string, func: (self) -> nil in ClassMechanicLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            Promise.try(func, self)
        end
    end
end

function ClassMechanicLib:Destroy()
    ClassEmpty()
    Empty()
end


--// Private Methods

function ClassMechanicLib:_ListenClassTracker()
    local function _classHandler()
        ClassEmpty()

        local newClass = plr:GetAttribute("Class") :: string

        if not self["_CLASS_"..newClass] then
            warn("Invalid CLASS Func Id")
            return
        end

        self["_CLASS_"..newClass](self)
    end
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Class"] = _classHandler
    }))
end


ClassMechanicLib._CLASS_Chain = function(self)
    local function _classAbilityClear()
        char:SetAttribute("ChainCombo", 0)
    end
    local function _airCheck(state: Enum.HumanoidStateType)
        if state == Enum.HumanoidStateType.Landed
            or state ~= Enum.HumanoidStateType.Jumping
            or state ~= Enum.HumanoidStateType.Freefall then

            _classAbilityClear()
        end
    end
    ClassAdd(char.Humanoid.StateChanged:Connect(_airCheck))
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))


    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Burst = function(self)
    local function _classAbilityClear()
        char:SetAttribute("BurstArrow", 0)
    end
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))


    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Reverberation = function(self)
    ClassAdd(ServerBindables.PlayerTargetingListChanged:Connect(function(charId: string, entity: Model)
        if char.Name ~= charId then return end

        local resonateNum = math.random(1, 9)
        entity:SetAttribute("ReverResonateNum_"..plr.UserId, resonateNum)

        Events.CLASS_RollNewResonateNumForEnemy.Fire(plr, {
            Entity = entity,
            ResonateNum = resonateNum
        })
    end))
end


ClassMechanicLib._CLASS_Flow = function(self)
    local function _classAbilityClear()
        char:SetAttribute("FlowHeat", 0)
    end
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))


    ClassAdd(HarukaLib.Clock(0.45, function()
        if char:GetAttribute("FlowHeat") > 0 then
            HarukaLib:AddAttr(char, "FlowHeat", -1)
        end
    end))


    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Rise = function(self)

end


ClassMechanicLib:Init()