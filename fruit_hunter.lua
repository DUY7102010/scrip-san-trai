repeat wait() until game:IsLoaded()
wait(1)

-- 🍎 Hiển thị trái ác quỷ (ESP)
local camera = workspace.CurrentCamera
local danhSachLoaiTru = {
    ["Banana"] = true, ["Apple"] = true, ["Strawberry"] = true,
    ["Pineapple"] = true, ["Mushroom"] = true, ["Lemon"] = true,
    ["Watermelon"] = true, ["Kilo Fruit"] = true
}

local function taoESP(trai)
    if trai:FindFirstChild("Handle") and not trai.Handle:FindFirstChild("FruitESP") then
        local esp = Instance.new("BillboardGui", trai.Handle)
        esp.Name = "FruitESP"
        esp.Size = UDim2.new(0, 150, 0, 30)
        esp.StudsOffset = Vector3.new(0, 2, 0)
        esp.AlwaysOnTop = true

        local label = Instance.new("TextLabel", esp)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSansBold
        label.Text = trai.Name
    end
end

local function quetTrai()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not danhSachLoaiTru[obj.Name] then
            taoESP(obj)
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not danhSachLoaiTru[obj.Name] then
        taoESP(obj)
    end
end)

-- 🛸 Bay đến trái
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

local function timTrai()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not danhSachLoaiTru[obj.Name] then
            return obj
        end
    end
    return nil
end

-- 🔁 Tự chuyển server nếu không có trái
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function layServerMoi()
    local danhSach = {}
    local cursor = ""
    local thanhCong, phanHoi

    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        thanhCong, phanHoi = pcall(function()
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
            warn("⚠️ Không thể lấy danh sách server.")
            return nil
        end
    until cursor == "" or #danhSach > 0

    if #danhSach > 0 then
        return danhSach[math.random(1, #danhSach)]
    else
        return nil
    end
end

-- 🔁 Tự chạy lại sau khi chuyển server (nếu executor hỗ trợ)
local scriptTaiLai = [[
repeat wait() until game:IsLoaded()
loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_ID"))()
]]

-- 🧠 Hàm chính
local function batDau()
    quetTrai()
    local trai = timTrai()
    if trai then
        print("✅ Tìm thấy trái:", trai.Name)
        bayDenTrai(trai)
    else
        print("🔁 Không có trái, chuyển server...")
        local idMoi = layServerMoi()
        if idMoi then
            if queue_on_teleport then
                queue_on_teleport(scriptTaiLai)
            end
            TeleportService:TeleportToPlaceInstance(PlaceId, idMoi, nguoiChoi)
        else
            warn("⚠️ Không tìm được server phù hợp.")
        end
    end
end

batDau()
