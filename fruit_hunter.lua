repeat wait() until game:IsLoaded()
wait(1)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = 2753915549 -- Blox Fruits

-- 🍎 Trái không cần nhặt
local LoaiTru = {
    ["Banana"] = true, ["Apple"] = true, ["Strawberry"] = true,
    ["Pineapple"] = true, ["Mushroom"] = true, ["Lemon"] = true,
    ["Watermelon"] = true, ["Kilo Fruit"] = true
}

-- 🔍 Tìm trái
local function timTrai()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not LoaiTru[obj.Name] then
            return obj
        end
    end
    return nil
end

-- 🛸 Bay đến trái
local function bayDen(trai)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and trai and trai:FindFirstChild("Handle") then
        local pos = trai.Handle.Position + Vector3.new(0, 5, 0)
        local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - pos).Magnitude / 500, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tween:Play()
    end
end

-- 🧲 Nhặt trái
local function nhat(trai)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and trai and trai:FindFirstChild("Handle") then
        firetouchinterest(hrp, trai.Handle, 0)
        firetouchinterest(hrp, trai.Handle, 1)
    end
end

-- 👁️ ESP trái
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Danh sách màu theo độ hiếm
local fruitColors = {
    ["Dragon Fruit"] = Color3.fromRGB(255, 0, 0), -- Legendary
    ["Leopard Fruit"] = Color3.fromRGB(255, 85, 0), -- Legendary
    ["Dough Fruit"] = Color3.fromRGB(255, 170, 0), -- Mythical
    ["Light Fruit"] = Color3.fromRGB(255, 255, 0), -- Rare
    ["Flame Fruit"] = Color3.fromRGB(255, 100, 0), -- Common
    ["Bomb Fruit"] = Color3.fromRGB(200, 200, 200), -- Common
}

-- Hàm tạo ESP
local function createESP(obj)
    if not obj:IsA("Tool") or not obj:FindFirstChild("Handle") then return end
    if obj.Handle:FindFirstChild("ESP") then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP"
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.Adornee = obj.Handle
    gui.Parent = obj.Handle

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🍒 " .. obj.Name
    label.TextColor3 = fruitColors[obj.Name] or Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.Parent = gui

    -- Cập nhật khoảng cách theo thời gian thực
    RunService.RenderStepped:Connect(function()
        if obj and obj.Parent and obj:FindFirstChild("Handle") then
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (obj.Handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
            label.Text = string.format("🍒 %s\n📏 %.0f m", obj.Name, distance)
        else
            gui:Destroy()
        end
    end)
end

-- Quét trái hiện có
for _, v in pairs(workspace:GetChildren()) do
    if v:IsA("Tool") and v:FindFirstChild("Handle") then
        createESP(v)
    end
end

-- Theo dõi trái mới xuất hiện
workspace.ChildAdded:Connect(function(v)
    if v:IsA("Tool") and v:FindFirstChild("Handle") then
        wait(0.2) -- đợi trái load xong
        createESP(v)
    end
end)

-- ⚓ Chọn Hải quân
local function chonHaiQuan()
    local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ChooseTeam")
    if gui then
        for _, nut in pairs(gui:GetDescendants()) do
            if nut:IsA("TextButton") and string.find(nut.Text, "Marine") then
                nut:Click()
            end
        end
    end
end

-- 🔁 Lấy server khác còn chỗ
local function layServerConCho()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=50&sortOrder=Desc"
    local thanhCong, phanHoi = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    local danhSach = {}
    if thanhCong and phanHoi and phanHoi.data then
        for _, server in pairs(phanHoi.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(danhSach, server.id)
            end
        end
    end
    return danhSach
end

-- 🔁 Script chạy lại sau khi chuyển server
local scriptTaiLai = [[
repeat wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/DUY7102010/scrip-san-trai/main/fruit_hunter.lua"))()
]]

-- 🚀 Chuyển server
local function hopServer()
    local danhSach = layServerConCho()
    if #danhSach == 0 then
        warn("❌ Không có server còn chỗ. Đợi 10s rồi thử lại...")
        wait(10)
        hopServer()
        return
    end

    local serverId = danhSach[math.random(1, #danhSach)]
    print("🔁 Đang chuyển đến server:", serverId)
    local thanhCong = pcall(function()
        if queue_on_teleport then
            queue_on_teleport(scriptTaiLai)
        end
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId)
    end)

    if not thanhCong then
        warn("⚠️ Lỗi khi chuyển server. Thử lại...")
        wait(5)
        hopServer()
    end
end

-- 🔄 Vòng lặp chính
local function batDau()
    chonHaiQuan()
    local trai = timTrai()
    if trai then
        print("✅ Tìm thấy trái:", trai.Name)
        taoESP(trai)
        bayDen(trai)
        wait(2)
        nhat(trai)
    else
        print("🔁 Không có trái. Đang chuyển server...")
        hopServer()
    end
end

batDau()
