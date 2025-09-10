--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Types = require(script.Types)


export type EntityAttackLib = Types.EntityAttackLibFreeze

local EntityAttackLib = {} :: EntityAttackLib


require(script.UniversalEntity)

local wait = task.wait


for _, module: ModuleScript in script.Library:GetDescendants() do
    if module:IsA("ModuleScript") then
        EntityAttackLib[module.Name] = require(module)
    end
end


shared.EntityAttackLib = EntityAttackLib


return EntityAttackLib :: EntityAttackLib