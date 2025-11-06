local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SPEED = 3.5
local WATER_HEIGHT = 3.5

local isRightMouseDown = false
local isAimbotActive = false
local lockedTarget = nil
local connection = nil

-- 🖱 Theo dõi chuột phải
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
    elseif input.KeyCode == Enum.KeyCode.B then
        isAimbotActive = not isAimbotActive
        lockedTarget = nil
        print("Aimbot: " .. (isAimbotActive and "BẬT" or "TẮT"))
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
    end
end)

-- 🔍 Tìm người chơi gần nhất
local function getClosestPlayer()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < shortest then
                    closest = root
                    shortest = dist
                end
            end
        end
    end
    return closest
end

-- 🚀 Kích hoạt tính năng một lần
local function activateOnce()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    connection = RunService.RenderStepped:Connect(function()
        -- 🏃 Di chuyển bằng CFrame
        if hum.MoveDirection.Magnitude > 0 then
            local move = hum.MoveDirection.Unit * SPEED
            hrp.CFrame = hrp.CFrame + Vector3.new(move.X, 0, move.Z)
        end

        -- 🌊 Giữ nổi trên nước
        if hrp.Position.Y < 0 then
            hum.PlatformStand = false
            hrp.Velocity = Vector3.zero
            hrp.CFrame = CFrame.new(hrp.Position.X, WATER_HEIGHT, hrp.Position.Z)
        end

        -- 🎯 Aimbot nếu bật và không giữ chuột phải
        if isAimbotActive and not isRightMouseDown then
            if not lockedTarget or not lockedTarget.Parent or (lockedTarget.Parent:FindFirstChild("Humanoid") and lockedTarget.Parent.Humanoid.Health <= 0) then
                lockedTarget = getClosestPlayer()
            end
            if lockedTarget then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Position)
            end
        end
    end)

    -- 🔁 Ngắt toàn bộ khi chết
    hum.Died:Connect(function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        lockedTarget = nil
        print("Script đã ngắt sau khi chết.")
    end)
end

-- 🔥 Chạy một lần duy nhất
if LocalPlayer.Character then
    activateOnce()
end
