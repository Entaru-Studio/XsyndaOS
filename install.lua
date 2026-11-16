term.clear()

function wot(text, x, y)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

wot("Welcome to XsyndaOS installer!", 1, 1)
wot("Downloading files...", 1, 3)

local edata = loadstring(http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/edata.lua").readAll())()

edata.write("startup.lua", "shell.run(\"sys/boot.lua\")")
fs.makeDir("sys")

edata.write("boot.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/boot.lua").readAll(), 1, "sys")
edata.write("desktop.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/desktop.lua").readAll(), 1, "sys")
edata.write("edata.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/edata.lua").readAll(), 1, "sys")

fs.delete("install.lua")

wot("System is installed! Rebooting...", 1, 5)
sleep(3)
os.reboot()