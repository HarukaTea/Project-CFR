
local RunService = game:GetService("RunService")


if RunService:IsStudio() then
    return "CF_Miliastra_DEV"..DateTime.now():ToIsoDate().."_V"..game.PlaceVersion
end


return "CF_REL_Halloween2025_V"..game.PlaceVersion