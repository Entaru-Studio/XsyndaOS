local m = {}

function m.start()
    term.clear()
    term.setCursorPos(1, 1)
    local work = true

    local currentString = 4
    local currentPage = 1
    local selectedPage = 1
    local history = {{}}

    wot("Select profile", _W/2, 2, false, colors.white, colors.black, true)

    wot("Create new", _W/2, _H-1, false, colors.white, colors.black, true)

    local function redraw()
        term.clear()
        paintutils.drawFilledBox(1, 1, _W, _H, colors.black)

        wot("Select profile", _W/2, 2, false, colors.white, colors.black, true)

        wot("Create new", _W/2, _H-1, false, colors.white, colors.black, true)

        for i, v in ipairs(history[selectedPage]) do
            if v then
                wot(v, _W/2, i, true, colors.yellow, colors.black, true)
            end
        end
    end

    for i, v in ipairs(edata.list("users", "").dir) do
        wot(v, _W/2, currentString, true, colors.yellow, colors.black, true)
        history[currentPage][currentString] = v
        if currentString < _H - 4 then
            currentString = currentString + 1
        else
            currentString = 4
            currentPage = currentPage + 1
            selectedPage = currentPage
            history[currentPage] = {}
        end
    end

    local function mainLoop()
        while work == true do
            local eventData = {os.pullEventRaw()}

            if eventData[1] == "terminate" then

            elseif eventData[1] == "key" then

            elseif eventData[1] == "mouse_scroll" then
                if eventData[2] == 1 then
                    -- down
                    if selectedPage < currentPage then
                        selectedPage = selectedPage + 1
                    end
                elseif eventData[2] == 0 then
                    if selectedPage > 1 then
                        selectedPage = selectedPage - 1
                    end
                end
            elseif eventData[1] == "mouse_click" then
                if eventData[4] == _H-1 then
                    work = false
                    cprof.start()
                elseif eventData[4] >= 4 and eventData[4] <= _H-3 then
                    if history[selectedPage][eventData[4]] then
                        work = false
                        enpass.start(history[selectedPage][eventData[4]])
                    end
                end
            end
        end
    end

    parallel.waitForAny(mainLoop)
end

return m