repeat wait() until game:IsLoaded()
wait(1)
print("✅ Script đã chạy lại sau khi chuyển server")

-- 🍎 Danh sách trái không cần nhặt
local danhSachLoaiTru = {
    ["Banana"] = true, ["Apple"] = true, ["Strawberry"] = true,
    ["Pineapple"] = true, ["Mushroom"] = true, ["Lemon"] = true,
    ["Watermelon"] = true, ["Kilo Fruit"] = true
}

-- 🔍 Tìm trái ác quỷ
local function timTrai()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not danhSachLoaiTru[obj.Name] then
            return obj
        end
    end
    return nil
end

-- 🛸 Bay đến trái
local TweenService = game:GetService("TweenService")
local nguoiChoi = game.Players.LocalPlayer

local function bayDenTrai(trai)
    local hrp = nguoiChoi.Character and nguoiChoi.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local viTri = trai.Handle.Position + Vector3.new(0, 5, 0)
    local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - viTri).Magnitude / 500, Enum.EasingStyle.Linear), {CFrame = CFrame.new(viTri)})
    tween:Play()
end

-- 🧲 Tự động nhặt trái
local function nhatTrai(trai)
    local hrp = nguoiChoi.Character and nguoiChoi.Character:FindFirstChild("HumanoidRootPart")
    if hrp and trai and trai.Handle then
        firetouchinterest(hrp, trai.Handle, 0)
        firetouchinterest(hrp, trai.Handle, 1)
    end
end

-- 🔍 Hiện ESP trái
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

-- ⚓ Tự chọn phe Hải quân
local function chonHaiQuan()
    local gui = nguoiChoi:WaitForChild("PlayerGui"):FindFirstChild("ChooseTeam")
    if gui then
        for _, nut in pairs(gui:GetDescendants()) do
            if nut:IsA("TextButton") and string.find(nut.Text, "Marine") then
                nut:Click()
            end
        end
    end
end

-- 🔁 Lấy danh sách server bất kỳ
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function layDanhSachServer()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=50&sortOrder=Desc"
    local thanhCong, phanHoi = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    local danhSach = {}
    if thanhCong and phanHoi and phanHoi.data then
        for _, server in pairs(phanHoi.data) do
            if server.id ~= game.JobId then
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

-- 🚀 Spam chuyển server đến khi vào được
local function spamChuyenServer()
    local danhSach = layDanhSachServer()
    if #danhSach == 0 then
        warn("❌ Không có server nào để chuyển.")
        wait(3)
        spamChuyenServer()
        return
    end

    for _, serverId in pairs(danhSach) do
        print("🔁 Thử chuyển đến server:", serverId)
        local thanhCong = pcall(function()
            if queue_on_teleport then
                queue_on_teleport(scriptTaiLai)
            end
            TeleportService:TeleportToPlaceInstance(PlaceId, serverId)
        end)

        if thanhCong then
            return
        else
            warn("⚠️ Server đầy hoặc lỗi. Thử server tiếp theo...")
            wait(1)
        end
    end

    warn("🚫 Đã thử hết danh sách server nhưng không vào được. Thử lại sau...")
    wait(3)
    spamChuyenServer()
end

-- 🔄 Vòng lặp săn trái
local function batDauSanTrai()
    chonHaiQuan()
    local trai = timTrai()
    if trai then
        print("✅ Tìm thấy trái:", trai.Name)
        taoESP(trai)
        bayDenTrai(trai)
        wait(2)
        nhatTrai(trai)
    else
        print("🔁 Không có trái, chuyển server...")
        spamChuyenServer()
    end
end

batDauSanTrai()
