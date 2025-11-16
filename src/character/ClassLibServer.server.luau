
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
    local chainAdd, chainEmpty = HarukaLib.Bin()
    ClassAdd(chainEmpty)


    local function _clearComboUI()
        if char.Head:FindFirstChild("ComboStyle") then
            char.Head.ComboStyle:Destroy()
        end
    end
    local function _classAbilityClear()
        chainEmpty()
        _clearComboUI()

        char:SetAttribute("ChainCombo", 0)
    end


    local _internal_AttrCD = false


    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear,
    }))
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-ChainCombo"] = function(combo: number)
            if char.Head:FindFirstChild("ComboStyle") then
                char.Head.ComboStyle.Text.Text = "CHAIN x"..combo
            else
                local comboStyle = RepS.Packages.ClassAttacks.ClassUIs.ComboStyle.ComboStyle:Clone() :: BillboardGui
                comboStyle.Adornee = char.Head
                comboStyle.Text.Text = "CHAIN x"..combo
                comboStyle.Parent = char.Head
            end
            if _internal_AttrCD then return end


            combo = combo or 0
            if combo <= 0 then
                _classAbilityClear()
                return
            end

            chainEmpty()
            if char:FindFirstChild("IsInComboUltPeriod") then return end


            chainAdd(HarukaLib.Clock(3.2, function()
                if char:FindFirstChild("IsInComboUltPeriod") then return end

                _internal_AttrCD = true
                HarukaLib:AddAttr(char, "ChainCombo", -1)
                _internal_AttrCD = false


                Events.Class_ChainUIUpdateSupport.Fire(plr)
            end))
        end
    }))
    ClassAdd(_classAbilityClear)
end


ClassMechanicLib._CLASS_Burst = function(self)
    local function _clearStackUI()
        if char.Head:FindFirstChild("StackStyle_Arrow") then
            char.Head.StackStyle_Arrow:Destroy()
        end
        if char.Head:FindFirstChild("StackStyle_Piercing") then
            char.Head.StackStyle_Piercing:Destroy()
        end
    end
    local function _classAbilityClear()
        _clearStackUI()

        char:SetAttribute("BurstArrow", 0)
        char:SetAttribute("BurstArrowPiercing", 0)
        char:SetAttribute("LastBurstTime", nil)
    end
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear
    }))
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-BurstArrow"] = function(arrow: number)
            arrow = arrow or 0

            local stackStyle1 = char.Head:FindFirstChild("StackStyle_Arrow") :: BillboardGui

            if arrow <= 0 then
                if stackStyle1 then stackStyle1:Destroy() end
                return
            end
            if stackStyle1 then
                stackStyle1.Text.Text = arrow.." ARROWS"
            else
                stackStyle1 = RepS.Packages.ClassAttacks.ClassUIs.StackStyle_Arrow.StackStyle:Clone() :: BillboardGui
                stackStyle1.Name = "StackStyle_Arrow"
                stackStyle1.Adornee = char.Head
                stackStyle1.Text.Text = arrow.." ARROWS"
                stackStyle1.Parent = char.Head
            end
        end,
        ["Attr-BurstArrowPiercing"] = function(arrow: number)
            arrow = arrow or 0

            local stackStyle2 = char.Head:FindFirstChild("StackStyle_Piercing") :: BillboardGui

            if arrow <= 0 then
                if stackStyle2 then stackStyle2:Destroy() end
                return
            end
            if stackStyle2 then
                stackStyle2.Text.Text = arrow.." PIERCING"
            else
                stackStyle2 = RepS.Packages.ClassAttacks.ClassUIs.StackStyle_Piercing.StackStyle:Clone() :: BillboardGui
                stackStyle2.Name = "StackStyle_Piercing"
                stackStyle2.Adornee = char.Head
                stackStyle2.Text.Text = arrow.." PIERCING"
                stackStyle2.Parent = char.Head
            end
        end
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