--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)


local wait = task.wait

return function (self: table)
	local scope = self.scope :: Fusion.Scope


	self.SlotUISignal = Signal.new()
    self.CutsceneUISignal = Signal.new()
    table.insert(scope, self.SlotUISignal)
    table.insert(scope, self.CutsceneUISignal)

    self.CharVals = {}

    for _ = 1, 3 do
        table.insert(self.CharVals, Fusion.Value(scope, nil))
    end

    table.insert(scope, task.spawn(function()
        Promise.new(function(resolve)
            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId)
            local r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)

            resolve(r6Char)

        end):andThen(function(r6Char: Model)
            r6Char.Name = "Rig"
            r6Char.PrimaryPart = r6Char.Humanoid.RootPart
            r6Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            r6Char.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            r6Char.Animate:Destroy()
            r6Char.Parent = workspace.MapComponents.Titlescreen


            for _, val: Fusion.Value in self.CharVals do
                local clonedChar = r6Char:Clone()
                clonedChar:PivotTo(workspace.MapComponents.Titlescreen.CharPreviewLocator.CFrame)
                clonedChar.Parent = workspace.MapComponents.Titlescreen

                val:set(clonedChar)
            end

        end):catch(function() end)
    end))


    table.insert(scope, task.spawn(function()
        Promise.try(function()
            local cframe = workspace.MapComponents.Titlescreen.TitleRoom.Rig.PrimaryPart.CFrame

            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(self.plr.UserId)
            local r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)

            r6Char.Name = "Rig"
            r6Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            r6Char.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            r6Char.Animate:Destroy()

            workspace.MapComponents.Titlescreen.TitleRoom.Rig:Destroy()
            r6Char:PivotTo(cframe)

            r6Char.Parent = workspace.MapComponents.Titlescreen.TitleRoom


            local anim: Animation = RepS.Packages.Anims.CharAnims.Idle1
            local animTrack = r6Char.Humanoid.Animator:LoadAnimation(anim) :: AnimationTrack

            animTrack.Looped = true
            animTrack.Priority = Enum.AnimationPriority.Idle

            animTrack:Play()


            table.insert(scope, HarukaLib:Hydrate(workspace, {
                ["Attr-Titlescreen_TempClass"] = function(class: string)
                    class = class or "Chain"

                    local weapons = {
                        Chain = "WoodenSword",
                        Burst = "WoodenBow",
                        Flow = "WoodenStaff",
                    }
                    local weaponId = weapons[class] or "WoodenSword"

                    for _, weapon: Model in r6Char:GetChildren() do
                        if weapon:HasTag("ClassWeapon") then weapon:Destroy() end
                    end
                    if not RepS.Packages.ClassWeapons:FindFirstChild(class) then return end
                    if not RepS.Packages.ClassWeapons[class]:FindFirstChild(weaponId) then return end


                    local targetFolder = RepS.Packages.ClassWeapons[class][weaponId].Combat :: Folder

                    for _, weapon: Model in targetFolder:GetChildren() do
                        weapon = weapon:Clone()
                        weapon:AddTag("ClassWeapon")

                        ClientLib:WeldWeapon(weapon, r6Char)
                    end

                    HarukaLib:EmitParticles(workspace.MapComponents.Titlescreen.TitleRoom.SwitchVFX)
                end
            }))
        end):catch(function() end)
    end))

end
