
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")


local Bindables = require(RepS.HarukaShared.Library.Bindables)

local plr = Players.LocalPlayer

local wait = task.wait


if not workspace:GetAttribute("AllowFreecam") then return end


local Freecam = require(RepS.HarukaShared.Shared.Freecam)


local freecamCommand = Instance.new("TextChatCommand")
freecamCommand.Name = "HarukaFreecamCommand"
freecamCommand.Parent = TextChatService:WaitForChild("TextChatCommands")
freecamCommand.PrimaryAlias = "/freecam"
freecamCommand.SecondaryAlias = "!freecam"
freecamCommand.AutocompleteVisible = true
freecamCommand.Enabled = true

freecamCommand.Triggered:Connect(function(textSource: TextSource)
    if textSource.UserId == plr.UserId then
        Bindables.CreateNotify:Fire("Press Esc to exit Freecam.")

        wait(2)
        Freecam.Toggle(true)
    end
end)
GuiService.MenuOpened:Connect(function()
    Freecam.Toggle(false)
end)
