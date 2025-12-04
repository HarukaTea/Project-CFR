
local Types = require(script.Types)


export type EntityAttackLib = Types.EntityAttackObj

local EntityAttackLib = {} :: EntityAttackLib



for _, module: ModuleScript in script.Library:QueryDescendants("ModuleScript") do
    EntityAttackLib[module.Name] = require(module)
end


return EntityAttackLib