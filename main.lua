shared.YuniSettings = {
    Active = true,
    Visuals = {
        Box = false,
        Name = false,
        Distance = false,
        Health = false,
        TeamName = false,
        Tracers = false,
    },
    LockOn = {
        Enabled = false,
        Key = Enum.KeyCode.E,
        Mode = "Hold", -- "Hold" or "Toggle"
        Type = "Camera", -- "Camera" or "Mouse"
        Smoothness = 5,
        Prediction = 1.5,
        IgnoreTeammates = true,
        FOV = false,
        FOVSize = 100,
    },
    Misc = {
        FPSCap = 60,
    }
}

local BaseGitHubUrl = "https://raw.githubusercontent.com/unitedforklow/sgjujsusujgusgsujg/main/"

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local TargetParent = gethui and gethui() or game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuniCC_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 13, 16)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 160, 255)
MainFrame.Parent = ScreenGui

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
TopAccent.BorderSizePixel = 0
TopAccent.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "yuni.cc"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 100, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local TitleShadow = Title:Clone()
TitleShadow.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleShadow.TextTransparency = 0.5
TitleShadow.Position = UDim2.new(0, 16, 0, 1)
TitleShadow.ZIndex = Title.ZIndex - 1
TitleShadow.Parent = Header

local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.Size = UDim2.new(0, 130, 1, -40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.Parent = TabsFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Position = UDim2.new(0, 140, 0, 50)
ContentFrame.Size = UDim2.new(1, -150, 1, -60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 255)
    Page.Visible = false
    Page.Parent = ContentFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    Pages[name] = Page
    return Page
end

local function SelectTab(tabName)
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    for name, button in pairs(TabButtons) do
        if name == tabName then
            button.TextColor3 = Color3.fromRGB(0, 160, 255)
            button.BackgroundTransparency = 0.9
        else
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
            button.BackgroundTransparency = 1
        end
    end
end

local function CreateTabButton(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 32)
    Button.BackgroundTransparency = 1
    Button.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    Button.BorderSizePixel = 0
    Button.Text = "  " .. name:upper()
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = TabsFrame

    Button.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)

    TabButtons[name] = Button
end

local VisualsPage = CreatePage("Visuals")
local LockOnPage = CreatePage("Lock-on")
local MiscPage = CreatePage("Misc")

CreateTabButton("Visuals")
CreateTabButton("Lock-on")
CreateTabButton("Misc")

SelectTab("Visuals")

local function CreateToggle(parent, text, configTable, configKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

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
        if callback then callback(configTable[configKey]) end
    end)
end

local function CreateSlider(parent, text, min, max, default, configTable, configKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

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
        local roundedValue = math.floor(rawValue * 10) / 10
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(roundedValue)
        configTable[configKey] = roundedValue
        if callback then callback(roundedValue) end
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

local function CreateCycleButton(parent, text, options, default, configTable, configKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 22)
    Button.Position = UDim2.new(1, -120, 0.5, -11)
    Button.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    Button.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Button.Font = Enum.Font.Gotham
    Button.Text = default
    Button.TextColor3 = Color3.fromRGB(0, 160, 255)
    Button.TextSize = 12
    Button.Parent = Container

    local currentIndex = table.find(options, default) or 1

    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        local newOption = options[currentIndex]
        Button.Text = newOption
        configTable[configKey] = newOption
        if callback then callback(newOption) end
    end)
end

local function CreateKeybind(parent, text, default, configTable, configKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 22)
    Button.Position = UDim2.new(1, -120, 0.5, -11)
    Button.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    Button.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Button.Font = Enum.Font.Gotham
    Button.Text = default.Name
    Button.TextColor3 = Color3.fromRGB(0, 160, 255)
    Button.TextSize = 12
    Button.Parent = Container

    local listening = false

    Button.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        Button.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Button.Text = input.KeyCode.Name
                configTable[configKey] = input.KeyCode
                if callback then callback(input.KeyCode) end
                connection:Disconnect()
                listening = false
            end
        end)
    end)
end

CreateToggle(VisualsPage, "2D Box", shared.YuniSettings.Visuals, "Box")
CreateToggle(VisualsPage, "Name ESP", shared.YuniSettings.Visuals, "Name")
CreateToggle(VisualsPage, "Distance", shared.YuniSettings.Visuals, "Distance")
CreateToggle(VisualsPage, "Health Bar", shared.YuniSettings.Visuals, "Health")
CreateToggle(VisualsPage, "Team Name", shared.YuniSettings.Visuals, "TeamName")
CreateToggle(VisualsPage, "Tracers", shared.YuniSettings.Visuals, "Tracers")

CreateToggle(LockOnPage, "Enable Lock-on", shared.YuniSettings.LockOn, "Enabled")
CreateKeybind(LockOnPage, "Keybind", shared.YuniSettings.LockOn.Key, shared.YuniSettings.LockOn, "Key")
CreateCycleButton(LockOnPage, "Mode", {"Hold", "Toggle"}, shared.YuniSettings.LockOn.Mode, shared.YuniSettings.LockOn, "Mode")
CreateCycleButton(LockOnPage, "Lock Type", {"Camera", "Mouse"}, shared.YuniSettings.LockOn.Type, shared.YuniSettings.LockOn, "Type")
CreateSlider(LockOnPage, "Smoothness", 1, 20, shared.YuniSettings.LockOn.Smoothness, shared.YuniSettings.LockOn, "Smoothness")
CreateSlider(LockOnPage, "Predictions", 0, 10, shared.YuniSettings.LockOn.Prediction, shared.YuniSettings.LockOn, "Prediction")
CreateToggle(LockOnPage, "Ignore Teammates", shared.YuniSettings.LockOn, "IgnoreTeammates")
CreateToggle(LockOnPage, "Show FOV Circle", shared.YuniSettings.LockOn, "FOV")
CreateSlider(LockOnPage, "FOV Size", 30, 500, shared.YuniSettings.LockOn.FOVSize, shared.YuniSettings.LockOn, "FOVSize")

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -10, 0, 35)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
CloseButton.BorderColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.Text = "UNLOAD INTERFACE"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(240, 100, 100)
CloseButton.TextSize = 13
CloseButton.Parent = MiscPage

CloseButton.MouseButton1Click:Connect(function()
    shared.YuniSettings.Active = false
    ScreenGui:Destroy()
end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local function SafeLoad(moduleName, url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and content then
        local loaded, err = loadstring(content)
        if loaded then
            task.spawn(loaded)
        else
            warn("[yuni.cc] Error compilating module " .. moduleName .. ": " .. tostring(err))
        end
    else
        warn("[yuni.cc] Couldn't fetch the module " .. moduleName .. " from github.")
    end
end

task.spawn(function()
    SafeLoad("Visuals Module", BaseGitHubUrl .. "visuals.lua")
    print("Visuals Module loaded in main.lua.")
end)

task.spawn(function()
    SafeLoad("Lock-on Module", BaseGitHubUrl .. "lock-on.lua")
    print("Lock-on Module loaded in main.lua.")
end)

task.spawn(function()
    SafeLoad("Misc Module", BaseGitHubUrl .. "misc.lua")
    print("Misc Module loaded in main.lua.")
end)

task.spawn(function()
    SafeLoad("TriggerBot Module", BaseGitHubUrl .. "triggerbot.lua")
    print("TriggerBot Module loaded in main.lua.")
end)

print("[yuni.cc] Main interface is loaded!")
