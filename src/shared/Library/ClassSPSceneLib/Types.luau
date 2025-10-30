
export type ClassSPSceneLib = {
    _tweenValue: (start: number, duration: number, endTime: number, obj: Instance) -> NumberValue,
    _createMarkContainer: () -> Folder,

    [string]: (char: Model, projectileUniqueId: string) -> nil
}


return nil