local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local t = require(ReplicatedStorage.Packages.t)

type BaseSetting = {
    label: string,
    description: string,
    deviceMode: "Mobile" | "PC" | "Console" | "All",
}

export type AllowedTypes = "Range" | "Enum" | "Color3" | "Boolean"
export type AllTypes = AllowedTypes | "Container"

export type RangeSetting = BaseSetting & {
    type: "Range",
    min: number,
    max: number,
    --- Defaults to 1
    step: number?,
    default: number,
}

export type EnumSetting = BaseSetting & {
    type: "Enum",
    options: { string },
    default: string,
}

export type Color3Setting = BaseSetting & {
    type: "Color3",
    default: { r: number, g: number, b: number }, --- Map of 3 values (r, g, b)
}

export type BooleanSetting = BaseSetting & {
    type: "Boolean",
    default: boolean,
}

--- Used for combining settings that are very similar to each other.
export type ContainerSetting = BaseSetting & {
    type: "Container",
    settings: {
        [string]: AllEntries,
    },
}

export type AllowedEntries = RangeSetting | EnumSetting | Color3Setting | BooleanSetting
export type AllEntries = AllowedEntries | ContainerSetting

export type SettingDetails = {
    [string]: {
        [string]: RangeSetting | EnumSetting | Color3Setting | BooleanSetting,
    }
}

local colorMinNumT = t.numberMin(0)
local colorMaxNumT = t.numberMax(255)
local colorRangeT = t.every(t.integer, colorMinNumT, colorMaxNumT)
local color3T = t.strictInterface({
    r = colorRangeT,
    g = colorRangeT,
    b = colorRangeT,
})

local typing = {}

typing.allowedTypes = {
    range = t.literal("Range"),
    enum = t.literal("Enum"),
    color3 = t.literal("Color3"),
    boolean = t.literal("Boolean"),
    container = t.literal("Container"),
}

typing.deviceModes = {
    mobile = t.literal("Mobile"),
    pc = t.literal("PC"),
    console = t.literal("Console"),
    all = t.literal("All")
}

typing.allowedTypesT = t.union(
    unpack(TableUtil.Values(typing.allowedTypes))
)

typing.baseSettingT = t.interface({
    label = t.string,
    description = t.string,
})

typing.rangeSettingT = t.intersection(typing.baseSettingT, t.interface({
    type = typing.allowedTypes.range,
    min = t.number,
    max = t.number,
    step = t.optional(t.number),
    default = t.number,
}))

typing.enumSettingT = t.intersection(typing.baseSettingT, t.interface({
    type = typing.allowedTypes.enum,
    options = t.array(t.string),
    default = t.string,
}))

typing.color3SettingT = t.intersection(typing.baseSettingT, t.interface({
    type = typing.allowedTypes.color3,
    default = color3T,
}))

typing.booleanSettingT = t.intersection(typing.baseSettingT, t.interface({
    type = typing.allowedTypes.boolean,
    default = t.boolean,
}))

typing.containerSettingT = t.intersection(typing.baseSettingT, t.interface({
    type = typing.allowedTypes.container,
    settings = t.map(t.string, t.union(
        typing.rangeSettingT,
        typing.enumSettingT,
        typing.color3SettingT,
        typing.booleanSettingT
    )),
}))

typing.typeCheckers = {
    Range = typing.rangeSettingT,
    Enum = typing.enumSettingT,
    Color3 = typing.color3SettingT,
    Boolean = typing.booleanSettingT,
    Container = typing.containerSettingT,
}

--- Only `Color3` returns a second value.
typing.valueCheckers = {
    Range = t.number,
    Enum = t.number, -- The value will be converted to number in UI
    Color3 = color3T,
    Boolean = t.boolean,
} :: { [AllowedTypes]: (value: any) -> (boolean, string?) }

typing.allowedEntriesT = t.union(
    unpack(TableUtil.Values(TableUtil.Filter(typing.typeCheckers, function(value, key): boolean
        return key ~= "Container"
    end)))
)

typing.deviceModesT = t.union(
    unpack(TableUtil.Values(typing.deviceModes))
)

typing.allEntriesT = t.union(typing.allowedEntriesT, typing.containerSettingT)

return table.freeze(typing)