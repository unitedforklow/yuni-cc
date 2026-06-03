local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local timeout = 15
local elapsed = 0
while not (shared.YuniSettings and shared.YuniSettings.Loaded) do
    task.wait(0.5)
    elapsed = elapsed + 0.5
    if elapsed >= timeout then
        warn("[yuni.cc] Silent Aim Error: Timeout waiting for settings!")
        return
    end
end

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = true
FovCircle.Transparency = 0.15
FovCircle.NumSides = 64
FovCircle.Visible = false

local VisualizerOuter = Drawing.new("Circle")
VisualizerOuter.Thickness = 1
VisualizerOuter.Color = Color3.fromRGB(255, 0, 100)
VisualizerOuter.Filled = false
VisualizerOuter.Radius = 13
VisualizerOuter.NumSides = 32
VisualizerOuter.Visible = false

local VisualizerInner = Drawing.new("Circle")
VisualizerInner.Thickness = 1.5
VisualizerInner.Color = Color3.fromRGB(255, 0, 100)
VisualizerInner.Filled = false
VisualizerInner.NumSides = 32
VisualizerInner.Visible = false

local isKeyHeld = false
local currentTarget = nil
local connections = {}

-- Функция очистки
local function cleanConnections()
    for name, connection in pairs(connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    pcall(function()
        FovCircle:Destroy()
        VisualizerOuter:Destroy()
        VisualizerInner:Destroy()
    end)
end

connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not shared.YuniSettings or not shared.YuniSettings.Active then return end
    local settings = shared.YuniSettings.Silent
    if settings and input.KeyCode == settings.Key then
        isKeyHeld = true
    end
end)

connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end
    local settings = shared.YuniSettings.Silent
    if settings and input.KeyCode == settings.Key then
        isKeyHeld = false
    end
end)

local function getPredictedPosition(player)
    local settings = shared.YuniSettings.Silent
    local character = player.Character
    if not character then return nil end

    local targetBoneName = settings.TargetBone or "Head"
    local bone = character:FindFirstChild(targetBoneName) or character:FindFirstChild("HumanoidRootPart")
    if not bone or not bone:IsA("BasePart") then return nil end

    local position = bone.Position

    if settings.Prediction then
        local velocity = bone.AssemblyLinearVelocity or bone.Velocity
        if velocity then

            local mult = settings.PredictionAmount or 1.5
            position = position + (velocity * (mult / 100))
        end
    end

    return position
end

local function getClosestTarget()
    local settings = shared.YuniSettings.Silent
    local lockOnSettings = shared.YuniSettings.LockOn
    
    local active = settings.Enabled and (settings.AlwaysOn or isKeyHeld)
    if not active then return nil end

    local closestPlayer = nil
    local shortestDistance = settings.FOVSize or 100
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local teamCheck = lockOnSettings and lockOnSettings.IgnoreTeammates
            if not (teamCheck and player.Team == LocalPlayer.Team) then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local targetPos = getPredictedPosition(player)
                    if targetPos then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

connections.PreRender = RunService.PreRender:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        cleanConnections()
        return
    end

    local settings = shared.YuniSettings.Silent
    local mousePos = UserInputService:GetMouseLocation()

    if settings.Enabled and settings.ShowFOV then
        local pulse = (settings.FOVSize or 100) + math.sin(tick() * 2.5) * 3.0
        FovCircle.Position = mousePos
        FovCircle.Radius = pulse
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end

    currentTarget = getClosestTarget()

    if currentTarget and settings.ShowVisualizer then
        local targetPos = getPredictedPosition(currentTarget)
        if targetPos then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local screenVec2 = Vector2.new(screenPos.X, screenPos.Y)
                
                VisualizerOuter.Position = screenVec2
                VisualizerOuter.Visible = true

                local pulseRadius = 7.0 + math.sin(tick() * 10) * 2.5
                VisualizerInner.Position = screenVec2
                VisualizerInner.Radius = pulseRadius
                VisualizerInner.Visible = true
            else
                VisualizerOuter.Visible = false
                VisualizerInner.Visible = false
            end
        end
    else
        VisualizerOuter.Visible = false
        VisualizerInner.Visible = false
    end
end)

local HookNamecall
HookNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and shared.YuniSettings and shared.YuniSettings.Active then
        local settings = shared.YuniSettings.Silent
        if settings and settings.Enabled and (settings.AlwaysOn or isKeyHeld) then
            if currentTarget then
                local targetPos = getPredictedPosition(currentTarget)
                if targetPos then
                    if self == Camera and (method == "ScreenPointToRay" or method == "ViewportPointToRay") then
                        local origin = Camera.CFrame.Position
                        local direction = (targetPos - origin).Unit
                        return Ray.new(origin, direction)
                    end

                    if self == workspace and method == "Raycast" then
                        local origin = args[1]
                        args[2] = (targetPos - origin).Unit * 1000
                        return HookNamecall(self, unpack(args))
                    end
                end
            end
        end
    end

    return HookNamecall(self, ...)
end))

print("[yuni.cc] Module Silent Aim is loaded.")
