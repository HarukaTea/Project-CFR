export type MaterialDetails = {
    name: string,
    description: string,
    --- rblxid://somethingsomething
    icon: string,
}

return table.freeze({
    maxQuantity = 1_000_000,
    materials = {

    } :: { [string]: MaterialDetails }
})