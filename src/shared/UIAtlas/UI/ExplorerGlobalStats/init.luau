
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local wait = task.wait


local Pinia = require(script.Pinia)

return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
	self.char = plr.Character
    self.scope = Fusion.scoped()


	Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerStatsGlobal") then
        plr.PlayerGui.ExplorerStatsGlobal:Destroy()
    end


	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerStatsGlobal",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

	}, {
        BottomProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),

            [Children] = {
                Components.Frame(scope, {
                    Name = "CastTimeBars",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),

                        Components.UIScale(scope, {
                            Scale = 0.9
                        }),
                    }
                }),


                Components.Frame(scope, {
                    Name = "BadgeAwarding",
                    AnchorPoint = Vector2.zero,
                    Position = UDim2.fromScale(0, -1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            Padding = UDim.new(0.5, 0)
                        })
                    }
                })
            }
        },
        CenterProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),


            [Children] = {
                Components.Frame(scope, {
                    Name = "ItemDropsDiv",
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromScale(1, 0),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1
                        }),

                        Components.Frame(scope, {
                            Name = "ItemDrops",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(0.99, 0),

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    Padding = UDim.new(0.15, 0),
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    VerticalAlignment = Enum.VerticalAlignment.Top,
                                    SortOrder = Enum.SortOrder.Name,
                                }),
                            }
                        }),
                    }
                }),
            }
        },

        TopProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),

            [Children] = {
                Components.Frame(scope, {
                    Name = "LevelEXP",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 1.5),

                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.IsUIShown2)
                    end),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.75
                        }),
                    }
                }),
            }
        }
    })
    self.UI = UI


	require(script.Anims)(UI, self)


	return function ()
        Fusion.doCleanup(scope)
    end
end