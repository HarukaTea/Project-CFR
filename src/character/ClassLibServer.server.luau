--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)

local ClassMechanicLib = {}


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait


repeat wait() until char:HasTag("PlayerCharEntity")

local ClassAdd, ClassEmpty = HarukaLib.Bin()
local Add, Empty = HarukaLib.Bin()


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		ClassMechanicLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    ClassMechanicLib:Destroy()
end))



function ClassMechanicLib:Init()
    ClassMechanicLib:_ListenClassTracker()


    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			self:Destroy()
		end
	end))
	Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
		local newParent = char
        if newParent then
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                self:Destroy()
                return
            end
        else
            self:Destroy()
        end
	end))
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

        if char.Head:FindFirstChild("ComboStyle") then
            char.Head.ComboStyle:Destroy()
        end
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

        if char.Head:FindFirstChild("StackStyle") then
            char.Head.StackStyle:Destroy()
        end
    end
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))


    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Reverberation = function(self)
    local RNG = Random.new()

    ClassAdd(char.PlayerTargetAdded.Event:Connect(function(charId: string, entity: Model)
        if char.Name ~= charId then return end
        if entity:GetAttribute("ReverResonateNum_"..plr.UserId) then return end

        local notOdd = { 2, 4, 6, 8 }
        local resonateNum = notOdd[RNG:NextInteger(1, #notOdd)]
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

        if char.Head:FindFirstChild("FocusStyle") then
            char.Head.FocusStyle:Destroy()
        end
    end
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))


    ClassAdd(HarukaLib.Clock(0.55, function()
        if char:GetAttribute("FlowHeat") > 0 then
            HarukaLib:AddAttr(char, "FlowHeat", -1)

            if char.Head:FindFirstChild("FocusStyle") then
                char.Head.FocusStyle.Text.Text = "FOCUS "..char:GetAttribute("FlowHeat").."%"
            end
        end
    end))


    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Execution = function(self)

end


ClassMechanicLib:Init()