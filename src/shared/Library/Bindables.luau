
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    CDEndTimeReached = Signal.new(),
    RequestToResetItemCD = Signal.new(),

    PlayerChatted = Signal.new(),
    PlayAnimation = Signal.new(),
    ClientTween = Signal.new(),
    PlaySound = Signal.new(),
    PlayCameraCutscene = Signal.new(),


    CreateNotify = Signal.new(),
    CreateSystemNotify = Signal.new(),
    CreateFSNotify = Signal.new(),
    CreateConfirmPrompt = Signal.new(),
    CreateCenterNotify = Signal.new(),
    CreateCircularFade = Signal.new(),

    ConfirmPromptChosen = Signal.new(),
}