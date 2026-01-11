
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

local fromScale = UDim2.fromScale

return function (scope: Fusion.Scope, props: {
    Text: string,
    ShowBar: boolean
})
    local bar1, bar2

    if props.ShowBar then
        local CenterNotifyBar = function(pos: "Top" | "Bottom") : Frame
            return Fusion.Hydrate(scope, Components:RefUI("DecoBar_CH1_1"))({
                Position = if pos == "Top" then fromScale(-0.2, 0) else fromScale(1.2, 0.9),
            })
        end
        bar1, bar2 = CenterNotifyBar("Top"), CenterNotifyBar("Bottom")

        HarukaLib:CreateTween(bar1, Components.TweenInfos.one, {
            Position = fromScale(1.2, 0)
        }):Play()

        HarukaLib:CreateTween(bar2, Components.TweenInfos.one, {
            Position = fromScale(-0.2, 0.9)
        }):Play()
    end


    return Components.HarukaFrame(scope, {
        Name = "CenterHintLabel",
        BackgroundTransparency = 0.2,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Hint_CH1_2", true))({
                Text = HarukaLib:RichTextify(props.Text)
            }),

            bar1, bar2
        }
    })
end