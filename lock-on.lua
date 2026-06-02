local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

shared.YuniSettings.LockOn.Sticky = false
shared.YuniSettings.LockOn.WallCheck = false
shared.YuniSettings.LockOn.WallHack = false

local mousemoverel = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel)

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 160, 255)
FovCircle.Filled = false
FovCircle.NumSides = 64
FovCircle.Transparency = 0.8
FovCircle.Visible = false

local lockOnActive = false
local currentTarget = nil
local isLmbPressed = false
local modifiedParts = {}

local function checkWall(targetPosition, targetCharacter)
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    
    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    raycastParams.FilterDescendantsInstances = {localCharacter, targetCharacter, Camera}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)

    return result == nil
end

local function getClosestPlayer()
    local settings = shared.YuniSettings.LockOn
    local localCharacter = LocalPlayer.Character
    local localHrp = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHrp then return nil end

    if settings.Sticky and currentTarget then
        local character = currentTarget.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local passesWall = true
                if settings.WallCheck then
                    passesWall = checkWall(hrp.Position, character)
                end
                
                if passesWall then
                    if settings.FOV then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distanceToCenter <= settings.FOVSize then
                            return currentTarget
                        end
                    else
                        return currentTarget
                    end
                end
            end
        end
        currentTarget = nil
    end

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (settings.IgnoreTeammates and player.Team == LocalPlayer.Team) then
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    local passesWall = true
                    if settings.WallCheck then
                        passesWall = checkWall(hrp.Position, character)
                    end

                    if passesWall then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if not settings.FOV or distanceToCenter <= settings.FOVSize then
                                local distanceToPlayer = (hrp.Position - localHrp.Position).Magnitude
                                if distanceToPlayer < shortestDistance then
                                    shortestDistance = distanceToPlayer
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    currentTarget = closestPlayer
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
            if not lockOnActive then currentTarget = nil end
        elseif settings.Mode == "Hold" then
            lockOnActive = true
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLmbPressed = true
    end
end)

local InputEndedConn
InputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
    if not shared.YuniSettings or not shared.YuniSettings.Active then return end
    
    local settings = shared.YuniSettings.LockOn
    if input.KeyCode == settings.Key then
        if settings.Mode == "Hold" then
            lockOnActive = false
            currentTarget = nil
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLmbPressed = false
        for part, originalState in pairs(modifiedParts) do
            if part and part.Parent then
                part.CanCollide = originalState
            end
        end
        table.clear(modifiedParts)
    end
end)

local PreRenderConn
PreRenderConn = RunService.PreRender:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        FovCircle:Destroy()
        InputBeganConn:Disconnect()
        InputEndedConn:Disconnect()
        PreRenderConn:Disconnect()
        return
    end

    local settings = shared.YuniSettings.LockOn
    if settings.WallHack and isLmbPressed then
        local localCharacter = LocalPlayer.Character
        if localCharacter then
            local mouseLocation = UserInputService:GetMouseLocation()
            local mouseRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
            
            local origin = mouseRay.Origin
            local direction = mouseRay.Direction * 1000
                
            if lockOnActive and currentTarget then
                local targetChar = currentTarget.Character
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    origin = Camera.CFrame.Position
                    direction = (targetHrp.Position - origin).Unit * 1000
                end
            end

            local filter = {localCharacter, Camera}
            if currentTarget and currentTarget.Character then
                table.insert(filter, currentTarget.Character)
            end

            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.IgnoreWater = true
                
            for i = 1, 5 do
                raycastParams.FilterDescendantsInstances = filter
                local result = workspace:Raycast(origin, direction, raycastParams)

                if result and result.Instance then
                    local hitPart = result.Instance
                    local isFloor = hitPart.Name:lower():find("floor") or hitPart.Name:lower():find("baseplate") or hitPart.Name:lower():find("ground")
                    local isCharacterPart = hitPart:FindFirstAncestorOfClass("Model") and hitPart:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")

                    if hitPart:IsA("BasePart") and not isFloor and not isCharacterPart and hitPart.CanCollide == true then
                        if modifiedParts[hitPart] == nil then
                            modifiedParts[hitPart] = hitPart.CanCollide
                        end
                        hitPart.CanCollide = false
                    end
                    table.insert(filter, hitPart)
                else
                    break
                end
            end
        end
    end

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

task.spawn(function()
    local TargetParent = gethui and gethui() or game:GetService("CoreGui")
    local ScreenGui = TargetParent:WaitForChild("YuniCC_Gui", 12)
    local LockOnPage = ScreenGui and ScreenGui:FindFirstChild("Lock-onPage", true)

    if LockOnPage then
        local function AddToggle(text, configTable, configKey)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -10, 0, 30)
            Container.BackgroundTransparency = 1
            Container.Parent = LockOnPage

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container

            local Box = Instance.new("TextButton")
            Box.Position = UDim2.new(1, -30, 0.5, -10)
            Box.Size = UDim2.new(0, 20, 0, 20)
            Box.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
            Box.BorderColor3 = Color3.fromRGB(60, 60, 60)
            Box.Text = ""
            Box.Parent = Container

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(1, -6, 1, -6)
            Indicator.Position = UDim2.new(0, 3, 0, 3)
            Indicator.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
            Indicator.BorderSizePixel = 0
            Indicator.Visible = configTable[configKey]
            Indicator.Parent = Box

            Box.MouseButton1Click:Connect(function()
                configTable[configKey] = not configTable[configKey]
                Indicator.Visible = configTable[configKey]
            end)
        end
            
        AddToggle("Sticky Aim", shared.YuniSettings.LockOn, "Sticky")
        AddToggle("Wall Check", shared.YuniSettings.LockOn, "WallCheck")
        AddToggle("Wall Hack (No-Collide on LMB)", shared.YuniSettings.LockOn, "WallHack")
    end
end)

print("[yuni.cc] Модуль Lock-on успешно обновлен.")
