
-- ⏳ Đợi game tải xong
repeat wait() until game:IsLoaded()
wait(1)

-- ✅ Kiểm tra script có chạy lại không
print("✅ Script đã chạy lại sau khi chuyển server")

-- 🍎 Danh sách trái không cần nhặt
local danhSachLoaiTru = {
    ["Banana"] = true, ["Apple"] = true, ["Strawberry"] = true,
    ["Pineapple"] = true, ["Mushroom"] = true, ["Lemon"] = true,
    ["Watermelon"] = true, ["Kilo Fruit"] = true
}

-- 🔍 Tìm trái ác quỷ trong workspace
local function timTrai()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not danhSachLoaiTru[obj.Name] then
            return obj
        end
    end
    return nil
end

-- 🛸 Bay đến vị trí trái
local TweenService = game:GetService("TweenService")
local nguoiChoi = game.Players.LocalPlayer

local function bayDenTrai(trai)
    local hrp = nguoiChoi.Character and nguoiChoi.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local viTri = trai.Handle.Position + Vector3.new(0, 5, 0)
    local khoangCach = (hrp.Position - viTri).Magnitude
    local tocDo = 500
    local thoiGian = khoangCach / tocDo

    local tween = TweenService:Create(hrp, TweenInfo.new(thoiGian, Enum.EasingStyle.Linear), {CFrame = CFrame.new(viTri)})
    tween:Play()
end

-- 🔁 Lấy server mới có slot trống
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function layServerMoi()
    local danhSach = {}
    local cursor = ""
    local soLanThu = 0

    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local thanhCong, phanHoi = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if thanhCong and phanHoi and phanHoi.data then
            for _, server in pairs(phanHoi.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(danhSach, server.id)
                end
            end
            cursor = phanHoi.nextPageCursor or ""
        else
            warn("⚠️ Không thể lấy danh sách server. Thử lại...")
            wait(2)
            soLanThu += 1
        end
    until cursor == "" or #danhSach > 0 or soLanThu >= 3

    print("🔍 Số server phù hợp tìm được:", #danhSach)
    if #danhSach > 0 then
        return danhSach[math.random(1, #danhSach)]
    else
        return nil
    end
end

-- 🔁 Script chạy lại sau khi chuyển server
local scriptTaiLai = [[
repeat wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/DUY7102010/scrip-san-trai/main/fruit_hunter.lua"))()
]]

-- 🧠 Bắt đầu săn trái
local trai = timTrai()
if trai then
    print("✅ Tìm thấy trái:", trai.Name)
    bayDenTrai(trai)
else
    print("🔁 Không có trái, chuyển server...")
    local serverId = layServerMoi()
    if serverId then
        if queue_on_teleport then
            queue_on_teleport(scriptTaiLai)
        end
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId)
    else
        warn("❌ Không tìm được server phù hợp.")
    end
end
