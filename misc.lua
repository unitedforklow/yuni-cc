local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local setfpscap = setfpscap or (syn and syn.setfpscap)

shared.YuniSettings.Misc.AntiAFK = true
shared.YuniSettings.Misc.InfJump = false
shared.YuniSettings.Misc.FPSCap = 120

local AfkConnection = LocalPlayer.Idled:Connect(function()
    if shared.YuniSettings and shared.YuniSettings.Misc.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if shared.YuniSettings and shared.YuniSettings.Misc.InfJump then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

task.spawn(function()
    while shared.YuniSettings and shared.YuniSettings.Active do
        if setfpscap then
            setfpscap(shared.YuniSettings.Misc.FPSCap)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if not shared.YuniSettings or not shared.YuniSettings.Active then
            AfkConnection:Disconnect()
            JumpConnection:Disconnect()
            break
        end
        task.wait(1)
    end
end)

local TargetParent = gethui and gethui() or game:GetService("CoreGui")
local ScreenGui = TargetParent:WaitForChild("YuniCC_Gui", 10)
local MiscPage = ScreenGui and ScreenGui:FindFirstChild("MiscPage", true)

if MiscPage then
    local UnloadButton = MiscPage:FindFirstChildOfClass("TextButton")
    if UnloadButton then
        UnloadButton.LayoutOrder = 999
    end

    local function AddToggle(text, configTable, configKey)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -10, 0, 30)
        Container.BackgroundTransparency = 1
        Container.LayoutOrder = 1
        Container.Parent = MiscPage

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
        Container.LayoutOrder = 2
        Container.Parent = MiscPage

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
        ValueLabel.Text = tostring(default)
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
            ValueLabel.Text = tostring(roundedValue)
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

    AddToggle("Anti-AFK Bypass", shared.YuniSettings.Misc, "AntiAFK")
    AddToggle("Infinite Jump", shared.YuniSettings.Misc, "InfJump")
    AddSlider("FPS Limit", 30, 360, shared.YuniSettings.Misc.FPSCap, shared.YuniSettings.Misc, "FPSCap")
end

print("[yuni.cc] Module Misc is loaded.")
