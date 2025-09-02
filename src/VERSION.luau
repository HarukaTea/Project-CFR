local RunService = game:GetService("RunService")


if RunService:IsStudio() then
    return "CF_DEMO1_DEV"..DateTime.now():ToIsoDate()
end


return "CF_REL_PT4_V0902_06"
