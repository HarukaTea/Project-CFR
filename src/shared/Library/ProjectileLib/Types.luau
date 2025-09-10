--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

export type ProjectileLib = {
    _incomingCylinderAtt: (projectileBase: BasePart) -> nil,
    _rotateAttentionPoint: (projectileBase: BasePart, container: Folder, props: {
        ShouldDetail: boolean,
        Size: "Big" | "Small" | "SuperBig"
    }) -> nil,
    _fadeAwayAndDestroy: (obj: Instance) -> nil,
    _spawnProjectile: (
        projectile: Model,
        container: Folder,
        duration: number,
        callback: (projectile: Model) -> nil
    ) -> nil,

    [string]: (projectile: Model, container: Folder) -> nil
}


return nil