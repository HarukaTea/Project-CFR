local ServerStorage = game:GetService("ServerStorage")
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end

return api