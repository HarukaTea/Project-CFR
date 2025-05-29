--!nocheck

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB
local fromHex = Color3.fromHex

local AssetBook = {}

AssetBook.TweenInfos = {
	fourHalf = newTweenInfo(0.05),
	threeHalf = newTweenInfo(0.15),
	twiceHalf = newTweenInfo(0.2),
	onceHalf = newTweenInfo(0.3),
	half = newTweenInfo(0.5),
	halfBack = newTweenInfo(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = newTweenInfo(0.75),
	threeHalfOne = newTweenInfo(0.9),
	one = newTweenInfo(1),
	oneHalf = newTweenInfo(1.5),
	two = newTweenInfo(2),
	four = newTweenInfo(4),
	six = newTweenInfo(6),
	fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}


AssetBook.StackableItemTypes = { "Accessory", "Weapon" }


AssetBook.ExtraIcons = {
	Null = "rbxassetid://1637592633",
	Unknown = "rbxassetid://114332372182764",
	Marked = "rbxassetid://94557907177407"
}


AssetBook.TierColors = {
	fromRGB(0, 255, 0),
	fromRGB(49, 226, 236),
	fromRGB(214, 96, 253),
	fromRGB(250, 250, 65),
	fromRGB(255, 22, 57),
}
AssetBook.TierColorsType2 = {
	fromHex('#626771'),
	fromHex('#52836f'),
	fromHex('#57789c'),
	fromHex('#6f639f'),
	fromHex('#ac712c'),
}

AssetBook.QuestTypeColors = {
	Main = Color3.fromHex('#2ed573'),
	Side = Color3.fromHex('#fdcb6e'),
	Town = Color3.fromHex('#a29bfe')
}


AssetBook.ItemEffectIcons = {
	CanLight = "rbxassetid://2965771738",
	CanMine = "rbxassetid://12118509077",
	CanClimb = "rbxassetid://119170658838472",

	CD = "rbxassetid://81749788783510",
	MaxMana = "rbxassetid://131740194041023",
	CriChance = "rbxassetid://73146024586376",
	ATK = "rbxassetid://2965862892",
	Speed = "rbxassetid://4824421210",
	Magic = "rbxassetid://2965863231",
	MaxHealth = "rbxassetid://73706423714397",

	Intensity = "rbxassetid://4824421210",
	CriDMG = "rbxassetid://73146024586376",

	Focus = "rbxassetid://132943384940547",
	Combo = "rbxassetid://91123652494859",
	Stack = ""
}
AssetBook.ItemEffectIcons.Mana = AssetBook.ItemEffectIcons.MaxMana


AssetBook.ItemEffectIconColors = {
	CriChance = fromHex('#ffeaa7'),
	MaxHealth = fromHex('#2ed573'),
}
AssetBook.ItemEffectNames = {
	CD = "CD Time",
	Mana = "Mana Cost",
	MaxManaEx = "Mana",
	CriChanceEx = "Critical Chance",
	CriDMGEx = "Critical DMG",
	ATK = "ATK",
	SpeedEx = "Speed",
	MagicEx = "Magic",
	MaxHealthEx = "Health",
	IntensityEx = "Intensity",
}
AssetBook.ItemEffectIsPercentage = {
	CriChanceEx = true,
	CriDMGEx = true,
	IntensityEx = true,
}


AssetBook.PromptIcons = {
	Default = "rbxassetid://13124035950",
	Market = "rbxassetid://118291405899454",
	Chest = "rbxassetid://89067747729088"
}
AssetBook.PromptIcons.Chat = AssetBook.PromptIcons.Default

AssetBook.PreloadAssets = {
	Images = {
		"rbxassetid://91832243782412",
		"rbxassetid://82804434423267",
		"rbxassetid://72813522573875",
	}
}



return AssetBook
