
local RepS = game:GetService("ReplicatedStorage")

local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

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
    EggFoundV1: number,
    EggsV1: { [string]: boolean },

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

local playerStats = {
    Slot1 = {
        Attrs = {
            Level = 1,

            EXP = 0,

            Gold = 0,
            Astra = 0,

            ClassLevel = {},
            ClassEXPV2 = {},
            ClassPerkPoints = {},

            PerkPoints = 2,
            STRPoints = 0,
            INTPoints = 0,
            VITPoints = 0,
            DEXPoints = 0,

            TalentPoints = 1,
            Talents = {},

            PlayTime = 0,
            Class = "Chain",
            LastSeen = "InitusBay",

            LastJoinedDateTime = DateTime.now():ToIsoDate(),

            ItemsSQL = {},
            EquippingItemsSQL = {},
            QuestsV3 = {},

            CombatWonTimes = 0,

            Title = "Explorer",
            AbyssDropPity = 0,
            FavActionDone = false,
            IsInGroup = false,

            --// event fields
            HalloweenCandy = 0,
            IceCandy = 0,
            ClaimedChristmasDonation = false,
            ClaimedHalloweenDonation = false,
            ChristmasGiftFound = 0,
            ChristmasGifts = {},
            EggFoundV1 = 0,
            EggsV1 = {},

            --// migration fields
            EXPFormulaV2Given = false,
            IceCandyV1Given = false,
        }
    },

    JoinDateTime = DateTime.now():ToIsoDate(),

    GamepassPurchaseLogs = {},
    DevProductsPurchaseLogs = {},

    Settings = {}
}

--// additional fields
for class: string, _ in ClassBook do
    playerStats.Slot1.Attrs.ClassLevel[class] = 1
    playerStats.Slot1.Attrs.ClassEXPV2[class] = 0
    playerStats.Slot1.Attrs.ClassPerkPoints[class] = 2
end

playerStats.Slot2 = HarukaLib.TableUtils.DeepCopy(playerStats.Slot1)
playerStats.Slot3 = HarukaLib.TableUtils.DeepCopy(playerStats.Slot1)

return playerStats