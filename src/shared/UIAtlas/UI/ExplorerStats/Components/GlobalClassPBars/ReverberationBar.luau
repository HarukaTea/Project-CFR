--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {

})

    local targetingContainer = Instance.new("Folder")
    targetingContainer.Name = "TargetingContainer_ReverberationBar"
    targetingContainer.Parent = game:GetService("ServerStorage")
    table.insert(scope, targetingContainer)


    local targeting = FusionComponents.useFolder(scope, targetingContainer)


    table.insert(scope, Events.CLASS_RollNewResonateNumForEnemy.On(function(data)
        local symbol = Instance.new("ObjectValue")
        symbol.Name = "ResonateNum"
        symbol.Value = data.Entity

        symbol:SetAttribute("ResonateNum", data.ResonateNum)

        symbol.Parent = targetingContainer
    end))


    local folder = nil
    local barDiv = nil

    folder = Fusion.New(scope, "Folder")({
        Name = "ResonateNums",

        [Children] = {
            Fusion.ForValues(scope, targeting, function(_, scope: Fusion.Scope, target: ObjectValue)
                local HP = Fusion.Value(scope, 100)

                if not ClientLib:IsCharValid(target.Value) then return nil end

                table.insert(scope, HarukaLib:Hydrate(target.Value.Humanoid, {
                    ["Prop-Health"] = function(newHP: number)
                        HP:set(newHP)
                    end,
                }))

                return Components.BillboardGui(scope, {
                    Name = "ResonateNum_"..target.Name,
                    MaxDistance = 125,
                    Size = UDim2.fromScale(6, 6),
                    StudsOffset = Vector3.yAxis * 17,
                    Adornee = target.Value,

                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(HP) > 0
                    end),


                    [Children] = {
                        Components.IconImageLabel(scope, {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromScale(0.75, 0.75),
                            Image = "rbxassetid://121488236607929"
                        }),

                        IconShadeTex(scope, {}),

                        Components.TextLabel(scope, {
                            Name = "Num",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, -0.3),
                            ZIndex = 2,
                            Size = UDim2.fromScale(0.75, 0.75),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            FontFace = Font.fromName("Roboto", Enum.FontWeight.Bold),
                            Text = target:GetAttribute("ResonateNum") or "0",

                            [Children] = {
                                Components.TextUIStroke(scope, { Thickness = 2.3 })
                            }
                        })
                    }
                })
            end)
        }
    })
    barDiv = Components.Frame(scope, {
        Name = "ReverberationStyle",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.92, 1),


        [Children] = {
            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0.015, 0)
            })
        }
    })


    return { folder, barDiv }
end