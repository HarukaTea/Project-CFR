
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children


return function (scope: Fusion.Scope<any>, props: {
    Enemy: Model,
})

    if not ClientLib.IsCharValid(props.Enemy) then return nil end
    if not EntityBook[props.Enemy.Name] then return nil end


    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local HP = Value(100)


    table.insert(scope, HarukaLib:Hydrate(props.Enemy.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            HP:set(newHP)
        end,
    }))



    local billboardGui = Components.BillboardGui(scope, {
        Name = "EnemyHPBar_"..props.Enemy.Name,
        Adornee = props.Enemy.PrimaryPart,
        MaxDistance = 115,
        Size = UDim2.fromScale(25.5, 6),
        StudsOffset = Vector3.yAxis * 12,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),


        [Children] = {
            Components.TextLabel(scope, {
                Name = "HP",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.6),
                Size = UDim2.fromScale(1, 0.5),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(HP)
                end),

                [Children] = {
                    Components.TextUIStroke(scope, {
                        Thickness = 2
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "EffectList",
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.fromScale(1, 0.3),
                Position = UDim2.fromScale(0.5, 0.3),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.01, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    })
                }
            })
        }
    })


    --// track effect list
    ClientLib.TrackEffectListToUI({
        Target = props.Enemy,
        Scope = scope,
        GuiContainer = billboardGui.EffectList
    })



    return billboardGui
end