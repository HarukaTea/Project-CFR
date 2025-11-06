
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local wait = task.wait


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,
    UI: ScreenGui,

    ServerLocation: Fusion.Value<string>,

    HP: Fusion.Value<number>,
    MaxHP: Fusion.Value<number>,

    EXP: Fusion.Value<number>,
    MaxEXP: Fusion.Value<number>,

    Shield: Fusion.Value<number>,
    MaxShield: Fusion.Value<number>,

    Level: Fusion.Value<number>,
    Class: Fusion.Value<string>,
    ClassUltProgress: Fusion.Value<number>,
    MaxClassUltProgress: Fusion.Value<number>,

    MinDMG: Fusion.Value<number>,
    MaxDMG: Fusion.Value<number>,
    Magic: Fusion.Value<number>,

    IsInCombat: Fusion.Value<boolean>,

    TargetingList: Fusion.Value<{ ObjectValue }>,
    TargetingEnemy: Fusion.Value<Model?>,

    IsHPRecovering: Fusion.Value<boolean>,
    IsShieldRepairing: Fusion.Value<boolean>,

    IsMenuShown: Fusion.Value<boolean>,
    IsUIShown: Fusion.Value<boolean>,
    IsUIShown2: Fusion.Value<boolean>,

    PassiveBGAbsContentSize: Fusion.Value<Vector2>,

    CurrentHoveringPassive: Fusion.Value<string>,

    DungeonId: Fusion.Value<string?>,
    DungeonStarted: Fusion.Value<boolean>,
    DungeonFinished: Fusion.Value<boolean>,
    DungeonLeftTime: Fusion.Value<number>,
    DungeonEndActionsClicked: Fusion.Value<boolean>,

    MenuSelectionShown: Fusion.Value<boolean>,

    Items: Fusion.Value<{ IntConstrainedValue }>,
    EquippingItems: Fusion.Value<{ StringValue }>,


    ActiveList: {
        {
            Id: string,
            CDSymbol: NumberValue,
            Cooldown: Fusion.Value<string>,
            CDRotation: Fusion.Value<number>,

            ItemId: Fusion.Value<string>,
            ItemUniqueId: Fusion.Value<string>,

            CastCD: boolean,
            DisplayOrder: number,
            KeyDisplay: string
        }
    }?,
    PassiveList: {
        {
            Id: string,
            ItemId: Fusion.Value<string>,
            ItemUniqueId: Fusion.Value<string>,
        }
    }?,
    CharAbilityList: {
        {
            Id: string,
            Cooldown: Fusion.Value<string>,
            CDRotation: Fusion.Value<number>,

            CastCD: boolean,
            DisplayOrder: number,
            KeyDisplay: string,

            CDSymbol: NumberValue,
        }
    }?,


    RequestToCastClassUlt: Signal.SignalClass,
    RequestToCastItem: Signal.SignalClass,
    RequestToDash: Signal.SignalClass,

    ClassActiveCastCD: boolean,
}




return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope<any>
    local plr = self.plr :: Player


    plr:SetAttribute("CurrentUIGroup", "None")


    self.ServerLocation = Value("Unknown")

    self.HP = Value(100)
    self.MaxHP = Value(100)

    self.Shield = Value(0)
    self.MaxShield = Value(10)

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

    local targeting = FusionComponents.useFolder(scope, self.char:WaitForChild("TargetingList"))

    self.TargetingList = targeting :: Fusion.Value<{ ObjectValue }>
    self.TargetingEnemy = FusionComponents.useValue(scope, self.char:WaitForChild("TargetingEnemy"))

    self.IsHPRecovering = Value(false)
    self.IsShieldRepairing = Value(false)


    self.IsMenuShown = Value(false)
    self.IsUIShown = Value(true)

    self.PassiveBGAbsContentSize = Value(Vector2.zero)

    self.CurrentHoveringPassive = Value("")

    self.DungeonId = Fusion.Value(self.scope, nil)
    self.DungeonStarted = Value(false)
    self.DungeonFinished = Value(false)
    self.DungeonLeftTime = Value(0)
    self.DungeonEndActionsClicked = Value(false)

    self.MenuSelectionShown = Value(false)


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

    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
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
    local list = self.ActiveList
    for index, slot in list do
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
    for i = #list, 1, -1 do
        local slot = list[i]

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
    local list3 = self.CharAbilityList
    for index, slot in list3 do
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
    local list2 = self.PassiveList
    for index, slot in list2 do
        slot.Id = "Passive"..tostring(index)

        slot.ItemId = Value("None")
        slot.ItemUniqueId = Value("None")
    end


    local equipping = FusionComponents.useFolder(scope, self.plr:WaitForChild("EquippingItems", 999))
    self.EquippingItems = equipping :: Fusion.Value<{ StringValue }>

    local function _handleItemEquip()
        for _, slotInfo in list do
            slotInfo.ItemId:set("None")
            slotInfo.ItemUniqueId:set("None")
        end
        for _, slotInfo in list2 do
            slotInfo.ItemId:set("None")
            slotInfo.ItemUniqueId:set("None")
        end

        for _, equipping: StringValue in Fusion.peek(self.EquippingItems) do
            local itemInfo = ItemBook:GetItemInfo(equipping.Value)
            if itemInfo == nil then continue end


            local index = equipping.Name
            local uniqueId = equipping:GetAttribute("HarukaUniqueId") :: string


            if string.find(index, "Active") then
                local slotInfo = list[tonumber(string.sub(index, 7))]

                slotInfo.ItemId:set(itemInfo.ItemId)
                slotInfo.ItemUniqueId:set(uniqueId)

            elseif string.find(index, "Accessory") then
                local slotInfo = list2[tonumber(string.sub(index, 10))]

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


    local function _normalCancelCD(info: { [string]: any })
        task.delay(0.15, function()
            info.CastCD = false
        end)
    end
    self.RequestToCastItem:Connect(function(slotId: number)
        local info = list[slotId]

        if info == nil then return end
        if info.CastCD then return end

        info.CastCD = true

        if not info then
            warn("Invalid item properties when casting item")
            _normalCancelCD(info)
            return
        end

        local slotIdStr: string = tostring(slotId)
        slotIdStr = "Active"..slotIdStr

        local equippingItems = plr.EquippingItems :: Folder
        if equippingItems:FindFirstChild(slotIdStr) then
            local itemSymbol = equippingItems[slotIdStr] :: StringValue

            local itemInfo = ItemBook:GetItemInfo(itemSymbol.Value)
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
                if cdSymbol.Name == plr.UserId and cdSymbol:GetAttribute("ItemId") == itemInfo.ItemId then
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
                SlotId = slotIdStr
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



    local function _createCooldownAnim(cdTime: number, info: { [string]: any })
        local tween = TweenInfo.new(cdTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

        local cdSymbol = info.CDSymbol :: NumberValue
        cdSymbol.Value = 1
        local realCDSymbol = cdSymbol.RealCD :: NumberValue
        realCDSymbol.Value = cdTime

        HarukaLib:CreateTween(cdSymbol, tween, { Value = 0 }):Play()
        HarukaLib:CreateTween(realCDSymbol, tween, { Value = 0 }):Play()

        task.delay(cdTime, function()
            info.CastCD = false

            Bindables.CDEndTimeReached:Fire(info.Id)
            tween = nil
        end)
    end
    table.insert(scope, Events.RequestToCastItem_Response.On(function(data)
        local slotId = data.SlotId
        local cdTime = data.CooldownTime

        slotId = string.sub(slotId, 7)
        if slotId == nil then return end
        if slotId == "" then return end

        slotId = tonumber(slotId)

        local info = list[slotId]
        if not info then return end


        if cdTime <= 0 then
            _createCooldownAnim(0, info)
            return
        end


        _createCooldownAnim(cdTime, info)
    end))
    self.RequestToDash:Connect(function()
        local info = list3[1]

        local char = self.char :: Model

        if info.CastCD then
            return
        end
        if char:GetAttribute("IsChatting") then return end
        info.CastCD = true

        _createCooldownAnim(5, info)


        local direction = char.Humanoid.MoveDirection :: Vector3
        if direction.Magnitude <= 0 then
            direction = char.PrimaryPart.CFrame.LookVector
        end


        local linearVelo = Instance.new("LinearVelocity")
        linearVelo.Name = "Dash"
        linearVelo.Attachment0 = char.PrimaryPart.AlignMoverAttachment
        linearVelo.RelativeTo = Enum.ActuatorRelativeTo.World
        linearVelo.MaxForce = 1500 * char.PrimaryPart.AssemblyMass
        linearVelo.VectorVelocity = direction * 100
        linearVelo.Parent = char.PrimaryPart
        Debris:AddItem(linearVelo, 0.2)


        for _, part: BasePart in char:GetChildren() do
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

        Bindables.PlayAnimation:Fire("Dash")
    end)



    local uiButtons = {
        "Backpack", "CharSelfView", "Settings",
    }
    table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj: InputObject, gpe: boolean)
        if gpe then return end

        local isGamepad = string.find(inputObj.UserInputType.Name, "Gamepad")
        local isKeyboard = string.find(inputObj.UserInputType.Name, "Keyboard")
        if not isGamepad and not isKeyboard then return end

        local isUIButtonCheck = false
        local isWhichUIButton = nil
        for _, uiButton: string in uiButtons do
            if KeybindsBook.PC[uiButton] == inputObj.KeyCode then
                isUIButtonCheck = true
                isWhichUIButton = uiButton
                break
            end
        end

        if isWhichUIButton and isUIButtonCheck then
            local curUIGroup = self.plr:GetAttribute("CurrentUIGroup") :: string

            if curUIGroup ~= "None" and curUIGroup ~= isWhichUIButton then return end

            self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and isWhichUIButton or "None")
        end
        if inputObj.KeyCode == KeybindsBook.PC.ClassUlt or inputObj.KeyCode == KeybindsBook.Console.ClassUlt then
            self.RequestToCastClassUlt:Fire()

        elseif inputObj.KeyCode == KeybindsBook.PC.Active1 or inputObj.KeyCode == KeybindsBook.Console.Active1 then
            self.RequestToCastItem:Fire(1)

        elseif inputObj.KeyCode == KeybindsBook.PC.Active2 or inputObj.KeyCode == KeybindsBook.Console.Active2 then
            self.RequestToCastItem:Fire(2)

        elseif inputObj.KeyCode == KeybindsBook.PC.Active3 or inputObj.KeyCode == KeybindsBook.Console.Active3 then
            self.RequestToCastItem:Fire(3)

        elseif inputObj.KeyCode == KeybindsBook.PC.Dash or inputObj.KeyCode == KeybindsBook.Console.Dash then
            self.RequestToDash:Fire()
        end
    end))


    --// track class
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Class"] = function(val: string)
            val = val or "Burst"

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


    --// track cd
    local function _updateCD(targetList: string, val: number, index: number)
        local formattedVal = if val >= 10 then string.format("%.0f", val) else string.format("%.1f", val)

        self[targetList][index].Cooldown:set(formattedVal)
    end
    local function _updateRotation(targetList: string, val: number, index: number)
        self[targetList][index].CDRotation:set(val)
    end
    for index, slot in list do
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
    for index, slot in list3 do
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


    --// track dungeon
    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-DungeonId"] = function(id: string)
            self.DungeonId:set(id)
        end,
        ["Attr-DungeonStarted"] = function(state: boolean)
            self.DungeonStarted:set(state)
        end,
        ["Attr-DungeonFinished"] = function(state: boolean)
            self.DungeonFinished:set(state)
        end,
        ["Attr-DungeonLeftTime"] = function(val: number)
            val = val or 0

            self.DungeonLeftTime:set(val)
        end
    }))
end