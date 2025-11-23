
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
    local function _clearComboUI()
        if char.Head:FindFirstChild("ComboStyle") then
            char.Head.ComboStyle:Destroy()
        end
    end
    local function _classAbilityClear()
        _clearComboUI()

        char:SetAttribute("ChainCombo", 0)
    end


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

            combo = combo or 0
            if combo <= 0 then
                _classAbilityClear()
            end
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
                stackStyle1 = RepS.Packages.ClassAttacks.ClassUIs.StackStyle.StackStyle_Arrow:Clone() :: BillboardGui
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
                stackStyle2 = RepS.Packages.ClassAttacks.ClassUIs.StackStyle.StackStyle_Piercing:Clone() :: BillboardGui
                stackStyle2.Adornee = char.Head
                stackStyle2.Text.Text = arrow.." PIERCING"
                stackStyle2.Parent = char.Head
            end
        end
    }))


    ClassAdd(_classAbilityClear)
end



ClassMechanicLib._CLASS_Flow = function(self)
    local function _clearFlowUI()
        if char.Head:FindFirstChild("FocusStyle") then
            char.Head.FocusStyle:Destroy()
        end
    end
    local function _classAbilityClear()
        _clearFlowUI()

        char:SetAttribute("FlowMark", 0)
    end


    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _classAbilityClear,
    }))
    ClassAdd(HarukaLib:Hydrate(char, {
        ["Attr-FlowMark"] = function(mark: number)
            local realMark = mark * 35
            realMark = math.clamp(realMark, 0, 100)

            if char.Head:FindFirstChild("FocusStyle") then
                char.Head.FocusStyle.Text.Text = "MARK "..realMark.."%"
            else
                local focusStyle = RepS.Packages.ClassAttacks.ClassUIs.FocusStyle.FocusStyle:Clone() :: BillboardGui
                focusStyle.Adornee = char.Head
                focusStyle.Text.Text = "MARK "..realMark.."%"
                focusStyle.Parent = char.Head
            end

            mark = mark or 0
            if mark <= 0 then
                _classAbilityClear()
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


        local num = RNG:NextInteger(1, 5)
        entity:SetAttribute("ReverberationPitch_"..plr.Name, num)


        Events.Class_ReverberationEnemySupport.Fire(plr, {
            Enemy = entity,
            Num = num
        })
    end))
end


ClassMechanicLib:Init()