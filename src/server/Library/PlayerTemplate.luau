

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
