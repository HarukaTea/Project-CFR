
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ClassVal: Fusion.Value<number>,

    Char: Model
})

    local char = props.Char
    local rayCastHeight = Fusion.Value(scope, 0)
    local jumpHeight = Fusion.Value(scope, char.Humanoid.JumpHeight)

    table.insert(scope, RunService.Heartbeat:Connect(function()
        if not ClientLib:IsModelValid(char) then return end

        local rayResult = ClientLib:FindGroundByRay(char.PrimaryPart.Position)

        rayCastHeight:set((rayResult + Vector3.yAxis * 4.5 - char.PrimaryPart.Position).Magnitude)
    end))
    table.insert(scope, HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-JumpHeight"] = function(newHeight: number)
            jumpHeight:set(newHeight)
        end
    }))


    return Components.Frame(scope, {
        Name = "ChainStyle",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -1.8),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(props.ClassVal) > 0
        end),

        [Children] = {
            Components.Frame(scope, {
                AnchorPoint = Vector2.new(0.5, 1),
                Name = "BarBG",
                BackgroundTransparency = 0,
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromScale(0.25, 0.2),

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.Frame(scope, {
                        Name = "TweenBar",

                        BackgroundColor3 = ClassBook.Chain.Color,
                        BackgroundTransparency = 0,

                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                            local jHeight = use(jumpHeight) * 1.599 ^ 3 :: number
                            local rayHeight = use(rayCastHeight) :: number
                            local barHeight = math.clamp(rayHeight / jHeight, 0, 1)

                            return UDim2.fromScale(barHeight, 1)

                        end), AssetBook.TweenInfos.twiceHalf),


                        [Children] = {
                            Components.RoundUICorner(scope)
                        }
                    })
                }
            })
        }
    })
end