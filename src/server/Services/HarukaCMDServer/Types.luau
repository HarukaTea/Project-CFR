
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

    new: () -> HarukaCMDClass,
    Init: (self: HarukaCMDClass) -> nil,
    AddCommandBook: (self: HarukaCMDClass, commandBook: { CommandJSON }) -> nil,

    _InitRequestListenTracker: (self: HarukaCMDClass) -> nil,
    _InitCommandExecutionTracker: (self: HarukaCMDClass) -> nil,

    _ValidateCmd: (realCMD: CommandJSON, cmdArgs: { string }) -> (boolean, CommandJSON | {}),

    Commands: { CommandJSON },
    Add: <T>(item: T) -> T,
    Empty: () -> nil,
}

return nil