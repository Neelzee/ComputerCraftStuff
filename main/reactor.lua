local utils = require "utils"

local methods = {}

function methods.ReactorConnection()
    -- Coroutine for handling events
    local events = coroutine.create(utils.HandleEvents)

    -- Checks if modem is open
    if not utils.MODEM.isOpen(utils.RC_CHANNEL)
    then
        utils.MODEM.open(utils.RC_CHANNEL)
    end

    -- Loop
    while true
    do
        utils.MODEM.transmit(utils.RC_CHANNEL, utils.RC_CHANNEL, utils.STATUS_MSG)

        local status = {}

        
        
        os.startTimer(10)
        local index = 1

        -- Loops for 10 seconds
        while true
        do
            local succ, event, side, channel, replyChannel, msg, distance = coroutine.resume(events, {"modem_message", "timer"})

            if not succ or event == "timer"
            then
                break
            end

            local code, state = msg

            if event == "modem_message" and (channel == replyChannel and replyChannel == utils.DB_CHANNEL)
            then
                status[index] = state
                status[index].response = code
                index = index + 1
            end
        end

        coroutine.yield(status)
    end
end


return methods