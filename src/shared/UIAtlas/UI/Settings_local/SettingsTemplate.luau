--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Signal = require(RepS.HarukaShared.Shared.Signal)


local template = {
    Sounds = {
        PanelTitle = "Sounds",
		LayoutOrder = 3,

		Includes = {
			MusicVolume = {
				OptionTitle = "Music Volume",
				Type = "Slider",
				LayoutOrder = 1,

				Min = 0,
				Max = 2,
				DefaultValue = 1,
				Increasement = 0.1,

				ValChanged = Signal.new()
			},
            SFXVolume = {
				OptionTitle = "SFX Volume",
				Type = "Slider",
				LayoutOrder = 2,

				Min = 0,
				Max = 2,
				DefaultValue = 1.2,
				Increasement = 0.1,

				ValChanged = Signal.new()
			}
		}
    },
	Interface = {
		PanelTitle = "Interface",
		LayoutOrder = 2,

		Includes = {
			UIScale = {
				OptionTitle = "UI Scale",
				Type = "Slider",
				LayoutOrder = 1,

				Min = 0.8,
				Max = 1.2,
				DefaultValue = if UserInputService.TouchEnabled then 1.1 else 1,
				Increasement = 0.1,

				ValChanged = Signal.new()
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
			GlobalShadows = {
				OptionTitle = "Shadows",
				Type = "Switcher",
				LayoutOrder = 3,

				DefaultValue = true,
			},
		}
	}
}


return template
