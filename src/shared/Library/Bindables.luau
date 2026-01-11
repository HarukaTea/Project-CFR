
return {
    ---@params: `(slotId: number)`
    CDEndTimeReached = Instance.new("BindableEvent"),

    ---@params: `None`
    ActionSlide = Instance.new("BindableEvent"),

    ---@params: `None`
    CloseExplorerUIs = Instance.new("BindableEvent"),



    ---@params: `(message: string, sender: Player)`
    PlayerChatted = Instance.new("BindableEvent"),

    ---@params: `(anim: string)`
    PlayClassAnim = Instance.new("BindableEvent"),

    ---@params: `(data: {TweenInfo: string, Goal: { [string]: any }, Objs: { Instance }, UseHarukaTween: boolean?} )`
    ClientTween = Instance.new("BindableEvent"),

    --@parmas: `(sound: Sound)`
    PlaySound = Instance.new("BindableEvent"),

    ---@params: `(part: BasePart)`
    UpdateCameraPart = Instance.new("BindableEvent"),

    ---@params: `(cframe: CFrame)`
    UpdateCameraCF = Instance.new("BindableEvent"),

    ---@params: `(msg: string)`
    CreateNotify = Instance.new("BindableEvent"),

    ---@params: `(msg: string)`
    CreateSystemNotify = Instance.new("BindableEvent"),

    ---@params: `(msg: string, duration: number)`
    CreateFSNotify = Instance.new("BindableEvent"),

    ---@params: `(data: {Hint: string, ConfirmText: string, CancelText: string, ConfirmUniqueId: string} )`
    CreateConfirmPrompt = Instance.new("BindableEvent"),

    ---@params: `(text: string, showBar: boolean)`
    CreateCenterNotify = Instance.new("BindableEvent"),

    ---@params: `(duration: number)`
    CreateCircularFade = Instance.new("BindableEvent"),

    ---@params: `(uniqueId: string, result: "YES" | "NO")`
    ConfirmPromptChosen = Instance.new("BindableEvent"),

    ---@params: `(prompt: ProximityPrompt)`
    PromptTriggered = Instance.new("BindableEvent"),



    ---@params: `None`
    DevProductPurchasing = Instance.new("BindableEvent"),

    ---@params: `None`
    RToCreatePartyInvite = Instance.new("BindableEvent"),
}