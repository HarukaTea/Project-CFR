export type MaterialDetails = {
    name: string,
    description: string,
    --- rblxid://somethingsomething
    icon: string,
}

local enum = {}

enum.maxQuantity = 1_000_000

enum.materials = {} :: { [string]: MaterialDetails }

return table.freeze(enum)