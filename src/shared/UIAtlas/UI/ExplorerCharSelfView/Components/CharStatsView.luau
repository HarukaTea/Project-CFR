
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children



local STAT_ICONS = {
	ATK = "rbxassetid://2965862892",
	["BURN CHANCE"] = "rbxassetid://74588474308433",
	["POISON CHANCE"] = "rbxassetid://137874332790885",
	["BLEED CHANCE"] = "rbxassetid://101337562500575",
	["CRIT CHANCE"] = "rbxassetid://73146024586376",
	["CRIT DMG"] = "rbxassetid://73146024586376",
	["DODGE CHANCE"] = "rbxassetid://74429503512836",
	HP = "rbxassetid://104142948728530",
	MANA = "rbxassetid://12119869276",
	JMP = "rbxassetid://89411498131129",
	MAGIC = "rbxassetid://2965863231",
	SHIELD = "rbxassetid://139807236835811",
	SPD = "rbxassetid://128019227796527",
	LUCK = "rbxassetid://109627611842021",
    ["FREEZE CHANCE"] = "rbxassetid://79241468928508",
    ["STUN CHANCE"] = "rbxassetid://106465902273177",
    WARDING = "rbxassetid://133479347120603",
    INTENSITY = "rbxassetid://128019227796527",
}
local STAT_ICON_COLORS = {
	["CRIT CHANCE"] = Color3.fromHex('#ffeaa7'),
	HP = Color3.fromHex('#2ed573'),
	LUCK = Color3.fromHex('#2ed573'),
	SHIELD = Color3.fromHex('#ffeaa7'),
	["DODGE CHANCE"] = Color3.fromHex('#70a1ff'),
    ["FREEZE CHANCE"] = Color3.fromHex('#81ecec'),
    ["STUN CHANCE"] = Color3.fromRGB(255, 255, 127)
}


return function (scope: Fusion.Scope, props: {
    StatList: {
        {
            Id: string,
            Val: { Fusion.Value<number> }
        }
    },
    BaseStatList: {
        {
            Id: string,
            Val: { Fusion.Value<number> }
        }
    },
})
    return Components.ScrollingFrame(scope, {
        Name = "CharStatsPanel",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.03, 1),
        Size = UDim2.fromScale(0.6, 7.3),
        ScrollBarThickness = 5,
        ScrollingDirection = Enum.ScrollingDirection.Y,

        [Children] = {
            Components.PaddingFrame(scope, "AAA"),

            Fusion.ForPairs(scope, props.StatList, function(_, scope: Fusion.Scope, index: number, val)

                local correspondingBaseStat = nil
                for _, baseStatInfo in props.BaseStatList do
                    if baseStatInfo.Id == val.Id then
                        correspondingBaseStat = baseStatInfo
                        break
                    end
                end
                if not correspondingBaseStat then
                    warn("Unable to find corresponding base stat for stat: "..val.Id)
                    return index, nil
                end


                return index, Components.Frame(scope, {
                    Name = "BBB_"..val.Id,
                    BackgroundColor3 = Color3.fromRGB(),
                    BackgroundTransparency = if index % 2 == 0 then 0.1 else 0.65,
                    Size = UDim2.fromScale(1, 0.1),
                    LayoutOrder = index,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 21.063),

                        Components.TextLabel(scope, {
                            Name = "Title",
                            Position = UDim2.fromScale(0.08, 0),
                            Size = UDim2.fromScale(0.3, 1),
                            Text = val.Id,
                            TextXAlignment = Enum.TextXAlignment.Left,

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingBottom = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0, 0),
                                    PaddingRight = UDim.new(0, 0)
                                })
                            }
                        }),
                        Components.TextLabel(scope, {
                            Name = "Stat",
                            AnchorPoint = Vector2.xAxis,
                            Position = UDim2.fromScale(0.98, 0),
                            Size = UDim2.fromScale(0.3, 1),
                            TextXAlignment = Enum.TextXAlignment.Right,


                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local shouldUsePercent = false
                                if string.find(val.Id, "CRIT DMG") then
                                    shouldUsePercent = true
                                elseif string.find(val.Id, "CHANCE") then
                                    shouldUsePercent = true
                                end

                                if val.Id == "ATK" then
                                    return `{use(val.Val[1])}-{use(val.Val[2])}`
                                else
                                    return use(val.Val[1])..(if shouldUsePercent then "%" else "")
                                end
                            end),
                            TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                if use(val.Val[1]) > use(correspondingBaseStat.Val[1]) then
                                    return Color3.fromRGB(0, 255, 255)
                                else
                                    return Color3.fromHex('#ffffff')
                                end
                            end),


                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingBottom = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0, 0),
                                    PaddingRight = UDim.new(0, 0)
                                })
                            }
                        }),

                        Components.IconImageLabel(scope, {
                            Position = UDim2.fromScale(0.02, 0.5),
                            AnchorPoint = Vector2.new(0, 0.5),
                            Size = UDim2.fromScale(0.8, 0.8),

                            Image = STAT_ICONS[val.Id] or AssetBook.ExtraIcons.Unknown,
                            ImageColor3 = STAT_ICON_COLORS[val.Id] or Color3.fromRGB(255, 255, 255),
                        })
                    }
                })
            end)
        }

    }, {
        Padding = UDim.new(0, 0),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
end