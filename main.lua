shared.YuniSettings = {
    Active = true,
    Visuals = {
        Box = false,
        Name = false,
        Distance = false,
        Health = false,
        HealthText = false,
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
        Sticky = false,
        WallCheck = false,
        WallHack = false,
    },
    TriggerBot = {
        Enabled = false,
        IgnoreTeammates = true,
        Delay = 250,
    },
    Misc = {
        AntiAFK = true,
        InfJump = false,
        FPSCap = 144,

        FakeLagEnabled = false,
        FakeLagLimit = 15,
        FakeLagKey = Enum.KeyCode.F,

        DesyncEnabled = false,
        DesyncMode = "Jitter", -- "Predictive", "Spin", "Jitter"
        DesyncMultiplier = 15,     -- Inverse force
        DesyncKey = Enum.KeyCode.H,
    }
}

-- CONFIGS LOADOUT

pcall(function()
    if isfile and isfile("yuni_config.json") and readfile then
        local HttpService = game:GetService("HttpService")
        local rawJson = readfile("yuni_config.json")
        local data = HttpService:JSONDecode(rawJson)
        
        local function restoreAndMerge(target, source)
            for k, v in pairs(source) do
                if type(v) == "table" and type(target[k]) == "table" then
                    if v.__enum and v.value then
                        pcall(function()
                            local enumType = v.__enum:gsub("Enum.", "")
                            target[k] = Enum[enumType][v.value]
                        end)
                    else
                        restoreAndMerge(target[k], v)
                    end
                else
                    if type(v) == "table" and v.__enum and v.value then
                        pcall(function()
                            local enumType = v.__enum:gsub("Enum.", "")
                            target[k] = Enum[enumType][v.value]
                        end)
                    else
                        target[k] = v
                    end
                end
            end
        end
        
        restoreAndMerge(shared.YuniSettings, data)
        print("[yuni.cc] Autoload: Config successfully applied on startup!")
    end
end)

local BaseGitHubUrl = "https://raw.githubusercontent.com/unitedforklow/yuni-cc/main/"

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
MainFrame.Size = UDim2.new(0, 600, 0, 480)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(30, 30, 30)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "yuni.cc"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 80, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local TitleShadow = Title:Clone()
TitleShadow.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleShadow.TextTransparency = 0.5
TitleShadow.Position = UDim2.new(0, 16, 0, 1)
TitleShadow.ZIndex = Title.ZIndex - 1
TitleShadow.Parent = Header

local Badge = Instance.new("Frame")
Badge.Size = UDim2.new(0, 55, 0, 20)
Badge.Position = UDim2.new(0, 100, 0.5, -10)
Badge.BackgroundColor3 = Color3.fromRGB(54, 100, 244)
Badge.BorderSizePixel = 0
Badge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 10)
BadgeCorner.Parent = Badge

local BadgeText = Instance.new("TextLabel")
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "1.0.4"
BadgeText.Font = Enum.Font.GothamBold
BadgeText.TextSize = 11
BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
BadgeText.Parent = Badge

local WindowControls = Instance.new("Frame")
WindowControls.Size = UDim2.new(0, 80, 1, 0)
WindowControls.Position = UDim2.new(1, -95, 0, 0)
WindowControls.BackgroundTransparency = 1
WindowControls.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
CloseBtn.Parent = WindowControls

CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 120) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() shared.YuniSettings.Active = false end)

local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Position = UDim2.new(0, 15, 0, 60)
TabsFrame.Size = UDim2.new(0, 150, 1, -80)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.Parent = TabsFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Position = UDim2.new(0, 180, 0, 60)
ContentFrame.Size = UDim2.new(1, -195, 1, -85)
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
    Page.ScrollBarImageColor3 = Color3.fromRGB(54, 100, 244)
    Page.Visible = false
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Parent = ContentFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
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
            TweenService:Create(button, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.9
            }):Play()
            button.UIStroke.Color = Color3.fromRGB(54, 100, 244)
        else
            TweenService:Create(button, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(150, 150, 150),
                BackgroundTransparency = 1
            }):Play()
            button.UIStroke.Color = Color3.fromRGB(30, 30, 30)
        end
    end
end

local function CreateTabButton(name, emoji)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundTransparency = 1
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BorderSizePixel = 0
    Button.Text = "   " .. emoji .. "  " .. name
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.TextColor3 = Color3.fromRGB(150, 150, 150)
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = TabsFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(30, 30, 30)
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BtnStroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)

    TabButtons[name] = Button
end

local VisualsPage = CreatePage("Visuals")
local LegitPage = CreatePage("Legit")
local MiscPage = CreatePage("Misc")
local ConfigsPage = CreatePage("Configs")
local SettingsPage = CreatePage("Settings")

CreateTabButton("Visuals", "👁")
CreateTabButton("Legit", "🎯")
CreateTabButton("Misc", "🧩")
CreateTabButton("Configs", "☁")
CreateTabButton("Settings", "⚙")

SelectTab("Visuals")

local function CreateToggle(parent, text, desc, configTable, configKey, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(30, 30, 30)
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.Font = Enum.Font.GothamMedium
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.7, 0, 0, 15)
    Description.Position = UDim2.new(0, 15, 0, 28)
    Description.BackgroundTransparency = 1
    Description.Text = desc
    Description.Font = Enum.Font.Gotham
    Description.TextColor3 = Color3.fromRGB(130, 130, 130)
    Description.TextSize = 11
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Position = UDim2.new(1, -53, 0.5, -10)
    Switch.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(54, 100, 244) or Color3.fromRGB(40, 40, 40)
    Switch.Text = ""
    Switch.Parent = Card

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = configTable[configKey] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    Switch.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        local active = configTable[configKey]
        
        TweenService:Create(Switch, TweenInfo.new(0.18), {
            BackgroundColor3 = active and Color3.fromRGB(54, 100, 244) or Color3.fromRGB(40, 40, 40)
        }):Play()
        TweenService:Create(Dot, TweenInfo.new(0.18), {
            Position = active and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()

        if callback then callback(active) end
    end)
end

local function CreateSlider(parent, text, desc, min, max, default, configTable, configKey, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 75)
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(30, 30, 30)
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.Font = Enum.Font.GothamMedium
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.7, 0, 0, 15)
    Description.Position = UDim2.new(0, 15, 0, 26)
    Description.BackgroundTransparency = 1
    Description.Text = desc
    Description.Font = Enum.Font.Gotham
    Description.TextColor3 = Color3.fromRGB(130, 130, 130)
    Description.TextSize = 11
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 45, 0, 20)
    ValueLabel.Position = UDim2.new(0, 15, 0, 47)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.Parent = Card

    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, -85, 0, 5)
    SliderTrack.Position = UDim2.new(0, 65, 0, 55)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Text = ""
    SliderTrack.Parent = Card

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(54, 100, 244)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 8, 0, 16)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.BorderSizePixel = 0
    Handle.Parent = SliderTrack

    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, 4)
    HandleCorner.Parent = Handle

    local function UpdateSlider(input)
        local percentage = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        local rawValue = min + (percentage * (max - min))
        local roundedValue = math.floor(rawValue * 10) / 10
        if roundedValue % 1 == 0 then roundedValue = math.floor(roundedValue) end
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        Handle.Position = UDim2.new(percentage, 0, 0.5, 0)
        ValueLabel.Text = tostring(roundedValue)
        configTable[configKey] = roundedValue
        if callback then callback(roundedValue) end
    end

    local dragging = false
    SliderTrack.InputBegan:Connect(function(input)
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

local function CreateDropdown(parent, text, desc, options, default, configTable, configKey, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(30, 30, 30)
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.Font = Enum.Font.GothamMedium
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.6, 0, 0, 15)
    Description.Position = UDim2.new(0, 15, 0, 28)
    Description.BackgroundTransparency = 1
    Description.Text = desc
    Description.Font = Enum.Font.Gotham
    Description.TextColor3 = Color3.fromRGB(130, 130, 130)
    Description.TextSize = 11
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    local DropBox = Instance.new("TextButton")
    DropBox.Size = UDim2.new(0, 110, 0, 24)
    DropBox.Position = UDim2.new(1, -125, 0.5, -12)
    DropBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropBox.BorderSizePixel = 0
    DropBox.Text = default .. "  ▼"
    DropBox.Font = Enum.Font.GothamMedium
    DropBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropBox.TextSize = 12
    DropBox.Parent = Card

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = DropBox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Thickness = 1
    BoxStroke.Color = Color3.fromRGB(45, 45, 45)
    BoxStroke.Parent = DropBox

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(1, 0, 0, #options * 26 + 10)
    ListFrame.Position = UDim2.new(0, 0, 1, 4)
    ListFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ZIndex = 100
    ListFrame.Parent = DropBox

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = ListFrame

    local ListStroke = Instance.new("UIStroke")
    ListStroke.Thickness = 1
    ListStroke.Color = Color3.fromRGB(45, 45, 45)
    ListStroke.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ListLayout.Parent = ListFrame

    for i, option in ipairs(options) do
        local OptButton = Instance.new("TextButton")
        OptButton.Size = UDim2.new(1, -10, 0, 24)
        OptButton.BackgroundTransparency = 1
        OptButton.Text = option
        OptButton.Font = Enum.Font.Gotham
        OptButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        OptButton.TextSize = 12
        OptButton.ZIndex = 101
        OptButton.Parent = ListFrame

        local OptCorner = Instance.new("UICorner")
        OptCorner.CornerRadius = UDim.new(0, 4)
        OptCorner.Parent = OptButton

        OptButton.MouseEnter:Connect(function()
            OptButton.BackgroundTransparency = 0.95
            OptButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        OptButton.MouseLeave:Connect(function()
            OptButton.BackgroundTransparency = 1
            OptButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        end)

        OptButton.MouseButton1Click:Connect(function()
            DropBox.Text = option .. "  ▼"
            configTable[configKey] = option
            ListFrame.Visible = false
            if callback then callback(option) end
        end)
    end

    DropBox.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)
end

local function CreateKeybind(parent, text, desc, default, configTable, configKey, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(30, 30, 30)
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.Font = Enum.Font.GothamMedium
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.6, 0, 0, 15)
    Description.Position = UDim2.new(0, 15, 0, 28)
    Description.BackgroundTransparency = 1
    Description.Text = desc
    Description.Font = Enum.Font.Gotham
    Description.TextColor3 = Color3.fromRGB(130, 130, 130)
    Description.TextSize = 11
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    local buttonText = "None"
    if default then
        if typeof(default) == "EnumItem" then
            buttonText = default.Name
        elseif typeof(default) == "string" then
            buttonText = default
        end
    end

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 90, 0, 24)
    Button.Position = UDim2.new(1, -105, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.BorderSizePixel = 0
    Button.Text = buttonText
    Button.Font = Enum.Font.GothamMedium
    Button.TextColor3 = Color3.fromRGB(54, 100, 244)
    Button.TextSize = 12
    Button.Parent = Card

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(45, 45, 45)
    BtnStroke.Parent = Button

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

local function CreateButtonCard(parent, text, desc, btnText, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -5, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(30, 30, 30)
    CardStroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 0, 20)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.Font = Enum.Font.GothamMedium
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.6, 0, 0, 15)
    Description.Position = UDim2.new(0, 15, 0, 28)
    Description.BackgroundTransparency = 1
    Description.Text = desc
    Description.Font = Enum.Font.Gotham
    Description.TextColor3 = Color3.fromRGB(130, 130, 130)
    Description.TextSize = 11
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 90, 0, 24)
    Button.Position = UDim2.new(1, -105, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.BorderSizePixel = 0
    Button.Text = btnText
    Button.Font = Enum.Font.GothamMedium
    Button.TextColor3 = Color3.fromRGB(240, 240, 240)
    Button.TextSize = 12
    Button.Parent = Card

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(45, 45, 45)
    BtnStroke.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

CreateToggle(VisualsPage, "2D Box", "Render physical boxes around targets", shared.YuniSettings.Visuals, "Box")
CreateToggle(VisualsPage, "Name ESP", "Display targets names over their models", shared.YuniSettings.Visuals, "Name")
CreateToggle(VisualsPage, "Distance", "Show distance in meters to target", shared.YuniSettings.Visuals, "Distance")
CreateToggle(VisualsPage, "Health Bar", "Show live vertical health bar status", shared.YuniSettings.Visuals, "Health")
CreateToggle(VisualsPage, "Health Text", "Display live health points as text", shared.YuniSettings.Visuals, "HealthText")
CreateToggle(VisualsPage, "Team Name", "Show target's team name underneath", shared.YuniSettings.Visuals, "TeamName")
CreateToggle(VisualsPage, "Tracers", "Draw paths from bottom center to targets", shared.YuniSettings.Visuals, "Tracers")

local LockHeader = Instance.new("TextLabel")
LockHeader.Size = UDim2.new(1, 0, 0, 25)
LockHeader.BackgroundTransparency = 1
LockHeader.Text = "  AIM BOT (LOCK-ON)"
LockHeader.Font = Enum.Font.GothamBold
LockHeader.TextColor3 = Color3.fromRGB(54, 100, 244)
LockHeader.TextSize = 11
LockHeader.TextXAlignment = Enum.TextXAlignment.Left
LockHeader.Parent = LegitPage

CreateToggle(LegitPage, "Enable Lock-on", "Smooth aim assist towards target head", shared.YuniSettings.LockOn, "Enabled")
CreateKeybind(LegitPage, "Lock-on Keybind", "Key to lock onto targets", shared.YuniSettings.LockOn.Key, shared.YuniSettings.LockOn, "Key")
CreateDropdown(LegitPage, "Lock-on Mode", "Aim assist toggle behavior", {"Hold", "Toggle"}, shared.YuniSettings.LockOn.Mode, shared.YuniSettings.LockOn, "Mode")
CreateDropdown(LegitPage, "Lock Type", "Input destination engine type", {"Camera", "Mouse"}, shared.YuniSettings.LockOn.Type, shared.YuniSettings.LockOn, "Type")
CreateSlider(LegitPage, "Smoothness", "Camera interpolation smoothing speed", 1, 20, shared.YuniSettings.LockOn.Smoothness, shared.YuniSettings.LockOn, "Smoothness")
CreateSlider(LegitPage, "Predictions", "Velocity vectors compensation offset", 0, 10, shared.YuniSettings.LockOn.Prediction, shared.YuniSettings.LockOn, "Prediction")
CreateToggle(LegitPage, "Ignore Teammates", "Do not target players in your team", shared.YuniSettings.LockOn, "IgnoreTeammates")
CreateToggle(LegitPage, "Show FOV Circle", "Draw dynamic limit capture radius", shared.YuniSettings.LockOn, "FOV")
CreateSlider(LegitPage, "FOV Size", "Define maximum radius to allow capture", 30, 500, shared.YuniSettings.LockOn.FOVSize, shared.YuniSettings.LockOn, "FOVSize")
CreateToggle(LegitPage, "Sticky Aim", "Lock onto first target and hold focus", shared.YuniSettings.LockOn, "Sticky")
CreateToggle(LegitPage, "Wall Check", "Prevent aiming at targets behind opaque objects", shared.YuniSettings.LockOn, "WallCheck")

local TrigHeader = Instance.new("TextLabel")
TrigHeader.Size = UDim2.new(1, 0, 0, 25)
TrigHeader.BackgroundTransparency = 1
TrigHeader.Text = "  AUTO FIRE (TRIGGERBOT)"
TrigHeader.Font = Enum.Font.GothamBold
TrigHeader.TextColor3 = Color3.fromRGB(54, 100, 244)
TrigHeader.TextSize = 11
TrigHeader.TextXAlignment = Enum.TextXAlignment.Left
TrigHeader.Parent = LegitPage

CreateToggle(LegitPage, "Enable TriggerBot", "Auto fire when crosshair hovers over target", shared.YuniSettings.TriggerBot, "Enabled")
CreateToggle(LegitPage, "TB Ignore Teammates", "Do not auto fire at teammates", shared.YuniSettings.TriggerBot, "IgnoreTeammates")
CreateSlider(LegitPage, "TB Reaction Delay (ms)", "Human reaction emulator delay", 0, 500, shared.YuniSettings.TriggerBot.Delay, shared.YuniSettings.TriggerBot, "Delay")

CreateToggle(MiscPage, "Anti-AFK Bypass", "Anti-idle 20 minutes kick preventer", shared.YuniSettings.Misc, "AntiAFK")
CreateToggle(MiscPage, "Infinite Jump", "Allows multi-jumping inside mid-air", shared.YuniSettings.Misc, "InfJump")
CreateSlider(MiscPage, "FPS Limit", "Unlock and restrict framerate cap", 30, 360, shared.YuniSettings.Misc.FPSCap, shared.YuniSettings.Misc, "FPSCap")

CreateToggle(MiscPage, "Fake Lag", "Desyncs physics replication to bypass ragdolls or disrupt targeting", shared.YuniSettings.Misc, "FakeLagEnabled")
CreateSlider(MiscPage, "Fake Lag Limit", "Replication freeze length (ticks)", 1, 30, shared.YuniSettings.Misc.FakeLagLimit, shared.YuniSettings.Misc, "FakeLagLimit")
CreateKeybind(MiscPage, "Fake Lag Keybind", "Toggle Fake Lag instantly", shared.YuniSettings.Misc.FakeLagKey, shared.YuniSettings.Misc, "FakeLagKey")

CreateToggle(MiscPage, "Desync (Anti-Aim)", "Disrupts predictive aimbots and head alignment", shared.YuniSettings.Misc, "DesyncEnabled")
CreateDropdown(MiscPage, "Desync Mode", "Type of desynchronization method", {"Predictive", "Spin", "Jitter"}, shared.YuniSettings.Misc.DesyncMode, shared.YuniSettings.Misc, "DesyncMode")
CreateSlider(MiscPage, "Desync Multiplier", "Velocity spoofing power / spin speed", 1, 100, shared.YuniSettings.Misc.DesyncMultiplier, shared.YuniSettings.Misc, "DesyncMultiplier")
CreateKeybind(MiscPage, "Desync Keybind", "Toggle Desync instantly", shared.YuniSettings.Misc.DesyncKey, shared.YuniSettings.Misc, "DesyncKey")

CreateButtonCard(ConfigsPage, "Save Settings", "Write configs to workspace folder", "Save", function()
    if shared.YuniActions and shared.YuniActions.SaveConfig then
        shared.YuniActions.SaveConfig()
    else
        warn("[yuni.cc] Save action is not registered yet.")
    end
end)

CreateButtonCard(ConfigsPage, "Load Settings", "Read configs from workspace folder", "Load", function()
    if shared.YuniActions and shared.YuniActions.LoadConfig then
        shared.YuniActions.LoadConfig()
    else
        warn("[yuni.cc] Load action is not registered yet.")
    end
end)

CreateButtonCard(SettingsPage, "Unload GUI", "Destroy screen gui and terminate loops", "Unload", function()
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
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
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
            warn("[yuni.cc] Error compiling module " .. moduleName .. ": " .. tostring(err))
        end
    else
        warn("[yuni.cc] Couldn't fetch the module " .. moduleName .. " from github.")
    end
end

task.spawn(function()
    SafeLoad("Visuals Module", BaseGitHubUrl .. "visuals.lua")
end)

task.spawn(function()
    SafeLoad("Lock-on Module", BaseGitHubUrl .. "lock-on.lua")
end)

task.spawn(function()
    SafeLoad("Misc Module", BaseGitHubUrl .. "misc.lua")
end)

task.spawn(function()
    SafeLoad("TriggerBot Module", BaseGitHubUrl .. "triggerbot.lua")
end)

task.spawn(function()
    SafeLoad("Fake Lag Module", BaseGitHubUrl .. "fakelag.lua")
end)

task.spawn(function()
    SafeLoad("Configs Module", BaseGitHubUrl .. "configs.lua")
end)

task.spawn(function()
    SafeLoad("Desync Module", BaseGitHubUrl .. "desync.lua")
end)

shared.YuniSettings.Loaded = true

print("[yuni.cc] Main interface is loaded!")
