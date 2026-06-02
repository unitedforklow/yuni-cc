local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local setfpscap = setfpscap or (syn and syn.setfpscap)

repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

local AfkConnection = LocalPlayer.Idled:Connect(function()
    if shared.YuniSettings and shared.YuniSettings.Misc and shared.YuniSettings.Misc.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if shared.YuniSettings and shared.YuniSettings.Misc and shared.YuniSettings.Misc.InfJump then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

task.spawn(function()
    local lastFpsCap = nil
    while shared.YuniSettings and shared.YuniSettings.Active do
        if setfpscap and shared.YuniSettings.Misc then
            local currentCap = shared.YuniSettings.Misc.FPSCap
            if currentCap ~= lastFpsCap then
                setfpscap(currentCap)
                lastFpsCap = currentCap
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if not shared.YuniSettings or not shared.YuniSettings.Active then
            if AfkConnection then AfkConnection:Disconnect() end
            if JumpConnection then JumpConnection:Disconnect() end
            break
        end
        task.wait(1)
    end
end)

print("[yuni.cc] Module Misc is loaded.")
