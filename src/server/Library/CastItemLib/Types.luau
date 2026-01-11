
export type Dict = { [string]: any } & {
    CostManaFunc: (char: Model) -> boolean
}

export type CastItemLib = {
    _preCheck: (props: {
        ReqCombat: boolean,
        ReqEnemy: boolean
    }, data: {
        ItemId: string,
        Player: Player,
        Char: Model
    }) -> nil,

    _eatSoundFunc: (char: Model, func: () -> nil) -> nil,
    _drinkSoundFunc: (char: Model, func: () -> nil) -> nil,

    [string]: (player: Player, char: Model, extraInfo: Dict) -> number?
}

return nil