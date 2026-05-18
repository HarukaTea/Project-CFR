local enum = {}

enum.statPointsPerLevel = 2

--- full name of each stat must be capitalised when displayed.
enum.basicStats = {
    str = {
        abbv = "str",
        full = "strength",
    },

    agi = {
        abbv = "agi",
        full = "agility",
    },

    int = {
        abbv = "int", -- we don't have this, sorry.
        full = "intelligence",
    },

    vit = {
        abbv = "vit",
        full = "vitality",
    },

    dex = {
        abbv = "dex",
        full = "dexterity",
    },
}

return table.freeze(enum)