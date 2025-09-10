--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local PerkRawBook = require(ReplicatedStorage.HarukaShared.Library.PerkRawBookV2)


local PerkBook = {}


PerkBook.FindPerk = function(perkId: string) : {
    PerkId: string,
    Stat: string,
    Req: string,
    Children: string
}
    local talentFound = nil

    for _, talent in PerkRawBook do
        if talent.PerkId == perkId then
            talentFound = talent
            break
        end
    end

    return talentFound
end


PerkBook.CanUnlockPerk = function(perkId: string, plr: Player) : boolean
    local talent = PerkBook.FindPerk(perkId)
    if not talent then return false end

    if plr.Talents:FindFirstChild(perkId) then return false end


    if talent.Req ~= "" then
        local reqTalent = PerkBook.FindPerk(talent.Req)
        if not reqTalent then return false end
        if not plr.Talents:FindFirstChild(reqTalent.PerkId) then return false end

        return true
    end
end


if RunService:IsServer() then
    PerkBook.UnlockPerk = function(perkId: string, plr: Player) : boolean
        local talent = PerkBook.FindPerk(perkId)
        if not talent then return false end

        if PerkBook.CanUnlockPerk(perkId, plr) then
            local newTalent = Instance.new("BoolValue")
            newTalent.Name = talent.PerkId
            newTalent.Value = true
            newTalent.Parent = plr.Talents

            return true
        else
            return false
        end
    end
end


return PerkBook