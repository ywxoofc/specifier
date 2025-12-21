print("Script gestartet – warte auf vollständiges Laden...")
game.Loaded:Wait()
task.wait(3)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

player.CharacterAdded:Wait()
local character = player.Character or player.CharacterAdded:Wait()

local health = character:WaitForChild("HealthProperties"):WaitForChild("Health")

local remote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Teleport")
    :WaitForChild("StartRaid")

local rewardsGui = player:WaitForChild("PlayerGui")
    :WaitForChild("MissionRewards")
    :WaitForChild("MissionRewards")

print("Spiel vollständig geladen")

local ids = {1005, 1006, 1007}

local wasDead = false
local wasVisible = false
local healthCheckCounter = 0

while true do
    if health.Value <= 0 then
        healthCheckCounter += 1
        if healthCheckCounter % 10 == 0 then
            print("[DEBUG] Health <= 0 | Check #" .. healthCheckCounter)
        end
        if not wasDead then
            wasDead = true
            remote:FireServer(ids[math.random(#ids)], 5)
        end
    else
        wasDead = false
        healthCheckCounter = 0
    end

    if rewardsGui.Visible and not wasVisible then
        wasVisible = true
        remote:FireServer(ids[math.random(#ids)], 5)
    elseif not rewardsGui.Visible then
        wasVisible = false
    end

    task.wait(0.1)
end
