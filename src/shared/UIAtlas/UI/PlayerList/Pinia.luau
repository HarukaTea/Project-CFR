
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local wait = task.wait


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    Players: Fusion.Value<{ Player }>,
    Characters: Fusion.Value<{ Model }>,

    IsUIShown: Fusion.Value<boolean>,
    IsUIFolded: Fusion.Value<boolean>,

    PlayerSelecting: Fusion.Value<Player?>,
    PlayerSelected: Fusion.Value<Player?>,

    PartyMembers: Fusion.Value<{ Model }>,
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    local players, chars =
        FusionComponents.useTagged(scope, "PlayerEntity"),
        FusionComponents.useTagged(scope, "PlayerCharEntity")

    self.Players = players
    self.Characters = chars

    self.IsUIShown = Value(true)
    self.IsUIFolded = Value(false)

    self.PlayerSelecting = Fusion.Value(self.scope, nil)
    self.PlayerSelected = Fusion.Value(self.scope, nil)


    self.PartyMembers = Value({})




    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))


    --// track tab input
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        if input.KeyCode == Enum.KeyCode.Tab then
            self.IsUIFolded:set(not Fusion.peek(self.IsUIFolded))
            self.PlayerSelecting:set(nil)
        end
    end))


    --// track party
    local partyAdd, partyEmpty = HarukaLib.Bin()

	table.insert(scope, HarukaLib:Hydrate(self.plr, {
		["Attr-IsInParty"] = function(state: boolean)
			partyEmpty()

			if not state then
				self.PartyMembers:set({})
			else
				repeat wait(1) until workspace.MapComponents.PartyHolder:FindFirstChild(self.plr.Name, true)

				local party = workspace.MapComponents.PartyHolder:FindFirstChild(self.plr.Name, true)
				if party:IsA("ObjectValue") then party = party.Parent end

				local function _updateParty()
                    wait()
					self.PartyMembers:set(party:GetChildren())
				end
				_updateParty()
				partyAdd(party.ChildAdded:Connect(_updateParty))
				partyAdd(party.ChildRemoved:Connect(_updateParty))
			end
		end
	}))
	table.insert(scope, partyEmpty)
end