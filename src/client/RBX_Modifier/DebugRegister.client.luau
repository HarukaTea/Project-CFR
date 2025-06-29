--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")


local Events = require(RepS.HarukaShared.Library.Events)
local Bindables = require(RepS.HarukaShared.Library.Bindables)

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
            Events.RequestToRejoinGame.Fire()
        end
    end)
end



--// freecam
if workspace:GetAttribute("AllowFreecam") then
    local Freecam = require(RepS.HarukaShared.Library.Freecam)


    local freecamCommand = Instance.new("TextChatCommand")
    freecamCommand.Name = "HarukaFreecamCommand"
    freecamCommand.Parent = TextChatService:WaitForChild("TextChatCommands")
    freecamCommand.PrimaryAlias = "/freecam"
    freecamCommand.SecondaryAlias = "!freecam"
    freecamCommand.AutocompleteVisible = true
    freecamCommand.Enabled = true

    freecamCommand.Triggered:Connect(function(textSource: TextSource)
        if textSource.UserId == plr.UserId then
            Bindables.CreateNotify:Fire("Initializing Freecam...")
            Bindables.CreateNotify:Fire("You can exit Freecam mode by pressing the Esc key.")

            wait(2)
            Freecam.Toggle(true)
        end
    end)
    GuiService.MenuOpened:Connect(function()
        Freecam.Toggle(false)
    end)
end



wait(5)
repeat wait() until plr:GetAttribute("Rank")
if (plr:GetAttribute("Rank") or 0) < 2 then
    return
end

local HarukaCMD = require(RepS.HarukaShared.Shared.HarukaCMD)

local harukaCMDObj = HarukaCMD.new()
harukaCMDObj:Init()
