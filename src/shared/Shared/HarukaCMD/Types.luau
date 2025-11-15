
export type CallbackProps = {
    Executor: Player,
    Args: { any },

    ResolveObj: () -> nil
}


export type CommandArgJSON = {
    Name: string,
    Type: string,

    ShouldBeInteger: boolean?,
    RangeMin: number?,
    RangeMax: number?,

    EnumItems: { string }?,
}


export type CommandJSON = {
    Name: string,
    Alias: string,
    Args: { CommandArgJSON },
    RankReq: number,

    Callback: (props: CallbackProps) -> nil
}


export type HarukaCMDClass = {
    __index: HarukaCMDClass,

    ExecuteCommandFunc: () -> nil,
    AutoCompleteFunc: () -> nil,
    ArgAutoCompleteFunc: () -> nil,


    -- i know there are more but im lazy to type them all out
}



return nil