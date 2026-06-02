local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

shared.YuniSettings.TriggerBot = shared.YuniSettings.TriggerBot or {
    Enabled = false,
    IgnoreTeammates = true,
    Delay = 0,
}

local function findGui()
    local paths = {
        gethui and gethui(),
        game:GetService("CoreGui"),
        LocalPlayer:FindFirstChildOfClass("PlayerGui")
    }
    for _, path in ipairs(paths) do
        if path then
            local gui = path:FindFirstChild("YuniCC_Gui")
            if gui then
                return gui
            end
        end
    end
    return nil
end

local function click()
    if mouse1press and mouse1release then
        mouse1press()
        task.wait(0.02)
        mouse1release()
    else
        local vim = game:GetService("VirtualInputManager")
        local mouseLocation = UserInputService:GetMouseLocation()
        vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, true, game, 1)
        task.wait(0.02)
        vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, false, game, 1)
    end
end

local function checkTarget()
    local settings = shared.YuniSettings.TriggerBot
    local mouseLocation = UserInputService:GetMouseLocation()
    
    local mouseRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    
    if result and result.Instance then
        local hitPart = result.Instance
        local character = hitPart:FindFirstAncestorOfClass("Model")
        local targetPlayer = character and Players:GetPlayerFromCharacter(character)
        
        if targetPlayer and targetPlayer ~= LocalPlayer then
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

local isShooting = false
local TriggerConn

TriggerConn = RunService.PostSimulation:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        TriggerConn:Disconnect()
        return
    end

    local settings = shared.YuniSettings.TriggerBot
    if settings.Enabled and not isShooting then
        if checkTarget() then
            isShooting = true
            task.spawn(function()
                if settings.Delay > 0 then
                    task.wait(settings.Delay / 1000)
                end
                
                if checkTarget() then
                    click()
                end
                
                task.wait(0.12)
                isShooting = false
            end)
        end
    end
end)

task.spawn(function()
    local ScreenGui = findGui()
    if not ScreenGui then
        warn("[yuni.cc TriggerBot] UI не найден в доступных путях.")
        return
    end

    local TabsFrame = ScreenGui:FindFirstChild("TabsFrame", true)
    local ContentFrame = ScreenGui:FindFirstChild("ContentFrame", true)

    if TabsFrame and ContentFrame then
        if TabsFrame:FindFirstChild("TriggerBotTab") then TabsFrame.TriggerBotTab:Destroy() end
        if ContentFrame:FindFirstChild("TriggerBotPage") then ContentFrame.TriggerBotPage:Destroy() end

        local TriggerBotPage = Instance.new("ScrollingFrame")
        TriggerBotPage.Name = "TriggerBotPage"
        TriggerBotPage.Size = UDim2.new(1, 0, 1, 0)
        TriggerBotPage.BackgroundTransparency = 1
        TriggerBotPage.ScrollBarThickness = 2
        TriggerBotPage.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 255)
        TriggerBotPage.Visible = false
        TriggerBotPage.Parent = ContentFrame

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = TriggerBotPage

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TriggerBotTab"
        TabButton.Size = UDim2.new(1, -10, 0, 32)
        TabButton.BackgroundTransparency = 1
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
        TabButton.BorderSizePixel = 0
        TabButton.Text = "  TRIGGERBOT"
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabsFrame

        TabButton.MouseButton1Click:Connect(function()
            for _, page in ipairs(ContentFrame:GetChildren()) do
                if page:IsA("ScrollingFrame") or page:IsA("Frame") then
                    page.Visible = false
                end
            end
            TriggerBotPage.Visible = true

            for _, btn in ipairs(TabsFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    btn.BackgroundTransparency = 1
                end
            end
            TabButton.TextColor3 = Color3.fromRGB(0, 160, 255)
            TabButton.BackgroundTransparency = 0.9
        end)

        for _, otherPage in ipairs(ContentFrame:GetChildren()) do
            if otherPage:IsA("ScrollingFrame") and otherPage.Name ~= "TriggerBotPage" then
                otherPage:GetPropertyChangedSignal("Visible"):Connect(function()
                    if otherPage.Visible then
                        TriggerBotPage.Visible = false
                        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
                        TabButton.BackgroundTransparency = 1
                    end
                end)
            end
        end

        local function AddToggle(text, configTable, configKey)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -10, 0, 30)
            Container.BackgroundTransparency = 1
            Container.Parent = TriggerBotPage

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

        local function AddSlider(text, min, max, default, configTable, configKey)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -10, 0, 45)
            Container.BackgroundTransparency = 1
            Container.Parent = TriggerBotPage

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default) .. " ms"
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextColor3 = Color3.fromRGB(0, 160, 255)
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Container

            local SliderBar = Instance.new("TextButton")
            SliderBar.Position = UDim2.new(0, 0, 0, 25)
            SliderBar.Size = UDim2.new(1, 0, 0, 6)
            SliderBar.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
            SliderBar.BorderSizePixel = 0
            SliderBar.Text = ""
            SliderBar.Parent = Container

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar

            local function UpdateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local rawValue = min + (percentage * (max - min))
                local roundedValue = math.floor(rawValue)
                
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = tostring(roundedValue) .. " ms"
                configTable[configKey] = roundedValue
            end

            local dragging = false
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
        end

        AddToggle("Enable TriggerBot", shared.YuniSettings.TriggerBot, "Enabled")
        AddToggle("Ignore Teammates", shared.YuniSettings.TriggerBot, "IgnoreTeammates")
        AddSlider("Reaction Delay (ms)", 0, 500, shared.YuniSettings.TriggerBot.Delay, shared.YuniSettings.TriggerBot, "Delay")
    else
        warn("[yuni.cc TriggerBot] Failed to find tab or page containers.")
    end
end)

print("[yuni.cc] Module TriggerBot is loaded.")
