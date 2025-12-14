
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

return {
    ---@params: `player: Player`
    RToSpawnChar = Signal.new(),

    ---@params: `charId: string, orbName: string, extraProps: {Offset: Vector3?, ForceLocation: CFrame?}?`
    RToSpawnOrb = Signal.new(),

    ---@params: `charId: string, props: {ProjectId: string, ProjectileType: "OneTime" | "OverTime"`
    --`,Duration: number, ProjectileUniqueId: string, DMGType: "DMG" | "Magic", DoTType: string, DMGBonus: number`
    --`,IsClassUlt: boolean }`
    RToCreateProjectileSymbol = Signal.new(),

    ---@params: `key: string, value: any, storeName: string`
    RToUpdateLeaderboardRank = Signal.new(),

    ---@params: `player: Player, storeName: string`
    RToAwardLeaderboardRank = Signal.new(),

    ---@params: `player: Player, data: {AbyssId: number}`
    RToChallengeAbyss = Signal.new(),

    ---@params: `playerName: string`
    PlayerDied = Signal.new(),

    ---@params: `player: Player, option: string, newMember: string`
    PartyInvite = Signal.new(),

    ---@params: `player: Player, questId: string`
    QuestCompleted = Signal.new(),

    ---@params: `msg: string`
    RToSendMsgToDiscord = Signal.new(),

    ---@params: `player: Player`
    RToCheckPlayerBadges = Signal.new(),
}