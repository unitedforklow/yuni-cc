local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

local localPlayer = Players.LocalPlayer
local tickCounter = 0

local connections = {}

local function resetCharacterPhysics()
    local character = localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
    end
end

connections.Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        if connections.Input then connections.Input:Disconnect() end
        return
    end

    local settings = shared.YuniSettings.Misc
    if settings and settings.FakeLagKey and input.KeyCode == settings.FakeLagKey then
        settings.FakeLagEnabled = not settings.FakeLagEnabled
    end
end)

connections.Heartbeat = RunService.Heartbeat:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        for name, connection in pairs(connections) do
            if connection then connection:Disconnect() end
        end
        resetCharacterPhysics()
        return
    end

    local settings = shared.YuniSettings.Misc
    local character = localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if settings.FakeLagEnabled and hrp then
        local limit = settings.FakeLagLimit or 15
        if tickCounter < limit then
            hrp.Anchored = true
            tickCounter = tickCounter + 1
        else
            hrp.Anchored = false
            tickCounter = 0
        end
    else
        if hrp and hrp.Anchored then
            hrp.Anchored = false
        end
        tickCounter = 0
    end
end)

print("[yuni.cc] Module FakeLag is loaded.")
