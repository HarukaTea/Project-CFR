
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)

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

    local view; view = Fusion.Hydrate(scope, Components:RefUI("ServerList_CFTitle2_1", false, true, {
        "CAPatternTex", "Title"
    }))({
        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Empty_CFTitleServer1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib.TableUtils.IsEmpty(use(serversAvailable))
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

                        return index, Fusion.Hydrate(scope, Components:RefUI("ServerSlot_CFTitleServer1_1", false, false, {
                            "UICorner", "UIAspectRatioConstraint", "Icon"
                        }))({
                            Name = "Server_"..index,
                            LayoutOrder = order,

                            Components.ConnectSelectEvents(isSelecting),

                            [Children] = {
                                Components.ScaledUIStroke(scope, {
                                    Thickness = 0.03,

                                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(isSelecting)
                                    end)
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("ServerId_CFTitleServer1_1"))({
                                    Text = info.ServerName..[[<font color="#444444">]].." [ "..info.ServerLocation..", "..info.CityLocation.." / "..id.."]</font>"
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("PlayerCount_CFTitleServer1_1"))({
                                    Text = "Adventurers: "..symbol.Value.." / 20",
                                    TextColor3 = Fusion.Computed(scope, function()
                                        return if symbol.Value < 20 then Color3.fromRGB(0, 198, 96) else Color3.fromRGB(255, 0, 0)
                                    end)
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("JoinBtn_CFTitleServer1_1", true))({
                                    BackgroundColor3 = Fusion.Computed(scope, function()
                                        return if symbol.Value < 20 then Components.GREEN_COLOR else Components.RED_COLOR
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        if game.JobId == symbol.Name then
                                            Bindables.CreateNotify:Fire("Already in this server")
                                            return
                                        end
                                        Events.ServerHop_C.Fire(symbol.Name)
                                    end
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