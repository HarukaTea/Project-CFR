
local CollectionService = game:GetService("CollectionService")

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")
repeat task.wait() until workspace:FindFirstChild("Maps", 999)

local wait = task.wait

local PreloadClientWorldLib = {}


function PreloadClientWorldLib:Init()
    PreloadClientWorldLib:_DoMapComponentTracker()
end


function PreloadClientWorldLib:_DoMapComponentTracker()
    local function _handleWindmill(windmill: Model)
        repeat wait() until windmill and windmill.PrimaryPart

        wait()
        task.defer(function()
            while wait(0.01) do
                windmill.PrimaryPart.CFrame *= CFrame.Angles(math.rad(-1.7), 0, 0)
            end
        end)
    end
    local function _handleGalleon(galleon: Model)
        repeat wait() until galleon and galleon.PrimaryPart

        wait()
        task.defer(function()
            while wait(0.01) do
                for _ = 1, 50 do
                    galleon.PrimaryPart.CFrame *= CFrame.new(0, 0.04, 0)
                    wait(0.01)
                end
                for _ = 1, 50 do
                    galleon.PrimaryPart.CFrame *= CFrame.new(0, -0.04, 0)
                    wait(0.01)
                end
            end
        end)
    end
    for _, wings: Model in CollectionService:GetTagged("WindmillWings") do
        _handleWindmill(wings)
    end
    for _, galleon: Model in CollectionService:GetTagged("SkyGalleon") do
        _handleGalleon(galleon)
    end
    CollectionService:GetInstanceAddedSignal("WindmillWings"):Connect(_handleWindmill)
    CollectionService:GetInstanceAddedSignal("SkyGalleon"):Connect(_handleGalleon)
end


PreloadClientWorldLib:Init()
