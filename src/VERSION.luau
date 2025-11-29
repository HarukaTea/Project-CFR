
local RunService = game:GetService("RunService")


if RunService:IsStudio() then
    return "CF_Miliastra_DEV"..DateTime.now():ToIsoDate().."_V"..game.PlaceVersion
end


return "CF_ALPHA0.6_V"..game.PlaceVersion