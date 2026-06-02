local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. Безопасное ожидание загрузки настроек с таймаутом (чтобы избежать вечного зависания потока)
local timeout = 15 -- секунд
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

-- Функция безопасного сброса физики персонажа
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

-- Функция безопасного отключения всех подключений (Event Disconnection)
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

-- 2. Безопасный обработчик Keybind ввода
connections.Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Проверка активности чита на глобальном уровне
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local success, err = pcall(function()
        local settings = shared.YuniSettings.Misc
        if settings and settings.FakeLagKey then
            if input.KeyCode == settings.FakeLagKey then
                settings.FakeLagEnabled = not settings.FakeLagEnabled
            end
        end
    end)
    
    if not success then
        warn("[yuni.cc] FakeLag Input Error: " .. tostring(err))
    end
end)

-- 3. Безопасный цикл FakeLag на событии Heartbeat
connections.Heartbeat = RunService.Heartbeat:Connect(function()
    -- Проверка на деактивацию (Unload чита)
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        resetCharacterPhysics()
        return
    end

    -- Защищаем исполнение тика фейклага
    local success, err = pcall(function()
        local settings = shared.YuniSettings.Misc
        if not settings then return end

        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        -- Проверяем, включен ли фейклаг и доступен ли HumanoidRootPart как физическое тело
        if settings.FakeLagEnabled and hrp and hrp:IsA("BasePart") then
            -- Безопасное приведение лимита к числу на случай сбоя слайдера
            local limit = tonumber(settings.FakeLagLimit) or 15
            
            if tickCounter < limit then
                hrp.Anchored = true
                tickCounter = tickCounter + 1
            else
                hrp.Anchored = false
                tickCounter = 0
            end
        else
            -- Если функция выключена или HRP временно отсутствует (например, при смерти персонажа)
            if hrp and hrp:IsA("BasePart") and hrp.Anchored then
                hrp.Anchored = false
            end
            tickCounter = 0
        end
    end)

    -- Если во время цикла произошла непредвиденная ошибка (например, персонаж удален)
    if not success then
        warn("[yuni.cc] FakeLag Runtime Error: " .. tostring(err))
        -- В случае сбоя пробуем мягко восстановить физику, чтобы не сломать игру пользователю
        pcall(resetCharacterPhysics)
    end
end)

print("[yuni.cc] Backend FakeLag module successfully loaded with Error Handling.")
