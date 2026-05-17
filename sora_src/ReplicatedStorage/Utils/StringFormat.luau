local StringFormat = {}

--- "hello world" -> "HelloWorld"
function StringFormat.toPascalCase(str: string): string
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end):gsub("%s+", ""))
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

--- "hello world" -> "Hello World"
function StringFormat.toTitleCase(str: string): string
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

--- "hello world" -> "hello_world"
function StringFormat.toSnakeCase(str: string): string
    return str:lower():gsub("%s+", "_")
end

--- "hello world" -> "HELLO_WORLD"
function StringFormat.toScreamingSnakeCase(str: string): string
    return str:upper():gsub("%s+", "_")
end

--- "hello world" -> "hello-world"
function StringFormat.toKebabCase(str: string): string
    return str:lower():gsub("%s+", "-")
end

--- 1500000 -> "1,500,000"
function StringFormat.toCommaSeparated(n: number): string
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

return table.freeze(StringFormat)