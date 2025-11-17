
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
})
    if not ClientLib.IsCharValid(props.Enemy) then return nil end

    if props.Enemy:GetAttribute("_UIMarked_Flow") then return nil end

    props.Enemy:SetAttribute("_UIMarked_Flow", true)


    table.insert(scope, props.Enemy.ChildAdded:Connect(function(ins)
        if ins.Name == "MarkHolder_"..plr.Name then
            local markUI1 = RepS.Packages.ClassAttacks.ClassUIs.FocusStyle.FocusStyle:Clone() :: BillboardGui
            markUI1.Adornee = props.Enemy.Head
            markUI1.Text.Text = "MARK x1"

            markUI1.Parent = ins

            local markUI2 = RepS.Packages.ClassAttacks.ClassUIs.FocusStyle.FocusStyle_Mark:Clone() :: BillboardGui
            markUI2.Adornee = props.Enemy.Head
            markUI2.Parent = ins


            local function _update()
                local markedSymbol = #ins:GetChildren()

                markUI1.Text.Text = "MARK x"..markedSymbol
            end
            _update()
            table.insert(scope, ins.ChildAdded:Connect(_update))
            table.insert(scope, ins.ChildRemoved:Connect(_update))
        end
    end))


    return nil
end
