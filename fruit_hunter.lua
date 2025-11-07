-- INTRO GUI: LVDGODZ
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local IntroGui = Instance.new("ScreenGui", PlayerGui)
IntroGui.Name = "IntroLVD"
IntroGui.IgnoreGuiInset = true
IntroGui.ResetOnSpawn = false

local Background = Instance.new("Frame", IntroGui)
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(5, 5, 10)

local Gradient = Instance.new("UIGradient", Background)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
}
Gradient.Rotation = 45

local Glow = Instance.new("ImageLabel", Background)
Glow.Size = UDim2.new(1.5, 0, 1.5, 0)
Glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://9150630156"
Glow.ImageColor3 = Color3.fromRGB(90, 130, 255)
Glow.ImageTransparency = 0.85
Glow.ZIndex = 0

local Text = Instance.new("TextLabel", Background)
Text.AnchorPoint = Vector2.new(0.5, 0.5)
Text.Position = UDim2.new(0.5, 0, 0.5, 0)
Text.Size = UDim2.new(1, 0, 0.25, 0)
Text.Text = "LVDGODZ"
Text.TextColor3 = Color3.fromRGB(230, 235, 255)
Text.TextTransparency = 1
Text.TextScaled = true
Text.Font = Enum.Font.GothamBold
Text.ZIndex = 3
Text.BackgroundTransparency = 1

local Stroke = Instance.new("UIStroke", Text)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(120, 150, 255)
Stroke.Transparency = 0.3
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Shine = Instance.new("ImageLabel", Background)
Shine.AnchorPoint = Vector2.new(0.5, 0.5)
Shine.Position = UDim2.new(0.5, 0, 0.5, 0)
Shine.Size = UDim2.new(2, 0, 3, 0)
Shine.BackgroundTransparency = 1
Shine.Image = "rbxassetid://9150641010"
Shine.ImageColor3 = Color3.fromRGB(100, 130, 255)
Shine.ImageTransparency = 0.9
Shine.ZIndex = 2

TweenService:Create(Blur, TweenInfo.new(2), {Size = 25}):Play()
TweenService:Create(Text, TweenInfo.new(2), {TextTransparency = 0}):Play()
TweenService:Create(Stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5}):Play()
TweenService:Create(Shine, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.7}):Play()
TweenService:Create(Glow, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.75}):Play()

task.delay(4, function()
    TweenService:Create(Text, TweenInfo.new(2), {TextTransparency = 1}):Play()
    TweenService:Create(Background, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Blur, TweenInfo.new(2), {Size = 0}):Play()
    task.delay(2.2, function()
        IntroGui:Destroy()
        Blur:Destroy()
    end)
end)

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
