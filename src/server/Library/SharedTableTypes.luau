
local SSS = game:GetService("ServerScriptService")

local UniversalEntityTypes = require(SSS.HarukaServer.Library.EntityAttackLib.UniversalEntity)
local PlayerLibTypes = require(SSS.HarukaServer.Services.PlayerLib)


export type SharedTable = {
    PlayerLib: PlayerLibTypes.PlayerLibClass,
    UniversalEntity: UniversalEntityTypes.UniversalEntity
}


return nil