--!nocheck

local DialogueBook = {}

--// Main series


--// Side series

DialogueBook.Inter1 = {
    Side1501 = {
        "Go with the blessings of the village. May the spirits guide your way."
    },
    Else = {
        "I have grave news... <yellow>Initus Bay</font> is on the brink of a great peril.",
        "The ancient <yellow>Sky Tower</font>, long dormant, has begun to stir.",
        "It is said that within its highest spire lies a power that could doom us all.",
        "Long ago, our ancestors hid a key, a key that can unlock the secrets of the <yellow>Sky Tower</font>.",
        "Only by finding this key can we hope to avert the coming storm.",
        "<yellow>You</font>, brave adventurer. Your heart is pure, and your spirit is strong.",
        "You must seek out the key and unlock the <yellow>Sky Tower</font>. Only then can we save our village.",
        "Your journey begins at the forest. There, you will find clues that will guide you.",
        "Be cautious, for the path is fraught with peril. But I have faith in you.",
        "Go with the blessings of the village. May the spirits guide your way."
    },

    Extra = {
        Else = "InterSkyTowerQuest"
    }
}


--// Else series


DialogueBook.BlueTea1 = {
    Else = {
        "This dragon is currently very obedient and won't attack people on its own.",
        "Well, at least for the next few days."
    },

    Extra = {}
}



return DialogueBook
