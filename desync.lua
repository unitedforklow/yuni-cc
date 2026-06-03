local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local timeout = 15
local elapsed = 0
while not (shared.YuniSettings and shared.YuniSettings.Loaded) do
    task.wait(0.5)
    elapsed = elapsed + 0.5
    if elapsed >= timeout then
        warn("[yuni.cc] Desync Error: Timeout waiting for settings!")
        return
    end
end

local connections = {}
local spinAngle = 0
local jitterToggle = false

local function resetJoints()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not torso then return end
        
        local neck = torso:FindFirstChild("Neck")
        local waist = torso:FindFirstChild("Waist")

        if neck and neck:IsA("Motor6D") then
            neck.Transform = CFrame.new()
        end
        if waist and waist:IsA("Motor6D") then
            waist.Transform = CFrame.new()
        end
    end)
end

local function cleanConnections()
    for name, connection in pairs(connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
            connections[name] = nil
        end
    end
    resetJoints()
end

connections.Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local settings = shared.YuniSettings.Misc
    if settings and settings.DesyncKey and input.KeyCode == settings.DesyncKey then
        settings.DesyncEnabled = not settings.DesyncEnabled
    end
end)

connections.PreRender = RunService.PreRender:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local settings = shared.YuniSettings.Misc
    if not settings or not settings.DesyncEnabled then
        resetJoints()
        return
    end

    local character = LocalPlayer.Character
    local torso = character and (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
    if not torso then return end

    local neck = torso:FindFirstChild("Neck")
    local waist = torso:FindFirstChild("Waist")

    local mode = settings.DesyncMode or "Predictive"
    local mult = tonumber(settings.DesyncMultiplier) or 15

    pcall(function()
        if mode == "Spin" then
            spinAngle = (spinAngle + mult) % 360
            local rotation = CFrame.Angles(0, math.rad(spinAngle), 0)
            
            if neck and neck:IsA("Motor6D") then
                neck.Transform = rotation
            end
            if waist and waist:IsA("Motor6D") then
                waist.Transform = rotation
            end

        elseif mode == "Jitter" then
            jitterToggle = not jitterToggle
            local pitch = jitterToggle and 85 or -85
            local yaw = jitterToggle and 45 or -45
            
            if neck and neck:IsA("Motor6D") then
                neck.Transform = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
            end
            if waist and waist:IsA("Motor6D") then
                waist.Transform = CFrame.Angles(0, math.rad(yaw), 0)
            end
            
        else
            if neck and neck:IsA("Motor6D") then
                neck.Transform = CFrame.new()
            end
            if waist and waist:IsA("Motor6D") then
                waist.Transform = CFrame.new()
            end
        end
    end)
end)

connections.Heartbeat = RunService.Heartbeat:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local settings = shared.YuniSettings.Misc
    if not settings or not settings.DesyncEnabled then return end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    local mode = settings.DesyncMode or "Predictive"
    local mult = tonumber(settings.DesyncMultiplier) or 15

    pcall(function()
        if mode == "Predictive" then
            local currentVelocity = hrp.AssemblyLinearVelocity
            if math.random(1, 2) == 1 then
                hrp.AssemblyLinearVelocity = Vector3.new(currentVelocity.X * -mult, currentVelocity.Y, currentVelocity.Z * -mult)
            else
                local randomX = math.random(-50, 50) * mult
                local randomZ = math.random(-50, 50) * mult
                hrp.AssemblyLinearVelocity = Vector3.new(randomX, currentVelocity.Y, randomZ)
            end
        end
    end)
end)

print("[yuni.cc] Module Desync is loaded.")
