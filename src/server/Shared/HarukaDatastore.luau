

--// Inspired by ProfileStore, but we dont need to worry about multi-server safety, etc
--// @Author: HarukaTea


local DSS = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


export type Dict = {[string]: any}
export type Profile<T> = {
    __index: Profile<T>,

    Store: DataStore,
    Template: Dict,
    Key: string,
    UserId: number,
    _IsTransferred: boolean,

    Data: T,

    AddUserId: (self: Profile<T>, userId: number) -> nil,
    SaveProfileAsync: (self: Profile<T>) -> nil,
    TransferDataAsync: (self: Profile<T>) -> boolean,
}
export type HarukaDatastore = {
    GetStore: (storeName: string, template: Dict) -> HarukaDatastore,
    CreateProfileAsync: <T>(self: HarukaDatastore, key: string) -> Profile<T>,


    StoreName: string,
    Store: DataStore,
    Template: Dict,
    Key: string,
}



local HarukaDatastore = {} :: HarukaDatastore
HarukaDatastore.__index = HarukaDatastore


local Profile = {} :: Profile<Dict>
Profile.__index = Profile


local KEYINFO_MOCK = {
    GetMetadata = function(_: any)
        return {}
    end,
    GetUserIds = function(_: any)
        return {}
    end
}



function Profile:AddUserId(userId: number)
    self.UserId = userId
end


function Profile:SaveProfileAsync()
    local success, result = pcall(function()
        self.Store:UpdateAsync(self.Key, function(oldValue: Dict, keyInfo: DataStoreKeyInfo)
            keyInfo = keyInfo or KEYINFO_MOCK

            local userIds = keyInfo:GetUserIds()
            local metaData = keyInfo:GetMetadata()

            if #userIds <= 0 then
                userIds = { self.UserId }
            end

            if self.Data == nil then
                return oldValue, userIds, metaData
            end
            return self.Data, userIds, metaData
        end)
    end)
    if not success then warn(result) end
end


-- Transfer profile service data to new module
function Profile:TransferDataAsync(storeName: string, key: string) : boolean
    local oriStore = DSS:GetDataStore(storeName)
    local oriProfile: Dict

    local success, result = pcall(function()
        oriProfile = oriStore:GetAsync(key)
    end)
    if not success then
        warn("[HarukaDS Transfer]: "..result)
        return false
    end

    if oriProfile == nil then
        oriProfile = HarukaLib.TableUtils.DeepCopy(self.Template)
    end
    HarukaLib.TableUtils.Reconcile(oriProfile, self.Template)


    self._IsTransferred = true
    self.Data = oriProfile


    return true
end







function HarukaDatastore.GetStore(storeName: string, template: Dict) : HarukaDatastore
    local self = setmetatable({}, HarukaDatastore)


    self.StoreName = storeName
    self.Store = DSS:GetDataStore(storeName)
    self.Template = template or {}


    return self
end


function HarukaDatastore:CreateProfileAsync(key: string)
    self.Key = key

    local data: Dict, keyInfo: DataStoreKeyInfo = self.Store:GetAsync(key)
    if data == nil then
        data = HarukaLib.TableUtils.DeepCopy(self.Template)
    end

    keyInfo = keyInfo or KEYINFO_MOCK

    local selfProfile = setmetatable({}, Profile)

    selfProfile.Template = self.Template
    selfProfile.Store = self.Store
    selfProfile.Key = key
    selfProfile.Data = data

    selfProfile.DatastoreKeyInfo = keyInfo
    selfProfile._IsTransferred = keyInfo:GetMetadata()._IsTransferred or false


    HarukaLib.TableUtils.Reconcile(selfProfile.Data, self.Template)


    return selfProfile
end




return HarukaDatastore
