function setGlobal(key, data)
    _G[key] = data
end

edata = dofile("sys/lib/edata.lua")
setGlobal("edata", edata)

-- Main vars
_W, _H = term.getSize(); setGlobal("_W", _W); setGlobal("_H", _H)
_V, _VT = 7, "2.1"; setGlobal("_V", _V); setGlobal("_VT", _VT)
setGlobal("currentProfile", "")

-- For keyboard
allowedLetters = {
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
setGlobal("allowedLetters", allowedLetters)

replaceUpperLetters = {
    leftBracket = "{", rightBracked = "}", semiColon = ":", apostrophe = "\"",
    comma = "<", period = ">", slash = "?", backslash = "|", one = "!",
    two = "@", three = "#", four = "$", five = "%", six = "^", seven = "&",
    eight = "*", nine = "(", zero = ")", minus = "_", equals = "+"
}
setGlobal("replaceUpperLetters", replaceUpperLetters)

replaceLetters = {
    one = 1, two = 2, three = 3, four = 4, five = 5,
    six = 6, seven = 7, eight = 8, nine = 9, zero = 0,
    space = " ", period = ".", comma = ",", slash = "/",
    backslash = "\\", leftBracked = "[", rightBracked = "]",
    semiColon = ";", apostrophe = "'", minus = "-", equals = "="
}
setGlobal("replaceLetters", replaceLetters)

replaceColors = {
    [1] = 32768,
    [2] = 2048,
    [4] = 1,
    [8] = 32768,
    [16] = 32768,
    [32] = 32768,
    [64] = 32768,
    [128] = 1,
    [256] = 32768,
    [512] = 1,
    [1024] = 1,
    [2048] = 1,
    [4096] = 1,
    [8192] = 32768,
    [16384] = 1,
    [32768] = 1
}
setGlobal("replaceColors", replaceColors)

-- Useful functions
function wot(text, x, y, clearLine, textColor, bgColor, halfX)
    local oldX, oldY = term.getCursorPos()
    local oldTextColor = term.getTextColor()
    local oldBgColor = term.getBackgroundColor()
    term.setCursorPos(x, y)
    if halfX == true then
        term.setCursorPos(x - math.floor(string.len(text)/2), y)
    end
    term.setTextColor(textColor)
    term.setBackgroundColor(bgColor)
    if clearLine and clearLine == true then
        term.clearLine()
    end
    term.write(text)
    term.setCursorPos(oldX, oldY)
    term.setTextColor(oldTextColor)
    term.setBackgroundColor(oldBgColor)
end
setGlobal("wot", wot)
function split(str, sep)
    local result = {}
    if sep == nil or sep == "" then
        for word in string.gmatch(str, "%S+") do
            table.insert(result, word)
        end
    else
        local pattern = "([^" .. sep:gsub("%p", "%%%0") .. "]+)"
        for word in string.gmatch(str, pattern) do
            table.insert(result, word)
        end
    end
    return result
end
setGlobal("split", split)
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
setGlobal("wrapText", wrapText)

-- Load scenes
setGlobal("init", dofile("sys/init.lua"))
setGlobal("login", dofile("sys/login.lua"))
setGlobal("cprof", dofile("sys/cprof.lua"))
setGlobal("enpass", dofile("sys/enpass.lua"))
setGlobal("desktop", dofile("sys/desktop.lua"))

init.start()