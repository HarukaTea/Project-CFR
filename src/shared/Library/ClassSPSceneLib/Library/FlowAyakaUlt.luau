--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


--// Main

return function(self: Types.ClassSPSceneTable, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
    if not ClientLib.IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


    local flowCharge = RepS.Packages.SkillProjectiles:FindFirstChild("FlowCharge", true):Clone() :: BasePart
    flowCharge.CFrame = char.PrimaryPart.CFrame
    flowCharge.Parent = workspace
    Debris:AddItem(flowCharge, 1)

    HarukaLib:EmitParticles(flowCharge)


    local tempMarkedContainer = ClassSPSceneLib._createMarkContainer()


    for _, angle: number in { -8, 8 } do
        task.spawn(function()
            local part = HarukaLib:CreateMockPart()
            part.CFrame = char.PrimaryPart.CFrame * CFrame.new(angle / 3, 0, 0)
            part.Parent = workspace
            Debris:AddItem(part, 10)


            Promise.new(function(resolve)
                local isFound = false

                while true do
                    RunService.Heartbeat:Wait()

                    if isFound then break end
                    if part == nil then break end
                    if part.Parent == nil then break end

                    local pos = part.Position

                    for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                        if not ClientLib.IsCharValid(symbol.Value) then continue end
                        if tempMarkedContainer:FindFirstChild(symbol.Value:GetAttribute("HarukaUniqueId")) then continue end


                        local entity = symbol.Value :: Model
                        local enemyPos = entity.PrimaryPart.Position
                        local dist = (pos - enemyPos).Magnitude :: number

                        if dist < 26 then
                            local bool = Instance.new("BoolValue")
                            bool.Name = entity:GetAttribute("HarukaUniqueId")
                            bool.Value = true
                            bool.Parent = tempMarkedContainer


                            Events.RequestToDMGEnemyBySkillProjectile.Fire({
                                ProjectileUniqueId = projectileUniqueId,
                                EnemyEntity = entity,
                            })
                            isFound = true
                            break
                        end
                    end
                end

                resolve()

            end):timeout(5):catch(function() end)


            local startPos = part.CFrame
            local endPos = part.CFrame * CFrame.new(angle, 3.5, -32.5)
            local distance = (endPos.Position - startPos.Position).Magnitude :: number

            Promise.try(function()
                for i = 0, distance, 0.125 do
                    local progress = i / distance
                    endPos *= CFrame.new(0, 0, -0.225)

                    part.CFrame = part.CFrame:Lerp(endPos, progress)

                    if i >= 12 then break end
                    wait()
                end

                part:Destroy()
            end):catch(function() end)


            --- visual
            local flowIce = RepS.Packages.SkillProjectiles:FindFirstChild("FlowIce", true):Clone() :: BasePart
            flowIce.CFrame = part.CFrame
            flowIce.Parent = workspace
            Debris:AddItem(flowIce, 10)

            Promise.try(function()
                while part and part.Parent do
                    flowIce.Rot.Orientation = Vector3.zAxis * math.random(-360, 360)
                    flowIce.Rot.Shards:Emit(35)
                    wait(0.15)
                end
            end):catch(function() end)

            Promise.try(function()
                while true do
                    RunService.Heartbeat:Wait()

                    if flowIce == nil then break end
                    if flowIce.Parent == nil then break end

                    if part and part.Parent then
                        HarukaLib:CreateTween(flowIce, TweenInfo.new(0.005, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            CFrame = part.CFrame
                        }):Play()
                    else
                        Debris:AddItem(flowIce, 2)

                        local val = ClassSPSceneLib._tweenValue(3, 0.135, 20)
                        HarukaLib:CreateTween(flowIce.Attachment.PointLight, AssetBook.TweenInfos.twiceHalf, {Range = 35}):Play()

                        flowIce.Attachment.Smoke.Enabled = false
                        flowIce.Attachment.Specs.Enabled = false
                        flowIce.Attachment.Main.Enabled = false
                        flowIce.Attachment.Wind.Enabled = false
                        flowIce.Attachment.Vortex.Enabled = false

                        flowIce.Hit.Spark:Emit(1)
                        flowIce.Hit.Gradient:Emit(1)
                        flowIce.Hit.Snowflake:Emit(7)
                        flowIce.Hit.Shards:Emit(20)
                        flowIce.Hit.Specs:Emit(25)
                        flowIce.Hit.Smoke:Emit(80)

                        val.Changed:Connect(function(newVal: number)
                            pcall(function()
                                flowIce.Attachment.Main.Size = NumberSequence.new({flowIce.Attachment.Main.Size.Keypoints[1], NumberSequenceKeypoint.new(1, newVal)})
                                flowIce.Attachment.Wind.Size = NumberSequence.new({flowIce.Attachment.Main.Size.Keypoints[1], NumberSequenceKeypoint.new(1, (newVal * 1.35))})
                            end)
                        end)

                        wait(0.35)
                        HarukaLib:CreateTween(flowIce.Attachment.PointLight, TweenInfo.new(0.8), {Range = 0}):Play()
                        break
                    end
                end

            end):catch(function() end)
        end)
    end
end
