--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local newTweenInfo = TweenInfo.new
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


AssetBook.ItemTierColors = {
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
	CanYellowLight = "rbxassetid://2965771738",
	CanBlueLight = "rbxassetid://2965771738",
	CanLight = "rbxassetid://2965771738",
	CanMine = "rbxassetid://12118509077",
	CanClimb = "rbxassetid://119170658838472",

	CD = "rbxassetid://81749788783510",
	CriChance = "rbxassetid://73146024586376",
	ATK = "rbxassetid://2965862892",
	Speed = "rbxassetid://128019227796527",
	Magic = "rbxassetid://2965863231",
	MaxHealth = "rbxassetid://104142948728530",
	MaxShield = "rbxassetid://139807236835811",
	Warding = "rbxassetid://133479347120603",
	PoisonChance = "rbxassetid://137874332790885",
	BurnChance = "rbxassetid://74588474308433",
	BleedChance = "rbxassetid://101337562500575",
	FreezeChance = "rbxassetid://79241468928508",
	JumpPower = "rbxassetid://89411498131129",
	JumpEx = "rbxassetid://89411498131129",

	Intensity = "rbxassetid://128019227796527",
	CriDMG = "rbxassetid://73146024586376",

	Focus = "rbxassetid://132943384940547",
	Combo = "rbxassetid://91123652494859",
	Stack = "rbxassetid://85379466166048",

	Luck = "rbxassetid://109627611842021"
}


AssetBook.ItemEffectIconColors = {
	CriChance = fromHex('#ffeaa7'),
	Luck = fromHex('#2ed573'),
	MaxHealth = fromHex('#2ed573'),
	MaxShield = fromHex('#ffeaa7'),
	FreezeChance = fromHex('#81ecec')
}
AssetBook.ItemEffectNames = {
	CD = "CD Time",
	CriChanceEx = "Critical Chance",
	CriDMGEx = "Critical DMG",
	ATK = "ATK",
	SpeedEx = "Speed",
	MagicEx = "Magic",
	MaxHealthEx = "Health",
	IntensityEx = "Intensity",
	LuckEx = "Luck",
	MaxShieldEx = "Shield",
	WardingEx = "Warding",
	PoisonChanceEx = "Poison Chance",
	BurnChanceEx = "Burn Chance",
	BleedChanceEx = "Bleed Chance",
	FreezeChanceEx = "Freeze Chance",
	JumpEx = "Jump",
}
AssetBook.ItemEffectIsPercentage = {
	CriChanceEx = true,
	CriDMGEx = true,
	IntensityEx = true,
	LuckEx = true,
	WardingEx = true,
	PoisonChanceEx = true,
	BurnChanceEx = true,
	BleedChanceEx = true,
	FreezeChanceEx = true,
}


AssetBook.CharStatIcons = {
	ATK = "rbxassetid://2965862892",
	["BURN CHANCE"] = "rbxassetid://74588474308433",
	["POISON CHANCE"] = "rbxassetid://137874332790885",
	["BLEED CHANCE"] = "rbxassetid://101337562500575",
	["CRIT CHANCE"] = "rbxassetid://73146024586376",
	["CRIT DMG"] = "rbxassetid://73146024586376",
	["DODGE CHANCE"] = "rbxassetid://74429503512836",
	HP = "rbxassetid://104142948728530",
	JMP = "rbxassetid://89411498131129",
	MAGIC = "rbxassetid://2965863231",
	SHIELD = "rbxassetid://139807236835811",
	SPD = "rbxassetid://128019227796527",
	LUCK = "rbxassetid://109627611842021"
}
AssetBook.CharStatIconColors = {
	["CRIT CHANCE"] = fromHex('#ffeaa7'),
	HP = fromHex('#2ed573'),
	LUCK = fromHex('#2ed573'),
	SHIELD = fromHex('#ffeaa7'),
	["DODGE CHANCE"] = fromHex('#70a1ff')
}



AssetBook.PromptIcons = {
	Default = "rbxassetid://13124035950",
	Market = "rbxassetid://118291405899454",
	Chest = "rbxassetid://89067747729088",
	Crafting = "rbxassetid://117468861815122",
}
AssetBook.PromptIconsType = {
	Default = "Default",
	Market = "CAIcon",
	Chest = "Default",
	Crafting = "CAIcon",
}

AssetBook.PreloadAssets = {
	Images = {
		"rbxassetid://91832243782412",
		"rbxassetid://82804434423267",
		"rbxassetid://72813522573875",
	}
}

AssetBook.EnemyVariants = {
	SlimePart1 = { "GreenSlime", "WheatSlime", "BlueSlime", "LapisSlime" },
	SlimePart2 = { "PurpleSlime", "EvolvedGreenSlime" },
	WolfPart1 = { "SpikeWolf", "ThornWolf", "NeedleWolf" }
}


AssetBook.XboxControllerColors = {
	X = Color3.fromHex('#1e90ff'),
	A = Color3.fromHex('#2ed573'),
	B = Color3.fromHex('#d63031'),
	Y = Color3.fromHex('#f9ca24')
}


AssetBook.PerkPointColors = {
	STR = Color3.fromRGB(255, 255, 0),
	INT = Color3.fromHex('#91a7ff'),
	VIT = Color3.fromHex('#63e6be'),
}



AssetBook.GamepassIds = {
	Donation1 = 1094837868,
	Donation2 = 1094827969,
	Donation3 = 1274366124,
	Donation4 = 1274424139
}


AssetBook.DevProductIds = {
	DonationPack5 = 3315706829,
	DonationPack6Mega = 3315707330
}

AssetBook.BadgeIds = {
	CrimsonSlimeHunter = 4040961258983736,
	QueenBeeDestroyer = 2491246281240652,
	HMWolfHunter = 467703311828658,
	GoldCollector = 306749336762986,
	SkyAdventurer = 2140109709187125,
	GoldGatherer = 4119351477910950,
	StoneBreaker = 1589730243445305,
	Fighter = 3437152739289237
}



AssetBook.PlaceIds = {
	AbyssLevelTest = 17737750943,
	AbyssLevelReal = 18331795211,

	MainworldTest = 118088243313343,
	MainworldReal = 124519565742104,

	TutorialTest = 0,
	TutorialReal = 1043446942,

	["7037847546"] = {
		AbyssLevel = 18331795211,
		Mainworld = 124519565742104,
		Tutorial = 1043446942,
	}
}


AssetBook.CFUniverseId = 7037847546

return AssetBook