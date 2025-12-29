
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


AssetBook.StackableItemTypes = { "Accessory", "Weapon", "CosmeticArmor", "CosmeticWeapon" }


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


AssetBook.PromptIcons = {
	Default = "rbxassetid://13124035950",
	Market = "rbxassetid://118291405899454",
	Chest = "rbxassetid://89067747729088",
	Crafting = "rbxassetid://117468861815122",
}


AssetBook.XboxControllerColors = {
	X = Color3.fromHex('#1e90ff'),
	A = Color3.fromHex('#2ed573'),
	B = Color3.fromHex('#d63031'),
	Y = Color3.fromHex('#f9ca24')
}


AssetBook.GamepassIds = {}


AssetBook.DevProductIds = {
	DonationPack1 = 3454021702,
	DonationPack2 = 3454021999,
	DonationPack3 = 3454022448,
	DonationPack4 = 3315707330,
	DonationPack5 = 3454023339,
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