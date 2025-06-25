--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children


return function(scope: Fusion.Scope, props: {
    MobId: string,
    MobInfo: {
        Level: number,
        EnvironmentBonus: number
    }
})

    if not EntityBook[props.MobId] then return nil end

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = props.MobId,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(),

        [Fusion.OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [Fusion.OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 3.513),
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.2, 0)
            }),

            Components.UIStroke(scope, {
                Thickness = 2.5,
                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),


            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.05, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                Image = EntityBook[props.MobId].Icon
            }),

            Components.TextLabel(scope, {
                Name = "EnemyName",
                Position = UDim2.fromScale(0.32, 0.15),
                Size = UDim2.fromScale(0.6, 0.3),
                TextXAlignment = Enum.TextXAlignment.Left,
                RichText = true,

                Text = `<u>{EntityBook[props.MobId].Name}</u>`
            }),
            Components.TextLabel(scope, {
                Name = "EnemyLevel",
                Position = UDim2.fromScale(0.32, 0.55),
                Size = UDim2.fromScale(0.6, 0.27),
                TextColor3 = Color3.fromRGB(255, 255, 127),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = `Lv.{props.MobInfo.Level}`
            }),
        }
    })
end
