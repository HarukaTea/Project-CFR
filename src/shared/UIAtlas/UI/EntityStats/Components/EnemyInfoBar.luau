--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Enemy: Model,
})
    if not ClientLib.IsCharValid(props.Enemy) then return nil end
    if not EntityBook[props.Enemy.Name] then return nil end


    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local level = Value(1)
    local HP = Value(100)


    table.insert(scope, HarukaLib:Hydrate((props.Enemy :: any).Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            HP:set(newHP)
        end,
    }))
    table.insert(scope, HarukaLib:Hydrate(props.Enemy, {
        ["Attr-Level"] = function(val: number)
            level:set(val)
        end
    }))


    return Components.BillboardGui(scope, {
        Name = "EnemyInfoBar_"..props.Enemy.Name,
        Adornee = props.Enemy.PrimaryPart,
        MaxDistance = 115,
        Size = UDim2.fromScale(8, 2),
        StudsOffset = Vector3.yAxis * 6,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),


        [Children] = {
            Components.Frame(scope, {
                Name = "TitleSection",
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0.05, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    Components.PaddingFrame(scope, "ZZZ"),

                    Components.IconImageLabel(scope, {
                        Size = UDim2.fromScale(1.5, 1.5),
                        LayoutOrder = 3,

                        Image = EntityBook[props.Enemy.Name].Icon,
                    }),

                    Components.TextLabel(scope, {
                        Name = "EnemyLevel",
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(0.4, 0.8),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Components.WHITE_COLOR,
                        TextColor3 = Components.BLACK_COLOR,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(level)}`
                        end),

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0.05, 0),
                                PaddingRight = UDim.new(0.05, 0)
                            })
                        }
                    }),
                }
            }),
        }
    })
end