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
        --print(text)
        
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
        --print(currentDir .. "> ")
        isNeedCommand = true
    end

    enterCommand = function(answer)
        history[currentPage][currentStroka] = currentDir .. "> " .. answer .. "_"
        currentStroka = currentStroka+1
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
            else
                newMessageWithAnswer("Unknown command")
            end
        end

        local status, err = pcall(processRequest)
        if status == false then
            newMessageWithAnswer("Error: " .. (err or "unknown"))
        end
    end
    newMessageWithAnswer("XsyndaOS | Entaru Studio | Version 1.0")

    local function mainLoop()
        while work == true do
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
                --print(key)
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
            sleep(0.05)
        end
    end

    parallel.waitForAny(mainLoop)
end

return m