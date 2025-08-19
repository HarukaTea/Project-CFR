--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Signal = require(RepS.HarukaShared.Shared.Signal)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)


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
				DefaultValue = if UserInputService.TouchEnabled then 1.1 else 1,

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
	Graphics = {
		PanelTitle = "Graphics",
		LayoutOrder = 1,

		Includes = {
			LowDetailMode = {
				OptionTitle = "Low-Detail Mode",
				Type = "Switcher",
				LayoutOrder = 1,

				DefaultValue = false
			},
			Trees = {
				OptionTitle = "Trees",
				Type = "Switcher",
				LayoutOrder = 2,

				DefaultValue = true,
			},
			GlobalShadows = {
				OptionTitle = "Shadows",
				Type = "Switcher",
				LayoutOrder = 3,

				DefaultValue = true,
			},
			WindEffect = {
				OptionTitle = "Wind Effect",
				Type = "Switcher",
				LayoutOrder = 4,

				DefaultValue = true,
			},
			RainEffect = {
				OptionTitle = "Rain Effect",
				Type = "Switcher",
				LayoutOrder = 5,

				DefaultValue = true,
			},
			EntityRenderDistance = {
				OptionTitle = "Enemy Render Distance",
				Type = "Slider",
				LayoutOrder = 7,
				AllowDecimals = false,

				Min = 159,
				Max = 999,
				DefaultValue = 189,

				ValChanged = Signal.new()
			},
			FocusRenderDistance = {
				OptionTitle = "Text Render Distance",
				Type = "Slider",
				LayoutOrder = 8,
				AllowDecimals = false,

				Min = 159,
				Max = 999,
				DefaultValue = 486,

				ValChanged = Signal.new()
			},
			TreeRenderDistance = {
				OptionTitle = "Tree Render Distance",
				Type = "Slider",
				LayoutOrder = 9,
				AllowDecimals = false,

				Min = 159,
				Max = 999,
				DefaultValue = 888,

				ValChanged = Signal.new()
			},
			FlowerRenderDistance = {
				OptionTitle = "Flower Render Distance",
				Type = "Slider",
				LayoutOrder = 9,
				AllowDecimals = false,

				Min = 159,
				Max = 999,
				DefaultValue = 555,

				ValChanged = Signal.new()
			}
		}
	},
	Game = {
		PanelTitle = "Game",
		LayoutOrder = 2,

		Includes = {
			CombatMode = {
				OptionTitle = "Combat Mode",
				Type = "Dropdown",
				LayoutOrder = 1,
				DropdownOptions = { "Solo", "Public", "Party" },

				DefaultValue = "Public",
			},
			AllowPartyInvites = {
				OptionTitle = "Allow Party Invites",
				Type = "Switcher",
				LayoutOrder = 2,

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
