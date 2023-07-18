local methods = {}


local keywords = {
    select = "SELECT",
    from = "FROM",
    where = "WHERE",
    update = "UPDATE",
    delete = "DELETE",
    create = "CREATE",
    drop = "DROP",
    TRUE = "true",
    FALSE = "false"
}

methods.keywords = keywords

local identifier = { }

function identifier.validateIdentifier(str)
    -- Check length (up to 64 characters)
    if #str > 64 then
        return false
    end

    -- Check for reserved keywords
    for _, keyword in pairs(keywords) do
        if string.lower(str) == keyword then
            return false
        end
    end

    -- Check for reserved literals
    for _, literal in pairs(literals) do
        if string.lower(str) == literal then
            return false
        end
    end

    -- Check for reserved operators
    for _, operator in pairs(operators) do
        if string.lower(str) == operator.lower() then
            return false
        end
    end

    -- Check if the identifier adheres to the allowed character set
    if not string.match(str, "^[%a_]+$") then
        return false
    end

    return true
end

methods.identifier = identifier

local literals = {
    number = "int",
    float = "float",
    boolean = "bool",
    string = "str"
}

function literals.validateLiteral(str)
    -- Integer: Check if the string represents a valid integer
    if tonumber(str) ~= nil then
        return true
    end

    -- Float: Check if the string represents a valid float
    if string.match(str, "^%d*%.?%d+f?$") ~= nil then
        return true
    end

    -- Boolean: Check if the string represents a valid boolean
    local lowerStr = string.lower(str)
    if lowerStr == keywords.TRUE or lowerStr == keywords.FALSE then
        return true
    end

    -- String: Check if the string represents a valid string literal
    if string.match(str, "^'.*'$") ~= nil then
        return true
    end

    return false
end


methods.literals = literals

local operators = {
    addition = "+",
    subtraction = "-",
    multiplication = "*",
    division = "/",
    AND = "AND",
    OR = "OR",
    NOT = "NOT",
    EQ = "=",
    NE = "!=",
    LT = "<",
    LE = "<=",
    GT = ">",
    GE = "=>"
}

function operators.validateOperators(str)
    for _, n in operators
    do
        if n == str:upper()
        then
            return true
        end
    end
    return false
end

methods.operators = operators

local comments = { }


function comments.isComment(str)
    -- Remove leading whitespaces
    local trimmedStr = str:match("^%s*(.*)$")

    -- Check if the trimmed string starts with //
    if trimmedStr:match("^//") then
        return true
    else
        return false
    end
end


methods.comments = comments


return methods