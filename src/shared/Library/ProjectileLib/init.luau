--!nocheck

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local TS = TweenService
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Maid = require(RepS.HarukaShared.Shared.Maid)

local ProjectileLib = {}

local wait = task.wait


local function _incomingCylinderAtt(projectileBase: BasePart)
    local cylinderMesh = Instance.new("CylinderMesh")

    local eff = Instance.new("Part")
    eff.Size = Vector3.new(projectileBase.Size.X + 1, 100, projectileBase.Size.Z + 1)
    eff.CFrame = projectileBase.CFrame
    eff.Color = Color3.fromRGB(255, 107, 107)
    eff.Material = Enum.Material.Neon
    eff.Transparency = 0.4
    eff.CanCollide = false
    eff.CanTouch = false
    eff.Massless = true
    eff.Anchored = true
    eff.CastShadow = false
    eff.CanQuery = false
    cylinderMesh.Parent = eff

    eff.Parent = projectileBase
    Debris:AddItem(eff, 1)


    HarukaLib:CreateTween(eff, AssetBook.TweenInfos.half, {
        Size = Vector3.new(0.01, 100, 0.01), Transparency = 1
    }):Play()
end
local function _rotateAttentionPoint(projectileBase: BasePart, container: Folder, props: {
    ShouldDetail: boolean,
    Size: "Big" | "Small" | "SuperBig"
})
    wait()
    local rotation = if math.random(1, 2) == 1 then 5000 else -5000

    local exclamationPart = RepS.Packages.EnemyAttacks:FindFirstChild("Exclamation_"..props.Size, true):Clone() :: Model
    exclamationPart:PivotTo(projectileBase.CFrame * CFrame.new(0, 1.599, 0))
    exclamationPart.Parent = container
    Debris:AddItem(exclamationPart, 1)

    local surfaceGui = exclamationPart.PrimaryPart.SurfaceGui :: SurfaceGui

    if props.ShouldDetail then _incomingCylinderAtt(projectileBase) end


    HarukaLib:CreateTween(surfaceGui.Exclamation, AssetBook.TweenInfos.fifteen, { Rotation = rotation }):Play()

    Promise.delay(0.5):andThen(function()
        HarukaLib:CreateTween(surfaceGui.Exclamation, AssetBook.TweenInfos.half, { ImageTransparency = 1 }):Play()

    end):catch(function() end)
end
local function _fadeAwayAndDestroy(obj: Instance)
    Debris:AddItem(obj, 1)

    obj:RemoveTag("PierceEntity")
    obj:RemoveTag("DMGEntity")


    if HarukaLib:IsBasePartType(obj) then
        HarukaLib:CreateTween(obj, AssetBook.TweenInfos.half, {
            Transparency = 1
        }):Play()
    else
        for _, child: Instance in obj:GetDescendants() do
            if HarukaLib:IsBasePartType(child) then
                HarukaLib:CreateTween(child, AssetBook.TweenInfos.half, {
                    Transparency = 1
                }):Play()

                child:RemoveTag("PierceEntity")
                child:RemoveTag("DMGEntity")
            end
        end
    end
end
local function _spawnProjectile(
    projectile: Model,
    container: Folder,
    duration: number,
    callback: (projectile: Model) -> nil
)
    local sProjectile = projectile.Projectile.Value:Clone() :: Model
    sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

    projectile.Owner:Clone().Parent = sProjectile

    callback(sProjectile)

    sProjectile.Parent = container

    Maid:AddItem(sProjectile, duration)

    ProjectileLib[sProjectile.Name](sProjectile, container)
end
ProjectileLib._fadeAwayAndDestroy = _fadeAwayAndDestroy
ProjectileLib._rotateAttentionPoint = _rotateAttentionPoint
ProjectileLib._spawnProjectile = _spawnProjectile



for _, module: ModuleScript in script.Library:GetChildren() do
    require(module)(ProjectileLib)
end


return ProjectileLib
