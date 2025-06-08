

local PerkBook = {}


local template = {
    Id = "",
    Name = "",
    Desc = "",
    Req = 0,
    Type = "STR?",
    Icon = ""
}


PerkBook.STR = {
    {
        Id = "HeavyHit",
        Name = "Heavy Hit",
        Desc = "<red>+5% ATK</font>",
        Req = 5,
        Type = "STR",
        Icon = "rbxassetid://71323680044836"
    },
    {
        Id = "Endurance",
        Name = "Endurance",
        Desc = "<green>+5% Max Health</font>",
        Req = 10,
        Type = "STR",
        Icon = "rbxassetid://2965863677"
    },
    {
        Id = "IronWill",
        Name = "Your Will",
        Desc = "<green>+5% Knockback Reduction</font>",
        Req = 20,
        Type = "STR",
        Icon = "rbxassetid://2970818097"
    },
    {
        Id = "FirstStrike",
        Name = "Morph Strike",
        Desc = "Damage to full health monsters <red>+10%</font>",
        Req = 30,
        Type = "STR",
        Icon = "rbxassetid://73146024586376"
    },
    {
        Id = "WarriorPride",
        Name = "Warrior's Pride",
        Desc = "<red>+10% ATK</font>",
        Req = 50,
        Type = "STR",
        Icon = "rbxassetid://17355782628"
    }
}


PerkBook.INT = {
}


PerkBook.VIT = {

}


PerkBook.DEX = {

}



return PerkBook
