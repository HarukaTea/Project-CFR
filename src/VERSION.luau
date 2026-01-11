
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
    return "CF_Miliastra_DEV"..DateTime.now():ToIsoDate()
end

return "CF_ALPHA0.7_V"..game.PlaceVersion