
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
        if Fusion.peek(props.ClassVal) <= 0 then return end

        local rayResult = ClientLib:FindGroundByRay(char.PrimaryPart.Position)

        rayCastHeight:set((rayResult + Vector3.yAxis * 4.5 - char.PrimaryPart.Position).Magnitude)
    end))
    table.insert(scope, HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-JumpHeight"] = function(newHeight: number)
            jumpHeight:set(newHeight)
        end
    }))


    return Fusion.Hydrate(scope, Components:RefUI("ChainStyle_CA1_1"))({
        Visible = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(props.ClassVal) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("BarBG_CA1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("TweenBar_CA1_1", true))({
                        BackgroundColor3 = ClassBook.Chain.Color,

                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                            local jHeight = use(jumpHeight) * 1.599 ^ 3 :: number
                            local rayHeight = use(rayCastHeight) :: number
                            local barHeight = math.clamp(rayHeight / jHeight, 0, 1)

                            return UDim2.fromScale(barHeight, 1)

                        end), Components.TweenInfos.twiceHalf),
                    })
                }
            })
        }
    })
end