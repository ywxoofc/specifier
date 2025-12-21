print("[AutoLoader] Start")

local g = getgenv()
if g._AutoLoader then
    print("[AutoLoader] Bereits ausgeführt – Abbruch")
    return
end
g._AutoLoader = true
print("[AutoLoader] Guard gesetzt")

local MAIN = "https://raw.githubusercontent.com/ywxoofc/specifier/refs/heads/main/WZ3.lua"
local AUTO = "https://raw.githubusercontent.com/ywxoofc/specifier/refs/heads/main/WZ5.lua"

local function safeLoad(url)
    print("[AutoLoader] Lade:", url)
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok then
        warn("[AutoLoader] HttpGet Fehler")
        return
    end
    local ok2, err = pcall(loadstring(src))
    if not ok2 then
        warn("[AutoLoader] loadstring Fehler:", err)
    else
        print("[AutoLoader] Script geladen")
    end
end

local function onTeleport()
    local q = (syn and syn.queue_on_teleport) or queue_on_teleport or queueonteleport
    if type(q) ~= "function" then
        warn("[AutoLoader] queue_on_teleport nicht verfügbar")
        return
    end

    print("[AutoLoader] Teleport-Queue gesetzt")
    q(('pcall(function() loadstring(game:HttpGet("%s"))() end)'):format(AUTO))
end

task.spawn(onTeleport)
safeLoad(MAIN)

print("[AutoLoader] Fertig")
