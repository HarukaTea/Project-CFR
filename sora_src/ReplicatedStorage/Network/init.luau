local requiredModules = {} :: { string }
local children = script:GetChildren()

table.sort(children, function(a: ModuleScript, b: ModuleScript)
    return a.Name < b.Name
end)

for _, module: ModuleScript in children do
    require(module)
    table.insert(requiredModules, module.Name)
end

-- print(`[Network Initialisation]: registered {#requiredModules} modules: {table.concat(requiredModules, ", ")}`)

return table.freeze(requiredModules)