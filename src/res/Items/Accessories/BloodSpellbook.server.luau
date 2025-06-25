local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(event.Event:Connect(function(_, attacker: Model, dmgProps: {
    DMG: number,
    Attacker: string,

    DMGType: string,
})
    if script == nil then return end
    if script.Parent == nil then return end
    if attacker ~= char then return end
    if not dmgProps then return end
    if not dmgProps.DMG then return end
    if not dmgProps.Attacker then return end
    if dmgProps.Attacker ~= "ClassAttacks" then return end


    char.Humanoid:TakeDamage(math.ceil(char.Humanoid.MaxHealth * 0.05))
end))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
