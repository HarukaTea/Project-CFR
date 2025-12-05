
local RepS = game:GetService("ReplicatedStorage")

local ItemRawBook = require(RepS.HarukaShared.Library.ItemRawBook)

local ItemBook = {}


export type ItemBookRawJSON = {
    ItemId: string,
    Name: string,
    Type: string,
    Tier: string,
    Level: string,
    Desc: string,
    Stat: string,
    StatInfo: string,
    Icon: string,
    Price: string,
    SellPrice: string,
    ExtraStatInfo: string,
    Recipe: string,
    ArtifactId: string,
    Tags: string,
}
export type ItemBookJSON = {
    ItemId: string,
    Name: string,
    Type: string,
    Tier: number,
    Level: number,
    Desc: string,
    Stat: string,
    StatInfo: string,
    Icon: string,
    Price: number,
    SellPrice: number,
    ExtraStatInfo: string,
    Recipe: string,
    ArtifactId: string,
    Tags: string,

    StatInfoDesync: { [string]: any },
    ExtraStatInfoDesync: { [string]: any },
    RecipeDesync: { [string]: any },
    TagsDesync: { string },
}


ItemBook.PackItemAttrToTable = function(_, itemSymbol: IntValue) : { [string]: any }
    local attrs = {}

    for attr: string, val: any in itemSymbol:GetAttributes() do
        if string.find(attr, "ATTR_") then
            attrs[string.sub(attr, 6)] = val
        end
    end

    return attrs
end


ItemBook.DesyncItemStat = function(_, infoType: "Stat" | "Extra", info: { string }) : { [string]: any }
    local attrs = {}

    if infoType == "Extra" then
        for _, stat: string in info do
            local ex, val = string.match(stat, "(%a+)%((%-?%d+)%)")
            if ex == nil or val == nil then continue end

            if val == "159940" then --// a special number that means it's a boolean
                val = true
            else
                if tonumber(val) then val = tonumber(val) end
            end

            attrs[ex] = val
        end

    elseif infoType == "Stat" then
        for _, stat: string in info do
            if string.find(stat, "Can") then
                attrs[stat] = true
                continue

            elseif string.find(stat, "ForClass") then
                local attr, content = string.match(stat, "^(.-)%((.-)%)$")
                if attr == nil or content == nil then continue end

                attrs[attr] = content
                continue
            end

            local ex, val = string.match(stat, "(%a+)%((%-?%d+)%)")
            if ex == nil or val == nil then continue end

            attrs[ex] = tonumber(val) or 0
        end
    end


    return attrs
end


ItemBook.PackTableToItemStat = function(_, infoType: "Stat" | "Extra", info: { [string]: any }) : string
    local randomStat = ""

    if infoType == "Stat" then
        for attr: string, val: any in info do
            if typeof(val) == "boolean" then
                if val == true then
                    randomStat..= ","..attr
                end

            elseif typeof(val) == "string" or typeof(val) == "number" then
                randomStat ..= ","..attr.."("..val..")"
            end
        end
        if string.sub(randomStat, 1, 1) == "," then
            randomStat = string.sub(randomStat, 2)
        end
    end

    return randomStat
end




ItemBook.GetItemInfo = function(_, itemId: string) : ItemBookJSON
    local itemInfo = nil

    for _, thatItemInfo in ItemRawBook do
        if thatItemInfo.ItemId == itemId then
            itemInfo = thatItemInfo
            break
        end
    end

    return itemInfo
end


ItemBook.GetAllItems = function(_) : { string }
    local itemIds = {}

    for _, itemInfo in ItemRawBook do
        table.insert(itemIds, itemInfo.ItemId)
    end

    return itemIds
end


ItemBook.GetAllMaterialsLoot = function(_) : { [string]: number }
    local materialsLoot = {}

    for _, itemInfo in ItemRawBook do
        if table.find(itemInfo.TagsDesync, "Abyss") then
            materialsLoot[itemInfo.ItemId] = 10
        end
    end

    return materialsLoot
end




--// handle item book

for index: number, itemInfo: ItemBookRawJSON in ItemRawBook do
    local itemInfo = table.clone(itemInfo)

    itemInfo.ExtraStatInfoDesync = {}
    itemInfo.StatInfoDesync = {}
    itemInfo.RecipeDesync = {}
    itemInfo.TagsDesync = {}


    itemInfo.Tier = tonumber(itemInfo.Tier) or 1
    itemInfo.Level = tonumber(itemInfo.Level) or 1
    itemInfo.Icon = "rbxassetid://"..itemInfo.Icon
    itemInfo.Price = tonumber(itemInfo.Price) or 1599
    itemInfo.SellPrice = tonumber(itemInfo.SellPrice) or 1599


    --// desync extra info
    if itemInfo.ExtraStatInfo ~= "" then
        local extraInfo = itemInfo.ExtraStatInfo

        extraInfo = string.gsub(extraInfo, " ", "")
        local attrsExtra = string.split(extraInfo, ",")

        itemInfo.ExtraStatInfoDesync = ItemBook:DesyncItemStat("Extra", attrsExtra)
    end

    --// desync stat info
    if itemInfo.StatInfo ~= "" then
        local statInfo = itemInfo.StatInfo

        statInfo = string.gsub(statInfo, " ", "")
        local attrs = string.split(statInfo, ",")

        itemInfo.StatInfoDesync = ItemBook:DesyncItemStat("Stat", attrs)
    end

    --// desync recipe
    if itemInfo.Recipe ~= "" then
        local recipeInfo = itemInfo.Recipe

        recipeInfo = string.gsub(recipeInfo, " ", "")
        local attrs = string.split(recipeInfo, ",")

        itemInfo.RecipeDesync = ItemBook:DesyncItemStat("Extra", attrs)
    end

    --// desync tags
    if itemInfo.Tags ~= "" then
        local tags = itemInfo.Tags
        tags = string.gsub(tags, " ", "")

        itemInfo.TagsDesync = string.split(tags, ",")
    end

    --// add passive info
    if itemInfo.Type == "Passive" then
        itemInfo.Stat = "<yellow>(Passive will work without equipping)</font> <br/>"..itemInfo.Stat
    end

    ItemRawBook[index] = itemInfo
end

return ItemBook