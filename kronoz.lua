-- =====================================================================
-- KRONOZ TEST - khusus diagnosa bug accessories/korblox/headless di Evade
-- Cuma ada: pasang 1 accessory test + info lengkap apa yang kedeteksi.
-- Nyalain, tunggu beberapa detik, pencet "SALIN INFO", paste ke chat.
-- =====================================================================
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local me = Players.LocalPlayer

-- id accessory publik (topi klasik "Fedora") buat bahan tes, bukan punya kamu sendiri
local TEST_ACC_ID = 21070112

local function mk(cls, props, par)
	local o = Instance.new(cls)
	for k, v in pairs(props) do o[k] = v end
	if par then o.Parent = par end
	return o
end

local gui = mk("ScreenGui", {Name = "KronozTest", ResetOnSpawn = false, DisplayOrder = 999, IgnoreGuiInset = true}, me:WaitForChild("PlayerGui"))
local kotak = mk("Frame", {AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 20, 0, 60), Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(15, 15, 18), BorderSizePixel = 0}, gui)
mk("UICorner", {CornerRadius = UDim.new(0, 12)}, kotak)
mk("UIStroke", {Color = Color3.fromRGB(60, 60, 66), Thickness = 1}, kotak)
mk("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, kotak)
mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, kotak)

mk("TextLabel", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "KRONOZ TEST INFO", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, kotak)

local info = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(22, 22, 26), Text = "menunggu...", TextColor3 = Color3.fromRGB(150, 255, 170), Font = Enum.Font.Code, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2}, kotak)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, info)
mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, info)

local baris = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 3}, kotak)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, baris)
local bSalin = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = Color3.fromRGB(176, 28, 38), Text = "SALIN INFO", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false}, baris)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, bSalin)
local bTutup = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = Color3.fromRGB(45, 45, 50), Text = "TUTUP", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false}, baris)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, bTutup)

local alive = true
bTutup.MouseButton1Click:Connect(function() alive = false; gui:Destroy() end)

local accObj = nil
local accErr = nil
local accCoba = false

local function pasangAccTest(char)
	if accCoba then return end
	accCoba = true
	local ok, err = pcall(function()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then error("Humanoid tidak ada") end
		local asset = game:GetObjects("rbxassetid://" .. TEST_ACC_ID)[1]
		if not asset then error("gagal load asset " .. TEST_ACC_ID) end
		local acc = asset:IsA("Accessory") and asset or asset:FindFirstChildWhichIsA("Accessory", true)
		if not acc then error("bukan Accessory") end
		hum:AddAccessory(acc)
		accObj = acc
	end)
	if not ok then accErr = tostring(err) end
end

local function cariKarakter()
	local c = me.Character
	if c and c.Parent then return c end
	return nil
end

local function statusPart(char, nama)
	local p = char and char:FindFirstChild(nama)
	if not p then return nama .. "=-" end
	return nama .. "=ada(Trans " .. string.format("%.1f", p.Transparency) .. "/" .. string.format("%.1f", p.LocalTransparencyModifier) .. ")"
end

local function bangunInfo()
	local baris2 = {}
	table.insert(baris2, "PlaceId: " .. tostring(game.PlaceId))
	table.insert(baris2, "waktu: " .. os.date("%H:%M:%S"))
	local char = cariKarakter()
	table.insert(baris2, "me.Character: " .. (char and "ada" or "TIDAK ADA"))
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		table.insert(baris2, "Humanoid: " .. (hum and "ada" or "TIDAK ADA") .. (hum and (" | RigType=" .. tostring(hum.RigType)) or ""))
		table.insert(baris2, "Rig: " .. ((char:FindFirstChild("UpperTorso") and "R15") or (char:FindFirstChild("Torso") and "R6") or "?"))
		table.insert(baris2, statusPart(char, "Head"))
		table.insert(baris2, statusPart(char, "HumanoidRootPart"))
		table.insert(baris2, statusPart(char, "Torso"))
		table.insert(baris2, statusPart(char, "UpperTorso"))
		-- daftar semua anak langsung + class-nya, biar ketauan ada "Rigs" folder atau struktur aneh
		local anak = {}
		for _, d in ipairs(char:GetChildren()) do table.insert(anak, d.Name .. "[" .. d.ClassName .. "]") end
		table.insert(baris2, "Children char: " .. table.concat(anak, ", "))
		-- cek folder Rigs di workspace (dipakai sebagian game buat render karakter lain)
		local rigs = workspace:FindFirstChild("Rigs")
		table.insert(baris2, "workspace.Rigs: " .. (rigs and "ADA" or "-"))
		if not accObj or not accObj.Parent then pasangAccTest(char) end
	else
		table.insert(baris2, "(nunggu karakter...)")
	end
	table.insert(baris2, "--- TEST ACCESSORY (Fedora id " .. TEST_ACC_ID .. ") ---")
	if accErr then
		table.insert(baris2, "status: GAGAL DIPASANG -> " .. accErr)
	elseif accObj and accObj.Parent then
		local h = accObj:FindFirstChild("Handle")
		table.insert(baris2, "status: terpasang, Parent=" .. accObj.Parent:GetFullName())
		if h then
			table.insert(baris2, "Handle.Transparency=" .. string.format("%.2f", h.Transparency))
			table.insert(baris2, "Handle.LocalTransparencyModifier=" .. string.format("%.2f", h.LocalTransparencyModifier))
			table.insert(baris2, "Handle.Parent=" .. h.Parent:GetFullName())
			local w = h:FindFirstChildWhichIsA("Weld") or h:FindFirstChildWhichIsA("WeldConstraint")
			table.insert(baris2, "Weld di Handle: " .. (w and (w.ClassName .. " ada, Part0=" .. (w.Part0 and w.Part0.Name or "nil") .. " Part1=" .. (w.Part1 and w.Part1.Name or "nil")) or "TIDAK ADA"))
		else
			table.insert(baris2, "Handle: TIDAK ADA (aneh, accessory tanpa handle)")
		end
	elseif accCoba then
		table.insert(baris2, "status: sudah dicoba tapi accObj kosong/ke-destroy, kemungkinan game langsung menghapusnya")
	else
		table.insert(baris2, "status: belum dicoba (nunggu karakter)")
	end
	return table.concat(baris2, "\n")
end

task.spawn(function()
	while alive do
		local ok, teks = pcall(bangunInfo)
		if ok then info.Text = teks else info.Text = "error bikin info: " .. tostring(teks) end
		task.wait(1)
	end
end)

bSalin.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(info.Text)
		print("[KRONOZ TEST] info disalin ke clipboard")
	else
		print("[KRONOZ TEST] setclipboard tidak didukung, copy manual dari console:")
	end
	print(info.Text)
end)

me.CharacterAdded:Connect(function()
	accObj = nil; accErr = nil; accCoba = false
end)

print("[KRONOZ TEST] jalan. Tunggu beberapa detik, lalu pencet SALIN INFO.")
