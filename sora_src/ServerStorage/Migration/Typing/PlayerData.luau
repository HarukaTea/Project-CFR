export type PlayerItemDataJSON = {
    ItemId: string,
    Amount: number,
    UniqueId: string,
    ItemStat: string,
    IsFav: boolean,
    IsLocked: boolean,

    --// legacy fields
    IsV2ItemStat: boolean?,
    Level: number?
}
export type PlayerEquippingItemDataJSON = {
    ItemId: string,
    UniqueId: string
}
export type PlayerQuestDataJSON = {
    Completed: boolean,
    Objectives: { [string]: number }
}

export type PlayerDataJSON = {
    Level: number,
    EXP: number,
    Gold: number,
    Astra: number,

    PerkPoints: number,
    STRPoints: number,
    INTPoints: number,
    VITPoints: number,
    DEXPoints: number,
    PlayTime: number,
    Class: string,
    LastSeen: string,
    LastJoinedDateTime: string,
    ItemsSQL: {
        [string]: PlayerItemDataJSON
    },
    EquippingItemsSQL: {
        [string]: PlayerEquippingItemDataJSON
    },
    QuestsV3: {
        [string]: PlayerQuestDataJSON
    },
    CombatWonTimes: number,

    --// new fields
    Title: string,
    AbyssDropPity: number,
    FavActionDone: boolean,
    IsInGroup: boolean,
    ClassLevel: { [string]: number },
    ClassEXPV2: { [string]: number },
    ClassPerkPoints: { [string]: number },

    --// legacy fields
    Settings: {}?,
    Talents: {}?,
    TalentPoints: number,

    -- event fields
    HalloweenCandy: number,
    IceCandy: number,
    ClaimedChristmasDonation: boolean,
    ClaimedHalloweenDonation: boolean,
    ChristmasGiftFound: number,
    ChristmasGifts: { [string]: boolean },

    -- migration fields
    EXPFormulaV2Given: boolean?,
    IceCandyV1Given: boolean?
}

export type GamepassPurchaseLogJSON = {
    Purchased: boolean,
    PurchaseDateTime: string,
    PurchasedPrice: number
}

export type PlayerMainDataJSON = {
    JoinDateTime: string,
    GamepassPurchaseLogs: { [string]: GamepassPurchaseLogJSON },
    DevProductsPurchaseLogs: { GamepassPurchaseLogJSON },
    Settings: {
        [string]: any
    }
}

export type JSON = {
    Slot1: {
        Attrs: PlayerDataJSON
    },
    Slot2: {
        Attrs: PlayerDataJSON
    },
    Slot3: {
        Attrs: PlayerDataJSON
    },
} & PlayerMainDataJSON

return {}