local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local mousemoverel = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel)

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 160, 255)
FovCircle.Filled = false
FovCircle.NumSides = 64
FovCircle.Transparency = 0.8
FovCircle.Visible = false

local lockOnActive = false

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local settings = shared.YuniSettings.LockOn

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (settings.IgnoreTeammates and player.Team == LocalPlayer.Team) then
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

                        if distanceToCenter < shortestDistance then
                            if not settings.FOV or distanceToCenter <= settings.FOVSize then
                                shortestDistance = distanceToCenter
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

local function aimAt(target)
    local settings = shared.YuniSettings.LockOn
    local character = target.Character
    local aimPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
    
    if not aimPart then return end

    local targetPos = aimPart.Position
    local velocity = aimPart.AssemblyLinearVelocity or aimPart.Velocity
    if velocity and settings.Prediction > 0 then
        targetPos = targetPos + (velocity * (settings.Prediction / 100))
    end

    if settings.Type == "Camera" then
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)

        local smoothAmount = math.clamp(1 / settings.Smoothness, 0.01, 1)
        Camera.CFrame = currentCF:Lerp(targetCF, smoothAmount)

    elseif settings.Type == "Mouse" then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local mouseLocation = UserInputService:GetMouseLocation()
            local diffX = (screenPos.X - mouseLocation.X) / settings.Smoothness
            local diffY = (screenPos.Y - mouseLocation.Y) / settings.Smoothness

            if mousemoverel then
                mousemoverel(diffX, diffY)
            else
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
                local smoothAmount = math.clamp(1 / settings.Smoothness, 0.01, 1)
                Camera.CFrame = currentCF:Lerp(targetCF, smoothAmount)
            end
        end
    end
end

local InputBeganConn
InputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not shared.YuniSettings or not shared.YuniSettings.Active then return end
    
    local settings = shared.YuniSettings.LockOn
    if input.KeyCode == settings.Key then
        if settings.Mode == "Toggle" then
            lockOnActive = not lockOnActive
        elseif settings.Mode == "Hold" then
            lockOnActive = true
        end
    end
end)

local InputEndedConn
InputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
    if not shared.YuniSettings or not shared.YuniSettings.Active then return end
    
    local settings = shared.YuniSettings.LockOn
    if input.KeyCode == settings.Key then
        if settings.Mode == "Hold" then
            lockOnActive = false
        end
    end
end)

local MainLoopConn
MainLoopConn = RunService.RenderStepped:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        FovCircle:Destroy()
        InputBeganConn:Disconnect()
        InputEndedConn:Disconnect()
        MainLoopConn:Disconnect()
        return
    end

    local settings = shared.YuniSettings.LockOn

    if settings.Enabled and settings.FOV then
        local mouseLocation = UserInputService:GetMouseLocation()
        FovCircle.Position = mouseLocation
        FovCircle.Radius = settings.FOVSize
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end

    if settings.Enabled and lockOnActive then
        local target = getClosestPlayer()
        if target then
            aimAt(target)
        end
    end
end)

print("[yuni.cc] Module Lock-on is loaded.")
