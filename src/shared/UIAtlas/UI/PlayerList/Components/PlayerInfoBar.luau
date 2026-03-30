
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Char: Model,
    Player: Player
})
    if not ClientLib:IsCharValid(props.Char) then return nil end
    if props.Player == nil then return nil end
    if props.Player.Name == Players.LocalPlayer.Name then return nil end

    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local level = Value(1)
    local HP = Value(100)
    local class = Value("Burst")
    local role = Value("")
    local title = Value("Explorer")

    table.insert(scope, HarukaLib:Hydrate(props.Char.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            HP:set(newHP)
        end,
    }))
    table.insert(scope, HarukaLib:Hydrate(props.Player, {
        ["Attr-Level"] = function(val: number)
            level:set(val)
        end,
        ["Attr-Class"] = function(val: string)
            class:set(val)
        end,
        ["Attr-Role"] = function(val: string)
            role:set(val)
        end,
        ["Attr-Title"] = function(val: string)
            title:set(val)
        end
    }))

    return { Components.BillboardGui(scope, {
        Name = "PlayerInfoBar",
        Size = UDim2.fromScale(4.8, 1.2),
        MaxDistance = 65,
        StudsOffset = Vector3.yAxis * 3,
        Adornee = props.Char.PrimaryPart,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("TitleSection_PI1_1", false, true))({
                [Children] = {
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.Hydrate(scope, Components:RefUI("Icon_PI1_2", true))({
                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("PlayerLevel_PI1_2", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(level)}`
                        end)
                    })
                }
            })
        }
    }), Components.BillboardGui(scope, {
        Name = "PlayerInfoBar",
        Size = UDim2.fromScale(12, 1),
        MaxDistance = 65,
        StudsOffset = Vector3.yAxis * 4.5,
        Adornee = props.Char.PrimaryPart,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("DisplayName_PN1_1", true))({
                Text = props.Player.DisplayName
            })
        }
    }), Components.BillboardGui(scope, {
        Name = "PlayerTitleBar",
        Size = UDim2.fromScale(12, 0.7),
        MaxDistance = 65,
        StudsOffset = Vector3.yAxis * 5.5,
        Adornee = props.Char.PrimaryPart,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Title_PT1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local titleState = use(title) :: string
                    if titleState == nil then return "" end
                    if titleState == "" then return "" end

                    return `- {titleState} -`
                end)
            })
        }
    }), Components.BillboardGui(scope, {
        Name = "PlayerRoleBar",
        Size = UDim2.fromScale(12, 0.7),
        MaxDistance = 65,
        StudsOffset = Vector3.yAxis * 6.5,
        Adornee = props.Char.PrimaryPart,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Role_PR1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local roleState = use(role) :: string
                    if roleState == nil then return "" end
                    if roleState == "" then return "" end

                    return `- {roleState} -`
                end)
            })
        }
    })
    }
end