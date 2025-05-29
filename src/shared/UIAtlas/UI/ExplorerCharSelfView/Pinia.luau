--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.Class = Value("Burst")
    self.Level = Value(1)
    self.EXP = Value(0)


    self.PerkPoints = Value(0)
    self.Points = {
        STR = Value(0),
        DEX = Value(0),
        INT = Value(0),
        VIT = Value(0),
    }


    self.Stats = {
        {
            Id = "ATK",
            Val = {
                Value(0), Value(0)
            }
        },
    }

    local statsList = {
        "MAGIC", "MANA", "HP", "SHIELD", "SPD", "JMP",
        "CRIT CHANCE", "CRIT DMG", "DODGE CHANCE", "BURN CHANCE"
    }
    for _, stat: string in statsList do
        table.insert(self.Stats, {
            Id = stat,
            Val = Value(0),
        })
    end


    local function _setVal(stat: string, val: number)
        for _, s in self.Stats do
            if s.Id == stat then
                s.Val:set(val)
                break
            end
        end
    end


    --// track points
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-PerkPoints"] = function(val: number)
            self.PerkPoints:set(val)
        end,
        ["Attr-STRPoints"] = function(val: number)
            self.Points.STR:set(val)
        end,
        ["Attr-DEXPoints"] = function(val: number)
            self.Points.DEX:set(val)
        end,
        ["Attr-INTPoints"] = function(val: number)
            self.Points.INT:set(val)
        end,
        ["Attr-VITPoints"] = function(val: number)
            self.Points.VIT:set(val)
        end
    }))


    --// track class
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Class"] = function(class: string)
            self.Class:set(class)
        end
    }))


    --// track level and exp
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Level"] = function(level: number)
            self.Level:set(level)
        end,
        ["Attr-EXP"] = function(exp: number)
            self.EXP:set(exp)
        end
    }))


    --// track stats
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-MinDMG"] = function(val: number)
            for _, s in self.Stats do
                if s.Id == "ATK" then
                    s.Val[1]:set(val)
                    break
                end
            end
        end,
        ["Attr-MaxDMG"] = function(val: number)
            for _, s in self.Stats do
                if s.Id == "ATK" then
                    s.Val[2]:set(val)
                    break
                end
            end
        end,
        ["Attr-Magic"] = function(val: number)
            _setVal("MAGIC", val)
        end,
        ["Attr-MaxMana"] = function(val: number)
            _setVal("MANA", val)
        end,
        ["Attr-MaxShield"] = function(val: number)
            _setVal("SHIELD", val)
        end,
        ["Attr-CriChance"] = function(val: number)
            _setVal("CRIT CHANCE", val)
        end,
        ["Attr-CriDMG"] = function(val: number)
            _setVal("CRIT DMG", val)
        end,
        ["Attr-DodgeChance"] = function(val: number)
            _setVal("DODGE CHANCE", val)
        end,
        ["Attr-BurnChance"] = function(val: number)
            _setVal("BURN CHANCE", val)
        end
    }))



    table.insert(scope, HarukaLib:Hydrate(self.char.Humanoid, {
        ["Prop-MaxHealth"] = function(val: number)
            _setVal("HP", val)
        end,
        ["Prop-WalkSpeed"] = function(speed: number)
            _setVal("SPD", speed)
        end,
        ["Prop-JumpPower"] = function(jump: number)
            _setVal("JMP", jump)
        end,
    }))


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "CharSelfView")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Char",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end
