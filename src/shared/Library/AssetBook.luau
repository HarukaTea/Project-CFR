
local AssetBook = {}

AssetBook.TweenInfos = {
	fourHalf = TweenInfo.new(0.05),
	threeHalf = TweenInfo.new(0.15),
	twiceHalf = TweenInfo.new(0.2),
	onceHalf = TweenInfo.new(0.3),
	half = TweenInfo.new(0.5),
	halfBack = TweenInfo.new(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = TweenInfo.new(0.75),
	threeHalfOne = TweenInfo.new(0.9),
	one = TweenInfo.new(1),
	oneHalf = TweenInfo.new(1.5),
	two = TweenInfo.new(2),
	three = TweenInfo.new(3),
	four = TweenInfo.new(4),
	six = TweenInfo.new(6),
	fifteen = TweenInfo.new(15, Enum.EasingStyle.Linear)
}

AssetBook.StackableItemTypes = { "Accessory", "Weapon", "Cosmetic" }

AssetBook.ExtraIcons = {
	Null = "rbxassetid://1637592633",
	Unknown = "rbxassetid://114332372182764",
	Marked = "rbxassetid://94557907177407"
}

AssetBook.ItemTierColors = {
	Color3.fromHex('#626771'),
	Color3.fromHex('#52836f'),
	Color3.fromHex('#57789c'),
	Color3.fromHex('#6f639f'),
	Color3.fromHex('#ac712c'),
	Color3.fromHex('#a72424')
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
	HalloweenCandy = "rbxassetid://101642799593354",
	IceCandy = "rbxassetid://4806921700",
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