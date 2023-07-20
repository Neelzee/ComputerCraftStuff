local component = require "component"

local reactors = {}

local ncReactor = "nc_fission_reactor"

-- Gets all connected reactors
local i = 1
for address in component.list(ncReactor)
do
    local el = component.proxy(address)
    reactors:insert({id = 1, comp = el})
end

RUNNING = true


local function percentage(a, b)
    local val = a / b * 100

    if val >= 100
    then
        val = 100
    end

    return val
end


local function reactorProcess(reactor, minEnergy, maxEnergy, maxTemp)
    if reactor == nil or not reactor.isComplete()
    then
        return
    end

    local lengthX = reactor.getLengthX()
    local lengthY = reactor.getLengthY()
    local lengthZ = reactor.getLengthZ()
    while RUNNING
    do
        -- If over max temp, shutdown
        if percentage(reactor.getHeatStored(), reactor.getHeatCapacity()) >= maxTemp
        then
            reactor.deactivate()
        end
        coroutine.yield(reactor.isActive())
    end

    -- If here, deactivate reactor
    reactor.deactivate()
    coroutine.yield(reactor.deactivate())
end

local function getReactor(id)
    for i, reactor in reactors
    do
        if i == id
        then
            return reactor
        end
    end
end

local function shutDownProc(processes)
    if not RUNNING
    then
        for i = 1, #processes, 1
        do
            local id = processes[i].id
            local proc = processes[i].proc
            
            coroutine.close(proc)
            local r = getReactor(id)
            if r ~= nil
            then
                r.deactivate()
            end
        end
    end
end

local function main()
    local processes = {}

    for id, _ in reactors
    do
        processes:insert({id = id, proc = reactorProcess})
    end

    local maxTemp = 70

    while RUNNING
    do
        for i = 1, #processes, 1
        do
            local id = processes[i].id
            local proc = processes[i].proc

            if coroutine.status(proc) == "dead"
            then
                RUNNING = false
            end

            local r = coroutine.resume(proc, getReactor(id), nil, nil, maxTemp)

            RUNNING = not (r == nil)
        end
    end

    shutDownProc(processes)
end