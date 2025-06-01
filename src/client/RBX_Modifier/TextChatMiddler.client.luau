--!nocheck

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local RankBook = require(RepS.HarukaShared.Library.RankBook)


TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    local properties = Instance.new("TextChatMessageProperties")

    --- TextChatAddon
    if message.TextSource then
        --// Player message
        local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
        if not sender:IsDescendantOf(Players) then return properties end

        Bindables.PlayerChatted:Fire(message.Text, sender)
        properties.PrefixText = string.format("%s", message.PrefixText)

        if sender:GetAttribute("Role") then
            local role = sender:GetAttribute("Role") :: string
            local roleInfo: table?


            for _, roleinfo: table in RankBook.RankRoleInfo do
                if roleinfo.Role == role then roleInfo = roleinfo break end
            end
            for _, roleinfo: table in RankBook.CustomRoleInfo do
                if roleinfo.Role == role then roleInfo = roleinfo break end
            end

            if not roleInfo.ChatRole then
                return properties
            end

            properties.PrefixText = string.format(
                "<font color='#%s'><b>[%s]</b></font> %s",
                roleInfo.Color,
                string.upper(roleInfo.ChatRole),
                properties.PrefixText)
        end
    end

    return properties
end