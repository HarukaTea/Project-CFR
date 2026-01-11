
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)

type Dict = {[string]: any}

export type OrbData = {
    UniqueId: string,
    OrbId: string,
    OrbStyle: string,
    OrbSubStyle: string?,
    OrbUniStyle: string?,
    OrbDuration: number,
    OrbLocation: CFrame,
    Owner: string,
    CreatedTimeMS: number
}
export type SkillProjectileData = {
    ProjectileId: string,
    ProjectileType: "OneTime" | "OverTime",
    Duration: number,
    ProjectileUniqueId: string,
    DMGType: "DMG" | "Magic",
    DoTType: string,
    DMGBonus: number,
    IsClassUlt: boolean,

    Owner: string,
}
export type EnemyProjectileData = {
    UniqueId: string,
    ProjectilePos: Vector3,
    ProjectileDMG: number,
    EnemyLevel: number,
    Owner: Model?,

    --// optional
    DoTStatus: string?
}
export type ItemDropSymbolData = {
    UniqueId: string,
    Amount: number,
    ItemId: string,
    Receiver: Player
}

export type ServerTable = {
    OrbSymbols: {[string]: { [string]: OrbData }},
    SkillProjectileSymbols: {[string]: { [string]: SkillProjectileData }},
    EnemyProjectileSymbols: {[string]: EnemyProjectileData },
    ItemDropSymbols: {[string]: ItemDropSymbolData},

    AddItem: (self: ServerTable, linkTable: string, uniqueId: string, lifeTime: number) -> nil
}

local ServerTable = {
    ----@params [charUniqueId]: {}
    OrbSymbols = {},

    ----@params [charUniqueId]: {},
    SkillProjectileSymbols = {},

    EnemyProjectileSymbols = {},
    ItemDropSymbols = {},
} :: ServerTable

--// garbadge collector
HarukaLib.Clock(15, function()
    local charUniqueIds = {}
    for _, char: Model in CollectionService:GetTagged("PlayerCharEntity") do
        table.insert(charUniqueIds, char:GetAttribute("HarukaUniqueId"))
    end

    local playerUniqueIds = {}
    for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
        table.insert(playerUniqueIds, player:GetAttribute("HarukaUniqueId"))
    end

    for uniqueId: string, v in ServerTable.OrbSymbols do
        if not table.find(charUniqueIds, uniqueId) then
            ServerTable.OrbSymbols[uniqueId] = nil
        end
    end

    for uniqueId: string, v in ServerTable.SkillProjectileSymbols do
        if not table.find(charUniqueIds, uniqueId) then
            ServerTable.SkillProjectileSymbols[uniqueId] = nil
        end
    end
end)

function ServerTable:AddItem(linkTable: string, uniqueId: string, lifeTime: number)
    Promise.try(lifeTime, function()
        linkTable[uniqueId] = nil

    end):catch(function() end)
end

return ServerTable