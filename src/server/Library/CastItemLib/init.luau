
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)


local Types = require(script.Types)


export type CastItemLib = Types.CastItemLib


local CastItemLib = {} :: CastItemLib

local wait = task.wait




local function _preCheck(props: {
    ReqCombat: boolean,
    ReqEnemy: boolean,
}, data: {
    ItemId: string,
    Player: Player,
    Char: Model
}) : boolean

    local player, char = data.Player, data.Char


    if not player or not char then
        return false
    end
    if not ServerLib.IsCharValid(char) then
        return false
    end
    if not ItemBook:GetItemInfo(data.ItemId) then
        Events.CreateNotify_S.Fire(player, "[Error] Invalid Item Id")
        return false
    end
    if props.ReqCombat then
        if not char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(player, "You need to be in combat mode to use this item!")
            return false
        end
    end
    if props.ReqEnemy then
        if not char.TargetingEnemy.Value then
            Events.CreateNotify_S.Fire(player, "You need to have a target monster to use this item!")
            return false
        end

        local enemy = char.TargetingEnemy.Value :: Model
        if not ServerLib.IsCharValid(enemy) then
            Events.CreateNotify_S.Fire(player, "[Error] Invalid Target Entity")
            return false
        end
    end

    return true
end
local function _eatSoundFunc(char: Model, func: () -> nil)
    local eatSound = SoundService.SFXs.EatSound :: Sound
    ServerLib.PlayWorldSound(eatSound, char.PrimaryPart.Position)


    task.delay(eatSound.TimeLength / 2, func)
end
local function _drinkSoundFunc(char: Model, func: () -> nil)
    local drinkSound = SoundService.SFXs.DrinkSound :: Sound
    ServerLib.PlayWorldSound(drinkSound, char.PrimaryPart.Position)


    task.delay(drinkSound.TimeLength / 2, func)
end



CastItemLib._preCheck = _preCheck
CastItemLib._eatSoundFunc = _eatSoundFunc
CastItemLib._drinkSoundFunc = _drinkSoundFunc



for _, module: ModuleScript in script.Library:GetChildren() do
    CastItemLib[module.Name] = function(...)
        require(module)(CastItemLib, ...)
    end
end
for _, module: ModuleScript in script.LibrarySP:GetChildren() do
    require(module)(CastItemLib)
end


return CastItemLib