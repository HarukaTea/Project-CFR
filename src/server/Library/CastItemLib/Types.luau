

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

    [string]: (player: Player, char: Model, extraInfo: {
        CostManaFunc: () -> nil
    }) -> number?
}


return nil