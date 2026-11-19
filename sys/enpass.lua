local m = {}

function m.start(profile)
    term.clear()
    term.setCursorPos(1, 1)
    local work = true

    local enteredText = ""
    local isNeedEnterText = true
    local isUpper = false
    local currentString = 6

    wot(profile, _W/2, 2, false, colors.white, colors.black, true)

    wot("Enter password", _W/2, 4, false, colors.white, colors.black, true)

    wot("_", _W/2, currentString, true, colors.yellow, colors.black, true)

    local function mainLoop()
        while work == true do
            local eventData = {os.pullEventRaw()}

            if eventData[1] == "terminate" then

            elseif eventData[1] == "key" then
                local key = keys.getName(eventData[2])
                if key == "enter" then
                    if enteredText == "" or enteredText == nil then
                        wot("Password field is empty", _W/2, _H-1, true, colors.white, colors.black, true)
                    else
                        local status, data = edata.read("udat.json", 1, "users/" .. profile)
                        if status == true then
                            local usD = textutils.unserializeJSON(data)

                            if enteredText == usD.pass then
                                local status, data = edata.read("settings.json", 1, "users/" .. profile)
                                if status == true then
                                    local settings = textutils.unserializeJSON(data)

                                    if settings.hourFormat == nil then
                                        settings.hourFormat = 24
                                    end
                                    if settings.bgColor == nil then
                                        settings.bgColor = colors.black
                                    end

                                    edata.write("settings.json", textutils.serializeJSON(settings), 1, "users/" .. profile)
                                else
                                    local settings = {
                                        hourFormat = 24,
                                        bgColor = colors.black
                                    }

                                    edata.write("settings.json", textutils.serializeJSON(settings), 1, "users/" .. profile)
                                end
                                fs.makeDir("users/" .. profile .. "/apps")
                                work = false
                                currentProfile = profile
                                desktop.start()
                            else
                                wot("Incorrect password!", _W/2, _H-1, true, colors.white, colors.black, true)
                            end
                        else
                            wot("User not found", _W/2, _H-1, true, colors.white, colors.black, true)
                        end
                    end
                elseif key == "backspace" then
                    if isNeedEnterText == true then
                        enteredText = string.sub(enteredText, 1, -2)
                        wot(enteredText .. "_", _W/2, currentString, true, colors.yellow, colors.black, true)
                    end
                elseif key == "leftShift" then
                    isUpper = true
                else
                    if allowedLetters[key] == true and isNeedEnterText == true then
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
                        enteredText = enteredText .. symbol
                        wot(enteredText .. "_", _W/2, currentString, true, colors.yellow, colors.black, true)
                    end
                end
            elseif eventData[1] == "key_up" then
                local key = keys.getName(eventData[2])
                if key == "leftShift" then
                    isUpper = false
                end
            end
        end 
    end

    parallel.waitForAny(mainLoop)
end

return m