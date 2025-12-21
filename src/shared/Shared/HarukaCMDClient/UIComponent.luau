
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)


local Children = Fusion.Children


local Types = require(script.Parent.Types)


type Dict = {[string]: any}


return function (scope: Fusion.Scope, props: {
    IsShownVal: Fusion.Value<boolean>,
    CMDInput: Fusion.Value<string>,
    CMDSearchInput: Fusion.Value<string>,

    Intellisense: Fusion.Value<{ Types.CommandJSON }>,
    ItemIntellisense: Fusion.Value<{ Types.CommandJSON }>,

    IntellisensePointer: Fusion.Value<number>,
    ItemIntellisensePointer: Fusion.Value<number>,

    ExtraArgs: { Fusion.Value<string> },
    ExtraArgsSearch: { Fusion.Value<string> },

}, self: Types.HarukaCMDClass)

    local isSelectingCMD = Fusion.Value(scope, false)


    return Components.HarukaScreenGui(scope, {
        Name = "HarukaCMD",
        DisplayOrder = 1000,
        Parent = Players.LocalPlayer.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(props.IsShownVal)
        end)

    }, {
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "Input",
                    Position = UDim2.fromScale(0.5, 1),
                    AnchorPoint = Vector2.new(0.5, 1),
                    Size = UDim2.new(1, 0, 0, 26),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),


                        Components.TextButton(scope, {
                            Name = "CMDPreview",
                            AutoButtonColor = false,
                            AutoLocalize = false,
                            RichText = true,
                            LayoutOrder = 2,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 0,

                            [Fusion.Out("Text")] = props.CMDInput,


                            BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return if use(isSelectingCMD) then Components.WHITE_COLOR else Components.BLACK_COLOR
                            end),
                            TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return if use(isSelectingCMD) then Color3.new() else Components.WHITE_COLOR
                            end),
                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local text = use(props.CMDInput) :: string

                                local count = 0
                                local extraArgsText = string.gsub(text, "<([^>]*)>", function(content)
                                    count += 1
                                    if use(props.ExtraArgs[count]) == "" then
                                        return "<"..content..">"
                                    end

                                    return "<"..use(props.ExtraArgs[count])..">"
                                end)

                                return extraArgsText
                            end),

                            [Fusion.OnEvent("MouseEnter")] = function()
                                isSelectingCMD:set(true)
                            end,
                            [Fusion.OnEvent("MouseLeave")] = function()
                                isSelectingCMD:set(false)
                            end,
                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                self.ExecuteCommandFunc()
                            end,

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0.01, 0),
                                    PaddingRight = UDim.new(0.01, 0),
                                    PaddingBottom = UDim.new(0.15, 0)
                                })
                            }
                        }),
                        Components.TextBox(scope, {
                            Name = "CMDSearch",
                            AutoLocalize = false,
                            RichText = true,
                            LayoutOrder = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 0,
                            PlaceholderText = "Search Commands Here",
                            PlaceholderColor3 = Color3.fromRGB(159, 159, 159),

                            [Fusion.Out("Text")] = props.CMDSearchInput,

                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return use(props.CMDSearchInput)
                            end),

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0.01, 0),
                                    PaddingRight = UDim.new(0.01, 0),
                                    PaddingBottom = UDim.new(0.15, 0)
                                })
                            }
                        })
                    }
                }),
                Components.Frame(scope, {
                    Name = "CMDIntellisense",
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0.5, 0, 0.8, -52),
                    AnchorPoint = Vector2.new(0.5, 1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),


                        Fusion.ForPairs(scope, props.Intellisense, function(_, scope: Fusion.Scope, index: number, cmd: Types.CommandJSON)
                            return index, Components.TextButton(scope, {
                                Name = cmd.Name,
                                AutoLocalize = false,
                                AutoButtonColor = false,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                BackgroundTransparency = 0,
                                LayoutOrder = index + 1,

                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.IntellisensePointer) == index then Components.WHITE_COLOR else Components.BLACK_COLOR
                                end),
                                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.IntellisensePointer) == index then Color3.new() else Components.WHITE_COLOR
                                end),

                                Text = Fusion.Computed(scope, function()
                                    local alias = cmd.Alias
                                    local totalArgs = ""
                                    for _, arg in cmd.Args do
                                        totalArgs..= "<"..arg.Name..">"
                                    end

                                    return string.format("%s %s", alias, totalArgs)
                                end),

                                [Fusion.OnEvent("MouseEnter")] = function()
                                    props.IntellisensePointer:set(index)
                                end,
                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    self.AutoCompleteFunc()
                                end,

                                [Children] = {
                                    Components.UIPadding(scope, {
                                        PaddingTop = UDim.new(0.15, 0),
                                        PaddingLeft = UDim.new(0.01, 0),
                                        PaddingRight = UDim.new(0.01, 0),
                                        PaddingBottom = UDim.new(0.15, 0)
                                    })
                                }
                            })
                        end),


                        Components.Frame(scope, {
                            Name = "Padding",
                            Size = UDim2.fromScale(1, 1),
                            LayoutOrder = 1
                        }),

                        Components.Frame(scope, {
                            Name = "ItemIntellisense",
                            Size = UDim2.fromScale(1, 1),
                            LayoutOrder = 0,

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    Padding = UDim.new(0.02, 0),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                }),

                                Components.PaddingFrame(scope, "AAA"),

                                Fusion.ForPairs(scope, props.ItemIntellisense, function(_, scope: Fusion.Scope, index: number, arg: Types.CommandArgJSON)
                                    local argType = arg.Type :: string

                                    local intellisenseItems = Fusion.Value(scope, {})
                                    local extraArgSearchVal = props.ExtraArgsSearch[index]

                                    if argType == "enum" then
                                        intellisenseItems:set(arg.EnumItems)

                                        local enumItems: { string } = arg.EnumItems

                                        local searchObserver = Fusion.Observer(scope, extraArgSearchVal)
                                        searchObserver:onBind(function()
                                            local searchText = Fusion.peek(extraArgSearchVal) :: string
                                            local realSearch = string.gsub(searchText, " ", "")

                                            if realSearch == "" then
                                                intellisenseItems:set(enumItems)
                                                return
                                            end

                                            realSearch = realSearch :: string

                                            local accepted = {}
                                            pcall(function()
                                                for _, option in enumItems do
                                                    if string.find(string.lower(option), string.lower(realSearch)) then
                                                        table.insert(accepted, option)
                                                    end
                                                end
                                            end)

                                            intellisenseItems:set(accepted)
                                        end)

                                    elseif argType == "player" or argType == "players" then
                                        local function __getPlayers()
                                            local players = {}
                                            for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
                                                table.insert(players, player.Name)
                                            end

                                            if argType == "players" then
                                                table.insert(players, "All")
                                            end

                                            intellisenseItems:set(players)
                                        end
                                        __getPlayers()
                                        table.insert(scope, CollectionService:GetInstanceAddedSignal("PlayerEntity"):Connect(__getPlayers))
                                        table.insert(scope, CollectionService:GetInstanceRemovedSignal("PlayerEntity"):Connect(__getPlayers))


                                        local searchObserver = Fusion.Observer(scope, extraArgSearchVal)
                                        searchObserver:onBind(function()
                                            local searchText = Fusion.peek(extraArgSearchVal) :: string
                                            local realSearch = string.gsub(searchText, " ", "")

                                            if realSearch == "" then
                                                __getPlayers()
                                                return
                                            end

                                            realSearch = realSearch :: string

                                            local accepted = {}
                                            pcall(function()
                                                for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
                                                    if string.find(string.lower(player.Name), string.lower(realSearch)) then
                                                        table.insert(accepted, player.Name)
                                                    end
                                                end
                                            end)
                                            if argType == "players" then
                                                table.insert(accepted, "All")
                                            end

                                            intellisenseItems:set(accepted)
                                        end)
                                    else
                                        local extraArgVal = props.ExtraArgs[index]
                                        local argTypeCopy = argType

                                        if argType == "number" then
                                            if arg.RangeMin and arg.RangeMax then
                                                argTypeCopy = `number ({arg.RangeMin}-{arg.RangeMax})`
                                            end
                                            if arg.RangeMin and not arg.RangeMax then
                                                argTypeCopy = `number (Min: {arg.RangeMin})`
                                            end
                                            if arg.RangeMax and not arg.RangeMin then
                                                argTypeCopy = `number (Max: {arg.RangeMax})`
                                            end
                                            if arg.ShouldBeInteger then
                                                argTypeCopy ..= "[Integer]"
                                            end
                                        end

                                        argType = argTypeCopy

                                        return index, Components.TextBox(scope, {
                                            Name = arg.Name,
                                            LayoutOrder = index,
                                            Size = UDim2.fromScale(0.23, 1),
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            BackgroundTransparency = 0,
                                            BackgroundColor3 = Color3.fromRGB(),

                                            [Fusion.Out("Text")] = extraArgVal,

                                            PlaceholderText = argType,
                                            PlaceholderColor3 = Color3.fromRGB(159, 159, 159),

                                            [Children] = {
                                                Components.UIPadding(scope, {
                                                    PaddingTop = UDim.new(0.15, 0),
                                                    PaddingLeft = UDim.new(0.03, 0),
                                                    PaddingRight = UDim.new(0.03, 0),
                                                    PaddingBottom = UDim.new(0.15, 0)
                                                })
                                            }
                                        })
                                    end

                                    local pointer = Fusion.Value(scope, 1)

                                    return index, Components.Frame(scope, {
                                        Name = arg.Name,
                                        LayoutOrder = index,
                                        Size = UDim2.fromScale(0.23, 1),

                                        [Children] = {
                                            Components.UIListLayout(scope, {
                                                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                            }),


                                            Fusion.ForPairs(scope, intellisenseItems, function(_, scope: Fusion.Scope, iindex: number, option: string)
                                                return iindex, Components.TextButton(scope, {
                                                    Name = option,
                                                    AutoLocalize = false,
                                                    AutoButtonColor = false,
                                                    TextXAlignment = Enum.TextXAlignment.Left,
                                                    BackgroundTransparency = 0,
                                                    LayoutOrder = iindex + 1,

                                                    BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                        return if use(props.ItemIntellisensePointer) == index and use(pointer) == iindex then Components.WHITE_COLOR else Components.BLACK_COLOR
                                                    end),
                                                    TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                        return if use(props.ItemIntellisensePointer) == index and use(pointer) == iindex then Color3.new() else Components.WHITE_COLOR
                                                    end),

                                                    Text = option,

                                                    [Fusion.OnEvent("MouseEnter")] = function()
                                                        props.ItemIntellisensePointer:set(index)
                                                        pointer:set(iindex)
                                                    end,
                                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                                        self.ArgAutoCompleteFunc({
                                                            Option = option,
                                                            Index = index
                                                        })
                                                    end,

                                                    [Children] = {
                                                        Components.UIPadding(scope, {
                                                            PaddingTop = UDim.new(0.15, 0),
                                                            PaddingLeft = UDim.new(0.03, 0),
                                                            PaddingRight = UDim.new(0.03, 0),
                                                            PaddingBottom = UDim.new(0.15, 0)
                                                        })
                                                    }
                                                })
                                            end),

                                            Components.TextBox(scope, {
                                                Name = arg.Name,
                                                LayoutOrder = 999,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                BackgroundTransparency = 0,
                                                BackgroundColor3 = Color3.fromRGB(),

                                                [Fusion.Out("Text")] = extraArgSearchVal,

                                                PlaceholderText = "Search Object Here",
                                                PlaceholderColor3 = Color3.fromRGB(159, 159, 159),

                                                [Children] = {
                                                    Components.UIPadding(scope, {
                                                        PaddingTop = UDim.new(0.15, 0),
                                                        PaddingLeft = UDim.new(0.03, 0),
                                                        PaddingRight = UDim.new(0.03, 0),
                                                        PaddingBottom = UDim.new(0.15, 0)
                                                    })
                                                }
                                            })
                                        }
                                    })
                                end)
                            }
                        }),
                    }
                })
            }
        }
    })
end