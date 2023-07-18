local reactor = peripheral.wrap("back")
local modem = peripheral.wrap("bottom")

local date = require "date"

local utils = require "reactor.utils"

local msg = {}

local rec_msg = false

local settings = {
    active = false,
    controlRodLevel = 50,
    maxTemp = 100,
    maxConsumption = 10,
    channel = utils.REACTOR_CHANNEL
}

local status = {}

local function split(str, sep)
    local lst = {""}
    local i = 1

    if sep == nil
    then
        sep = " "
    end

    for c in str
    do
        if c == sep
        then
            i = i + 1
        else
            lst[i] = lst[i] + c
        end
    end

    return lst
end


local function handleTermination()
    os.pullEventRaw("terminate")

    local filename = os.getComputerLabel() + "_" + os.getComputerID() + "_STATE"

    local file = io.open(filename, "a")

    file:write("\n")
    file:write(tostring(os.date("%A %d %B %Y")))
    file:write("\n")
    file:write(textutils.serialise(settings))
end


local function loadSettings()
    local filename = os.getComputerLabel() + "_" + os.getComputerID() + "_STATE"

    local file = io.open(filename, "r")

    local dates = {}

    local i = 1

    for l in file:lines()
    do
        local parsedDate = date(l, "%d %B %Y")

        dates[i] = parsedDate
    end

    local latestDate = dates[1]

    for i = 2, #dates
    do
        if dates[i] > latestDate
        then
            latestDate = dates[i]
        end
    end
    file:close()
    file = io.open(filename, "r")

    local findSettings = false

    local rawSettings = ""

    for l in file:lines()
    do
        local a, b, c, d = split(l)

        if a ~= nil and b ~= nil and c ~= nil and d ~= nil
        then
            local parsedDate = date(l, "%d %B %Y")

            if parsedDate == latestDate
            then
                findSettings = true
            elseif findSettings
            then
                file:close()
                break
            end
        else
            if findSettings
            then
                rawSettings = rawSettings + l + "\n"
            end
        end
    end

    settings = textutils.unserialise(rawSettings)
    modem.open(tonumber(settings.channel))
end

local function reactorStatus()
    status = {
        -- General
        active = reactor.active(),
        fuelTemp = reactor.fuelTemperature(),
        caseTemp = reactor.casingTemperature(),
        stackTemp = reactor.stackTemperature(),
        ambientTemp = reactor.ambientTemperature(),

        -- Battery
        energyStored = reactor.battery().stored(),
        energyCap = reactor.battery().capacity(),
        energyProdLastTick = reactor.battery().producedLastTick(),

        -- Fuel tank
        fuelCap = reactor.fuelTank().capacity(),
        totalReactant = reactor.fuelTank().totalReactant(),
        fuel = reactor.fuelTank().fuel(),
        waste = reactor.fuelTank().waste(),
        fuelReactivity = reactor.fuelTank().fuelReactivity(),
        burnedLastTick = reactor.fuelTank().burnedLastTick(),

        -- Coolant tank
        coldFluidAmount = reactor.coolantTank().coldFluidAmount(),
        hotFluidAmount = reactor.coolantTank().hotFluidAmount(),
        coolantCap = reactor.coolantTank().capacity(),
        coolantTransLastTick = reactor.coolantTank().transitionedLastTick(),
        coolantMaxTransLastTick = reactor.coolantTank().maxTransitionedLastTick(),
        controlRods = { }
    }
    
    for i = 1, reactor.controlRodCount()
    do
        status.controlRods[i] = {
            index = i,
            name = reactor.getControlRod(i).name(),
            level = reactor.getControlRod(i).level(),
        }
    end
end

local function validCommands()
    return {
        { args = "bool", func = reactor.setActiv, name = "setActive" },
        { args = nil, func = reactor.fuelTank().ejectWaste, name = "ejectWaste" },
        { args = nil, funcs = reactor.coolantTank().dump, name = "dumpCoolant" },
        { args = "number", funcs = reactor.setAllControlRodLevels, name = "setLevel" },
    }
end

local function isValidCommand(command)
    for _, _, cmd in validCommands()
    do
        if cmd == command
        then
            return true
        end
    end
    return false
end

local function getCommand(command)
    for _, f, name in validCommands()
    do
        if name == command
        then
            return f
        end  
    end
end

local function updateReactor(commands)
    for cmd, arg in commands
    do
        if isValidCommand(cmd)
        then
            local func = getCommand(cmd)
            if arg == nil
            then
                func()
            else
                func(arg)
            end
        end
    end
end

local function listen()
    while true
    do
        local event, side, channel, replyChannel, m, distance = os.pullEvent("modem_message")

        if utils.REACTOR_CHANNEL == channel
        then
            msg = m
            msg.replyChannel = replyChannel
            rec_msg = true
        end
    end
end

local function exec()
    while true
    do
        if rec_msg
        then
            rec_msg = false
            if msg.command == utils.STATUS_MSG
            then
                reactorStatus()

                modem.transmit(msg.replyChannel, utils.REACTOR_CHANNEL, status)

            elseif msg.command == utils.PING
            then
                modem.transmit(msg.replyChannel, utils.REACTOR_CHANNEL, "Pong!")
            else
                modem.transmit(msg.replyChannel, utils.REACTOR_CHANNEL, 404)
            end
        else
            coroutine.yield()
        end
    end
end

local function main()
    loadSettings()

    local l = coroutine.create(listen)
    local e = coroutine.create(exec)

    while true
    do
        term.clearLine()
        print("Listening...")
        coroutine.resume(l)
        term.clearLine()
        print("Recived message.")
        term.clearLine()
        print("Executing...")
        coroutine.resume(e)
        term.clearLine()
        print("Finished executing request")
        sleep(0.5)
    end
end