
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    MobId: string,
    Level: number
})
    if not EntityBook[props.MobId] then return nil end

    local isSelecting = Fusion.Value(scope, false)

    return Fusion.Hydrate(scope, Components:RefUI("Enemy_EAbyss3_1", false, true, {
        "CFEmblemTex"
    }))({
        Name = "Abyss_"..props.MobId,

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_EAbyss3_3", true))({
                Image = EntityBook[props.MobId].Icon
            }),

            Fusion.Hydrate(scope, Components:RefUI("EnemyLevel_EAbyss3_3"))({
                Text = `Lv.{props.Level}`
            }),

            Fusion.Hydrate(scope, Components:RefUI("EnemyName_EAbyss3_3"))({
                Text = `<u>{EntityBook[props.MobId].Name}</u>`
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),
            })
        }
    })
end