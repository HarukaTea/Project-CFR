
--// Cmd for my own projects

local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local SSS = game:GetService("ServerScriptService")


local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Events = nil
local GlobalEvents = nil

if RunService:IsClient() then
    Events = require(script.Events)
    Events.RequestCommands_Request.Fire()
else
    Events = require(script.ServerEvents)
    GlobalEvents = require(SSS.HarukaServer.Library.ServerEvents)
end


local Types = require(script.Types)

type CallbackProps = Types.CallbackProps
type CommandJSON = Types.CommandJSON


--// Init once
local CommandBook = nil

if RunService:IsClient() then
    CommandBook = {}

    Events.RequestCommands_Response.On(function(data)
        CommandBook = data.Commands
    end)
end


local UIComponent = nil
if RunService:IsClient() then
    UIComponent = require(script.UIComponent)
end

local wait = task.wait


local HarukaCMD = {} :: Types.HarukaCMDClass
HarukaCMD.__index = HarukaCMD


--// Constructor
function HarukaCMD.new()
    local self = setmetatable({}, HarukaCMD)

    if RunService:IsClient() then
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
    end

    self.Commands = {}
    self.Add, self.Empty = HarukaLib.Bin()

    return self
end



function HarukaCMD:Init()
    if RunService:IsClient() then
        self.Rank = self.Player:GetAttribute("Rank")
        self.Commands = {}

        self.RefreshCommandBookFunc = function()
            local afterCommands = table.clone(CommandBook)

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

            Events.RequestToExecuteCommand.Fire({
                Command = Fusion.peek(self.CMDInput)
            })
        end


        self:_InitUI()
        self:_ListenUITracker()
        self:_ListenInputTracker()
    else
        self:_InitRequestListenTracker()
        self:_InitCommandExecutionTracker()
    end
end


function HarukaCMD:AddCommand(commandProps: {
    Name: string,
    Alias: string,
    Callback: (...any) -> nil,
    RankReq: number,
    Args: {
        Name: string,
        Type: string
    }
})
    table.insert(self.Commands, commandProps)
end


function HarukaCMD:Destroy()
    if RunService:IsClient() then
        Fusion.doCleanup(self.scope)
    end


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



--// Server Private Methods

function HarukaCMD:_InitRequestListenTracker()
    Events.RequestCommands_Request.SetCallback(function(plr: Player)
        local transformedCommands = {}

        for _, cmd in self.Commands do
            table.insert(transformedCommands, HarukaLib.TableUtils.CopyTableExcept(cmd, { "Callback" }))
        end

        Events.RequestCommands_Response.Fire(plr, {
            Commands = transformedCommands
        })
    end)
end


function HarukaCMD:_InitCommandExecutionTracker()
    Events.RequestToExecuteCommand.SetCallback(function(plr: Player, data)
        local command = data.Command
        if command == nil then return end


        local cmdId = string.match(command, "^(/%S+)")
        if cmdId == "" or cmdId == nil then return end

        local cmdArgs = {}
        local cmdArgsStr = string.gmatch(command, "<([^>]+)>")
        for arg in cmdArgsStr or {} do
            table.insert(cmdArgs, arg)
        end

        local realCmd = nil
        for _, cmdProp in self.Commands do
            if cmdProp.Alias == cmdId then
                realCmd = cmdProp
                break
            end
        end
        if realCmd == nil then return end


        --// return true args
        local check, validatedArgs = self:_ValidateCmd(realCmd, cmdArgs)
        if not check then
            GlobalEvents.CreateNotify_S.Fire(plr, "[Error] Command failed to pass the parameter check!")
            return
        end


        --// Check if the player has the required rank
        if (plr:GetAttribute("Rank") or 0) < realCmd.RankReq then
            GlobalEvents.CreateNotify_S.Fire(plr, "Insufficient permissions!")
            return
        end
        if (plr:GetAttribute("Rank") or 0) == 127 and game.GameId ~= AssetBook.CFUniverseId_Main then
            GlobalEvents.CreateNotify_S.Fire(plr, "We're sorry, but Mods are not allowed to execute commands in test place.")
            return
        end


        Promise.new(function(resolve)
            if not RunService:IsStudio() and realCmd.RankReq > 1 and game.GameId == AssetBook.CFUniverseId_Main then
                Promise.try(function()
                    local WEBHOOK_URL = "http://rainyleaf.xyz:3000/roblox-message"

                    local JSONData = {
                        message = `{plr.Name} executed command: {command} in PlaceId: {game.PlaceId}`
                    }
                    local JSONBody = HttpService:JSONEncode(JSONData)

                    local success, response = pcall(function()
                        return HttpService:PostAsync(WEBHOOK_URL, JSONBody, Enum.HttpContentType.ApplicationJson, false)
                    end)
                    if not success then
                        warn("Failed to send message to webhook: "..tostring(response))
                    end

                end):catch(function(err)
                    warn(tostring(err))
                end)
            end


            realCmd.Callback({
                Executor = plr,
                Args = validatedArgs,

                ResolveObj = resolve
            })
        end):catch(function(err)
            warn(tostring(err))

            GlobalEvents.CreateNotify_S.Fire(plr, "Command execution failed!")
        end)
    end)
end


function HarukaCMD:_ValidateCmd(realCMD: CommandJSON, cmdArgs: { string }) : (boolean, CommandJSON | {})
    local realCMDArgs = table.clone(cmdArgs)

    local args = realCMD.Args
    local check = true

    if HarukaLib.TableUtils.IsEmpty(realCMDArgs) and not HarukaLib.TableUtils.IsEmpty(args) then
        return false, {}
    end
    if #realCMDArgs ~= #args then
        return false, {}
    end

    for index: number, arg: string in realCMDArgs do
        if not args[index] then
            check = false
            break
        end
        if arg == nil or arg == "" then
            check = false
            break
        end

        local argType = args[index].Type
        if argType == "number" then
            if not tonumber(arg) then
                check = false
                break
            end

            local val = tonumber(arg)
            if args[index].ShouldBeInteger then
                if not HarukaLib:TypeCheck("Integer", val) then
                    check = false
                    break
                end
            end
            if args[index].RangeMin then
                if not HarukaLib:TypeCheck("Min", val, { Min = args[index].RangeMin }) then
                    check = false
                    break
                end
            end
            if args[index].RangeMax then
                if not HarukaLib:TypeCheck("Max", val, { Max = args[index].RangeMax }) then
                    check = false
                    break
                end
            end
            if val ~= val then
                check = false
                break
            end

            realCMDArgs[index] = val

        elseif argType == "player" then
            local hasPlayer = false
            for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
                if player.Name == arg then
                    realCMDArgs[index] = player
                    hasPlayer = true
                    break
                end
            end

            if not hasPlayer then
                check = false
                break
            end

        elseif argType == "players" then
            local hasPlayer = false

            if arg ~= "All" then
                for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
                    if player.Name == arg then
                        realCMDArgs[index] = { player }
                        hasPlayer = true
                        break
                    end
                end

                if not hasPlayer then
                    check = false
                    break
                end
            else
                realCMDArgs[index] = CollectionService:GetTagged("PlayerEntity")
            end
        end
    end
    if not check then
        return false, {}
    end

    return true, realCMDArgs
end


return HarukaCMD