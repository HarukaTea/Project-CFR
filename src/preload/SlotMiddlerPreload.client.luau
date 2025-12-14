
repeat task.wait() until workspace:GetAttribute("Titlescreen_LoadSlot")

local RepS = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Debris = game:GetService("Debris")
local SocialService = game:GetService("SocialService")


local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)


local LoadView = require(RepS.HarukaShared.UIAtlas.Components.LoadView)


local wait = task.wait


local slotId = workspace:GetAttribute("Titlescreen_SlotId") or 1


local enableFeedback = false
local enableFav = false
local enableMobileSettings = false
local scope = Fusion.scoped()
local loadViewUI: ScreenGui = nil


local shouldShow = enableFav or enableMobileSettings



if shouldShow then
    local LoadView = require(RepS.HarukaShared.UIAtlas.Components.LoadView)
    local LoadingTextVal = Fusion.Value(scope, "Taking a break...")

    loadViewUI = LoadView(scope, {
        LoadingText = LoadingTextVal
    })
    HarukaLib:UITween(loadViewUI, "In")
end



if enableMobileSettings then

end


if enableFav then
    local result = Components:CreateConfirmPrompt(scope, {
        CancelText = "No",
        ConfirmText = "Yes",
        Hint = "You've played for over 30 mins! Would you like to favorite the game?",
        ConfirmUniqueId = "FavTitlescreen"
    }):Wait()

    if result == "YES" then
        AvatarEditorService:PromptSetFavorite(AssetBook.PlaceIds["7037847546"].Mainworld, Enum.AvatarItemType.Asset, true)
        wait(2)
    end
end



if enableFeedback then
    local result = Components:CreateConfirmPrompt(scope, {
        CancelText = "No",
        ConfirmText = "Yes",
        Hint = "You've played for an hour! Got a minute to give us some feedback?",
        ConfirmUniqueId = "FavTitlescreen"
    }):Wait()

    if result == "YES" then
        local success, err = pcall(function()
            SocialService:PromptFeedbackSubmissionAsync()
        end)
        if not success then
            print(err)
        end
        wait(2)
    end
end







if shouldShow then
    HarukaLib:UITween(loadViewUI, "Out", {
        TweenCallback = function()
            Fusion.doCleanup(scope)
        end
    })
end



--// entering the game
Bindables.CreateCircularFade:Fire(2)

Events.Titlescreen_SlotActions_C.Fire({
    ActionId = "Play",
    SlotId = "Slot"..slotId
})


Debris:AddItem(script, 30)