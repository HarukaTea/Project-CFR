--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Signal = require(RepS.HarukaShared.Shared.Signal)

local wait = task.wait

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.AbsTopicDescSize = Value(Vector2.zero)

    self.PanelSelected = Value("Combat")
    self.PanelSwitched = Signal.new()

    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "TutorialBook")
        end
    }))


    --// track events
    local function _topicOpen(data)
        self.plr:SetAttribute("CurrentUIGroup", "TutorialBook")

        self.PanelSelected:set(data.Topic)
        self.PanelSwitched:Fire(data.Topic)
    end
    table.insert(scope, Events.DisplayTutorialTopic.On(_topicOpen))
    table.insert(scope, Bindables.DisplayTutorialTopic:Connect(_topicOpen))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_TutorialBook",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end