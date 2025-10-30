
local ServerScriptService = game:GetService("ServerScriptService")

local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)


export type DMGPropsMetaData = {
    DMG: number,
    DMGType: string,
    Attacker: string,
}

export type StatusPropsMetaData = {
    Target: Model,
    Type: string,
    Creator: Model,
    Power: number,
    Duration: number,
}

local AccessoryUniversal = {}



AccessoryUniversal.RegisterEnemyOnHit = function(
    source: Script,
    event: BindableEvent,
    char: Model,
    handler: (targeting: Model, attacker: Model, dmgProps: DMGPropsMetaData) -> nil
) : RBXScriptConnection
    return event.Event:Connect(function(targeting: Model, attacker: Model, dmgProps: DMGPropsMetaData)
        if source == nil then return end
        if source.Parent == nil then return end
        if attacker ~= char then return end
        if not ServerLib.IsCharValid(targeting) then return end
        if not ServerLib.IsCharValid(attacker) then return end
        if not dmgProps then return end
        if not dmgProps.DMG then return end
        if not dmgProps.Attacker then return end

        handler(targeting, attacker, dmgProps)
    end)
end



AccessoryUniversal.RegisterStatusApplied = function(
    source: Script,
    event: BindableEvent,
    char: Model,
    handler: (targeting: Model, attacker: Model, statusProps: StatusPropsMetaData) -> nil
) : RBXScriptConnection

    return event.Event:Connect(function(targeting: Model, attacker: Model, statusProps: StatusPropsMetaData)
        if source == nil then return end
        if source.Parent == nil then return end
        if attacker ~= char then return end
        if not ServerLib.IsCharValid(targeting) then return end
        if not ServerLib.IsCharValid(attacker) then return end
        if not statusProps then return end
        if not statusProps.Type then return end

        handler(targeting, attacker, statusProps)
    end)
end
AccessoryUniversal.RegisterEnemyStatusRemoved = function(
    source: Script,
    event: BindableEvent,
    char: Model,
    handler: (targeting: Model, attacker: Model, statusProps: StatusPropsMetaData) -> nil
) : RBXScriptConnection

    return event.Event:Connect(function(targeting: Model, attacker: Model, statusProps: StatusPropsMetaData)
        if source == nil then return end
        if source.Parent == nil then return end
        if attacker ~= char then return end
        if not ServerLib.IsCharValid(targeting) then return end
        if not ServerLib.IsCharValid(attacker) then return end
        if not statusProps then return end
        if not statusProps.Type then return end

        handler(targeting, attacker, statusProps)
    end)
end


AccessoryUniversal.RegisterPlayerDiedEmpty = function(source: Script, event: BindableEvent, empty: () -> nil)
    source.Destroying:Connect(empty)
    event.Event:Connect(empty)
end




return AccessoryUniversal