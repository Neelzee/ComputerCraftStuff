local methods = {}

methods.MODEM =
    function()
        for _, modem in { peripheral.find("modem") }
        do
            return modem
        end
    end

methods.DB_CHANNEL = 10

methods.RC_CHANNEL = 20

methods.QUERY = nil

methods.QUERY_RESULT = nil

methods.REACTOR_STATUS = nil

methods.COMMAND_HISTORY = {}

methods.CURRENT_COMMAND = ""

methods.STATUS_MSG = "STATUS"

function methods.HandleEvents(events)
    while true do
        local event, side, channel, replyChannel, msg, distance = os.pullEvent()

        for e in events
        do
            if e == event
            then
                coroutine.yield(200, event, side, channel, replyChannel, msg, distance)
            end
        end
    end
end



return methods