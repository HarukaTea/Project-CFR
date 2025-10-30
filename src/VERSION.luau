
local RunService = game:GetService("RunService")


if RunService:IsStudio() then
    return "CF_Miliastra_DEV"..DateTime.now():ToIsoDate()
end


return "CF_REL_Miliastra_Halloween2025_V01"