local g = getgenv()
if g._AutoLoader then return end
g._AutoLoader = true

local MAIN = "https://raw.githubusercontent.com/ywxoofc/specifier/refs/heads/main/WZ1.lua"
local AUTO = "https://raw.githubusercontent.com/ywxoofc/specifier/refs/heads/main/WZ2.lua"

local function safeLoad(url)
    local ok, src = pcall(game.HttpGet, game, url)
    if ok then pcall(loadstring(src)) end
end

local function onTeleport()
    local q = (syn and syn.queue_on_teleport) or queue_on_teleport or queueonteleport
    if type(q) == "function" then
        q(('pcall(function() loadstring(game:HttpGet("%s"))() end)'):format(AUTO))
    end
end

task.spawn(onTeleport)
safeLoad(MAIN)
