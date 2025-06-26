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


DialogueBook.Bob1 = {
    Else = {
        "Oh, a traveler! It's been a long time since I've seen a new face... especially a lively young one like yourself.",
        "Ever since the 'Critical War,' this harbor has gone from bad to worse. The tides grew fiercer, and the sea monsters became more numerous.",
        "Our boats are constantly damaged, and the dock is barely holding on. We used to be self-sufficient, but now... life gets harder every day.",
        "You don't seem like an ordinary person; there's a special strength about you... Perhaps you could help us?",
        "Our Initus Bay was once an important supply point on the continent of Alter, but now, we desperately need repairs so we can continue fishing and keep our town alive.",
        "We need materials, we need skilled hands, and most of all... we need some funding. ",
        "This amount of money is a huge expense for our small town. I know it's a lot to ask, but every bit of help, no matter how small, means the world to us.",
        "If you're willing to lend a hand, you just need to click on donation UI on your screen, and you'll see how you can contribute. No matter the amount, we'll be eternally grateful.",
        "May the wind spirits bless your journey, traveler. I hope Initus Bay will see its glory days again."
    },

    Extra = {}
}
DialogueBook.Piranha1 = {
    Else = {
        "The start of the world...",
        "The key of the Alter Continent...",
        "The start of a new era...",
        "The truth behind the code..."
    },

    Extra = {}
}
DialogueBook.Piranha2 = {
    Else = {
        "Send the correct code to #key-finding"
    },

    Extra = {}
}



return DialogueBook
