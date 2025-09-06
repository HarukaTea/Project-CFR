--!nocheck

local ServerScriptService = game:GetService("ServerScriptService")

local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)


export type DMGPropsMetaData = {
    DMG: number,
    DMGType: string,
    Attacker: string,
}

export type ClassUltMetaData = {
    ClassId: string,
    ClassVariant: string,
    DMGType: string,
    Target: Model?
}

local ArtifactUniversal = {}



ArtifactUniversal.RegisterEnemyOnHit = function(
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
        if not dmgProps.Attacker then return end

        handler(targeting, attacker, dmgProps)
    end)


    return conn
end


ArtifactUniversal.RegisterClassUltCasted = function(
    source: Script,
    event: BindableEvent,
    char: Model,
    handler: (target: Model, caster: Model, ultProps: ClassUltMetaData) -> nil
) : RBXScriptConnection
    local conn: RBXScriptConnection

    event.Event:Connect(function(caster: Model, ultProps: ClassUltMetaData)
        if source == nil then return end
        if source.Parent == nil then return end
        if caster ~= char then return end
        if not ServerLib.IsCharValid(ultProps.Target) then return end
        if not ServerLib.IsCharValid(caster) then return end
        if not ultProps then return end
        if not ultProps.ClassId then return end
        if not ultProps.ClassVariant then return end

        handler(ultProps.Target, caster, ultProps)
    end)


    return conn
end


ArtifactUniversal.RegisterPlayerDiedEmpty = function(source: Script, event: BindableEvent, empty: () -> nil)
    source.Destroying:Connect(empty)
    event.Event:Connect(empty)
end




return ArtifactUniversal
