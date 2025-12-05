
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)


export type IncludesJSON = {
	OptionTitle: string,
	Type: string,
	LayoutOrder: number,
	Min: number,
	Max: number,
	DefaultValue: any,
	AllowDecimals: boolean,

	ValChanged: Signal.SignalClass,
}

export type SettingsJSON = {
	[string]: {
		PanelTitle: string,
		LayoutOrder: number,

		Includes: {
			[string]: IncludesJSON
		}
	}
}


local template = {
    Sounds = {
        PanelTitle = "Sounds",
		LayoutOrder = 4,

		Includes = {
			MusicVolume = {
				OptionTitle = "Music Volume",
				Type = "Slider",
				LayoutOrder = 1,

				Min = 0,
				Max = 2,
				DefaultValue = 1,
				AllowDecimals = true,

				ValChanged = Signal.new()
			},
            SFXVolume = {
				OptionTitle = "SFX Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 1.2,

				ValChanged = Signal.new()
			},
			FootstepVolume = {
				OptionTitle = "Footstep Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 0.9,

				ValChanged = Signal.new()
			},
			AmbientVolume = {
				OptionTitle = "Ambient Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 0.8,

				ValChanged = Signal.new()
			}
		}
    },
	Interface = {
		PanelTitle = "Interface",
		LayoutOrder = 3,

		Includes = {
			UIScale = {
				OptionTitle = "UI Scale",
				Type = "Slider",
				LayoutOrder = 1,
				AllowDecimals = true,

				Min = 0.8,
				Max = 1.2,
				DefaultValue = if HarukaLib:GetAccurateDevice() == "Phone" or HarukaLib:GetAccurateDevice() == "Tablet" then 1.1 else 1,

				ValChanged = Signal.new()
			},
			HideUI = {
				OptionTitle = "Hide UI",
				Type = "Switcher",
				LayoutOrder = 2,

				DefaultValue = false,
			},
		}
	},
	Game = {
		PanelTitle = "Game",
		LayoutOrder = 1,

		Includes = {
			LowDetailMode = {
				OptionTitle = "Low-Detail Mode",
				Type = "Switcher",
				LayoutOrder = 1,

				DefaultValue = false
			},
			GlobalShadows = {
				OptionTitle = "Shadows",
				Type = "Switcher",
				LayoutOrder = 3,

				DefaultValue = true,
			},
			RainEffect = {
				OptionTitle = "Rain Effect",
				Type = "Switcher",
				LayoutOrder = 5,

				DefaultValue = true,
			},
			CombatMode = {
				OptionTitle = "Combat Mode",
				Type = "Dropdown",
				LayoutOrder = 7,
				DropdownOptions = { "Solo", "Public", "Party" },

				DefaultValue = "Public",
			},
			AllowPartyInvites = {
				OptionTitle = "Allow Party Invites",
				Type = "Switcher",
				LayoutOrder = 6,

				DefaultValue = true,
			},
		}
	},
	KeybindsPC = {
		PanelTitle = "Keybinds / PC",
		LayoutOrder = 5,

		Includes = KeybindsBook.PC
	},
	KeybindsConsole = {
		PanelTitle = "Keybinds / Xbox",
		LayoutOrder = 6,

		Includes = KeybindsBook.Console
	}
}


return template