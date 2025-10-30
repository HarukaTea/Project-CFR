
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
    Id: string,
    QuestState: string,
    ObjectiveProgress: {
        [string]: any
    }
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
    DEFPoints: number,
    TalentPoints: number,
    Talents: {},
    PlayTime: number,
    Class: string,
    ClassVariant: string,
    StarterClass: string,
    LastSeen: string,
    LastJoinedDateTime: string,
    ItemsSQL: {
        [string]: PlayerItemDataJSON
    },
    EquippingItemsSQL: {
        [string]: PlayerEquippingItemDataJSON
    },
    QuestsV2: {
        [string]: PlayerQuestDataJSON
    },
    CombatWonTimes: number,

    --// legacy fields
    Settings: {}?
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



local playerStats = {
    Slot1 = {
        Attrs = {
            Level = 1,

            EXP = 0,

            Gold = 0,
            Astra = 0,

            PerkPoints = 2,
            STRPoints = 0,
            INTPoints = 0,
            VITPoints = 0,
            DEXPoints = 0,
            DEFPoints = 0,

            TalentPoints = 1,
            Talents = {},

            PlayTime = 0,
            Class = "Chain",
            ClassVariant = "None",
            StarterClass = "Chain",
            LastSeen = "InitusBay",

            LastJoinedDateTime = DateTime.now():ToIsoDate(),

            ItemsSQL = {},
            EquippingItemsSQL = {},
            QuestsV2 = {},

            CombatWonTimes = 0,
        }
    },

    JoinDateTime = DateTime.now():ToIsoDate(),


    GamepassPurchaseLogs = {},
    DevProductsPurchaseLogs = {},

    Settings = {}
}
playerStats.Slot2 = table.clone(playerStats.Slot1)
playerStats.Slot3 = table.clone(playerStats.Slot1)


return table.clone(playerStats)