export type GroupRanks = {
    [number]: {
        title: string,
        chatRole: string,
        color: Color3,
    }
}

return table.freeze({
    groupId = 16912246,
    --- Group Rank titles
    groupRanks = {
        --- Tester
        [2] = {
            title = "QA Tester",
            chatRole = "QA",
            color = Color3.fromRGB(112, 161, 255),
        },
        --- Content Creator
        [3] = {
            title = "Content Creator",
            chatRole = "Content Creator",
            color = Color3.fromRGB(214, 48, 49),
        },
        --- Translator
        [4] = {
            title = "Translator",
            chatRole = "Translator",
            color = Color3.fromRGB(255, 255, 255),
        },
        --- Contributor
        [125] = {
            title = "Contributor",
            chatRole = "Contributor",
            color = Color3.fromRGB(255, 255, 255),
        },
        --- Moderator
        [127] = {
            title = "Moderator",
            chatRole = "Moderator",
            color = Color3.fromRGB(255, 255, 255),
        },
        --- Developer
        [128] = {
            title = "Developer",
            chatRole = "Developer",
            color = Color3.fromRGB(255, 234, 167),
        },
        --- Lead Developer
        [129] = {
            title = "Lead Developer",
            chatRole = "Lead Developer",
            color = Color3.fromRGB(129, 236, 236),
        },
    } :: GroupRanks,
    --- Prioritised over group rank titles
    userPersonalTitles = {
        --- iDemandSky
        [267186225] = {
            title = "System Administrator",
            chatRole = "System Admin",
            color = Color3.fromRGB(45, 112, 255),
        },
    },
})