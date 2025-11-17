
local Types = require(script.Types)


export type EntityAttackLib = Types.EntityAttackObj

local EntityAttackLib = {} :: EntityAttackLib



for _, module: ModuleScript in script.Library:GetDescendants() do
    if module:IsA("ModuleScript") then
        EntityAttackLib[module.Name] = require(module)
    end
end


return EntityAttackLib