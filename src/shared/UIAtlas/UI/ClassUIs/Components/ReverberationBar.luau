
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


local plr = Players.LocalPlayer


return function(scope: Fusion.Scope, props: {
    Enemy: Model,
    SelfUI: GuiObject,
})
    if not ClientLib.IsCharValid(props.Enemy) then return nil end

    if props.Enemy:GetAttribute("_UIMarked_Reverberation") then return nil end

    props.Enemy:SetAttribute("_UIMarked_Reverberation", true)


    local function _placeUI()
        for _, ins in CollectionService:GetTagged("_ReverberationPointUI") do
            ins:Destroy()
        end

        local pointUI = RepS.Packages.ClassAttacks.ClassUIs.ReverberationStyle.ReverberationStyle:Clone() :: BillboardGui
        pointUI.Adornee = props.Enemy.Head

        pointUI:AddTag("_ReverberationPointUI")

        pointUI.Frame.Text.Text = props.Enemy:GetAttribute("ReverberationPitch_"..plr.Name)
        pointUI.Parent = props.Enemy

        table.insert(scope, pointUI)
    end
    table.insert(scope, task.delay(1, function()
        _placeUI()

        table.insert(scope, HarukaLib:Hydrate(props.Enemy, {
            ["Attr-ReverberationPitch_"..plr.Name] = function(val: number)
                if not val then return end

                _placeUI()
            end
        }))
    end))

    return nil
end
