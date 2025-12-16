
export type VFXSceneLib = {
    _tweenValue: (start: number, duration: number, endTime: number, obj: Instance) -> NumberValue,
    _createMarkContainer: () -> Folder,

    LockedPartTypes: {
        [string]: (part: BasePart) -> nil
    },

    [string]: (char: Model, projectileUniqueId: string) -> nil
}


return nil