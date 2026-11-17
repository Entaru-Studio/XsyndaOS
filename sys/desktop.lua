local m = {}

function m.start()
    term.clear()

    local work = true

    local history = {{}}
    local currentPage = 1
    local selectedPage = 1

    local currentStroka = 1
    local currentDir = "/"

    local enterCommand

    local app
    local mode = "shell"
    local activeApp = nil
    local appCtx = nil

    local shutDownTimer
    local rebootTimer

    local enteredCommand = ""
    local isNeedCommand = false
    local isUpper = false
    local allowedKeys = {
        a = true, b = true, c = true, d = true, e = true,
        f = true, g = true, h = true, i = true, j = true,
        k = true, l = true, m = true, n = true, o = true,
        p = true, q = true, r = true, s = true, t = true,
        u = true, v = true, w = true, x = true, y = true,
        z = true, one = true, two = true, three = true,
        four = true, five = true, six = true, seven = true,
        eight = true, nine = true, zero = true, space = true,
        period = true, comma = true, slash = true, backslash = true,
        ["!"] = true, ["@"] = true, ["#"] = true, ["$"] = true,
        ["%"] = true, ["^"] = true, ["&"] = true, ["*"] = true,
        ["("] = true, [")"] = true, ["{"] = true, ["}"] = true,
        leftBracked = true, rightBracked = true, ["|"] = true, [":"] = true,
        semiColon = true, ["\""] = true, apostrophe = true, ["<"] = true,
        [">"] = true, ["?"] = true, minus = true, ["_"] = true,
        equals = true, ["+"] = true
    }
    local replaceKeys = {
        one = 1, two = 2, three = 3, four = 4, five = 5,
        six = 6, seven = 7, eight = 8, nine = 9, zero = 0,
        space = " ", period = ".", comma = ",", slash = "/",
        backslash = "\\", leftBracked = "[", rightBracked = "]",
        semiColon = ";", apostrophe = "'", minus = "-", equals = "="
    }

    local function redraw()
        term.clear()
        for i = 1, _H do
            if history[selectedPage][i] then
                wot(history[selectedPage][i], 1, i)
            end
        end
    end

    function newMessage(text)
        enteredCommand = ""
        local splittedText = wrapText(text, _W)
        for i, v in ipairs(splittedText) do
            wot(v, 1, currentStroka)
            history[currentPage][currentStroka] = v
            currentStroka = currentStroka + 1
            if currentStroka >= _H then
                currentPage = currentPage + 1
                history[currentPage] = {}
                currentStroka = 1
                selectedPage = currentPage
                redraw()
            end
        end
    end
    function newMessageWithAnswer(text)
        enteredCommand = ""
        local splittedText = wrapText(text, _W)
        for i, v in ipairs(splittedText) do
            wot(v, 1, currentStroka)
            history[currentPage][currentStroka] = v
            currentStroka = currentStroka + 1
            if currentStroka >= _H then
                currentPage = currentPage + 1
                history[currentPage] = {}
                currentStroka = 1
                selectedPage = currentPage
                redraw()
            end
        end
        wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka)
        history[currentPage][currentStroka] = currentDir .. "> " .. enteredCommand .. "_"
        isNeedCommand = true
    end

    enterCommand = function(answer)
        if answer ~= "" and answer ~= nil then
            history[currentPage][currentStroka] = currentDir .. "> " .. answer .. "_"
            currentStroka = currentStroka + 1
            if currentStroka >= _H then
                currentPage = currentPage + 1
                history[currentPage] = {}
                currentStroka = 1
            end
            local command = split(answer)

            local function processRequest()
                if command[1] == "selectpath" then
                    if command[2] then
                        currentDir = command[2]
                    else
                        currentDir = "/"
                    end
                    newMessageWithAnswer("Selected: " .. command[2])
                elseif command[1] == "shutdown" then
                    if command[2] then
                        shutDownTimer = os.startTimer(command[2])
                    else
                        os.shutdown()
                    end
                elseif command[1] == "reboot" then
                    if command[2] then
                        rebootTimer = os.startTimer(command[2])
                    else
                        os.reboot()
                    end
                elseif command[1] == "hardreboot" then
                    local hrc = [[
local edata = require "sys.edata"
edata.write("startup.lua", "shell.run(\"sys/boot.lua\")", 1, "")                
]]
                    edata.write("startup.lua", hrc, 1, "")
                    os.reboot()
                elseif command[1] == "fs" then
                    if command[2] == "create" then
                        edata.write(command[3], "", 1, currentDir)
                        newMessageWithAnswer("File created")
                        editor.start(currentDir .. command[3])
                    elseif command[2] == "open" then
                        newMessageWithAnswer("Opened")
                        editor.start(currentDir .. command[3])
                    elseif command[2] == "copy" then
                        fs.copy(currentDir .. command[3], currentDir .. command[4])
                        newMessageWithAnswer("File copied")
                    elseif command[2] == "rename" then
                        fs.copy(currentDir .. command[3], currentDir .. command[4])
                        fs.delete(currentDir .. command[3])
                        newMessageWithAnswer("File renamed")
                    elseif command[2] == "folder" then
                        fs.makeDir(currentDir .. command[3])
                        newMessageWithAnswer("Folder(-s) created")
                    elseif command[2] == "move" then
                        fs.move(currentDir .. command[3], currentDir .. command[4])
                        newMessageWithAnswer("File moved")
                    elseif command[2] == "delete" then
                        fs.delete(command[3])
                    elseif command[2] == "list" then
                        local list = edata.list(currentDir .. command[3])
                        newMessage("   Directories")
                        if #list.dir == 0 then
                            newMessage("Empty")
                        else 
                            for i, v in ipairs(list.dir) do
                                newMessage(v)
                            end
                        end
                        newMessage("   Files")
                        if #list.files == 0 then
                            newMessageWithAnswer("Empty")
                        else
                            for i, v in ipairs(list.files) do
                                if i+1 >= #list.files then
                                    newMessageWithAnswer(v)
                                else
                                    newMessage(v)
                                end
                            end
                        end
                    elseif command[2] == "fm" then
                        if command[4] == "mb" then
                            newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1048576))
                        elseif command[4] == "gb" then
                            newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1073741824))
                        elseif command[4] == "kb" then
                            newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1024))
                        else
                            newMessageWithAnswer("Remaining memory: " .. fs.getFreeSpace(currentDir .. command[3]))
                        end
                    else
                        newMessageWithAnswer("Unknown fs command")
                    end
                elseif command[1] == "for" then
                    for i = command[2], command[3] do
                        enterCommand(table.concat(command, " ", 4))
                    end
                elseif command[1] == "help" then
                    newMessage("selectpath path")
                    newMessage("shutdown [time]")
                    newMessage("reboot [time]")
                    newMessage("hardreboot")
                    newMessage("fs create path")
                    newMessage("fs open path")
                    newMessage("fs copy path newPath")
                    newMessage("fs rename filePath newPath")
                    newMessage("fs folder path")
                    newMessage("fs move oldPath newPath")
                    newMessage("fs delete path")
                    newMessage("fs list path")
                    newMessage("fs fm")
                    newMessage("fs fm kb")
                    newMessage("fs fm mb")
                    newMessage("fs fm gb")
                    newMessageWithAnswer("for startNumber endNumber command")
                elseif command[1] == "run" then
                    local ok, loaded = pcall(dofile, currentDir .. command[2])
                    if not ok then
                        newMessageWithAnswer("Error: " .. tostring(loaded))
                    elseif type(loaded) ~= "table" or type(loaded.start) ~= "function" then
                        newMessageWithAnswer("Error: app has no .start()")
                    else
                        activeApp = loaded
                        appCtx = {
                            isClosed = function() return mode ~= "app" end,
                            close = function() mode = "shell" end,
                            sysVer = _V
                        }
                        mode = "app"
                        term.clear()
                        term.setCursorPos(1, 1)
                    end
                else
                    newMessageWithAnswer("Unknown command")
                end
            end

            local status, err = pcall(processRequest)
            if status == false then
                newMessageWithAnswer("Error: " .. (err or "unknown"))
            end
        else
            isNeedCommand = true
        end
    end
    newMessageWithAnswer(string.format("XsyndaOS | Entaru Studio | Version %s (%s)", _VT, _V))

    local function mainLoop()
        while work == true do
            if mode == "app" then
                local realPull = os.pullEvent
                os.pullEvent = function(filter)
                    while true do
                        local ev = {realPull(filter)}
                        if ev[1] == "key" and keys.getName(ev[2]) == "home" then
                            error("__APP_CLOSED__", 0)
                        end
                        if filter == nil or ev[1] == filter then
                            return table.unpack(ev)
                        end
                    end
                end

                local ok, err = pcall(activeApp.start, appCtx)
                os.pullEvent = realPull

                if not ok and tostring(err) ~= "__APP_CLOSED__" then
                    newMessage("App error: " .. tostring(err))
                end

                mode = "shell"
                activeApp = nil
                appCtx = nil

                selectedPage = currentPage
                term.clear()
                term.setCursorPos(1, 1)
                redraw()
                newMessageWithAnswer("App closed")
            else
                local eventData = {os.pullEvent()}
                local event = eventData[1]

                if event == "mouse_scroll" then
                    if eventData[2] == 1 then
                        if selectedPage < #history then
                            selectedPage = selectedPage + 1
                            redraw()
                        end
                    else
                        if selectedPage > 1 then
                            selectedPage = selectedPage - 1
                            redraw()
                        end
                    end
                elseif event == "timer" then
                    if eventData[2] == shutDownTimer then
                        os.shutdown()
                    elseif eventData[2] == rebootTimer then
                        os.reboot()
                    end
                elseif event == "key" then
                    local key = keys.getName(eventData[2])
                    if key == "leftShift" then
                        isUpper = true
                    elseif key == "enter" then
                        if isNeedCommand == true and selectedPage == currentPage then
                            isNeedCommand = false
                            enterCommand(enteredCommand)
                        end
                    elseif key == "backspace" then
                        if isNeedCommand == true then
                            enteredCommand = string.sub(enteredCommand, 1, -2)
                            wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka)
                        end
                    else
                        if allowedKeys[key] == true and isNeedCommand == true and selectedPage == currentPage then
                            local symbol = key
                            if isUpper == true then
                                if symbol == "leftBracket" then
                                    symbol = "{"
                                elseif symbol == "rightBracked" then
                                    symbol = "}"
                                elseif symbol == "semiColon" then
                                    symbol = ":"
                                elseif symbol == "apostrophe" then
                                    symbol = "\""
                                elseif symbol == "comma" then
                                    symbol = "<"
                                elseif symbol == "period" then
                                    symbol = ">"
                                elseif symbol == "slash" then
                                    symbol = "?"
                                elseif symbol == "backslash" then
                                    symbol = "|"
                                elseif symbol == "one" then
                                    symbol = "!"
                                elseif symbol == "two" then
                                    symbol = "@"
                                elseif symbol == "three" then
                                    symbol = "#"
                                elseif symbol == "four" then
                                    symbol = "$"
                                elseif symbol == "five" then
                                    symbol = "%"
                                elseif symbol == "six" then
                                    symbol = "^"
                                elseif symbol == "seven" then
                                    symbol = "&"
                                elseif symbol == "eight" then
                                    symbol = "*"
                                elseif symbol == "nine" then
                                    symbol = "("
                                elseif symbol == "zero" then
                                    symbol = ")"
                                elseif symbol == "`" then
                                    symbol = "~"
                                elseif symbol == "minus" then
                                    symbol = "_"
                                elseif symbol == "equals" then
                                    symbol = "+"
                                else
                                    symbol = string.upper( symbol )
                                end
                            end
                            for k, v in pairs(replaceKeys) do
                                symbol = symbol:gsub(k, v)
                            end
                            enteredCommand = enteredCommand .. symbol
                            wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka)
                        end
                    end
                elseif event == "key_up" then
                    local key = keys.getName(eventData[2])
                    if key == "leftShift" then
                        isUpper = false
                    end
                end
            end
            sleep(0.01)
        end
    end

    parallel.waitForAny(mainLoop)
end

return m