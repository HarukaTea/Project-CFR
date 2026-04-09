
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)


local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    SaveSlotClickedSignal: BindableEvent,
    SaveSlotBackSignal: BindableEvent,
    ReadyToTeleportSignal: BindableEvent,

    ServerListClickedSignal: BindableEvent,

    SlotChosen: Fusion.Value<string>
})

    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local isVisible = Value(false)
    local serversAvailable = Components.FusionComponents.useChildren(scope, workspace.MapComponents.GlobalServers)


    props.ServerListClickedSignal.Event:Connect(function()
        isVisible:set(true)
    end)
    props.SaveSlotClickedSignal.Event:Connect(function()
        isVisible:set(true)
    end)
    props.SaveSlotBackSignal.Event:Connect(function()
        isVisible:set(false)
    end)


    local view; view = Components.Frame(scope, {
        Name = "ServerList",
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.6, 8),
        Position = UDim2.fromScale(0.65, 0.5),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible)
        end),

        [Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.03, 0) }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.01,
                Color = Color3.new(),
            }),

            CAPatternTex(scope, {
                TileSize = UDim2.fromScale(0.07, 0.15)
            }),


            Components.TextLabel(scope, {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.02),
                Size = UDim2.fromScale(0.86, 0.075),
                RichText = true,

                Text = "<u>Global Servers</u>",
            }),

            Components.TextLabel(scope, {
                Name = "Empty",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 0.07),

                Text = "NO SERVERS AVAILABLE",
                TextColor3 = Color3.fromRGB(159, 159, 159),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return next(use(serversAvailable)) == nil
                end)
            }),


            Components.ScrollingFrame(scope, {
                Name = "ServerList_List",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.15),
                Size = UDim2.fromScale(0.95, 0.8),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Children] = {
                    Components.PaddingFrame(scope, "AAA"),
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.ForPairs(scope, serversAvailable, function(_, scope: Fusion.Scope, index: number, symbol: IntValue)
                        local isSelecting = Fusion.Value(scope, false)

                        local info = symbol:GetAttributes() :: {
                            CityLocation: string,
                            WorldId: string,
                            ServerLocation: string,
                            ServerName: string
                        }
                        info.ServerLocation = info.ServerLocation or "Unknown"
                        info.CityLocation = info.CityLocation or "Unknown"
                        info.ServerName = info.ServerName or "The Initia"
                        info.WorldId = info.WorldId or "InitusWorld"


                        local order = 999 - symbol.Value


                        local id = string.sub(symbol.Name, 1, 8)
                        if symbol.Name == game.JobId then
                            id = "Current Server"
                            order = 5
                        end


                        return index, Components.HoverImageButton(scope, {
                            Name = "Server_"..index,
                            Size = UDim2.fromScale(0.94, 0.2),
                            BackgroundColor3 = Color3.new(),
                            BackgroundTransparency = 0,

                            LayoutOrder = order,

                            [Fusion.OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [Fusion.OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,


                            [Children] = {
                                Components.UIAspectRatioConstraint(scope, 11.184),

                                Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.2, 0) }),


                                Components.ScaledUIStroke(scope, {
                                    Thickness = 0.03,

                                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(isSelecting)
                                    end)
                                }),

                                Components.IconImageLabel(scope, {
                                    Name = "Icon",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.023, 0.5),
                                    Size = UDim2.fromScale(0.8, 0.8),
                                    BackgroundColor3 = Components.BLACK_COLOR,

                                    Image = "rbxassetid://124997253539716"
                                }),
                                Components.TextLabel(scope, {
                                    Name = "ServerId",
                                    Position = UDim2.fromScale(0.11, 0.098),
                                    Size = UDim2.fromScale(0.85, 0.35),
                                    RichText = true,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutoLocalize = false,

                                    Text = info.ServerName..[[<font color="#444444">]].." [ "..info.ServerLocation..", "..info.CityLocation.." / "..id.."]</font>"
                                }),
                                Components.TextLabel(scope, {
                                    Name = "PlayerCount",
                                    Position = UDim2.fromScale(0.11, 0.48),
                                    Size = UDim2.fromScale(0.85, 0.35),
                                    TextXAlignment = Enum.TextXAlignment.Left,

                                    Text = "Adventurers: "..symbol.Value.." / 20",
                                    TextColor3 = Fusion.Computed(scope, function()
                                        return if symbol.Value < 20 then Color3.fromRGB(0, 198, 96) else Color3.fromRGB(255, 0, 0)
                                    end)
                                }),

                                Components.TextButton(scope, {
                                    Name = "JoinBtn",
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    Position = UDim2.fromScale(0.98, 0.5),
                                    Size = UDim2.fromScale(0.13, 0.4),
                                    Text = "JOIN",
                                    TextColor3 = Components.BLACK_COLOR,

                                    BackgroundColor3 = Fusion.Computed(scope, function()
                                        return if symbol.Value < 20 then Components.GREEN_COLOR else Components.RED_COLOR
                                    end),


                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        if game.JobId == symbol.Name then
                                            Bindables.CreateNotify:Fire("Already in this server")
                                            return
                                        end

                                        Events.ServerHop_C.Fire(symbol.Name)
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                        Components.UIPadding(scope, {
                                            PaddingTop = UDim.new(0.05, 0),
                                            PaddingBottom = UDim.new(0.05, 0),
                                            PaddingLeft = UDim.new(0, 0),
                                            PaddingRight = UDim.new(0, 0)
                                        })
                                    }
                                })
                            }
                        })
                    end)
                }
            }, {
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
        }
    })


    --// anims
    local visibleObserver = Fusion.Observer(scope, isVisible)
    visibleObserver:onBind(function()
        local vis = Fusion.peek(isVisible)
        if vis then
            HarukaLib:UITransTween(view, "In", {
                TweenTime = 0.5,

                PosTweenStyle = "FromR2L",
                PosTweenBaseElement = view,
                PosTweenOffset = 15.99 * 2
            })
        end
    end)

    return view
end