--!nocheck

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local CastingTimeBar = require(script.Parent.Components.CastTimeBar)

local wait = task.wait

return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope
    local plr = self.plr :: Player


    plr:SetAttribute("CurrentUIGroup", "None")


    self.ServerLocation = Value("Unknown")

    self.HP = Value(100)
    self.MaxHP = Value(100)

    self.Shield = Value(0)
    self.MaxShield = Value(10)

    self.Mana = Value(50)
    self.MaxMana = Value(50)

    self.EXP = Value(50)
    self.MaxEXP = Value(100)

    self.Level = Value(1)
    self.Class = Value("Burst")
    self.ClassUltProgress = Value(0)
    self.MaxClassUltProgress = Value(100)

    self.MinDMG = Value(0)
    self.MaxDMG = Value(0)
    self.Magic = Value(0)

    self.IsInCombat = Value(false)

    self.ClassVals = {}
    self.ClassVals2 = {}
    for class, _ in ClassBook do
        self.ClassVals[class] = Value(0)
    end
    for class, _ in ClassBook do
        self.ClassVals2[class] = Value(0)
    end

    self.TargetingList = FusionComponents.useFolder(scope, self.char:WaitForChild("TargetingList"))
    self.TargetingEnemy = FusionComponents.useValue(scope, self.char:WaitForChild("TargetingEnemy"))

    self.IsHPRecovering = Value(false)
    self.IsShieldRepairing = Value(false)


    self.IsMenuShown = Value(false)
    self.IsBackpackShown = Value(false)
    self.IsUIShown = Value(true)

    self.PassiveBGAbsContentSize = Value(Vector2.zero)

    self.AreaIn = Value("None")

    self.CurrentHoveringPassive = Value("")


    --// track server
    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-ServerLocation"] = function(newLocation: string)
            self.ServerLocation:set(newLocation)
        end
    }))

    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))


    --// track skills
    local skillCDContainer = Instance.new("Folder")
    skillCDContainer.Name = "HARUKA_SkillCDs"
    skillCDContainer.Parent = game:GetService("ServerStorage")
    table.insert(scope, skillCDContainer)

    --// track active skills
    self.ActiveList = {
        {
            --Cooldown = Value("0"),
            --CDRotation = Value(0),
        }, {}, {}
    }
    for index, slot in self.ActiveList do
        local cdSymbol = Instance.new("NumberValue")
        cdSymbol.Name = "CDSymbol_"..tostring(index)
        cdSymbol.Parent = skillCDContainer

        local realCD = Instance.new("NumberValue")
        realCD.Name = "RealCD"
        realCD.Parent = cdSymbol

        slot.Id = "Active"..tostring(index)
        slot.CDSymbol = cdSymbol
        slot.Cooldown = Value("0")
        slot.CDRotation = Value(0)

        slot.ItemId = Value("None")
        slot.ItemUniqueId = Value("None")

        slot.CastCD = false
    end
    local order = 1
    for i = #self.ActiveList, 1, -1 do
        local slot = self.ActiveList[i]

        slot.DisplayOrder = order
        slot.KeyDisplay = tostring(i)

        order += 1
    end

    self.CharAbilityList = {
        {
            Id = "Ability1",
            Cooldown = Value("0"),
            CDRotation = Value(0),

            CastCD = false,
            DisplayOrder = 1,
            KeyDisplay = "R"
        }
    }
    for index, slot in self.CharAbilityList do
        local cdSymbol = Instance.new("NumberValue")
        cdSymbol.Name = "AbilityCDSymbol_"..tostring(index)
        cdSymbol.Parent = skillCDContainer

        local realCD = Instance.new("NumberValue")
        realCD.Name = "RealCD"
        realCD.Parent = cdSymbol

        slot.CDSymbol = cdSymbol
    end


    --// track passive skills
    self.PassiveList = {
        {}, {}, {}
    }
    for index, slot in self.PassiveList do
        slot.Id = "Passive"..tostring(index)

        slot.ItemId = Value("None")
        slot.ItemUniqueId = Value("None")
    end


    self.EquippingItems = FusionComponents.useFolder(scope, self.plr.EquippingItems)

    local function _handleItemEquip()
        for _, slotInfo: table in self.ActiveList do
            slotInfo.ItemId:set("None")
            slotInfo.ItemUniqueId:set("None")
        end
        for _, slotInfo: table in self.PassiveList do
            slotInfo.ItemId:set("None")
            slotInfo.ItemUniqueId:set("None")
        end

        for _, equipping: StringValue in Fusion.peek(self.EquippingItems) do
            local itemInfo = ItemLib:GetItemInfo(equipping.Value)
            if itemInfo == nil then continue end


            local index = equipping.Name
            local uniqueId = equipping:GetAttribute("HarukaUniqueId") :: string


            if string.find(index, "Active") then
                local slotInfo = self.ActiveList[tonumber(string.sub(index, 7))]

                slotInfo.ItemId:set(itemInfo.ItemId)
                slotInfo.ItemUniqueId:set(uniqueId)

            elseif string.find(index, "Accessory") then
                local slotInfo = self.PassiveList[tonumber(string.sub(index, 10))]

                slotInfo.ItemId:set(itemInfo.ItemId)
                slotInfo.ItemUniqueId:set(uniqueId)
            end
        end
    end
    Fusion.Observer(scope, self.EquippingItems):onBind(_handleItemEquip)



    --// track input
    self.RequestToCastClassUlt = Signal.new()
    self.RequestToCastItem = Signal.new()
    self.RequestToDash = Signal.new()

    table.insert(scope, self.RequestToCastClassUlt)
    table.insert(scope, self.RequestToCastItem)
    table.insert(scope, self.RequestToDash)


    local function _normalCancelCD(info: table)
        task.delay(0.15, function()
            info.CastCD = false
        end)
    end
    self.RequestToCastItem:Connect(function(slotId: number)
        local info = self.ActiveList[slotId]

        if info == nil then return end
        if info.CastCD then return end

        info.CastCD = true

        if not info then
            warn("Invalid item properties when casting item")
            _normalCancelCD(info)
            return
        end

        slotId = "Active"..slotId

        local equippingItems = plr.EquippingItems :: Folder
        if equippingItems:FindFirstChild(slotId) then
            local itemSymbol = equippingItems[slotId] :: StringValue

            local itemInfo = ItemLib:GetItemInfo(itemSymbol.Value)
            if not itemInfo then
                Bindables.CreateNotify:Fire("[Error] Invalid Item Id")
                _normalCancelCD(info)
                return
            end

            local castWhiteList = { "Active", "Consumable" }
            if not table.find(castWhiteList, itemInfo.Type) then
                Bindables.CreateNotify:Fire("[Error] Invalid Item Type")
                _normalCancelCD(info)
                return
            end

            local inCDCheck = false
            for _, cdSymbol: BoolValue in CollectionService:GetTagged("ItemCDSymbol") do
                if cdSymbol.Name == plr.Name and cdSymbol:GetAttribute("ItemId") == itemInfo.ItemId then
                    inCDCheck = true
                    break
                end
            end
            if inCDCheck then
                Bindables.CreateNotify:Fire("The item is still on cooldown!")
                _normalCancelCD(info)
                return
            end


            Events.RequestToCastItem_Request.Fire({
                SlotId = slotId
            })
        else
            _normalCancelCD(info)
        end
    end)
    self.RequestToCastClassUlt:Connect(function()
        if self.ClassActiveCastCD then
            return
        end
        self.ClassActiveCastCD = true


        task.delay(1, function()
            self.ClassActiveCastCD = false
        end)
        Events.RequestToCastClassUlt.Fire()
    end)



    local function _createCooldownAnim(cdTime: nuamber, info: table)
        local tween = TweenInfo.new(cdTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

        local cdSymbol = info.CDSymbol :: NumberValue
        cdSymbol.Value = 1
        local realCDSymbol = cdSymbol.RealCD :: NumberValue
        realCDSymbol.Value = cdTime

        HarukaLib:CreateTween(cdSymbol, tween, { Value = 0 }):Play()
        HarukaLib:CreateTween(realCDSymbol, tween, { Value = 0 }):Play()

        Promise.delay(cdTime):andThen(function()
            info.CastCD = false

            Bindables.CDEndTimeReached:Fire(info.Id)
            tween = nil
        end):catch(function() end)
    end
    table.insert(scope, Events.RequestToCastItem_Response.On(function(data)
        local slotId = data.SlotId
        local cdTime = data.CooldownTime

        slotId = string.sub(slotId, 7)
        if slotId == nil then return end
        if slotId == "" then return end

        slotId = tonumber(slotId)

        local info = self.ActiveList[slotId]
        if not info then return end


        if cdTime <= 0 then
            _normalCancelCD(info)
            Bindables.RequestToResetItemCD:Fire(slotId)
            return
        end


        _createCooldownAnim(cdTime, info)
    end))
    self.RequestToDash:Connect(function()
        local info = self.CharAbilityList[1]

        if info.CastCD then
            return
        end
        info.CastCD = true

        _createCooldownAnim(5, info)


        local linearVelo = Instance.new("LinearVelocity")
        linearVelo.Name = "Dash"
        linearVelo.Attachment0 = self.char.PrimaryPart.AlignMoverAttachment
        linearVelo.ForceLimitsEnabled = false
        linearVelo.VectorVelocity = self.char.PrimaryPart.CFrame.LookVector * 100 + Vector3.yAxis * 6
        linearVelo.Parent = self.char.PrimaryPart
        Debris:AddItem(linearVelo, 0.12)


        for _, part: BasePart in self.char:GetChildren() do
            if HarukaLib:IsBasePartType(part) then
                local clone = part:Clone()
                clone.Transparency = 0.2
                clone.Anchored = true
                clone.Color = Color3.fromRGB(255, 255, 255)
                clone.Material = Enum.Material.Neon
                clone.CFrame = part.CFrame
                clone.Parent = workspace.Terrain

                clone:ClearAllChildren()

                Debris:AddItem(clone, 0.5)

                HarukaLib:CreateTween(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                    Transparency = 1
                }):Play()
            end
        end
    end)



    local keyCodes = {
        B = "Backpack",
        C = "CharSelfView",
        Z = "PerkTree",
        N = "Settings",
        X = "Guild",
        V = "Store"
    }
    table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj: InputObject, gpe: boolean)
        if gpe then return end

        if keyCodes[inputObj.KeyCode.Name] then
            local curUIGroup = self.plr:GetAttribute("CurrentUIGroup") :: string

            if curUIGroup ~= "None" and curUIGroup ~= keyCodes[inputObj.KeyCode.Name] then return end

            self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and keyCodes[inputObj.KeyCode.Name] or "None")

        elseif inputObj.KeyCode == Enum.KeyCode.Q then
            self.RequestToCastClassUlt:Fire()

        elseif inputObj.KeyCode == Enum.KeyCode.One then
            self.RequestToCastItem:Fire(1)

        elseif inputObj.KeyCode == Enum.KeyCode.Two then
            self.RequestToCastItem:Fire(2)

        elseif inputObj.KeyCode == Enum.KeyCode.Three then
            self.RequestToCastItem:Fire(3)

        elseif inputObj.KeyCode == Enum.KeyCode.R then
            self.RequestToDash:Fire()
        end
    end))


    --// track class
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Class"] = function(val: string)
            self.Class:set(val)
        end
    }))
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-ClassUltProgress"] = function(val: number)
            self.ClassUltProgress:set(val)
        end,
        ["Attr-MaxClassUltProgress"] = function(val: number)
            self.MaxClassUltProgress:set(val)
        end
    }))


    --// track stat
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-MinDMG"] = function(val: number)
            self.MinDMG:set(val)
        end,
        ["Attr-MaxDMG"] = function(val: number)
            self.MaxDMG:set(val)
        end,
        ["Attr-Magic"] = function(val: number)
            self.Magic:set(val)
        end,
        ["Attr-Shield"] = function(val: number)
            self.Shield:set(val)
        end,
        ["Attr-MaxShield"] = function(val: number)
            self.MaxShield:set(val)
        end,
        ["Attr-IsHPRecovering"] = function(val: boolean)
            self.IsHPRecovering:set(val)
        end,
        ["Attr-IsShieldRepairing"] = function(val: boolean)
            self.IsShieldRepairing:set(val)
        end
    }))


    --// track combat
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-IsInCombat"] = function(val: boolean)
            self.IsInCombat:set(val)
        end,

        ["Attr-ChainCombo"] = function(val: number)
            self.ClassVals.Chain:set(val)
        end,
        ["Attr-BurstArrow"] = function(val: number)
            self.ClassVals.Burst:set(val)
        end,
        ["Attr-FlowHeat"] = function(val: number)
            self.ClassVals.Flow:set(val)
        end,
    }))

    --// track exp
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-EXP"] = function(val: number)
            self.EXP:set(val)
        end,
        ["Attr-MaxEXP"] = function(val: number)
            self.MaxEXP:set(val)
        end,
    }))


    --// track hp
    table.insert(scope, HarukaLib:Hydrate(self.char.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            self.HP:set(newHP)
        end,
        ["Prop-MaxHealth"] = function(newMaxHP: number)
            self.MaxHP:set(newMaxHP)
        end
    }))

    --// track mana
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-Mana"] = function(val: number)
            self.Mana:set(val)
        end,
        ["Attr-MaxMana"] = function(val: number)
            self.MaxMana:set(val)
        end,
    }))



    --// track cd
    local function _updateCD(targetList: string, val: number, index: number)
        local formattedVal = if val >= 10 then string.format("%.0f", val) else string.format("%.1f", val)

        self[targetList][index].Cooldown:set(formattedVal)
    end
    local function _updateRotation(targetList: string, val: number, index: number)
        self[targetList][index].CDRotation:set(val)
    end
    for index, slot in self.ActiveList do
        table.insert(scope, HarukaLib:Hydrate(slot.CDSymbol, {
            ["Prop-Value"] = function(val: number)
                _updateRotation("ActiveList", val, index)
            end
        }))
        table.insert(scope, HarukaLib:Hydrate(slot.CDSymbol.RealCD, {
            ["Prop-Value"] = function(val: number)
                _updateCD("ActiveList", val, index)
            end
        }))
    end
    for index, slot in self.CharAbilityList do
        table.insert(scope, HarukaLib:Hydrate(slot.CDSymbol, {
            ["Prop-Value"] = function(val: number)
                _updateRotation("CharAbilityList", val, index)
            end
        }))
        table.insert(scope, HarukaLib:Hydrate(slot.CDSymbol.RealCD, {
            ["Prop-Value"] = function(val: number)
                _updateCD("CharAbilityList", val, index)
            end
        }))
    end


    --// track cast cd
    table.insert(scope, Events.OpenCastTimeBar.On(function(data)
        local castingTimeBar = CastingTimeBar(scope, {
            Time = data.Duration
        })
        castingTimeBar.Parent = self.UI.Bottom.CastTimeBars

        Debris:AddItem(castingTimeBar, data.Duration + 0.2)


        wait(data.Duration)
        HarukaLib:UITween(castingTimeBar, "Out")
    end))
end
