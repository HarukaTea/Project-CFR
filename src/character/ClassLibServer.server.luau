
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)



local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait


repeat wait() until char:HasTag("PlayerCharEntity")

local ClassAdd, ClassEmpty = HarukaLib.Bin()
local Add, Empty = HarukaLib.Bin()



type ClassMechanicLibClass = {
    Destroy: (self: ClassMechanicLibClass) -> nil,
    Init: (self: ClassMechanicLibClass) -> nil,


    _ListenClassTracker: (self: ClassMechanicLibClass) -> nil,


    [string]: (self: ClassMechanicLibClass) -> nil
}



local ClassMechanicLib = {} :: ClassMechanicLibClass




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

        if self["_CLASS_"..newClass] then
            self["_CLASS_"..newClass](self)
        end
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
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))
    ClassAdd(HarukaLib.Clock(3.2, function()
        if char:FindFirstChild("IsInComboUltPeriod") then return end


        HarukaLib:AddAttr(char, "ChainCombo", -1)

        if char:GetAttribute("ChainCombo") <= 0 then
            _classAbilityClear()
        end
    end))


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
        if entity:GetAttribute("ReverberationPitch_"..plr.Name) then return end

        entity:SetAttribute("ReverberationPitch_"..plr.Name, RNG:NextInteger(1, 9))
    end))
end


ClassMechanicLib:Init()