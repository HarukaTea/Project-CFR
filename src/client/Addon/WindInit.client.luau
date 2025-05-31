--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local RepS = game:GetService("ReplicatedStorage")

local WindLines = require(RepS.HarukaShared.Shared.Ambient.WindLines)

local v3New = Vector3.new


local WIND_VECTOR = v3New(-0.3, 0, 0.8)

--// Enable winds
do
    workspace.GlobalWind = WIND_VECTOR

    WindLines:Init({
        Direction = WIND_VECTOR,
        Speed = 15.99,
        LifeTime = 1.5,
        SpawnRate = 8,
    })
end
