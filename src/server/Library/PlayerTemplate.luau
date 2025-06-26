

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
            LastSeen = "InitusBay",

            LastJoinedDateTime = DateTime.now():ToIsoDate(),


            ItemsSQL = {},
            EquippingItemsSQL = {},
            QuestsV2 = {},
            Settings = {},

            CombatWonTimes = 0,
        }
    },

    JoinDateTime = DateTime.now():ToIsoDate(),


    GamepassPurchaseLogs = {},
    DevProductsPurchaseLogs = {}
}
playerStats.Slot2 = table.clone(playerStats.Slot1)
playerStats.Slot3 = table.clone(playerStats.Slot1)


return table.clone(playerStats)
