term.clear()

function wot(text, x, y)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

wot("Welcome to XsyndaOS installer/updater!", 1, 1)
wot("Waiting...", 1, 3)

sleep(2)

wot("Installing...", 1, 3)

local edata = loadstring(http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/edata.lua").readAll())()

edata.write("startup.lua", "shell.run(\"sys/boot.lua\")")
sleep(0.1)
fs.makeDir("sys")
sleep(0.1)
fs.makeDir("sys/lib")
sleep(0.1)
edata.write("core.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/core.lua").readAll(), 1, "sys")
sleep(0.1)
edata.write("init.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/init.lua").readAll(), 1, "sys")
sleep(0.1)
edata.write("login.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/login.lua").readAll(), 1, "sys")
sleep(0.1)
edata.write("cprof.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/cprof.lua").readAll(), 1, "sys")
sleep(0.1)
edata.write("enpass.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/enpass.lua").readAll(), 1, "sys")
sleep(0.1)
edata.write("edata.lua", http.get("https://raw.githubusercontent.com/Entaru-Studio/XsyndaOS/refs/heads/main/sys/lib/edata.lua").readAll(), 1, "sys")
sleep(0.1)
fs.delete("install.lua")

wot("System is installed! Rebooting...", 1, 3)
sleep(3)
os.reboot()
