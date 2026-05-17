local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = require(ReplicatedStorage.Constants.Typing.UserSettings)

type RangeSetting = Typing.RangeSetting
type BooleanSetting = Typing.BooleanSetting
type EnumSetting = Typing.EnumSetting
type Color3Setting = Typing.Color3Setting
type ContainerSetting = Typing.ContainerSetting

local enum = {}

enum.settingTypes = {
    "Range",
    "Boolean",
    "Enum",
    "Color3",
    "Container",
}

--- Do not use this. Go to `ReplicatedStorage.Shared.API.UserSettings` instead.
--- The typing heavily enforces correct format, so watch out for any typo.
--- The string values don't really matter since the database will store a number instead of a string.
enum.details = {
    general = {
        combatMode = {
            label = "Combat Mode",
            description = "Choose your preferred combat stance.",
            type = "Enum",
            options = {
                "Public",
                "Party",
                "Friends Only",
            },
            default = "Public",
        } :: EnumSetting,
    },

    graphics = {
        disableParticles = {
            label = "Disable Particles",
            description = "",
            type = "Boolean",
            default = false
        } :: BooleanSetting,

        lowDetailMode = {
            label = "Low-Detail Mode",
            description = "Reduces visual quality to improve performance on slower devices.",
            type = "Boolean",
            default = false,
        } :: BooleanSetting,

        rainEffect = {
            label = "Rain Effect",
            description = "Toggles the visibility of weather-related rain particles.",
            type = "Boolean",
            default = true,
        } :: BooleanSetting,

        shadows = {
            label = "Shadows",
            description = "Toggles dynamic shadows in the world.",
            type = "Boolean",
            default = true,
        } :: BooleanSetting,
    },

    interface = {
        uiScale = {
            label = "UI Scale",
            description = "Adjusts the overall size of the user interface.",
            type = "Range",
            min = 0.5,
            max = 1.5,
            step = 0.1,
            default = 1,
        } :: RangeSetting,

        hideUi = {
            label = "Hide UI",
            description = "Toggles the visibility of all on-screen interface elements.",
            type = "Boolean",
            default = false,
        } :: BooleanSetting,
    },

    preferences = {
        otherPlayerVisibility = {
            label = "Player Visibility", -- Label of the settings, mandatory.
            description = "", -- Description of the settings, mandatory.
            type = "Enum", -- Setting type, mandatory.
            options = { -- In the database, the number keys will be used for storing value. (1, 2, 3, ...)
                "Everyone", -- Has to be capitalised on every word.
                "Party Only",
                "Disabled",
            },
            default = "Everyone", -- This must be within the boundary/options; no typo allowed.
        } :: EnumSetting,

        partyInvites = {
            label = "Party Invites",
            description = "",
            type = "Enum",
            options = {
                "Disabled",
                "Friends Only",
                "Everyone",
            },
            default = "Everyone",
        } :: EnumSetting,

        guiNumberDisplay = {
            label = "Number Display",
            description = "",
            type = "Container",
            settings = { -- a map where k is a string, and v is either boolean, range, color3, or enum setting. No nested containers allowed.
                selfNumberDisplay = {
                    label = "Your Number Display",
                    description = "This will determine the visibility of your damage, heals, damage taken, etc.",
                    type = "Enum",
                    options = {
                        "Visible",
                        "Opaque",
                        "Invisible",
                    },
                    default = "Visible",
                } :: EnumSetting,

                participantNumberDisplay = {
                    label = "Other Participant's Number Display",
                    description = "",
                    type = "Enum",
                    options = {
                        "Visible",
                        "Opaque",
                        "Invisible",
                    },
                    default = "Visible",
                } :: EnumSetting,
            }
        } :: ContainerSetting,

    },

    audio = {
        musicVolume = {
            label = "Music Volume",
            description = "Adjusts the volume of background music.",
            type = "Range",
            min = 0,
            max = 100,
            step = 1,
            default = 50,
        } :: RangeSetting,

        footstepVolume = {
            label = "Foostep Volume",
            description = "Adjusts the volume of player and NPC walking sounds.",
            type = "Range",
            min = 0,
            max = 100,
            step = 1,
            default = 50,
        } :: RangeSetting,

        ambientVolume = {
            label = "Ambient Volume",
            description = "Adjusts the volume of environmental background noise.",
            type = "Range",
            min = 0,
            max = 100,
            step = 1,
            default = 50,
        } :: RangeSetting,

        sfxVolume = {
            label = "SFX Volume",
            description = "Adjusts the volume of environmental background noise.",
            type = "Range",
            min = 0,
            max = 100,
            step = 1,
            default = 50,
        } :: RangeSetting,
    },

    keyBindings = {
        
    },
}

return table.freeze(enum)