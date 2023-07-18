local methods = {
    
}

local fields = {
    tableName = "",
    header = "",
    diskDriver = nil,
    content = {}
}


local function save()
    local path = ""
    if fields.diskDriver ~= nil and fields.diskDriver.isDiskPresent()
    then
        path = s.diskDriver.getMountPath()

        path = path + "/" + fields.tableName
    else
        path = fields.tableName
    end
    local file = io.open(path, "w+")

    file:write(fields.header)
    file:write("\n")

    for l in fields.contents
    do
        file:write(l)
        file:write("\n")
    end
end


local function writeLine(line)
    fields.length = fields.length + 1
    fields.content[fields.length] = line
end


local function replaceLine(line, n)

    if n < 0 or n >= fields.line
    then
        return nil
    end

    fields.content[n] = line
end


local function removeLine(n)

    if n < 0 or n >= fields.line
    then
        return nil
    end

    fields.content[n] = nil


    local content = {}
    local j = 1
    for i = 1, #fields.content, 1
    do
        if fields.content[j] ~= nil
        then
            content[j] = fields.content[i]
            j = j + 1
        end
    end

    fields.content = content
end

local function split(s, sep)
    local lst = {}
    local j = 1
    for i = 1, #s, 1
    do
        if s[i] == sep
        then
            j = j + 1
        else
            lst[j] = lst[j] + s[i]
        end
    end

    return lst
end


function methods.selectWhere(q)
    local columns = split(fields.header, ",")

    for col in columns
    do
        
    end
end

methods.fields = fields

return methods