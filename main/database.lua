local utils = require "utils"

local methods = {}


function methods.DatabaseConnection(q)
    while true
    do
        if q == nil
        then
            coroutine.yield(nil)
        end

        if not MODEM.isOpen(utils.DB_CHANNEL)
        then
            MODEM.open(utils.DB_CHANNEL)
        end
    
        local query = coroutine.create(methods.DatabaseQuery)
    
        local table = coroutine.resume(query, q)
    
        coroutine.yield(table)
    end
end


function methods.DatabaseQuery(query)
    utils.MODEM.transmit(utils.DB_CHANNEL, utils.DB_CHANNEL, ("%s"):format(query))

    os.startTimer(5)
    local events = coroutine.create(utils.HandleEvents)

    local succ, event, side, channel, replyChannel, msg, distance = coroutine.resume(events, {"modem_message", "timer"})

    if not succ
    then
        -- TODO: Handle error on events
    end
    

    if event == "modem_message" and (channel == replyChannel and replyChannel == utils.DB_CHANNEL)
    then
        local res, msg, table = msg

        if not res
        then
            -- TODO: handle errors
        end

        coroutine.yield(table)
    else
        -- TODO: Handle event not being modem_message
    end
end


return methods