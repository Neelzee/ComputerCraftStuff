local db = require "database"
local utils = require "utils"
local rc = require "reactor"
local terminal = require "terminal"

function Main()
    -- Terminal thread
    local cmds = coroutine.create(terminal.TerminalCommands)
    local tf = 
        function ()

            if coroutine.status(cmds) == "suspended"
            then
                coroutine.resume(cmds)
            end

        end
    -- Database-connection thread
    local db_conn = coroutine.create(db.DatabaseConnection)
    local dbf =
        function ()
            if coroutine.status(db_conn) == "suspended"
            then
                utils.QUERY_RESULT = coroutine.resume(db_conn, utils.QUERY)
            end
        end

    -- Display thread
    local disp = coroutine.create(TerminalDisplay)
    local df =
        function ()
            if coroutine.status(disp) == "suspended"
            then
                coroutine.resume(disp)
            end
        end

    -- Reactor-computer-connection thread
    local rc_conn = coroutine.create(rc.ReactorConnection)
    local rcf =
        function ()
            if coroutine.status(rc_conn) == "suspended"
            then
                utils.REACTOR_STATUS = coroutine.resume(rc_conn)
            end
        end

    -- TODO: Add error handling for terminating threads
    while true do
        parallel.waitForAny
        (
            tf,
            dbf,
            df,
            rcf
        )
    end
end

function TerminalDisplay()
    local width, height = term.getSize()
    
end



