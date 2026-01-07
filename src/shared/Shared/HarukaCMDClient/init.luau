
--// Cmd for my own projects

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Events = require(script.Events)
local Types = require(script.Types)

type CommandJSON = Types.CommandJSON


--// Init once
local CommandBook = {}

Events.RequestCommands_Response.On(function(data)
    CommandBook = data.Commands
end)


Events.RequestCommands_Request.Fire()




local UIComponent = require(script.UIComponent)

local wait = task.wait


local HarukaCMD = {} :: Types.HarukaCMDClass
HarukaCMD.__index = HarukaCMD


--// Constructor
function HarukaCMD.new()
    local self = setmetatable({}, HarukaCMD)

    self.scope = Fusion.scoped()
    local function Value(val: any) : Fusion.Value<any>
        return Fusion.Value(self.scope, val)
    end

    self.Player = Players.LocalPlayer

    self.IsShown = Value(false)
    self.CMDInput = Value("")
    self.CMDSearchInput = Value("")

    self.CMDIntellisense = Value({})
    self.ItemIntellisense = Value({})
    self.Rank = 0

    self.AutoCompletePointer = Value(1)
    self.ItemAutoCompletePointer = Value(1)

    self.ExtraArgs = {}
    self.ExtraArgsSearch = {}
    for _ = 1, 5 do
        table.insert(self.ExtraArgs, Value(""))
        table.insert(self.ExtraArgsSearch, Value(""))
    end

    self.Commands = {}
    self.Add, self.Empty = HarukaLib.Bin()

    return self
end



function HarukaCMD:Init()
    self.Rank = self.Player:GetAttribute("Rank")
    self.Commands = {}

    self.RefreshCommandBookFunc = function()
        local afterCommands = HarukaLib.TableUtils.DeepCopy(CommandBook)

        for index: number, cmd in afterCommands do
            if cmd.RankReq > Fusion.peek(self.Rank) then
                table.remove(afterCommands, index)
            end
        end

        self.Commands = afterCommands
    end
    self.RefreshCommandBookFunc()


    self.AutoCompleteFunc = function()
        local suggestedCommands = Fusion.peek(self.CMDIntellisense)
        local nextPointer = Fusion.peek(self.AutoCompletePointer) :: number

        if not suggestedCommands[1] then return end
        if not suggestedCommands[nextPointer] then return end

        local suggestedCommand: CommandJSON = suggestedCommands[nextPointer]

        local text = ""
        text ..= suggestedCommand.Alias
        text ..= " "
        for _, _ in suggestedCommand.Args do
            text ..= "<>"
            text ..= " "
        end

        local aliasOnly = ""
        aliasOnly ..= suggestedCommand.Alias

        wait()
        self.CMDInput:set(text)
        self.CMDSearchInput:set(aliasOnly)
    end
    self.ArgAutoCompleteFunc = function(argProps: {
        Option: string,
        Index: number
    })
        local text = Fusion.peek(self.CMDInput) :: string
        local count = 0

        local result = string.gsub(text, "<([^>]*)>", function(content)
            count += 1

            if count == argProps.Index then
                return "<"..argProps.Option..">"
            else
                return "<"..content..">"
            end
        end)

        wait()
        self.CMDInput:set(result)
    end
    self.ExecuteCommandFunc = function()
        self.IsShown:set(false)

        local rank = self.Player:GetAttribute("Rank") :: number
        if not rank then return end
        if rank < 2 then return end

        Events.RequestToExecuteCommand.Fire({
            Command = Fusion.peek(self.CMDInput)
        })
    end


    self:_InitUI()
    self:_ListenUITracker()
    self:_ListenInputTracker()
end



function HarukaCMD:Destroy()
    Fusion.doCleanup(self.scope)

    self.Empty()
end


--// Private Methods

function HarukaCMD:_InitUI()
    self.UI = UIComponent(self.scope, {
        IsShownVal = self.IsShown,
        CMDInput = self.CMDInput,
        CMDSearchInput = self.CMDSearchInput,
        Intellisense = self.CMDIntellisense,
        IntellisensePointer = self.AutoCompletePointer,
        ItemIntellisense = self.ItemIntellisense,
        ItemIntellisensePointer = self.ItemAutoCompletePointer,
        ExtraArgs = self.ExtraArgs,
        ExtraArgsSearch = self.ExtraArgsSearch,

        AutoCompleteFunc = self.AutoCompleteFunc,
    }, self)
end


function HarukaCMD:_ListenInputTracker()
    local function _handleOpen()
        if GuiService.MenuIsOpen then
            self.IsShown:set(false)
            return
        end

        self.IsShown:set(not Fusion.peek(self.IsShown))
    end
    self.Add(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if input.KeyCode == Enum.KeyCode.Quote then
            _handleOpen()

        elseif input.KeyCode == Enum.KeyCode.Return then
            if not Fusion.peek(self.IsShown) then return end

            self.ExecuteCommandFunc()
        end
    end))

    local panelCommand = Instance.new("TextChatCommand")
    panelCommand.Name = "HarukaCMDCommand"
    panelCommand.Parent = TextChatService:WaitForChild("TextChatCommands")
    panelCommand.PrimaryAlias = "/cmds"
    panelCommand.SecondaryAlias = "!cmds"
    panelCommand.AutocompleteVisible = true
    panelCommand.Enabled = true

    panelCommand.Triggered:Connect(function(textSource: TextSource)
        if textSource.UserId == Players.LocalPlayer.UserId then
            self.IsShown:set(not Fusion.peek(self.IsShown))
        end
    end)

    self.Add(panelCommand)
    self.Add(GuiService.MenuOpened:Connect(_handleOpen))
end


function HarukaCMD:_ListenUITracker()
    local cmdOpenObserver = Fusion.Observer(self.scope, self.IsShown)
    cmdOpenObserver:onBind(function()
        if Fusion.peek(self.IsShown) then
            self.RefreshCommandBookFunc()

            self.CMDInput:set("/")
            self.CMDSearchInput:set("/")

            if GuiService.MenuIsOpen then
                task.defer(function() --- do this step in next frame to avoid Busy values
                    self.IsShown:set(false) --- special case for roblox menu bugs (rarely)
                end)
            end

            for _, argVal: Fusion.Value<string> in self.ExtraArgs do
                argVal:set("")
            end
            for _, argVal: Fusion.Value<string> in self.ExtraArgsSearch do
                argVal:set("")
            end
        end
    end)


    local cmdInputObserver = Fusion.Observer(self.scope, self.CMDSearchInput)
    cmdInputObserver:onBind(function()
        local input = Fusion.peek(self.CMDSearchInput) :: string
        local realInput = string.gsub(input, " ", "")

        if realInput == "" then realInput = "/" end

        local acceptedCmds = {}
        pcall(function()
            for _, cmd: CommandJSON in self.Commands do
                local inputLen, aliasLen = #realInput, #cmd.Alias
                local inputCMD, aliasCMD = realInput, cmd.Alias

                if inputLen > aliasLen then
                    inputCMD, aliasCMD = aliasCMD, inputCMD
                end
                if string.find(string.lower(aliasCMD), string.lower(inputCMD)) then
                    table.insert(acceptedCmds, cmd)
                end
            end
        end)

        self.CMDIntellisense:set(acceptedCmds)

        if #acceptedCmds <= 0 then return end

        local totalElements = #acceptedCmds
        local nextPointer = math.clamp(Fusion.peek(self.AutoCompletePointer), 1, totalElements)

        self.AutoCompletePointer:set(nextPointer)
    end)


    local pointerObserver = Fusion.Observer(self.scope, self.AutoCompletePointer)
    pointerObserver:onBind(function()
        local pointer = Fusion.peek(self.AutoCompletePointer) :: number
        local suggestedCommands = Fusion.peek(self.CMDIntellisense)
        if #suggestedCommands <= 0 then
            self.ItemIntellisense:set({})
            return
        end

        pointer = math.clamp(pointer, 1, #suggestedCommands)

        local curSuggested = suggestedCommands[pointer]
        self.ItemIntellisense:set(curSuggested.Args)

        for _, argVal: Fusion.Value<string> in self.ExtraArgs do
            argVal:set("")
        end
        for _, argVal: Fusion.Value<string> in self.ExtraArgsSearch do
            argVal:set("")
        end
    end)


    local cmdIntellisenseObserver = Fusion.Observer(self.scope, self.CMDIntellisense)
    cmdIntellisenseObserver:onBind(function()
        local suggestedCommands = Fusion.peek(self.CMDIntellisense)
        if #suggestedCommands <= 0 then
            self.ItemIntellisense:set({})
            return
        end

        local pointer = Fusion.peek(self.AutoCompletePointer) :: number

        pointer = math.clamp(pointer, 1, #suggestedCommands)
        self.AutoCompletePointer:set(pointer)

        local curSuggested = suggestedCommands[pointer]
        self.ItemIntellisense:set(curSuggested.Args)

        for _, argVal: Fusion.Value<string> in self.ExtraArgs do
            argVal:set("")
        end
        for _, argVal: Fusion.Value<string> in self.ExtraArgsSearch do
            argVal:set("")
        end
    end)


    local itemIntellisenseObserver = Fusion.Observer(self.scope, self.ItemIntellisense)
    itemIntellisenseObserver:onBind(function()
        self.ItemAutoCompletePointer:set(1)
    end)
end


return HarukaCMD