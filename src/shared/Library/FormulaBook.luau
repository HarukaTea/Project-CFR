
local LOG_E = 2.71828

local formulas = {
    ENEMY_MAX_LEVEL = 950,
    PLAYER_MAX_LEVEL = 185,
    PLAYER_POINT_PER_LEVEL = 2,
    PLAYER_MAX_DEX_POINTS = 50,


    PlayerLevelCurveCal = function(props: {
        Level: number
    })
        if props.Level <= 15 then
            return math.floor(15 * props.Level)

        elseif props.Level > 15 and props.Level <= 45 then
            return math.floor(55 * props.Level)

        elseif props.Level > 45 and props.Level <= 100 then
            return math.floor(99 * props.Level)

        elseif props.Level > 100 and props.Level <= 170 then
            return math.floor(135 * props.Level)

        elseif props.Level > 170 and props.Level <= 180 then
            return math.floor(188 * props.Level)

        elseif props.Level > 180 then
            return math.floor(233 * props.Level)
        end
    end,


    -- // enemy curve calculation

    EnemyEXPCurveCal = function(props: {
        Level: number
    })
        return math.floor(30 * props.Level)
    end,


    EnemyHealthCurveCal = function(props: {
        Level: number,
        IsBoss: boolean,
        EnvironmentBonus: number?
    })
        props.EnvironmentBonus = props.EnvironmentBonus or 1

        local f = 115 * props.Level * 1.599 ^ 1.1599 - 50

        return math.ceil(f * props.EnvironmentBonus)
    end,


    EnemyDMGCurveCal = function(props: {
        Level: number,
        EnvironmentBonus: number?
    })
        local f = 3.5 * props.Level

        return math.ceil(f)
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
        return math.floor(props.BaseHealth + 35 * props.HealthPoints)
    end,

    PlayerDMGCurveCal = function(props: {
        BaseDMG: number,
        DMGPoints: number,

        ATKType: string
    })

        local baseFactor = 1.1
        if props.ATKType == "Max" then
            baseFactor = 1.2
        end
        local extra = 1 + ((props.DMGPoints * baseFactor) / 100)


        return math.ceil(props.BaseDMG * extra)
    end,


    PlayerMagicCurveCal = function(props: {
        BaseMagic: number,
        MagicPoints: number
    })
        local extra = 1 + ((props.MagicPoints * 1.4) / 100)

        return math.ceil(props.BaseMagic * extra)
    end,


    PlayerShieldCurveCal = function(props: {
        BaseShield: number,
        Level: number,
    })
        return math.floor(props.BaseShield + 3 * math.log(props.Level + 1, LOG_E))
    end,

    PlayerManaCurveCal = function(props: {
        BaseMana: number,
        ManaPoints: number
    })
        return math.floor(props.BaseMana + 25 * props.ManaPoints)
    end,

    PlayerCriChanceCurveCal = function(props: {
        BaseCritChance: number,
        DexPoints: number
    })
        return math.floor(props.BaseCritChance + math.min(60, math.floor(props.DexPoints * 0.8)))
    end,

    PlayerDodgeChanceCurveCal = function(props: {
        BaseDodgeChance: number,
        DexPoints: number
    })
        return math.floor(props.BaseDodgeChance + math.min(20, math.floor(props.DexPoints / 2.75)))
    end,



    --// items

    ItemUpgradeCurveCal = function(props: {
        Stat: string,
        Val: number
    })
        local stat = props.Stat
        local level = props.Level
        local val = props.Val

        val = val or 0
        if stat == nil or level == nil then
            return val
        end


        return val + math.floor(val * 0.11)

        --// TODO: make intensity useful
    end

}


return formulas
