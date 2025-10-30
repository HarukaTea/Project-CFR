
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

local isInviting = false
local isHovered = false

local scope = Fusion.scoped()

--- sending party invite
local function _targetCheck(target: BasePart) : Model | nil
    if isInviting then return end
    if not target then return end
    if not target.Parent then return end
    if not target.Parent.Parent then return end
    if target.Parent:FindFirstChildOfClass("Humanoid") then target = target.Parent end
    if target.Parent.Parent:FindFirstChildOfClass("Humanoid") then target = target.Parent.Parent end
    if target == plr.Character then return end

    local target = target

    local thatPlr = Players:GetPlayerFromCharacter(target)
    if not thatPlr then return end

    local distance = thatPlr:DistanceFromCharacter(plr.Character.PrimaryPart.Position)
    if distance > 33 or distance <= 0 then return end

    return target
end

mouse.Button1Down:Connect(function()
    local char = plr.Character
    if not ClientLib.IsCharValid(char) then return end
    if char:GetAttribute("IsInCombat") then return end

    local target = mouse.Target

    target = _targetCheck(target)
    if not target then return end

    local thatPlr = Players:GetPlayerFromCharacter(target)

    local criRPGSettings = thatPlr:FindFirstChild("CriRPGSettings") :: Configuration
    if not criRPGSettings then return end


    if criRPGSettings:FindFirstChild("AllowPartyInvites") then
        local boolean = criRPGSettings.AllowPartyInvites.Value
        if boolean == false then
            Bindables.CreateNotify:Fire("Player can not be invited due to their privacy settings!")
            return
        end
    end
    if thatPlr:GetAttribute("IsInParty") then
        Bindables.CreateNotify:Fire("Player is already in a party!")
        return
    end
    if target:GetAttribute("IsInCombat") then
        Bindables.CreateNotify:Fire("Player is in combat! Try again later?")
        return
    end
    isInviting = true

    local choice = Components:CreateConfirmPrompt(scope, {
        Hint = `Send party invite to <yellow>{thatPlr.DisplayName}</font>?`,
        ConfirmText = "YES",
        CancelText = "NO",
        ConfirmUniqueId = "ConfirmInvite"..HarukaLib:GenerateUUID(),
    }):Wait()

    isInviting = false

    if choice ~= "YES" then return end

    Events.RequestToPartyInvite.Fire({ Option = "Invite", PlayerName = thatPlr.Name })
end)
mouse.Move:Connect(function()
    local target = mouse.Target

    target = _targetCheck(target)
    if not target then
        if isHovered then
            local highlights = CollectionService:GetTagged("PartyHighlight")
            for _, highlight: Highlight in highlights do highlight:Destroy() end

            isHovered = false
            return
        end
        return
    end

    isHovered = true
    if target:FindFirstChild("PartyHighlight") then target.PartyHighlight:Destroy() end

    local partyHighlight = RepS.Packages.Effects.PartyHighlight:Clone() :: Highlight
    partyHighlight.Adornee = target
    partyHighlight:AddTag("PartyHighlight")
    partyHighlight.Parent = target
end)

--- handling party invite
Events.PartyInviteResult.On(function(data)
    local option, inviter = data.Option, data.PlayerName
    local char = plr.Character

    if option == "Invite" then
        if not char then return end
        if not char.PrimaryPart then return end
        if not char:FindFirstChild("PartyInviteTicket") then return end
        if char.PartyInviteTicket.Value ~= Players[inviter].Character then return end
        if plr.PlayerGui:FindFirstChild("ConfirmPrompt") then return end


        local choice = Components:CreateConfirmPrompt(scope, {
            Hint = `Accept party invite from <yellow>{Players[inviter].DisplayName}</font>?`,
            ConfirmText = "YES",
            CancelText = "NO",
            ConfirmUniqueId = "ConfirmInviteAccept"..HarukaLib:GenerateUUID(),
        }):Wait()
        if choice == "YES" then
            Events.RequestToPartyInvite.Fire({ Option = "InviteAccept", PlayerName = inviter })
        else
            Events.RequestToPartyInvite.Fire({ Option = "InviteDecline", PlayerName = inviter })
        end
    end
end)