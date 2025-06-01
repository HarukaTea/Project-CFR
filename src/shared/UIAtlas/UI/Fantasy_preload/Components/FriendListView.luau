--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local FrameBorderTex = require(RepS.HarukaShared.UIAtlas.Components.FrameBorderTex)
local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children

local fromRGB = Color3.fromRGB
local wait = task.wait


return function (scope: Fusion.Scope, props: {
    SaveSlotClickedSignal: RBXScriptSignal,
    SaveSlotBackSignal: RBXScriptSignal,
    ReadyToTeleportSignal: RBXScriptSignal,

    FriendListClickedSignal: RBXScriptSignal,
    ServerListClickedSignal: RBXScriptSignal,

    SlotChosen: Fusion.Value
})

    local function Value(val: any) : Fusion.Value
        return Fusion.Value(scope, val)
    end
    local isVisible = Value(false)
    local friendsOnline = Value({})


    props.FriendListClickedSignal:Connect(function()
        isVisible:set(true)
    end)
    props.ServerListClickedSignal:Connect(function()
        isVisible:set(false)
    end)

    props.SaveSlotClickedSignal:Connect(function()
        isVisible:set(true)
    end)
    props.SaveSlotBackSignal:Connect(function()
        isVisible:set(false)
    end)

    local function _getFriendsOnline()
        pcall(function()
            friendsOnline:set(Players.LocalPlayer:GetFriendsOnline())
        end)
    end
    table.insert(scope, task.spawn(function()
        _getFriendsOnline()

        while wait(35) do
            _getFriendsOnline()
        end
    end))


    local view; view = Components.Frame(scope, {
        Name = "FriendList",
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.6, 8),
        Position = UDim2.fromScale(0.65, 0.5),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible)
        end),

        [Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.03, 0) }),

            Components.UIStroke(scope, {
                Thickness = 3,
                Color = Color3.new(),
            }),

            FrameBorderTex(scope, {
                BorderType = "Outer",
                Size = UDim2.fromScale(0.07, 0.07)
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

                Text = "<u>Friends Playing</u>",
            }),

            Components.TextLabel(scope, {
                Name = "Empty",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 0.07),

                Text = "FETCHING ONLINE FRIENDS...",
                TextColor3 = Color3.fromRGB(159, 159, 159),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return next(use(friendsOnline)) == nil
                end)
            }),


            Components.ScrollingFrame(scope, {
                Name = "FriendList",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.15),
                Size = UDim2.fromScale(0.95, 0.8),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Children] = {
                    Components.PaddingFrame(scope, "AAA"),
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.ForPairs(scope, friendsOnline, function(_, scope: Fusion.Scope, index: string, info: {
                        IsAlreadyInInitus: boolean,

                        VisitorId: number,
                        UserName: string,
                        DisplayName: string,
                        LastOnline: string,
                        IsOnline: boolean,
                        LastLocation: string,
                        PlaceId: number,
                        GameId: number,
                        LocationType: number
                    })
                        local isSelecting = Fusion.Value(scope, false)
                        local playerAvatarIcon = Fusion.Value(scope, "")

                        table.insert(scope, task.spawn(function()
                            local imageId = Players:GetUserThumbnailAsync(
                                info.VisitorId,
                                Enum.ThumbnailType.HeadShot,
                                Enum.ThumbnailSize.Size48x48
                            )

                            playerAvatarIcon:set(imageId)
                        end))

                        local STATUS_COLORS = {
                            [1] = fromRGB(0, 198, 96),
                            [4] = fromRGB(0, 198, 96),
                            [5] = fromRGB(0, 198, 96),

                            [0] = fromRGB(85, 170, 255),
                            [2] = fromRGB(85, 170, 255),

                            [3] = fromRGB(255, 170, 0),
                            [6] = fromRGB(255, 170, 0)
                        }

                        return index, Components.HoverImageButton(scope, {
                            Name = Fusion.Computed(scope, function()
                                if info.IsAlreadyInInitus then return "A-InInitus-"..info.UserName end

                                if STATUS_COLORS[info.LocationType] == fromRGB(0, 198, 96) then
                                    return "C-InGame-"..info.UserName

                                elseif STATUS_COLORS[info.LocationType] == fromRGB(85, 170, 255) then
                                    return "D-Online-"..info.UserName
                                else
                                    return "E-Studio-"..info.UserName
                                end
                            end),

                            Size = UDim2.fromScale(0.94, 0.2),
                            BackgroundColor3 = Color3.new(),
                            BackgroundTransparency = 0,

                            [Fusion.OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [Fusion.OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,


                            [Children] = {
                                Components.UIAspectRatioConstraint(scope, 11.184),

                                Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.2, 0) }),


                                Components.UIStroke(scope, {
                                    Thickness = 1.75,
                                    Color = Color3.fromRGB(193, 193, 193),

                                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(isSelecting)
                                    end)
                                }),

                                Components.IconImageLabel(scope, {
                                    Name = "Avatar",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.023, 0.5),
                                    Size = UDim2.fromScale(0.8, 0.8),
                                    BackgroundColor3 = Components.BLACK_COLOR,

                                    Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(playerAvatarIcon)
                                    end),

                                    [Children] = {
                                        Components.IconImageLabel(scope, {
                                            Name = "Status",
                                            Position = UDim2.fromScale(0.7, 0.7),
                                            Size = UDim2.fromScale(0.3, 0.3),
                                            ZIndex = 2,
                                            BackgroundColor3 = STATUS_COLORS[info.LocationType],
                                        })
                                    }
                                }),
                                Components.TextLabel(scope, {
                                    Name = "PlayerName",
                                    Position = UDim2.fromScale(0.11, 0.098),
                                    Size = UDim2.fromScale(0.85, 0.35),
                                    RichText = true,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutoLocalize = false,

                                    Text = Fusion.Computed(scope, function()
                                        local displayName, userName = info.DisplayName :: string, info.UserName :: string

                                        if displayName == userName then
                                            return displayName
                                        else
                                            return displayName..[[<font color="#999">]].." (@"..userName..")</font>"
                                        end
                                    end)
                                }),
                                Components.TextLabel(scope, {
                                    Name = "Playing",
                                    Position = UDim2.fromScale(0.11, 0.48),
                                    Size = UDim2.fromScale(0.85, 0.35),
                                    Text = info.LastLocation,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    TextColor3 = STATUS_COLORS[info.LocationType],
                                    AutoLocalize = false
                                }),
                            }
                        })
                    end)
                }
            }, {
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.Name
            }),
        }
    })


    --// anims
    local visibleObserver = Fusion.Observer(scope, isVisible)
    visibleObserver:onBind(function()
        local vis = Fusion.peek(isVisible)
        if vis then
            HarukaLib:UITween(view, "In", {
                TweenTime = 0.5,

                PosTweenStyle = "FromR2L",
                PosTweenBaseElement = view,
                PosTweenOffset = 15.99 * 2
            })
        end
    end)

    return view
end
