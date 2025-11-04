
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)


export type PartyClassStruct = {
    __index: PartyClassStruct,

    Leader: Player,
    Members: { [Player]: boolean },
    MaxSize: number,
    Holder: Folder,

    new: (leader: Player) -> PartyClassStruct,

    AddMember: (self: PartyClassStruct, plr: Player) -> boolean,
    RemoveMember: (self: PartyClassStruct, plr: Player) -> nil,
    IsFull: (self: PartyClassStruct) -> boolean,
    GetAllMembers: (self: PartyClassStruct) -> { Player },
    Disband: (self: PartyClassStruct) -> nil
}


--// helper functions

local function _createMemberSymbol(name: string, value: Instance, parent: Instance) : ObjectValue
    local obj = Instance.new("ObjectValue")
    obj.Name = name
    obj.Value = value
    obj.Parent = parent

    return obj
end


--// to prevent memory leaks
HarukaLib.Clock(150, function()
    for _, partyHolder: Folder in workspace.MapComponents.PartyHolder:GetChildren() do
        if #partyHolder:GetChildren() <= 0 then
            partyHolder:Destroy()
        end
    end
end)



local PartyClass = {} :: PartyClassStruct
PartyClass.__index = PartyClass


function PartyClass.new(leader: Player)
	local self = setmetatable({}, PartyClass)

	self.Leader = leader
	self.Members = {
        [leader] = true
    }
	self.MaxSize = 6


    local folder = Instance.new("Folder")
	folder.Name = leader.Name
	folder.Parent = workspace.MapComponents.PartyHolder


	self.Holder = folder
	_createMemberSymbol(leader.Name, leader, folder)

	return self
end


function PartyClass:AddMember(plr: Player) : boolean
	if self:IsFull() then return false end
    if self.Members[plr] then return false end

	self.Members[plr] = true
	_createMemberSymbol(plr.Name, plr, self.Holder)

    return true
end



function PartyClass:RemoveMember(plr: Player)
	self.Members[plr] = nil

    local memberSymbol = self.Holder:FindFirstChild(plr.Name)
	if memberSymbol then memberSymbol:Destroy() end
end



function PartyClass:IsFull() : boolean
    return HarukaLib.TableUtils.CountDictLength(self.Members) >= self.MaxSize
end


function PartyClass:GetAllMembers() : { Player }
	return HarukaLib.TableUtils.Keys(self.Members)
end


function PartyClass:Disband()
	for member: Player in self.Members do
		member:SetAttribute("IsInParty", false)
	end
	self.Members = {}

    if self.Holder then
		self.Holder:Destroy()
	end
end



local PlayerPartyDataClass = {}
local playerToPartyPool = {}


function PlayerPartyDataClass:SetParty(plr: Player, party: PartyClassStruct)
	playerToPartyPool[plr] = party

	plr:SetAttribute("IsInParty", party ~= nil)
end

function PlayerPartyDataClass:GetParty(plr: Player) : PartyClassStruct
	return playerToPartyPool[plr]
end

function PlayerPartyDataClass:ClearParty(plr: Player)
	playerToPartyPool[plr] = nil

	plr:SetAttribute("IsInParty", false)
end

function PlayerPartyDataClass:IsInParty(plr: Player) : boolean
	return playerToPartyPool[plr] ~= nil
end



local HarukaParty = {}


function HarukaParty:Invite(inviter: Player, target: Player)
	if PlayerPartyDataClass:IsInParty(target) then
		Events.CreateNotify.Fire(inviter, "Player already in a party!")
		return
	end

	--Events.PartyInvite:FireClient(target, inviter)
end


function HarukaParty:Accept(inviter: Player, invitee: Player)
	local inviterParty = PlayerPartyDataClass:GetParty(inviter)

	if not inviterParty then
		inviterParty = PartyClass.new(inviter)

		PlayerPartyDataClass:SetParty(inviter, inviterParty)
	end


	local ok = inviterParty:AddMember(invitee)
	if not ok then
		Events.CreateNotify.Fire(invitee, "Party is full!")
		Events.CreateNotify.Fire(inviter, "Party is full!")
		return
	end
	PlayerPartyDataClass:SetParty(invitee, inviterParty)


	for _, member in inviterParty:GetAllMembers() do
		Events.CreateNotify.Fire(member, invitee.DisplayName .. " joined the party!")
	end
end


function HarukaParty:Decline(inviter: Player, invitee: Player)
	Events.CreateNotify.Fire(inviter, invitee.DisplayName .. " declined your invitation.")
end


function HarukaParty:Kick(leader: Player, target: Player)
	local party = PlayerPartyDataClass:GetParty(leader)

	if not party or party.Leader ~= leader then
		Events.CreateNotify.Fire(leader, "You are not a leader!")
        return
	end
	if not party.Members[target] then
		Events.CreateNotify.Fire(leader, "Player not in your party!")
        return
	end

	party:RemoveMember(target)
	PlayerPartyDataClass:ClearParty(target)

	for _, member in party:GetAllMembers() do
		Events.CreateNotify.Fire(member, target.DisplayName .. " was kicked from the party!")
	end
end



function HarukaParty:Leave(plr: Player)
	local party = PlayerPartyDataClass:GetParty(plr)
	if not party then return end

	local isLeader = (party.Leader == plr)

	party:RemoveMember(plr)
	PlayerPartyDataClass:ClearParty(plr)

	if isLeader then
		party:Disband()

		for _, member in party:GetAllMembers() do
			PlayerPartyDataClass:ClearParty(member)

			Events.CreateNotify.Fire(member, "Party has been disbanded!")
		end
	else
		for _, member in party:GetAllMembers() do
			Events.CreateNotify.Fire(member, plr.DisplayName .. " has left the party.")
		end
	end
end



return HarukaParty


