
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    MobId: string,
    Level: number
})

    if not EntityBook[props.MobId] then return nil end

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = props.MobId,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(),
        Size = UDim2.fromScale(0.425, 1),

        [Fusion.OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [Fusion.OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,

        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.2, 0)
            }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,
                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            CFEmblemTex(scope, {
                Position = UDim2.fromScale(0.42, 0.5),
                Transparency = 0.9
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

                Text = `Lv.{props.Level}`
            }),
        }
    })
end