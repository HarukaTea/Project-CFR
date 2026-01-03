
export type RankRoleJSON = {
    Role: string,
    Color: string
}
export type CustomRoleJSON = {
    Role: string,
    Color: string,
    ChatRole: string
}

export type PlayerTitleJSON = {
    Title: string,
    Color: string,
    ChatRole: string?
}


local RankBook = {}

RankBook.RankRoleInfo = {
    [2] = {
        Role = "Tester",
        Color = "#70a1ff"
    },
    [3] = {
        Role = "Content Creator",
        Color = "#d63031",
        ChatRole = "YT"
    },
    [4] = {
        Role = "Translator",
        Color = "#ffffff"
    },
    [125] = {
        Role = "Contributor",
        Color = "#ffffff"
    },
    [127] = {
        Role = "Mod",
        Color = "#ffffff"
    },
    [128] = {
        Role = "Developer",
        Color = "#ffeaa7",
        ChatRole = "Dev"
    },
    [129] = {
        Role = "Lead Developer",
        Color = "#81ecec",
        ChatRole = "Lead"
    },
    [254] = {
        Role = "Herman",
        Color = "#e91e63"
    },
}
RankBook.CustomRoleInfo = {
    ["304008764"] = {
        Role = "CF Founder",
        Color = "#ffa502",
        ChatRole = "Leaf"
    },
    ["68027875"] = {
        Role = "CW Founder",
        Color = "#ffa502",
        ChatRole = "Ethyrias"
    },
    ["2040399306"] = {
        Role = "CSV Founder",
        Color = "#ffa502",
        ChatRole = "AKM"
    },
    ["1097119343"] = {
        Role = "CV Founder",
        Color = "#ffa502",
        ChatRole = "FrenchCat"
    },
    ["3563941913"] = {
        Role = "CO Founder",
        Color = "#ffa502",
        ChatRole = "Pika"
    },
    ["91364976"] = {
        Role = "CR Founder",
        Color = "#ffa502",
        ChatRole = "Luigit"
    },
    ["28635029"] = {
        Role = "CL2 Founder",
        Color = "#ffa502",
        ChatRole = "Levon"
    },
    ["224796939"] = {
        Role = "CE Founder",
        Color = "#ffa502",
        ChatRole = "Lychee"
    }
}




RankBook.PlayerTitleInfo = {
}


RankBook.PlayerTitles = {
    TitleExplorer = "Explorer",
    TitleAdventurer = "Adventurer",
    TitleAbyss = "Abyss Conqueror",
    TitleAbyssT6 = "The Abyss",
    TitleSantaHelper = "Santa's Helper",
    TitleCapybara = "Capybara",
}



return RankBook