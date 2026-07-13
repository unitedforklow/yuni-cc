shared.YuniSettings.Loaded = true

print("[yuni.cc] Main interface is loaded!")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Vector2_new = Vector2.new
local Color3_fromRGB = Color3.fromRGB
local math_floor = math.floor
local math_clamp = math.clamp
local math_tan = math.tan
local math_rad = math.rad
local table_insert = table.insert
local pcall = pcall

local espCache = {}

local function createEsp(player)
    local esp = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        TeamName = Drawing.new("Text"),
        HealthText = Drawing.new("Text"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        VisibleState = nil
    }

    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Color = Color3_fromRGB(0, 0, 0)
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Transparency = 0.6
    esp.BoxOutline.Visible = false

    esp.Box.Thickness = 1
    esp.Box.Color = Color3_fromRGB(0, 160, 255)
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Visible = false

    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3_fromRGB(240, 240, 240)
    esp.Name.Visible = false
    esp.Name.Font = 2 

    esp.Distance.Size = 11
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3_fromRGB(200, 200, 200)
    esp.Distance.Visible = false
    esp.Distance.Font = 2

    esp.TeamName.Size = 11
    esp.TeamName.Center = true
    esp.TeamName.Outline = true
    esp.TeamName.Color = Color3_fromRGB(150, 200, 255)
    esp.TeamName.Visible = false
    esp.TeamName.Font = 2

    esp.HealthText.Size = 11
    esp.HealthText.Center = true
    esp.HealthText.Outline = true
    esp.HealthText.Color = Color3_fromRGB(0, 255, 0)
    esp.HealthText.Visible = false
    esp.HealthText.Font = 2

    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Color = Color3_fromRGB(0, 0, 0)
    esp.HealthBarOutline.Filled = true
    esp.HealthBarOutline.Transparency = 0.5
    esp.HealthBarOutline.Visible = false

    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Visible = false

    esp.Tracer.Thickness = 1
    esp.Tracer.Color = Color3_fromRGB(0, 160, 255)
    esp.Tracer.Transparency = 0.8
    esp.Tracer.Visible = false

    espCache[player] = esp
    return esp
end

local function hideEsp(esp)
    if esp.VisibleState == false then return end
    
    esp.Box.Visible = false
    esp.BoxOutline.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    esp.TeamName.Visible = false
    esp.HealthText.Visible = false
    esp.HealthBar.Visible = false
    esp.HealthBarOutline.Visible = false
    esp.Tracer.Visible = false
    
    esp.VisibleState = false
end

local function removeEsp(player)
    if espCache[player] then
        for _, object in pairs(espCache[player]) do
            pcall(function() object:Destroy() end)
        end
        espCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeEsp)

local Connection
Connection = RunService.RenderStepped:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        local toClear = {}
        for player in pairs(espCache) do
            table_insert(toClear, player)
        end
        for _, player in ipairs(toClear) do
            removeEsp(player)
        end
        Connection:Disconnect()
        return
    end

    local settings = shared.YuniSettings.Visuals
    if not settings then return end
    
    local showBox = settings.Box
    local showName = settings.Name
    local showDistance = settings.Distance
    local showTeamName = settings.TeamName
    local showHealth = settings.Health
    local showHealthText = settings.HealthText
    local showTracers = settings.Tracers

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                local esp = espCache[player] or createEsp(player)
                
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local depth = hrpPos.Z
                    local scale = (Camera.ViewportSize.Y / (2 * depth * math_tan(math_rad(Camera.FieldOfView / 2))))
                    local boxHeight = scale * 5.0
                    local boxWidth = boxHeight * 0.6
                    
                    local boxX = hrpPos.X - (boxWidth / 2)
                    local boxY = hrpPos.Y - (boxHeight * 0.45)

                    esp.VisibleState = true

                    if showBox then
                        local sizeVec = Vector2_new(boxWidth, boxHeight)
                        local posVec = Vector2_new(boxX, boxY)
                        
                        esp.BoxOutline.Size = sizeVec
                        esp.BoxOutline.Position = posVec
                        esp.BoxOutline.Visible = true

                        esp.Box.Size = sizeVec
                        esp.Box.Position = posVec
                        esp.Box.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                    end

                    if showName then
                        esp.Name.Position = Vector2_new(hrpPos.X, boxY - 15)
                        if esp.Name.Text ~= player.Name then esp.Name.Text = player.Name end
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end

                    local distance = math_floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    if showDistance then
                        local yOffset = 2
                        if showTeamName then yOffset = 14 end
                        
                        esp.Distance.Position = Vector2_new(hrpPos.X, boxY + boxHeight + yOffset)
                        local distText = "[" .. tostring(distance) .. "m]"
                        if esp.Distance.Text ~= distText then esp.Distance.Text = distText end
                        esp.Distance.Visible = true
                    else
                        esp.Distance.Visible = false
                    end

                    if showTeamName then
                        local teamText = player.Team and player.Team.Name or "No Team"
                        local teamColor = player.TeamColor and player.TeamColor.Color or Color3_fromRGB(150, 200, 255)
                        
                        esp.TeamName.Position = Vector2_new(hrpPos.X, boxY + boxHeight + 2)
                        if esp.TeamName.Text ~= teamText then esp.TeamName.Text = teamText end
                        esp.TeamName.Color = teamColor
                        esp.TeamName.Visible = true
                    else
                        esp.TeamName.Visible = false
                    end

                    if showHealth then
                        local healthPct = math_clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = boxHeight * healthPct
                        
                        esp.HealthBarOutline.Position = Vector2_new(boxX - 6, boxY)
                        esp.HealthBarOutline.Size = Vector2_new(4, boxHeight)
                        esp.HealthBarOutline.Visible = true

                        esp.HealthBar.Position = Vector2_new(boxX - 5, boxY + (boxHeight - barHeight) + 1)
                        esp.HealthBar.Size = Vector2_new(2, math_clamp(barHeight - 2, 0, boxHeight))
                        esp.HealthBar.Color = Color3_fromRGB(255, 0, 0):Lerp(Color3_fromRGB(0, 255, 0), healthPct)
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthBar.Visible = false
                        esp.HealthBarOutline.Visible = false
                    end

                    if showHealthText then
                        local currentHealth = math_floor(humanoid.Health)
                        local healthPct = math_clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        
                        local lateralOffset = showHealth and -20 or -14
                        local targetY = boxY + (boxHeight * (1 - healthPct)) - 5
                        
                        esp.HealthText.Position = Vector2_new(boxX + lateralOffset, targetY)
                        
                        local textValue = tostring(currentHealth)
                        if esp.HealthText.Text ~= textValue then 
                            esp.HealthText.Text = textValue 
                        end
                        
                        esp.HealthText.Color = Color3_fromRGB(255, 0, 0):Lerp(Color3_fromRGB(0, 255, 0), healthPct)
                        esp.HealthText.Visible = true
                    else
                        esp.HealthText.Visible = false
                    end

                    if showTracers then
                        esp.Tracer.From = Vector2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2_new(hrpPos.X, boxY + boxHeight)
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end

                else
                    hideEsp(esp)
                end
            else
                if espCache[player] then
                    hideEsp(espCache[player])
                end
            end
        end
    end
end)

print("[yuni.cc] Module Visuals is loaded.")
