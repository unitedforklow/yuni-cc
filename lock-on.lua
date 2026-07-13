local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local mousemoverel = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel)

assert(hookmetamethod, "[yuni.cc] Executor does not support hookmetamethod!")
assert(checkcaller, "[yuni.cc] Executor does not support checkcaller!")

if shared.YuniSettings and shared.YuniSettings.LockOn then
    shared.YuniSettings.LockOn.Sticky = shared.YuniSettings.LockOn.Sticky or false
    shared.YuniSettings.LockOn.WallCheck = shared.YuniSettings.LockOn.WallCheck or false
end

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(0, 160, 255)
FovCircle.Filled = false
FovCircle.NumSides = 64
FovCircle.Transparency = 0.8
FovCircle.Visible = false

local lockOnActive = false
local currentTarget = nil

local function checkWall(targetPosition, targetCharacter)
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    
    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local filter = {localCharacter, targetCharacter, Camera}

    for i = 1, 5 do
        raycastParams.FilterDescendantsInstances = filter
        local result = workspace:Raycast(origin, direction, raycastParams)
        
        if result then
            local part = result.Instance
            local isTransparent = part.Transparency > 0.7
            local isNoCollide = part.CanCollide == false
            local isPassable = part.Name:lower():find("glass") or part.Name:lower():find("water") or part.Name:lower():find("trigger")
            
            if isTransparent or isNoCollide or isPassable then
                table.insert(filter, part)
            else
                return false
            end
        else
            return true
        end
    end
    return false
end

local function getClosestPlayer()
    local settings = shared.YuniSettings.LockOn
    local localCharacter = LocalPlayer.Character
    local localHrp = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHrp then 
        lockOnActive = false
        currentTarget = nil
        return nil 
    end

    if settings.Sticky and currentTarget then
        local character = currentTarget.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            local passesWall = true
            if settings.WallCheck then
                passesWall = checkWall(hrp.Position, character)
            end
            
            local passesFOV = true
            if settings.FOV and onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if distanceToCenter > settings.FOVSize then
                    passesFOV = false
                end
            elseif settings.FOV and not onScreen then
                passesFOV = false
            end
            
            if onScreen and passesWall and passesFOV then
                return currentTarget
            end
        end
        
        lockOnActive = false
        currentTarget = nil
        return nil
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

    if settings.Type == "Mouse" then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local isMouseLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter 
                               or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition
                               or not UserInputService.MouseIconEnabled

            local originPos
            if isMouseLocked then
                originPos = Camera.ViewportSize / 2
            else
                local guiInset = GuiService:GetGuiInset()
                originPos = UserInputService:GetMouseLocation() - guiInset
            end
            
            local diffX = (screenPos.X - originPos.X)
            local diffY = (screenPos.Y - originPos.Y)
            
            local smooth = math.max(settings.Smoothness, 1)
            local stepX = diffX / smooth
            local stepY = diffY / smooth

            local maxMove = 35
            stepX = math.clamp(stepX, -maxMove, maxMove)
            stepY = math.clamp(stepY, -maxMove, maxMove)

            if mousemoverel then
                mousemoverel(stepX, stepY)
            end
        end
    end
end

local lastTime = os.clock()
local function getSmoothLookCFrame(originalCFrame, targetPosition, smoothness)
    local origin = originalCFrame.Position
    local targetCFrame = CFrame.new(origin, targetPosition)
    
    local currentTime = os.clock()
    local dt = currentTime - lastTime
    lastTime = currentTime
    
    dt = math.clamp(dt, 0.001, 0.1)

    local lerpFactor = math.clamp((1 / smoothness) * (dt * 60), 0.01, 1)
    return originalCFrame:Lerp(targetCFrame, lerpFactor)
end

local HookNewIndex
HookNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, property, value)
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        return HookNewIndex(self, property, value)
    end
            
    if self == Camera and property == "CFrame" and not checkcaller() then
        local settings = shared.YuniSettings.LockOn
        if settings and settings.Enabled and lockOnActive and settings.Type == "Camera" then
            local target = getClosestPlayer()
            local character = target and target.Character
            local aimPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
            
            if aimPart then
                local targetPos = aimPart.Position
                
                local velocity = aimPart.AssemblyLinearVelocity or aimPart.Velocity
                if velocity and settings.Prediction > 0 then
                    targetPos = targetPos + (velocity * (settings.Prediction / 100))
                end
                
                local smoothVal = math.max(settings.Smoothness, 1)
                value = getSmoothLookCFrame(value, targetPos, smoothVal)
            end
        end
    end

    return HookNewIndex(self, property, value)
end))

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

    if currentTarget then
        local character = currentTarget.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            lockOnActive = false
            currentTarget = nil
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
            if settings.Type == "Mouse" then
                aimAt(target)
            elseif settings.Type == "Camera" then
                local character = target.Character
                local aimPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
                if aimPart then
                    local targetPos = aimPart.Position
                    local velocity = aimPart.AssemblyLinearVelocity or aimPart.Velocity
                    if velocity and settings.Prediction > 0 then
                        targetPos = targetPos + (velocity * (settings.Prediction / 100))
                    end
                    
                    local smoothVal = math.max(settings.Smoothness, 1)
                    Camera.CFrame = getSmoothLookCFrame(Camera.CFrame, targetPos, smoothVal)
                end
            end
        end
    end
end)

task.spawn(function()
    local TargetParent = gethui and gethui() or game:GetService("CoreGui")
    local ScreenGui = TargetParent:WaitForChild("YuniCC_Gui", 12)
    local LockOnPage = ScreenGui and ScreenGui:FindFirstChild("Lock-onPage", true)

    if LockOnPage then
        for _, child in ipairs(LockOnPage:GetChildren()) do
            if child:IsA("Frame") and (child.Name == "StickyFrame" or child.Name == "WallCheckFrame" or child.Name == "WallHackFrame") then
                child:Destroy()
            end
        end

        local function AddToggle(text, configTable, configKey, frameName)
            local Container = Instance.new("Frame")
            Container.Name = frameName
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

        AddToggle("Sticky Aim", shared.YuniSettings.LockOn, "Sticky", "StickyFrame")
        AddToggle("Wall Check", shared.YuniSettings.LockOn, "WallCheck", "WallCheckFrame")
    end
end)

print("[yuni.cc] Module Lock-on is loaded.")
