
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

local keybinds = {
    PC = {},
    Console = {}
}


keybinds.KEYBIND_NAMES = {
    PromptTrigger = "Trigger Prompt",
    Backpack = "Backpack",
    CharSelfView = "Character Stats",
    Settings = "Settings",
    ClassUlt = "Class Ultimate",
    Active1 = "Active Skill 1",
    Active2 = "Active Skill 2",
    Active3 = "Active Skill 3",
    Dash = "Dash",
    TargetSwitch = "Target Switch"
}



keybinds.PC.PromptTrigger = Enum.KeyCode.F
keybinds.Console.PromptTrigger = Enum.KeyCode.ButtonY


keybinds.PC.Backpack = Enum.KeyCode.B
keybinds.PC.CharSelfView = Enum.KeyCode.C
keybinds.PC.Settings = Enum.KeyCode.N

keybinds.PC.ClassUlt = Enum.KeyCode.Q
keybinds.PC.Active1 = Enum.KeyCode.One
keybinds.PC.Active2 = Enum.KeyCode.Two
keybinds.PC.Active3 = Enum.KeyCode.Three
keybinds.PC.Dash = Enum.KeyCode.R
keybinds.PC.TargetSwitch = Enum.KeyCode.LeftAlt

keybinds.Console.ClassUlt = Enum.KeyCode.ButtonY
keybinds.Console.Active1 = Enum.KeyCode.ButtonL1
keybinds.Console.Active2 = Enum.KeyCode.ButtonR1
keybinds.Console.Active3 = Enum.KeyCode.ButtonR2
keybinds.Console.Dash = Enum.KeyCode.ButtonX
keybinds.Console.TargetSwitch = Enum.KeyCode.DPadRight




keybinds.KEYBIND_ID_NAMES = {
    LeftCurly = "{",
    RightCurly = "}",
    Pipe = "|",
    Tilde = "~",
    Delete = "Del",
    One = "1",
    Two = "2",
    Three = "3",
    Four = "4",
    Five = "5",
    Six = "6",
    Seven = "7",
    Eight = "8",
    Nine = "9",
    Zero = "0",
    Colon = ":",
    Semicolon = ";",
    LessThan = "<",
    GreaterThan = ">",
    Equals = "=",
    Question = "?",
    At = "@",
    LeftBracket = "[",
    RightBracket = "]",
    Backslash = [[\]],
    Caret = "^",
    Underscore = "_",
    Backquote = "`",
    Return = "Enter",
    Escape = "Esc",
    QuotedDouble = [["]],
    Hash = "#",
    Dollar = "$",
    Percent = "%",
    Ampersand = "&",
    Quote = [[']],
    LeftParenthesis = "(",
    RightParenthesis = ")",
    Asterisk = "*",
    Plus = "+",
    Comma = ",",
    Minus = "-",
    Period = ".",
    Slash = "/",

    KeypadZero = "0",
    KeypadOne = "1",
    KeypadTwo = "2",
    KeypadThree = "3",
    KeypadFour = "4",
    KeypadFive = "5",
    KeypadSix = "6",
    KeypadSeven = "7",
    KeypadEight = "8",
    KeypadNine = "9",
    KeypadPeriod = ".",
    KeypadDivide = "/",
    KeypadMultiply = "*",
    KeypadMinus = "-",
    KeypadPlus = "+",
    KeypadEnter = "Enter",
    KeypadEquals = "=",

    PageUp = "PgUp",
    PageDown = "PgDn",

    RightShift = "RShift",
    LeftShift = "LShift",
    RightControl = "RCtrl",
    LeftControl = "LCtrl",
    RightAlt = "RAlt",
    LeftAlt = "LAlt",
    RightMeta = "RMeta",
    LeftMeta = "LMeta",
    LeftSuper = "LSuper",
    RightSuper = "RSuper",

    DPadLeft = "Left",
    DPadRight = "Right",
    DPadUp = "Up",
    DPadDown = "Down",
}
for _, keycode: Enum.KeyCode in Enum.KeyCode:GetEnumItems() do
    if string.find(keycode.Name, "Button") and string.sub(keycode.Name, 1, 6) == "Button" then
        keybinds.KEYBIND_ID_NAMES[keycode.Name] = string.sub(keycode.Name, 7)
    end
end


keybinds.OnKeybindChanged = Signal.new()


return keybinds