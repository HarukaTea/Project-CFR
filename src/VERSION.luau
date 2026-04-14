
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
    return "CF_STUDIO_DEV"..DateTime.now():ToIsoDate()
end

return "CF_REL_V"..game.PlaceVersion