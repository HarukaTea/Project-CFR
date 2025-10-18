--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local Children = Fusion.Children

local wait = task.wait

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.scope = Fusion.scoped()

    require(script.Pinia)(self)


    local scope = self.scope :: Fusion.Scope
    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerHints",
        DisplayOrder = UIPriorityBook.Highest + 1,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = plr.PlayerGui,

    }, {
        TopProps = {
            Position = UDim2.new(0.5, 0, 0, 56),

            [Children] = {
                Components.Frame(scope, {
                    Name = "Hints",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 0),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0, 12),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),

                        Components.UIScale(scope)
                    }
                })
            }
        }
    })
    self.UI = UI



    local AGLObj = HarukaListLayout.new(UI.Top.Hints.UIListLayout)
    AGLObj:Enable()

    table.insert(scope, AGLObj)
end