
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local RankBook = require(RepS.HarukaShared.Library.RankBook)

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    local properties = Instance.new("TextChatMessageProperties")
    if not message.TextSource then return properties end


    --// Player message
    local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
    if not sender:IsDescendantOf(Players) then
        return properties
    end

    Bindables.PlayerChatted:Fire(message.Text, sender)
    properties.PrefixText = string.format("%s", message.PrefixText)

    if string.find(message.Text, "/e") then
        return properties
    end

    if sender:GetAttribute("Role") then
        local role = sender:GetAttribute("Role") :: string
        local roleInfo: RankBook.CustomRoleJSON = nil

        for _, roleinfo in RankBook.RankRoleInfo do
            if roleinfo.Role == role then roleInfo = roleinfo break end
        end
        for _, roleinfo in RankBook.CustomRoleInfo do
            if roleinfo.Role == role then roleInfo = roleinfo break end
        end

        if not roleInfo then
            return properties
        end
        if not roleInfo.ChatRole then
            return properties
        end

        properties.PrefixText = string.format(
            "<font color='#%s'><b>[%s]</b></font> %s",
            roleInfo.Color,
            string.upper(roleInfo.ChatRole),
            properties.PrefixText)

        return properties
    end

    if sender:GetAttribute("Title") then
        local title = sender:GetAttribute("Title") :: string
        local titleInfo: RankBook.PlayerTitleJSON = nil

        for _, titleinfo in RankBook.PlayerTitleInfo do
            if titleinfo.Title == title then titleInfo = titleinfo break end
        end

        if not titleInfo then
            return properties
        end
        if not titleInfo.ChatRole then
            return properties
        end

        properties.PrefixText = string.format(
            "<font color='#%s'><b>[%s]</b></font> %s",
            titleInfo.Color,
            string.upper(titleInfo.ChatRole),
            properties.PrefixText)

        return properties
    end

    return properties
end