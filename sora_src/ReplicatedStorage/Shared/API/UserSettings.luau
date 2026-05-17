local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums
local Typing = ReplicatedStorage.Constants.Typing
local Packages = ReplicatedStorage.Packages

local UserSettingsEnum = require(Enums.UserSettings)

local UserSettingsTyping = require(Typing.UserSettings)

local TableUtil = require(Packages.TableUtil)
local EnumList = require(Packages.EnumList)

type AllEntries = UserSettingsTyping.AllEntries
type AllowedEntries = UserSettingsTyping.AllowedEntries
type AllTypes = UserSettingsTyping.AllTypes
type AllSettingsData = {
    [string]: AllEntries
}

local categories = TableUtil.Keys(UserSettingsEnum.details) :: { string }
local allowedDetailTypes = {} :: { [AllTypes]: true }
local allSettings = {} :: AllowedEntries
local settingEnums = {} :: { [string]: typeof(EnumList.new) }
--- settingName: its category within `categories`
local settingCategory = {} :: { [string]: string }
local api = {}

local function extractDetails(settingsData: AllSettingsData, allowNesting: boolean, category: string)
    for name: string, detail: AllEntries in settingsData do
        local detailType: string = detail.type
        local isValidSetting, message = UserSettingsTyping.allEntriesT(detail)
        local isContainer: boolean = detailType == "Container"
        local alreadyExists: boolean = allSettings[name] ~= nil
        
        if not allowedDetailTypes[detailType] then
            warn(`User setting called '{name}' does not have a valid type (value: {detailType}).`)
            continue
        end

        if not isValidSetting then
            warn(`User setting called '{name}' does not have a valid setting. {message}`)
            continue
        end

        if alreadyExists then
            warn(`There is an existing user setting called '{name}'. Skipping.`)
            continue
        end

        if isContainer and not allowNesting then
            warn(`User setting container called '{name}' is not allowed to be in nested container.`)
            continue
        end

        if isContainer and allowNesting then
            extractDetails(detail.settings, false, category)
            continue
        end

        allSettings[name] = detail
        settingCategory[name] = category

        if detailType == "Enum" then
            local newEnum = EnumList.new(name, detail.options, category)
            settingEnums[name] = newEnum
        end
    end
end

-- API --

function api.hasCategory(name: string): boolean
    return table.find(categories, name) ~= nil
end

function api.getCategories(): { string }
    return categories
end

--- Retrieves all settings within the category. Returns nil if the category doesn't exist.
--- This does not include containers but includes the settings in it.
function api.getSettingsByCategory(category: string): AllSettingsData?
    return UserSettingsEnum.details[category]
end

function api.isInCategory(settingName: string, categoryName: string): (boolean, string?)
    if not api.hasCategory(categoryName) then
        return false, `User setting category '{categoryName}' does not exist.`
    end

    if settingCategory[settingName] ~= categoryName then
        return false, `User setting '{settingName}' is not a part of category '{categoryName}'.`
    end

    return true, nil
end

function api.getSetting(name: string): AllowedEntries
    return allSettings[name]
end

--- Checks if the setting exists. If it does, it returns the enum associated with the setting. Otherwise, it returns nil.
function api.exists(settingName: string): boolean
    return api.getSetting(settingName) ~= nil
end

--- Only applies to enum settings. Returns the enum if it exists, otherwise returns nil.
function api.getEnum(settingName: string): typeof(EnumList.new)?
    return settingEnums[settingName]
end

function api.getDefaultValue(settingName: string): any?
    if not api.exists(settingName) then
        warn(`User settings called '{settingName}' doesn't exist to get the default value.`)
        return nil
    end

    local setting = api.getSetting(settingName)
    return setting.default
end

--- Returns the result, finalised value (nil if setting name not found), and error message (optional, nil if success).
--- Enum settings will translate the value as numbers within the enum range.
function api.validateInput(settingName: string, value: any): (boolean, any?, string?)
    if not api.exists(settingName) then
        return false, nil, `User settings called '{settingName}' doesn't exist to validate the value! (value: {value}, type: {typeof(value)}).`
    end

    local setting = api.getSetting(settingName)
    local settingType = setting.type
    local valueChecker = UserSettingsTyping.valueCheckers[settingType]
    local isValid, message = valueChecker(value)

    if not isValid then
        return false, api.getDefaultValue(settingName), message or `Provided value '{tostring(value)}' is not valid (type: {typeof(value)}).`
    end

    return true, value, nil
end

-- INITIALISATION --

for _, settingType in UserSettingsEnum.settingTypes do
    allowedDetailTypes[settingType] = true
end

for category: string, allSettings: AllSettingsData in UserSettingsEnum.details do
    extractDetails(allSettings, true, category)
end

return table.freeze(api)