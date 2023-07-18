local diskDriver = peripheral.find("disk")

local parser = require "lql.parse"

local expr = require "lql.expr"

local db = {
    tables = {}
}


local function exec(query)
    if not parser.parse(query)
    then
        coroutine.yield()
    end

    local lst = parser.split(query)

    local action = lst[1]

    local identifiers = {}

    local i = 2
    local id = lst[i]
    local j = 1
    while expr.identifier.validateIdentifier(id)
    do
        identifiers[j] = id
        id = lst[i]
        i = i + 1
        j = j + 1
    end

    -- SELECT
    if action == expr.keywords.select
    then
        j = j + 1
        local t = lst[j]
    
        local tableDB = nil
    
        for table in db.tables
        do
            if table.name == t
            then
                tableDB = table
            end
        end
    
        if tableDB == nil
        then
            -- TODO: ERROR, TABLE NOT FOUND
        end
    
        local q = ""
        while j < #lst
        do
            j = j + 1
            q = q + " " + lst[j]
        end
    
        local res = tableDB.selectWhere(q)
    end

end



local function main()

end