
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Bindables = require(RepS.HarukaShared.Library.Bindables)

local Children = Fusion.Children

local fromScale = UDim2.fromScale

return function (scope: Fusion.Scope, props: {
    Member: ObjectValue
})
    local member = props.Member.Value
    if member == nil then return nil end


    return Components.Frame(scope, {
        Name = member.Name,
        BackgroundTransparency = 0,
        Size = fromScale(0.15, 0.7),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.TextLabel(scope, {
                Name = "MemberName",
                Size = fromScale(1, 1),
                Text = Players[member.Name].DisplayName,

                [Children] = {
                    Fusion.New(scope, "UIPadding")({
                        PaddingTop = UDim.new(0.15, 0),
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0.1, 0),
                        PaddingRight = UDim.new(0.1, 0),
                    })
                }
            }),
            Components.TextButton(scope, {
                Name = "Kick",
                Size = fromScale(0.7, 0.7),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Position = if math.random(1, 2) == 1 then fromScale(-0.05, -0.15) else fromScale(0.92, -0.15),
                AutoLocalize = false,
                Text = "X",
                BackgroundColor3 = Components.RED_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if not member then return end
                    if not member.Parent then return end

                    if Players.LocalPlayer.Name == member.Name then
                        Events.PartyInvite_C.Fire({ Option = "PartyLeave", PlayerName = member.Name })
                        return
                    end
                    if Players.LocalPlayer.Name ~= member.Parent.Name then
                        Bindables.CreateNotify:Fire("Only the party leader can kick members")
                        return
                    end

                    Events.PartyInvite_C.Fire({ Option = "PartyKick", PlayerName = member.Name })
                end,

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            })
        }
    })
end