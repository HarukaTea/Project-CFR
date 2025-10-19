--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

export type EntityAttackLibFreeze = {
    [string]: EntityAttackLib
}


export type EntityAttackLib = {
    new: (entity: Model) -> EntityAttackLib,
    Destroy: () -> nil,

    DoAttackTasks: (self: EntityAttackLib, resolveObj: () -> nil) -> nil
}


export type UniversalEntity = {
    InitTemplate: (self: UniversalEntity, entityObj: EntityObj, entity: Model) -> nil,
    InitResolveObj: (self: UniversalEntity, entity: Model, resolveObj: () -> ()) -> nil,
    InitAttackTables: (self: UniversalEntity, entityObj: EntityObj) -> nil,
    InitAttackTasks: (self: UniversalEntity, entityObj: EntityObj, resolveObj: () -> nil) -> nil,


    GetTargets: (self: UniversalEntity, entity: Model) -> { Player },
    GetNearbyPlayers: (self: UniversalEntity, entity: Model) -> { Player },
    GetRandomTarget: (self: UniversalEntity, entity: Model) -> Model,

    EditProjectileList: (self: UniversalEntity, projectileUniqueId: string, projectilePos: Vector3 | CFrame, entity: Model) -> nil,

    CheckCombatState: (self: UniversalEntity, entity: Model) -> (boolean, "NoTarget" | "Dead" | "Combating"),

    DeadTask: (self: UniversalEntity, entityObj: EntityObj) -> nil
}


return nil