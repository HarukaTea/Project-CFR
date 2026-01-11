
local RepS = game:GetService("ReplicatedStorage")

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

	ValChanged: BindableEvent,
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

local device = HarukaLib:GetAccurateDevice()

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

				ValChanged = Instance.new("BindableEvent")
			},
            SFXVolume = {
				OptionTitle = "SFX Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 1.2,

				ValChanged = Instance.new("BindableEvent")
			},
			FootstepVolume = {
				OptionTitle = "Footstep Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 0.9,

				ValChanged = Instance.new("BindableEvent")
			},
			AmbientVolume = {
				OptionTitle = "Ambient Volume",
				Type = "Slider",
				LayoutOrder = 2,
				AllowDecimals = true,

				Min = 0,
				Max = 2,
				DefaultValue = 0.8,

				ValChanged = Instance.new("BindableEvent")
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
				DefaultValue = if device == "Phone" or device == "Tablet" then 1.15 else 1,

				ValChanged = Instance.new("BindableEvent")
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

				DefaultValue = if device == "Phone" or device == "Tablet" then true else false,
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