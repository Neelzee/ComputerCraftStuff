local term = require "term"


local fields = {
    -- What mode the program is in
    mode = "",
    filename = "No Name",
    -- Whats not been written to a file
    buffer = {},
    -- Previous command
    prevCmd = {},
    -- Previous action, like deleting a line, moving a line, etc.
    prevAction = {},
    cursor = {x = 0, y = 0},
    notSavedIcon = "+"
}

local commands = {
    { cmd = "w", info = "saves the file" },
    { cmd = "q", info = "exits the editor, will prompt if there is unsaved progress" },
    { cmd = "q!", info = "exits the editor, even if there is unsaved progress" },
    { cmd = "u", info = "undos the last edit" },
    { cmd = "h", info = "prints this menu" },
    { cmd = "wq", info = "saves and exits" },
}



-- Returns the CLI position
local function getCLIPosition()
    local _, y, _, _, _, _ = term.getViewPort()

    return 0, y
end

-- Clears the CLI
local function clearCLI()
    local startRow, endRow = getCLIPosition()
    local x, y, _, _, _, _ = term.getCursor()
    fields.cursor = {x = x, y = y}

    for i = startRow, endRow, 1
    do
        term.setCursor(0, i)
    end

    
    term.clearLine()

    term.setCursor(term.getCursor()[1], term.getCursor()[2])
end

-- Formats the cursor position to x,y
local function formatCursorPosition()
    return ("%n,%n"):format(fields.cursor.x, fields.cursor.y)
end

-- Draws the CLI
local function drawCLI()
    local _, y = getCLIPosition()
    fields.cursor = term.getCursor()

    term.setCursor(0, y)

    local str = ("[%s]"):format(fields.filename)

    local rows, cols, _, _, _, _ = term.getViewPort()

    if #fields.buffer ~= 0
    then
        str = str + (" [%]"):format(fields.notSavedIcon)
    end

    -- TODO: Change to replicate or whatever
    -- Length of the current string, + a whitespace, + length of the savedIcon + 2, - the length of the current position
    for i = #str + 1 + #fields.notSavedIcon  + 2 - #formatCursorPosition(), cols, 1
    do
        str = str + " "
    end 

    str = str + formatCursorPosition()

    str = str + ("\n-- %s --"):format(fields.move:upper())

    term.write(str)
end

-- Parses the user input into a command and arguments
local function parseCommand(input)
    local inp = {}

    local i = 1

    for j = 1, #input, 1
    do
        if input[j] == " "
        then
            i = i + 1
        else
            inp[i] = inp[i] + input[j]
        end
    end

    local cmd = inp[1]
    local args = {}
    for i = 2, #inp, 1
    do
        args:insert(inp[i])
    end

    return cmd, args
end


local function writeToTerminal()
    while true
    do
        
    end
end