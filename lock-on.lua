local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService") -- Добавлено для учета GUI Inset
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local mousemoverel = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel)

if shared.YuniSettings and shared.YuniSettings.LockOn then
    shared.YuniSettings.LockOn.Sticky = shared.YuniSettings.LockOn.Sticky or false
    shared.YuniSettings.LockOn.WallCheck = shared.YuniSettings.LockOn.WallCheck or false
    shared.YuniSettings.LockOn.WallHack = shared.YuniSettings.LockOn.WallHack or false
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
local isLmbPressed = false
local modifiedParts = {}

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
            -- 1. Определяем, скрыт/заблокирован ли курсор в центре (1-е лицо, Shift-Lock, зажатая ПКМ)
            local isMouseLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter 
                               or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition
                               or not UserInputService.CursorIconEnabled

            local originPos
            if isMouseLocked then
                -- Если мышь заблокирована игрой, за центр отсчета всегда берем середину вьюпорта
                originPos = Camera.ViewportSize / 2
            else
                -- Если мышь свободна, вычитаем смещение GuiInset, чтобы сопоставить координаты
                local guiInset = GuiService:GetGuiInset()
                originPos = UserInputService:GetMouseLocation() - guiInset
            end
            
            -- 2. Вычисляем точную разницу в пикселях
            local diffX = (screenPos.X - originPos.X)
            local diffY = (screenPos.Y - originPos.Y)
            
            -- 3. Делим на плавность (чем выше Smoothness, тем медленнее доводка)
            local smooth = math.max(settings.Smoothness, 1)
            local stepX = diffX / smooth
            local stepY = diffY / smooth

            -- 4. Ограничиваем максимальный шаг за один кадр.
            -- Это защищает прицел от «взлета» или резкого разворота при высокой сенсе мыши.
            local maxMove = 35
            stepX = math.clamp(stepX, -maxMove, maxMove)
            stepY = math.clamp(stepY, -maxMove, maxMove)

            if mousemoverel then
                mousemoverel(stepX, stepY)
            else
                -- Мягкий фоллбек на CFrame-наводку, если эксплоит не поддерживает mousemoverel
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
                local smoothAmount = math.clamp(1 / smooth, 0.01, 1)
                Camera.CFrame = currentCF:Lerp(targetCF, smoothAmount)
            end
        end
    end
end

local function restoreWalls()
    for part, originalParent in pairs(modifiedParts) do
        if part then
            part.Parent = originalParent
        end
    end
    table.clear(modifiedParts)
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
        restoreWalls()
    end
end)

local PreRenderConn
PreRenderConn = RunService.PreRender:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        FovCircle:Destroy()
        restoreWalls()
        InputBeganConn:Disconnect()
        InputEndedConn:Disconnect()
        PreRenderConn:Disconnect()
        return
    end

    local settings = shared.YuniSettings.LockOn

    if settings.WallHack and isLmbPressed then
        local localCharacter = LocalPlayer.Character
        if localCharacter then
            local origin = Camera.CFrame.Position
            local direction = nil
            
            if lockOnActive and currentTarget and currentTarget.Character then
                local targetHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    direction = (targetHrp.Position - origin)
                end
            end

            if not direction then
                local mouseLocation = UserInputService:GetMouseLocation()
                local mouseRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
                direction = mouseRay.Direction * 1000
            end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude

            local filter = {localCharacter, Camera}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    table.insert(filter, p.Character)
                end
            end

            for i = 1, 6 do
                raycastParams.FilterDescendantsInstances = filter
                local result = workspace:Raycast(origin, direction, raycastParams)
                
                if result and result.Instance then
                    local hitPart = result.Instance
                    
                    local isFloor = hitPart.Name:lower():find("floor") or hitPart.Name:lower():find("baseplate") or hitPart.Name:lower():find("ground") or hitPart:IsA("Terrain")
                    
                    if hitPart:IsA("BasePart") and not isFloor then
                        if not modifiedParts[hitPart] then
                            modifiedParts[hitPart] = hitPart.Parent
                            hitPart.Parent = nil
                        end
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
        AddToggle("Wall Hack (Delete Walls on LMB)", shared.YuniSettings.LockOn, "WallHack", "WallHackFrame")
    end
end)

print("[yuni.cc] Module Lock-on is loaded with Mouse fixes.")
