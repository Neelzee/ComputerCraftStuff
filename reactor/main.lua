local reactor = peripheral.wrap("back")

local date = require "date"

local settings = {
    active = false,
    controlRodLevel = 50,
    maxTemp = 100,
    maxConsumption = 10,
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
end

local function reactorStatus()
    while true do
        status = {
            isConnected = reactor.getConnected(),
            isActive = reactor.isConnected(),
            controlRods = { },
            energy = reactor.getEnergyStored(),
            fuelTemp = reactor.getFuelTemperature(),
            casingTemp = reactor.getCasingTemperature(),
            fuel = reactor.getFuelAmount(),
            waste = reactor.getWasteAamount(),
            fuelMax = reactor.getFuelAmountMax(),
            energyProdLastTick = reactor.getEnergyProducedLastTick(),
            hotFluidProdLastTick = reactor.getHotFluidProducedLastTick(),
            coolantType = reactor.getCoolantType(),
            coolantAmount = reactor.getCoolantAmount(),
            hotFluidType = reactor.getHotFluidAmount(),
            fuelReactivity = reactor.getFuelReactivity(),
            fuelConsumptionLastTick = reactor.getFuelConsumedLastTick(),
            isActivelyCooled = reactor.isActivelyCooled()
        }
    
        for i = 1, reactor.getControlRods(), 1
        do
            status.controlRods[i] = {
                name = reactor.getControlRodName(i),
                level = reactor.getControlRodLevel(i)
            }
        end
    end
end


local function updateReactor(commands)
    for cmd, arg in commands
    do
        reactor[cmd](arg)
    end
end



local function main()
    loadSettings()
    local update = coroutine.create(updateReactor)

    

end