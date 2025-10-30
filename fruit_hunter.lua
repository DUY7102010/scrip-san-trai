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
local function taoESP(trai)
    if trai and trai:FindFirstChild("Handle") and not trai.Handle:FindFirstChild("ESP") then
        local esp = Instance.new("BillboardGui", trai.Handle)
        esp.Name = "ESP"
        esp.Size = UDim2.new(0, 100, 0, 40)
        esp.AlwaysOnTop = true
        esp.StudsOffset = Vector3.new(0, 2, 0)
        local text = Instance.new("TextLabel", esp)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "🍒 " .. trai.Name
        text.TextColor3 = Color3.new(1, 0, 0)
        text.TextScaled = true
    end
end

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
