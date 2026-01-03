
export type Dict = {[string]: any}

export type LocationInfo = {
    Name: string,

    Music: string,
    CombatMusic: string,

    LightingInfo: Dict,
    AtmosphereInfo: {
        [string]: Dict
    },

    RainLevel: number?,
    BaseSpeed: number?,
}



return {}