local utils = require "utils"

local methods = {}



function methods.TerminalCommands()
    local events = coroutine.create(utils.HandleEvents)
    while true do
        local c, event = coroutine.resume(events, {"char", "key"})

        if c == "28"
        then
            -- TODO: Parse command
            utils.COMMAND_HISTORY[#utils.COMMAND_HISTORY] = utils.CURRENT_COMMAND
        elseif c == "57"
        then
            utils.CURRENT_COMMAND = utils.CURRENT_COMMAND + " "
        elseif c >= 2 and c <= 11
        then
            utils.URRENT_COMMAND = utils.CURRENT_COMMAND + tostring(c)
        elseif event == "char"
        then
            utils.CURRENT_COMMAND = utils.CURRENT_COMMAND + c
        end
    end
end