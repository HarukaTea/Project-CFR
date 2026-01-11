
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)

export type PartyClass = {
	__index: PartyClass,
	Leader: Player,
	Members: { [Player]: boolean },
	MaxSize: number,
	Holder: Folder,

	new: (leader: Player) -> PartyClass,

	AddMember: (self: PartyClass, plr: Player) -> boolean,
	RemoveMember: (self: PartyClass, plr: Player) -> (),
	IsFull: (self: PartyClass) -> boolean,
	GetAllMembers: (self: PartyClass) -> { Player },
	Disband: (self: PartyClass) -> (),
	Destroy: (self: PartyClass) -> ()
}

local Party = {} :: PartyClass
Party.__index = Party

local playerToParty: { [Player]: PartyClass } = {}
local PartyLib = {}

--// Helper functions
local function _createMemberSymbol(name: string, value: Instance, parent: Instance): ObjectValue
	local obj = Instance.new("ObjectValue")
	obj.Name = name
	obj.Value = value
	obj.Parent = parent

	return obj
end
local function _setPlayerPartyData(plr: Player, party: PartyClass?)
	playerToParty[plr] = party

	plr:SetAttribute("IsInParty", party ~= nil)
end

--// Cleanup Loop
HarukaLib.Clock(150, function()
	local holderRoot = workspace.MapComponents:FindFirstChild("PartyHolder")
	if not holderRoot then return end

	for _, partyFolder: Folder in holderRoot:GetChildren() do
		if #partyFolder:GetChildren() <= 0 then
			partyFolder:Destroy()
		end
	end
end)

function Party.new(leader: Player)
	local self = setmetatable({}, Party)

	self.Leader = leader
	self.Members = { [leader] = true }
	self.MaxSize = 6

	local folder = Instance.new("Folder")
	folder.Name = leader.Name
	folder.Parent = workspace.MapComponents.PartyHolder
	self.Holder = folder

	_createMemberSymbol(leader.Name, leader, folder)

	return self
end

function Party:AddMember(plr: Player): boolean
	if self:IsFull() or self.Members[plr] then return false end

	self.Members[plr] = true
	_createMemberSymbol(plr.Name, plr, self.Holder)
	return true
end

function Party:RemoveMember(plr: Player)
	self.Members[plr] = nil
	local symbol = self.Holder:FindFirstChild(plr.Name)
	if symbol then symbol:Destroy() end

	if HarukaLib.TableUtils.CountDictLength(self.Members) <= 0 then
		self:Disband()
	end
end

function Party:IsFull(): boolean
	return HarukaLib.TableUtils.CountDictLength(self.Members) >= self.MaxSize
end

function Party:GetAllMembers(): { Player }
	return HarukaLib.TableUtils.Keys(self.Members)
end

function Party:Disband()
	self.Members = {}
	if self.Holder then self.Holder:Destroy() end
end

--// Public API

function PartyLib:GetParty(plr: Player): PartyClass
	return playerToParty[plr]
end

function PartyLib:Invite(inviter: Player, target: Player)
	if playerToParty[target] then
		Events.CreateNotify_S.Fire(inviter, "Player is already in a party!")
		return
	end

	local pParty = playerToParty[inviter]
	if pParty and pParty.Leader ~= inviter then
		Events.CreateNotify_S.Fire(inviter, "Only the leader can invite!")
		return
	end

	Events.PartyInviteResult_S.Fire(target, {
		Option = "Invite",
		PlayerName = inviter.Name
	})
end

function PartyLib:Accept(inviter: Player, invitee: Player)
	if playerToParty[invitee] then return end

	local party: PartyClass = playerToParty[inviter]
	if not party then
		party = Party.new(inviter)
		_setPlayerPartyData(inviter, party)
	end

	if party.Leader ~= inviter then
		Events.CreateNotify_S.Fire(invitee, "Invite is no longer valid")
		return
	end

	if not party:AddMember(invitee) then
		Events.CreateNotify_S.Fire(invitee, "Party is full!")
		Events.CreateNotify_S.Fire(inviter, "Party is full!")
		return
	end
	_setPlayerPartyData(invitee, party)

	for _, member in party:GetAllMembers() do
		Events.CreateNotify_S.Fire(member, invitee.DisplayName .. " joined the party!")
	end
end

function PartyLib:Decline(inviter: Player, invitee: Player)
	Events.CreateNotify_S.Fire(inviter, invitee.DisplayName .. " declined your invitation")
end

function PartyLib:Kick(leader: Player, target: Player)
	local party = playerToParty[leader]

	if not party or party.Leader ~= leader then
		Events.CreateNotify_S.Fire(leader, "You are not the leader!")
		return
	end

	if not party.Members[target] then return end

	party:RemoveMember(target)
	_setPlayerPartyData(target, nil)

	for _, member in party:GetAllMembers() do
		Events.CreateNotify_S.Fire(member, target.DisplayName .. " was kicked from the party!")
	end
end

function PartyLib:Leave(plr: Player)
	local party = playerToParty[plr]
	if not party then return end

	local isLeader = (party.Leader == plr)

	party:RemoveMember(plr)
	_setPlayerPartyData(plr, nil)

	if isLeader then
		local members = party:GetAllMembers()
		party:Disband()

		for _, member in members do
			_setPlayerPartyData(member, nil)
			Events.CreateNotify_S.Fire(member, "Party has been disbanded!")
		end
	else
		for _, member in party:GetAllMembers() do
			Events.CreateNotify_S.Fire(member, plr.DisplayName .. " has left the party")
		end
	end
end

return PartyLib
