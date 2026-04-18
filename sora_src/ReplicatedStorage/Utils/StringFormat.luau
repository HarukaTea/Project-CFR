local StringFormat = {}

--- "hello world" -> "Hello World"
function StringFormat.toPascalCase(str: string): string
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

--- "hello world" -> "helloWorld"
function StringFormat.toCamelCase(str: string): string
    local result = StringFormat.toPascalCase(str)
    return result:sub(1, 1):lower() .. result:sub(2)
end

--- "hello world" -> "Hello world"
function StringFormat.toCapitalized(str: string): string
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

--- "hello world" -> "HELLO_WORLD"
function StringFormat.toScreamingSnakeCase(str: string): string
    return str:upper():gsub("%s+", "_")
end

--- 1500000 -> "1,500,000"
function StringFormat.toCommaSeparated(n: number): string
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

--- 1500 -> "1.5K", 1000000 -> "1M"
function StringFormat.toShorthand(n: number): string
    if n >= 1_000_000 then
        return string.format("%.1fM", n / 1_000_000)
    elseif n >= 1_000 then
        return string.format("%.1fK", n / 1_000)
    end
    return tostring(n)
end

--- 90 (seconds) -> "1:30"
function StringFormat.toTimeFormat(seconds: number): string
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

return table.freeze(StringFormat)