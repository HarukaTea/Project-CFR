
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    --@params: `(slotId: number)`
    CDEndTimeReached = Signal.new(),

    --@params: `None`
    ActionSlide = Signal.new(),

    --@params: `None`
    CloseExplorerUIs = Signal.new(),



    --@params: `(message: string, sender: Player)`
    PlayerChatted = Signal.new(),

    --@params: `(anim: string)`
    PlayClassAnim = Signal.new(),

    --@params: `(data: {TweenInfo: string, Goal: { [string]: any }, Objs: { Instance }, UseHarukaTween: boolean?} )`
    ClientTween = Signal.new(),

    --@parmas: `(sound: Sound)`
    PlaySound = Signal.new(),

    --@params: `(part: BasePart)`
    UpdateCameraPart = Signal.new(),

    --@params: `(cframe: CFrame)`
    UpdateCameraCF = Signal.new(),

    --@params: `(msg: string)`
    CreateNotify = Signal.new(),

    --@params: `(msg: string)`
    CreateSystemNotify = Signal.new(),

    --@params: `(msg: string, duration: number)`
    CreateFSNotify = Signal.new(),

    --@params: `(data: {Hint: string, ConfirmText: string, CancelText: string, ConfirmUniqueId: string} )`
    CreateConfirmPrompt = Signal.new(),

    --@params: `(text: string, showBar: boolean)`
    CreateCenterNotify = Signal.new(),

    --@params: `(duration: number)`
    CreateCircularFade = Signal.new(),

    --@params: `(uniqueId: string, result: "YES" | "NO")`
    ConfirmPromptChosen = Signal.new(),

    --@params: `(prompt: ProximityPrompt)`
    PromptTriggered = Signal.new(),



    --@params: `None`
    DevProductPurchasing = Signal.new(),

    --@params: `(state: boolean)`
    SetChatEnabled = Signal.new(),


    --@params: `None`
    RToCreatePartyInvite = Signal.new(),
}