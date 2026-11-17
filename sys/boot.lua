term.clear()

local work = true

_W, _H = term.getSize()
_V, _VT = 4, "1.1.2"

edata = require("edata")

desktop = require("desktop")

function wot(text, x, y)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end
function split(str)
    local result = {}
    for word in string.gmatch(str, "%S+") do
        table.insert(result, word)
    end
    return result
end
function wrapText(text, width)
    local lines = {}
    for paragraph in (text .. "\n"):gmatch("(.-)\n") do
        if #paragraph == 0 then
            lines[#lines + 1] = ""
        else
            local line = ""
            for word in paragraph:gmatch("%S+") do
                if #line == 0 then
                    -- первое слово в строке
                    while #word > width do
                        lines[#lines + 1] = word:sub(1, width)
                        word = word:sub(width + 1)
                    end
                    line = word
                elseif #line + 1 + #word <= width then
                    line = line .. " " .. word
                else
                    lines[#lines + 1] = line
                    while #word > width do
                        lines[#lines + 1] = word:sub(1, width)
                        word = word:sub(width + 1)
                    end
                    line = word
                end
            end
            if #line > 0 then
                lines[#lines + 1] = line
            end
        end
    end
    return lines
end

wot("X S Y N D A O S", 1, 1)
wot("Entaru Studio 2026", 1, 2)
wot(string.format("OS Version: %s (%s)", _VT, _V), 1, 3)
wot("Free space: " .. math.floor(fs.getFreeSpace("/") / 1000000) .. "mb", 1, 4)

wot("Loading...", 1, 6)

local status, data = edata.read("settings.json", 1, "sys")
if status == true then
    Settings = textutils.unserializeJSON(data)
    if Settings.bgColor == nil then
        Settings.bgColor = "blue"
    end

    edata.write("settings.json", textutils.serializeJSON(Settings), 1, "sys")
else
    Settings = {
        bgColor = "blue"
    }

    edata.write("settings.json", textutils.serializeJSON(Settings), 1, "sys")
end

sleep(math.random(1, 20)/10)
work = false
desktop.start()

local function mainLoop()
    while work == true do

        sleep(0.05)
    end
end

parallel.waitForAny(mainLoop)