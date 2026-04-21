local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Properties = require(ReplicatedStorage.Constants.Typing.Properties)

export type ItemProperties =
    Properties.OrbProperty |
    Properties.HealthProperty |
    Properties.DamageType |
    Properties.CritProperty |
    Properties.DefenseProperty |
    Properties.ShieldProperty |
    Properties.ManaProperty

--- Must be used in `ReplicatedStorage/Constants/Items`
export type ItemDetails = {
    name: string,
    description: string,
    modeller: number, --- creator's ID,
    minProperties: { [ItemProperties]: number },
    maxProperties: { [ItemProperties]: number }, --- If there is no max property then the value will always be set to min property.
}

return {}