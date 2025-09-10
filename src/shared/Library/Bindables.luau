--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    CDEndTimeReached = Signal.new(),
    ActionSlide = Signal.new(),

    PlayerChatted = Signal.new(),
    PlayAnimation = Signal.new(),
    PlayRawAnimation = Signal.new(),
    CancelRawAnimation = Signal.new(),
    ClientTween = Signal.new(),
    PlaySound = Signal.new(),
    PlayCameraCutscene = Signal.new(),


    CreateNotify = Signal.new(),
    CreateSystemNotify = Signal.new(),
    CreateFSNotify = Signal.new(),
    CreateConfirmPrompt = Signal.new(),
    CreateInfoPrompt = Signal.new(),
    CreateCenterNotify = Signal.new(),
    CreateCircularFade = Signal.new(),

    ConfirmPromptChosen = Signal.new(),


    Titlescreen_ChangeClassScene = Signal.new(),
    Titlescreen_CameraCFrameChanged = Signal.new(),

    DisplayTutorialTopic = Signal.new(),
}