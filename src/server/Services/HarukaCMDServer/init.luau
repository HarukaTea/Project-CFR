
--// Cmd for my own projects

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")


local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Events = require(script.ServerEvents)
local GlobalEvents = require(SSS.HarukaServer.Library.ServerEvents)



local Types = require(script.Types)


export type CommandJSON = Types.CommandJSON
export type HarukaCMDClass = Types.HarukaCMDClass



local HarukaCMD = {} :: Types.HarukaCMDClass
HarukaCMD.__index = HarukaCMD


--// Constructor
function HarukaCMD.new() : Types.HarukaCMDClass
    local self = setmetatable({}, HarukaCMD)

    self.Commands = {}
    self.Add, self.Empty = HarukaLib.Bin()

    return self
end



function HarukaCMD:Init()
    self:_InitRequestListenTracker()
    self:_InitCommandExecutionTracker()
end


function HarukaCMD:AddCommandBook(commandBook: { CommandJSON })
    for _, commandProps in commandBook do
        table.insert(self.Commands, commandProps)
    end
end


function HarukaCMD:Destroy()
    self.Empty()
end


--// Private Methods


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
            GlobalEvents.CreateNotify_S.Fire(plr, "[Error] Invalid Arguments")
            return
        end


        --// Check if the player has the required rank
        if (plr:GetAttribute("Rank") or 0) < realCmd.RankReq then
            GlobalEvents.CreateNotify_S.Fire(plr, "Permission Denied")
            return
        end


        Promise.new(function(resolve)
            if not RunService:IsStudio() and realCmd.RankReq > 1 and game.GameId == AssetBook.CFUniverseId_Main then
                Promise.try(function()
                    local WEBHOOK_URL = "http://rainyleaf.xyz:1599/roblox-message"

                    local JSONData = {
                        message = `{plr.Name} executed command: {command} in World: {workspace:GetAttribute("WorldId") or "Unknown"}`,
                        secretKey = "1599mkk40_fallen_forever"
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

            GlobalEvents.CreateNotify_S.Fire(plr, "Command Error")
        end)
    end)
end


function HarukaCMD:_ValidateCmd(realCMD: CommandJSON, cmdArgs: { string }) : (boolean, CommandJSON | {})
    local realCMDArgs = HarukaLib.TableUtils.DeepCopy(cmdArgs)

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