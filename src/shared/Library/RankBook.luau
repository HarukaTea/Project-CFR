
export type RankRoleJSON = {
    Role: string,
    Color: string
}
export type CustomRoleJSON = {
    Role: string,
    Color: string,
    ChatRole: string
}


local Ranks = {}

Ranks.RankRoleInfo = {
    [2] = {
        Role = "Tester",
        Color = "#70a1ff"
    },
    [3] = {
        Role = "Content Creator",
        Color = "#ffffff"
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
        Color = "#ffffff",
        ChatRole = "DEV"
    },
    [129] = {
        Role = "Lead Developer",
        Color = "#ffffff",
        ChatRole = "DEV"
    },
    [254] = {
        Role = "Herman",
        Color = "#e91e63"
    },
}
Ranks.CustomRoleInfo = {
    ["304008764"] = {
        Role = "CF Founder",
        Color = "#ffffff",
        ChatRole = "DEV"
    },
    ["68027875"] = {
        Role = "CW Founder",
        Color = "#ffa502",
        ChatRole = "Eth"
    },
    ["2040399306"] = {
        Role = "CSV Founder",
        Color = "#ffa502",
        ChatRole = "AKM"
    },
    ["1097119343"] = {
        Role = "CV Founder",
        Color = "#ffa502"
    },
    ["3563941913"] = {
        Role = "CO Founder",
        Color = "#ffa502"
    },
    ["91364976"] = {
        Role = "CR Founder",
        Color = "#ffa502",
        ChatRole = "Luigit"
    },
    ["28635029"] = {
        Role = "CL2 Founder",
        Color = "#ffa502"
    },
    ["224796939"] = {
        Role = "CE Founder",
        Color = "#ffa502",
    }
}

return Ranks