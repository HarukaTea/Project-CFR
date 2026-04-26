local ServerStorage = game:GetService("ServerStorage")
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local dataAccessor = {} :: DataAccessor.API
local api = {}

function api.init(accessor: DataAccessor.API)
    dataAccessor = accessor
end

function api.addExp(player: Player, amount: number)
    
end



return api