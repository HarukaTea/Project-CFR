
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ItemId: string,
    Amount: number
})

    local itemInfo = ItemBook:GetItemInfo(props.ItemId)
    if not itemInfo then return nil end

	local position = Fusion.Value(scope, UDim2.fromScale(-0.5, 0))

    SoundService.SFXs.ItemAcquired:Play()

	table.insert(scope, task.delay(0.1, function()
		position:set(UDim2.fromScale(-0.02, 0))
	end))
	table.insert(scope, task.delay(3.2, function()
		position:set(UDim2.fromScale(-0.5, 0))
	end))

	return Fusion.Hydrate(scope, Components:RefUI("ItemDropBar_IDrops1_2"))({
		[Children] = {
			Fusion.Hydrate(scope, Components:RefUI("Bar_IDrops1_3", false, true))({
				Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
					return use(position)
				end), Components.TweenInfos.twiceHalfOne),

				[Children] = {
					Fusion.Hydrate(scope, Components:RefUI("Icon_IDrops1_3", true))({
						Image = itemInfo.Icon,
					}),

					Fusion.Hydrate(scope, Components:RefUI("Title_IDrops1_3"))({
						Text = "ACQUIRED x"..props.Amount,
					}),

					Fusion.Hydrate(scope, Components:RefUI("Item_IDrops1_3"))({
						Text = itemInfo.Name,
						TextColor3 = AssetBook.ItemTierColors[itemInfo.Tier]:Lerp(Color3.new(1, 1, 1), 0.5),
					}),
				}
			})
		}
	})
end