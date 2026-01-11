
return {
    ---@params: `player: Player`
    RToSpawnChar = Instance.new("BindableEvent"),

    ---@params: `charId: string, orbName: string, extraProps: {Offset: Vector3?, ForceLocation: CFrame?}?`
    RToSpawnOrb = Instance.new("BindableEvent"),

    ---@params: `charId: string, props: {ProjectId: string, ProjectileType: "OneTime" | "OverTime"`
    --`,Duration: number, ProjectileUniqueId: string, DMGType: "DMG" | "Magic", DoTType: string, DMGBonus: number`
    --`,IsClassUlt: boolean }`
    RToCreateProjectileSymbol = Instance.new("BindableEvent"),

    ---@params: `key: string, value: any, storeName: string`
    RToUpdateLeaderboardRank = Instance.new("BindableEvent"),

    ---@params: `player: Player, storeName: string`
    RToAwardLeaderboardRank = Instance.new("BindableEvent"),

    ---@params: `playerName: string`
    PlayerDied = Instance.new("BindableEvent"),

    ---@params: `player: Player, option: string, newMember: string`
    PartyInvite = Instance.new("BindableEvent"),

    ---@params: `player: Player, questId: string`
    QuestCompleted = Instance.new("BindableEvent"),

    ---@params: `msg: string`
    RToSendMsgToDiscord = Instance.new("BindableEvent"),

    ---@params: `player: Player`
    RToCheckPlayerBadges = Instance.new("BindableEvent"),

    ---@params: `id: string`,
    NPCChatFinished = Instance.new("BindableEvent"),
}