
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)

local formulas = {
    ENEMY_MAX_LEVEL = 1599,
    PLAYER_MAX_LEVEL = 200,
    PLAYER_MAX_CLASS_LEVEL = 15,
    PLAYER_POINT_PER_LEVEL = 2,
    PLAYER_MAX_DEX_POINTS = 50,

    FAIRLY_BIG_NUMBER = 1599 * 40 * 15,

    MAX_ITEM_LIMIT = 9999,

    EXPEvent = 1,


    PlayerLevelCurveCal = function(props: {
        Level: number
    })
        return math.floor(11 * (props.Level ^ 1.85))
    end,
    PlayerClassLevelCurveCal = function(props: {
        Level: number,
    })
        return math.floor(80 * (props.Level ^ 1.4))
    end,


    -- // enemy curve calculation

    EnemyEXPCurveCal = function(props: {
        Level: number
    })
        return math.floor(12 * (props.Level ^ 1.35))
    end,
    EnemyClassEXPCurveCal = function(props: {
        Level: number
    })
        return math.floor(3 * (props.Level ^ 1.1))
    end,


    EnemyHealthCurveCal = function(props: {
        Level: number,
        EnvironmentBonus: number?
    })
        props.EnvironmentBonus = props.EnvironmentBonus or 1

        local base: number = 1
        if props.Level < 50 then
            base = 25 + 55 * props.Level
        elseif props.Level >= 50 then
            base = 500 + 255 * props.Level
        end
        return math.ceil(base * props.EnvironmentBonus)
    end,


    EnemyDMGCurveCal = function(props: {
        Level: number,
        EnvironmentBonus: number?
    })
        props.EnvironmentBonus = props.EnvironmentBonus or 1

        local f = 8 + 3 * props.Level
        return math.ceil(f * props.EnvironmentBonus)
    end,

    EnemyGoldCurveCal = function(props: {
        Level: number,
    })
        return math.floor(5 * props.Level)
    end,


    --// player curve calculation

    PlayerHealthCurveCal = function(props: {
        BaseHealth: number,
        HealthPoints: number
    })
        return math.floor(props.BaseHealth + 75 * props.HealthPoints)
    end,

    PlayerDMGCurveCal = function(props: {
        BaseDMG: number,
        DMGPoints: number,

        ATKType: string
    })

        local baseFactor = 30
        if props.ATKType == "Max" then
            baseFactor = 50
        end
        local extra = 1 + ((props.DMGPoints * baseFactor) / 100)


        return math.ceil(props.BaseDMG * extra)
    end,


    PlayerMagicCurveCal = function(props: {
        BaseMagic: number,
        MagicPoints: number
    })
        local extra = 1 + ((props.MagicPoints * 80) / 100)

        return math.ceil(props.BaseMagic * extra)
    end,


    PlayerCriChanceCurveCal = function(props: {
        BaseCritChance: number,
        DexPoints: number
    })
        return math.floor(props.BaseCritChance + math.min(40, math.floor(props.DexPoints * 0.8)))
    end,


    --// items

    ItemUpgradeCurveCal = function(val: number)
        val = val or 0

        return val + math.floor(val * 0.11)
    end

}


if game.GameId ~= AssetBook.CFUniverseId_Main then
    formulas.EXPEvent = 80
end
if formulas.EXPEvent > 1 then
    print("EXP Event Enabled")
end


return formulas