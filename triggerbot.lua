local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Ожидание инициализации основного меню во избежание ошибок считывания
repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

-- Эмуляция нажатия левой кнопки мыши (ЛКМ) для выстрела
local function click()
    if mouse1press and mouse1release then
        mouse1press()
        task.wait(0.02)
        mouse1release()
    else
        -- Резервный метод клика для исполнителей без mouse1press
        local vim = game:GetService("VirtualInputManager")
        local mouseLocation = UserInputService:GetMouseLocation()
        vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, true, game, 1)
        task.wait(0.02)
        vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, false, game, 1)
    end
end

-- Проверка наличия вражеского персонажа непосредственно под перекрестием прицела
local function checkTarget()
    local settings = shared.YuniSettings.TriggerBot
    local mouseLocation = UserInputService:GetMouseLocation()
    
    -- Проекция луча из точки курсора
    local mouseRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    -- Наш персонаж и камера исключаются из трассировки луча
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    
    if result and result.Instance then
        local hitPart = result.Instance
        local character = hitPart:FindFirstAncestorOfClass("Model")
        local targetPlayer = character and Players:GetPlayerFromCharacter(character)
        
        -- Если луч пересекается с моделью другого живого игрока
        if targetPlayer and targetPlayer ~= LocalPlayer then
            -- Проверка на игнорирование союзников по команде
            if settings.IgnoreTeammates and targetPlayer.Team == LocalPlayer.Team then
                return false
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

-- Постоянный цикл мониторинга цели (выполняется в PostSimulation)
local isShooting = false
local TriggerConn

TriggerConn = RunService.PostSimulation:Connect(function()
    -- Полное отключение потока при деактивации GUI
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        TriggerConn:Disconnect()
        return
    end

    local settings = shared.YuniSettings.TriggerBot
    if settings.Enabled and not isShooting then
        if checkTarget() then
            isShooting = true
            task.spawn(function()
                -- Задержка перед выстрелом (имитация человеческого пинга/реакции)
                if settings.Delay > 0 then
                    task.wait(settings.Delay / 1000)
                end
                
                -- Повторная проверка: осталась ли цель под прицелом по истечении задержки
                if checkTarget() then
                    click()
                end
                
                -- Небольшая пауза между выстрелами
                task.wait(0.12)
                isShooting = false
            end)
        end
    end
end)

print("[yuni.cc] Backend TriggerBot module successfully loaded.")
