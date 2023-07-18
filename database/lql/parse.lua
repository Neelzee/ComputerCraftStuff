local expr = require "database.lql.expr"

local methods = {}

function methods.split(s)
    local lst = {""}
    local j = 1
    for i = 1, #s, 1
    do
        if s[i] == " "
        then
            j = j + 1
        else
            lst[j] = lst[j] + s[i]
        end
    end

    return lst
end


function methods.parse(s)
    local lst = methods.split(s)

    -- SELECT ???

    if string.upper(lst[1]) ~= expr.keywords.select and string.upper(lst[1]) ~= expr.keywords.create and string.upper(lst[1]) ~= expr.keywords.upper and string.upper(lst[1]) ~= expr.keywords.drop
    then
        -- TODO: Raise error, should start with SELECT, CREATE, UPDATE or DROP
    end

    local index = 2

    -- SELECT data ???

    for i = 2, #lst, 1
    do
        if not expr.identifier.validateIdentifier(lst[i])
        then
            -- Should be FROM
            if lst[i]:upper() ~= expr.keywords.from
            then
                -- TODO: Error
            else
                index = i + 1
                break
            end
        end
    end

    -- SELECT data FROM table ???

    -- If theres more

    while index < #lst
    do

        -- SELECT data FROM table WHERE ???

        if lst[index] ~= expr.keywords.where
        then
            -- TODO: error time
        end

        index = index + 1
        --- SELECT data FROM table WHERE data
        if index >= #lst
        then
            -- TODO: Incomplete expression
        end
        
        if not (expr.identifier.validateIdentifier(lst[index])) or (expr.literals.validateLiteral(lst[index]))
        then
            -- TODO: Invalid
        end
        
        index = index + 1
        
        
        --- SELECT data FROM table WHERE data =
        if not expr.operators.validateOperators(lst[index])
        then
            -- TODO: Invalid
        end
        
        index = index + 1
        
        if index > #lst
        then
            -- TODO: Incomplete expression
        end
        --- SELECT data FROM table WHERE data = 10
        
        if not (expr.identifier.validateIdentifier(lst[index])) or (expr.literals.validateLiteral(lst[index]))
        then
            -- TODO: Invalid
        end
        
        index = index + 1

        -- Checks if there are more operators
        
        --- SELECT data FROM table WHERE data = 10 AND
        if #lst - index > 0
        then
            if not (expr.keywords.AND == lst[index] or expr.keywords.OR == lst[index])
            then
                -- TODO: Error
            end
        end

    end
end

return methods