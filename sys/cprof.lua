local m = {}

function m.start()
    term.clear()
    term.setCursorPos(1, 1)
    local work = true

    local enteredText = ""
    local isNeedEnterText = true
    local isUpper = false
    local currentString = 4

    local username
    local password

    wot("Enter username", _W/2, 2, false, colors.white, colors.black, true)

    wot("_", _W/2, currentString, true, colors.yellow, colors.black, true)

    local function mainLoop()
        while work == true do
            local eventData = {os.pullEventRaw()}

            if eventData[1] == "terminate" then

            elseif eventData[1] == "key" then
                local key = keys.getName(eventData[2])
                if key == "enter" then
                    if currentString == 4 then
                        local status, _ = edata.read(enteredText .. "/udat.json", 1, "users")
                        if status == true then
                            wot("This user is already exists", _W/2, _H-1, true, colors.white, colors.black, true)
                        elseif enteredText == "" or enteredText == nil then
                            wot("Incorrect username", _W/2, _H-1, true, colors.white, colors.black, true)
                        else
                            wot(enteredText, _W/2, currentString, true, colors.yellow, colors.black, true)
                            username = enteredText
                            enteredText = ""
                            wot("Create password", _W/2, 6, false, colors.white, colors.black, true)
                            currentString = 8
                            wot(enteredText .. "_", _W/2, currentString, true, colors.yellow, colors.black, true)
                        end
                    elseif currentString == 8 then
                        password = enteredText
                        wot(enteredText, _W/2, currentString, true, colors.yellow, colors.black, true)
                        enteredText = ""
                        isNeedEnterText = false

                        local isAdmin = false
                        if #edata.list("users", "").dir == 0 then
                            isAdmin = true
                        end
                        fs.makeDir("users/" .. username)
                        edata.write("udat.json", textutils.serializeJSON({pass=password, isAd=isAdmin}), 1, "users/" .. username)

                        local settings = {
                            hourFormat = 24,
                            bgColor = colors.black
                        }

                        edata.write("settings.json", textutils.serializeJSON(settings), 1, "users/" .. username)
                        fs.makeDir("users/" .. username .. "/apps")

                        fs.makeDir("users/" .. username .. "/apps/Store/")
                        fs.copy("sys/store.lua", "users/" .. username .. "/apps/Store/main.lua")

                        work = false
                        login.start()
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