
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

	return Components.Frame(scope, {
		Name = itemInfo.ItemId,
		AnchorPoint = Vector2.zero,
        ZIndex = 99,

		[Children] = {
			Components.Frame(scope, {
				Name = "Bar",
				BackgroundTransparency = 0.2,
				AnchorPoint = Vector2.zero,
				Size = UDim2.fromScale(0.2, 1),

				Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
					return use(position)
				end), Components.TweenInfos.twiceHalfOne),

				[Children] = {
					Components.RoundUICorner(scope),

					Components.IconImageLabel(scope, {
						Position = UDim2.fromScale(0.81, 0),
						Image = itemInfo.Icon,
					}),
					Components.TextLabel(scope, {
						Name = "Title",
						Position = UDim2.fromScale(0.15, 0.03),
						Size = UDim2.fromScale(0.62, 0.35),
						Text = "ACQUIRED x"..props.Amount,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
					Components.TextLabel(scope, {
						Name = "Item",
						Position = UDim2.fromScale(0.15, 0.44),
						Size = UDim2.fromScale(0.62, 0.45),
						Text = itemInfo.Name,
						TextColor3 = AssetBook.ItemTierColors[itemInfo.Tier]:Lerp(Color3.new(1, 1, 1), 0.5),
						TextXAlignment = Enum.TextXAlignment.Right
					}),
				},
			}),
		},
	})
end