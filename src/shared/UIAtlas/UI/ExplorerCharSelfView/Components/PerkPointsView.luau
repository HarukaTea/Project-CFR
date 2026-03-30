
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Class: Fusion.Value<string>,
    Level: Fusion.Value<number>,
    EXP: Fusion.Value<number>,
    PerkPoints: Fusion.Value<number>,

    PointList: { [string]: Fusion.Value<number> },
})

    local inputTextbox = Fusion.Hydrate(scope, Components:RefUI("AmountInput_PPEB1_1", true))({})
    local amount = ClientLib:TrackInputTextbox({
        Scope = scope,
        TextBox = inputTextbox,

        Callback = function() end
    })

    return Fusion.Hydrate(scope, Components:RefUI("CharStatsView_ECSV1_1", false, true, {
        "HorizonLine"
    }))({
        [Children] = {
            Components.PaddingFrame(scope, "AAA"),

            Fusion.Hydrate(scope, Components:RefUI("ExplorationLevel_ECSV1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Class_ExpLvl1_1", true))({
                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ClassBigFade_ExpLvl1_1", true))({
                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(props.Class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("PlayerName_ExpLvl1_1", true))({
                        Text = HarukaLib:RichText(`{Players.LocalPlayer.DisplayName}  <gray>(#{Players.LocalPlayer.UserId})</font>`)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Level_ExpLvl1_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(props.Level)}`
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("EXP_ExpLvl1_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local maxEXP = FormulaBook.PlayerLevelCurveCal({
                                Level = use(props.Level)
                            })
                            return `{use(props.EXP)}  /  {maxEXP}`
                        end)
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("PerkPointInfo_ECSV1_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Icon_PerkPInfoExp1_1", true))({}),

                    Fusion.Hydrate(scope, Components:RefUI("PointLeft_PerkPInfoExp1_1"))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(props.PerkPoints)
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Buttons_PerkPInfoExp1_1", false, true))({
                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("Reset_PPEB1_1", true))({
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    Events.ResetStatPoint_C.Fire()
                                end
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("IncreasePoint_PPEB1_1", true))({
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    local curAmount = Fusion.peek(amount)
                                    local nextAmount = curAmount + 1
                                    nextAmount = math.clamp(nextAmount, 1, 99)

                                    amount:set(nextAmount)
                                end
                            }),

                            Fusion.Hydrate(scope, Components:RefUI("DecreasePoint_PPEB1_1", true))({
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    local curAmount = Fusion.peek(amount)
                                    local nextAmount = curAmount - 1
                                    nextAmount = math.clamp(nextAmount, 1, 99)

                                    amount:set(nextAmount)
                                end,
                            }),

                            inputTextbox
                        }
                    }),
                }
            }),

            Components.ScrollingFrame(scope, {
                Name = "ExplorationPoints",
                Size = UDim2.fromScale(0.9, 0.437),
                ScrollingDirection = Enum.ScrollingDirection.Y,
                ScrollBarThickness = 5,
                LayoutOrder = 4,

                [Children] = {
                    Fusion.ForPairs(scope, { "STR", "INT", "VIT", "DEX" }, function(
                        _,
                        scope: Fusion.Scope,
                        index: number,
                        point: string
                    )
                        local SYMBOL_ICONS = {
                            STR = "rbxassetid://134445989246357",
                            DEX = "rbxassetid://123194426967050",
                            INT = "rbxassetid://81020560446846",
                            VIT = "rbxassetid://106075217220023",
                            DEF = "rbxassetid://139549262926539"
                        }

                        return index, Fusion.Hydrate(scope, Components:RefUI("PointTemplate_EPV1_1", false, true))({
                            Name = point,
                            LayoutOrder = index + 1,

                            [Children] = {
                                Fusion.Hydrate(scope, Components:RefUI("Icon_EPV1_1", true))({
                                    Image = SYMBOL_ICONS[point]
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("Title_EPV1_1", true))({
                                    Text = point
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("Stat_EPV1_1", true))({
                                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PointList[point])
                                    end),
                                    Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        local perkPoints, pointValue = use(props.PerkPoints) :: number, use(props.PointList[point]) :: number

                                        if perkPoints > 0 and pointValue <= 0 then
                                            return UDim2.fromScale(0.825, 0)
                                        elseif perkPoints > 0 and pointValue > 0 then
                                            return UDim2.fromScale(0.725, 0)
                                        elseif perkPoints <= 0 and pointValue > 0 then
                                            return UDim2.fromScale(0.725, 0)
                                        elseif perkPoints <= 0 and pointValue <= 0 then
                                            return UDim2.fromScale(0.925, 0)
                                        end
                                        return UDim2.fromScale(0.925, 0)
                                    end),
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("Increase_EPV1_1", true))({
                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PerkPoints) > 0
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        SoundService.SFXs.Ding:Play()

                                        Events.AddStatPoint_C.Fire({
                                            PointId = point,
                                            PointAmount = Fusion.peek(amount)
                                        })
                                    end
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("Decrease_EPV1_1", true))({
                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(props.PointList[point]) > 0
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        SoundService.SFXs.Ding:Play()

                                        Events.AddStatPoint_C.Fire({
                                            PointId = point,
                                            PointAmount = -Fusion.peek(amount)
                                        })
                                    end,
                                }),
                            }
                        })
                    end)
                }
            }, {
                Padding = UDim.new(0, 12),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
        }
    })
end