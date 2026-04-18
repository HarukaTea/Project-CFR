local Table = {}

--- Deep copy a table
function Table.deepCopy<T>(original: T): T
    local copy = {}
    for k, v in original :: any do
        copy[k] = if type(v) == "table" then Table.deepCopy(v) else v
    end
    return (copy :: any) :: T
end

--- Merge src into dst (shallow, mutates dst)
function Table.merge<T>(dst: T, src: {[any]: any}): T
    for k, v in src do
        (dst :: any)[k] = v
    end
    return dst
end

--- Check if a value exists in an array
function Table.includesValue<T>(t: {T}, value: T): boolean
    for _, v in t do
        if v == value then
            return true
        end
    end
    return false
end

-- Check if a key exists in the table
function Table.includesKey<T>(t: {T}, key: T): boolean
    for k, _ in t do
        if k == key then
            return true
        end
    end
    return false
end

--- Filter an array by predicate
function Table.filter<T>(t: {T}, predicate: (T) -> boolean): {T}
    local result = {}
    for _, v in t do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

--- Map an array to a new array
function Table.map<T, U>(t: {T}, transform: (T) -> U): {U}
    local result = {}
    for i, v in t do
        result[i] = transform(v)
    end
    return result
end

--- Sum an array of numbers
function Table.sum(t: {number}): number
    local total = 0
    for _, v in t do
        total += v
    end
    return total
end

--- Count entries matching predicate
function Table.count<T>(t: {T}, predicate: (T) -> boolean): number
    local n = 0
    for _, v in t do
        if predicate(v) then
            n += 1
        end
    end
    return n
end

--- Pick a random element
function Table.random<T>(t: {T}): T
    return t[math.random(1, #t)]
end

return table.freeze(Table)