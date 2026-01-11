
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.HarukaShared.Shared.Fusion)

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
    RefreshCommandBookFunc: () -> nil,

    new: () -> HarukaCMDClass,
    Init: (self: HarukaCMDClass) -> nil,
    Destroy: (self: HarukaCMDClass) -> nil,

    _InitUI: (self: HarukaCMDClass) -> nil,
    _ListenUITracker: (self: HarukaCMDClass) -> nil,
    _ListenInputTracker: (self: HarukaCMDClass) -> nil,

    scope: Fusion.Scope,

    Player: Player,
    IsShown: Fusion.Value<boolean>,
    CMDInput: Fusion.Value<string>,
    CMDSearchInput: Fusion.Value<string>,
    CMDIntellisense: Fusion.Value<{ CommandJSON }>,
    ItemIntellisense: Fusion.Value<{ [string]: any }>,
    Rank: number,

    AutoCompletePointer: Fusion.Value<number>,
    ItemAutoCompletePointer: Fusion.Value<number>,

    ExtraArgs: { Fusion.Value<string> },
    ExtraArgsSearch: { Fusion.Value<string> },

    Commands: { CommandJSON },
    Add: <T>(item: T) -> T,
    Empty: () -> nil,
}

return nil