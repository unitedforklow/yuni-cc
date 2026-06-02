local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espCache = {}

local function createEsp(player)
    local esp = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        TeamName = Drawing.new("Text"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }

    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Transparency = 0.6
    esp.BoxOutline.Visible = false

    esp.Box.Thickness = 1
    esp.Box.Color = Color3.fromRGB(0, 160, 255)
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Visible = false

    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(240, 240, 240)
    esp.Name.Visible = false
    esp.Name.Font = 2 

    esp.Distance.Size = 11
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Visible = false
    esp.Distance.Font = 2

    esp.TeamName.Size = 11
    esp.TeamName.Center = true
    esp.TeamName.Outline = true
    esp.TeamName.Color = Color3.fromRGB(150, 200, 255)
    esp.TeamName.Visible = false
    esp.TeamName.Font = 2

    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBarOutline.Filled = true
    esp.HealthBarOutline.Transparency = 0.5
    esp.HealthBarOutline.Visible = false

    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Visible = false

    esp.Tracer.Thickness = 1
    esp.Tracer.Color = Color3.fromRGB(0, 160, 255)
    esp.Tracer.Transparency = 0.8
    esp.Tracer.Visible = false

    espCache[player] = esp
    return esp
end

local function hideEsp(esp)
    esp.Box.Visible = false
    esp.BoxOutline.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    esp.TeamName.Visible = false
    esp.HealthBar.Visible = false
    esp.HealthBarOutline.Visible = false
    esp.Tracer.Visible = false
end

local function removeEsp(player)
    if espCache[player] then
        for _, object in pairs(espCache[player]) do
            object:Destroy()
        end
        espCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeEsp)

local Connection
Connection = RunService.RenderStepped:Connect(function()
    if not shared.YuniSettings or not shared.YuniSettings.Active then
        for player in pairs(espCache) do
            removeEsp(player)
        end
        Connection:Disconnect()
        return
    end

    local settings = shared.YuniSettings.Visuals

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                local esp = espCache[player] or createEsp(player)

                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight / 2
                    local boxX = hrpPos.X - (boxWidth / 2)
                    local boxY = topPos.Y

                    if settings.Box then
                        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.BoxOutline.Visible = true

                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                    end

                    if settings.Name then
                        esp.Name.Position = Vector2.new(hrpPos.X, boxY - 15)
                        esp.Name.Text = player.Name
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end

                    local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    if settings.Distance then
                        local yOffset = 2
                        if settings.TeamName then yOffset = 14 end
                        
                        esp.Distance.Position = Vector2.new(hrpPos.X, boxY + boxHeight + yOffset)
                        esp.Distance.Text = "[" .. tostring(distance) .. "m]"
                        esp.Distance.Visible = true
                    else
                        esp.Distance.Visible = false
                    end

                    if settings.TeamName then
                        local teamText = player.Team and player.Team.Name or "No Team"
                        esp.TeamName.Position = Vector2.new(hrpPos.X, boxY + boxHeight + 2)
                        esp.TeamName.Text = teamText
                        esp.TeamName.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(150, 200, 255)
                        esp.TeamName.Visible = true
                    else
                        esp.TeamName.Visible = false
                    end

                    if settings.Health then
                        local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = boxHeight * healthPct
                        
                        esp.HealthBarOutline.Position = Vector2.new(boxX - 6, boxY)
                        esp.HealthBarOutline.Size = Vector2.new(4, boxHeight)
                        esp.HealthBarOutline.Visible = true

                        esp.HealthBar.Position = Vector2.new(boxX - 5, boxY + (boxHeight - barHeight) + 1)
                        esp.HealthBar.Size = Vector2.new(2, barHeight - 2)
                        esp.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPct)
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthBar.Visible = false
                        esp.HealthBarOutline.Visible = false
                    end

                    if settings.Tracers then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(hrpPos.X, boxY + boxHeight)
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
