local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local timeout = 15 -- seconds
local elapsed = 0
while not (shared.YuniSettings and shared.YuniSettings.Loaded) do
    task.wait(0.5)
    elapsed = elapsed + 0.5
    if elapsed >= timeout then
        warn("[yuni.cc] FakeLag Error: Timeout waiting for YuniSettings.Loaded! Module aborted.")
        return
    end
end

local localPlayer = Players.LocalPlayer
local tickCounter = 0
local connections = {}

local function resetCharacterPhysics()
    local success, err = pcall(function()
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then
                hrp.Anchored = false
            end
        end
    end)
    if not success then
        warn("[yuni.cc] FakeLag Safety: Failed to reset physics - " .. tostring(err))
    end
end

local function cleanConnections()
    for name, connection in pairs(connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
            connections[name] = nil
        end
    end
end

connections.Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local success, err = pcall(function()
        local settings = shared.YuniSettings.Misc
        if settings and settings.FakeLagKey then
            local rawKey = settings.FakeLagKey
            local targetKeyCode = nil
            
            if typeof(rawKey) == "string" then
                pcall(function()
                    targetKeyCode = Enum.KeyCode[rawKey]
                end)
            elseif typeof(rawKey) == "EnumItem" then
                targetKeyCode = rawKey
            end

            if targetKeyCode and input.KeyCode == targetKeyCode then
                settings.FakeLagEnabled = not settings.FakeLagEnabled
            end
        end
    end)
    
    if not success then
        warn("[yuni.cc] FakeLag Input Error: " .. tostring(err))
    end
end)

connections.Heartbeat = RunService.Heartbeat:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        resetCharacterPhysics()
        return
    end

    local success, err = pcall(function()
        local settings = shared.YuniSettings.Misc
        if not settings then return end

        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if settings.FakeLagEnabled and hrp and hrp:IsA("BasePart") then
            local limit = tonumber(settings.FakeLagLimit) or 15
            
            if tickCounter < limit then
                hrp.Anchored = true
                tickCounter = tickCounter + 1
            else
                hrp.Anchored = false
                tickCounter = 0
            end
        else
            if hrp and hrp:IsA("BasePart") and hrp.Anchored then
                hrp.Anchored = false
            end
            tickCounter = 0
        end
    end)

    if not success then
        warn("[yuni.cc] FakeLag Runtime Error: " .. tostring(err))
        pcall(resetCharacterPhysics)
    end
end)

print("[yuni.cc] Backend FakeLag module successfully loaded with Error Handling.")
