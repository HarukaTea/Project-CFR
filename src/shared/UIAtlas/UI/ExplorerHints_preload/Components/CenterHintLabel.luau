
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

local fromScale = UDim2.fromScale

return function (scope: Fusion.Scope, props: {
    Text: string,
    ShowBar: boolean
})

    local CenterNotifyBar = function(pos: "Top" | "Bottom") : Frame
        return Components.Frame(scope, {
            Name = pos.."Bar",
			Size = fromScale(0.15, 0.1),
            Position = if pos == "Top" then fromScale(-0.2, 0) else fromScale(1.2, 0.9),
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AnchorPoint = Vector2.zero
        })
	end
    local bar1, bar2

    if props.ShowBar then
        bar1, bar2 = CenterNotifyBar("Top"), CenterNotifyBar("Bottom")

        HarukaLib:CreateTween(bar1, AssetBook.TweenInfos.one, {
            Position = fromScale(1.2, 0)
        }):Play()

        HarukaLib:CreateTween(bar2, AssetBook.TweenInfos.one, {
            Position = fromScale(-0.2, 0.9)
        }):Play()
    end



    return Components.HarukaFrame(scope, {
        Name = "CenterHintLabel",
        BackgroundTransparency = 0.2,

        [Children] = {
            Components.TextLabel(scope, {
                Name = "Label",
                RichText = true,

                Text = HarukaLib:RichText(props.Text),

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0.2, 0),
                        PaddingBottom = UDim.new(0.2, 0),
                        PaddingLeft = UDim.new(0.2, 0),
                        PaddingRight = UDim.new(0.2, 0)
                    })
                }
            }),

            bar1, bar2
        }
    })
end