local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

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

print("[yuni.cc] Module TriggerBot is loaded.")
