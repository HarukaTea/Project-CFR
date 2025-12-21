
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")


local Events = require(RepS.HarukaShared.Library.Events)

local plr = Players.LocalPlayer

local wait = task.wait


--// rejoin command debug for all players
local worldId = workspace:GetAttribute("WorldId")

if worldId and worldId == "InitusWorld" then
    local rejoinCommand = Instance.new("TextChatCommand")
    rejoinCommand.Name = "HarukaRejoinCommand"
    rejoinCommand.Parent = TextChatService:WaitForChild("TextChatCommands")
    rejoinCommand.PrimaryAlias = "/rejoin"
    rejoinCommand.SecondaryAlias = "!rejoin"
    rejoinCommand.AutocompleteVisible = true
    rejoinCommand.Enabled = true

    rejoinCommand.Triggered:Connect(function(textSource: TextSource)
        if textSource.UserId == plr.UserId then
            Events.RejoinGame_C.Fire()
        end
    end)
end



wait(5)
repeat wait() until plr:GetAttribute("Rank")
if (plr:GetAttribute("Rank") or 0) < 2 then return end



local HarukaCMD = require(RepS.HarukaShared.Shared.HarukaCMDClient)

local harukaCMDObj = HarukaCMD.new()
harukaCMDObj:Init()