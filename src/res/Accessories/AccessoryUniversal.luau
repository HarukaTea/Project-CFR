--!nocheck

local ServerScriptService = game:GetService("ServerScriptService")

local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)


export type DMGPropsMetaData = {
    DMG: number,
    AttackType: string,
    DMGType: string,
}

local AccessoryUniversal = {}



AccessoryUniversal.RegisterEnemyOnHit = function(
    source: Script,
    event: BindableEvent,
    char: Model,
    handler: (targeting: Model, attacker: Model, dmgProps: DMGPropsMetaData) -> nil
) : RBXScriptConnection
    local conn: RBXScriptConnection

    event.Event:Connect(function(targeting: Model, attacker: Model, dmgProps: DMGPropsMetaData)
        if source == nil then return end
        if source.Parent == nil then return end
        if attacker ~= char then return end
        if not ServerLib.IsCharValid(targeting) then return end
        if not ServerLib.IsCharValid(attacker) then return end
        if not dmgProps then return end
        if not dmgProps.DMG then return end
        if not dmgProps.AttackType then return end

        handler(targeting, attacker, dmgProps)
    end)


    return conn
end


AccessoryUniversal.RegisterPlayerDiedEmpty = function(source: Script, event: BindableEvent, empty: () -> nil)
    source.Destroying:Connect(empty)
    event.Event:Connect(empty)
end




return AccessoryUniversal
