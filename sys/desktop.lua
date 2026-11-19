local m = {}

function m.start()
    term.clear()

    paintutils.drawFilledBox(1, 1, _W, _H, colors.black)

    local work = true

    local history = {}

    local currentStroka = 1
    local scrollOffsetY = 0
    local currentDir = "/users/" .. currentProfile .. "/"

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

    local function redraw()
        term.clear()
        for i, v in ipairs(history) do
            if v then
                wot(v.text, 1, i+scrollOffsetY, false, v.color, colors.black, false)
            end
        end
    end

    function newMessage(text, color)
        enteredCommand = ""
        if not color or color == nil then
            color = colors.white
        end
        local splittedText = wrapText(text, _W)
        for i, v in ipairs(splittedText) do
            wot(v, 1, currentStroka+scrollOffsetY, false, color, colors.black, false)
            history[currentStroka] = {text=v, color=color}
            currentStroka = currentStroka + 1
        end
        if (math.abs(scrollOffsetY)+_H) < #history then
            scrollOffsetY = scrollOffsetY - #splittedText
            redraw()
        end
    end
    function newMessageWithAnswer(text, color)
        enteredCommand = ""
        if not color or color == nil then
            color = colors.white
        end
        local splittedText = wrapText(text, _W)
        for i, v in ipairs(splittedText) do
            wot(v, 1, currentStroka+scrollOffsetY, false, color, colors.black, false)
            history[currentStroka] = {text=v, color=color}
            currentStroka = currentStroka + 1
        end
        wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka+scrollOffsetY, false, colors.yellow, colors.black, false)
        history[currentStroka] = {text=currentDir .. "> " .. enteredCommand .. "_", color=colors.yellow}
        isNeedCommand = true
        if (math.abs(scrollOffsetY)+_H) < #history then
            scrollOffsetY = scrollOffsetY - #splittedText - 1
            redraw()
        end
    end

    enterCommand = function(answer, printOutput)
        if answer ~= "" and answer ~= nil then
            history[currentStroka] = {text=currentDir .. "> " .. answer, color=colors.yellow}
            currentStroka = currentStroka + 1
            local command = split(answer)

            local function processRequest()
                if command[1] == "selectpath" then
                    if command[2] then
                        if command[2] ~= ".." then
                            currentDir = command[2]
                        else
                            currentDir = fs.getDir(command[2])
                        end
                    else
                        currentDir = "/"
                    end
                    if printOutput then
                        newMessageWithAnswer("Selected: " .. command[2])
                    end
                    return "complete"
                elseif command[1] == "shutdown" then
                    if command[2] then
                        shutDownTimer = os.startTimer(command[2])
                    else
                        os.shutdown()
                    end
                    if printOutput then
                        newMessageWithAnswer("Shutdown...")
                    end
                    return "complete"
                elseif command[1] == "reboot" then
                    if command[2] then
                        rebootTimer = os.startTimer(command[2])
                    else
                        os.reboot()
                    end
                    if printOutput then
                        newMessageWithAnswer("Reboot...")
                    end
                    return "complete"
                elseif command[1] == "fs" then
                    if command[2] == "create" then
                        edata.write(command[3], "", 1, currentDir)
                        if printOutput then
                            newMessageWithAnswer("File created", colors.lime)
                        end
                        enterCommand("runApp Editor " .. currentDir .. command[3])
                        return "complete"
                    elseif command[2] == "open" then
                        local path = currentDir .. command[3]
                        if string.find(path, "sys") or string.find(path, "startup.lua") then
                            if printOutput then
                                newMessageWithAnswer("Can't open this file :(", colors.red)
                            end
                        else
                            if printOutput then
                                newMessageWithAnswer("Opened", colors.lime)
                            end
                            enterCommand("runApp Editor " .. currentDir .. command[3])
                        end
                        return "complete"
                    elseif command[2] == "set" then
                        edata.write(command[3], table.concat(command, " ", 4), 1, currentDir)
                        return "complete"
                    elseif command[2] == "copy" then
                        fs.copy(currentDir .. command[3], currentDir .. command[4])
                        if printOutput then
                            newMessageWithAnswer("File copied", colors.lime)
                        end
                        return "complete"
                    elseif command[2] == "rename" then
                        fs.copy(currentDir .. command[3], currentDir .. command[4])
                        fs.delete(currentDir .. command[3], colors.lime)
                        if printOutput then
                            newMessageWithAnswer("File renamed", colors.lime)
                        end
                        return "complete"
                    elseif command[2] == "folder" then
                        fs.makeDir(currentDir .. command[3], colors.lime)
                        if printOutput then
                            newMessageWithAnswer("Folder(-s) created", colors.lime)
                        end
                        return "complete"
                    elseif command[2] == "move" then
                        fs.move(currentDir .. command[3], currentDir .. command[4])
                        if printOutput then
                            newMessageWithAnswer("File moved", colors.lime)
                        end
                        return "complete"
                    elseif command[2] == "delete" then
                        fs.delete(command[3])
                        if printOutput then
                            newMessageWithAnswer("File or directory deleted", colors.lime)
                        end
                        return "complete"
                    elseif command[2] == "list" then
                        local list = edata.list(currentDir .. command[3])
                        
                        if printOutput then
                            newMessage("Directories", colors.lime)
                        end
                        if #list.dir == 0 then
                            if printOutput then
                                newMessage("Empty", colors.red)
                            end
                        else 
                            for i, v in ipairs(list.dir) do
                                if printOutput then
                                    newMessage(v)
                                end
                            end
                        end
                        if printOutput then
                            newMessage("Files", colors.lime)
                        end
                        if #list.files == 0 then
                            if printOutput then
                                newMessageWithAnswer("Empty", colors.red)
                            end
                        else
                            for i, v in ipairs(list.files) do
                                if i+1 >= #list.files then
                                    if printOutput then
                                        newMessageWithAnswer(v)
                                    end
                                else
                                    if printOutput then
                                        newMessage(v)
                                    end
                                end
                            end
                        end
                        return list
                    elseif command[2] == "fm" then
                        if command[4] == "mb" then
                            if printOutput then
                                newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1048576), colors.lime)
                            end
                            return fs.getFreeSpace(currentDir .. command[3])/1048576
                        elseif command[4] == "gb" then
                            if printOutput then
                                newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1073741824), colors.lime)
                            end
                            return fs.getFreeSpace(currentDir .. command[3])/1073741824
                        elseif command[4] == "kb" then
                            if printOutput then
                                newMessageWithAnswer("Remaining memory: " .. (fs.getFreeSpace(currentDir .. command[3])/1024), colors.lime)
                            end
                            return fs.getFreeSpace(currentDir .. command[3])/1024
                        else
                            if printOutput then
                                newMessageWithAnswer("Remaining memory: " .. fs.getFreeSpace(currentDir .. command[3]), colors.lime)
                            end
                            return fs.getFreeSpace(currentDir .. command[3])
                        end
                    else
                        if printOutput then
                            newMessageWithAnswer("Unknown fs command", colors.red)
                        end
                        return "unknown fs command"
                    end
                elseif command[1] == "for" then
                    for i = command[2], command[3] do
                        enterCommand(table.concat(command, " ", 4))
                    end
                    if printOutput then
                        newMessageWithAnswer("Completed!", colors.lime)
                    end
                    return "complete"
                elseif command[1] == "help" then
                    if printOutput then
                        newMessage("selectpath path")
                        newMessage("shutdown [time]")
                        newMessage("reboot [time]")
                        newMessage("fs create path")
                        newMessage("fs open path")
                        newMessage("fs set path data")
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
                        newMessage("for startNumber endNumber command")
                        newMessage("runApp appName [, args...]")
                        newMessage("runLuaX path")
                        newMessage("print text...")
                        newMessage("clear")
                        newMessage("logout")
                        newMessageWithAnswer("wins? symbol")
                    end
                elseif command[1] == "runApp" then
                    local ok, loaded = pcall(dofile, "users/" .. currentProfile .. "/apps/" .. command[2] .. "/main.lua")
                    if not ok then
                        if printOutput then
                            newMessageWithAnswer("Error: " .. tostring(loaded), colors.red)
                        end
                        return "error: " .. tostring(loaded)
                    elseif type(loaded) ~= "table" or type(loaded.start) ~= "function" then
                        if printOutput then
                            newMessageWithAnswer("Error: app has no .start()", colors.red)
                        end
                        return "error: no .start()"
                    else
                        local args = {}
                        for i = 3, #command do
                            args[#args + 1] = command[i]
                        end
                        activeApp = loaded
                        appCtx = {
                            isClosed = function() return mode ~= "app" end,
                            close = function() mode = "shell" end,
                            sysVer = _V,
                            sysVerT = _VT,
                            args = args,
                            currentDir = "users/" .. currentProfile .. "/apps/" .. command[2],
                            width = _W,
                            height = _H,
                            edata = edata,
                            currentProfile = currentProfile
                        }
                        mode = "app"
                        term.clear()
                        term.setCursorPos(1, 1)
                    end
                elseif command[1] == "runLuaX" then
                    local api = {
                        runCommand = function(command)
                            if command ~= "run" and command ~= "" and command ~= nil and command ~= "fs open" and command ~= "fs create" then
                                enterCommand(command)
                            end
                        end
                    }

                    local status, data = edata.read(currentDir .. command[2], 1, "")
                    if status == true then
                        local script = load(data, "customScript", "t", api)
                        if script then
                            local status, err = pcall(script)
                            if status == false then
                                if printOutput then
                                    newMessageWithAnswer("Script error: " .. err, colors.red)
                                end
                            else
                                if printOutput then
                                    newMessageWithAnswer("Script completed", colors.lime)
                                end
                            end
                        else
                            if printOutput then
                                newMessageWithAnswer("File not founded or not luaX script", colors.red)
                            end
                        end
                    else
                        if printOutput then
                            newMessageWithAnswer("File not founded", colors.red)
                        end
                    end
                elseif command[1] == "print" then
                    newMessageWithAnswer(table.concat(command, " ", 2))
                    return table.concat(command, " ", 2)
                elseif command[1] == "wins?" then
                    if printOutput then
                        newMessageWithAnswer("Symbol: " .. command[2] .. " | Code: " .. string.byte(command[2]))
                    end
                    return command[2], string.byte(command[2])
                elseif command[1] == "clear" then
                    history = {}
                    redraw()
                    if printOutput then
                        newMessageWithAnswer("Cleared")
                    end
                    return "complete"
                elseif command[1] == "logout" then
                    work = false
                    currentProfile = ""
                    login.start()
                else
                    if printOutput then
                        newMessageWithAnswer("Unknown command", colors.red)
                    end
                    return "unknown command"
                end
            end

            local status, err = pcall(processRequest)
            if status == false then
                newMessageWithAnswer("Error: " .. (err or "unknown"), colors.red)
            end
        else
            isNeedCommand = true
        end
    end
    newMessageWithAnswer(string.format("XsyndaOS | Entaru Studio | Version %s (%s)", _VT, _V), colors.lime)

    local function mainLoop()
        while work == true do
            if mode == "app" then
                local realPull = os.pullEventRaw
                os.pullEvent = function(filter)
                    while true do
                        local ev = {realPull(filter)}
                        if ev[1] == "key" and keys.getName(ev[2]) == "home" then
                            error("__APP_CLOSED__", 0)

                        elseif ev[1] == "terminate" then

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

                term.clear()
                term.setCursorPos(1, 1)
                redraw()
                newMessageWithAnswer("App closed")
            else
                local eventData = {os.pullEventRaw()}
                local event = eventData[1]

                if event == "mouse_scroll" then
                    if eventData[2] == 1 then
                        if (math.abs(scrollOffsetY)+_H) < #history then
                            scrollOffsetY = scrollOffsetY - 1
                            redraw()
                        end
                    elseif eventData[2] == 0 and math.abs(scrollOffsetY) >= 1 then
                        scrollOffsetY = scrollOffsetY + 1
                        redraw()
                    end
                elseif event == "terminate" then

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
                        if isNeedCommand == true then
                            isNeedCommand = false
                            enterCommand(enteredCommand, true)
                        end
                    elseif key == "backspace" then
                        if isNeedCommand == true then
                            enteredCommand = string.sub(enteredCommand, 1, -2)
                            wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka+scrollOffsetY, true, colors.yellow, colors.black, false)
                        end
                    elseif key == "end" then
                        if (math.abs(scrollOffsetY)+_H) < #history then
                            scrollOffsetY = -#history + _H
                            redraw()
                        end
                    else
                        if allowedLetters[key] == true and isNeedCommand == true then
                            local symbol
                            if isUpper == true then
                                symbol = replaceUpperLetters[key]
                                if symbol == nil then
                                    symbol = string.upper( key )
                                end
                            else
                                symbol = replaceLetters[key]
                                if symbol == nil then
                                    symbol = key
                                end
                            end
                            if type(symbol) == "number" then
                                symbol = tostring(symbol)
                            end
                            enteredCommand = enteredCommand .. symbol
                            wot(currentDir .. "> " .. enteredCommand .. "_", 1, currentStroka+scrollOffsetY, true, colors.yellow, colors.black, false)
                        end
                    end
                elseif event == "key_up" then
                    local key = keys.getName(eventData[2])
                    if key == "leftShift" then
                        isUpper = false
                    end
                end
            end
            --sleep(0.001)
        end
    end

    parallel.waitForAny(mainLoop)
end

return m