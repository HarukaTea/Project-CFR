
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
	three = newTweenInfo(3),
	four = newTweenInfo(4),
	six = newTweenInfo(6),
	fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}


AssetBook.StackableItemTypes = { "Accessory", "Weapon", "Passive", "CosmeticArmor", "CosmeticWeapon" }


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
	fromHex('#a72424')
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
	JumpPower = "rbxassetid://128019227796527",
	JumpEx = "rbxassetid://128019227796527",

	Intensity = "rbxassetid://128019227796527",
	CriDMG = "rbxassetid://73146024586376",

	Focus = "rbxassetid://132943384940547",
	Combo = "rbxassetid://91123652494859",
	Stack = "rbxassetid://85379466166048",

	Luck = "rbxassetid://109627611842021"
}


AssetBook.ItemEffectIconColors = {
	CriChance = fromHex('#ffeaa7'),
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
	MaxShieldEx = "Shield",
	PoisonChanceEx = "Poison Chance",
	BurnChanceEx = "Burn Chance",
	BleedChanceEx = "Bleed Chance",
	FreezeChanceEx = "Freeze Chance",
	JumpEx = "Jump",
}
AssetBook.ItemEffectIsPercentage = {
	CriChanceEx = true,
	CriDMGEx = true,
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
	Donations = {}
}


AssetBook.DevProductIds = {
	Donations = {
		DonationPack1 = 3454021702,
		DonationPack2 = 3454021999,
		DonationPack3 = 3454022448,
		DonationPack4 = 3315707330,
		DonationPack5 = 3454023339,
	},
	HalloweenCandy = {
		HalloweenPack1 = 3454075092,
		HalloweenPack2 = 3454075601,
	}
}

AssetBook.BadgeIds = {
	CrimsonSlimeHunter = 4040961258983736,
	QueenBeeDestroyer = 2491246281240652,
	HMWolfHunter = 467703311828658,
	GoldCollector = 306749336762986,
	GoldGatherer = 4119351477910950,
	StoneBreaker = 1589730243445305,
	Fighter = 3437152739289237,

	--// SkyAdventurer = 2140109709187125,
}



AssetBook.CurrencyIcons = {
    Gold = "rbxassetid://18421784947",
    Astra = "rbxassetid://93309091471652",

	HalloweenCandy = "rbxassetid://118291405899454",
}


AssetBook.PlaceIds = {
	-- CF REL
	["7037847546"] = {
		AbyssLevel = 18331795211,
		Mainworld = 124519565742104,
		WaveDefense = 1043446942,
	},

	-- CFT_but_public
	["6754928573"] = {
		AbyssLevel = 17737750943,
		Mainworld = 118088243313343,
		WaveDefense = 18502526655,
	},

	-- CFT
	["7793504190"] = {
		Mainworld = 124519565742104,
	}
}


AssetBook.CFUniverseId_Main = 7037847546



return AssetBook