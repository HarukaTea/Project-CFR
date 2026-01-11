
repeat task.wait() until workspace:GetAttribute("Titlescreen_LoadSlot")

if workspace:GetAttribute("ShouldSkipTitlescreen") then
    script:Destroy()
    return
end

local RepS = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)


local wait = task.wait


local slotId = workspace:GetAttribute("Titlescreen_SlotId") or 1

local profileContainer = Players.LocalPlayer.ProfileContainer :: Folder

local playTime = profileContainer:GetAttribute("Slot"..slotId.."_PlayTime") or 0 :: number
local isFav = profileContainer:GetAttribute("Slot"..slotId.."_FavActionDone") or false :: boolean


local enableFav = playTime >= 60 * 60 * 1 and isFav == false
local scope = Fusion.scoped()
local loadViewUI: ScreenGui = nil


local shouldShow = enableFav


Bindables.CreateCircularFade:Fire(2)


if shouldShow then
    wait(1)
    local LoadView = require(RepS.HarukaShared.UIAtlas.Components.LoadView)
    local LoadingTextVal = Fusion.Value(scope, "Taking a break...")

    loadViewUI = LoadView(scope, {
        LoadingText = LoadingTextVal
    })
    HarukaLib:UITween(loadViewUI, "In")

    wait(2.5)
end



if enableFav then
    local result = Components:CreateConfirmPrompt(scope, {
        CancelText = "No",
        ConfirmText = "Yes",
        Hint = "You've played for over 30 mins! Would you like to favorite the game?",
        ConfirmUniqueId = "FavTitlescreen"
    }).Event:Wait()

    if result == "YES" then
        pcall(function()
            AvatarEditorService:PromptSetFavorite(AssetBook.PlaceIds["7037847546"].Mainworld, Enum.AvatarItemType.Asset, true)
        end)
    end
    wait(2)
end




if shouldShow then
    Bindables.CreateCircularFade:Fire(2)

    wait(1)
    HarukaLib:UITween(loadViewUI, "Out", {
        TweenCallback = function()
            Fusion.doCleanup(scope)
        end
    })
end



--// entering the game
Events.Titlescreen_SlotActions_C.Fire({
    ActionId = "Play",
    SlotId = "Slot"..slotId,

    SlotMiddler = {
        Favorited = enableFav,
    }
})

if not shouldShow then
    wait(1.15)
end


Debris:AddItem(script, 30)