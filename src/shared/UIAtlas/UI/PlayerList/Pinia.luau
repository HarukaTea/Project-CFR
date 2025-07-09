--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local wait = task.wait


return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.Players = FusionComponents.useTagged(scope, "PlayerEntity")
    self.Characters = FusionComponents.useTagged(scope, "PlayerCharEntity")

    self.IsUIShown = Value(true)
    self.IsUIFolded = Value(false)

    self.PlayerSelecting = Value(nil)
    self.PlayerSelected = Value(nil)


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

        if input.KeyCode == Enum.KeyCode.Tab then
            self.IsUIFolded:set(not Fusion.peek(self.IsUIFolded))
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
				repeat wait(0.03) until workspace.MapComponents.PartyHolder:FindFirstChild(self.plr.Name, true)

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
