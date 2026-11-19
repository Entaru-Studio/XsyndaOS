local m = {}

function m.start()
    term.clear()
    term.setCursorPos(1, 1)
    local work = true

    wot("XsyndaOS", 1, 1, false, colors.lime, colors.black)
    wot("Entaru Studios", 1, 2, false, colors.lime, colors.black)
    wot("Version name: " .. _VT, 1, 3, false, colors.lime, colors.black)
    wot("Version code: " .. _V, 1, 4, false, colors.lime, colors.black)
    local freeMem = fs.getFreeSpace("/")
    if freeMem > 1073741824 then
        freeMem = freeMem/1073741824 .. "gb"
    elseif freeMem > 1048576 then
        freeMem = freeMem/1048576 .. "mb"
    elseif freeMem > 1024 then
        freeMem = freeMem/1024 .. "kb"
    elseif freeMem > 0 then
        freeMem = freeMem .. "b"
    end
    wot("Free memory remaining: " .. freeMem, 1, 5, false, colors.lime, colors.black)

    wot("Press DELETE for enter to shell", 1, 7, false, colors.yellow, colors.black)

    local initEnd = os.startTimer(1.5)

    fs.makeDir("users")

    local function mainLoop()
        while work == true do
            local eventData = {os.pullEvent()}
            
            if eventData[1] == "key" then
                if keys.getName(eventData[2]) == "delete" then
                    term.clear()
                    term.setCursorPos(1, 1)
                    error("Shell started. Use \"reboot\" or \"startup\" to start the system", 0)
                end
            elseif eventData[1] == "timer" then
                if eventData[2] == initEnd then
                    work = false
                    login.start()
                end
            end
            sleep(0.05)
        end
    end

    parallel.waitForAny(mainLoop)
end

return m