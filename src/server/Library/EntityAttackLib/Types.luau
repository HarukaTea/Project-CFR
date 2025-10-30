
local RepS = game:GetService("ReplicatedStorage")

local Promise = require(RepS.HarukaShared.Shared.Promise)

export type EntityAttackObj = {
    __index: EntityAttackObj,

    new: (entity: Model) -> EntityAttackObj,
    Destroy: (self: EntityAttackObj) -> nil,

    DoAttackTasks: (self: EntityAttackObj, resolveObj: () -> nil) -> nil,


    Promises: { Promise.Promise },

    Entity: Model,
    EntityId: string,
    Add:<T> (item: T) -> T,
    Empty: () -> nil,
    Died: boolean,

    Anims: {},
    AttackFuncs: { (target: Model) -> nil },
    ComboAttackFuncs: { (target: Model, rFuncId: number, rComboId: number) -> nil }
}


export type UniversalEntity = {
    InitTemplate: (self: UniversalEntity, entityAtkObj: EntityAttackObj, entity: Model) -> nil,
    InitResolveObj: (self: UniversalEntity, entity: Model, resolveObj: () -> ()) -> nil,
    InitAttackTables: (self: UniversalEntity, entityAtkObj: EntityAttackObj) -> nil,
    InitAttackTasks: (self: UniversalEntity, entityAtkObj: EntityAttackObj, resolveObj: () -> nil) -> nil,


    GetTargets: (self: UniversalEntity, entity: Model) -> { Player },
    GetNearbyPlayers: (self: UniversalEntity, entity: Model) -> { Player },
    GetRandomTarget: (self: UniversalEntity, entity: Model) -> Model,

    EditProjectileList: (self: UniversalEntity, projectileUniqueId: string, projectilePos: Vector3 | CFrame, entity: Model) -> nil,

    CheckCombatState: (self: UniversalEntity, entity: Model) -> (boolean, "NoTarget" | "Dead" | "Combating"),

    DeadTask: (self: UniversalEntity, entityAtkObj: EntityAttackObj) -> nil
}


return nil