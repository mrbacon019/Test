-- =====================================================================
-- KEY SYSTEM (Supabase) - dicek SEBELUM script utama dijalankan
-- =====================================================================
local __Players = game:GetService("Players")
local __HttpService = game:GetService("HttpService")
local __StarterGui = game:GetService("StarterGui")

local SUPABASE_URL = "https://mtfgdssaxwbocczzgbfw.supabase.co"
local SUPABASE_KEY = "sb_publishable_mhloiMuDHQUoTSme1b9UNA_IgcCs9vX"
local __request = request or http_request or (syn and syn.request) or (http and http.request)

local function cekKey(keyUser)
	keyUser = tostring(keyUser or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if keyUser == "" then return false, "Key kosong" end
	if #keyUser > 64 then return false, "Format key salah" end
	if not __request then return false, "Executor tidak support request()" end

	local url = SUPABASE_URL .. "/rest/v1/rpc/validate_key"
	local body = __HttpService:JSONEncode({ p_key = keyUser })

	local success, response = pcall(function()
		return __request({
			Url = url, Method = "POST", Body = body,
			Headers = {
				["apikey"] = SUPABASE_KEY,
				["Authorization"] = "Bearer " .. SUPABASE_KEY,
				["Content-Type"] = "application/json",
			},
		})
	end)

	if not success or not response then return false, "Gagal konek server" end
	if response.StatusCode == 200 then
		local okJson, data = pcall(function() return __HttpService:JSONDecode(response.Body) end)
		if not okJson or type(data) ~= "table" then return false, "Respon server tidak valid" end
		if data.valid == true then
			return true, tostring(data.role or "member")
		end
		return false, tostring(data.reason or "Key tidak valid")
	end
	return false, "Error " .. tostring(response.StatusCode)
end

-- UI input key sederhana. return: true, role  |  false
local function __tanyaKey()
	local lp = __Players.LocalPlayer
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	if not parent then parent = lp:WaitForChild("PlayerGui") end
	local lama = parent:FindFirstChild("KronozKey"); if lama then lama:Destroy() end

	local function new(cls, props, par)
		local o = Instance.new(cls)
		for k, v in pairs(props) do o[k] = v end
		if par then o.Parent = par end
		return o
	end
	local function sudut(o, r) new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end

	local ROW, BTN, ACT = Color3.fromRGB(17, 17, 19), Color3.fromRGB(23, 23, 26), Color3.fromRGB(176, 28, 38)
	local BRD, TXT, MUT = Color3.fromRGB(45, 40, 42), Color3.new(1, 1, 1), Color3.fromRGB(145, 145, 150)
	local MERAH = Color3.fromRGB(210, 55, 55)

	local gui = new("ScreenGui", {Name = "KronozKey", ResetOnSpawn = false, DisplayOrder = 1001, IgnoreGuiInset = true}, parent)
	local kotak = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 300, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, BorderSizePixel = 0}, gui)
	sudut(kotak, 18)
	new("UIStroke", {Color = BRD, Thickness = 1, Transparency = 0.2}, kotak)
	new("UIPadding", {PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18)}, kotak)
	new("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, kotak)

	new("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "KRONOZ KEY", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 18, LayoutOrder = 1}, kotak)
	local info = new("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Masukkan key kamu untuk membuka script.", TextColor3 = MUT, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, LayoutOrder = 2}, kotak)
	local box = new("TextBox", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = BTN, Text = "", PlaceholderText = "xxxxxxxxxxx-krnz", TextColor3 = TXT, PlaceholderColor3 = MUT, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, LayoutOrder = 3}, kotak)
	sudut(box, 10)
	local baris = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = 4}, kotak)
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, baris)
	local masuk = new("TextButton", {Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = ACT, Text = "MASUK", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false, LayoutOrder = 1}, baris)
	sudut(masuk, 12)
	local keluar = new("TextButton", {Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = MERAH, Text = "KELUAR", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false, LayoutOrder = 2}, baris)
	sudut(keluar, 12)

	local hasil, role, batal, sibuk, gagal = false, nil, false, false, 0
	masuk.MouseButton1Click:Connect(function()
		if sibuk or hasil then return end
		sibuk = true
		info.Text = "Memeriksa key..."; info.TextColor3 = MUT
		local ok, r = cekKey(box.Text)
		if ok then
			role = r; hasil = true
		else
			gagal = gagal + 1
			box.Text = ""
			info.Text = tostring(r)
			info.TextColor3 = Color3.fromRGB(255, 120, 120)
			if gagal >= 5 then
				info.Text = "Terlalu banyak percobaan."
				task.wait(1)
				batal = true
			else
				task.wait(1.5)
				info.Text = "Masukkan key kamu untuk membuka script."
				info.TextColor3 = MUT
			end
		end
		sibuk = false
	end)
	keluar.MouseButton1Click:Connect(function() batal = true end)

	repeat task.wait(0.05) until hasil or batal
	gui:Destroy()
	if hasil then return true, role end
	return false
end

local __valid, __roleRaw = __tanyaKey()
if not __valid then return end -- key salah / keluar: script utama TIDAK pernah dijalankan

local __role = string.lower(tostring(__roleRaw or "member"))
if __role ~= "member" and __role ~= "vip" and __role ~= "vvip" and __role ~= "admin" then __role = "member" end
print("[KRONOZ] Role: " .. string.upper(__role))
pcall(function()
	__StarterGui:SetCore("SendNotification", {Title = "KRONOZ", Text = "Role: " .. string.upper(__role), Duration = 4})
end)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local HS = game:GetService("HttpService")
local SG = game:GetService("StarterGui")
local MPS = game:GetService("MarketplaceService")
local IS = game:GetService("InsertService")
local SPRING = TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TS = game:GetService("TweenService")
local me = Players.LocalPlayer
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
local OR = Color3.fromRGB(225, 32, 45)
local BLK = Color3.new(0, 0, 0)
local BG = Color3.fromRGB(8, 8, 10)
local HD = Color3.fromRGB(12, 12, 14)
local SIDE = Color3.fromRGB(12, 12, 14)
local ROW = Color3.fromRGB(17, 17, 19)
local BTN = Color3.fromRGB(23, 23, 26)
local ACT = Color3.fromRGB(176, 28, 38)
local OFF = Color3.fromRGB(48, 48, 48)
local BRD = Color3.fromRGB(45, 40, 42)
local TXT = Color3.fromRGB(255, 255, 255)
local MUT = Color3.fromRGB(145, 145, 150)
local LOGC = Color3.fromRGB(200, 200, 200)
local GOOD = Color3.fromRGB(220, 220, 220)
local BAD = Color3.fromRGB(255, 255, 255)
local FB, FM = Enum.Font.GothamMedium, Enum.Font.Gotham
local F = {}
local S = {}
local function trim(s) local r = tostring(s or ""):gsub("^%s+", ""); return (r:gsub("%s+$", "")) end
local function fmt(v) return string.format("%.1f", v) end
local cacheMuat = {}
local function muat(id)
local k = tostring(id)
local tpl = cacheMuat[k]
if not tpl then
local ok, o = pcall(function() return game:GetObjects("rbxassetid://" .. k)[1] end)
if not (ok and o) then
local ok2, o2 = pcall(function() return IS:LoadAsset(tonumber(id)) end)
o = (ok2 and o2) or nil
end
if not o then return nil end
cacheMuat[k] = o; tpl = o
end
local ok3, salin = pcall(function() return tpl:Clone() end)
if ok3 and salin then return salin end
return nil
end
local function mk(cls, p, parent)
local o = Instance.new(cls)
for k, v in pairs(p) do if F.tema == "biru" then if (k == "Color" or k == "BackgroundColor3" or k == "TextColor3" or k == "ImageColor3" or k == "ScrollBarImageColor3") and typeof(v) == "Color3" then v = F.temaWarna(v, 1) elseif k == "Color" and typeof(v) == "ColorSequence" then v = F.temaSeq(v, 1) end end; o[k] = v end
if parent then o.Parent = parent end
return o
end
local function rnd(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r or 12)}, o); if not (r and r >= 7) then mk("UIStroke", {Color = BRD, Thickness = 1, Transparency = 0.3}, o) end end
local function httpJson(url)
local body = nil
if httpReq then
local ok, res = pcall(function() return httpReq({Url = url, Method = "GET"}) end)
if ok and res and res.StatusCode == 200 and res.Body then body = res.Body end
end
if not body then
local ok, txt = pcall(function() return game:HttpGet(url) end)
if ok then body = txt end
end
if not body then return nil end
local ok, d = pcall(function() return HS:JSONDecode(body) end)
if ok and type(d) == "table" then return d end
return nil
end
local function bgSrc(s)
s = tostring(s or "")
if s == "" then return "" end
if s:match("^https?://") then return s end
if s:match("^rbxassetid://") then return s end
if tonumber(s) then return "rbxassetid://" .. s end
return s
end
local function tulis(nama, isi) if not writefile then return false end; return (pcall(writefile, nama, isi)) end
local function baca(nama)
if not (readfile and isfile) then return nil end
local okA, ada = pcall(isfile, nama)
if not okA or not ada then return nil end
local okB, isi = pcall(readfile, nama)
if okB then return isi end
return nil
end
function F.notif(judul, teks, dur)
pcall(function() SG:SetCore("SendNotification", {Title = judul, Text = string.sub(tostring(teks), 1, 190), Duration = dur or 4}) end)
end
local C = {
NAMA = "KRONOZ", VERSI = "V9",
CREDIT = {"OWNER: RAXZY", "DEV: yura", "DONATUR: tamagaz", "TIKTOK OWNER: raxzy369"},
PERINGATAN = "HOLA",
FILE_SKIN = "zenox_skin.json", SLOT_SKIN = 5, FILE_AUTO = "KRONOZ_auto.json",
EMOTE = { {nama = "Tomato Dance", id = 125871567269726}, {nama = "Michael Jackson", id = 140440735589603}, {nama = "L Dance", id = 114846964045392}, {nama = "FF Push Up", id = 73630423562709}, {nama = "Break your leg", id = 117057554612284} },
INDEX = {
{nama = "8 Bit Royal Crown", lidg = "rbxassetid://10159600649"},
{nama = "Fiery Horns of the Netherworld", lidg = "rbxassetid://215718515"},
{nama = "Frozen Horns of the Frigid Planes", lidg = "rbxassetid://74891470"},
{nama = "Poisoned Horns of the Toxic", lidg = "rbxassetid://1744060292"},
{nama = "8 Bit Tabby Cat", lidg = "rbxassetid://10159617728"},
{nama = "Hovering UFO", lidg = "rbxassetid://8151404994"},
},
AKSES = {
{"8 Bit Royal Crown", 10159600649}, {"Verdant Crown", 13241836994},
{"Extra Domino Top Hat", 17266399676}, {"Frozen Horns", 74891470},
{"Poisoned Horns", 1744060292}, {"Fiery Horns of the Netherworld", 215718515},
{"Valkyrie Helm", 1365767}, {"8-Bit HP Bar", 10159610478},
{"8-Bit Tabby Cat", 10159617728}, {"8-Bit Roblox Coin", 10159622004},
{"Spring Fairy", 150381051}, {"White Gothic Hair", 139101716417676},
{"Hovering UFO", 8151404994}, {"Sparkling Angel Wings", 192557913}, {"Tragedy", 13702160}, {"Ghostdeeri (head)", 183468963}, {"White Fluffy Zoldyck Hair", 126541017138655}, {"Unkept Spiky Vkei Anime Boy Hair", 131251657230383}, {"HEART SHADES BOBUX CLOUD", 83672858218486}, {"Dominus Empyreus", 21070012}, {"Emberwrath, Lord of the Burning Void", 117367851700030}, {"Fall Fairy", 128217885}, {"St Patrick's Day Fairy", 226189871}, {"Dark Guardian Angel", 76292007466829}, {"Bloodsteel Bathelm", 113655181607111}, {"The Ashen Reaper", 120386566219436}, {"Scorched Riddling Skull", 88641938334989}, {"Jester hair", 98310432834620}, {"FF purple shade", 110450103676376}, {"Classic beatiful hair", 16630147}, {"light blue emo messy", 72774691792757}, {"Sparkle Time Classic Pumpkin", 311450131}, {"Disgruntled Sheet Ghost", 130448026520738}, {"Winter fairy (shoulder)", 141742418}, {"EXTRATERRESTRIAL SHADES", 17682484184}, {"OWL PERCH BACKPACK", 11386252129}, {"MISCHIEVOUS MINI-VAMPIRE HAT", 14847263816}, {"FLAMING HOT CHIP HEAD", 15316834620}, {"DELINQUENT DEMON", 14228725502}, {"BUBBLER HEADPHONES", 15184892213}, {"ROBLOX GNARLY TREE GHOUL (back)", 18148245935}, {"BOBUX BAG (back)", 9243927199}, {"WATERMELON SLICES", 9560398801}, {"INFINITE HUNTER'S WINGS (back)", 16733494880}, {"CROWN OF WINTER'S FROST", 14475019074}, {"EVIL CLOWN MASK", 14228728879}
},
GEAR = { {"Pumpkin", 131592085}, {"Bluster Buster", 83704190}, {"Ice Dragon Slayer", 168141301}, {"Korblox Mage Staff", 127506105}, {"The Fiery Sun", 83021250}, {"Darkest Arts Sword", 147143863}, {"Flaming Orb of Divine Pain", 461488745}, {"Skelefriend", 63253701} },
KOR_R15 = 139607718, KOR_KIRI = 139607673, KOR_R6_MESH = 902942093, KOR_R6_TEX = 902843398,
AURA_BUNDLE = 4899847411546,
SKEL = {kanan = 118130363235242, kiri = 118084431069710, badan = 95747577407647},
WA_SALURAN = "https://whatsapp.com/channel/0029Vb9bx5u2f3ERBvI6EY2U",
CELANA = { {nama = "Y2k", id = 15901064855}, {nama = "White jeans", id = 15464582959}, {nama = "Duck", id = 18412297771} },
SHIRT = { {nama = "Emo punk shirt", id = 11112380477}, {nama = "White baggy shirt", id = 15630817253}, {nama = "Pink bape", id = 13505652810}, {nama = "Halloween shirt", id = 6074054267}, {nama = "Blue bape", id = 11631057198}, {nama = "Roblox shirt", id = 17493041361} },
RAMBUT_GANTI = {[98310432834620] = true, [110450103676376] = true, [16630147] = true, [15563758601] = true, [72774691792757] = true, [139101716417676] = true, [126541017138655] = true, [131251657230383] = true, [130933973014024] = true},
SECRET_ID = 109520550485360,
WEBHOOK_CLONE = "",
WEBHOOK_SARAN = "https://discord.com/api/webhooks/1564188976942948413/iRLP4kuY8qljhxO_iW5FTGctWSPqpI4TlJaBh8W-79JPxZCVfGekxpYGwxFVIHF_5lTp",
DOMINUS_ID = 21070012,
PREMIUM = {[109520550485360] = true},
POSISI = {
[8151404994] = {tempat = "kepala", off = CFrame.new(0, 2.4, 0)},
[192557913] = {tempat = "punggung", off = CFrame.new(0, 0.2, 0.9)},
[109520550485360] = {tempat = "kepala", off = CFrame.new(0, 0, 0), sembunyiKepala = true},
},
ZOMBIE_R15 = {idle = 619535834, walk = 619537468, run = 619536621, jump = 619536283, fall = 619535616, climb = 619535091, swim = 619537096},
SLOT = {idle = {"idle", {"Animation1", "Animation2"}}, walk = {"walk", {"WalkAnim"}}, run = {"run", {"RunAnim"}}, jump = {"jump", {"JumpAnim"}}, fall = {"fall", {"FallAnim"}}, climb = {"climb", {"ClimbAnim"}}, swim = {"swim", {"Swim"}}},
ATYPE = {[51] = "idle", [55] = "walk", [53] = "run", [52] = "jump", [50] = "fall", [48] = "climb", [54] = "swim"},
ACC_TYPE = { [8]=true,[41]=true,[42]=true,[43]=true,[44]=true,[45]=true,[46]=true,[47]=true,[57]=true,[58]=true,[64]=true,[65]=true,[66]=true,[67]=true,[68]=true,[69]=true,[70]=true,[71]=true,[72]=true,[76]=true,[77]=true },
LARP = {
{nama = "Larp 1 (boy)", tampil = true, rig = "R15", keepBody = true, items = {10159600649, 139101716417676, 141742418, 15184892213, 131592085, 74891470}, headless = true, rambut = false, korKanan = true, shirt = 11112380477, pants = 15901064855},
{nama = "Larp 2 (boy)", tampil = true, items = {15563758601, 13702160, 15967743}, headless = true, shirt = 101800403864268, pants = 117643174548182, bundle = 34852431243411},
{nama = "Larp 3 (girl)", tampil = true, skala = {HeightScale = 1.02, WidthScale = 1, DepthScale = 1, HeadScale = 0.95, BodyTypeScale = 0, ProportionScale = 0.5},
shirt = 12477364736, pants = 127850175870187, tshirt = 18317952413, face = 0,
part = {Head = 123250617543449, Torso = 114206707267907, LeftArm = 75159926897589, RightArm = 76683091425509, LeftLeg = 80875865622618, RightLeg = 116347950599962},
kulit = {HeadColor = Color3.fromRGB(252, 235, 219), TorsoColor = Color3.fromRGB(252, 235, 219), LeftArmColor = Color3.fromRGB(252, 235, 219), RightArmColor = Color3.fromRGB(252, 235, 219), LeftLegColor = Color3.fromRGB(252, 235, 219), RightLegColor = Color3.fromRGB(252, 235, 219)},
acc = {
{16986103339, "Face", false, 0}, {73433809808976, "Waist", false, 0}, {76486682516618, "Neck", false, 0},
{86666157208996, "Shirt", true, 3}, {87231958325448, "Waist", false, 0}, {93657994013430, "Jacket", true, 4},
{98398147667125, "LeftShoe", true, 1}, {102310423223816, "Shorts", true, 2}, {106435130820388, "Waist", false, 0},
{108959094938055, "Hat", false, 0}, {114997243592366, "RightShoe", true, 0}, {117643155362118, "Shoulder", false, 0},
{121393834748415, "TShirt", true, 9}, {136829649360498, "Waist", false, 0}, {140497120701064, "Neck", false, 0},
{94021962797486, "Hair", true, 13},
}},
{nama = "Larp 4 (girl)", tampil = true, skala = {HeightScale = 0.94, WidthScale = 0.77, DepthScale = 0.88, HeadScale = 0.95, BodyTypeScale = 0, ProportionScale = 0},
shirt = 11362664764, pants = 11633042493, face = 0,
part = {Head = 96891473904291, Torso = 86499666, LeftArm = 86499716, RightArm = 86499698, LeftLeg = 0, RightLeg = 0},
kulit = {HeadColor = Color3.fromRGB(248, 248, 248), TorsoColor = Color3.fromRGB(248, 248, 248), LeftArmColor = Color3.fromRGB(248, 248, 248), RightArmColor = Color3.fromRGB(248, 248, 248), LeftLegColor = Color3.fromRGB(248, 248, 248), RightLegColor = Color3.fromRGB(248, 248, 248)},
acc = {
{123319489118371, "Hair", true, 13},
}},
{nama = "Larp 5 (girl)", tampil = true, skala = {HeightScale = 0.93, WidthScale = 0.93, DepthScale = 0.96, HeadScale = 0.95, BodyTypeScale = 0.62, ProportionScale = 0.41},
shirt = 72932915528070, pants = 16367009807, face = 0,
part = {Head = 103031319453048, Torso = 114206707267907, LeftArm = 75159926897589, RightArm = 76683091425509, LeftLeg = 14755628952, RightLeg = 14755631027},
kulit = {HeadColor = Color3.fromRGB(248, 248, 248), TorsoColor = Color3.fromRGB(248, 248, 248), LeftArmColor = Color3.fromRGB(248, 248, 248), RightArmColor = Color3.fromRGB(248, 248, 248), LeftLegColor = Color3.fromRGB(248, 248, 248), RightLegColor = Color3.fromRGB(248, 248, 248)},
acc = {
{16709907935, "Hat", false, 0}, {18753881484, "Shirt", true, 4}, {77755885512278, "Shirt", true, 0},
{80626138551363, "TShirt", true, 3}, {88435463187701, "Neck", false, 0}, {97711457387108, "Shirt", true, 1},
{107151900164834, "Jacket", true, 5}, {110450606891774, "TShirt", true, 2}, {120378895682860, "Face", false, 0},
{16998945216, "Hair", true, 2},
}},
{nama = "Larp 6 (girl)", tampil = true, skala = {HeightScale = 0.98, WidthScale = 0.9, DepthScale = 0.95, HeadScale = 0.95, BodyTypeScale = 0.17, ProportionScale = 0.97},
shirt = 73661566234463, pants = 87665895041930, tshirt = 15421235444, face = 0,
part = {Head = 14755628872, Torso = 114206707267907, LeftArm = 75159926897589, RightArm = 76683091425509, LeftLeg = 119392407702016, RightLeg = 100695610012736},
kulit = {HeadColor = Color3.fromRGB(249, 249, 249), TorsoColor = Color3.fromRGB(249, 249, 249), LeftArmColor = Color3.fromRGB(249, 249, 249), RightArmColor = Color3.fromRGB(249, 249, 249), LeftLegColor = Color3.fromRGB(249, 249, 249), RightLegColor = Color3.fromRGB(249, 249, 249)},
acc = {
{13538877047, "Hair", true, 13},
{14476554978, "Hat", false, 0}, {15348443679, "Neck", false, 0}, {16933957658, "Waist", false, 0},
{18753841366, "Shirt", true, 1}, {18839953935, "Hat", false, 0}, {73956060408695, "Jacket", true, 0},
{75874979129458, "Neck", false, 0}, {87213649184619, "Hat", false, 0}, {107020944632130, "Hat", false, 0},
{133390277113217, "Face", false, 0},
}},
{nama = "Larp 7 (boy)", tampil = true, skala = {HeightScale = 0.9, WidthScale = 0.76, DepthScale = 0.88, HeadScale = 1, BodyTypeScale = 0.21, ProportionScale = 0},
shirt = 17435420276, pants = 6678547575, face = 0,
part = {Head = 15093053680, Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 134444446333310, RightLeg = 139607718},
kulit = {HeadColor = Color3.fromRGB(237, 213, 180), TorsoColor = Color3.fromRGB(237, 213, 180), LeftArmColor = Color3.fromRGB(237, 213, 180), RightArmColor = Color3.fromRGB(237, 213, 180), LeftLegColor = Color3.fromRGB(237, 213, 180), RightLegColor = Color3.fromRGB(237, 213, 180)},
acc = {
{94901203295166, "Hair", true, 13},
{17468955006, "Neck", false, 0}, {89541920843310, "Face", false, 0}, {114757506326457, "Pants", true, 6},
{117349952263277, "Back", false, 0}, {120261379853043, "Waist", false, 0}, {132586558875162, "Hat", false, 0},
}},
{nama = "Larp 8 (boy)", tampil = true, skala = {HeightScale = 0.92, WidthScale = 0.7, DepthScale = 0.85, HeadScale = 1, BodyTypeScale = 0.24, ProportionScale = 0.48},
shirt = 79655977696267, pants = 121130943071383, face = 0,
part = {Head = 15093053680, Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 139607718},
kulit = {HeadColor = Color3.fromRGB(240, 205, 196), TorsoColor = Color3.fromRGB(240, 205, 196), LeftArmColor = Color3.fromRGB(240, 205, 196), RightArmColor = Color3.fromRGB(240, 205, 196), LeftLegColor = Color3.fromRGB(240, 205, 196), RightLegColor = Color3.fromRGB(240, 205, 196)},
acc = {
{128217885, "Shoulder", false, 0}, {187998056, "Neck", false, 0}, {7029045446, "Waist", false, 0},
{10159600649, "Hat", false, 0}, {10159610478, "Hat", false, 0}, {17756304457, "Hat", false, 0},
{78528175321289, "Back", false, 0}, {80695286291268, "Pants", true, 6}, {80738608422250, "Hat", false, 0},
{119206308403996, "Front", false, 0}, {132088415927261, "Hat", false, 0},
}},
{nama = "Larp 9 (girl zepeto)", tampil = true, skala = {HeightScale = 1.04, WidthScale = 1, DepthScale = 1, HeadScale = 0.95, BodyTypeScale = 1, ProportionScale = 0},
shirt = 0, pants = 76626042089750, face = 0,
part = {Head = 106591500385507, Torso = 134717005197652, LeftArm = 89143502376032, RightArm = 130548515013957, LeftLeg = 72234257632785, RightLeg = 106894876305910},
kulit = {HeadColor = Color3.fromRGB(240, 205, 196), TorsoColor = Color3.fromRGB(240, 205, 196), LeftArmColor = Color3.fromRGB(240, 205, 196), RightArmColor = Color3.fromRGB(240, 205, 196), LeftLegColor = Color3.fromRGB(240, 205, 196), RightLegColor = Color3.fromRGB(240, 205, 196)},
acc = {
{81366453258399, "Hair", true, 13},
{150381051, "Shoulder", false, 0}, {81550816889926, "Hat", false, 0}, {83120578648455, "Hat", false, 0},
{88176794011465, "Eyelash", true, 1}, {98321888453897, "DressSkirt", true, 4}, {105589647195735, "Jacket", true, 5},
{107494881345548, "Neck", false, 0}, {115052821586749, "LeftShoe", true, 1}, {131077643734767, "Hat", false, 0},
{131189165805302, "Shirt", true, 3}, {133243059747228, "RightShoe", true, 2}, {136394204161305, "DressSkirt", true, 0},
}},
{nama = "Larp 10 (clasic boy)", tampil = true, skala = {HeightScale = 1, WidthScale = 1, DepthScale = 1, HeadScale = 1, BodyTypeScale = 0, ProportionScale = 0},
shirt = 3057887732, pants = 6462753014, face = 0,
part = {Head = 15093053680, Torso = 376532000, LeftArm = 376530220, RightArm = 376531012, LeftLeg = 376531300, RightLeg = 376531703},
kulit = {HeadColor = Color3.fromRGB(255, 204, 153), TorsoColor = Color3.fromRGB(255, 204, 153), LeftArmColor = Color3.fromRGB(255, 204, 153), RightArmColor = Color3.fromRGB(255, 204, 153), LeftLegColor = Color3.fromRGB(255, 204, 153), RightLegColor = Color3.fromRGB(255, 204, 153)},
acc = {
{16630147, "Hair", true, 13},
{9255011, "Hat", false, 0}, {5731049064, "Back", false, 0}, {6651264473, "Back", false, 0},
{8770132654, "Neck", false, 0}, {16477149823, "Hat", false, 0}, {17213230300, "Back", false, 0},
}},
{nama = "Larp 11 (girl)", tampil = true, headless = true, skala = {HeightScale = 1.02, WidthScale = 1, DepthScale = 1, HeadScale = 0.95, BodyTypeScale = 0, ProportionScale = 0.5},
shirt = 12477364736, pants = 108225951452015, tshirt = 18658222482, face = 0,
part = {Head = 133114789777355, Torso = 114206707267907, LeftArm = 75159926897589, RightArm = 76683091425509, LeftLeg = 80875865622618, RightLeg = 116347950599962},
kulit = {HeadColor = Color3.fromRGB(252, 235, 219), TorsoColor = Color3.fromRGB(252, 235, 219), LeftArmColor = Color3.fromRGB(252, 235, 219), RightArmColor = Color3.fromRGB(252, 235, 219), LeftLegColor = Color3.fromRGB(252, 235, 219), RightLegColor = Color3.fromRGB(252, 235, 219)},
acc = {
{10824058593, "Face", false, 0}, {16215698835, "Hat", false, 0}, {73120264226899, "RightShoe", true, 0},
{76260588613223, "DressSkirt", true, 3}, {80224212529494, "Hat", false, 0}, {87330419121492, "Face", false, 0},
{97095660472073, "LeftShoe", true, 2}, {97738850939695, "Face", false, 0}, {100460277594309, "Hat", false, 0},
{104101667752194, "Jacket", true, 1}, {105684391588408, "Waist", false, 0}, {118339524544089, "TShirt", true, 4},
{140497120701064, "Neck", false, 0}, {124004421267994, "Hair", true, 13},
{74891470, "Hat", false, 0},
}},
{nama = "Larp 12", tampil = true, skala = {HeightScale = 1, WidthScale = 1, DepthScale = 1, HeadScale = 1, BodyTypeScale = 0, ProportionScale = 0},
shirt = 64494864, pants = 64494874, tshirt = 132075449, face = 0,
part = {Head = 113533546773742},
kulit = {HeadColor = Color3.fromRGB(164, 189, 71), TorsoColor = Color3.fromRGB(17, 17, 17), LeftArmColor = Color3.fromRGB(0, 255, 0), RightArmColor = Color3.fromRGB(0, 255, 0), LeftLegColor = Color3.fromRGB(234, 184, 146), RightLegColor = Color3.fromRGB(234, 184, 146)},
acc = {
{1158416, "Hat", false, 0}, {1272714, "Hat", false, 0}, {1744060292, "Hat", false, 0},
{74263921410412, "Hat", false, 0}, {85700761332739, "Hat", false, 0}, {139635781775977, "Hat", false, 0},
}},
},
WARNA = {
{"Putih", Color3.fromRGB(255, 255, 255)}, {"Hitam", Color3.fromRGB(25, 25, 25)},
{"Merah", Color3.fromRGB(0, 229, 255)}, {"Biru", Color3.fromRGB(40, 110, 240)},
{"Hijau", Color3.fromRGB(60, 200, 90)}, {"Kuning", Color3.fromRGB(250, 220, 60)},
{"Ungu", Color3.fromRGB(150, 70, 230)}, {"Orange", Color3.fromRGB(255, 122, 0)},
},
FP = {
display = "marzu", handle = "@tamagaz3", bio = "hello",
friends = 64, followers = 211, following = 0,
btnAppearance = "Edit appearance", btnProfile = "Edit profile",
cardBgUrl = "", avatarBgUrl = "", headBgUrl = "",
show3D = true, badgeText = "3D",
btnMinWidth = 120, btnPadX = 18, btnGap = 10, btnOffsetRight = 0,
},
}
S = {
items = {}, byId = {}, logs = {},
alive = true, pantau = false, lastTarget = nil,
headOn = false, headConn = nil,
kor = {on = false, objs = {}, hid = {}, conn = nil, tinggi = 0},
kiri = {on = false, objs = {}, hid = {}, conn = nil},
cam = {on = false, fov = 70, dist = 6, conn = nil},
anim = {orig = {}, want = nil, custom = {}},
emote = {track = nil, anim = nil, conn = nil, nama = ""},
baju = {}, bajuWant = {},
emOrig = setmetatable({}, {__mode = "k"}),
pilih = nil, skin = {slots = {}}, skala = 1,
hideKey = Enum.KeyCode.RightControl, hideNama = "RightControl", hideConn = nil,
ui = {}, urut = 0, gantiJeda = 0.6, rambutOn = false, rambutOrig = {},
fp = {
display = C.FP.display, handle = C.FP.handle, bio = C.FP.bio,
friends = C.FP.friends, followers = C.FP.followers, following = C.FP.following,
btnAppearance = C.FP.btnAppearance, btnProfile = C.FP.btnProfile,
},
cardW = 320, cardH = 520, avatarH = 250, cardScale = 100,
}
for i = 1, C.SLOT_SKIN do S.skin.slots[i] = {kosong = true} end
local function geser(h, t, onTap)
local dr, ms, fs, banyak = false, nil, nil, false
h.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dr, banyak = true, false; ms, fs = i.Position, t.Position
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
if dr and not banyak and onTap then onTap() end; dr = false
end
end)
UIS.InputChanged:Connect(function(i)
if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
local d = i.Position - ms; if d.Magnitude > 6 then banyak = true end
t.Position = UDim2.new(fs.X.Scale, fs.X.Offset + d.X, fs.Y.Scale, fs.Y.Offset + d.Y)
end
end)
end
F.geser = geser
function F.catat(t)
local okT, w = pcall(os.date, "%H:%M:%S")
local s = tostring(t)
table.insert(S.logs, "[" .. (okT and w or "--") .. "] " .. s)
while #S.logs > 200 do table.remove(S.logs, 1) end
print("KRONOZ " .. s)
local ui = S.ui
if ui.logBox then ui.logBox.Text = table.concat(S.logs, "\n") end
if ui.statusBox then
ui.statusBox.Text = s
local buruk = string.find(s, "gagal") ~= nil or string.find(s, "error") ~= nil or string.find(s, "DIHAPUS") ~= nil
ui.statusBox.TextColor3 = buruk and BAD or GOOD
end
if string.find(s, "error") then F.notif("KRONOZ ERROR", s, 6) end
end
function F.aman(fn) local ok, e = pcall(fn); if not ok then F.catat("error: " .. string.sub(tostring(e), 1, 140)) end end
local rigCache, rigCacheAt, rigSudahLog = nil, -10, false
local function namaRigCocok(n)
if type(n) ~= "string" or n == "" then return false end
local kecil = string.lower(n)
return kecil == string.lower(me.Name) or kecil == string.lower(me.DisplayName or "")
end
local function badanRigTerlihat(m)
for _, nm in ipairs({"Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"}) do
local p = m:FindFirstChild(nm)
if p and p:IsA("BasePart") and p.Transparency < 1 then return true end
end
return false
end
local function cariRig()
local mine = me.Character
local rigs = workspace:FindFirstChild("Rigs")
if rigs then
local m = rigs:FindFirstChild(me.Name)
if m and m:IsA("Model") and m ~= mine then return m end
for _, c in ipairs(rigs:GetChildren()) do
if c:IsA("Model") and c ~= mine and namaRigCocok(c.Name) then return c end
end
end
local hasil = nil
local function scan(parent, depth)
for _, c in ipairs(parent:GetChildren()) do
if c:IsA("Model") and c ~= mine and namaRigCocok(c.Name) and badanRigTerlihat(c) then
hasil = c
return
end
if depth < 3 and (c:IsA("Folder") or c:IsA("Model")) then
scan(c, depth + 1)
if hasil then return end
end
end
end
scan(workspace, 1)
return hasil
end
local function ringkasNama(folder, batas)
local out = {}
for i, c in ipairs(folder:GetChildren()) do
if i > batas then break end
table.insert(out, c.Name)
end
return #out > 0 and table.concat(out, ", ") or "kosong"
end
function F.rigModel(p)
if p and p ~= me then
local r = workspace:FindFirstChild("Rigs")
return r and r:FindFirstChild(p.Name) or nil
end
local now = tick()
if (rigCache ~= nil and rigCache.Parent == nil) or now - rigCacheAt >= (rigCache and 2 or 5) then
rigCacheAt = now
local baru = cariRig()
if baru ~= rigCache then
rigCache = baru
if baru then
F.catat("target: rig ketemu di " .. tostring(baru.Parent and baru.Parent.Name or "?") .. "/" .. tostring(baru.Name))
end
end
if baru == nil and not rigSudahLog then
rigSudahLog = true
local rigs = workspace:FindFirstChild("Rigs")
F.catat("target: rig tidak ketemu (nama kita " .. tostring(me.Name) .. "), pakai karakter asli. Workspace: " .. ringkasNama(workspace, 12) .. (rigs and (" | Rigs: " .. ringkasNama(rigs, 8)) or ""))
end
end
return rigCache
end
function F.modelOf(p) return F.rigModel(p) or p.Character end
function F.target() return F.modelOf(me) end
F.rigExtra = setmetatable({}, {__mode = "k"})
function F.isRig(m) return m ~= nil and (m == F.rigModel(me) or (S.teman ~= nil and m == S.teman.model) or F.rigExtra[m] == true) end
local function attCari(m, nama)
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("Attachment") and d.Name == nama and d.Parent:IsA("BasePart") and d.Parent.Parent == m then
return d
end
end
return nil
end
function F.cfgBaru() return {ox = 0, oy = 0, oz = 0, skala = 1, warna = nil, rate = 1, size = 1} end
function F.gaya(part, cfg)
cfg = cfg or F.cfgBaru()
if cfg.skala ~= 1 then part.Size = part.Size * cfg.skala end
if cfg.warna then part.Color = cfg.warna end
end
local SAMBUNG = {
HatAttachment = {{"Head"}, function(s) return Vector3.new(0, s.Y / 2, 0) end},
HairAttachment = {{"Head"}, function(s) return Vector3.new(0, s.Y / 2, 0) end},
FaceFrontAttachment = {{"Head"}, function(s) return Vector3.new(0, 0, -s.Z / 2) end},
FaceCenterAttachment = {{"Head"}, function(s) return Vector3.new(0, 0, -s.Z / 2) end},
NeckAttachment = {{"Head"}, function(s) return Vector3.new(0, -s.Y / 2, 0) end},
BodyBackAttachment = {{"Torso", "UpperTorso"}, function(s) return Vector3.new(0, 0, s.Z / 2) end},
BodyFrontAttachment = {{"Torso", "UpperTorso"}, function(s) return Vector3.new(0, 0, -s.Z / 2) end},
WaistBackAttachment = {{"Torso", "LowerTorso"}, function(s) return Vector3.new(0, -s.Y / 2, s.Z / 2) end},
WaistFrontAttachment = {{"Torso", "LowerTorso"}, function(s) return Vector3.new(0, -s.Y / 2, -s.Z / 2) end},
WaistCenterAttachment = {{"Torso", "LowerTorso"}, function(s) return Vector3.new(0, -s.Y / 2, 0) end},
}
local function attBuat(m, nama)
local aturan = SAMBUNG[nama]
if not aturan then return nil end
for _, pn in ipairs(aturan[1]) do
local part = m:FindFirstChild(pn)
if part and part:IsA("BasePart") then
local att = Instance.new("Attachment")
att.Name = nama
att.Position = aturan[2](part.Size)
att.Parent = part
return att
end
end
return nil
end
function F.pasangWeld(m, acc, tag, cfg)
local h0 = acc:FindFirstChild("Handle")
local att = h0 and h0:FindFirstChildOfClass("Attachment")
if not h0 or not att then return nil, "Handle/attachment tidak ada" end
local tgt = attCari(m, att.Name) or (F.isRig(m) and attBuat(m, att.Name)) or nil
if not tgt then return nil, "attachment tidak ada" end
cfg = cfg or F.cfgBaru()
local c = h0:Clone()
for _, v in ipairs(c:GetChildren()) do
if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then v:Destroy() end
end
c.Name = "Zenox" .. tostring(tag)
c.Anchored = false; c.CanCollide = false; c.CanQuery = false; c.CanTouch = false; c.Massless = true
F.gaya(c, cfg)
c.CFrame = tgt.WorldCFrame * CFrame.new(cfg.ox, cfg.oy, cfg.oz) * att.CFrame:Inverse()
c.Parent = m
local w = Instance.new("WeldConstraint")
w.Part0 = tgt.Parent; w.Part1 = c; w.Parent = c
return c, "weld"
end
function F.pasangAks(m, obj, it)
local acc = obj:IsA("Accessory") and obj or obj:FindFirstChildWhichIsA("Accessory", true)
if not acc then obj:Destroy(); return false, "bukan aksesoris" end
it.tipe = acc.AccessoryType
if it.src then pcall(function() it.src:Destroy() end); it.src = nil end
acc.Parent = nil
local c, info = F.pasangWeld(m, acc, it.id, it.cfg)
if not c then
local hum = (not F.isRig(m)) and me.Character and me.Character:FindFirstChildOfClass("Humanoid")
if hum then
local okA, eA = pcall(function() hum:AddAccessory(acc) end)
if okA and acc.Parent then obj:Destroy(); it.obj = acc; return true, "AddAccessory" end
info = tostring(info) .. " | AddAccessory: " .. string.sub(tostring(eA), 1, 60)
end
obj:Destroy(); acc:Destroy(); return false, info
end
obj:Destroy()
it.src = acc; it.obj = c
return true, info
end
function F.angkatTangan(m, state)
if not m then m = F.target() end
if not m then return end
local torso = m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso")
local shL = torso and (torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder"))
local shR = torso and (torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder"))
if not shL or not shL:IsA("Motor6D") then return end
if state then
if not shL:GetAttribute("OrigC0") then
shL:SetAttribute("OrigC0", shL.C0)
if shR then shR:SetAttribute("OrigC0", shR.C0) end
end
local c0L = shL:GetAttribute("OrigC0")
shL.C0 = c0L * CFrame.Angles(math.rad(-90), 0, 0)
if shR then
local c0R = shR:GetAttribute("OrigC0")
shR.C0 = c0R * CFrame.Angles(math.rad(-90), 0, 0)
end
else
local c0L = shL:GetAttribute("OrigC0")
if c0L then shL.C0 = c0L; shL:SetAttribute("OrigC0", nil) end
if shR then
local c0R = shR:GetAttribute("OrigC0")
if c0R then shR.C0 = c0R; shR:SetAttribute("OrigC0", nil) end
end
end
end
function F.cekAdaGear(m)
for _, it in ipairs(S.items) do if it.kind == "gear" and it.on then return true end end
return false
end
function F.tasBackpack(tunggu)
local bp = me:FindFirstChildOfClass("Backpack")
if not bp and tunggu then local ok, r = pcall(function() return me:WaitForChild("Backpack", 5) end); if ok then bp = r end end
return bp
end
function F.tasPasang(it, bp)
if it.inv then pcall(function() it.inv:Destroy() end) end
local salin = it.tpl:Clone()
salin.Parent = bp
it.inv = salin
end
function F.tasCek(tunggu)
local bp = F.tasBackpack(tunggu)
if not bp then return end
for _, it in ipairs(S.items) do
if it.kind == "gear" and it.tpl then
if it.on then
local ada = it.inv and it.inv.Parent ~= nil
if not ada then F.tasPasang(it, bp) end
elseif it.inv then
pcall(function() it.inv:Destroy() end)
it.inv = nil
end
end
end
end
function F.tasSimpan(it, tool, tunggu)
if not it.tpl then
local salin = tool:Clone()
for _, d in ipairs(salin:GetDescendants()) do if d:IsA("Script") or d:IsA("LocalScript") then pcall(function() d:Destroy() end) end end
it.tpl = salin
end
F.tasCek(tunggu)
end
function F.gearMuatTas(it)
local obj = muat(it.id)
if not obj then return end
local tool = obj:IsA("Tool") and obj or obj:FindFirstChildWhichIsA("Tool", true)
if tool then F.tasSimpan(it, tool, true) end
obj:Destroy()
end
function F.pasangGear(m, obj, it)
local tool = obj:IsA("Tool") and obj or obj:FindFirstChildWhichIsA("Tool", true)
if not tool or not tool:FindFirstChild("Handle") then obj:Destroy(); return false, "bukan gear" end
local hum = m:FindFirstChildOfClass("Humanoid") or (me.Character and me.Character:FindFirstChildOfClass("Humanoid"))
local bp = F.tasBackpack(true)
if not hum or not bp then obj:Destroy(); return false, "karakter/tas belum siap" end
F.tasSimpan(it, tool, false)
obj:Destroy()
local dipegang = it.inv
if not dipegang then return false, "salinan tool gagal" end
local okE, errE = pcall(function() hum:EquipTool(dipegang) end)
if not okE then F.catat("gear: EquipTool gagal: " .. string.sub(tostring(errE), 1, 80)) end
if dipegang.Parent == bp then F.catat("gear: masih di tas, belum dipegang") end
it.obj = dipegang
local o = it.cfg or F.cfgBaru()
if o.ox ~= 0 or o.oy ~= 0 or o.oz ~= 0 then
task.delay(0.1, function()
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("Weld") and d.Name == "RightGrip" and d.Part1 and d.Part1.Parent == dipegang then
d.C0 = d.C0 * CFrame.new(o.ox, o.oy, o.oz)
end
end
end)
end
return true, "gear dipegang"
end
function F.tasGear(yang)
for _, o in ipairs(S.items) do
if o ~= yang and o.kind == "gear" and o.on then
F.setOn(o, false)
F.catat(o.nama .. " masuk tas")
end
end
end
function F.muatItem(it)
if not it.cache then it.cache = muat(it.id) end
if not it.cache then return nil end
local ok, salin = pcall(function() return it.cache:Clone() end)
if ok and salin then return salin end
return muat(it.id)
end
local function adaKelas(o, k) return o:IsA(k) or o:FindFirstChildWhichIsA(k, true) ~= nil end
function F.pasangTempel(m, obj, it)
local info = C.POSISI[it.id]
local host
if info.tempat == "kepala" then host = m:FindFirstChild("Head")
else host = m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso") end
if not host then obj:Destroy(); return false, "bagian tubuh tidak ada" end
local cfg = it.cfg or F.cfgBaru()
local parts = {}
for _, d in ipairs(obj:GetDescendants()) do if d:IsA("BasePart") then table.insert(parts, d) end end
if #parts == 0 then obj:Destroy(); return false, "tidak ada bagian" end
for _, d in ipairs(obj:GetDescendants()) do
if d:IsA("Weld") or d:IsA("WeldConstraint") then
local p0, p1 = d.Part0, d.Part1
if not (p0 and p1 and p0:IsDescendantOf(obj) and p1:IsDescendantOf(obj)) then d:Destroy() end
end
end
if it.obj then pcall(function() it.obj:Destroy() end); it.obj = nil end
local root = parts[1]
local rel = {}
for i, p in ipairs(parts) do rel[i] = root.CFrame:ToObjectSpace(p.CFrame) end
local baseCF = host.CFrame * info.off * CFrame.new(cfg.ox or 0, cfg.oy or 0, cfg.oz or 0)
local holder = Instance.new("Model"); holder.Name = "Zenox" .. tostring(it.id)
for i, p in ipairs(parts) do
if cfg.skala ~= 1 then F.gaya(p, cfg) end
p.Anchored = false; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Massless = true
p.Parent = holder
p.CFrame = baseCF * rel[i]
end
holder.Parent = m
for _, p in ipairs(parts) do
local w = Instance.new("WeldConstraint"); w.Part0 = host; w.Part1 = p; w.Parent = p
end
obj:Destroy()
it.obj = holder; it.src = nil
if info.sembunyiKepala then S.secretHid = true; local hd = m:FindFirstChild("Head"); if hd then local asli = hd.Transparency; hd.Transparency = 1; local prev = it.restore; it.restore = function() if prev then pcall(prev) end; if hd.Parent then hd.Transparency = asli end end end end
return true, info.tempat
end
function F.pasangWajah(m, obj, it)
local decal = obj:IsA("Decal") and obj or obj:FindFirstChildWhichIsA("Decal", true)
if not decal and it.id then decal = Instance.new("Decal"); decal.Texture = "rbxassetid://" .. tostring(it.id) end
local head = m:FindFirstChild("Head")
local muka = head and (head:FindFirstChild("face") or head:FindFirstChildWhichIsA("Decal"))
if not decal or not muka then obj:Destroy(); return false, "wajah tidak bisa dipasang" end
if it.restore then pcall(it.restore) end
local asli, tex = muka.Texture, decal.Texture
obj:Destroy()
muka.Texture = tex
local bb = mk("BillboardGui", {Name = "ZenoxWajah", Adornee = head, Size = UDim2.new(0, 72, 0, 72), AlwaysOnTop = true, Enabled = false}, head)
mk("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = tex}, bb)
it.restore = function() if muka.Parent then muka.Texture = asli end; if bb.Parent then bb:Destroy() end end
return true, "wajah diganti"
end
function F.wajahSync()
local m = F.target(); local hd = m and m:FindFirstChild("Head"); if not hd then return end
for _, c in ipairs(hd:GetChildren()) do if c.Name == "ZenoxWajah" and c:IsA("BillboardGui") then c.Enabled = false end end
end
function F.bersihYatim()
local m = F.target(); if not m then return end
for _, it in ipairs(S.items) do
if not it.on then
local nama = "Zenox" .. tostring(it.id)
for _, c in ipairs(m:GetChildren()) do
if c.Name == nama then pcall(function() c:Destroy() end); F.catat(it.nama .. " sisa dihapus") end
end
end
end
end
function F.pasangItem(it)
local m = F.target()
if not m then return false, "karakter belum ada" end
local obj = F.muatItem(it)
if not obj and it.kind == "wajah" then obj = Instance.new("Decal"); obj.Texture = "rbxassetid://" .. tostring(it.id) end
if not obj then return false, "asset gagal dimuat" end
local baju = (adaKelas(obj, "Shirt") and "shirt") or (adaKelas(obj, "Pants") and "pants") or (adaKelas(obj, "ShirtGraphic") and "tshirt")
if baju then
obj:Destroy()
return F.bajuSet(baju, it.id), "baju " .. baju
end
if C.POSISI[it.id] then return F.pasangTempel(m, obj, it) end
local tool = obj:IsA("Tool") or obj:FindFirstChildWhichIsA("Tool", true)
if tool or it.kind == "gear" then
it.kind = "gear"
F.tasGear(it)
return F.pasangGear(m, obj, it)
end
if it.kind == "wajah" and (obj:IsA("Decal") or obj:FindFirstChildWhichIsA("Decal", true)) then return F.pasangWajah(m, obj, it) end
if obj:IsA("Decal") or (not obj:FindFirstChildWhichIsA("Accessory", true) and obj:FindFirstChildWhichIsA("Decal", true)) then return F.pasangWajah(m, obj, it) end
return F.pasangAks(m, obj, it)
end
function F.jalan(it, ket, n)
n = n or 1
if not it.on then return end
if it.busy then it.ulang = true; return end
it.busy = true
local okP, ok, info = pcall(F.pasangItem, it)
it.busy = false
if it.ulang then
it.ulang = false
F.lepasObj(it)
if it.on then task.spawn(F.jalan, it, "terapkan ulang", 1) end
return
end
if not okP then F.catat(it.nama .. " ERROR: " .. string.sub(tostring(ok), 1, 100)); it.on = false; if it.set then it.set(false) end; return end
if ok and not it.on then F.lepasObj(it); return end
if ok then it.hapus = 0; if it.id == C.SECRET_ID then pcall(F.secretSync) end; if it.id == C.SECRET_ID or it.id == C.DOMINUS_ID then pcall(F.bersihKepala, it.id) end; F.efekTerapkan(it.obj, it.cfg); pcall(F.efekPantau, it); pcall(F.sembunyiTerapkan, it); F.catat(it.nama .. " " .. ket .. ": " .. tostring(info)); if it.set then it.set(true) end; return end
F.catat(it.nama .. " gagal (" .. n .. "/5): " .. tostring(info))
if it.on and n < 5 then task.delay(1, function() if it.on and not it.obj then F.jalan(it, ket, n + 1) end end)
else it.on = false; if it.set then it.set(false) end; F.catat(it.nama .. " GAGAL TOTAL") end
end
function F.lepasObj(it)
if it.efekConn then pcall(function() it.efekConn:Disconnect() end); it.efekConn = nil; it.efekHook = nil end
local rs = it.restore; it.restore = nil; if rs then pcall(rs) end
local o = it.obj; it.obj = nil
if o then pcall(function() o:Destroy() end) end
local s = it.src; it.src = nil
if s then pcall(function() s:Destroy() end) end
end
function F.setOn(it, v)
if v and it.premium and not S.premium then F.catat(it.nama .. ": butuh key khusus"); if it.set then it.set(false) end; return end
if v and it.on and it.obj then if it.set then it.set(true) end; return end
it.on = v
if v then task.spawn(F.jalan, it, "pasang", 1)
else
F.lepasObj(it)
if it.kind == "gear" then
F.tasCek(false)
end
F.catat(it.nama .. " dilepas")
end
pcall(F.hairSync); pcall(F.bersihYatim)
if it.id == C.SECRET_ID then pcall(F.secretSync) end
if it.set then it.set(it.on) end
end
local catatanRespawn = nil
me.CharacterRemoving:Connect(function()
catatanRespawn = {kor = S.kor.on == true, kiri = S.kiri.on == true, head = S.headOn == true}
end)
me.CharacterAdded:Connect(function(char)
local catatan = catatanRespawn or {kor = S.kor.on == true, kiri = S.kiri.on == true, head = S.headOn == true}
catatanRespawn = nil
pcall(function() char:WaitForChild("Humanoid", 10); char:WaitForChild("HumanoidRootPart", 10) end)
task.wait(1.5)
if catatan.head and not S.headOn then pcall(F.headSet, true) end
if catatan.kor and not S.kor.on then pcall(F.korSet, true) end
if catatan.kiri and not S.kiri.on then pcall(F.kiriSet, true) end
for _, it in ipairs(S.items) do
if it.on and not it.obj then
task.spawn(F.jalan, it, "respawn", 1)
task.wait(0.2)
end
end
end)
function F.bersihKepala(sumber)
local n = 0
for _, it in ipairs(S.items) do
if it.on and it.id ~= sumber and it.kind == "akses" and it.tipe == Enum.AccessoryType.Hat then F.setOn(it, false); n = n + 1 end
end
if n > 0 then F.catat("aksesoris kepala dilepas: " .. n) end
end
function F.secretSync()
local it = S.byId[C.SECRET_ID]
local nyala = it ~= nil and it.on == true
if nyala and not S.secretCam then
S.secretCam = true
S.secretCamPrev = S.cam.on
if not S.cam.on then F.camSet(true) end
F.catat("Secret Head ON: kamera depan")
elseif not nyala and S.secretCam then
S.secretCam = false
if not S.secretCamPrev and S.cam.on then F.camSet(false) end
S.secretCamPrev = nil
F.catat("Secret Head OFF: kamera & kepala normal")
end
pcall(F.hairSync)
end
function F.addItem(nama, id, kind)
if S.byId[id] then return S.byId[id] end
local it = { nama = nama, id = id, kind = kind or "auto", on = false, obj = nil, src = nil, hapus = 0, busy = false, builtin = false, cfg = F.cfgBaru(), premium = C.PREMIUM[id] == true }
table.insert(S.items, it); S.byId[id] = it
if S.ui.itemAdd then S.ui.itemAdd(it) end
F.pilihRender()
return it
end
function F.terapkanUlang(it)
if not it.on then return end
if it.busy then it.ulang = true; return end
F.lepasObj(it)
task.spawn(F.jalan, it, "terapkan ulang", 1)
end
function F.pilihWajib() if S.pilih then return true end; F.catat("pilih item dulu"); return false end
function F.pilihTeks()
local it = S.pilih
if not it then
if #S.items == 0 then return "belum ada item." end
return "belum pilih item."
end
return "dipilih: " .. it.nama .. (it.on and "" or "  (belum nyala)")
end
function F.pilihKe(it) S.pilih = it; F.pilihRender(); F.segarkanUI(); F.catat("dipilih: " .. it.nama) end
S.favSet = {}
local FAV_FILE = "KRONOZ_favorit.json"
function F.favSimpan()
local daftar = {}
for id, v in pairs(S.favSet) do if v then table.insert(daftar, id) end end
pcall(function() tulis(FAV_FILE, game:GetService("HttpService"):JSONEncode(daftar)) end)
end
function F.favMuat()
local isi = baca(FAV_FILE)
if not isi then return end
pcall(function()
for _, id in ipairs(game:GetService("HttpService"):JSONDecode(isi)) do
local n = tonumber(id); if n then S.favSet[n] = true end
end
end)
end
function F.isFav(it) return it ~= nil and it.id ~= nil and S.favSet[it.id] == true end
function F.favAtur(it, v)
if not it or not it.id then return end
S.favSet[it.id] = v and true or nil
F.favSimpan()
end
F.favMuat()
function F.pilihRender()
for _, w in ipairs(S.ui.pilihWadah or {}) do
if w.Parent then
for _, c in ipairs(w:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
local urut = {}
for _, it in ipairs(F.itemTampil()) do if F.isFav(it) then table.insert(urut, it) end end
for _, it in ipairs(F.itemTampil()) do if not F.isFav(it) then table.insert(urut, it) end end
for i, it in ipairs(urut) do
local dipilih = S.pilih == it
local b = mk("TextButton", {
Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = dipilih and OR or ROW,
Text = "", Font = FM, TextSize = 11,
AutoButtonColor = false, LayoutOrder = i,
}, w)
rnd(b)
if it.id then
local foto = mk("ImageLabel", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 6, 0.5, -15), BackgroundColor3 = BTN, BorderSizePixel = 0, Image = "rbxthumb://type=Asset&id=" .. tostring(it.id) .. "&w=150&h=150", ScaleType = Enum.ScaleType.Fit}, b)
rnd(foto, 7)
end
mk("TextLabel", {Size = UDim2.new(1, -82, 1, 0), Position = UDim2.new(0, 44, 0, 0), BackgroundTransparency = 1, Text = it.nama, TextColor3 = dipilih and BLK or TXT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = true}, b)
if F.isFav(it) then
mk("TextLabel", {Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -34, 0, 0), BackgroundTransparency = 1, Text = "FAV", TextColor3 = dipilih and BLK or OR, Font = FB, TextSize = 9}, b)
end
b.Visible = (not S.ui.pilihCari or S.ui.pilihCari == "" or string.find(string.lower(it.nama), S.ui.pilihCari, 1, true) ~= nil)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.pilihKe(it) end) end)
end
end
end
end
function F.daftarSegar(fn) S.ui.segar = S.ui.segar or {}; table.insert(S.ui.segar, fn) end
function F.segarkanUI()
for _, fn in ipairs(S.ui.segar or {}) do pcall(fn) end
end
function F.efekTarget()
if S.pilih then return {S.pilih} end
local daftar = {}
for _, it in ipairs(S.items) do if it.on and it.obj then table.insert(daftar, it) end end
return daftar
end
function F.nilaiPilih(kunci, fmtFn) local it = S.pilih or F.efekTarget()[1]; if not it then return "-" end; local val = it.cfg[kunci]; if type(val) ~= "number" then val = 1 end; return fmtFn(val) end
function F.efekTerapkan(root, cfg)
if not root or not root.Parent then return end
cfg = cfg or F.cfgBaru()
local rate, size = cfg.rate or 1, cfg.size or 1
local function skalaSeq(seq, k)
local keys = {}
for i, kp in ipairs(seq.Keypoints) do keys[i] = NumberSequenceKeypoint.new(kp.Time, math.min(kp.Value * k, 200), kp.Envelope) end
return NumberSequence.new(keys)
end
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("ParticleEmitter") then
local o = S.emOrig[d]
if not o then o = {rate = d.Rate, size = d.Size}; S.emOrig[d] = o end
d.Rate = math.min(o.rate * rate, 1000)
d.Size = skalaSeq(o.size, size)
elseif d:IsA("Fire") then
local o = S.emOrig[d]
if not o then o = {size = d.Size, heat = d.Heat}; S.emOrig[d] = o end
d.Size = math.clamp(o.size * size, 2, 30)
d.Heat = math.clamp(o.heat * rate, 0, 25)
elseif d:IsA("Smoke") then
local o = S.emOrig[d]
if not o then o = {size = d.Size, opacity = d.Opacity}; S.emOrig[d] = o end
d.Size = math.clamp(o.size * size, 0.1, 100)
d.Opacity = math.clamp(o.opacity * rate, 0, 1)
elseif d:IsA("Trail") then
local o = S.emOrig[d]
if not o then o = {w = d.WidthScale, life = d.Lifetime}; S.emOrig[d] = o end
d.WidthScale = skalaSeq(o.w, size)
d.Lifetime = math.clamp(o.life * rate, 0.05, 20)
elseif d:IsA("Beam") then
local o = S.emOrig[d]
if not o then o = {w0 = d.Width0, w1 = d.Width1}; S.emOrig[d] = o end
d.Width0 = o.w0 * size; d.Width1 = o.w1 * size
elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
local o = S.emOrig[d]
if not o then o = {b = d.Brightness, r = d.Range}; S.emOrig[d] = o end
d.Brightness = math.clamp(o.b * rate, 0, 30)
d.Range = math.clamp(o.r * size, 0, 60)
end
end
end
function F.efekPantau(it)
if not it or not it.obj then return end
local obj = it.obj
if it.efekHook ~= obj then
if it.efekConn then pcall(function() it.efekConn:Disconnect() end) end
it.efekHook = obj
it.efekConn = obj.DescendantAdded:Connect(function()
task.defer(function()
if it.obj == obj and obj.Parent and it.cfg then pcall(F.efekTerapkan, obj, it.cfg) end
end)
end)
end
if S.efekLoopOn then return end
S.efekLoopOn = true
task.spawn(function()
while S.alive and not S.mati do
for _, x in ipairs(S.items) do
if x.on and x.obj and x.obj.Parent and x.cfg and ((x.cfg.rate or 1) ~= 1 or (x.cfg.size or 1) ~= 1) then
pcall(F.efekTerapkan, x.obj, x.cfg)
end
end
task.wait(1.5)
end
S.efekLoopOn = false
end)
end
function F.efekSet(kind, v)
local daftar = F.efekTarget()
if #daftar == 0 then F.notif("Efek", "pilih item atau nyalakan item dulu", 3); return end
for _, it in ipairs(daftar) do
it.cfg[kind] = v
if it.obj then F.efekTerapkan(it.obj, it.cfg); pcall(F.efekPantau, it) end
if S.pilih and not it.on then F.setOn(it, true) end
end
F.catat(string.format("efek %s: %.1fx (%d item)", kind, v, #daftar)); F.segarkanUI()
end
function F.efekGeser(kind, d)
local daftar = F.efekTarget()
if #daftar == 0 then F.notif("Efek", "pilih item atau nyalakan item dulu", 3); return end
local current = daftar[1].cfg[kind] or 1
local nv = math.floor(math.clamp(current + d, 0.5, 8) * 10 + 0.5) / 10
F.efekSet(kind, nv)
end
function F.efekReset()
local daftar = F.efekTarget()
if #daftar == 0 then F.notif("Efek", "pilih item atau nyalakan item dulu", 3); return end
for _, it in ipairs(daftar) do
it.cfg.rate, it.cfg.size = 1, 1
if it.obj then F.efekTerapkan(it.obj, it.cfg) end
end
F.catat("efek direset (" .. #daftar .. " item)"); F.segarkanUI()
end
function F.aplikasiItem(it)
if it.on then F.terapkanUlang(it) else F.setOn(it, true) end
end
function F.itemSet(kunci, v)
if not F.pilihWajib() then return end
local it = S.pilih
local lo, hi = -5, 5
if kunci == "skala" then lo, hi = 0.5, 2 end
it.cfg[kunci] = math.floor(math.clamp(v, lo, hi) * 10 + 0.5) / 10
F.aplikasiItem(it)
end
function F.itemGeser(sumbu, d)
if not F.pilihWajib() then return end
F.itemSet(sumbu, (S.pilih.cfg[sumbu] or 0) + d)
end
function F.itemSkala(d)
if not F.pilihWajib() then return end
F.itemSet("skala", (S.pilih.cfg.skala or 1) + d)
end
function F.itemWarna(col, nama)
if not F.pilihWajib() then return end
local it = S.pilih; it.cfg.warna = col; F.aplikasiItem(it); F.catat(it.nama .. " warna: " .. (nama or "asli"))
end
function F.itemReset()
if not F.pilihWajib() then return end
local it = S.pilih; it.cfg = F.cfgBaru(); F.terapkanUlang(it); F.catat(it.nama .. " reset")
end
function F.cfgResetSemua() for _, it in ipairs(S.items) do it.cfg = F.cfgBaru(); F.terapkanUlang(it) end end
function F.bajuPada(m, kelas, id)
local cls, prop
if kelas == "shirt" then cls, prop = "Shirt", "ShirtTemplate"
elseif kelas == "pants" then cls, prop = "Pants", "PantsTemplate"
elseif kelas == "tshirt" then cls, prop = "ShirtGraphic", "Graphic"
else return nil end
local o = m:FindFirstChildOfClass(cls)
local buat = false; local asli = nil
if o then asli = o[prop]
else o = Instance.new(cls); o.Parent = m; buat = true end
o[prop] = tostring(id)
return {obj = o, prop = prop, asli = asli, buat = buat}
end
function F.bajuTemplate(kelas, id)
local cls, prop = "Shirt", "ShirtTemplate"
if kelas == "pants" then cls, prop = "Pants", "PantsTemplate"
elseif kelas == "tshirt" then cls, prop = "ShirtGraphic", "Graphic" end
local obj = muat(id)
if obj then
local src = obj:IsA(cls) and obj or obj:FindFirstChildWhichIsA(cls, true)
if src then
local ok, v = pcall(function() return src[prop] end)
if ok and type(v) == "string" and v ~= "" then return v end
end
end
return "rbxassetid://" .. tostring(id)
end
function F.bajuSet(kelas, id)
local m = F.target()
if not m then return false end
local tpl = F.bajuTemplate(kelas, id)
local rec = S.baju[kelas]
if rec and rec.obj and rec.obj.Parent == m then rec.obj[rec.prop] = tpl
else S.baju[kelas] = F.bajuPada(m, kelas, tpl) end
S.bajuWant[kelas] = id; F.catat(kelas .. " " .. tostring(id))
return true
end
function F.bajuReset()
for _, rec in pairs(S.baju) do
if rec.obj then
pcall(function() if rec.buat then rec.obj:Destroy() else rec.obj[rec.prop] = rec.asli or "" end end)
end
end
S.baju = {}; S.bajuWant = {}
end
function F.bajuHapus()
local m = F.target(); if not m then return end
if not S.bajuBackup then
local cad = {}
for _, c in ipairs(m:GetChildren()) do if c:IsA("Shirt") or c:IsA("ShirtGraphic") then table.insert(cad, c:Clone()) end end
S.bajuBackup = cad
end
for _, c in ipairs(m:GetChildren()) do if c:IsA("Shirt") or c:IsA("ShirtGraphic") then c:Destroy() end end
S.baju = {}; S.bajuWant.shirt = nil; S.bajuWant.tshirt = nil
F.catat("baju dihapus")
end
function F.bajuGanti(id)
local kelas = "shirt"
local ok, inf = pcall(function() return MPS:GetProductInfo(id) end)
if ok and inf and inf.AssetTypeId == 2 then kelas = "tshirt" end
F.bajuHapus()
F.bajuSet(kelas, id)
end
function F.bajuKembali()
local m = F.target(); if not m then return end
for _, c in ipairs(m:GetChildren()) do if c:IsA("Shirt") or c:IsA("ShirtGraphic") then c:Destroy() end end
for _, c in ipairs(S.bajuBackup or {}) do pcall(function() c.Parent = m end) end
S.bajuBackup = nil; S.baju = {}; S.bajuWant.shirt = nil; S.bajuWant.tshirt = nil
F.catat("baju asli dikembalikan")
end
function F.celanaGanti(id)
local m = F.target(); if not m then return end
local kelas = "pants"
local ok, inf = pcall(function() return MPS:GetProductInfo(id) end)
if ok and inf then local t = inf.AssetTypeId; if t == 11 or t == 2 then kelas = "shirt" end end
if kelas ~= "pants" then return F.bajuGanti(id) end
if not S.celanaBackup then
local cad = {}
for _, c in ipairs(m:GetChildren()) do if c:IsA("Pants") then table.insert(cad, c:Clone()) end end
S.celanaBackup = cad
end
for _, c in ipairs(m:GetChildren()) do if c:IsA("Pants") then c:Destroy() end end
S.baju.pants = nil
F.bajuSet("pants", id)
end
function F.celanaKembali()
local m = F.target(); if not m then return end
for _, c in ipairs(m:GetChildren()) do if c:IsA("Pants") then c:Destroy() end end
for _, c in ipairs(S.celanaBackup or {}) do pcall(function() c.Parent = m end) end
S.celanaBackup = nil; S.baju.pants = nil; S.bajuWant.pants = nil
F.catat("celana asli dikembalikan")
end
function F.uiTerapkan()
local gui = S.ui.gui; if not gui then return end
S.uiOrig = S.uiOrig or {}
local a = S.uiAlpha or 1
local mini = S.ui.mini
for _, d in ipairs(gui:GetDescendants()) do
local lewat = d == mini
if not lewat then
local o = S.uiOrig[d]
if not o then o = {}; S.uiOrig[d] = o end
if d:IsA("GuiObject") then
if o.bg == nil then o.bg = d.BackgroundTransparency end
d.BackgroundTransparency = 1 - (1 - o.bg) * a
end
if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
if o.txt == nil then o.txt = d.TextTransparency end
d.TextTransparency = 1 - (1 - o.txt) * a
elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
if o.img == nil then o.img = d.ImageTransparency end
d.ImageTransparency = 1 - (1 - o.img) * a
elseif d:IsA("UIStroke") then
if o.st == nil then o.st = d.Transparency end
d.Transparency = 1 - (1 - o.st) * a
end
end
end
end
function F.uiAlphaSet(v)
S.uiAlpha = math.floor(math.clamp(v, 0, 1) * 10 + 0.5) / 10
F.uiTerapkan()
end
function F.uiAlphaGeser(d) F.uiAlphaSet((S.uiAlpha or 1) + d) end
function F.skalaTujuan(k) return (S.skala or 1) * (S.ui and S.ui.fit or 1) * (k or 1) end
function F.skalaSet(v)
S.skala = math.floor(math.clamp(v, 0.6, 1.4) * 10 + 0.5) / 10
if S.ui.skalaUI then S.ui.skalaUI.Scale = F.skalaTujuan(1) end
F.catat("besar UI: " .. tostring(math.floor(S.skala * 100 + 0.5)) .. "%")
end
function F.headSet(v)
S.headOn = v
if S.headConn then S.headConn:Disconnect(); S.headConn = nil end
if v then
S.headConn = RS.Heartbeat:Connect(function()
local m = F.target(); local hd = m and m:FindFirstChild("Head")
if hd and hd.Transparency ~= 1 then hd.Transparency = 1 end
F.wajahAksesoris(m, 1)
end)
else
local m = F.target(); local hd = m and m:FindFirstChild("Head"); if hd then hd.Transparency = 0 end
F.wajahAksesoris(m, 0)
end
if v then task.delay(2, function() pcall(F.wajahLog) end) end
pcall(F.wajahSync)
end
function F.wajahCocok(acc)
local tipe = string.lower(tostring(acc.AccessoryType))
for _, kata in ipairs({"face", "mouth", "neck", "eye"}) do
if string.find(tipe, kata, 1, true) then return true end
end
return false
end
function F.wajahAksesoris(m, t)
if not m then return end
for _, acc in ipairs(m:GetChildren()) do
if acc:IsA("Accessory") and F.wajahCocok(acc) then
local h = acc:FindFirstChild("Handle")
if h and h:IsA("BasePart") and h.Transparency ~= t then h.Transparency = t end
end
end
end
function F.wajahLog()
local m = F.target(); if not m then return end
local daftar = {}
for _, acc in ipairs(m:GetChildren()) do
if acc:IsA("Accessory") then
local tipe = (string.gsub(tostring(acc.AccessoryType), "Enum%.AccessoryType%.", ""))
table.insert(daftar, acc.Name .. "(" .. tipe .. (F.wajahCocok(acc) and ", disembunyikan" or ", tampil") .. ")")
end
end
F.catat("headless: aksesoris " .. (#daftar > 0 and table.concat(daftar, ", ") or "tidak ada"))
end
function F.korClearS(st)
if st.conn then st.conn:Disconnect(); st.conn = nil end
for _, o in ipairs(st.objs) do pcall(function() o:Destroy() end) end
st.objs = {}; st.sync = {}
for p, t in pairs(st.hid) do if p.Parent then p.Transparency = t end end
st.hid = {}
end
function F.korLas(tg, c)
local w = Instance.new("WeldConstraint"); w.Part0 = tg; w.Part1 = c; w.Parent = c
end
local function kakiCari(m, sisi)
for _, nm in ipairs({sisi .. " Leg", sisi .. "Leg", sisi .. "UpperLeg"}) do
local p = m:FindFirstChild(nm)
if p and p:IsA("BasePart") then return p end
end
return nil
end
function F.korR15(m, sisi, st)
local obj = muat(sisi == "Left" and C.KOR_KIRI or C.KOR_R15)
if not obj then return false, "asset gagal (id " .. tostring(sisi == "Left" and C.KOR_KIRI or C.KOR_R15) .. ")" end
local n = 0
local off = CFrame.new(S.kor.geserX or 0, S.kor.tinggi, S.kor.geserZ or 0)
for _, nm in ipairs({sisi .. "UpperLeg", sisi .. "LowerLeg", sisi .. "Foot"}) do
local tg = m:FindFirstChild(nm); local src = obj:FindFirstChild(nm, true)
if tg and tg:IsA("MeshPart") and src and src:IsA("MeshPart") then
local terbaik, jarakMin = nil, math.huge
for _, a in ipairs(src:GetChildren()) do
if a:IsA("Attachment") then
local ta = tg:FindFirstChild(a.Name)
if ta and ta:IsA("Attachment") then
local cf = ta.WorldCFrame * off * a.CFrame:Inverse()
local jarak = (cf.Position - tg.Position).Magnitude
if jarak < jarakMin then jarakMin = jarak; terbaik = {a = a, ta = ta} end
end
end
end
if terbaik and jarakMin <= 8 then
local c = src:Clone()
c.Name = "ZenoxKor" .. nm; c.Anchored = false; c.CanCollide = false; c.CanQuery = false; c.CanTouch = false; c.Massless = true
c.CFrame = terbaik.ta.WorldCFrame * off * terbaik.a.CFrame:Inverse()
c.Parent = m
F.korLas(tg, c)
if st.hid[tg] == nil then st.hid[tg] = tg.Transparency end
table.insert(st.objs, c)
n = n + 1
end
end
end
obj:Destroy(); if n == 0 then return false, "gagal" end; return true, sisi .. " R15 " .. n
end
function F.korR6(m, sisi, st)
local tg = kakiCari(m, sisi); if not tg then return false, "kaki " .. sisi .. " tidak ketemu (bagian rig: " .. ringkasNama(m, 14) .. ")" end
local off = CFrame.new(S.kor.geserX or 0, S.kor.tinggi, S.kor.geserZ or 0)
local obj = muat(sisi == "Left" and C.KOR_KIRI or C.KOR_R15); if not obj then return false, "asset gagal (id " .. tostring(sisi == "Left" and C.KOR_KIRI or C.KOR_R15) .. ")" end
local bagian = {}
for _, nm in ipairs({sisi .. "UpperLeg", sisi .. "LowerLeg", sisi .. "Foot"}) do
local p = obj:FindFirstChild(nm, true)
if p and p:IsA("MeshPart") then table.insert(bagian, p) end
end
if #bagian < 3 then obj:Destroy(); return false, "mesh kaki kurang (" .. #bagian .. " dari 3), tidak dipasang supaya tidak terpotong" end
local acuan = bagian[1].CFrame
local lokal, minV, maxV = {}, Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
for i, p in ipairs(bagian) do
local lc = acuan:ToObjectSpace(p.CFrame)
lokal[i] = lc
local h = p.Size / 2
minV = minV:Min(lc.Position - h); maxV = maxV:Max(lc.Position + h)
end
local pusatA = (minV + maxV) / 2
local s = tg.Size.Y / math.max((maxV - minV).Y, 0.01)
local n = 0
for i, p in ipairs(bagian) do
local c = p:Clone()
c.Name = "ZenoxKor" .. p.Name
c.Anchored = true; c.CanCollide = false; c.CanQuery = false; c.CanTouch = false; c.Massless = true
c.Parent = m
pcall(function() game:GetService("ContentProvider"):PreloadAsync({c}) end)
c.Size = p.Size * s
c.CFrame = tg.CFrame * off * CFrame.new((lokal[i].Position - pusatA) * s) * lokal[i].Rotation
c.Anchored = false
F.korLas(tg, c)
table.insert(st.objs, c)
n = n + 1
end
obj:Destroy()
if st.hid[tg] == nil then st.hid[tg] = tg.Transparency end
return true, sisi .. " R6 " .. n .. " bagian"
end
function F.korSepatu(m, sisi, st)
st.bakSepatu = st.bakSepatu or {}
for _, acc in ipairs(m:GetChildren()) do
if acc:IsA("Accessory") and string.find(tostring(acc.AccessoryType), sisi .. "Shoe", 1, true) then
local salinan = acc:Clone()
if salinan then table.insert(st.bakSepatu, salinan) end
acc:Destroy()
end
end
end
function F.korPulihSepatu(st)
local m = F.target()
if m and st.bakM == m then
for _, c in ipairs(st.bakSepatu or {}) do pcall(function() c.Parent = m end) end
end
st.bakSepatu = {}; st.bakM = nil
end
function F.korSetS(st, sisi, v)
local nama = sisi == "Left" and "kiri" or "kanan"
F.korClearS(st); st.on = v
if not v then F.korPulihSepatu(st); F.catat("korblox " .. nama .. " OFF"); return true end
local m = F.target()
if not m then st.on = false; F.catat("korblox " .. nama .. " gagal: karakter/rig belum ketemu"); return false end
if st.bakM ~= m then st.bakSepatu = {}; st.bakM = m end
local ok, info
if m:FindFirstChild(sisi .. "UpperLeg") then ok, info = F.korR15(m, sisi, st) end
if not ok then ok, info = F.korR6(m, sisi, st) end
if not ok then st.on = false; F.catat("korblox " .. nama .. " gagal: " .. tostring(info) .. " | bagian rig: " .. ringkasNama(m, 14)); return false end
F.korSepatu(m, sisi, st)
st.conn = RS.Heartbeat:Connect(function()
for p in pairs(st.hid) do if p.Parent and p.Transparency ~= 1 then p.Transparency = 1 end end
end)
F.catat("korblox " .. nama .. " ON (" .. tostring(info) .. ")")
return true
end
function F.korSet(v) return F.korSetS(S.kor, "Right", v) end
function F.kiriSet(v) return F.korSetS(S.kiri, "Left", v) end
function F.korApplyAll()
if S.kor.on then F.korSetS(S.kor, "Right", true) end
if S.kiri.on then F.korSetS(S.kiri, "Left", true) end
end
function F.korPendAmbil()
S.korPend = S.korPend or {tinggi = S.kor.tinggi or 0, geserX = S.kor.geserX or 0, geserZ = S.kor.geserZ or 0}
return S.korPend
end
function F.korPendGeser(kunci, d)
local p = F.korPendAmbil()
p[kunci] = math.floor(math.clamp((p[kunci] or 0) + d, -1.5, 1.5) * 100 + 0.5) / 100
end
function F.korTinggi(d) F.korPendGeser("tinggi", d) end
function F.korGeser(sumbu, d) F.korPendGeser(sumbu == "x" and "geserX" or "geserZ", d) end
function F.korTerapkan()
local p = F.korPendAmbil()
S.kor.tinggi = p.tinggi; S.kor.geserX = p.geserX; S.kor.geserZ = p.geserZ
F.korApplyAll()
F.catat(string.format("korblox diterapkan: tinggi %.2f, kiri/kanan %.2f, depan/belakang %.2f", p.tinggi, p.geserX, p.geserZ))
end
function F.korReset()
S.korPend = {tinggi = 0, geserX = 0, geserZ = 0}
F.korTerapkan()
end
function F.temaWarna(c, arah)
local h, sat, v = c:ToHSV()
if sat < 0.2 then return c end
if arah == 1 and (h >= 0.9 or h < 0.1) then h = (h + 0.6) % 1
elseif arah == -1 and h >= 0.5 and h <= 0.7 then h = (h - 0.6) % 1 end
return Color3.fromHSV(h, sat, v)
end
function F.temaSeq(seq, arah)
local kp = {}
for _, k in ipairs(seq.Keypoints) do table.insert(kp, ColorSequenceKeypoint.new(k.Time, F.temaWarna(k.Value, arah))) end
return ColorSequence.new(kp)
end
function F.temaSapu(arah)
local gui = S.ui and S.ui.gui; if not gui then return end
for _, d in ipairs(gui:GetDescendants()) do
if d:IsA("UIGradient") then pcall(function() d.Color = F.temaSeq(d.Color, arah) end)
elseif d:IsA("UIStroke") then pcall(function() d.Color = F.temaWarna(d.Color, arah) end)
else
for _, p in ipairs({"BackgroundColor3", "TextColor3", "ImageColor3", "ScrollBarImageColor3"}) do
pcall(function() local v = d[p]; if typeof(v) == "Color3" then d[p] = F.temaWarna(v, arah) end end)
end
end
end
end
function F.temaSet(nama)
local biru = nama == "biru"
F.tema = biru and "biru" or "merah"
F.temaSapu(biru and 1 or -1)
F.autoSimpan()
F.catat("tema: " .. (biru and "biru" or "merah (original)"))
end
function F.autoAmbil()
local akses = {}
for _, it in ipairs(S.items) do if it.on then table.insert(akses, {id = it.id, nama = it.nama, kind = it.kind}) end end
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
return {
autoLoad = S.autoLoad ~= false, tema = F.tema or "merah", items = akses,
kor = S.kor.on == true, kiri = S.kiri.on == true, head = S.headOn == true,
korPos = {tinggi = S.kor.tinggi or 0, geserX = S.kor.geserX or 0, geserZ = S.kor.geserZ or 0},
rig15 = (hum ~= nil and hum.RigType == Enum.HumanoidRigType.R15), r15 = S.r15,
animFav = S.animFav or {}, langit = S.langitOn == true, larp = S.larpAktif or "", autoExec = S.autoExec == true, autoExecKode = S.autoExecKode or F.AUTO_KODE,
}
end
function F.autoSimpan()
local okE, isi = pcall(function() return HS:JSONEncode(F.autoAmbil()) end)
if okE and isi ~= S.autoJejak then S.autoJejak = isi; tulis(C.FILE_AUTO, isi) end
end
function F.autoJalan()
local isi = baca(C.FILE_AUTO)
local d = nil
if isi then local ok, x = pcall(function() return HS:JSONDecode(isi) end); if ok and type(x) == "table" then d = x end end
S.autoLoad = not (d and d.autoLoad == false)
S.autoExec = not (d and d.autoExec == false)
if d then
if type(d.autoExecKode) == "string" and d.autoExecKode ~= "" then S.autoExecKode = d.autoExecKode end
if type(d.animFav) == "table" then S.animFav = d.animFav end
end
if d and d.langit == true then pcall(F.langitSet, true) end
if F.pakSegarSemua then pcall(F.pakSegarSemua) end
F.segarkanUI()
if S.autoExec then F.autoExecAntri() end
task.spawn(F.aman, function()
if d and S.autoLoad then
local t0 = os.clock()
while not F.target() and os.clock() - t0 < 30 do task.wait(0.5) end
task.wait(1.5)
if d.tema == "biru" then pcall(F.temaSet, "biru") end
local presetUlang = nil
if type(d.larp) == "string" and d.larp ~= "" then
for _, lp in ipairs(C.LARP or {}) do if lp.nama == d.larp then presetUlang = lp end end
end
if not presetUlang and d.rig15 and C.LARP and C.LARP[1] then presetUlang = C.LARP[1] end
if presetUlang then pcall(F.larpPasang, presetUlang); task.wait(2.5) end
if d.korPos then S.kor.tinggi = d.korPos.tinggi or 0; S.kor.geserX = d.korPos.geserX or 0; S.kor.geserZ = d.korPos.geserZ or 0; S.korPend = nil end
for _, it in ipairs(d.items or {}) do
local id = tonumber(it.id)
if id then
local x = S.byId[id] or F.addItem(tostring(it.nama or ("ID " .. id)), id, it.kind or "akses")
if not x.on then F.setOn(x, true) end
task.wait(0.2)
end
end
if (d.kor == true) ~= (S.kor.on == true) then pcall(F.korSet, d.kor == true) end
if (d.kiri == true) ~= (S.kiri.on == true) then pcall(F.kiriSet, d.kiri == true) end
if (d.head == true) ~= (S.headOn == true) then pcall(F.headSet, d.head == true) end
if d.rig15 and d.r15 then
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
if hum and hum.RigType == Enum.HumanoidRigType.R15 then S.r15 = d.r15; pcall(F.r15Terapkan) end
end
F.catat("auto load: setup terakhir dipasang")
end
while S.ui.gui and S.ui.gui.Parent do task.wait(2); pcall(F.autoSimpan) end
end)
end
F.AUTO_KODE = 'loadstring(readfile("KRONOZ.lua"))()'
function F.autoExecAntri()
local q = queue_on_teleport or (syn and syn.queue_on_teleport)
if not q then F.catat("auto execute: executor ini tidak punya queue_on_teleport"); return false end
local ok, e = pcall(q, S.autoExecKode or F.AUTO_KODE)
if not ok then F.catat("auto execute gagal: " .. string.sub(tostring(e), 1, 80)); return false end
return true
end
function F.autoExecSet(on)
S.autoExec = on == true
if S.autoExec then F.autoExecAntri() end
F.autoSimpan()
F.catat("auto execute: " .. (S.autoExec and "ON" or "OFF"))
end
function F.camSet(v)
S.cam.on = v
if S.cam.conn then S.cam.conn:Disconnect(); S.cam.conn = nil end
local kam = workspace.CurrentCamera; if not kam then return end
if v then
kam.CameraType = Enum.CameraType.Scriptable
S.cam.conn = RS.RenderStepped:Connect(function()
local m = F.target(); local hd = m and (m:FindFirstChild("Head") or m:FindFirstChild("Torso"))
if not hd then return end
local pos = hd.Position + hd.CFrame.LookVector * S.cam.dist + Vector3.new(0, 0.5, 0)
kam.CFrame = CFrame.lookAt(pos, hd.Position); kam.FieldOfView = S.cam.fov
end)
else
kam.CameraType = Enum.CameraType.Custom; kam.FieldOfView = 70
local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid"); if hum then kam.CameraSubject = hum end
end
end
function F.animCari(m) return m:FindFirstChild("Animate") or (me.Character and me.Character:FindFirstChild("Animate")) end
F.animCache = {}
function F.animId(id)
if F.animCache[id] then return F.animCache[id] end
local hasil = "rbxassetid://" .. tostring(id)
local o = muat(id)
if o then
local a = o:IsA("Animation") and o or o:FindFirstChildWhichIsA("Animation", true)
local aid = a and a.AnimationId or ""; o:Destroy(); if aid ~= "" then hasil = aid end
end
F.animCache[id] = hasil
return hasil
end
function F.animSet(m, slot, id)
local an = F.animCari(m); local inf = C.SLOT[slot]
if not an or not inf then return false end
local fd = an:FindFirstChild(inf[1]); if not fd then return false end
local aid = F.animId(id); local n = 0
for _, nm in ipairs(inf[2]) do
local nd = fd:FindFirstChild(nm)
if nd and nd:IsA("Animation") then
local k = slot .. "/" .. nm
if S.anim.orig[k] == nil then S.anim.orig[k] = nd.AnimationId end
nd.AnimationId = aid; n = n + 1
end
end
return n > 0
end
function F.animMuat(m)
local hum = m:FindFirstChildOfClass("Humanoid") or (me.Character and me.Character:FindFirstChildOfClass("Humanoid"))
if hum then pcall(function() for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end) end
local an = F.animCari(m); if not an or not an:IsA("LocalScript") then return end
local induk = an.Parent; local b = an:Clone(); an:Destroy(); task.wait(); b.Parent = induk
end
function F.animTerapkan(m, peta)
local n = 0
for slot, id in pairs(peta) do if F.animSet(m, slot, id) then n = n + 1 end end
if n > 0 then F.animMuat(m) end; return n
end
function F.animZombie() local m = F.target(); if not m then return end; S.anim.want = {kind = "zombie"}; F.animTerapkan(m, C.ZOMBIE_R15) end
function F.animBundle(id, label)
local m = F.target(); if not m then F.catat("pack: karakter belum siap"); return 0 end
local data, why = F.httpCoba("https://catalog.roblox.com/v1/bundles/" .. tostring(id) .. "/details")
if not data then F.catat("pack " .. tostring(label) .. " gagal diambil: " .. tostring(why)); return 0 end
local peta = {}
for _, it in ipairs(data.items or {}) do
if it.type == nil or it.type == "Asset" then
local t = tonumber(it.assetType) or F.pakTipe(it.id)
if t and C.ATYPE[t] then peta[C.ATYPE[t]] = it.id end
end
end
local n = F.animTerapkan(m, peta)
if n == 0 then F.catat("pack " .. tostring(label) .. ": tidak ada animasi R15 yang bisa dipasang"); return 0 end
S.anim.want = {bundle = id, label = label}
F.catat("pack dipasang: " .. tostring(label) .. " (" .. n .. " animasi)")
return n
end
function F.animCustom(slot, id) local m = F.target(); if not m or not C.SLOT[slot] then return end; S.anim.custom[slot] = id; F.animTerapkan(m, {[slot] = id}) end
function F.animUlang(m)
local w = S.anim.want
if w then
if w.kind == "zombie" then F.animZombie() elseif w.bundle then F.animBundle(w.bundle, w.label) end
end
if next(S.anim.custom) ~= nil and m then F.animTerapkan(m, S.anim.custom) end
end
function F.animReset()
local m = F.target(); local an = m and F.animCari(m)
if an then
for k, aid in pairs(S.anim.orig) do
local slot, nm = string.match(k, "^(%w+)/(%w+)$"); local inf = slot and C.SLOT[slot]
local fd = inf and an:FindFirstChild(inf[1]); local nd = fd and fd:FindFirstChild(nm)
if nd and nd:IsA("Animation") then nd.AnimationId = aid end
end
end
S.anim.orig = {}; S.anim.want = nil; S.anim.custom = {}; if m then F.animMuat(m) end
end
function F.emoteStop(alasan)
if S.emote.conn then S.emote.conn:Disconnect(); S.emote.conn = nil end
local tr, an, nama = S.emote.track, S.emote.anim, S.emote.nama
S.emote.track, S.emote.anim, S.emote.nama = nil, nil, ""; S.emote.id = nil
if tr then pcall(function() tr:Stop(0.2) end) end
end
function F.emotePlay(nama, id)
F.emoteStop()
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
if not hum and me.Character then hum = me.Character:FindFirstChildOfClass("Humanoid") end
if not hum then F.catat("emote: karakter belum siap"); return end
local animator = hum:FindFirstChildOfClass("Animator") or mk("Animator", {}, hum)
S.animCache = S.animCache or {}
local anim = S.animCache[tostring(id)]
if not anim then anim = Instance.new("Animation"); anim.AnimationId = F.animId(id); S.animCache[tostring(id)] = anim end
local okL, track = pcall(function() return animator:LoadAnimation(anim) end)
if not okL or not track then F.catat("emote gagal dimuat: " .. tostring(nama) .. " (belum dimiliki / tidak publik / R6?)"); return end
track.Priority = Enum.AnimationPriority.Action; track.Looped = true; track:Play()
S.emote.track = track; S.emote.anim = anim; S.emote.nama = nama; S.emote.id = id
S.emote.conn = RS.Heartbeat:Connect(function() if hum.Parent == nil or hum.MoveDirection.Magnitude > 0.1 then F.emoteStop() end end)
end
function F.emoteCari(teks)
local q = trim(teks); if #q < 2 then F.catat("emote: isi nama emote dulu"); return end
local d = F.cari(q)
if not d or not d.data or #d.data == 0 then F.catat("emote: tidak ketemu di katalog: " .. q); return end
local pilih, lq = d.data[1], string.lower(q)
for _, it in ipairs(d.data) do if string.find(string.lower(tostring(it.name or "")), lq, 1, true) then pilih = it; break end end
F.catat("emote: pasang " .. tostring(pilih.name) .. " (" .. tostring(pilih.id) .. ")")
F.emotePlay(tostring(pilih.name), tonumber(pilih.id))
end
function F.cari(teks)
local q = trim(teks); if #q < 2 then return nil end
return httpJson("https://catalog.roblox.com/v1/search/items?keyword=" .. HS:UrlEncode(q) .. "&limit=10")
end
function F.cariTampil(teks, wadah)
for _, c in ipairs(wadah:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
local d = F.cari(teks); if not d or not d.data then return end
for i, it in ipairs(d.data) do
local b = mk("TextButton", {
Size = UDim2.new(1, -4, 0, 28), BackgroundColor3 = ROW, TextColor3 = TXT, Font = FM, TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
Text = "  " .. tostring(it.name or "?") .. " [" .. tostring(it.itemType) .. "]", LayoutOrder = i,
}, wadah)
rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.pasangId(it.id) end) end)
end
end
S.body = S.body or {objs = {}, hid = {}, conn = nil}
F.BODY_PART = {[17] = "Head", [27] = "Torso", [28] = "Right Arm", [29] = "Left Arm", [30] = "Left Leg", [31] = "Right Leg"}
function F.bodyClear()
local b = S.body or {objs = {}, hid = {}}
if b.conn then b.conn:Disconnect(); b.conn = nil end
for _, o in ipairs(b.objs) do pcall(function() o:Destroy() end) end
for p, t in pairs(b.hid) do
if p.Parent and not (S.kor.hid[p] ~= nil or S.kiri.hid[p] ~= nil) then p.Transparency = t end
end
for p, c in pairs(b.col or {}) do if p.Parent then pcall(function() p.Color = c end) end end
S.body = {objs = {}, hid = {}, conn = nil}
end
function F.bagianAsset(obj)
local mp = obj:FindFirstChildWhichIsA("MeshPart", true)
if mp then return mp:Clone() end
local bp = obj:FindFirstChildWhichIsA("BasePart", true)
if not bp then return nil end
local p = Instance.new("Part"); p.Size = bp.Size; p.Color = bp.Color
local sm = bp:FindFirstChildWhichIsA("SpecialMesh", true)
if sm then sm:Clone().Parent = p end
return p
end
F.PETA_R15 = {
["Head"] = {"Head"},
["Torso"] = {"UpperTorso", "LowerTorso"},
["Right Arm"] = {"RightUpperArm", "RightLowerArm", "RightHand"},
["Left Arm"] = {"LeftUpperArm", "LeftLowerArm", "LeftHand"},
["Right Leg"] = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
["Left Leg"] = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
}
function F.rigTipe(m)
if not m then return nil end
if m:FindFirstChild("Torso") and m:FindFirstChild("Right Leg") then return "R6" end
if m:FindFirstChild("UpperTorso") and m:FindFirstChild("RightUpperLeg") then return "R15" end
return nil
end
function F.bodyGrup(m, tipe, nama)
if tipe == "R6" then
local tg = m:FindFirstChild(nama)
return (tg and tg:IsA("BasePart")) and {tg} or nil
end
local daftarNama = F.PETA_R15[nama]; if not daftarNama then return nil end
local grup = {}
for _, nm in ipairs(daftarNama) do
local p = m:FindFirstChild(nm)
if not (p and p:IsA("BasePart")) then return nil end
table.insert(grup, p)
end
return grup
end
function F.bungkus(grup)
local u = grup[1].CFrame
local minV, maxV = nil, nil
for _, p in ipairs(grup) do
local hs = p.Size / 2
for _, sx in ipairs({-1, 1}) do for _, sy in ipairs({-1, 1}) do for _, sz in ipairs({-1, 1}) do
local titik = u:PointToObjectSpace(p.CFrame * Vector3.new(sx * hs.X, sy * hs.Y, sz * hs.Z))
if minV then minV = minV:Min(titik); maxV = maxV:Max(titik) else minV = titik; maxV = titik end
end end end
end
return u * CFrame.new(0, (minV.Y + maxV.Y) / 2, 0), maxV - minV
end
local UKURAN_R6 = {["Torso"] = {2, 1}, ["Right Arm"] = {1, 1}, ["Left Arm"] = {1, 1}, ["Right Leg"] = {1, 1}, ["Left Leg"] = {1, 1}}
local cacheBagian = {}
local function muatBagian(id)
local k = tostring(id)
if cacheBagian[k] then
local ok, salin = pcall(function() return cacheBagian[k]:Clone() end)
if ok and salin then return salin end
end
local ok, lst = pcall(function() return game:GetObjects("rbxassetid://" .. k) end)
local hasil = nil
if ok and lst then
for _, o in ipairs(lst) do
if o:IsA("BasePart") or o:FindFirstChildWhichIsA("BasePart", true) then hasil = o; break end
end
for _, o in ipairs(lst) do if o ~= hasil then pcall(function() o:Destroy() end) end end
end
if not hasil then
local ok2, o2 = pcall(function() return IS:LoadAsset(tonumber(id)) end)
if ok2 and o2 then
if o2:IsA("BasePart") or o2:FindFirstChildWhichIsA("BasePart", true) then hasil = o2
else pcall(function() o2:Destroy() end) end
end
end
if not hasil then return nil end
cacheBagian[k] = hasil
local ok3, salin = pcall(function() return hasil:Clone() end)
return (ok3 and salin) or nil
end
function F.bodyApply(daftar, warna)
F.bodyClear()
local m = F.target()
local tipe = F.rigTipe(m)
if not tipe then
S.bodyOn = false; F.catat("body: rig tidak dikenali (bukan R6/R15)"); return false
end
local n = 0
for _, bp in ipairs(daftar) do
local grup = F.bodyGrup(m, tipe, bp.nama)
local obj = muatBagian(bp.id)
local c = obj and F.bagianAsset(obj)
if obj then pcall(function() obj:Destroy() end) end
if grup and c then
local utama = grup[1]
local asli = c.Size
local cf, sz = utama.CFrame, utama.Size
if #grup > 1 then
local span
cf, span = F.bungkus(grup)
local std = UKURAN_R6[bp.nama] or {asli.X, asli.Z}
sz = (tipe == "R15") and span or Vector3.new(std[1], span.Y, std[2])
end
local attA, attT = c:FindFirstChild("FaceCenterAttachment"), utama:FindFirstChild("FaceCenterAttachment")
if bp.nama == "Head" and attA and attT then
cf = attT.WorldCFrame * attA.CFrame:Inverse()
sz = asli
end
c.Name = "ZenoxBody" .. bp.nama
c.Anchored = true; c.CanCollide = false; c.CanQuery = false; c.CanTouch = false; c.Massless = true
c.CFrame = cf; c.Parent = m
pcall(function() game:GetService("ContentProvider"):PreloadAsync({c}) end)
c.Size = sz; c.CFrame = cf
if warna then pcall(function() c.TextureID = "" end); c.Color = warna end
c.Anchored = false
F.korLas(utama, c)
for _, tg in ipairs(grup) do
if S.body.hid[tg] == nil then S.body.hid[tg] = tg.Transparency end
tg.Transparency = 1
end
table.insert(S.body.objs, c)
F.catat(string.format("body: %s mesh %.2f x %.2f x %.2f", bp.nama, asli.X, asli.Y, asli.Z))
n = n + 1
else
if not grup then F.catat("body: " .. bp.nama .. " tidak ada padanan di rig " .. tipe)
elseif not obj and bp.nama == "Head" then F.catat("body: kepala dynamic ID " .. tostring(bp.id) .. " tidak bisa dimuat di executor ini, kepala asli dipertahankan")
elseif not obj then F.catat("body: " .. bp.nama .. " gagal dimuat (ID " .. tostring(bp.id) .. ")")
else F.catat("body: " .. bp.nama .. " tidak ada mesh di asset") end
end
end
if warna then
for _, nm in ipairs({"Head", "Torso", "UpperTorso", "LowerTorso", "Left Arm", "Right Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "Left Leg", "Right Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
local p = m:FindFirstChild(nm)
if p and p:IsA("BasePart") and not S.body.hid[p] then
S.body.col = S.body.col or {}
if S.body.col[p] == nil then S.body.col[p] = p.Color end
pcall(function() p.Color = warna end)
end
end
end
if n == 0 then S.bodyOn = false; F.bodyClear(); F.catat("body: tidak ada bagian terpasang"); return false end
S.bodyDaftar = daftar; S.bodyWarna = warna; S.bodyOn = true
S.body.conn = RS.Heartbeat:Connect(function()
for p in pairs(S.body.hid) do if p.Parent and p.Transparency ~= 1 then p.Transparency = 1 end end
end)
F.catat("body ON (" .. tipe .. "): " .. n .. " bagian")
return true
end
function F.bodyBundle(id)
local data = httpJson("https://catalog.roblox.com/v1/bundles/" .. tostring(id) .. "/details")
if not data or type(data.items) ~= "table" then return nil end
local daftar = {}
for _, it in ipairs(data.items) do
local nama = it.type == "Asset" and F.BODY_PART[tonumber(it.assetType)]
if nama then table.insert(daftar, {id = it.id, nama = nama}) end
end
return daftar
end
function F.bodyTambah(id, nama)
local daftar = {}
for _, bp in ipairs(S.bodyDaftar or {}) do if bp.nama ~= nama then table.insert(daftar, bp) end end
table.insert(daftar, {id = id, nama = nama})
return F.bodyApply(daftar, S.bodyWarna)
end
function F.bodySet(v, bundleId)
if not v then F.bodyClear(); S.bodyOn = false; F.catat("body OFF"); return true end
local daftar = F.bodyBundle(bundleId)
if not daftar then S.bodyOn = false; F.catat("body: katalog bundle tidak bisa dibaca"); return false end
local warna = (tonumber(bundleId) ~= 261702574320055) and Color3.fromRGB(163, 162, 165) or nil
return F.bodyApply(daftar, warna)
end
function F.bundleApply(id, data)
local n = 0; local peta = {}
for _, it in ipairs(data.items or {}) do
if it.type == "Asset" then
local t = tonumber(it.assetType)
if t and C.ATYPE[t] then peta[C.ATYPE[t]] = it.id
elseif t == 11 then F.bajuSet("shirt", it.id); n = n + 1
elseif t == 12 then F.bajuSet("pants", it.id); n = n + 1
elseif t == 2 then F.bajuSet("tshirt", it.id); n = n + 1
elseif t and F.BODY_PART[t] then F.bodyTambah(it.id, F.BODY_PART[t]); n = n + 1
elseif t == 19 then F.setOn(F.addItem(tostring(it.name), it.id, "gear"), true); n = n + 1
elseif t == 18 then F.setOn(F.addItem(tostring(it.name), it.id, "auto"), true); n = n + 1
elseif t and C.ACC_TYPE[t] then F.setOn(F.addItem(tostring(it.name), it.id, "akses"), true); n = n + 1 end
end
end
F.catat("bundle " .. tostring(id) .. " dibaca: " .. n .. " item"); local na = 0; local m = F.target(); if m and next(peta) ~= nil then na = F.animTerapkan(m, peta) end
end
function F.pasangId(id)
local ok, inf = pcall(function() return MPS:GetProductInfo(id) end)
if not ok or not inf then F.catat("ID " .. tostring(id) .. ": info tidak bisa dibaca"); return end
local t = inf.AssetTypeId
if t == 18 or (t and C.ACC_TYPE[t]) then
local it = S.byId[id] or F.addItem(inf.Name, id, t == 18 and "wajah" or "akses")
if t == 18 then it.kind = "wajah" end
F.setOn(it, true); return
end
F.catat("ID " .. tostring(id) .. " (" .. tostring(inf.Name) .. "): bukan aksesoris, tidak didukung")
end
function F.cariUser(teks)
local nama = trim(teks); if #nama < 3 then return nil, "minimal 3 huruf" end
local s = httpJson("https://users.roblox.com/v1/users/search?keyword=" .. HS:UrlEncode(nama) .. "&limit=10")
if not s then return nil, "gagal" end
for _, u in ipairs(s.data or {}) do if string.lower(tostring(u.name or "")) == string.lower(nama) then return u end end
return nil, "tidak ketemu"
end
function F.avaDaftar(userId)
local av = httpJson("https://avatar.roblox.com/v1/users/" .. tostring(userId) .. "/avatar")
if not av or type(av.assets) ~= "table" then return nil end
local out, shirt, pants = {}, nil, nil
for _, a in ipairs(av.assets) do
local t = a.assetType; if type(t) == "table" then t = t.id end; t = tonumber(t)
local id = tonumber(a.id)
if id and t then
if t == 11 then shirt = id elseif t == 12 then pants = id elseif C.ACC_TYPE[t] then table.insert(out, {id = id, nama = tostring(a.name or id), kind = "akses"}) end
end
end
return out, shirt, pants
end
function F.pakaiSet(daftar, label)
for _, it in ipairs(S.items) do if it.on then F.setOn(it, false) end end
task.wait(S.gantiJeda); local n = 0
for _, d in ipairs(daftar) do
local it = S.byId[d.id] or F.addItem(d.nama, d.id, d.kind or "akses")
F.setOn(it, true); n = n + 1; task.wait(S.gantiJeda)
end
end
function F.avaDariDesc(userId)
local out, shirt, pants = {}, nil, nil
local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
if not ok or not desc then return out, nil, nil end
local okA, acc = pcall(function() return desc:GetAccessories(true) end)
if okA and type(acc) == "table" then
for _, a in ipairs(acc) do
local id = tonumber(a.AssetId)
if id and id > 0 then table.insert(out, {id = id, nama = "ID " .. tostring(id), kind = "akses"}) end
end
end
if (desc.Shirt or 0) > 0 then shirt = desc.Shirt end
if (desc.Pants or 0) > 0 then pants = desc.Pants end
if (desc.Face or 0) > 0 then table.insert(out, {id = desc.Face, nama = "Face " .. tostring(desc.Face), kind = "auto"}) end
return out, shirt, pants
end
function F.custApply(teks)
local daftar = {}
for angka in string.gmatch(tostring(teks or ""), "%d+") do local n = tonumber(angka); if n and n > 0 then table.insert(daftar, n) end end
if #daftar == 0 then F.catat("isi ID dulu (angka)"); return end
for _, id in ipairs(daftar) do F.pasangId(id); task.wait(0.3) end
end
function F.bajuUser()
local c = me.Character
local hum = c and c:FindFirstChildOfClass("Humanoid")
local ok, desc = false, nil
if hum then ok, desc = pcall(function() return hum:GetAppliedDescription() end) end
if not ok or not desc then ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(me.UserId) end) end
if not ok or not desc then return nil, nil end
local sh = ((desc.Shirt or 0) > 0) and desc.Shirt or nil
local pt = ((desc.Pants or 0) > 0) and desc.Pants or nil
return sh, pt
end
function F.gantiSet(v) S.gantiJeda = math.floor(math.clamp(v, 0.1, 3) * 10 + 0.5) / 10 end
function F.outfitApply(outfitId, label)
label = label or "outfit"
if not outfitId or outfitId == 0 then F.catat(label .. ": outfitId belum diisi di kode"); return false end
local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromOutfitId(outfitId) end)
if not ok or not desc then F.catat(label .. ": outfit tidak bisa dibaca"); return false end
local daftar = {}
local okA, acc = pcall(function() return desc:GetAccessories(true) end)
if okA and type(acc) == "table" then
for _, a in ipairs(acc) do
local id = tonumber(a.AssetId)
if id and id > 0 then table.insert(daftar, {id = id, nama = "ID " .. tostring(id), kind = "akses"}) end
end
end
if (desc.Shirt or 0) > 0 then F.bajuSet("shirt", desc.Shirt) end
if (desc.Pants or 0) > 0 then F.bajuSet("pants", desc.Pants) end
F.pakaiSet(daftar, label)
F.catat(label .. " dipasang: " .. #daftar .. " item")
return true
end
local LARP_ACC = {[8]="Hat",[41]="Hair",[42]="Face",[43]="Neck",[44]="Shoulder",[45]="Front",[46]="Back",[47]="Waist",[57]="TShirt",[58]="Shirt",[59]="Pants",[64]="Jacket",[65]="Sweater",[66]="Shorts",[67]="LeftShoe",[68]="RightShoe",[69]="DressSkirt"}
local LARP_LAYER = {TShirt=true, Shirt=true, Pants=true, Jacket=true, Sweater=true, Shorts=true, LeftShoe=true, RightShoe=true, DressSkirt=true}
local LARP_SLOT = {Hat="HatAccessory", Hair="HairAccessory", Face="FaceAccessory", Neck="NeckAccessory", Shoulder="ShouldersAccessory", Front="FrontAccessory", Back="BackAccessory", Waist="WaistAccessory"}
local LARP_BP = {[17]="Head", [27]="Torso", [28]="RightArm", [29]="LeftArm", [30]="LeftLeg", [31]="RightLeg"}
local LARP_BP_NAMA = {["Head"]="Head", ["Torso"]="Torso", ["Right Arm"]="RightArm", ["Left Arm"]="LeftArm", ["Left Leg"]="LeftLeg", ["Right Leg"]="RightLeg"}
local function larpSetAcc(d, acc, accNama)
local berlapis = {}
for _, a in ipairs(acc) do if a.IsLayered then table.insert(berlapis, a) end end
local okSet = pcall(function() d:SetAccessories(berlapis, true) end)
if not okSet then okSet = pcall(function() d:SetAccessories(berlapis) end) end
local isiSlot = {}
for _, slot in pairs(LARP_SLOT) do isiSlot[slot] = {} end
for i, a in ipairs(acc) do
if not a.IsLayered then
local slot = LARP_SLOT[accNama[i]]
if slot then table.insert(isiSlot[slot], tostring(a.AssetId)) end
end
end
local berlapisTipe = {}
for _, a in ipairs(acc) do if a.IsLayered and a.AccessoryType then berlapisTipe[a.AccessoryType.Name] = true end end
for tipe, slot in pairs(LARP_SLOT) do
if #isiSlot[slot] > 0 or not berlapisTipe[tipe] then
pcall(function() d[slot] = table.concat(isiSlot[slot], ",") end)
end
end
local okG, ada = pcall(function() return d:GetAccessories(true) end)
if okG and type(ada) == "table" then
local dapat, kurang = {}, 0
for _, x in ipairs(ada) do dapat[x.AssetId] = true end
for _, a in ipairs(berlapis) do if not dapat[a.AssetId] then kurang = kurang + 1 end end
if kurang > 0 then F.catat("larp: " .. kurang .. " aksesoris berlapis tidak masuk deskripsi") end
end
return okSet
end
local function larpDasar()
local m = F.target()
local hum = m and m:FindFirstChildOfClass("Humanoid")
local okB, base = false, nil
if hum then okB, base = pcall(function() return hum:GetAppliedDescription() end) end
return (okB and base) or Instance.new("HumanoidDescription")
end
function F.larpExact(lp)
local d = larpDasar()
d.Shirt = lp.shirt or 0; d.Pants = lp.pants or 0; d.GraphicTShirt = lp.tshirt or 0
if lp.face ~= nil then d.Face = lp.face end
for k, v in pairs(lp.part or {}) do d[k] = v end
for k, v in pairs(lp.kulit or {}) do d[k] = v end
for k, v in pairs(lp.skala or {}) do d[k] = v end
local acc, accNama = {}, {}
for _, a in ipairs(lp.acc or {}) do
local okT, tipe = pcall(function() return Enum.AccessoryType[a[2]] end)
if okT and tipe then
table.insert(acc, {AssetId = a[1], AccessoryType = tipe, IsLayered = a[3] == true, Order = a[4] or 0, Puffiness = 1})
table.insert(accNama, a[2])
end
end
local okSet = larpSetAcc(d, acc, accNama)
return d, {}, okSet
end
function F.larpDesc(entri)
local d = larpDasar()
d.Shirt = 0; d.Pants = 0; d.GraphicTShirt = 0
local acc, accNama, gagal = {}, {}, {}
for _, e in ipairs(entri) do
local id = tonumber(e.id)
if id and id > 0 then
local okI, inf = pcall(function() return MPS:GetProductInfo(id) end)
local t = (okI and inf) and tonumber(inf.AssetTypeId) or nil
local bagian = e.bagian and LARP_BP_NAMA[e.bagian] or nil
if t == 11 then d.Shirt = id
elseif t == 12 then d.Pants = id
elseif t == 2 then d.GraphicTShirt = id
elseif t == 18 then d.Face = id
elseif t and LARP_BP[t] then d[LARP_BP[t]] = id
elseif t == nil and bagian then d[bagian] = id
elseif t and LARP_ACC[t] then
local nm = LARP_ACC[t]
table.insert(acc, {AssetId = id, AccessoryType = Enum.AccessoryType[nm], IsLayered = LARP_LAYER[nm] == true, Order = #acc + 1, Puffiness = 1})
table.insert(accNama, nm)
else
table.insert(gagal, tostring(id))
end
end
end
local okSet = larpSetAcc(d, acc, accNama)
return d, gagal, okSet
end
function F.larpPasang(lp)
if F.larpGirl(lp) and not F.izin("larpGirl") then F.kunci("larpGirl"); return end
if lp.maint then F.catat(lp.nama .. " lagi maintenance"); return end
if lp.outfit then F.outfitApply(lp.outfit, lp.nama); return end
if not F.target() then F.catat(lp.nama .. ": karakter belum siap"); return end
if S.headOn then F.headSet(false) end
if S.kor.on then F.korSet(false) end
if S.kiri.on then F.kiriSet(false) end
for _, it in ipairs(S.items) do if it.on then F.setOn(it, false) end end
if S.bodyOn then pcall(F.bodySet, false); S.bodyId = nil end
local d, gagal, okSet
if lp.acc then
d, gagal, okSet = F.larpExact(lp)
else
local entri = {}
for _, id in ipairs(lp.items or {}) do table.insert(entri, {id = id}) end
if lp.shirt then table.insert(entri, {id = lp.shirt}) end
if lp.pants then table.insert(entri, {id = lp.pants}) end
if lp.tshirt then table.insert(entri, {id = lp.tshirt}) end
if lp.body and not lp.keepBody then
for _, bp in ipairs(lp.body) do table.insert(entri, {id = bp.id, bagian = bp.nama}) end
end
if lp.bundle and not lp.keepBody then
for _, bp in ipairs(F.bodyBundle(lp.bundle) or {}) do table.insert(entri, {id = bp.id, bagian = bp.nama}) end
end
d, gagal, okSet = F.larpDesc(entri)
end
if lp.rig == "R15" then S.r15 = nil end
local ok, info = F.cloneApply(d, lp.rig)
if not ok then F.catat(lp.nama .. " gagal: " .. tostring(info)); return end
local mm = F.target(); local nAcc, namaAcc = 0, {}
if mm then for _, c in ipairs(mm:GetChildren()) do if c:IsA("Accessory") then nAcc = nAcc + 1; table.insert(namaAcc, c.Name) end end end
F.catat(lp.nama .. ": aksesoris di karakter " .. nAcc .. (nAcc > 0 and (" -> " .. table.concat(namaAcc, ", ")) or ""))
for _, g in ipairs(gagal or {}) do F.catat(lp.nama .. ": ID " .. g .. " dilewati (bukan aksesoris/bagian)") end
if not okSet then F.catat(lp.nama .. ": SetAccessories tidak tersedia, pakai cadangan") end
S.larpAktif = lp.nama
F.catat(lp.nama .. " dipasang")
if lp.headless then F.headSet(true) end
if lp.korKanan then F.korSet(true) end
F.rambutSet(lp.rambut == true)
if lp.anim then local mm = F.target(); if mm then F.animTerapkan(mm, lp.anim) end end
end
function F.adaHairItem()
for _, it in ipairs(S.items) do if it.on and (C.RAMBUT_GANTI[it.id] or (it.id == C.SECRET_ID and it.obj ~= nil)) then return true end end
return false
end
function F.hairSync()
if S.rambutOn or F.adaHairItem() then pcall(F.rambutTerapkan)
elseif next(S.rambutOrig) ~= nil then
for p, t in pairs(S.rambutOrig) do if p.Parent then p.Transparency = t end end
S.rambutOrig = {}
end
end
function F.rambutTerapkan()
local m = F.target(); if not m then return end
for _, acc in ipairs(m:GetChildren()) do
if acc:IsA("Accessory") and acc.AccessoryType == Enum.AccessoryType.Hair then
for _, d in ipairs(acc:GetDescendants()) do
if d:IsA("BasePart") then
if S.rambutOrig[d] == nil then S.rambutOrig[d] = d.Transparency end
d.Transparency = 1
end
end
end
end
end
C.GIRL_HAIR = {118056103257844}
function F.girlHairOn()
local it = S.byId[C.GIRL_HAIR[1]]
return it ~= nil and it.on == true
end
function F.girlHairSet(v)
for i, id in ipairs(C.GIRL_HAIR) do
local it = S.byId[id]
if not it then
it = {nama = i == 1 and "girl hair: rambut" or ("girl hair: layer " .. tostring(i - 1)), id = id, kind = "akses", on = false, obj = nil, src = nil, hapus = 0, busy = false, builtin = false, cfg = F.cfgBaru(), premium = false, senyap = true}
table.insert(S.items, it); S.byId[id] = it
end
if (it.on == true) ~= (v == true) then F.setOn(it, v == true) end
end
F.catat("girl hair " .. (v and "ON" or "OFF"))
end
function F.itemTampil()
local daftar = {}
for _, it in ipairs(S.items) do if not it.senyap then table.insert(daftar, it) end end
return daftar
end
function F.rambutSet(v)
S.rambutOn = v and true or false
F.hairSync()
F.catat("hapus rambut " .. (S.rambutOn and "ON" or "OFF"))
end
S.tiru = S.tiru or {on = false, asli = {}, snap = {}, lastCh = {}, sigOf = {}}
F.tiruBagian = {Head = true, UpperTorso = true, LowerTorso = true, LeftUpperArm = true, LeftLowerArm = true, LeftHand = true, RightUpperArm = true, RightLowerArm = true, RightHand = true, LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true, RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
function F.tiruSig()
local ku = me.Character; if not ku then return "" end
local parts = {}
for _, a in ipairs(ku:GetChildren()) do
if a:IsA("Accessory") then
local h = a:FindFirstChild("Handle")
local mid = (h and h:IsA("MeshPart")) and h.MeshId or ""
table.insert(parts, a.Name .. "|" .. tostring(a.AccessoryType) .. "|" .. tostring(mid))
end
end
for _, cls in ipairs({"Shirt", "Pants"}) do
local x = ku:FindFirstChildOfClass(cls)
if x then table.insert(parts, cls .. "|" .. tostring((cls == "Shirt") and x.ShirtTemplate or x.PantsTemplate)) end
end
for _, d in ipairs(ku:GetDescendants()) do
if d:IsA("BasePart") and not F.tiruBagian[d.Name] and d.Transparency < 1 then
table.insert(parts, d.Name .. "|" .. tostring(d:IsA("MeshPart") and d.MeshId or ""))
end
end
local kh = ku:FindFirstChild("Head"); local kf = kh and kh:FindFirstChildOfClass("Decal")
if kf then table.insert(parts, "face|" .. tostring(kf.Texture)) end
return table.concat(parts, ";")
end
function F.tiruSalin(karakter, sumber)
local ku = sumber or me.Character
if not (ku and karakter) then return false end
if not (ku:FindFirstChild("UpperTorso") and karakter:FindFirstChild("UpperTorso")) then return "rig" end
S.tiru.asli[karakter] = S.tiru.asli[karakter] or {}
local simpan = S.tiru.asli[karakter]
local bA = ku:FindFirstChildOfClass("BodyColors")
local bB = karakter:FindFirstChildOfClass("BodyColors")
if bA and bB then
simpan.warna = simpan.warna or {}
for _, p in ipairs({"HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3"}) do
if simpan.warna[p] == nil then simpan.warna[p] = bB[p] end
pcall(function() bB[p] = bA[p] end)
end
end
for _, a in ipairs(karakter:GetChildren()) do
if a:GetAttribute("ZenoxTiru") then
a:Destroy()
elseif a:IsA("Accessory") or a:IsA("Shirt") or a:IsA("Pants") or a:IsA("ShirtGraphic") then
table.insert(simpan, a:Clone())
a:Destroy()
end
end
for _, cls in ipairs({"Shirt", "Pants"}) do
local x = ku:FindFirstChildOfClass(cls)
if x then local c = x:Clone(); c:SetAttribute("ZenoxTiru", true); c.Parent = karakter end
end
local bagian = F.tiruBagian
simpan.trans = simpan.trans or {}
for nama in pairs(bagian) do
local kp = ku:FindFirstChild(nama); local tp = karakter:FindFirstChild(nama)
if kp and tp and tp:IsA("BasePart") then
if simpan.trans[nama] == nil then simpan.trans[nama] = tp.Transparency end
tp.Transparency = kp.Transparency
end
end
for _, d in ipairs(ku:GetDescendants()) do
if d:IsA("BasePart") and not bagian[d.Name] and d.Transparency < 1 then
local w = d:FindFirstChildWhichIsA("WeldConstraint") or d:FindFirstChildWhichIsA("Weld")
local induk = w and w.Part0
if induk and bagian[induk.Name] and induk:IsDescendantOf(ku) then
local tp = karakter:FindFirstChild(induk.Name)
if tp and tp:IsA("BasePart") then
local offset = induk.CFrame:ToObjectSpace(d.CFrame)
local c = d:Clone()
for _, x in ipairs(c:GetChildren()) do
if x:IsA("Weld") or x:IsA("WeldConstraint") or x:IsA("Motor6D") then x:Destroy() end
end
c.Anchored = false; c.CanCollide = false; c.Massless = true
c.CFrame = tp.CFrame * offset
local wc = Instance.new("WeldConstraint"); wc.Part0 = tp; wc.Part1 = c; wc.Parent = c
c:SetAttribute("ZenoxTiru", true)
c.Parent = karakter
end
end
end
end
local kh = ku:FindFirstChild("Head"); local th = karakter:FindFirstChild("Head")
local kf = kh and kh:FindFirstChildOfClass("Decal"); local tf = th and th:FindFirstChildOfClass("Decal")
if kf and tf then
if simpan.wajah == nil then simpan.wajah = tf.Texture end
tf.Texture = kf.Texture
end
return true
end
function F.tiruKembalikan(karakter)
if not karakter then return end
for _, a in ipairs(karakter:GetChildren()) do
if a:GetAttribute("ZenoxTiru") then a:Destroy() end
end
local simpan = S.tiru.asli and S.tiru.asli[karakter]
if simpan then
for _, a in ipairs(simpan) do
if a.Parent == nil then a.Parent = karakter end
end
local bB = karakter:FindFirstChildOfClass("BodyColors")
if bB and simpan.warna then
for p, col in pairs(simpan.warna) do pcall(function() bB[p] = col end) end
end
local th = karakter:FindFirstChild("Head"); local tf = th and th:FindFirstChildOfClass("Decal")
if tf and simpan.wajah then tf.Texture = simpan.wajah end
if simpan.trans then
for nama, t in pairs(simpan.trans) do
local bp = karakter:FindFirstChild(nama)
if bp and bp:IsA("BasePart") then bp.Transparency = t end
end
end
end
if S.tiru.asli then S.tiru.asli[karakter] = nil end
end
function F.tiruRestore(nama)
local p = nama and Players:FindFirstChild(nama)
if p and p.Character then pcall(F.tiruKembalikan, p.Character) end
end
function F.tiruFoto()
local ku = me.Character; if not ku then return nil end
local ok, m = pcall(function() ku.Archivable = true; return ku:Clone() end)
if not ok or not m then return nil end
for _, c in ipairs(m:GetDescendants()) do
if c:IsA("Script") or c:IsA("LocalScript") or c:IsA("Humanoid") or c:IsA("Animator") then pcall(function() c:Destroy() end) end
end
m.Parent = nil
return m
end
function F.tiruStop(semua)
if not (S.tiru.on or S.tiru.target or next(S.tiru.snap) ~= nil) then return end
local nama = S.tiru.target
S.tiru.on = false
if nama and not S.tiru.snap[nama] then F.tiruRestore(nama); S.tiru.target = nil end
if semua then
for n in pairs(S.tiru.snap) do F.tiruRestore(n) end
S.tiru.snap = {}
S.tiru.target = nil
S.tiru.asli = {}
end
S.tiru.lastCh = {}; S.tiru.sigOf = {}
F.catat(semua and "tiru: semua outfit pemain dikembalikan" or "tiru: berhenti")
end
function F.tiruJalan()
if S.tiruJalan then return end
S.tiruJalan = true
task.spawn(function()
while S.tiru.on or next(S.tiru.snap) ~= nil do
local daftar = {}
for nama in pairs(S.tiru.snap) do daftar[nama] = "snap" end
if S.tiru.on and S.tiru.target and not S.tiru.snap[S.tiru.target] then daftar[S.tiru.target] = "live" end
for nama, mode in pairs(daftar) do
local p = Players:FindFirstChild(nama)
local ch = p and p.Character
if ch and ch.Parent and ch:FindFirstChildOfClass("Humanoid") and (mode == "live" or S.tiru.snap[nama]) then
local sg = nil
local perlu = S.tiru.lastCh[nama] ~= ch
if mode == "live" then
sg = F.tiruSig()
if sg ~= S.tiru.sigOf[nama] then perlu = true end
end
if perlu then
local sumber = (mode == "snap") and S.tiru.snap[nama] or nil
local ok, hasil = pcall(F.tiruSalin, ch, sumber)
if not ok or hasil ~= true then
F.catat("tiru gagal (" .. nama .. "): " .. (ok and "karakter pemain bukan R15" or string.sub(tostring(hasil), 1, 80)))
if mode == "live" then S.tiru.on = false; S.tiru.target = nil; F.tiruRestore(nama)
else S.tiru.snap[nama] = nil end
else
S.tiru.lastCh[nama] = ch; S.tiru.sigOf[nama] = sg
end
end
end
end
task.wait(1)
end
S.tiruJalan = false
end)
end
function F.tiruPilih(nama)
if not F.izin("clone") then F.kunci("clone"); return end
if not nama or nama == me.Name then return end
if S.tiru.target and S.tiru.target ~= nama and not S.tiru.snap[S.tiru.target] then F.tiruRestore(S.tiru.target) end
S.tiru.target = nama; S.tiru.on = true
S.tiru.lastCh[nama] = nil; S.tiru.sigOf[nama] = nil
F.tiruJalan()
F.catat("tiru outfit kita ke " .. nama)
end
function F.tiruSimpanToggle()
local nama = S.tiru.target
if not nama then F.catat("pilih pemain dulu sebelum save outfit"); return end
if S.tiru.snap[nama] then
S.tiru.snap[nama] = nil
S.tiru.lastCh[nama] = nil
F.tiruRestore(nama)
if not S.tiru.on then S.tiru.target = nil end
F.catat("save outfit ke " .. nama .. " dilepas")
else
local foto = F.tiruFoto()
if not foto then F.catat("gagal ambil foto outfit"); return end
S.tiru.snap[nama] = foto
S.tiru.lastCh[nama] = nil
F.tiruJalan()
F.catat("outfit disimpan ke " .. nama)
end
end
function F.resetSemua()
pcall(F.tiruStop, true)
for _, it in ipairs(S.items) do if it.on then F.setOn(it, false) end end
if S.rambutOn then F.rambutSet(false) end; if S.headOn then F.headSet(false) end; if S.kor.on then F.korSet(false) end; if S.kiri.on then F.kiriSet(false) end; if S.cam.on then F.camSet(false) end; if S.bodyOn then F.bodySet(false) end
F.emoteStop(); F.bajuReset(); F.animReset(); F.cfgResetSemua()
if F.cloneKembalikan then pcall(F.cloneKembalikan) end
if S.share and S.share.target then pcall(F.shReset) end
F.catat("reset: avatar dikembalikan")
end
function F.resetAll()
local TS = game:GetService("TweenService")
local pg = me:FindFirstChildOfClass("PlayerGui") or me:WaitForChild("PlayerGui")
local g = mk("ScreenGui", {Name = "ZenoxFlash", ResetOnSpawn = false, DisplayOrder = 10000, IgnoreGuiInset = true}, pg)
local layar = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0}, g)
TS:Create(layar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
task.delay(1, function()
F.aman(function()
F.resetSemua()
if S.namaCustom then F.namaSet(nil) end
S.skel = {}
if S.bodyOn then F.bodyClear(); S.bodyOn = false end
S.bodyDaftar = nil
F.segarkanUI()
end)
local keluar = TS:Create(layar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
keluar:Play(); keluar.Completed:Wait(); g:Destroy()
end)
end
function F.skinMuat() local isi = baca(C.FILE_SKIN); if not isi then return end; local ok, d = pcall(function() return HS:JSONDecode(isi) end); if ok and type(d) == "table" and type(d.slots) == "table" then for i = 1, C.SLOT_SKIN do local s = d.slots[i]; if type(s) == "table" then S.skin.slots[i] = s end end end end
function F.skinTulis() return tulis(C.FILE_SKIN, HS:JSONEncode(S.skin)) end
function F.skinAmbil() local akses, gear = {}, {}; for _, it in ipairs(S.items) do if it.on then if it.kind == "gear" then table.insert(gear, it.id) else table.insert(akses, it.id) end end end; return {kosong = false, akses = akses, gear = gear, shirt = S.bajuWant.shirt, pants = S.bajuWant.pants, waktu = os.time()} end
function F.skinSimpan(i, nama) local d = F.skinAmbil(); local t = trim(nama); d.nama = (t ~= "") and t or ("skin " .. i); S.skin.slots[i] = d; if F.skinTulis() then F.catat("skin slot " .. i .. " disimpan") else F.catat("skin slot " .. i .. " di memori") end; F.skinSegarkan() end
function F.skinHapus(i) S.skin.slots[i] = {kosong = true}; F.skinTulis(); F.catat("skin slot " .. i .. " dihapus"); F.skinSegarkan() end
function F.skinPakai(i) local d = S.skin.slots[i]; if not d or d.kosong then F.catat("skin kosong"); return end; local daftar = {}; for _, id in ipairs(d.akses or {}) do local known = S.byId[id]; table.insert(daftar, {id = id, nama = known and known.nama or ("ID " .. tostring(id)), kind = "akses"}) end; for _, id in ipairs(d.gear or {}) do local known = S.byId[id]; table.insert(daftar, {id = id, nama = known and known.nama or ("ID " .. tostring(id)), kind = "gear"}) end; if d.shirt then F.bajuSet("shirt", d.shirt) end; if d.pants then F.bajuSet("pants", d.pants) end; F.pakaiSet(daftar, "skin " .. tostring(d.nama or i)) end
function F.skinSegarkan() local ui = S.ui; if not ui.skinBox then return end; local baris = {}; for i = 1, C.SLOT_SKIN do local d = S.skin.slots[i]; if d and not d.kosong then local jml = #(d.akses or {}) + #(d.gear or {}); table.insert(baris, i .. ". " .. tostring(d.nama) .. " (" .. jml .. " item)") else table.insert(baris, i .. ". kosong") end end; ui.skinBox.Text = table.concat(baris, "\n") end
function F.welRusak(o)
local w = o:FindFirstChildWhichIsA("WeldConstraint", true)
return w ~= nil and (w.Part0 == nil or w.Part1 == nil or w.Part0.Parent == nil)
end
-- jaga-jaga: sebagian game (mis. Evade) diam-diam nge-reset Transparency/LocalTransparencyModifier
-- part tanpa benar-benar menghapus weld-nya, jadi item ilang keliatan padahal masih nyambung.
-- dipanggil tiap siklus watchStep, cuma menimpa part milik item/korblox/head yang memang lagi ON.
function F.paksaTampil()
for _, it in ipairs(S.items) do
if it.on and it.obj and it.obj.Parent then
for _, d in ipairs(it.obj:GetDescendants()) do
if d:IsA("BasePart") then
if d.Transparency > 0 then d.Transparency = 0 end
if d.LocalTransparencyModifier ~= 0 then d.LocalTransparencyModifier = 0 end
elseif d:IsA("Decal") or d:IsA("Texture") then
if d.Transparency > 0 then d.Transparency = 0 end
end
end
end
end
if S.kor.on or S.kiri.on then
local m = F.target()
if m then
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("BasePart") and d.Name:find("Kor", 1, true) then
if d.Transparency > 0 then d.Transparency = 0 end
if d.LocalTransparencyModifier ~= 0 then d.LocalTransparencyModifier = 0 end
end
end
end
end
if S.headOn then
local m = F.target()
local hd = m and m:FindFirstChild("Head")
if hd then
if hd.LocalTransparencyModifier ~= hd.Transparency then hd.LocalTransparencyModifier = hd.Transparency end
end
end
end
function F.watchStep()
local sec0 = S.byId[C.SECRET_ID]
if S.secretHid and not (sec0 and sec0.on) then
S.secretHid = false
if not S.headOn then local m0 = F.target(); local hd0 = m0 and m0:FindFirstChild("Head"); if hd0 then hd0.Transparency = 0 end end
end
local m = F.target()
if m ~= S.lastTarget then
S.lastTarget = m; S.baju = {}; S.rambutOrig = {}; S.bajuBackup = nil; S.celanaBackup = nil
for _, it in ipairs(S.items) do pcall(F.lepasObj, it) end
if m then
F.catat("target baru: karakter")
for _, it in ipairs(S.items) do if it.on then task.spawn(F.jalan, it, "ulang", 1) end end
for kelas, id in pairs(S.bajuWant) do F.bajuSet(kelas, id) end
if S.headOn then F.headSet(true) end
if S.kor.on or S.kiri.on then task.spawn(F.korApplyAll) end; if S.centang then task.spawn(F.centangSync) end; if S.bodyOn and S.bodyDaftar then task.spawn(F.aman, function() F.bodyApply(S.bodyDaftar, S.bodyWarna) end) end
task.spawn(F.animUlang, m)
end
else
local sekarang = os.clock()
for _, it in ipairs(S.items) do
if it.on and it.obj and (not it.obj.Parent or F.welRusak(it.obj)) then
pcall(F.lepasObj, it)
local baru = {}
for _, t in ipairs(it.riwayat or {}) do if sekarang - t < 10 then table.insert(baru, t) end end
table.insert(baru, sekarang); it.riwayat = baru
if #baru > 5 then
it.on = false; it.riwayat = {}; it.jedaSampai = 0
if it.set then it.set(false) end
F.catat(it.nama .. " DIHENTIKAN: dihapus game 5x dalam 10 detik")
F.notif("KRONOZ", it.nama .. " dihentikan, sering dihapus game", 5)
else
local tunggu = math.max(0, (it.jedaSampai or 0) - sekarang)
it.jedaSampai = sekarang + tunggu + 0.5
if not it.jadwal then
it.jadwal = true
task.delay(tunggu, function()
it.jadwal = false
if it.on then F.catat(it.nama .. " dipasang ulang"); task.spawn(F.jalan, it, "ulang", 1) end
end)
end
end
end
end
end
F.tasCek(false)
local ui = S.ui
pcall(F.hairSync)
pcall(F.bersihYatim)
if ui.rigBox then
local hd = m and m:FindFirstChild("Head"); local n = 0
for _, it in ipairs(S.items) do if it.obj then n = n + 1 end end
ui.rigBox.Text = "target: " .. (m and "karakter" or "-") .. " | Head: " .. (hd and "ada" or "-") .. " | terpasang: " .. n
end
end
function F.jalanPantau()
if S.pantau then return end; S.pantau = true
task.spawn(function()
while S.alive do task.wait(0.5); local ok, e = pcall(F.watchStep); if not ok then F.catat("error pantau: " .. string.sub(tostring(e), 1, 100)) end; pcall(F.paksaTampil); pcall(F.tasCek, false); pcall(F.kameraJaga); pcall(F.nametagSync); if (S.uiAlpha or 1) ~= 1 then pcall(F.uiTerapkan) end; if S.ui.gui and S.ui.gui.Enabled then pcall(F.segarkanUI) end end
end)
end
function F.tutup()
S.alive = false
for _, it in ipairs(S.items) do it.on = false; F.lepasObj(it) end
F.headSet(false); F.korSet(false); F.kiriSet(false); F.camSet(false); F.bajuReset(); F.emoteStop()
if S.share and S.share.target then pcall(F.shReset) end
if S.hideConn then S.hideConn:Disconnect(); S.hideConn = nil end
if S.ui.gui then S.ui.gui:Destroy() end
end
local U = {order = 0}
function U.nx() U.order += 1; return U.order end
function U.sec(pg, t) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = t, TextColor3 = OR, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = U.nx()}, pg) end
function U.row(pg, h, nama, kanan)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, h or 32), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = U.nx()}, pg); rnd(r)
if nama then mk("TextLabel", {Size = UDim2.new(1, -((kanan or 50) + 18), 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r) end
return r
end
function U.toggle(pg, nama, cb, awal)
local r = U.row(pg, 32, nama, 50); local tr = mk("TextButton", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF, Text = "", AutoButtonColor = false}, r); rnd(tr, 10)
local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG, BorderSizePixel = 0}, tr); rnd(kn, 7)
local st = false
local function set(s, inst) st = s; local ti = TweenInfo.new(inst and 0 or 0.12, Enum.EasingStyle.Quad); TS:Create(tr, ti, {BackgroundColor3 = s and OR or OFF}):Play(); TS:Create(kn, ti, {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end
tr.MouseButton1Click:Connect(function() local ok, res = pcall(cb, not st); if not ok then F.catat("error: " .. tostring(res):sub(1, 90)); return end; if res ~= false then set(not st) end end)
if awal then set(true, true) end
return set, r
end
function U.stepper(pg, nama, get, dec, inc)
local r = U.row(pg, 32, nama, 112); local v = mk("TextLabel", {Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -88, 0, 0), BackgroundTransparency = 1, TextColor3 = OR, Font = Enum.Font.GothamMedium, TextSize = 13}, r)
local function mkBtn(txt, x) local b = mk("TextButton", {Size = UDim2.new(0, 26, 0, 22), Position = UDim2.new(1, x, 0.5, -11), BackgroundColor3 = OFF, Text = txt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 15}, r); rnd(b, 5); return b end
local function seg() v.Text = get() end; seg(); mkBtn("-", -116).MouseButton1Click:Connect(function() dec(); seg() end); mkBtn("+", -36).MouseButton1Click:Connect(function() inc(); seg() end)
return seg
end
function U.full(pg, txt, col, cb, solid)
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = solid and col or ROW, Text = txt, TextColor3 = solid and BLK or col, Font = Enum.Font.GothamMedium, TextSize = 13, LayoutOrder = U.nx()}, pg); rnd(b)
if not solid then mk("UIStroke", {Color = col, Thickness = 1}, b) end
b.MouseButton1Click:Connect(function() cb(b) end); return b
end
function U.input(pg, ph, val)
local r = U.row(pg, 36); local b = mk("TextBox", {Size = UDim2.new(1, -24, 1, -10), Position = UDim2.new(0, 12, 0, 5), BackgroundTransparency = 1, Text = val or "", PlaceholderText = ph, PlaceholderColor3 = MUT, TextColor3 = OR, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, r); return b
end
function F.barisItem(it, parent)
S.urut = S.urut + 1
local b = mk("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = S.urut }, parent); rnd(b)
mk("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = it.nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, b)
local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF, BorderSizePixel = 0}, b); rnd(sw, 10)
local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7)
it.set = function(v) TS:Create(sw, SPRING, {BackgroundColor3 = v and OR or OFF}):Play(); TS:Create(kn, SPRING, {Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end
it.set(it.on); b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.setOn(it, not it.on) end) end)
end
local function pgFitur(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
local function input(ph) local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r); return mk("TextBox", {Size = UDim2.new(1, -16, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "", PlaceholderText = ph, PlaceholderColor3 = MUT, TextColor3 = OR, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r) end
local function wadah() local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page); mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f); return f end
local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end
local function toggle(nama, get, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); mk("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b); local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF}, b); rnd(sw, 10); local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7); local function p() local s = get(); TS:Create(sw, SPRING, {BackgroundColor3 = s and OR or OFF}):Play(); TS:Create(kn, SPRING, {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end; p(); S.ui.segar = S.ui.segar or {}; table.insert(S.ui.segar, p); b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() fn(not (get() and true or false)); p() end) end) end
sec("Cari fitur (nama)"); local boxCari = input("ketik nama fitur, contoh: headless"); btn("CARI FITUR", true, function() F.cariFitur(boxCari.Text) end); boxCari:GetPropertyChangedSignal("Text"):Connect(function() F.cariFitur(boxCari.Text) end)
sec("Gear"); local wGear = wadah(); box(MUT).Text = "Gear dipegang satu per satu. Hanya muncul di tas kalau toggle-nya nyala. Aksesoris diatur lewat ITEM TERPILIH di kanan atas."
for _, it in ipairs(S.items) do if it.kind == "gear" and not C.RAMBUT_GANTI[it.id] then F.barisItem(it, wGear) end end; S.ui.itemAdd = function(it) if C.RAMBUT_GANTI[it.id] then if S.ui.hairAdd then S.ui.hairAdd(it) end; return end; if it.kind == "gear" then F.barisItem(it, wGear) end end
sec("Custom ID"); local boxId = input("ID gear / aksesoris"); btn("PASANG ID", true, function() local id = tonumber(trim(boxId.Text)); if id and id > 0 then F.pasangId(id) end end); btn("NYALAKAN SEMUA", false, function() for _, it in ipairs(S.items) do if not it.on then F.setOn(it, true) end end end); btn("MATIKAN SEMUA", false, function() for _, it in ipairs(S.items) do if it.on then F.setOn(it, false) end end end)
end
function F.sembunyiTerapkan(it)
local o = it.obj; if not o then return end
it.transAsli = it.transAsli or {}
local daftar = {}
if o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture") then table.insert(daftar, o) end
for _, d in ipairs(o:GetDescendants()) do if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then table.insert(daftar, d) end end
for _, d in ipairs(daftar) do
if it.sembunyi then
if it.transAsli[d] == nil then it.transAsli[d] = d.Transparency end
d.Transparency = 1
elseif it.transAsli[d] ~= nil then
if d.Parent then d.Transparency = it.transAsli[d] end
end
end
if not it.sembunyi then it.transAsli = {} end
end
function F.sembunyiSet(it, v)
it.sembunyi = v and true or false
F.sembunyiTerapkan(it)
F.catat(it.nama .. (it.sembunyi and " disembunyikan (efek tetap)" or " ditampilkan lagi"))
end
function F.sembunyiSemua(v)
for _, it in ipairs(S.items) do
it.sembunyi = v and true or false
pcall(F.sembunyiTerapkan, it)
end
F.catat("semua item " .. (v and "disembunyikan (efek tetap)" or "ditampilkan lagi"))
F.segarkanUI()
end
function F.barisHide(it, parent)
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false}, parent); rnd(b)
mk("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = it.nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b)
local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF, BorderSizePixel = 0}, b); rnd(sw, 10)
local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7)
local function segar() TS:Create(sw, SPRING, {BackgroundColor3 = it.sembunyi and OR or OFF}):Play(); TS:Create(kn, SPRING, {Position = it.sembunyi and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end
segar(); F.daftarSegar(segar)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.sembunyiSet(it, not it.sembunyi); segar() end) end)
end
function F.hideCari(teks, parent)
for _, c in ipairs(parent:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
local q = string.lower(trim(teks)); if q == "" then return end
local n = 0
for _, it in ipairs(S.items) do
if string.find(string.lower(it.nama), q, 1, true) then
n = n + 1; if n > 15 then break end
F.barisHide(it, parent)
end
end
end
function F.cariFitur(teks)
local q = string.lower(trim(teks))
local pertama = nil
for _, pg in pairs(S.ui.halamanList or {}) do
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("TextButton") and d.Text == "" then
local lb = d:FindFirstChildWhichIsA("TextLabel")
if lb then
local cocok = (q == "") or (string.find(string.lower(lb.Text), q, 1, true) ~= nil)
d.Visible = cocok
if cocok and q ~= "" and not pertama then pertama = pg end
end
end
end
end
if pertama and S.ui.tampil then S.ui.tampil(pertama:GetAttribute("zxKey")) end
if pertama and pertama:GetAttribute("zxSub") and S.ui.subTampil then S.ui.subTampil(pertama:GetAttribute("zxSub")) end
end
function F.pasangCustom(teks)
local id = tonumber(trim(teks or ""))
if not id or id <= 0 then F.catat("custom ID: isi angka ID dulu"); return end
task.spawn(F.aman, function()
local ok, inf = pcall(function() return MPS:GetProductInfo(id) end)
if not ok or not inf then F.catat("ID " .. id .. ": info tidak bisa dibaca"); return end
local t = inf.AssetTypeId
if t == 2 or t == 11 then F.bajuGanti(id); F.catat("shirt " .. tostring(inf.Name) .. " dipasang")
elseif t == 12 then F.celanaGanti(id); F.catat("celana " .. tostring(inf.Name) .. " dipasang")
else F.pasangId(id) end
end)
end
local function pgShirt(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local induk = page
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, induk); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
local function wadah() local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, induk); mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f); return f end
local function toggle(nama, get, fn)
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, induk); rnd(b)
mk("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, b)
local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF, BorderSizePixel = 0}, b); rnd(sw, 10)
local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7)
local function segar() local v = get(); TS:Create(sw, SPRING, {BackgroundColor3 = v and OR or OFF}):Play(); TS:Create(kn, SPRING, {Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end
segar(); b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() fn(not get()); segar() end) end); F.daftarSegar(segar)
end
local function grup(judul, buka)
local kepala = mk("TextButton", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, induk)
local teks = mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = OR, Font = FB, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, kepala)
local isi = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = buka, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, isi)
local function segar() teks.Text = judul .. (isi.Visible and "  -" or "  +") end
segar()
kepala.MouseButton1Click:Connect(function() isi.Visible = not isi.Visible; segar() end)
return isi
end
induk = grup("Custom ID (shirt / celana / hair)", false)
local boxCustom = mk("TextBox", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", PlaceholderText = "tempel ID shirt, celana, atau hair", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 11, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, induk)
rnd(boxCustom); mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, boxCustom)
btn("PASANG ID CUSTOM", true, function() F.pasangCustom(boxCustom.Text) end)
induk = grup("Baju (shirt)", false)
btn("HAPUS BAJU", false, function() F.bajuHapus() end)
btn("KEMBALIKAN BAJU ASLI", false, function() F.bajuKembali() end)
for i, s in ipairs(C.SHIRT) do btn(i .. ". " .. s.nama, true, function() F.bajuGanti(s.id) end) end
induk = grup("Celana (pants)", false)
btn("KEMBALIKAN CELANA ASLI", false, function() F.celanaKembali() end)
for _, s in ipairs(C.CELANA) do btn(s.nama, true, function() F.celanaGanti(s.id) end) end
induk = grup("Rambut", false)
toggle("Hapus rambut", function() return S.rambutOn == true end, function(v) F.rambutSet(v) end)
toggle("girl hair", F.girlHairOn, function(v) F.girlHairSet(v) end)
local wHair = wadah()
S.ui.hairAdd = function(it) F.barisItem(it, wHair) end
for _, it in ipairs(S.items) do if C.RAMBUT_GANTI[it.id] then F.barisItem(it, wHair) end end
end
local function pgHide(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local rowAll = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
local function tombol(txt, x, fn) local b = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(x, x > 0 and 4 or 0, 0, 0), BackgroundColor3 = ROW, Text = txt, TextColor3 = OR, Font = FB, TextSize = 12, AutoButtonColor = false}, rowAll); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end) end
tombol("SEMBUNYIKAN SEMUA", 0, function() F.sembunyiSemua(true) end)
tombol("TAMPILKAN SEMUA", 0.5, function() F.sembunyiSemua(false) end)
local bNama = mk("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, Text = "", TextColor3 = TXT, Font = FM, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(bNama)
local function segarNama() bNama.Text = (S.nametagHide == true) and "Username: DISEMBUNYIKAN (klik untuk tampilkan)" or "Username: TAMPIL (klik untuk sembunyikan)" end
bNama.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.nametagSet(S.nametagHide ~= true); segarNama() end) end)
segarNama()
sec("Hide item (cari dulu)")
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local boxHide = mk("TextBox", {Size = UDim2.new(1, -16, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "", PlaceholderText = "ketik nama item yang mau di hide", PlaceholderColor3 = MUT, TextColor3 = OR, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, r)
local wHide = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, wHide)
boxHide:GetPropertyChangedSignal("Text"):Connect(function() F.hideCari(boxHide.Text, wHide) end)
local catatan = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = MUT, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Text = "Item muncul setelah diketik. Hide hanya menyembunyikan badan item, efek partikelnya tetap jalan.", LayoutOrder = nx()}, page); rnd(catatan)
mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, catatan)
end
function F.skelSet(k, v)
S.skel = S.skel or {}
S.skel[k] = v and true or false
F.skelSync()
end
function F.skelSync()
local urut = {{"kanan", "Right Leg"}, {"kiri", "Left Leg"}, {"badan", "Torso"}}
local daftar = {}
for _, u in ipairs(urut) do
if S.skel and S.skel[u[1]] then table.insert(daftar, {id = C.SKEL[u[1]], nama = u[2]}) end
end
if #daftar == 0 then
if S.bodyOn then F.bodyClear(); S.bodyOn = false end
S.bodyDaftar = nil
F.catat("Classic skeleton OFF")
else
F.bodyApply(daftar, nil)
end
F.segarkanUI()
end
local function pgBody(page)
local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = t, TextColor3 = OR, Font = FB, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function langkah(nama, ambil, geser)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
mk("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local v = mk("TextLabel", {Size = UDim2.new(0, 44, 1, 0), Position = UDim2.new(1, -96, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = OR, Font = FB, TextSize = 12}, r)
local function segar() v.Text = string.format("%.2f", ambil()) end
local b1 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -50, 0, 4), BackgroundColor3 = OFF, Text = "-", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(b1, 5)
local b2 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -24, 0, 4), BackgroundColor3 = OFF, Text = "+", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(b2, 5)
b1.MouseButton1Click:Connect(function() task.spawn(F.aman, function() geser(-0.05); segar() end) end)
b2.MouseButton1Click:Connect(function() task.spawn(F.aman, function() geser(0.05); segar() end) end)
F.daftarSegar(segar); segar()
end
local rig = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local function segarRig()
local tipe = F.rigTipe(F.target()) or "?"
rig.Text = "Rig terdeteksi: " .. tipe .. "  -  Korblox & Headless otomatis cocok"
end
segarRig(); F.daftarSegar(segarRig)
sec("RIG AVATAR (kamu)")
do
local rr = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, rr)
for i, tp in ipairs({"R15", "R6"}) do
local b = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = ACT, Text = "Jadi " .. tp, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = i}, rr)
rnd(b)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.rigDiriSet(tp) end) end)
end
end
sec("KARAKTER KAMU")
F.togelDesk(page, nx, "Korblox Kanan", "Kaki kanan Korblox - otomatis R6 & R15", function() return S.kor.on end, function(v) F.korSet(v) end)
F.togelDesk(page, nx, "Korblox Kiri", "Kaki kiri Korblox - otomatis R6 & R15", function() return S.kiri.on end, function(v) F.kiriSet(v) end)
F.togelDesk(page, nx, "Headless", "Hilangkan kepala & wajah - otomatis R6 & R15", function() return S.headOn end, function(v) F.headSet(v) end)
sec("POSISI KAKI KORBLOX")
langkah("Tinggi", function() return F.korPendAmbil().tinggi end, function(d) F.korTinggi(d) end)
langkah("Kiri / Kanan", function() return F.korPendAmbil().geserX end, function(d) F.korGeser("x", d) end)
langkah("Depan / Belakang", function() return F.korPendAmbil().geserZ end, function(d) F.korGeser("z", d) end)
local tApply = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "APPLY KORBLOX", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(tApply)
tApply.MouseButton1Click:Connect(function() task.spawn(F.aman, F.korTerapkan) end)
local tReset = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "RESET POSISI KAKI", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(tReset)
tReset.MouseButton1Click:Connect(function() task.spawn(F.aman, F.korReset) end)
sec("PAKAIAN CLASSIC")
local function pasangBadan(kelas, id) return F.bajuSet(kelas, id) end
local function cekBadan(kelas) return (S.bajuWant or {})[kelas] ~= nil end
F.kotakPakaian(page, nx, "Baju (Shirt)", "shirt", pasangBadan, cekBadan)
F.kotakPakaian(page, nx, "Celana (Pants)", "pants", pasangBadan, cekBadan)
F.kotakPakaian(page, nx, "T-Shirt (Graphic)", "tshirt", pasangBadan, cekBadan)
local tLepasBaju = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "LEPAS PAKAIAN", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(tLepasBaju)
tLepasBaju.MouseButton1Click:Connect(function() task.spawn(F.aman, F.bajuReset) end)
sec("SET KAMU")
F.barisIsi(page, nx, "ID bundle (angka)", "Simpan", function(box)
local id = tonumber(trim(box.Text))
if not id then F.catat("body: isi ID bundle (angka)"); return end
F.bodySet(false)
local ok = F.bodySet(true, id)
S.bodyId = ok and id or nil
F.catat("body bundle " .. tostring(id) .. (ok and " dipasang" or " gagal"))
end)
local tombolLepas = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "LEPAS BODY", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tombolLepas)
tombolLepas.MouseButton1Click:Connect(function()
task.spawn(F.aman, function() S.bodyId = nil; F.bodySet(false) end)
end)
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = MUT, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx(), Text = "Body bundle R6 di-weld ke rig R15 kamu. Kepala bundle tidak bisa dimuat dari client, jadi kepala tetap seperti semula. Rig tetap R15."}, page)
end
function F.fiturUrut()
local daftar, dipakai = {}, {}
local function tambah(nama, on, cat) table.insert(daftar, {nama = nama, on = on == true, cat = cat}) end
for _, grup in ipairs({C.AKSES, C.GEAR}) do
for _, a in ipairs(grup) do
local it = S.byId[a[2]]
tambah(a[1], it and it.on, a[2]); dipakai[a[2]] = true
end
end
local wb, sk, em = S.bajuWant or {}, S.skel or {}, S.emote or {}
tambah("Headless", S.headOn)
tambah("Korblox kaki kanan", S.kor and S.kor.on)
tambah("Korblox kaki kiri", S.kiri and S.kiri.on)
tambah("Classic skeleton kaki kanan", sk.kanan, C.SKEL.kanan)
tambah("Classic skeleton kaki kiri", sk.kiri, C.SKEL.kiri)
tambah("Classic skeleton badan", sk.badan, C.SKEL.badan)
tambah("Hapus rambut", S.rambutOn)
local sid = wb.shirt or wb.tshirt
tambah("Shirt", sid ~= nil, sid)
tambah("Celana", wb.pants ~= nil, wb.pants)
tambah("Emote", (em.nama or "") ~= "")
for _, it in ipairs(S.items) do if not dipakai[it.id] then tambah(it.nama, it.on, it.id) end end
return daftar
end
function F.outfitKode()
local p = {}
for i, e in ipairs(F.fiturUrut()) do if e.on then table.insert(p, tostring(i)) end end
if #p == 0 then return "ZX-kosong" end
return "ZX-" .. table.concat(p, "-")
end
function F.avatarKode()
local c = {}
for _, e in ipairs(F.fiturUrut()) do if e.on and e.cat then table.insert(c, tostring(e.cat)) end end
if #c == 0 then return "(kosong)" end
return table.concat(c, ",")
end
function F.urutanTeks()
local b = {}
for i, e in ipairs(F.fiturUrut()) do table.insert(b, i .. ". " .. e.nama .. (e.on and "  [ON]" or "")) end
return table.concat(b, "\n")
end
function F.salin(teks, pesan)
if setclipboard then setclipboard(teks); F.notif("KRONOZ", pesan, 3)
else F.notif("KRONOZ", "executor ini tidak punya fungsi salin", 4) end
end
function F.pasangAvatarKode(teks)
local daftar, sudah = {}, {}
for angka in string.gmatch(teks or "", "%d+") do
local id = tonumber(angka)
if id and not sudah[id] then sudah[id] = true; table.insert(daftar, id) end
end
if #daftar == 0 then F.catat("avatar code kosong / tidak valid"); return end
task.spawn(F.aman, function()
local adaSkel = false
for _, id in ipairs(daftar) do
if id == C.SKEL.kanan or id == C.SKEL.kiri or id == C.SKEL.badan then
local nama = (id == C.SKEL.kanan and "kanan") or (id == C.SKEL.kiri and "kiri") or "badan"
S.skel = S.skel or {}; S.skel[nama] = true; adaSkel = true
elseif S.byId[id] then
if not S.byId[id].on then F.setOn(S.byId[id], true) end
else
local ok, inf = pcall(function() return MPS:GetProductInfo(id) end)
local t = ok and inf and inf.AssetTypeId
if t == 2 or t == 11 then F.bajuGanti(id)
elseif t == 12 then F.celanaGanti(id)
else F.pasangId(id) end
end
end
if adaSkel then F.skelSync() end
F.catat("avatar code dipasang: " .. #daftar .. " ID")
end)
end
function F.centangBadge(lbl)
local b = mk("Frame", {Name = "ZenoxCentang", Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = lbl.ZIndex + 1}, lbl)
local kotak = mk("Frame", {Name = "Badan", Size = UDim2.new(0.73, 0, 0.73, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 15, BackgroundColor3 = Color3.fromRGB(0, 102, 255), BorderSizePixel = 0, ZIndex = lbl.ZIndex + 1}, b)
local tebal = 0.1
local function garis(x1, y1, x2, y2)
local dx, dy = x2 - x1, y2 - y1
local g = mk("Frame", {Name = "Garis", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((x1 + x2) / 2, 0, (y1 + y2) / 2, 0), Size = UDim2.new(math.sqrt(dx * dx + dy * dy) + tebal, 0, tebal, 0), Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = lbl.ZIndex + 2}, b)
mk("UICorner", {CornerRadius = UDim.new(0.5, 0)}, g)
end
garis(0.325, 0.500, 0.430, 0.613)
garis(0.430, 0.613, 0.675, 0.360)
return b
end
F.LOGO_ADMIN_PNG = "https://tr.rbxcdn.com/180DAY-f4d4e5cc7d3422c40dc8d329ae49ebbe/150/150/Image/Png/noFilter"
F.LOGO_ADMIN_ASLI = "https://tr.rbxcdn.com/180DAY-f4d4e5cc7d3422c40dc8d329ae49ebbe/150/150/Image/Webp/noFilter"
F.logoAdminAset = nil
F.logoAdminSiap = false
function F.siapLogoAdmin()
if F.logoAdminSiap then return end
F.logoAdminSiap = true
task.spawn(function()
if httpReq and writefile and getcustomasset then
for _, url in ipairs({F.LOGO_ADMIN_PNG, F.LOGO_ADMIN_ASLI}) do
local okR, resp = pcall(function() return httpReq({Url = url, Method = "GET"}) end)
if okR and type(resp) == "table" and type(resp.Body) == "string" and #resp.Body > 64 and (resp.StatusCode == nil or resp.StatusCode == 200) then
local nama = "kronoz_logo_admin.png"
if pcall(writefile, nama, resp.Body) then
local okA, aset = pcall(getcustomasset, nama)
if okA and aset then F.logoAdminAset = aset; return end
end
end
end
end
F.logoAdminAset = F.LOGO_ADMIN_ASLI
end)
end
function F.badgeAdmin(induk)
local b = mk("ImageLabel", {Name = "KronozAdmin", Size = UDim2.new(0, 38, 0, 38), BackgroundTransparency = 1, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Fit, ZIndex = induk.ZIndex + 1}, induk)
local cadangan = mk("Frame", {Name = "KronozAdminCadangan", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = b.ZIndex}, b)
local perisai = mk("Frame", {Size = UDim2.new(0, 26, 0, 26), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45, BackgroundColor3 = Color3.fromRGB(200, 25, 35), BorderSizePixel = 0, ZIndex = b.ZIndex}, cadangan)
rnd(perisai, 8)
mk("UIStroke", {Color = Color3.fromRGB(220, 224, 232), Thickness = 1.5}, perisai)
local function garis(x1, y1, x2, y2)
local dx, dy = x2 - x1, y2 - y1
mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((x1 + x2) / 2, 0, (y1 + y2) / 2, 0), Size = UDim2.new(math.sqrt(dx * dx + dy * dy) + 0.1, 0, 0.14, 0), Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = Color3.fromRGB(230, 233, 240), BorderSizePixel = 0, ZIndex = b.ZIndex + 1}, cadangan)
end
garis(0.3, 0.5, 0.44, 0.66)
garis(0.44, 0.66, 0.72, 0.34)
if S.tier == "admin" then
F.siapLogoAdmin()
task.spawn(function()
for _ = 1, 60 do
if not b.Parent then return end
if F.logoAdminAset then pcall(function() b.Image = F.logoAdminAset end); break end
task.wait(0.5)
end
end)
end
task.spawn(function()
task.wait(8)
local okL, sudah = pcall(function() return b.IsLoaded end)
if b.Parent and not (okL and sudah) then cadangan.Visible = true end
end)
return b
end
function F.centangUkur(teks, d)
local ukuranTeks = d.TextSize
if d.TextScaled and d.AbsoluteSize.Y > 0 then ukuranTeks = math.max(8, math.floor(d.AbsoluteSize.Y * 0.8)) end
local ok, v = pcall(function()
return game:GetService("TextService"):GetTextSize(teks, ukuranTeks, d.Font, Vector2.new(10000, 10000)).X
end)
local okF, vF = pcall(function()
local prm = Instance.new("GetTextBoundsParams")
prm.Text = teks; prm.Font = d.FontFace; prm.Size = ukuranTeks; prm.Width = 10000
return game:GetService("TextService"):GetTextBoundsAsync(prm).X
end)
if okF and type(vF) == "number" and vF > 0 then ok, v = true, vF end
if not (ok and type(v) == "number" and v > 0) then
v = (d.TextBounds and d.TextBounds.X) or 0
end
local tb = (d.TextBounds and d.TextBounds.X) or 0
if tb > 0 then
local polos = string.lower(trim((string.gsub(tostring(d.Text or ""), "<[^>]->", ""))))
if polos == string.lower(trim(tostring(teks or ""))) then v = tb end
end
if tb > 0 and v > tb then v = tb end
if d.AbsoluteSize.X > 0 and v > d.AbsoluteSize.X then v = d.AbsoluteSize.X end
return v
end
function F.centangTitikDua(s)
local pos, i = 0, 1
while true do
local j = string.find(s, ":", i, true)
if not j then break end
pos = j; i = j + 1
end
return pos
end
function F.centangRuangChat(d, sz)
local teksNow = tostring(d.Text or "")
if d:GetAttribute("ZenoxSpasiTeks") == teksNow then return true end
local plain = trim(string.gsub(teksNow, "<[^>]->", ""))
if string.sub(plain, -1) ~= ":" then return false end
local pos = F.centangTitikDua(teksNow)
if pos <= 0 then return false end
local lebarSpasi = F.centangUkur(" ", d); if lebarSpasi <= 0 then lebarSpasi = 3 end
local k = math.min(12, math.ceil((sz + 4) / lebarSpasi))
local baru = string.sub(teksNow, 1, pos - 1) .. string.rep(" ", k) .. string.sub(teksNow, pos)
d:SetAttribute("ZenoxTeksAsli", teksNow)
d.Text = baru
d:SetAttribute("ZenoxSpasiTeks", baru)
return true
end
function F.centangDiChat(d, root)
local induk = d.Parent
while induk and induk ~= root do
if string.find(string.lower(induk.Name), "chat") then return true end
induk = induk.Parent
end
return false
end
function F.diUI(d)
local c = d
while c do
local okA, tanda = pcall(function() return c:GetAttribute("KronozUI") end)
if okA and tanda then return true end
c = c.Parent
end
return false
end
function F.badgeAdminLB(induk)
local b = mk("ImageLabel", {Name = "KronozAdminLB", Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Fit, Image = F.logoAdminAset or F.LOGO_ADMIN_ASLI, ZIndex = induk.ZIndex + 1}, induk)
local cadangan = mk("Frame", {Name = "KronozAdminLBCadangan", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = b.ZIndex}, b)
local perisai = mk("Frame", {Size = UDim2.new(0.72, 0, 0.72, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45, BackgroundColor3 = Color3.fromRGB(200, 25, 35), BorderSizePixel = 0, ZIndex = b.ZIndex}, cadangan)
rnd(perisai, 3)
mk("UIStroke", {Color = Color3.fromRGB(220, 224, 232), Thickness = 1}, perisai)
task.spawn(function()
task.wait(6)
local okL, sudah = pcall(function() return b.IsLoaded end)
if b.Parent and not (okL and sudah) then cadangan.Visible = true end
end)
return b
end
function F.centangTempel()
local nama = string.lower(me.Name)
local tampil = string.lower(me.DisplayName or "")
local adaAdmin = S.tier == "admin"
if adaAdmin then F.siapLogoAdmin() end
local jumlah = 0
local akar = {}
local pg = me:FindFirstChildOfClass("PlayerGui"); if pg then table.insert(akar, pg) end
if me.Character then table.insert(akar, me.Character) end
local okC, cg = pcall(function() return game:GetService("CoreGui") end)
if okC and cg then table.insert(akar, cg) end
for _, root in ipairs(akar) do
for _, d in ipairs(root:GetDescendants()) do
if (d:IsA("TextLabel") or d:IsA("TextButton")) and not F.diUI(d) then
local asliTxt = d.Text or ""
if d:GetAttribute("ZenoxNamaTampil") ~= nil and d.Text == d:GetAttribute("ZenoxNamaTampil") then asliTxt = d:GetAttribute("ZenoxNamaAsli") or asliTxt end
local teks = trim(string.gsub(asliTxt, "<[^>]->", ""))
if string.sub(teks, 1, 1) ~= "@" then
local t = string.lower(teks)
t = trim(string.gsub(t, ":$", ""))
if t ~= "" and (t == nama or (tampil ~= "" and t == tampil)) and not F.centangDiChat(d, root) then
jumlah = jumlah + 1
local sz = math.max(7, math.floor((d.TextSize or 14) * (S.centangUk or 0.62)))
local namaSaja = trim(string.gsub(trim(string.gsub(tostring(d.Text or ""), "<[^>]->", "")), ":$", ""))
local lebar = F.centangUkur(namaSaja, d)
if not S.lebarLog then S.lebarLog = true; F.catat("badge: lebar '" .. namaSaja .. "' " .. math.floor(lebar) .. "px (TextBounds " .. math.floor((d.TextBounds and d.TextBounds.X) or 0) .. "px, label " .. math.floor(d.AbsoluteSize.X) .. "px)") end
local plKiri = d:FindFirstChildOfClass("UIPadding")
if plKiri then lebar = lebar + plKiri.PaddingLeft.Offset end
local geserY = S.centangGeser or 0
local geserX = S.centangGeserX or 0
local tengah = d.TextXAlignment == Enum.TextXAlignment.Center
local function taruh(b, ukuran, off)
b.Size = UDim2.new(0, ukuran, 0, ukuran)
local oy = -math.floor(ukuran / 2) - 2 + geserY
if tengah then
b.Position = UDim2.new(0.5, math.floor(lebar / 2) + 2 + geserX + off, 0.5, oy)
else
b.Position = UDim2.new(0, math.floor(lebar) + 2 + geserX + off, 0.5, oy)
end
end
local geserBiru = 0
if adaAdmin then
local ukAdmin = math.max(16, math.floor((d.TextSize or 14) * 1.5))
local lb = d:FindFirstChild("KronozAdminLB") or F.badgeAdminLB(d)
local gambar = F.logoAdminAset or F.LOGO_ADMIN_ASLI
if lb.Image ~= gambar then lb.Image = gambar end
lb.Visible = true
taruh(lb, ukAdmin, 0)
geserBiru = ukAdmin + 2
end
if S.centang then
local b = d:FindFirstChild("ZenoxCentang") or F.centangBadge(d)
taruh(b, sz, geserBiru)
else
local lama = d:FindFirstChild("ZenoxCentang"); if lama then lama:Destroy() end
end
end
end
end
end
end
return jumlah
end
function F.centangSync()
local m = F.target(); local hd = m and m:FindFirstChild("Head")
if hd then local lama = hd:FindFirstChild("ZenoxCentang"); if lama then lama:Destroy() end end
if not S.centang and S.tier ~= "admin" then
F.bersihBadge()
return
end
if S.centangJalan then return end
S.centangJalan = true
task.spawn(function()
local laporan = false
while not S.mati and (S.centang or S.tier == "admin") do
local ok, n = pcall(F.centangTempel)
if not ok then F.catat("centang error: " .. string.sub(tostring(n), 1, 90))
elseif n > 0 and not laporan then laporan = true; F.catat("nama kamu ketemu di layar: " .. n .. " baris")
elseif n == 0 and not laporan then F.catat("nama belum ketemu di layar, buka leaderboard dulu") end
task.wait(2)
end
S.centangJalan = false
end)
end
function F.bersihBadge()
local akar = {}
local pg = me:FindFirstChildOfClass("PlayerGui"); if pg then table.insert(akar, pg) end
local okC, cg = pcall(function() return game:GetService("CoreGui") end)
if okC and cg then table.insert(akar, cg) end
for _, r in ipairs(akar) do
for _, d in ipairs(r:GetDescendants()) do
if d.Name == "ZenoxCentang" or d.Name == "ZenoxRuang" or d.Name == "KronozAdminLB" then pcall(function() d:Destroy() end) end
if (d:IsA("TextLabel") or d:IsA("TextButton")) and d:GetAttribute("ZenoxSpasiTeks") ~= nil then
pcall(function()
if d.Text == d:GetAttribute("ZenoxSpasiTeks") and d:GetAttribute("ZenoxTeksAsli") ~= nil then d.Text = d:GetAttribute("ZenoxTeksAsli") end
d:SetAttribute("ZenoxSpasiTeks", nil); d:SetAttribute("ZenoxTeksAsli", nil)
end)
end
end
end
end
function F.namaAkar()
local akar = {}
local pg = me:FindFirstChildOfClass("PlayerGui"); if pg then table.insert(akar, pg) end
local okC, cg = pcall(function() return game:GetService("CoreGui") end)
if okC and cg then table.insert(akar, cg) end
local m = F.target()
if m then table.insert(akar, m) end
if me.Character and me.Character ~= m then table.insert(akar, me.Character) end
return akar
end
function F.namaSapu(custom)
local jumlah = 0
for _, root in ipairs(F.namaAkar()) do
for _, d in ipairs(root:GetDescendants()) do
if (d:IsA("TextLabel") or d:IsA("TextButton")) and not (S.ui.gui and d:IsDescendantOf(S.ui.gui)) then
local tampil = d:GetAttribute("ZenoxNamaTampil")
if tampil ~= nil and d.Text ~= tampil then
d:SetAttribute("ZenoxNamaAsli", nil); d:SetAttribute("ZenoxNamaTampil", nil)
tampil = nil
end
if tampil ~= nil then
if custom then
if tampil ~= custom then d:SetAttribute("ZenoxNamaTampil", custom); d.Text = custom end
jumlah = jumlah + 1
else
d.Text = d:GetAttribute("ZenoxNamaAsli") or d.Text
d:SetAttribute("ZenoxNamaAsli", nil); d:SetAttribute("ZenoxNamaTampil", nil)
end
elseif custom then
local t = string.lower(trim((string.gsub(d.Text or "", "<[^>]->", ""))))
t = string.gsub(t, "^@", "")
t = string.gsub(t, ":$", "")
if t ~= "" and (t == string.lower(me.Name) or t == string.lower(me.DisplayName or "")) then
d:SetAttribute("ZenoxNamaAsli", d.Text)
d:SetAttribute("ZenoxNamaTampil", custom)
d.Text = custom
jumlah = jumlah + 1
end
end
end
end
end
return jumlah
end
function F.namaSet(v)
if type(v) == "string" and v ~= "" and not F.izin("fake") then F.kunci("fake"); return end
local t = trim((string.gsub(tostring(v or ""), "[<>]", "")))
S.namaCustom = (t ~= "" and string.sub(t, 1, 24)) or nil
if not S.namaCustom then
pcall(F.namaSapu, nil)
F.catat("custom name: kembali ke nama asli")
return
end
pcall(F.namaSapu, S.namaCustom)
F.catat("custom name: " .. S.namaCustom)
if S.namaJalan then return end
S.namaJalan = true
task.spawn(function()
while S.namaCustom do
local ok, e = pcall(F.namaSapu, S.namaCustom)
if not ok then F.catat("custom name error: " .. string.sub(tostring(e), 1, 90)) end
task.wait(1)
end
S.namaJalan = false
end)
end
function F.centangSet(v)
if v and not F.izin("fake") then F.kunci("fake"); return end
S.centang = v and true or false
F.centangSync()
F.catat("centang biru lokal " .. (S.centang and "ON" or "OFF"))
F.segarkanUI()
end
local CLONE = (function()
local inPlaceBackup = {}
local inPlaceUserId = nil
local buildR15Model = nil
local function log(...)
local t = {}
for i = 1, select("#", ...) do t[i] = tostring((select(i, ...))) end
F.catat(table.concat(t, " "))
end
local function restoreToggleEffects(character) end
local player = me
local running = true
local autoApply = true
local AutoApplyToggle = nil
local Window = nil
local targetInput = ""
local fake, real = nil, nil
local lastUserId, lastBuilder = nil, nil
local ours = {}
local copying = false
local savedLeg = nil
local stopEmoteSupport = nil
local reapplyBusy = false
local reapplyTimes = {}
local MAX_REAPPLY = 3
local REAPPLY_WINDOW = 60
local pendingRestore = {}
local RunService = RS
local ContentProvider = game:GetService("ContentProvider")
local trackedGuis = {}
local customName, prevCustomName = nil, nil
local ownEmoteData = nil
local lastEmotes = {}
local setupEmoteSupport = nil
local function notify(title, text)
F.catat(tostring(title) .. ": " .. string.sub(tostring(text), 1, 140))
end
local function nametagApply(char, on)
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
if on then
if hum:GetAttribute("zxDDT") == nil then hum:SetAttribute("zxDDT", hum.DisplayDistanceType.Name) end
pcall(function() hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
else
local asal = hum:GetAttribute("zxDDT")
if asal then
pcall(function() hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType[asal] end)
hum:SetAttribute("zxDDT", nil)
end
end
end
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BillboardGui") then
if on then
if d:GetAttribute("zxEn") == nil then d:SetAttribute("zxEn", d.Enabled) end
d.Enabled = false
else
local asal = d:GetAttribute("zxEn")
if asal ~= nil then d.Enabled = asal; d:SetAttribute("zxEn", nil) end
end
end
end
end
local function nametagPlayer(on) nametagApply(me.Character, on); local mT = F.target(); if mT and mT ~= me.Character then nametagApply(mT, on) end end
local function turnOffToggles()
pendingRestore = {kor = S.kor.on == true, kiri = S.kiri.on == true, head = S.headOn == true}
if S.bodyOn then pcall(F.bodySet, false); S.bodyId = nil end
if pendingRestore.kor then pcall(F.korSet, false) end
if pendingRestore.kiri then pcall(F.kiriSet, false) end
if pendingRestore.head then pcall(F.headSet, false) end
end
local function getDescription(userId)
local lastErr = "unknown"
for attempt = 1, 3 do
local ok, res = pcall(function()
return Players:GetHumanoidDescriptionFromUserId(userId)
end)
if ok and res then
return res, nil
end
lastErr = tostring(res)
log("Ambil deskripsi gagal (percobaan " .. attempt .. "): " .. lastErr)
task.wait(1)
end
return nil, lastErr
end
local R6_PART_NAMES = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local function isAppearanceItem(c)
return c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic")
or c:IsA("CharacterMesh") or c:IsA("BodyColors")
end
local function restoreInPlace(model)
local rec = inPlaceBackup[model]
if not rec then
return
end
inPlaceBackup[model] = nil
if model.Parent == nil then
return
end
local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true)
for _, c in ipairs(model:GetChildren()) do
if c:GetAttribute("KA_Copy") then
c:Destroy()
end
end
local head = model:FindFirstChild("Head")
for _, p in ipairs(model:GetChildren()) do
if p:IsA("BasePart") then
for _, c in ipairs(p:GetChildren()) do
if c:GetAttribute("KA_Copy") then
c:Destroy()
end
end
end
end
if rec.r15 then
local r = rec.r15
for cur, j in pairs(r.joints) do
if cur.Parent then
cur.C0 = j.c0
cur.C1 = j.c1
end
end
for a, cf in pairs(r.atts) do
if a.Parent then
a.CFrame = cf
end
end
for part, d in pairs(r.parts) do
if part.Parent then
if d.mesh then
pcall(function()
part.MeshId = d.mesh
end)
pcall(function()
part.TextureID = d.tex
end)
end
pcall(function()
part.Size = d.size
end)
part.Color = d.color
if d.sa then
d.sa.Parent = part
end
end
end
if hum then
pcall(function()
hum.HipHeight = r.hip
end)
end
end
for _, item in ipairs(rec.items) do
if item:IsA("Accessory") and hum then
local okAdd = pcall(function()
hum:AddAccessory(item)
end)
if not okAdd or item.Parent ~= model then
item.Parent = model
end
else
item.Parent = model
end
end
if head then
if rec.headMesh then
rec.headMesh.Parent = head
end
if rec.face and rec.face.decal and rec.face.decal.Parent then
rec.face.decal.Texture = rec.face.tex
end
end
for name, color in pairs(rec.colors) do
local part = model:FindFirstChild(name)
if part and part:IsA("BasePart") then
part.Color = color
end
end
end
local function resetInPlace()
local any = false
for model in pairs(inPlaceBackup) do
local okR, eR = pcall(restoreInPlace, model)
if not okR then log("reset error: " .. tostring(eR)) end
any = true
end
inPlaceBackup = {}
inPlaceUserId = nil
if player.Character then
for _, c in ipairs(player.Character:GetChildren()) do
if c:GetAttribute("KA_Copy") then pcall(function() c:Destroy() end); any = true end
end
end
return any
end
local function attachAccessoryInPlace(model, acc)
local handle = acc:FindFirstChild("Handle")
if not handle or not handle:IsA("BasePart") then
acc.Parent = model
return
end
for _, d in ipairs(acc:GetDescendants()) do
if d:IsA("JointInstance") and d.Name == "AccessoryWeld" then
d:Destroy()
end
end
for _, d in ipairs(acc:GetDescendants()) do
if d:IsA("BasePart") then
d.CanCollide = false
d.CanTouch = false
d.CanQuery = false
d.Massless = true
d.Anchored = false
end
end
local att0, att1 = nil, nil
local hatAtt = handle:FindFirstChild("HatAttachment")
local order = {}
if hatAtt and hatAtt:IsA("Attachment") then
table.insert(order, hatAtt)
end
for _, a in ipairs(handle:GetChildren()) do
if a:IsA("Attachment") and a ~= hatAtt then
table.insert(order, a)
end
end
for _, a in ipairs(order) do
if not att1 then
for _, p in ipairs(model:GetChildren()) do
if p:IsA("BasePart") then
local x = p:FindFirstChild(a.Name)
if x and x:IsA("Attachment") then
att0, att1 = x, a
break
end
end
end
end
end
acc.Parent = model
task.wait()
local good = false
for _, d in ipairs(handle:GetChildren()) do
if d:IsA("JointInstance") and d.Part1 == handle and d.Part0 and d.Part0:IsDescendantOf(model) then
good = true
break
end
end
if good then
return
end
local w = Instance.new("Weld")
w.Name = "AccessoryWeld"
if att0 and att1 then
w.Part0 = att0.Parent
w.Part1 = handle
w.C0 = att0.CFrame
w.C1 = att1.CFrame
else
local head = model:FindFirstChild("Head")
if not head then
return
end
w.Part0 = head
w.Part1 = handle
w.C0 = CFrame.new(0, head.Size.Y / 2, 0)
w.C1 = CFrame.new()
end
w.Parent = handle
end
local function applyR15Body(model, ref, hum, rec)
local data = {parts = {}, joints = {}, atts = {}, hip = hum.HipHeight}
rec.r15 = data
local refHum = ref:FindFirstChildOfClass("Humanoid")
for _, refPart in ipairs(ref:GetChildren()) do
if refPart:IsA("BasePart") and refPart.Name ~= "HumanoidRootPart" then
local part = model:FindFirstChild(refPart.Name)
if part and part:IsA("BasePart") then
local d = {size = part.Size, color = part.Color}
data.parts[part] = d
if part:IsA("MeshPart") and refPart:IsA("MeshPart") then
d.mesh = part.MeshId
d.tex = part.TextureID
pcall(function()
part.MeshId = refPart.MeshId
end)
pcall(function()
part.TextureID = refPart.TextureID
end)
local curSA = part:FindFirstChildOfClass("SurfaceAppearance")
if curSA then
d.sa = curSA
curSA.Parent = nil
end
local refSA = refPart:FindFirstChildOfClass("SurfaceAppearance")
if refSA then
local c = refSA:Clone()
c:SetAttribute("KA_Copy", true)
c.Parent = part
end
end
pcall(function()
part.Size = refPart.Size
end)
part.Color = refPart.Color
for _, a in ipairs(refPart:GetChildren()) do
if a:IsA("Attachment") then
local ca = part:FindFirstChild(a.Name)
if ca and ca:IsA("Attachment") then
data.atts[ca] = ca.CFrame
ca.CFrame = a.CFrame
end
end
end
end
end
end
for _, j in ipairs(ref:GetDescendants()) do
if j:IsA("Motor6D") and j.Part1 then
local p1 = model:FindFirstChild(j.Part1.Name)
local cur = p1 and p1:FindFirstChild(j.Name)
if cur and cur:IsA("Motor6D") then
data.joints[cur] = {c0 = cur.C0, c1 = cur.C1}
cur.C0 = j.C0
cur.C1 = j.C1
end
end
end
if refHum then
pcall(function()
hum.HipHeight = refHum.HipHeight
end)
end
end
local function applyAppearanceInPlace(model, userId, descOverride)
local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true)
if not hum then
return false, "Humanoid tidak ditemukan"
end
local isR15 = hum.RigType == Enum.HumanoidRigType.R15
if hum.RigType ~= Enum.HumanoidRigType.R6 and not isR15 then
return false, "Tipe rig tidak didukung"
end
if hum.Health <= 0 then
return false, "Karakter sedang mati, tunggu respawn"
end
local desc, descErr
if descOverride then desc = descOverride else desc, descErr = getDescription(userId) end
if not desc then
return false, "Gagal ambil data avatar: " .. tostring(descErr)
end
local okM, ref = pcall(function()
if isR15 and buildR15Model then
return buildR15Model(desc, Enum.HumanoidRigType.R15)
end
return Players:CreateHumanoidModelFromDescription(
desc, isR15 and Enum.HumanoidRigType.R15 or Enum.HumanoidRigType.R6)
end)
if not okM or not ref then
return false, "Gagal buat model referensi: " .. tostring(ref)
end
pcall(restoreInPlace, model)
pcall(restoreToggleEffects, model)
local rec = {items = {}, colors = {}, headMesh = nil, face = nil}
inPlaceBackup[model] = rec
for _, c in ipairs(model:GetChildren()) do
if isAppearanceItem(c) and not c:GetAttribute("KA_Copy") then
table.insert(rec.items, c)
c.Parent = nil
end
end
for _, refPart in ipairs(ref:GetChildren()) do
if refPart:IsA("BasePart") then
local part = model:FindFirstChild(refPart.Name)
if part and part:IsA("BasePart") then
for _, a in ipairs(refPart:GetChildren()) do
if a:IsA("Attachment") and not part:FindFirstChild(a.Name) then
local na = a:Clone()
na:SetAttribute("KA_Copy", true)
na.Parent = part
end
end
end
end
end
for _, c in ipairs(ref:GetChildren()) do
if isAppearanceItem(c) then
local cl = c:Clone()
for _, d in ipairs(cl:GetDescendants()) do
if d:IsA("LuaSourceContainer") then
d:Destroy()
end
end
cl:SetAttribute("KA_Copy", true)
if cl:IsA("Accessory") then
attachAccessoryInPlace(model, cl)
else
cl.Parent = model
end
end
end
if isR15 then
pcall(applyR15Body, model, ref, hum, rec)
end
local head = model:FindFirstChild("Head")
local refHead = ref:FindFirstChild("Head")
if head and refHead then
local refMesh = refHead:FindFirstChildOfClass("SpecialMesh")
local curMesh = head:FindFirstChildOfClass("SpecialMesh")
if refMesh then
if curMesh then
rec.headMesh = curMesh:Clone()
curMesh:Destroy()
end
local cm = refMesh:Clone()
cm:SetAttribute("KA_Copy", true)
cm.Parent = head
end
local refFace = refHead:FindFirstChildWhichIsA("Decal")
local curFace = head:FindFirstChildWhichIsA("Decal")
if refFace then
if curFace then
rec.face = {decal = curFace, tex = curFace.Texture}
curFace.Texture = refFace.Texture
else
local nf = refFace:Clone()
nf:SetAttribute("KA_Copy", true)
nf.Parent = head
end
end
end
for _, name in ipairs(R6_PART_NAMES) do
local part = model:FindFirstChild(name)
local refPart = ref:FindFirstChild(name)
if part and refPart and part:IsA("BasePart") and refPart:IsA("BasePart") then
rec.colors[name] = part.Color
part.Color = refPart.Color
end
end
pcall(function()
ref:Destroy()
end)
inPlaceUserId = userId
log("Copy R6 di tempat selesai: " .. model:GetFullName() .. " | item lama dicadangkan: " .. tostring(#rec.items))
return true, "tampilan berhasil disalin (karakter & isi map tidak diubah)"
end
local R15_BODY_SLOTS = {
{prop = "Head", parts = {"Head"}},
{prop = "Torso", parts = {"UpperTorso", "LowerTorso"}},
{prop = "LeftArm", parts = {"LeftUpperArm", "LeftLowerArm", "LeftHand"}},
{prop = "RightArm", parts = {"RightUpperArm", "RightLowerArm", "RightHand"}},
{prop = "LeftLeg", parts = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}},
{prop = "RightLeg", parts = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}},
}
local R15_COLORS = {
{prop = "HeadColor", parts = {"Head"}},
{prop = "TorsoColor", parts = {"UpperTorso", "LowerTorso"}},
{prop = "LeftArmColor", parts = {"LeftUpperArm", "LeftLowerArm", "LeftHand"}},
{prop = "RightArmColor", parts = {"RightUpperArm", "RightLowerArm", "RightHand"}},
{prop = "LeftLegColor", parts = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}},
{prop = "RightLegColor", parts = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}},
}
local R15_SCALE_PROPS = {"HeightScale", "WidthScale", "DepthScale", "HeadScale", "BodyTypeScale", "ProportionScale"}
buildR15Model = function(desc, rigType)
if rigType ~= Enum.HumanoidRigType.R15 then
return Players:CreateHumanoidModelFromDescription(desc, rigType)
end
local model = nil
local okA, resA = pcall(function()
return Players:CreateHumanoidModelFromDescription(
desc, Enum.HumanoidRigType.R15, Enum.AssetTypeVerification.Always)
end)
if okA and resA then
model = resA
else
model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
end
local fixed = 0
for _, slot in ipairs(R15_BODY_SLOTS) do
local id = 0
pcall(function()
id = desc[slot.prop]
end)
if type(id) == "number" and id > 0 then
local okS, ref = pcall(function()
local d = Instance.new("HumanoidDescription")
d[slot.prop] = id
return Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R15)
end)
if okS and ref then
for _, name in ipairs(slot.parts) do
local part = model:FindFirstChild(name)
local refPart = ref:FindFirstChild(name)
if part and refPart and part:IsA("MeshPart") and refPart:IsA("MeshPart") then
if part.MeshId ~= refPart.MeshId then
pcall(function()
part.MeshId = refPart.MeshId
end)
fixed = fixed + 1
log("R15 body diperbaiki: " .. name .. " -> " .. tostring(refPart.MeshId))
end
if part.TextureID ~= refPart.TextureID then
pcall(function()
part.TextureID = refPart.TextureID
end)
end
local refSA = refPart:FindFirstChildOfClass("SurfaceAppearance")
local curSA = part:FindFirstChildOfClass("SurfaceAppearance")
if refSA and (not curSA or curSA.ColorMap ~= refSA.ColorMap) then
if curSA then
curSA:Destroy()
end
refSA:Clone().Parent = part
end
end
end
pcall(function()
ref:Destroy()
end)
else
warn("[clone] R15 slot " .. slot.prop .. " gagal dicek: " .. tostring(ref))
end
end
end
for _, c in ipairs(R15_COLORS) do
local color = nil
pcall(function()
color = desc[c.prop]
end)
if typeof(color) == "Color3" then
for _, name in ipairs(c.parts) do
local part = model:FindFirstChild(name)
if part and part:IsA("BasePart") then
part.Color = color
end
end
end
end
local hum = model:FindFirstChildOfClass("Humanoid")
if hum then
local okG, applied = pcall(function()
return hum:GetAppliedDescription()
end)
if okG and applied then
for _, slot in ipairs(R15_BODY_SLOTS) do
local a, b = nil, nil
pcall(function()
a, b = applied[slot.prop], desc[slot.prop]
end)
if a ~= b then
log("R15 beda slot " .. slot.prop .. ": applied=" .. tostring(a) .. " target=" .. tostring(b))
end
end
for _, p in ipairs(R15_SCALE_PROPS) do
local a, b = nil, nil
pcall(function()
a, b = applied[p], desc[p]
end)
if type(a) == "number" and type(b) == "number" and math.abs(a - b) > 0.01 then
log("R15 beda skala " .. p .. ": applied=" .. tostring(a) .. " target=" .. tostring(b))
end
end
end
end
log("buildR15Model selesai | slot diperbaiki: " .. tostring(fixed))
return model
end
local GameRoot = {template = {}, conn = nil, made = 0}
function GameRoot.snapshot(char)
if not char or ours[char] or char == fake then
return
end
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp then
return
end
for _, ch in ipairs(hrp:GetChildren()) do
if GameRoot.template[ch.Name] == nil
and (ch:IsA("Attachment") or ch:IsA("ValueBase") or ch:IsA("Folder") or ch:IsA("Configuration")) then
local ok, cl = pcall(function()
return ch:Clone()
end)
if ok and cl then
GameRoot.template[ch.Name] = cl
end
end
end
end
function GameRoot.ensure(char)
if not char then
return
end
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp or not hrp:IsA("BasePart") then
return
end
for name, tpl in pairs(GameRoot.template) do
if not hrp:FindFirstChild(name) then
local ok, cl = pcall(function()
return tpl:Clone()
end)
if ok and cl then
cl.Parent = hrp
end
end
end
if not hrp:FindFirstChild("headpos") then
local a = Instance.new("Attachment")
a.Name = "headpos"
local head = char:FindFirstChild("Head")
if head and head:IsA("BasePart") then
a.Position = hrp.CFrame:PointToObjectSpace(head.Position)
else
a.Position = Vector3.new(0, 1.5, 0)
end
a.Parent = hrp
GameRoot.made = GameRoot.made + 1
if GameRoot.made <= 3 then
log("headpos dibuat otomatis di " .. char:GetFullName())
end
end
end
pcall(GameRoot.snapshot, player.Character)
GameRoot.conn = RunService.Heartbeat:Connect(function()
if not running then
return
end
local c = player.Character
if not c then
return
end
if ours[c] or c == fake then
pcall(GameRoot.ensure, c)
else
pcall(GameRoot.snapshot, c)
end
end)
local function getUserId(target)
local fromLink = string.match(tostring(target), "users/(%d+)")
if fromLink then
return tonumber(fromLink)
end
if tonumber(target) then
return tonumber(target)
end
local name = tostring(target):lower()
for _, p in ipairs(Players:GetPlayers()) do
if p.Name:lower():sub(1, #name) == name
or p.DisplayName:lower():sub(1, #name) == name then
return p.UserId
end
end
local ok, id = pcall(function()
return Players:GetUserIdFromNameAsync(target)
end)
if ok then
return id
end
return nil
end
local function setCamera(model)
local cam = workspace.CurrentCamera
local hum = model and model:FindFirstChildOfClass("Humanoid")
if cam and hum then
cam.CameraType = Enum.CameraType.Custom
cam.CameraSubject = hum
end
end
local function plainReplace(text, from, to)
if from == nil or from == "" then
return text
end
local out = ""
local pos = 1
while true do
local a, b = string.find(text, from, pos, true)
if not a then
break
end
out = out .. string.sub(text, pos, a - 1) .. to
pos = b + 1
end
return out .. string.sub(text, pos)
end
local function forEachLabel(gui, fn)
for _, d in ipairs(gui:GetDescendants()) do
if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
fn(d)
end
end
end
local function collectGuis(character)
local guis = {}
if character then
for _, d in ipairs(character:GetDescendants()) do
if d:IsA("BillboardGui") then
guis[d] = true
end
end
end
for g in pairs(trackedGuis) do
if g.Parent ~= nil then
guis[g] = true
else
trackedGuis[g] = nil
end
end
return guis
end
local function applyBillboardNames(character)
if not customName then
return
end
local names = {}
local seen = {}
local function add(n)
if n and n ~= "" and not seen[n] and n ~= customName then
seen[n] = true
table.insert(names, n)
end
end
add(player.DisplayName)
add(player.Name)
table.sort(names, function(a, b)
return #a > #b
end)
local guis = collectGuis(character)
for gui in pairs(guis) do
forEachLabel(gui, function(label)
local text = label.Text
local newText = text
if prevCustomName and prevCustomName ~= customName
and string.find(text, prevCustomName, 1, true) then
newText = plainReplace(text, prevCustomName, customName)
elseif not string.find(text, customName, 1, true) then
for _, n in ipairs(names) do
newText = plainReplace(newText, n, customName)
end
end
if newText ~= text then
label.Text = newText
end
end)
end
end
local function restoreBillboardNames(character, oldName)
if not oldName then
return
end
local guis = collectGuis(character)
for gui in pairs(guis) do
forEachLabel(gui, function(label)
local newText = plainReplace(label.Text, oldName, player.DisplayName)
if newText ~= label.Text then
label.Text = newText
end
end)
end
end
local function transferNametags(fromChar, toChar)
local count = 0
if not fromChar or not toChar then
return count
end
for _, d in ipairs(fromChar:GetDescendants()) do
if d:IsA("BillboardGui") then
local parent = d.Parent
local target = nil
if parent == fromChar then
target = toChar
elseif parent and parent:IsA("BasePart") then
target = toChar:FindFirstChild(parent.Name, true)
end
if target and not target:FindFirstChild(d.Name) then
local c = d:Clone()
if d.Adornee then
c.Adornee = toChar:FindFirstChild(d.Adornee.Name, true)
elseif target == toChar then
c.Adornee = toChar:FindFirstChild("Head", true)
end
c.Parent = target
trackedGuis[c] = true
count = count + 1
end
end
end
return count
end
local function retargetExternalNametags(fromChar, toChar)
local count = 0
if not fromChar or not toChar then
return count
end
local roots = {workspace, player:FindFirstChildOfClass("PlayerGui")}
local checked = 0
for _, root in ipairs(roots) do
for _, d in ipairs(root:GetDescendants()) do
checked = checked + 1
if checked % 3000 == 0 then
task.wait()
end
if d:IsA("BillboardGui") and not d:IsDescendantOf(toChar) then
local adornee = d.Adornee
if adornee and adornee:IsDescendantOf(fromChar) then
local counterpart = toChar:FindFirstChild(adornee.Name, true)
if counterpart then
d.Adornee = counterpart
trackedGuis[d] = true
count = count + 1
end
end
end
end
end
return count
end
local function copyHumanoidProps(from, to)
pcall(function()
to.WalkSpeed = from.WalkSpeed
to.UseJumpPower = from.UseJumpPower
to.JumpPower = from.JumpPower
to.JumpHeight = from.JumpHeight
to.MaxHealth = from.MaxHealth
to.Health = from.Health
to.DisplayName = from.DisplayName
to.AutoRotate = from.AutoRotate
end)
pcall(function()
to.DisplayDistanceType = from.DisplayDistanceType
to.NameDisplayDistance = from.NameDisplayDistance
to.HealthDisplayType = from.HealthDisplayType
to.HealthDisplayDistance = from.HealthDisplayDistance
end)
end
local extraTargets = {}
local lastTargetScan = -10
local pinnedTarget = nil
local function rootPos(model)
local r = model and model:FindFirstChild("HumanoidRootPart")
if r and r:IsA("BasePart") then
return r.Position
end
return nil
end
local function scanExtraTargets()
local list = {}
local seen = {}
local mine = player.Character
local function consider(m)
if m and m:IsA("Model") and m ~= mine and not seen[m] and m.Parent ~= nil then
seen[m] = true
table.insert(list, m)
end
end
if pinnedTarget then
if pinnedTarget.Parent ~= nil then
consider(pinnedTarget)
else
pinnedTarget = nil
end
end
local cam = workspace.CurrentCamera
local subject = cam and cam.CameraSubject
if subject then
local m = nil
if subject:IsA("Humanoid") then
m = subject.Parent
elseif subject:IsA("BasePart") then
m = subject:FindFirstAncestorOfClass("Model")
end
if m then
if mine then
local a, b = rootPos(m), rootPos(mine)
if a and b and (a - b).Magnitude < 25 then
consider(m)
end
else
local owner = Players:GetPlayerFromCharacter(m)
if owner == nil or owner == player then
consider(m)
end
end
end
end
local function scan(parent, depth)
for _, c in ipairs(parent:GetChildren()) do
if c:IsA("Model") and (c.Name == player.Name or c.Name == player.DisplayName)
and c:FindFirstChild("Head") then
consider(c)
end
if depth < 3 and (c:IsA("Folder") or c:IsA("Model")) then
scan(c, depth + 1)
end
end
end
scan(workspace, 1)
extraTargets = list
end
local function visualTargets()
local out = {}
local mine = player.Character
if mine then
table.insert(out, mine)
end
for _, m in ipairs(extraTargets) do
if m.Parent ~= nil and m ~= mine then
table.insert(out, m)
end
end
return out
end
local DEFAULT_ANIMS_R15 = {
idle = "rbxassetid://507766666",
walk = "rbxassetid://507777826",
run = "rbxassetid://507767714",
jump = "rbxassetid://507765000",
fall = "rbxassetid://507767968",
climb = "rbxassetid://507765644",
swim = "rbxassetid://507784897",
swimidle = "rbxassetid://507785072",
sit = "rbxassetid://2506281703",
}
local DEFAULT_ANIMS_R6 = {
idle = "rbxassetid://180435571",
walk = "rbxassetid://180426354",
run = "rbxassetid://180426354",
jump = "rbxassetid://125750702",
fall = "rbxassetid://180436148",
climb = "rbxassetid://180436334",
sit = "rbxassetid://178130996",
}
local ANIM_SOURCES = {
{name = "idle", field = "IdleAnimation", folder = "idle", anim = "Animation1", loop = true},
{name = "walk", field = "WalkAnimation", folder = "walk", anim = "WalkAnim", loop = true},
{name = "run", field = "RunAnimation", folder = "run", anim = "RunAnim", loop = true},
{name = "jump", field = "JumpAnimation", folder = "jump", anim = "JumpAnim", loop = false},
{name = "fall", field = "FallAnimation", folder = "fall", anim = "FallAnim", loop = true},
{name = "climb", field = "ClimbAnimation", folder = "climb", anim = "ClimbAnim", loop = true},
{name = "swim", field = "SwimAnimation", folder = "swim", anim = "Swim", loop = true},
{name = "swimidle", field = "SwimAnimation", folder = "swimidle", anim = "SwimIdle", loop = true, strict = true},
{name = "sit", field = nil, folder = "sit", anim = "SitAnim", loop = true},
}
local assetCache = {}
local function readAnimationAsset(assetId)
if assetCache[assetId] ~= nil then
return assetCache[assetId]
end
local list = {}
local roots = nil
local ok, objs = pcall(function()
return game:GetObjects("rbxassetid://" .. tostring(assetId))
end)
if ok and type(objs) == "table" then
roots = objs
else
local ok2, model = pcall(function()
return game:GetService("InsertService"):LoadAsset(assetId)
end)
if ok2 and model then
roots = {model}
end
end
if roots then
for _, obj in ipairs(roots) do
if obj:IsA("Animation") and obj.AnimationId ~= "" then
table.insert(list, {name = obj.Name, id = obj.AnimationId})
end
for _, d in ipairs(obj:GetDescendants()) do
if d:IsA("Animation") and d.AnimationId ~= "" then
table.insert(list, {name = d.Name, id = d.AnimationId})
end
end
pcall(function()
obj:Destroy()
end)
end
else
warn("[clone] Gagal membaca asset animasi " .. tostring(assetId) .. " (GetObjects/LoadAsset tidak tersedia di executor ini)")
end
assetCache[assetId] = list
return list
end
local function pickFromAsset(list, animName, strict)
for _, a in ipairs(list) do
if a.name == animName then
return a.id
end
end
if not strict and #list == 1 then
return list[1].id
end
return nil
end
local ANIM_PAKAI_TARGET = false
local function getCandidates(info, desc, srcAnimate, defaults, isR15)
local list = {}
local function add(id, label)
if not id or id == "" or id == "rbxassetid://0" then
return
end
for _, v in ipairs(list) do
if v.id == id then
return
end
end
table.insert(list, {id = id, label = label})
end
if ANIM_PAKAI_TARGET and isR15 and info.field then
local ok, value = pcall(function()
return desc[info.field]
end)
if ok and type(value) == "number" and value > 0 then
local assetList = readAnimationAsset(value)
local fromAsset = pickFromAsset(assetList, info.anim, info.strict)
if fromAsset then
add(fromAsset, "target (isi asset " .. tostring(value) .. ")")
end
add("rbxassetid://" .. tostring(value), "target (langsung " .. tostring(value) .. ")")
else
log("Avatar target tidak punya animasi khusus untuk: " .. info.name)
end
end
if srcAnimate then
local folder = srcAnimate:FindFirstChild(info.folder)
local anim = folder and folder:FindFirstChild(info.anim)
if anim and anim:IsA("Animation") then
add(anim.AnimationId, "animasi game")
end
end
add(defaults[info.name], "bawaan Roblox")
return list
end
local function loadTrack(animator, candidates)
for _, cand in ipairs(candidates) do
local anim = Instance.new("Animation")
anim.AnimationId = cand.id
local okLoad, track = pcall(function()
return animator:LoadAnimation(anim)
end)
if okLoad and track then
pcall(function()
ContentProvider:PreloadAsync({anim})
end)
local waited = 0
while track.Length == 0 and waited < 1.5 do
task.wait(0.1)
waited = waited + 0.1
end
if track.Length > 0 then
return track, cand.id, cand.label
end
pcall(function()
track:Destroy()
end)
end
anim:Destroy()
end
return nil, nil, nil
end
local RUN_SPEED_ENTER = 20
local RUN_SPEED_EXIT = 17
local WALK_ANIM_BASE = 16
local RUN_ANIM_BASE = 24
local function startAnimDriver(model, hum, root, tracks)
local current = nil
local conn = nil
local runConn = nil
local jumpConn = nil
local groundSpeed = 0
local freefallTime = 0
local jumpTimer = 0
local useRun = false
local lastMode = nil
local warnedRun = false
local smooth = 1
local function stopAll()
for _, t in pairs(tracks) do
if t.IsPlaying then
t:Stop(0.1)
end
end
current = nil
end
local function cleanup()
if conn then
conn:Disconnect()
end
if runConn then
runConn:Disconnect()
end
if jumpConn then
jumpConn:Disconnect()
end
stopAll()
end
local function play(name, speed)
local t = tracks[name]
if not t then
return
end
if current ~= name then
local prev = current and tracks[current]
if prev and prev.IsPlaying then
prev:Stop(0.2)
end
t:Play(0.2)
current = name
end
local spd = speed or 1
if math.abs(t.Speed - spd) > 0.02 then
t:AdjustSpeed(spd)
end
end
runConn = hum.Running:Connect(function(speed)
groundSpeed = speed
end)
jumpConn = hum.Jumping:Connect(function(active)
if active then
jumpTimer = 0.31
end
end)
conn = RunService.Heartbeat:Connect(function(dt)
if not running or model.Parent == nil or hum.Parent ~= model then
cleanup()
return
end
if hum.Health <= 0 then
stopAll()
return
end
local state = hum:GetState()
local vel = root.AssemblyLinearVelocity
local hspeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
if state == Enum.HumanoidStateType.Freefall then
freefallTime = freefallTime + dt
else
freefallTime = 0
end
if jumpTimer > 0 then
jumpTimer = jumpTimer - dt
end
if hum.Sit or state == Enum.HumanoidStateType.Seated then
if tracks.sit then
play("sit", 1)
else
play("idle", 1)
end
elseif state == Enum.HumanoidStateType.Climbing then
play("climb", math.abs(vel.Y) / 5)
elseif state == Enum.HumanoidStateType.Swimming then
if hspeed > 1 then
play("swim", hspeed / 10)
elseif tracks.swimidle then
play("swimidle", 1)
else
play("swim", 0)
end
elseif jumpTimer > 0 then
play("jump", 1)
elseif state == Enum.HumanoidStateType.Freefall and freefallTime > 0.2 then
play("fall", 1)
else
local speed = groundSpeed
if speed < 0.1 and hum.MoveDirection.Magnitude > 0.1 and hspeed > 1 then
speed = hspeed
end
local threshold = 0.75
if current == "walk" or current == "run" then
threshold = 0.4
end
if speed > threshold then
if useRun then
if speed < RUN_SPEED_EXIT then
useRun = false
end
else
if speed > RUN_SPEED_ENTER then
useRun = true
end
end
if useRun and not tracks.run and not warnedRun then
warnedRun = true
warn("[clone] Animasi run tidak termuat, memakai animasi walk")
end
local mode = "walk"
local target = speed / WALK_ANIM_BASE
if useRun and tracks.run then
mode = "run"
target = speed / RUN_ANIM_BASE
end
if mode ~= lastMode then
smooth = target
lastMode = mode
end
local alpha = math.clamp(dt * 12, 0, 1)
smooth = smooth + (target - smooth) * alpha
play(mode, smooth)
else
smooth = 1
lastMode = nil
play("idle", 1)
end
end
end)
end
local function setupAnimations(model, hum, root, desc, source, isR15)
local animator = hum:FindFirstChildOfClass("Animator")
if not animator then
animator = Instance.new("Animator")
animator.Parent = hum
end
local srcAnimate = source and source:FindFirstChild("Animate")
local defaults = DEFAULT_ANIMS_R6
if isR15 then
defaults = DEFAULT_ANIMS_R15
end
local tracks = {}
startAnimDriver(model, hum, root, tracks)
pcall(function()
log("Animasi target (tidak dipakai) -> idle=" .. tostring(desc.IdleAnimation)
.. " walk=" .. tostring(desc.WalkAnimation)
.. " run=" .. tostring(desc.RunAnimation)
.. " jump=" .. tostring(desc.JumpAnimation)
.. " fall=" .. tostring(desc.FallAnimation)
.. " climb=" .. tostring(desc.ClimbAnimation)
.. " swim=" .. tostring(desc.SwimAnimation))
end)
for _, info in ipairs(ANIM_SOURCES) do
if model.Parent == nil then
return
end
local candidates = getCandidates(info, desc, srcAnimate, defaults, isR15)
local track, usedId, label = loadTrack(animator, candidates)
if track then
track.Looped = info.loop
tracks[info.name] = track
log("Animasi " .. info.name .. " dimuat [" .. tostring(label) .. "]: " .. tostring(usedId))
else
warn("[clone] Animasi " .. info.name .. " gagal dimuat")
end
end
log("Semua animasi selesai diproses")
end
local function detectRig(model)
local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true)
if hum then
return hum.RigType, hum
end
if model:FindFirstChild("UpperTorso") or model:FindFirstChild("RightUpperLeg") then
return Enum.HumanoidRigType.R15, nil
end
if model:FindFirstChild("Torso") then
return Enum.HumanoidRigType.R6, nil
end
return nil, nil
end
local function findSourceCharacter()
local mine = player.Character
if mine then
local hum = mine:FindFirstChildOfClass("Humanoid") or mine:FindFirstChildWhichIsA("Humanoid", true)
if hum then
return mine, hum, hum.RigType
end
end
local cam = workspace.CurrentCamera
local subject = cam and cam.CameraSubject
if subject and subject:IsA("Humanoid") and subject.Parent then
local owner = Players:GetPlayerFromCharacter(subject.Parent)
if owner == nil or owner == player then
return subject.Parent, subject, subject.RigType
end
end
pcall(scanExtraTargets)
for _, t in ipairs(extraTargets) do
local hum = t:FindFirstChildOfClass("Humanoid") or t:FindFirstChildWhichIsA("Humanoid", true)
if hum then
return t, hum, hum.RigType
end
end
local candidates = {}
if mine then
table.insert(candidates, mine)
end
for _, t in ipairs(extraTargets) do
table.insert(candidates, t)
end
for _, t in ipairs(candidates) do
local r = detectRig(t)
if r then
return t, nil, r
end
end
return nil, nil, nil
end
local function loadOwnEmotes()
if ownEmoteData then
return ownEmoteData
end
local data = {emotes = {}, equipped = {}}
local d = getDescription(player.UserId)
if d then
pcall(function()
data.emotes = d:GetEmotes()
end)
pcall(function()
data.equipped = d:GetEquippedEmotes()
end)
end
ownEmoteData = data
return data
end
local function transferGameParts(fromChar, toChar)
local copied = {}
if not fromChar or not toChar then
return copied
end
local function allowed(c)
if c:IsA("JointInstance") or c:IsA("DataModelMesh") or c:IsA("Decal") or c:IsA("Texture")
or c:IsA("SurfaceAppearance") or c:IsA("LuaSourceContainer") or c:IsA("BillboardGui")
or c:IsA("Constraint") or c:IsA("BodyMover") or c:IsA("Tool") or c:IsA("Accessory")
or c:IsA("Clothing") or c:IsA("ShirtGraphic") or c:IsA("CharacterMesh") or c:IsA("BodyColors")
or c:IsA("Humanoid") or c:IsA("Animator") or c:IsA("ForceField") then
return false
end
return true
end
local function copyAttrs(a, b)
for k, v in pairs(a:GetAttributes()) do
if string.sub(k, 1, 3) ~= "KA_" and b:GetAttribute(k) == nil then
pcall(function()
b:SetAttribute(k, v)
end)
end
end
end
local function cloneInto(child, parent, label, origRef, twinRef)
local ok, cl = pcall(function()
return child:Clone()
end)
if not ok or not cl then
return
end
for _, d in ipairs(cl:GetDescendants()) do
if d:IsA("LuaSourceContainer") then
d:Destroy()
end
end
local weldIt = false
if cl:IsA("BasePart") and child:IsA("BasePart") and origRef and twinRef then
cl.Anchored = false
cl.CanCollide = false
cl.CanTouch = false
cl.CanQuery = false
cl.Massless = true
cl.CFrame = twinRef.CFrame * origRef.CFrame:ToObjectSpace(child.CFrame)
weldIt = true
end
cl.Parent = parent
if weldIt then
local w = Instance.new("WeldConstraint")
w.Part0 = twinRef
w.Part1 = cl
w.Parent = cl
end
table.insert(copied, label .. " (" .. cl.ClassName .. ")")
end
copyAttrs(fromChar, toChar)
do
local rootNames = {}
for _, ch in ipairs(fromChar:GetChildren()) do
table.insert(rootNames, ch.Name .. "<" .. ch.ClassName .. ">")
end
log("Isi karakter asli (" .. fromChar:GetFullName() .. "): " .. table.concat(rootNames, ", "))
local fromHrp0 = fromChar:FindFirstChild("HumanoidRootPart")
if fromHrp0 then
local hn = {}
for _, ch in ipairs(fromHrp0:GetChildren()) do
table.insert(hn, ch.Name .. "<" .. ch.ClassName .. ">")
end
log("Isi HumanoidRootPart asli: " .. table.concat(hn, ", "))
end
end
local fromRoot = fromChar:FindFirstChild("HumanoidRootPart")
local toRoot = toChar:FindFirstChild("HumanoidRootPart")
for _, c in ipairs(fromChar:GetChildren()) do
if c:IsA("BasePart") then
local twin = toChar:FindFirstChild(c.Name)
if twin and twin:IsA("BasePart") then
copyAttrs(c, twin)
for _, child in ipairs(c:GetChildren()) do
if allowed(child) and not twin:FindFirstChild(child.Name) then
cloneInto(child, twin, c.Name .. "." .. child.Name, c, twin)
end
end
end
elseif c:IsA("Humanoid") then
local th = toChar:FindFirstChildOfClass("Humanoid")
if th then
copyAttrs(c, th)
end
elseif allowed(c) and not toChar:FindFirstChild(c.Name) then
cloneInto(c, toChar, c.Name, fromRoot, toRoot)
end
end
if toRoot and not toRoot:FindFirstChild("headpos") then
local a = Instance.new("Attachment")
a.Name = "headpos"
local head = toChar:FindFirstChild("Head")
if head and head:IsA("BasePart") then
a.Position = toRoot.CFrame:PointToObjectSpace(head.Position)
else
a.Position = Vector3.new(0, 1.5, 0)
end
a.Parent = toRoot
table.insert(copied, "HumanoidRootPart.headpos (dibuat otomatis)")
end
return copied
end
local function copyAvatarInner(userId, builder, descOverride, rigOverride)
if not player.Character then
return false, "Belum ada karakter game (lobby). Masuk ke round dulu, atau pakai rig lobby (R6/R15 di tempat)"
end
local found, srcHum, rigType
if real then
local h = real:FindFirstChildOfClass("Humanoid") or real:FindFirstChildWhichIsA("Humanoid", true)
if h then
found, srcHum, rigType = real, h, h.RigType
end
end
if not found then
found, srcHum, rigType = findSourceCharacter()
end
if rigOverride then rigType = rigOverride end
local current = found
if real and player.Character then
current = player.Character
end
local source = real or current
if not current or not rigType then
return false, "Karakter/Humanoid tidak ditemukan"
end
if srcHum and srcHum.Health <= 0 then
return false, "Karakter sedang mati, tunggu respawn"
end
local desc, descErr
if descOverride then desc = descOverride else desc, descErr = getDescription(userId) end
if not desc then
return false, "Gagal ambil data avatar: " .. tostring(descErr)
end
local isR15 = rigType == Enum.HumanoidRigType.R15
local buildDesc = desc
if isR15 then
local data = loadOwnEmotes()
lastEmotes = data.emotes
local okC, cloned = pcall(function()
local x = desc:Clone()
x:SetEmotes(data.emotes)
x:SetEquippedEmotes(data.equipped)
return x
end)
if okC and cloned then
buildDesc = cloned
end
end
local okM, model = pcall(function()
if builder then
return builder(buildDesc, rigType)
end
return Players:CreateHumanoidModelFromDescription(buildDesc, rigType)
end)
if not okM or not model then
return false, "Gagal buat model avatar: " .. tostring(model)
end
local newHum = model:FindFirstChildOfClass("Humanoid")
local newRoot = model:FindFirstChild("HumanoidRootPart")
if not newHum or not newRoot then
model:Destroy()
return false, "Model avatar tidak lengkap (tanpa Humanoid/RootPart)"
end
ours[model] = true
model.PrimaryPart = newRoot
model.Name = player.Name
if srcHum then
copyHumanoidProps(srcHum, newHum)
end
do
local okT, listT = pcall(transferGameParts, source, model)
if okT then
log("Data game disalin ke model baru: " .. (#listT > 0 and table.concat(listT, ", ") or "tidak ada"))
else
warn("[clone] Gagal menyalin data game: " .. tostring(listT))
end
end
pcall(function()
model:PivotTo(current:GetPivot() * CFrame.new(0, 2, 0))
end)
if real == nil then
pcall(restoreToggleEffects, current)
end
local oldFake = fake
fake = model
if real == nil then
real = current
end
pcall(GameRoot.ensure, model)
model.Parent = workspace
player.Character = model
lastUserId = userId
lastBuilder = builder
if real and real.Parent ~= nil then
real.Parent = nil
end
if oldFake then
oldFake:Destroy()
end
task.spawn(function()
setupAnimations(model, newHum, newRoot, desc, source, isR15)
end)
if isR15 and setupEmoteSupport then
pcall(setupEmoteSupport, model, newHum, source)
end
task.spawn(function()
task.wait(0.5)
local moved = 0
local retargeted = 0
pcall(function()
moved = transferNametags(source, model)
end)
pcall(function()
retargeted = retargetExternalNametags(source, model)
end)
log("Nametag game: disalin=" .. tostring(moved) .. ", diarahkan=" .. tostring(retargeted))
end)
task.wait()
setCamera(model)
task.delay(0.5, function()
setCamera(model)
end)
return true, "avatar berhasil ditukar"
end
local function copyAvatar(userId, builder, descOverride, rigOverride)
if not F.izin("clone") then F.kunci("clone"); return false, "butuh key VVIP" end
if copying then
return false, "Copy sedang berjalan, tunggu sebentar"
end
copying = true
local ok, a, b = pcall(copyAvatarInner, userId, builder, descOverride, rigOverride)
copying = false
if not ok then
return false, "Error: " .. tostring(a)
end
return a, b
end
local function handleCopy(targetRaw)
local target = string.match(tostring(targetRaw or ""), "^%s*(.-)%s*$")
if target == nil or target == "" then
return false, "isi username dulu"
end
local userId = getUserId(target)
if not userId then
return false, "player tidak ditemukan (pakai link profil, UserId, atau username persis)"
end
turnOffToggles()
notify("Copy Avatar", "Mengambil avatar " .. tostring(userId) .. "...")
local srcModel, srcHumFound, srcRig = findSourceCharacter()
local ok, info
local inPlaceOk = srcModel ~= nil and srcHumFound ~= nil and not fake and not real
and (srcRig == Enum.HumanoidRigType.R6
or (srcRig == Enum.HumanoidRigType.R15 and srcModel ~= player.Character))
if inPlaceOk then
if copying then
ok, info = false, "Copy sedang berjalan, tunggu sebentar"
else
copying = true
local okP, a, b = pcall(applyAppearanceInPlace, srcModel, userId)
copying = false
if okP then
ok, info = a, b
else
ok, info = false, "Error: " .. tostring(a)
end
end
else
local builder = nil
if srcRig == Enum.HumanoidRigType.R15 then
builder = buildR15Model
end
ok, info = copyAvatar(userId, builder)
end
if ok then
notify("Berhasil", "Avatar " .. tostring(userId) .. ": " .. info)
else
notify("Gagal", info)
warn("[clone] Copy gagal: " .. tostring(info))
end
return ok, info
end
local function resetAvatar()
turnOffToggles()
local restoredInPlace = resetInPlace()
if stopEmoteSupport then
pcall(stopEmoteSupport)
end
if fake and real then
local oldFake = fake
local oldReal = real
local cf = oldFake:GetPivot()
fake = nil
real = nil
lastUserId = nil
pcall(function()
oldReal:PivotTo(cf * CFrame.new(0, 2, 0))
end)
oldReal.Parent = workspace
player.Character = oldReal
setCamera(oldReal)
oldFake:Destroy()
return true, "karakter asli dikembalikan"
end
restoreToggleEffects(player.Character)
if restoredInPlace then
return true, "tampilan asli dikembalikan"
end
return true, "efek Headless/Korblox dibersihkan"
end
local charConn = player.CharacterAdded:Connect(function(char)
if not running then
return
end
if ours[char] or char == fake or char == real then
return
end
log("Karakter baru dari server: " .. tostring(char.Name))
task.spawn(function()
char:WaitForChild("Humanoid", 10)
task.wait(0.5)
nametagApply(char, S.nametagHide == true)
end)
if inPlaceUserId and not fake then
inPlaceBackup = {}
if not autoApply then
inPlaceUserId = nil
log("Auto Apply mati, tampilan target tidak diterapkan ulang")
return
end
if reapplyBusy or copying then
log("Auto-apply sedang berjalan, event respawn ini diabaikan")
return
end
local uid = inPlaceUserId
reapplyBusy = true
task.spawn(function()
pcall(function()
char:WaitForChild("Humanoid", 10)
char:WaitForChild("HumanoidRootPart", 10)
end)
task.wait(1.5)
if running and player.Character == char then
local ok, info = applyAppearanceInPlace(char, uid)
notify(ok and "Respawn" or "Respawn gagal", ok and "Tampilan diterapkan ulang" or info)
end
task.wait(2)
reapplyBusy = false
end)
return
end
local hadFake = fake ~= nil
if fake then
pcall(function()
fake:Destroy()
end)
end
fake = nil
real = nil
savedLeg = nil
if not hadFake or not lastUserId then
return
end
if not autoApply then
lastUserId = nil
log("Auto Apply mati, avatar target tidak diterapkan ulang")
return
end
if reapplyBusy or copying then
log("Auto-apply sedang berjalan, event respawn ini diabaikan")
return
end
local now = os.clock()
local recent = {}
for _, t in ipairs(reapplyTimes) do
if now - t < REAPPLY_WINDOW then
table.insert(recent, t)
end
end
reapplyTimes = recent
if #reapplyTimes >= MAX_REAPPLY then
autoApply = false
lastUserId = nil
if AutoApplyToggle then
pcall(function()
AutoApplyToggle:Set(false)
end)
end
warn("[clone] Respawn berulang terdeteksi, Auto Apply dimatikan")
notify("Auto Apply", "Dimatikan karena respawn berulang. Tekan Copy Avatar lagi.")
return
end
table.insert(reapplyTimes, now)
local uid = lastUserId
local ub = lastBuilder
reapplyBusy = true
task.spawn(function()
pcall(function()
char:WaitForChild("Humanoid", 10)
char:WaitForChild("HumanoidRootPart", 10)
end)
task.wait(2)
if running and player.Character == char then
local ok, info = copyAvatar(uid, ub)
if ok then
notify("Respawn", "Avatar diterapkan ulang")
else
notify("Respawn", info)
end
else
log("Karakter sudah berubah sebelum apply, dibatalkan")
end
task.wait(3)
reapplyBusy = false
end)
end)
local function kirimLogClone(targetRaw, mode)
local url = (C.WEBHOOK_CLONE ~= "" and C.WEBHOOK_CLONE) or C.WEBHOOK_SARAN
if not httpReq or url == "" then log("log clone: webhook / executor tidak tersedia"); return end
local uid = getUserId(targetRaw)
if not uid then return end
local okN, namaT = pcall(function() return Players:GetNameFromUserIdAsync(uid) end)
local okD, desc = pcall(getDescription, uid)
if not okD then desc = nil end
local okW, waktu = pcall(function() return DateTime.now():ToIsoDate() end)
local function nilai(v) if v == nil then return "-" end; return tostring(v) end
local function ambil(p) local ok, v = pcall(function() return desc[p] end); if ok then return v end; return nil end
local function hexOf(v)
if typeof(v) ~= "Color3" then return "?" end
return string.format("#%02X%02X%02X", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
end
local baris = {}
local function tambah(s) table.insert(baris, s) end
tambah("CLONE AVATAR LOG")
tambah("Pengirim: " .. me.Name .. " (" .. tostring(me.UserId) .. ")")
tambah("Target: " .. (okN and namaT or tostring(targetRaw)) .. " (" .. tostring(uid) .. ")")
tambah("Mode: " .. tostring(mode) .. " | Waktu: " .. (okW and waktu or "-"))
if desc then
local bagian = {}
for _, p in ipairs({"Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
table.insert(bagian, p .. "=" .. nilai(ambil(p)))
end
tambah("BODY: " .. table.concat(bagian, " "))
local skala = {}
for _, p in ipairs({{"Height", "HeightScale"}, {"Width", "WidthScale"}, {"Depth", "DepthScale"}, {"Head", "HeadScale"}, {"BodyType", "BodyTypeScale"}, {"Proportion", "ProportionScale"}}) do
table.insert(skala, p[1] .. "=" .. nilai(ambil(p[2])))
end
tambah("SKALA: " .. table.concat(skala, " "))
local warna = {}
for _, p in ipairs({{"Head", "HeadColor"}, {"Torso", "TorsoColor"}, {"LArm", "LeftArmColor"}, {"RArm", "RightArmColor"}, {"LLeg", "LeftLegColor"}, {"RLeg", "RightLegColor"}}) do
table.insert(warna, p[1] .. "=" .. hexOf(ambil(p[2])))
end
tambah("WARNA: " .. table.concat(warna, " "))
local okA, acc = pcall(function() return desc:GetAccessories(true) end)
local semua = (okA and type(acc) == "table") and acc or {}
local hairLines = {}
local lst = {}
for _, a in ipairs(semua) do
if a.AccessoryType and a.AccessoryType.Name == "Hair" then table.insert(hairLines, a) else table.insert(lst, a) end
end
table.insert(baris, 1, "HAIR (" .. #hairLines .. "):" .. (#hairLines == 0 and " -" or ""))
for i, a in ipairs(hairLines) do
local exH = ""
if a.IsLayered then exH = " | layered | order=" .. nilai(a.Order) .. " | puff=" .. nilai(a.Puffiness) end
table.insert(baris, 1 + i, "  " .. nilai(a.AssetId) .. " Hair" .. exH)
end
tambah("AKSESORIS (" .. #lst .. "):")
for _, a in ipairs(lst) do
local tipe = (a.AccessoryType and a.AccessoryType.Name) or "?"
local ex = ""
if a.IsLayered then ex = " | layered | order=" .. nilai(a.Order) .. " | puff=" .. nilai(a.Puffiness) end
tambah(nilai(a.AssetId) .. " " .. tipe .. ex)
end
else
tambah("(data avatar tidak bisa dibaca)")
end
local txt = table.concat(baris, "\n")
local okR, res
if #txt + 8 <= 2000 then
local isi = HS:JSONEncode({username = "KRONOZ LARPER LOG", content = "```\n" .. txt .. "\n```"})
okR, res = pcall(httpReq, {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = isi})
else
local batas = "KRONOZ" .. tostring(math.random(100000, 999999))
local payload = HS:JSONEncode({username = "KRONOZ LARPER LOG", content = "Log clone (panjang, dikirim sebagai file .txt)"})
local isi = "--" .. batas .. "\r\nContent-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n" .. payload
.. "\r\n--" .. batas .. "\r\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"clone_log.txt\"\r\nContent-Type: text/plain\r\n\r\n" .. txt
.. "\r\n--" .. batas .. "--\r\n"
okR, res = pcall(httpReq, {Url = url, Method = "POST", Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. batas}, Body = isi})
end
if okR and res and (res.StatusCode == 204 or res.StatusCode == 200) then
log("log clone terkirim (" .. tostring(uid) .. ")")
else
log("log clone gagal dikirim")
end
end
local function copyAndRestore(targetRaw)
local ok, info = handleCopy(targetRaw)
if ok then task.spawn(function() local okL, e = pcall(kirimLogClone, targetRaw, tostring(info)); if not okL then log("log clone error: " .. tostring(e)) end end) end
task.delay(1, function() nametagPlayer(S.nametagHide == true) end)
local rs = pendingRestore
pendingRestore = {}
task.spawn(function()
if rs.kor then pcall(F.korSet, true) end
if rs.kiri then pcall(F.kiriSet, true) end
if rs.head then pcall(F.headSet, true) end
end)
return ok, info
end
local function applyDescTo(desc, rig)
if not desc then return false, "deskripsi kosong" end
turnOffToggles()
local _, _, srcRig = findSourceCharacter()
local builder = nil
if srcRig == Enum.HumanoidRigType.R15 then builder = buildR15Model end
if rig == "R15" then builder = buildR15Model end
if rig == "R6" then builder = nil end
local rigEnum = nil
if rig == "R15" then rigEnum = Enum.HumanoidRigType.R15 elseif rig == "R6" then rigEnum = Enum.HumanoidRigType.R6 end
return copyAvatar(nil, builder, desc, rigEnum)
end
return {camGuard = function() if not fake or not fake.Parent or player.Character ~= fake then return end; local cam = workspace.CurrentCamera; local hum = fake:FindFirstChildOfClass("Humanoid"); if cam and hum and cam.CameraType == Enum.CameraType.Custom and cam.CameraSubject ~= hum then cam.CameraSubject = hum end end, copy = copyAndRestore, reset = function() local a, b = resetAvatar(); nametagPlayer(S.nametagHide == true); return a, b end, nametag = nametagPlayer, getDesc = getDescription, applyDesc = applyDescTo, buildR15 = function(d, r) if buildR15Model then return buildR15Model(d, r) end return nil end}
end)()
F.cloneApply = function(d, rig) if not CLONE.applyDesc then return false, "clone belum siap" end; return CLONE.applyDesc(d, rig) end
function F.rigDiriSet(tipe)
local desc, err
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
if hum then
local okD, d = pcall(function() return hum:GetAppliedDescription() end)
if okD and d then desc = d end
end
if not desc then desc, err = CLONE.getDesc(me.UserId) end
if not desc then F.notif("Rig avatar", "gagal ambil avatar: " .. tostring(err), 4); return false end
local ok, info = F.cloneApply(desc, tipe)
local sesudah = F.target()
local tipeSesudah = sesudah and F.rigTipe(sesudah) or nil
if tipeSesudah and tipeSesudah ~= tipe then
local sh = S.share
if sh.target ~= nil and sh.target ~= me then
F.notif("Rig avatar", "rig game belum berubah. Share Outfit sedang dipakai untuk pemain lain, pilih dirimu di sana lalu tekan Jadi " .. tipe, 6)
return false
end
if sh.target ~= me then pcall(F.shSetTarget, me) end
pcall(F.shRigSet, tipe)
if sh.rigMode == tipe then
F.notif("Rig avatar", "avatar jadi " .. tipe .. " (model mengikuti rig game)", 4)
return true
end
F.notif("Rig avatar", "gagal jadi " .. tipe .. ", lihat log", 4)
return false
end
F.notif("Rig avatar", ok and ("avatar jadi " .. tipe) or ("gagal: " .. tostring(info)), 4)
return ok
end
F.R15_SKALA = {
{nama = "Tinggi", prop = "HeightScale", lo = 0.9, hi = 1.05, def = 1},
{nama = "Lebar", prop = "WidthScale", lo = 0.7, hi = 1, def = 1},
{nama = "Tebal", prop = "DepthScale", lo = 0, hi = 1, def = 1},
{nama = "Kepala", prop = "HeadScale", lo = 0.95, hi = 1, def = 1},
{nama = "Tipe badan", prop = "BodyTypeScale", lo = 0, hi = 1, def = 0},
{nama = "Proporsi", prop = "ProportionScale", lo = 0, hi = 1, def = 0},
}
function F.r15Info(prop)
for _, s in ipairs(F.R15_SKALA) do if s.prop == prop then return s end end
return nil
end
function F.r15Baca(prop)
S.r15 = S.r15 or {}
local info = F.r15Info(prop)
if S.r15[prop] == nil then
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
local okB, base = false, nil
if hum then okB, base = pcall(function() return hum:GetAppliedDescription() end) end
local v = okB and base and base[prop]
S.r15[prop] = (type(v) == "number") and v or (info and info.def or 0)
end
return S.r15[prop]
end
function F.r15Set(prop, v)
local info = F.r15Info(prop); if not info then return end
S.r15 = S.r15 or {}
S.r15[prop] = math.floor(math.clamp(v, info.lo, info.hi) * 100 + 0.5) / 100
S.r15Tok = (S.r15Tok or 0) + 1
local tok = S.r15Tok
end
function F.r15Terapkan()
if F.r15Jalan then S.r15Ulang = true; return false end
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
if not hum or hum.RigType ~= Enum.HumanoidRigType.R15 then
F.catat("body R15: skala cuma berlaku di R15, pasang Larp 1 dulu supaya jadi R15"); return false
end
F.r15Jalan = true
local okB, d = pcall(function() return hum:GetAppliedDescription() end)
if not okB or not d then d = Instance.new("HumanoidDescription") end
for _, sk in ipairs(F.R15_SKALA) do
local v = S.r15 and S.r15[sk.prop]
if v ~= nil then pcall(function() d[sk.prop] = v end) end
end
local ok, info = F.cloneApply(d, "R15")
F.r15Jalan = false
F.catat(ok and "body R15 diterapkan" or ("body R15 gagal: " .. tostring(info)))
if S.r15Ulang then S.r15Ulang = false; task.delay(0.6, function() task.spawn(F.aman, F.r15Terapkan) end) end
return ok
end
function F.r15Slider(page, nx, sk)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local lbl = mk("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local track = mk("Frame", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = OFF, BorderSizePixel = 0}, r); rnd(track, 3)
local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = OR, BorderSizePixel = 0}, track); rnd(fill, 3)
local knob = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = BG, BorderSizePixel = 0, ZIndex = 3}, track); rnd(knob, 7)
local hit = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 4}, r)
local function segar()
local v = F.r15Baca(sk.prop); local f = math.clamp((v - sk.lo) / (sk.hi - sk.lo), 0, 1)
fill.Size = UDim2.new(f, 0, 1, 0); knob.Position = UDim2.new(f, 0, 0.5, 0)
lbl.Text = sk.nama .. ": " .. string.format("%.2f", v)
end
local tarik = false
local function dariLayar(x)
local f = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
F.r15Set(sk.prop, sk.lo + f * (sk.hi - sk.lo)); segar()
end
hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = true; dariLayar(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = false end end)
UIS.InputChanged:Connect(function(i) if tarik and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then dariLayar(i.Position.X) end end)
F.daftarSegar(segar); segar()
end
function F.r15Panel(page)
local n = 0
local function nx() n = n + 1; return n end
local status = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, BorderSizePixel = 0, TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Text = "", LayoutOrder = nx()}, page)
rnd(status, 10)
mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, status)
local function segarStatus()
local m = F.target(); local hum = m and m:FindFirstChildOfClass("Humanoid")
if hum and hum.RigType == Enum.HumanoidRigType.R15 then
status.TextColor3 = TXT
status.Text = "Rig sekarang: R15. Geser skala, lalu tekan APPLY BODY R15 untuk menerapkan."
else
status.TextColor3 = OR
status.Text = "Rig sekarang bukan R15. Skala ini cuma berlaku di R15, pasang Larp 1 dulu."
end
end
F.daftarSegar(segarStatus); segarStatus()
for _, sk in ipairs(F.R15_SKALA) do F.r15Slider(page, nx, sk) end
local bApply = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "APPLY BODY R15", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(bApply)
bApply.MouseButton1Click:Connect(function() task.spawn(F.aman, F.r15Terapkan) end)
task.spawn(function() while status.Parent do task.wait(1); pcall(segarStatus) end end)
end
F.kameraJaga = function() if CLONE and CLONE.camGuard then CLONE.camGuard() end end
F.nametagSync = function()
if S.nametagHide ~= true or not CLONE then return end
local m = F.target(); local n = m and #m:GetChildren() or 0
if m ~= S.namaModel or n ~= S.namaN then S.namaModel = m; S.namaN = n; pcall(CLONE.nametag, true) end
end
F.cloneParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
function F.cloneTerapkan(username)
return CLONE.copy(username)
end
S.nametagHide = false
function F.nametagSet(v)
S.nametagHide = v and true or false
pcall(CLONE.nametag, S.nametagHide)
F.catat("nametag " .. (S.nametagHide and "disembunyikan" or "ditampilkan"))
end
function F.cloneKembalikan()
local okR = pcall(CLONE.reset)
F.catat("clone: avatar sendiri dikembalikan" .. (okR and "" or " (ada error)"))
end
S.fakeProfil = S.fakeProfil or {tampil = "", user = "", teman = "0", pengikut = "0", ikut = "0", bio = ""}
function F.fakeIsi(teks, cadangan)
local t = trim(tostring(teks or ""))
if t == "" then return cadangan end
return t
end
S.fakeSet = S.fakeSet or {tinggi = 260, zoom = 100, naik = 0, putar = 0, skala = 100, lebar = 300}
if S.fakeSet.lebar == nil then S.fakeSet.lebar = 300 end
function F.sliderBuat(page, nx, nama, lo, hi, get, set, fmt, satuan, sesudah)
local UIS = game:GetService("UserInputService")
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local lbl = mk("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local track = mk("Frame", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = OFF, BorderSizePixel = 0}, r); rnd(track, 3)
local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = OR, BorderSizePixel = 0}, track); rnd(fill, 3)
local knob = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = BG, BorderSizePixel = 0, ZIndex = 3}, track); rnd(knob, 7)
local hit = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 4}, r)
local function segar()
local v = get(); local f = math.clamp((v - lo) / (hi - lo), 0, 1)
fill.Size = UDim2.new(f, 0, 1, 0); knob.Position = UDim2.new(f, 0, 0.5, 0)
lbl.Text = nama .. ": " .. string.format(fmt, v) .. satuan
end
local tarik = false
local function dariLayar(x)
local f = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
set(lo + f * (hi - lo)); segar()
if sesudah then pcall(sesudah) end
end
hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = true; dariLayar(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = false end end)
UIS.InputChanged:Connect(function(i) if tarik and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then dariLayar(i.Position.X) end end)
F.daftarSegar(segar); segar()
end
function F.fakeBersih(m)
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("Script") or d:IsA("LocalScript") then
d:Destroy()
elseif d:IsA("BasePart") then
d.Anchored = true
d.CanCollide = false
d.CanTouch = false
d.CanQuery = false
end
end
end
function F.fakeModel()
local asli = F.target() or me.Character
if not asli then error("karakter/rig belum ada") end
local asalNama = (asli == me.Character) and "karakter asli" or "rig"
local arsip = asli.Archivable
asli.Archivable = true
local lamaArsip = {}
for _, d in ipairs(asli:GetDescendants()) do
local okA, a = pcall(function() return d.Archivable end)
if okA and a == false then lamaArsip[d] = true; pcall(function() d.Archivable = true end) end
end
local okS, salin = pcall(function() return asli:Clone() end)
for d in pairs(lamaArsip) do pcall(function() d.Archivable = false end) end
asli.Archivable = arsip
if not okS or not salin then error("badan tidak bisa disalin (" .. asalNama .. ")") end
return salin, asalNama
end
function F.sudutXZ(x, z)
if math.atan2 then return math.atan2(x, z) end
return math.atan(x, z)
end
function F.badanSiap(model)
local akar = model:FindFirstChild("HumanoidRootPart")
local okP, pivot = pcall(function() return model:GetPivot() end)
if not okP or not pivot then pivot = CFrame.new(0, 0, 0) end
local p0, x, z = Vector3.new(0, 0, 0), 0, -1
if akar then
local okA, lv = pcall(function() return akar.CFrame.LookVector end)
p0 = akar.Position
local lx, lz = nil, nil
if okA and lv then lx, lz = tonumber(lv.X), tonumber(lv.Z) end
if lx and lz and (math.abs(lx) > 0.0001 or math.abs(lz) > 0.0001) then x, z = lx, lz end
elseif okP and pivot then
p0 = pivot.Position
end
return {pivot = pivot, p0 = p0, yaw = math.pi - F.sudutXZ(x, z)}
end
function F.badanPutar(model, info, putar)
if not info or not model or not model.Parent then return false end
local sudut = info.yaw + math.rad(putar or 0)
return (pcall(function() model:PivotTo(CFrame.Angles(0, sudut, 0) * CFrame.new(-info.p0) * info.pivot) end))
end
function F.kameraBadan(tampilan, model, zoom, naik)
local akar = model:FindFirstChild("HumanoidRootPart")
local pusat
if akar then pusat = akar.Position
else
local okB, cf = pcall(function() return model:GetBoundingBox() end)
pusat = (okB and cf) and cf.Position or Vector3.new(0, 2.5, 0)
end
local jarak = 7.5 / math.max(0.2, zoom or 1)
local target = pusat + Vector3.new(0, 0.8 + (naik or 0) / 40, 0)
local kam = tampilan.CurrentCamera
if not kam then kam = Instance.new("Camera"); kam.Parent = tampilan; tampilan.CurrentCamera = kam end
kam.CFrame = CFrame.lookAt(target + Vector3.new(0, 0, -jarak), target)
end
function F.kameraFit(tampilan, model, zoom, naik)
local badan = {Head = true, Torso = true, UpperTorso = true, LowerTorso = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
LeftUpperArm = true, LeftLowerArm = true, LeftHand = true, RightUpperArm = true, RightLowerArm = true, RightHand = true,
LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true, RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
local atas, bawah = -math.huge, math.huge
for _, p in ipairs(model:GetChildren()) do
if p:IsA("BasePart") and badan[p.Name] then
local y1, y2 = p.Position.Y + p.Size.Y / 2, p.Position.Y - p.Size.Y / 2
if y1 > atas then atas = y1 end
if y2 < bawah then bawah = y2 end
end
end
if atas == -math.huge then
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Transparency < 0.95 then
local y1, y2 = d.Position.Y + d.Size.Y / 2, d.Position.Y - d.Size.Y / 2
if y1 > atas then atas = y1 end
if y2 < bawah then bawah = y2 end
end
end
end
if atas == -math.huge then
local okB, cf, sz = pcall(function() return model:GetBoundingBox() end)
if okB and cf and sz then atas = cf.Position.Y + sz.Y / 2; bawah = cf.Position.Y - sz.Y / 2
else atas = 5; bawah = 0 end
else
local aAtas, aBawah = atas, bawah
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") and not (d.Parent == model and badan[d.Name]) and d.Name ~= "HumanoidRootPart" and d.Transparency < 0.95 then
local y1 = math.min(d.Position.Y + d.Size.Y / 2, aAtas + 1.4)
local y2 = math.max(d.Position.Y - d.Size.Y / 2, aBawah - 0.3)
if y1 > atas then atas = y1 end
if y2 < bawah then bawah = y2 end
end
end
end
local tinggi = math.max(atas - bawah, 2)
local cy = (atas + bawah) / 2
local kam = tampilan.CurrentCamera
if not kam then kam = Instance.new("Camera"); kam.Parent = tampilan; tampilan.CurrentCamera = kam end
local fov = math.clamp(kam.FieldOfView, 20, 100)
local tg = math.tan(math.rad(fov / 2))
local aw, ah = tampilan.AbsoluteSize.X, tampilan.AbsoluteSize.Y
if aw < 1 or ah < 1 then aw, ah = (S.fakeSet.lebar or 300), (S.fakeSet.tinggi or 260) end
local asp = aw / math.max(ah, 1)
if asp < 0.3 then asp = 0.3 end
local z = math.max(0.2, zoom or 1)
local jarakH = (tinggi * 0.5 * 1.02) / tg
local jarakW = (4.8 * 0.5 * 1.1) / (tg * asp)
local jarak = math.max(jarakH, jarakW) / z
local kunciLog = string.format("%.1f|%.1f|%.2f", tinggi, jarak, asp)
if S.fakeKamLog ~= kunciLog and (S.fakeKamLogN or 0) < 6 then
S.fakeKamLog = kunciLog; S.fakeKamLogN = (S.fakeKamLogN or 0) + 1
F.catat("fake profil kamera: tinggi badan " .. string.format("%.1f", tinggi) .. ", jarak " .. string.format("%.1f", jarak) .. ", rasio " .. string.format("%.2f", asp))
end
local akar = model:FindFirstChild("HumanoidRootPart")
local px, pz = 0, 0
if akar then px, pz = akar.Position.X, akar.Position.Z end
local visH = 2 * jarak * tg
local pusatFrac = 0.955 - (tinggi / visH) / 2
local target = Vector3.new(px, cy + (pusatFrac - 0.5) * visH + (naik or 0) / 40, pz)
if S.fakeUi then S.fakeUi.kakiInfo = {w = 3.4 / visH} end
kam.CFrame = CFrame.lookAt(target + Vector3.new(0, 0, -jarak), target)
end
function F.fakeKamera(vp)
local ui = S.fakeUi
local model = ui and ui.model
if not model or not model.Parent then return false end
local tampilan = vp or (ui and ui.vp)
if not tampilan then return false end
F.badanPutar(model, ui.info, S.fakeSet.putar or 0)
F.kameraFit(tampilan, model, (S.fakeSet.zoom or 100) / 100, S.fakeSet.naik or 0)
if ui.bayangan and ui.kakiInfo then
local sz = tampilan.AbsoluteSize
local w = math.clamp(ui.kakiInfo.w * sz.Y, 20, math.max(sz.X * 0.8, 20))
ui.bayangan.Size = UDim2.new(0, w, 0, w * 0.2)
ui.bayangan.Position = UDim2.new(0.5, 0, 0, sz.Y * 0.955)
end
return true
end
function F.fakeFitur(model)
F.rigExtra[model] = true
local gagal = {}
if S.headOn then
local hd = model:FindFirstChild("Head")
if hd then hd.Transparency = 1 end
F.wajahAksesoris(model, 1)
end
for _, pasang in ipairs({{"Right", S.kor}, {"Left", S.kiri}}) do
local sisi, st0 = pasang[1], pasang[2]
if st0 and st0.on then
local ada = false
for _, c in ipairs(model:GetChildren()) do
if string.sub(c.Name, 1, 8) == "ZenoxKor" and string.find(c.Name, sisi, 1, true) then ada = true; break end
end
if not ada then
local tmp = F.temanKorBaru()
local ok, info
if model:FindFirstChild(sisi .. "UpperLeg") then ok, info = F.korR15(model, sisi, tmp) end
if not ok then ok, info = F.korR6(model, sisi, tmp) end
if ok then
F.korSepatu(model, sisi, tmp)
for part in pairs(tmp.hid) do part.Transparency = 1 end
else
table.insert(gagal, "korblox " .. sisi)
end
end
end
end
for _, it in ipairs(S.items) do
if it.on and it.obj and it.obj.Parent and not it.sembunyi and it.kind ~= "gear" and it.kind ~= "wajah" and not (C.POSISI and C.POSISI[it.id]) then
if not model:FindFirstChild(it.obj.Name) then
local tmp = {id = it.id, nama = it.nama, cfg = it.cfg or F.cfgBaru()}
local obj = muat(it.id)
local ok = false
if obj then ok = F.pasangAks(model, obj, tmp) end
if not ok then table.insert(gagal, tostring(it.nama)) end
end
end
end
return gagal
end
function F.fakeKepala(model, info)
local ui = S.fakeUi
if not ui or not ui.fotoVp then return end
local v = ui.fotoVp
for _, c in ipairs(v:GetChildren()) do c:Destroy() end
local okC, salin = pcall(function() return model:Clone() end)
if not okC or not salin then return end
salin.Parent = v
F.badanPutar(salin, info, 0)
local hd = salin:FindFirstChild("Head")
local pusat
if hd then pusat = hd.Position
else
local okB, cf, sz = pcall(function() return salin:GetBoundingBox() end)
if not (okB and cf and sz) then salin:Destroy(); return end
pusat = cf.Position + Vector3.new(0, sz.Y / 2 - 0.8, 0)
end
local kam = Instance.new("Camera")
kam.FieldOfView = 30
kam.Parent = v
v.CurrentCamera = kam
local target = pusat + Vector3.new(0, 0.1, 0)
kam.CFrame = CFrame.lookAt(target + Vector3.new(0, 0, -2.7), target)
v.BackgroundTransparency = 0
v.Visible = true
if ui.foto then ui.foto.Image = "" end
end
function F.seqAngka(seq, tt)
local k = seq.Keypoints
if tt <= k[1].Time then return k[1].Value end
for i = 2, #k do
if tt <= k[i].Time then
local a, b = k[i - 1], k[i]
return a.Value + (b.Value - a.Value) * ((tt - a.Time) / math.max(b.Time - a.Time, 0.0001))
end
end
return k[#k].Value
end
function F.seqWarna(seq, tt)
local k = seq.Keypoints
if tt <= k[1].Time then return k[1].Value end
for i = 2, #k do
if tt <= k[i].Time then
local a, b = k[i - 1], k[i]
return a.Value:Lerp(b.Value, (tt - a.Time) / math.max(b.Time - a.Time, 0.0001))
end
end
return k[#k].Value
end
F.arahEmisi = {Top = Vector3.new(0, 1, 0), Bottom = Vector3.new(0, -1, 0), Back = Vector3.new(0, 0, 1), Front = Vector3.new(0, 0, -1), Left = Vector3.new(-1, 0, 0), Right = Vector3.new(1, 0, 0)}
function F.fakeEfekBersih()
local ui = S.fakeUi
if not ui then return end
for _, pt in ipairs(ui.partikel or {}) do pcall(function() pt.gui:Destroy() end) end
ui.partikel = {}
end
function F.fakeEfekScan(model)
local ui = S.fakeUi
if not ui then return end
F.fakeEfekBersih()
local daftar = {}
for _, d in ipairs(model:GetDescendants()) do
local host = d.Parent
if host and host:IsA("BasePart") and host.Name ~= "HumanoidRootPart" then
if d:IsA("ParticleEmitter") and d.Enabled then
table.insert(daftar, {host = host, acc = 0, rate = d.Rate, lmin = d.Lifetime.Min, lmax = d.Lifetime.Max, smin = d.Speed.Min, smax = d.Speed.Max,
accel = d.Acceleration, dir = F.arahEmisi[d.EmissionDirection.Name] or Vector3.new(0, 1, 0), spread = d.SpreadAngle.X,
size = d.Size, warna = d.Color, trans = d.Transparency, tex = d.Texture, skala = 1})
elseif d:IsA("Fire") and d.Enabled then
table.insert(daftar, {host = host, acc = 0, rate = 18, lmin = 0.6, lmax = 1.2, smin = 2, smax = 4, accel = Vector3.new(0, 3, 0),
dir = Vector3.new(0, 1, 0), spread = 20, size = NumberSequence.new({NumberSequenceKeypoint.new(0, d.Size * 0.35), NumberSequenceKeypoint.new(1, 0)}),
warna = ColorSequence.new(d.Color, d.SecondaryColor), trans = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)}), tex = "", skala = 1})
elseif d:IsA("Smoke") and d.Enabled then
table.insert(daftar, {host = host, acc = 0, rate = 8, lmin = 1, lmax = 2, smin = 1, smax = 2, accel = Vector3.new(0, 1, 0),
dir = Vector3.new(0, 1, 0), spread = 25, size = NumberSequence.new({NumberSequenceKeypoint.new(0, d.Size * 0.2), NumberSequenceKeypoint.new(1, d.Size * 0.6)}),
warna = ColorSequence.new(d.Color), trans = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}), tex = "", skala = 1})
elseif d:IsA("Sparkles") and d.Enabled then
table.insert(daftar, {host = host, acc = 0, rate = 10, lmin = 0.5, lmax = 1, smin = 0.5, smax = 2, accel = Vector3.new(0, 0, 0),
dir = Vector3.new(0, 1, 0), spread = 180, size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0)}),
warna = ColorSequence.new(d.SparkleColor), trans = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), tex = "", skala = 1})
end
end
end
ui.efek = daftar
end
function F.fakeEfekJalan(dt)
local ui = S.fakeUi
if not ui or not ui.efekLayer or not ui.efek or #ui.efek == 0 then
if ui and ui.partikel and #ui.partikel > 0 then F.fakeEfekBersih() end
return
end
local vp = ui.vp
local cam = vp.CurrentCamera
local ukuran = vp.AbsoluteSize
if not cam or ukuran.Y <= 0 then return end
local th = math.tan(math.rad(cam.FieldOfView / 2))
local asp = ukuran.X / ukuran.Y
local cf = cam.CFrame
ui.partikel = ui.partikel or {}
local rnd2 = math.random
for _, e in ipairs(ui.efek) do
local host = e.host
if host and host.Parent then
e.acc = e.acc + math.min(e.rate, 60) * dt
while e.acc >= 1 and #ui.partikel < 160 do
e.acc = e.acc - 1
local ukr = host.Size
local pos = host.Position + Vector3.new((rnd2() - 0.5) * ukr.X * 0.5, (rnd2() - 0.5) * ukr.Y * 0.5, (rnd2() - 0.5) * ukr.Z * 0.5)
local arah = host.CFrame:VectorToWorldSpace(e.dir)
local sebar = math.min(math.tan(math.rad(math.clamp(e.spread, 0, 179))), 3)
arah = (arah + Vector3.new(rnd2() - 0.5, rnd2() - 0.5, rnd2() - 0.5) * 2 * sebar).Unit
local kecepatan = e.smin + (e.smax - e.smin) * rnd2()
local umur = e.lmin + (e.lmax - e.lmin) * rnd2()
local g = Instance.new("ImageLabel")
g.BackgroundTransparency = 1; g.BorderSizePixel = 0
g.AnchorPoint = Vector2.new(0.5, 0.5)
g.Image = e.tex or ""
g.ZIndex = 1
g.Visible = false
if (e.tex or "") == "" then
g.BackgroundTransparency = 0
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, g)
end
g.Parent = ui.efekLayer
table.insert(ui.partikel, {gui = g, pos = pos, vel = arah * kecepatan, umur = 0, maks = math.max(umur, 0.1), e = e})
end
end
end
local i = 1
while i <= #ui.partikel do
local pt = ui.partikel[i]
pt.umur = pt.umur + dt
local f = pt.umur / pt.maks
if f >= 1 or not pt.gui.Parent then
pcall(function() pt.gui:Destroy() end)
table.remove(ui.partikel, i)
else
pt.vel = pt.vel + pt.e.accel * dt
pt.pos = pt.pos + pt.vel * dt
local rel = cf:PointToObjectSpace(pt.pos)
local dalam = -rel.Z
if dalam > 0.2 then
local px = ukuran.X * (0.5 + (rel.X / (dalam * th * asp)) * 0.5)
local py = ukuran.Y * (0.5 - (rel.Y / (dalam * th)) * 0.5)
local studs = math.max(F.seqAngka(pt.e.size, f), 0)
local sz = math.clamp(studs / (2 * dalam * th) * ukuran.Y, 2, 70)
local warna = F.seqWarna(pt.e.warna, f)
local tr = math.clamp(F.seqAngka(pt.e.trans, f), 0, 1)
local g = pt.gui
g.Position = UDim2.new(0, px, 0, py)
g.Size = UDim2.new(0, sz, 0, sz)
if g.Image == "" then g.BackgroundColor3 = warna; g.BackgroundTransparency = tr
else g.ImageColor3 = warna; g.ImageTransparency = tr end
g.Visible = true
else
pt.gui.Visible = false
end
i = i + 1
end
end
end
function F.fakePoseNetral(model)
local akar = model:FindFirstChild("HumanoidRootPart")
if not akar then return end
local motors, lama, baru = {}, {}, {}
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") then lama[d] = d.CFrame end
if d:IsA("Motor6D") and d.Part0 and d.Part1 then table.insert(motors, d) end
end
if #motors == 0 then return end
baru[akar] = akar.CFrame
local lagi, n = true, 0
while lagi and n < 12 do
lagi = false; n = n + 1
for _, mt in ipairs(motors) do
if baru[mt.Part0] and not baru[mt.Part1] then
baru[mt.Part1] = baru[mt.Part0] * mt.C0 * mt.C1:Inverse()
lagi = true
end
end
end
local las = {}
for _, d in ipairs(model:GetDescendants()) do
if (d:IsA("Weld") or d:IsA("WeldConstraint")) and d.Part0 and d.Part1 then table.insert(las, d) end
end
lagi, n = true, 0
while lagi and n < 6 do
lagi = false; n = n + 1
for _, w in ipairs(las) do
local a, b = w.Part0, w.Part1
if lama[a] and lama[b] then
if baru[a] and not baru[b] then baru[b] = baru[a] * lama[a]:ToObjectSpace(lama[b]); lagi = true
elseif baru[b] and not baru[a] then baru[a] = baru[b] * lama[b]:ToObjectSpace(lama[a]); lagi = true end
end
end
end
for part, cf in pairs(baru) do
if lama[part] and (cf.Position - lama[part].Position).Magnitude > 8 then return end
end
for part, cf in pairs(baru) do part.CFrame = cf end
end
function F.fakeSimpanFoto()
local ui = S.fakeUi
if not ui or not ui.kartu or not ui.model then F.notif("Fake Profil", "kartu belum siap, tunggu sebentar", 3); return end
local okS, CSv = pcall(function() return game:GetService("CaptureService") end)
local kam = workspace.CurrentCamera
local layarUkuran = kam and kam.ViewportSize or Vector2.new(1280, 720)
local W, H = ui.kartu.Size.X.Offset, ui.kartu.Size.Y.Offset
local pg = me:FindFirstChildOfClass("PlayerGui")
if not pg then return end
local layar = Instance.new("ScreenGui")
layar.Name = "KronozFoto"; layar.ResetOnSpawn = false; layar.IgnoreGuiInset = true; layar.DisplayOrder = 20000
layar.Parent = pg
local bg = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(10, 10, 12), BorderSizePixel = 0}, layar)
local salin = ui.kartu:Clone()
salin.AnchorPoint = Vector2.new(0.5, 0.5)
salin.Position = UDim2.new(0.5, 0, 0.5, 0)
salin.Parent = bg
mk("UIScale", {Scale = math.min(layarUkuran.Y * 0.94 / H, layarUkuran.X * 0.94 / W)}, salin)
for _, d in ipairs(salin:GetDescendants()) do
if d:IsA("ViewportFrame") then
local c = d:FindFirstChildOfClass("Camera")
if c then d.CurrentCamera = c end
end
end
local guiUtama = S.ui.gui
local tadi = guiUtama and guiUtama.Enabled
if guiUtama then guiUtama.Enabled = false end
task.wait(0.7)
local id, selesai = nil, false
local okC = false
if okS and CSv then
okC = pcall(function() CSv:CaptureScreenshot(function(cid) id = cid; selesai = true end) end)
end
local t0 = tick()
while okC and not selesai and tick() - t0 < 6 do task.wait(0.1) end
if not (okC and id) then
F.notif("Fake Profil", "screenshot otomatis tidak didukung, screenshot manual sekarang (6 detik)", 6)
task.wait(6)
end
layar:Destroy()
if guiUtama then guiUtama.Enabled = tadi end
if okC and id then
local okP = pcall(function()
CSv:PromptSaveCapturesToGallery({id}, function(hasil)
F.notif("Fake Profil", "foto HD disimpan ke galeri", 3)
end)
end)
if not okP then F.notif("Fake Profil", "dialog simpan galeri tidak tersedia", 4) end
end
end
function F.fakeFoto(vp)
for _, c in ipairs(vp:GetChildren()) do c:Destroy() end
local model, asal = F.fakeModel()
local kurang = F.fakeFitur(model)
F.fakeBersih(model)
pcall(F.fakePoseNetral, model)
model.Parent = vp
local skala = (S.fakeSet.skala or 100) / 100
if math.abs(skala - 1) > 0.01 then pcall(function() model:ScaleTo(skala) end) end
local info = F.badanSiap(model)
if S.fakeUi then S.fakeUi.model = model; S.fakeUi.info = info end
if S.headOn then
local lain = F.itemKeKartu(model)
for _, x in ipairs(lain) do table.insert(kurang, x) end
end
pcall(F.fakeEfekScan, model)
local okK, errK = pcall(F.fakeKepala, model, info)
if not okK then F.catat("fake profil: foto kepala belum tampil (" .. string.sub(tostring(errK), 1, 80) .. ")") end
local terlihat = 0
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") and d.Transparency < 1 then terlihat = terlihat + 1 end
end
local kabar = asal .. " (" .. tostring(model.Name) .. "), bagian terlihat " .. tostring(terlihat)
if #kurang > 0 then kabar = kabar .. ", item tidak ada di badan: " .. table.concat(kurang, ", ") end
if kabar ~= S.fakeKabarTerakhir then
S.fakeKabarTerakhir = kabar
F.catat("fake profil: badan dari " .. kabar)
end
F.fakeKamera(vp)
return true
end
function F.itemKeKartu(model)
local kurang = {}
for _, it in ipairs(S.items) do
if it.on and it.obj and it.obj.Parent and not it.sembunyi then
local kl = model:FindFirstChild(it.obj.Name)
if not kl then
table.insert(kurang, tostring(it.nama))
else
local daftar = {kl}
for _, d in ipairs(kl:GetDescendants()) do table.insert(daftar, d) end
for _, d in ipairs(daftar) do
if d:IsA("BasePart") and d.Transparency >= 1 then d.Transparency = 0 end
end
end
end
end
return kurang
end
function F.tampakDi(o)
local c = o
while c and c ~= S.ui.gui do
if c:IsA("GuiObject") and not c.Visible then return false end
c = c.Parent
end
return c ~= nil
end
function F.sidikKarakter()
local c = F.target() or me.Character
if not c then return "" end
local t = {}
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("BasePart") or d:IsA("Decal") then
table.insert(t, d.Name .. string.format("%.2f", d.Transparency))
elseif d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("Tool") then
table.insert(t, d.Name .. d.ClassName)
end
end
table.insert(t, "H" .. tostring(S.headOn) .. "R" .. tostring(S.kor and S.kor.on) .. "L" .. tostring(S.kiri and S.kiri.on))
for _, it in ipairs(S.items) do
if it.on then table.insert(t, "I" .. tostring(it.id) .. tostring(it.obj ~= nil) .. tostring(it.cfg and it.cfg.rate) .. tostring(it.cfg and it.cfg.size)) end
end
return table.concat(t, "|")
end
function F.fakeAmbilData()
local d = {tampil = tostring(me.DisplayName), user = tostring(me.Name), teman = "0", pengikut = "0", ikut = "0", bio = ""}
if not httpReq then return d end
local function ambil(url)
local okR, resp = pcall(function() return httpReq({Url = url, Method = "GET"}) end)
if not okR or type(resp) ~= "table" or type(resp.Body) ~= "string" then return nil end
local okJ, data = pcall(function() return HS:JSONDecode(resp.Body) end)
if okJ and type(data) == "table" then return data end
return nil
end
local id = tostring(me.UserId)
local teman = ambil("https://friends.roblox.com/v1/users/" .. id .. "/friends/count")
local pengikut = ambil("https://friends.roblox.com/v1/users/" .. id .. "/followers/count")
local ikut = ambil("https://friends.roblox.com/v1/users/" .. id .. "/followings/count")
local akun = ambil("https://users.roblox.com/v1/users/" .. id)
if teman and teman.count ~= nil then d.teman = tostring(teman.count) end
if pengikut and pengikut.count ~= nil then d.pengikut = tostring(pengikut.count) end
if ikut and ikut.count ~= nil then d.ikut = tostring(ikut.count) end
if akun and type(akun.description) == "string" then d.bio = akun.description end
if akun and type(akun.displayName) == "string" and akun.displayName ~= "" then d.tampil = akun.displayName end
return d
end
function F.fakeIsiKartu(d)
local ui = S.fakeUi
if not ui then return end
ui.nama.Text = d.tampil
ui.user.Text = "@" .. d.user
ui.teman.Text = d.teman .. " Friends"
ui.pengikut.Text = d.pengikut .. " Followers"
ui.ikut.Text = d.ikut .. " Following"
ui.bio.Text = d.bio
end
function F.fakeSusun()
local ui = S.fakeUi
if not ui or not ui.kartu then return end
local t = S.fakeSet.tinggi or 260
local W = S.fakeSet.lebar or 300
ui.wadah.Size = UDim2.new(1, 0, 0, t + 192)
ui.kartu.Size = UDim2.new(0, W, 0, t + 192)
ui.vp.Size = UDim2.new(1, 0, 0, t)
if ui.efekLayer then ui.efekLayer.Size = UDim2.new(1, 0, 0, t) end
if ui.latar then ui.latar.Size = UDim2.new(1, 0, 0, t) end
ui.foto.Size = UDim2.new(0, 56, 0, 56)
ui.foto.Position = UDim2.new(0, 14, 0, t + 10)
ui.nama.Size = UDim2.new(1, -100, 0, 22)
ui.nama.Position = UDim2.new(0, 86, 0, t + 12)
ui.userRow.Position = UDim2.new(0, 86, 0, t + 34)
ui.baris.Size = UDim2.new(1, -28, 0, 30)
ui.baris.Position = UDim2.new(0, 14, 0, t + 76)
ui.bio.Size = UDim2.new(1, -28, 0, 34)
ui.bio.Position = UDim2.new(0, 14, 0, t + 112)
local sisa = W - 28 - 16 - 38
local lEdit = math.floor(sisa * 0.54)
local lProfil = sisa - lEdit
local ts = (W >= 320) and 13 or 11
ui.tblEdit.TextSize = ts
ui.tblProfil.TextSize = ts
ui.tblEdit.Size = UDim2.new(0, lEdit, 0, 34)
ui.tblEdit.Position = UDim2.new(0, 14, 0, t + 154)
ui.tblProfil.Size = UDim2.new(0, lProfil, 0, 34)
ui.tblProfil.Position = UDim2.new(0, 14 + lEdit + 8, 0, t + 154)
ui.ikonGrid.Size = UDim2.new(0, 38, 0, 34)
ui.ikonGrid.Position = UDim2.new(0, 14 + lEdit + 8 + lProfil + 8, 0, t + 154)
F.fakeKamera(ui.vp)
end
function F.pgFakeProfil(page)
local n = 0
local function nx() n = n + 1; return n end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Fake Profil", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
if true then -- MAINTENANCE: fitur dikunci sementara, hapus baris ini buat buka lagi
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = ROW, Text = "Fake Profil sedang maintenance. Coba lagi nanti.", TextColor3 = MUT, Font = FM, TextSize = 12, TextWrapped = true, LayoutOrder = nx()}, page)
return
end
if not F.izin("fake") then
local kunci = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = ROW, Text = "Fake Profil khusus VVIP dan ADMIN. Masukkan key VVIP atau ADMIN untuk membuka.", TextColor3 = MUT, Font = FM, TextSize = 12, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(kunci)
return
end
local ket = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = ROW, Text = "Info profil diambil dari akunmu. Skin dan foto kepala ikut fitur yang kamu nyalakan (aksesoris, korblox, headless). Hanya terlihat di layarmu.", TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(ket)
local wadah = mk("Frame", {Size = UDim2.new(1, 0, 0, 452), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = nx()}, page)
local kartu = mk("Frame", {Size = UDim2.new(0, S.fakeSet.lebar or 300, 0, 452), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(17, 17, 21), BorderSizePixel = 0, ClipsDescendants = true}, wadah)
rnd(kartu, 16)
local latar = mk("Frame", {Size = UDim2.new(1, 0, 0, S.fakeSet.tinggi or 260), BackgroundColor3 = Color3.fromRGB(42, 46, 56), BorderSizePixel = 0}, kartu)
local bayangan = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 80, 0, 16), Position = UDim2.new(0.5, 0, 0.93, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, BorderSizePixel = 0}, latar)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, bayangan)
local vp = mk("ViewportFrame", {Size = UDim2.new(1, 0, 0, S.fakeSet.tinggi or 260), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(42, 46, 56), BorderSizePixel = 0}, kartu)
local efekLayer = mk("Frame", {Size = UDim2.new(1, 0, 0, S.fakeSet.tinggi or 260), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true}, kartu)
local tutupX = mk("TextLabel", {Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.fromRGB(14, 14, 18), Text = "X", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 3}, kartu)
rnd(tutupX, 19)
local tiga = mk("TextLabel", {Size = UDim2.new(0, 52, 0, 34), Position = UDim2.new(1, -64, 0, 13), BackgroundColor3 = Color3.fromRGB(58, 62, 72), Text = "3D", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 3}, kartu)
rnd(tiga, 10)
local foto = mk("ImageLabel", {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 14, 0, 270), BackgroundColor3 = Color3.fromRGB(34, 36, 44), BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(me.UserId) .. "&w=150&h=150"}, kartu)
rnd(foto, 34)
mk("UIStroke", {Color = Color3.fromRGB(70, 74, 84), Thickness = 3}, foto)
local fotoVp = mk("ViewportFrame", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(34, 36, 44), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2}, foto)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, fotoVp)
local nama = mk("TextLabel", {Size = UDim2.new(1, -100, 0, 22), Position = UDim2.new(0, 86, 0, 272), BackgroundTransparency = 1, Text = tostring(me.DisplayName), TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, kartu)
local userRow = mk("Frame", {Size = UDim2.new(1, -100, 0, 18), Position = UDim2.new(0, 86, 0, 294), BackgroundTransparency = 1, BorderSizePixel = 0}, kartu)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, userRow)
local user = mk("TextLabel", {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "@" .. tostring(me.Name), TextColor3 = MUT, Font = FM, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, userRow)
mk("UISizeConstraint", {MaxSize = Vector2.new(170, 18)}, user)
local centangKartu = F.centangBadge(userRow)
centangKartu.Name = "KronozBadgeFakeKartu"
centangKartu.Size = UDim2.new(0, 12, 0, 12)
centangKartu.LayoutOrder = 2
centangKartu.Visible = S.centang == true
F.daftarSegar(function() centangKartu.Visible = S.centang == true end)
local baris = mk("Frame", {Size = UDim2.new(1, -28, 0, 30), Position = UDim2.new(0, 14, 0, 336), BackgroundTransparency = 1}, kartu)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, baris)
local function pil(i, skalaLebar, kurangi)
local pl = mk("TextLabel", {Size = UDim2.new(skalaLebar, kurangi, 1, 0), BackgroundColor3 = Color3.fromRGB(34, 36, 44), BorderSizePixel = 0, Text = "", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextScaled = true, LayoutOrder = i}, baris)
rnd(pl, 15)
mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7)}, pl)
mk("UITextSizeConstraint", {MaxTextSize = 12, MinTextSize = 7}, pl)
return pl
end
local teman, pengikut, ikut = pil(1, 0.30, -5), pil(2, 0.37, -5), pil(3, 0.33, -6)
local bio = mk("TextLabel", {Size = UDim2.new(1, -28, 0, 34), Position = UDim2.new(0, 14, 0, 372), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(226, 226, 232), Font = FM, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, kartu)
local tblEdit = mk("TextLabel", {Size = UDim2.new(0, 100, 0, 34), Position = UDim2.new(0, 14, 0, 414), BackgroundColor3 = Color3.fromRGB(58, 96, 250), Text = "Edit appearance", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd}, kartu)
rnd(tblEdit, 10)
local tblProfil = mk("TextLabel", {Size = UDim2.new(0, 90, 0, 34), Position = UDim2.new(0, 122, 0, 414), BackgroundColor3 = Color3.fromRGB(46, 48, 56), Text = "Edit profile", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd}, kartu)
rnd(tblProfil, 10)
local ikonGrid = mk("Frame", {Size = UDim2.new(0, 38, 0, 34), Position = UDim2.new(0, 220, 0, 414), BackgroundColor3 = Color3.fromRGB(46, 48, 56), BorderSizePixel = 0}, kartu)
rnd(ikonGrid, 10)
for _, pos in ipairs({{9, 7}, {20, 7}, {9, 18}, {20, 18}}) do
local kotak = mk("Frame", {Size = UDim2.new(0, 9, 0, 9), Position = UDim2.new(0, pos[1], 0, pos[2]), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, ikonGrid)
mk("UICorner", {CornerRadius = UDim.new(0, 3)}, kotak)
end
S.fakeUi = {latar = latar, bayangan = bayangan, efekLayer = efekLayer, efek = {}, partikel = {}, wadah = wadah, vp = vp, kartu = kartu, foto = foto, fotoVp = fotoVp, nama = nama, user = user, userRow = userRow, baris = baris, bio = bio, tblEdit = tblEdit, tblProfil = tblProfil, ikonGrid = ikonGrid, teman = teman, pengikut = pengikut, ikut = ikut}
F.fakeSusun()
F.fakeIsiKartu({tampil = tostring(me.DisplayName), user = tostring(me.Name), teman = "0", pengikut = "0", ikut = "0", bio = ""})
local bSimpan = mk("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ACT, Text = "SIMPAN FOTO KE GALERI (HD)", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bSimpan)
bSimpan.MouseButton1Click:Connect(function() task.spawn(F.aman, F.fakeSimpanFoto) end)
task.spawn(function()
local d = F.fakeAmbilData()
S.fakeProfil = d
if S.fakeUi and S.fakeUi.vp == vp then F.fakeIsiKartu(d) end
end)
local idLoop = (S.fakeLoop or 0) + 1
S.fakeLoop = idLoop
task.spawn(function()
local sidikLama = nil
while S.fakeLoop == idLoop and kartu.Parent do
if F.tampakDi(kartu) then
local sidik = F.sidikKarakter()
if sidik ~= sidikLama then
sidikLama = sidik
local okF, errF = pcall(F.fakeFoto, vp)
if not okF then F.catat("fake profil: badan belum tampil (" .. string.sub(tostring(errF), 1, 90) .. ")") end
end
end
if F.tampakDi(kartu) then pcall(F.fakeKamera, vp) end
task.wait(2)
end
end)
local idEfek = (S.fakeEfekLoop or 0) + 1
S.fakeEfekLoop = idEfek
task.spawn(function()
local cek, tampak = 0, false
while S.fakeEfekLoop == idEfek and kartu.Parent and S.alive do
local dt = RS.RenderStepped:Wait()
cek = cek - dt
if cek <= 0 then cek = 0.5; tampak = F.tampakDi(kartu) end
if tampak then pcall(F.fakeEfekJalan, math.min(dt, 0.1)) end
end
pcall(F.fakeEfekBersih)
end)
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "Pengaturan kartu (biar pas di screenshot)", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
F.sliderBuat(page, nx, "Lebar kartu", 240, 420, function() return S.fakeSet.lebar or 300 end, function(v) S.fakeSet.lebar = math.floor(v + 0.5) end, "%.0f", " px", F.fakeSusun)
F.sliderBuat(page, nx, "Tinggi area 3D", 100, 420, function() return S.fakeSet.tinggi or 120 end, function(v) S.fakeSet.tinggi = math.floor(v + 0.5) end, "%.0f", " px", F.fakeSusun)
F.sliderBuat(page, nx, "Zoom kamera", 50, 200, function() return S.fakeSet.zoom or 100 end, function(v) S.fakeSet.zoom = math.floor(v + 0.5) end, "%.0f", "%", function() F.fakeKamera(vp) end)
F.sliderBuat(page, nx, "Naik/turun kamera", -80, 80, function() return S.fakeSet.naik or 0 end, function(v) S.fakeSet.naik = math.floor(v + 0.5) end, "%.0f", " px", function() F.fakeKamera(vp) end)
F.sliderBuat(page, nx, "Putar karakter", -180, 180, function() return S.fakeSet.putar or 0 end, function(v) S.fakeSet.putar = math.floor(v + 0.5) end, "%.0f", " derajat", function() F.fakeKamera(vp) end)
F.sliderBuat(page, nx, "Ukuran karakter", 50, 150, function() return S.fakeSet.skala or 100 end, function(v) S.fakeSet.skala = math.floor(v + 0.5) end, "%.0f", "%", function() F.fakeFoto(vp) end)
local reset = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "RESET PENGATURAN KARTU", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(reset)
reset.MouseButton1Click:Connect(function()
S.fakeSet = {tinggi = 260, zoom = 100, naik = 0, putar = 0, skala = 100, lebar = 300}
F.fakeSusun()
F.fakeFoto(vp)
F.segarkanUI()
end)
end
function F.temanKorBaru() return {on = false, objs = {}, hid = {}, sync = {}, bakSepatu = {}, bakM = nil, conn = nil} end
S.teman = S.teman or {nama = "Teman", baju = {}, acc = {}, head = false, putar = 0, stK = {Right = F.temanKorBaru(), Left = F.temanKorBaru()}}
function F.asetDari(teks)
local d = string.match(tostring(teks or ""), "(%d+)")
return d and tonumber(d) or nil
end
function F.temanBadan()
local m = F.fakeModel()
for _, d in ipairs(m:GetDescendants()) do
local nama = tostring(d.Name)
if d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("Script") or d:IsA("LocalScript") or string.sub(nama, 1, 5) == "Zenox" then
pcall(function() d:Destroy() end)
elseif d:IsA("BasePart") and nama ~= "HumanoidRootPart" then
d.Transparency = 0
end
end
F.fakeBersih(m)
return m
end
function F.temanBajuPasang(kelas, id)
local t = S.teman
local cls, prop = "Shirt", "ShirtTemplate"
if kelas == "pants" then cls, prop = "Pants", "PantsTemplate"
elseif kelas == "tshirt" then cls, prop = "ShirtGraphic", "Graphic" end
t.baju[kelas] = id
local m = t.model
if not m then F.catat("teman: badan belum siap, pakaian disimpan"); return true end
local tpl = F.bajuTemplate(kelas, id)
local o = m:FindFirstChildWhichIsA(cls)
if not o then o = Instance.new(cls); o.Parent = m end
o[prop] = tpl
F.catat("teman " .. kelas .. " " .. tostring(id))
return true
end
function F.temanBajuLepas()
local t = S.teman
t.baju = {}
if t.model then
for _, d in ipairs(t.model:GetChildren()) do
if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then pcall(function() d:Destroy() end) end
end
end
F.catat("teman: pakaian dilepas")
end
function F.temanHeadTerap()
local m = S.teman.model
if not m then return end
local hd = m:FindFirstChild("Head")
if hd then hd.Transparency = S.teman.head and 1 or 0 end
F.wajahAksesoris(m, S.teman.head and 1 or 0)
end
function F.temanHeadSet(v)
S.teman.head = v and true or false
F.temanHeadTerap()
F.catat("teman headless " .. (S.teman.head and "ON" or "OFF"))
end
function F.temanKorSet(sisi, v)
local st = S.teman.stK[sisi]
local nama = sisi == "Left" and "kiri" or "kanan"
local tm = S.teman.model
F.korClearS(st)
st.on = v and true or false
if not st.on then
if tm and st.bakM == tm then for _, c in ipairs(st.bakSepatu or {}) do pcall(function() c.Parent = tm end) end end
st.bakSepatu = {}; st.bakM = nil
F.catat("teman korblox " .. nama .. " OFF")
return true
end
if not tm then st.on = false; F.catat("teman: badan belum siap"); return false end
st.bakM = tm; st.bakSepatu = {}
local ok, info
if tm:FindFirstChild(sisi .. "UpperLeg") then ok, info = F.korR15(tm, sisi, st) end
if not ok then ok, info = F.korR6(tm, sisi, st) end
if not ok then st.on = false; F.catat("teman korblox " .. nama .. " gagal: " .. tostring(info)); return false end
F.korSepatu(tm, sisi, st)
st.conn = RS.Heartbeat:Connect(function()
for p in pairs(st.hid) do if p.Parent and p.Transparency ~= 1 then p.Transparency = 1 end end
end)
F.catat("teman korblox " .. nama .. " ON (" .. tostring(info) .. ")")
return true
end
function F.temanAksAda(id)
for _, it in ipairs(S.teman.acc) do if it.id == id then return true end end
return false
end
function F.temanAksPasang(it)
local m = S.teman.model
if not m then return false, "badan belum siap" end
local obj = muat(it.id)
if not obj then return false, "aset " .. tostring(it.id) .. " gagal dimuat" end
return F.pasangAks(m, obj, it)
end
function F.temanAksTambah(id, nama)
local t = S.teman
if not t.model then F.catat("teman: badan belum siap"); return false end
if F.temanAksAda(id) then F.catat("teman: " .. tostring(id) .. " sudah dipasang"); return false end
if C.POSISI and C.POSISI[id] then F.catat("teman: aksesoris " .. tostring(id) .. " belum didukung di teman"); return false end
local it = {id = id, nama = nama or ("Aksesoris " .. tostring(id)), cfg = F.cfgBaru()}
local ok, info = F.temanAksPasang(it)
if not ok then F.catat("teman: " .. it.nama .. " gagal (" .. tostring(info) .. ")"); return false end
table.insert(t.acc, it)
F.catat("teman: " .. it.nama .. " dipasang")
return true
end
function F.temanAksHapus(it)
for i, x in ipairs(S.teman.acc) do
if x == it then table.remove(S.teman.acc, i); break end
end
F.lepasObj(it)
F.catat("teman: " .. tostring(it.nama) .. " dilepas")
end
function F.temanBangun(vp)
local t = S.teman
if vp then t.vp = vp end
if not t.vp then return false, "tampilan belum siap" end
local wantR, wantL = t.stK.Right.on, t.stK.Left.on
F.korClearS(t.stK.Right); F.korClearS(t.stK.Left)
t.stK.Right = F.temanKorBaru(); t.stK.Left = F.temanKorBaru()
if t.model then pcall(function() t.model:Destroy() end) end
t.model = nil
for _, it in ipairs(t.acc) do it.obj = nil; it.src = nil end
local m = F.temanBadan()
m.Parent = t.vp
t.model = m
t.info = F.badanSiap(m)
F.badanPutar(m, t.info, t.putar)
for kelas, id in pairs(t.baju) do F.temanBajuPasang(kelas, id) end
for _, it in ipairs(t.acc) do
local ok, info = F.temanAksPasang(it)
if not ok then F.catat("teman: " .. tostring(it.nama) .. " gagal (" .. tostring(info) .. ")") end
end
F.temanHeadTerap()
if wantR then F.temanKorSet("Right", true) end
if wantL then F.temanKorSet("Left", true) end
F.kameraBadan(t.vp, m, 1.3, 0)
return true
end
function F.temanPutarGeser(d)
local t = S.teman
t.putar = math.floor(math.clamp((t.putar or 0) + d, -180, 180) + 0.5)
if t.model then
F.badanPutar(t.model, t.info, t.putar)
if t.vp then F.kameraBadan(t.vp, t.model, 1.3, 0) end
end
end
function F.togelDesk(page, nx, nama, desk, get, fn)
S.ui.segar = S.ui.segar or {}
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b)
mk("TextLabel", {Size = UDim2.new(1, -66, 0, 20), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b)
mk("TextLabel", {Size = UDim2.new(1, -66, 0, 16), Position = UDim2.new(0, 12, 0, 25), BackgroundTransparency = 1, Text = desk, TextColor3 = MUT, Font = FM, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b)
local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF}, b); rnd(sw, 10)
local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7)
local function p()
local s = get() and true or false
TS:Create(sw, SPRING, {BackgroundColor3 = s and OR or OFF}):Play()
TS:Create(kn, SPRING, {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
end
p(); table.insert(S.ui.segar, p)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() fn(not (get() and true or false)); p() end) end)
return b
end
function F.barisIsi(page, nx, ph, teksTombol, aksi, isi)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local box = mk("TextBox", {Size = UDim2.new(1, -106, 1, -10), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = isi or "", PlaceholderText = ph, PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, r)
local b = mk("TextButton", {Size = UDim2.new(0, 88, 1, -10), Position = UDim2.new(1, -94, 0, 5), BackgroundColor3 = ACT, Text = teksTombol, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, r); rnd(b, 8)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() aksi(box) end) end)
return box, b
end
function F.barisDaftar(wadah, nx, teks, tombolTeks, warna, aksi)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, wadah); rnd(r)
mk("TextLabel", {Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = teks, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r)
local b = mk("TextButton", {Size = UDim2.new(0, 90, 0, 24), Position = UDim2.new(1, -98, 0.5, -12), BackgroundColor3 = warna, Text = tombolTeks, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, r); rnd(b, 8)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, aksi) end)
end
function F.kotakPakaian(page, nx, judul, kelas, pasang, cekPasang)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 74), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
mk("TextLabel", {Size = UDim2.new(0.6, 0, 0, 20), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = judul, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local stat = mk("TextLabel", {Size = UDim2.new(0.4, -12, 0, 20), Position = UDim2.new(0.6, 0, 0, 6), BackgroundTransparency = 1, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right}, r)
local function segarStat() stat.Text = cekPasang(kelas) and "Dipasang" or "Belum dipasang" end
local box = mk("TextBox", {Size = UDim2.new(1, -108, 0, 30), Position = UDim2.new(0, 8, 0, 34), BackgroundColor3 = BG, BorderSizePixel = 0, Text = "", PlaceholderText = "Asset ID / link...", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left}, r); rnd(box, 8)
local b = mk("TextButton", {Size = UDim2.new(0, 88, 0, 30), Position = UDim2.new(1, -96, 0, 34), BackgroundColor3 = ACT, Text = "Pasang", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, r); rnd(b, 8)
b.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
local id = F.asetDari(box.Text)
if not id then F.catat(judul .. ": isi Asset ID angka dulu"); return end
if pasang(kelas, id) then box.Text = "" end
segarStat()
end)
end)
F.daftarSegar(segarStat); segarStat()
end
function F.pgTeman(page)
local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = t, TextColor3 = OR, Font = FB, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Teman", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
if not F.izin("fake") then
local kunci = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = ROW, Text = "Teman khusus VVIP dan ADMIN. Masukkan key VVIP atau ADMIN untuk membuka.", TextColor3 = MUT, Font = FM, TextSize = 12, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(kunci)
return
end
local ket = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = ROW, Text = "Teman fiktif, dibuat dari salinan badanmu. Tidak bisa dipakai untuk meniru pemain lain. Hanya terlihat di layarmu.", TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(ket)
local kartu = mk("Frame", {Size = UDim2.new(1, 0, 0, 230), BackgroundColor3 = Color3.fromRGB(17, 17, 21), BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = nx()}, page)
rnd(kartu, 14)
local vp = mk("ViewportFrame", {Size = UDim2.new(1, 0, 1, -40), BackgroundColor3 = Color3.fromRGB(42, 46, 56), BorderSizePixel = 0}, kartu)
local namaLbl = mk("TextLabel", {Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 1, -36), BackgroundTransparency = 1, Text = tostring(S.teman.nama), TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2}, kartu)
mk("TextLabel", {Size = UDim2.new(0, 170, 0, 16), Position = UDim2.new(0, 10, 0, 8), BackgroundTransparency = 1, Text = "geser = putar avatar", TextColor3 = MUT, Font = FM, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, kartu)
local function tombolPutar(teks, y, d)
local b = mk("TextButton", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -42, 0, y), BackgroundColor3 = Color3.fromRGB(34, 36, 44), Text = teks, TextColor3 = TXT, Font = FB, TextSize = 16, AutoButtonColor = false, ZIndex = 3}, kartu)
rnd(b, 8)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.temanPutarGeser(d) end) end)
end
tombolPutar("+", 10, 15)
tombolPutar("-", 48, -15)
local UIS = game:GetService("UserInputService")
local tarik, xTerakhir = false, 0
vp.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = true; xTerakhir = i.Position.X end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = false end
end)
UIS.InputChanged:Connect(function(i)
if tarik and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
local dx = i.Position.X - xTerakhir
xTerakhir = i.Position.X
pcall(F.temanPutarGeser, dx * 0.6)
end
end)
local status = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local bBuat = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "BUAT ULANG DARI BADANMU", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bBuat)
local segarStatus, segarDaftar
bBuat.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
local ok, err = F.temanBangun(vp)
if not ok then F.catat("teman: " .. tostring(err)) end
segarDaftar(); segarStatus()
end)
end)
sec("SET TEMAN")
F.barisIsi(page, nx, "Nama teman...", "Simpan", function(box)
local nama = trim(box.Text)
if nama == "" then nama = "Teman" end
S.teman.nama = nama
namaLbl.Text = nama
segarStatus()
F.catat("teman: nama jadi " .. nama)
end, tostring(S.teman.nama))
sec("TEMAN - KARAKTER")
F.togelDesk(page, nx, "Korblox Kanan", "Kaki kanan Korblox - otomatis R6 & R15", function() return S.teman.stK.Right.on end, function(v) F.temanKorSet("Right", v) end)
F.togelDesk(page, nx, "Korblox Kiri", "Kaki kiri Korblox - otomatis R6 & R15", function() return S.teman.stK.Left.on end, function(v) F.temanKorSet("Left", v) end)
F.togelDesk(page, nx, "Headless", "Hilangkan kepala & wajah - otomatis R6 & R15", function() return S.teman.head end, function(v) F.temanHeadSet(v) end)
sec("PAKAIAN CLASSIC")
local function pasangTeman(kelas, id) return F.temanBajuPasang(kelas, id) end
local function cekTeman(kelas) return S.teman.baju[kelas] ~= nil end
F.kotakPakaian(page, nx, "Baju (Shirt)", "shirt", pasangTeman, cekTeman)
F.kotakPakaian(page, nx, "Celana (Pants)", "pants", pasangTeman, cekTeman)
F.kotakPakaian(page, nx, "T-Shirt (Graphic)", "tshirt", pasangTeman, cekTeman)
local tLepasBaju = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "LEPAS PAKAIAN", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tLepasBaju)
tLepasBaju.MouseButton1Click:Connect(function() task.spawn(F.aman, F.temanBajuLepas) end)
sec("TEMAN - AKSESORIS")
F.barisIsi(page, nx, "Asset ID / link aksesoris...", "Tambah", function(box)
local id = F.asetDari(box.Text)
if not id then F.catat("teman: isi Asset ID angka dulu"); return end
if F.temanAksTambah(id) then box.Text = "" end
segarDaftar()
end)
local terpasangWadah = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, terpasangWadah)
sec("DARI DAFTAR AKSESORISMU")
local bSegar = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "SEGARKAN DAFTAR", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bSegar)
bSegar.MouseButton1Click:Connect(function() task.spawn(F.aman, function() segarDaftar() end) end)
local katalogWadah = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, katalogWadah)
segarStatus = function()
local m = S.teman.model
local tipe = m and (F.rigTipe(m) or "?") or "-"
status.Text = "Rig: " .. tipe .. "  |  Aksesoris: " .. tostring(#S.teman.acc) .. "  |  Teman: " .. tostring(S.teman.nama)
end
segarDaftar = function()
for _, w in ipairs({terpasangWadah, katalogWadah}) do
for _, c in ipairs(w:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
end
if #S.teman.acc == 0 then
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Belum ada aksesoris di teman", TextColor3 = MUT, Font = FM, TextSize = 11, LayoutOrder = nx()}, terpasangWadah)
end
for _, it in ipairs(S.teman.acc) do
F.barisDaftar(terpasangWadah, nx, tostring(it.nama), "Hapus", BTN, function() F.temanAksHapus(it); segarDaftar(); segarStatus() end)
end
local ada = 0
for _, it in ipairs(S.items) do
if it.kind ~= "gear" and not (C.POSISI and C.POSISI[it.id]) then
ada = ada + 1
local sudah = F.temanAksAda(it.id)
F.barisDaftar(katalogWadah, nx, tostring(it.nama), sudah and "Terpasang" or "Pasang", ACT, function() F.temanAksTambah(it.id, it.nama); segarDaftar(); segarStatus() end)
end
end
if ada == 0 then
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Daftar aksesorismu kosong. Tambah dulu di tab Accesoris.", TextColor3 = MUT, Font = FM, TextSize = 11, LayoutOrder = nx()}, katalogWadah)
end
segarStatus()
end
F.daftarSegar(segarStatus)
segarDaftar()
local idLoop = (S.temanLoop or 0) + 1
S.temanLoop = idLoop
task.spawn(function()
local jumlahItem = -1
while S.temanLoop == idLoop and kartu.Parent do
if F.tampakDi(kartu) then
if S.teman.model == nil or not S.teman.model.Parent then
local okB, errB = pcall(F.temanBangun, vp)
if okB then segarDaftar()
elseif errB ~= S.temanErrTerakhir then
S.temanErrTerakhir = errB
F.catat("teman: badan belum siap (" .. string.sub(tostring(errB), 1, 90) .. ")")
end
end
if #S.items ~= jumlahItem then jumlahItem = #S.items; segarDaftar() end
end
task.wait(2)
end
end)
end
F.SHARE_FILE = "KRONOZ_share.json"
function F.shBaru()
return {
target = nil, model = nil,
baju = {}, bakBaju = {}, head = false, bakHead = nil, headConn = nil,
korOn = {Right = false, Left = false},
stK = {Right = F.temanKorBaru(), Left = F.temanKorBaru()},
acc = {}, lib = nil, sets = nil,
filter = "all", cari = "", pilih = nil, busy = false,
}
end
S.share = S.share or F.shBaru()
function F.shSimpan()
local s = S.share
local data = {lib = {}, sets = s.sets or {}}
for _, d in ipairs(s.lib or {}) do
table.insert(data.lib, {id = d.id, nama = d.nama, fav = d.fav and true or false})
end
local ok, js = pcall(function() return HS:JSONEncode(data) end)
if ok then tulis(F.SHARE_FILE, js) end
end
function F.shMuat()
local s = S.share
if s.lib then return end
s.lib = {}; s.sets = {}
local teks = baca(F.SHARE_FILE)
local dimuat = false
if teks then
local ok, d = pcall(function() return HS:JSONDecode(teks) end)
if ok and type(d) == "table" then
dimuat = true
for _, x in ipairs(d.lib or {}) do
if type(x) == "table" and tonumber(x.id) then
table.insert(s.lib, {id = tonumber(x.id), nama = tostring(x.nama or x.id), fav = x.fav == true})
end
end
for _, x in ipairs(d.sets or {}) do
if type(x) == "table" and x.nama then table.insert(s.sets, x) end
end
end
end
if not dimuat then
local sudah = {}
for _, a in ipairs(C.AKSES or {}) do
local id = tonumber(a[2])
if id and id ~= 0 and not sudah[id] and not (C.POSISI and C.POSISI[id]) then
sudah[id] = true
table.insert(s.lib, {id = id, nama = tostring(a[1]), fav = false})
end
end
end
end
function F.shLibAda(id)
for _, d in ipairs(S.share.lib or {}) do if d.id == id then return d end end
return nil
end
function F.shNamaAmbil(id, cb)
task.spawn(function()
local ok, info = pcall(function() return MPS:GetProductInfo(id) end)
if ok and type(info) == "table" and info.Name and info.Name ~= "" then pcall(cb, tostring(info.Name)) end
end)
end
function F.shCari(teks)
local q = string.lower(trim(teks or ""))
if q == "" then return nil, "isi username / display name dulu" end
local uid = tonumber(q)
local daftar = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= me then table.insert(daftar, p) end end
table.insert(daftar, me)
for pass = 1, 3 do
for _, p in ipairs(daftar) do
local n, d = string.lower(p.Name), string.lower(p.DisplayName)
local cocok = false
if pass == 1 then cocok = (n == q) or (d == q) or (uid ~= nil and p.UserId == uid)
elseif pass == 2 then cocok = (string.sub(n, 1, #q) == q) or (string.sub(d, 1, #q) == q)
else cocok = (string.find(n, q, 1, true) ~= nil) or (string.find(d, q, 1, true) ~= nil) end
if cocok then return p end
end
end
return nil, "pemain tidak ada di server ini"
end
function F.shModel()
local s = S.share
if not s.target or not s.target.Parent then return nil end
local m
if s.target == me then m = F.target() else m = F.modelOf(s.target) end
if m and m.Parent and m:FindFirstChildWhichIsA("BasePart") then return m end
return nil
end
function F.shBajuTerap(kelas, id)
local s = S.share; local m = s.model
if not m then return false end
local tpl = F.bajuTemplate(kelas, id)
local rec = F.bajuPada(m, kelas, tpl)
if not rec then return false end
local lama = s.bakBaju[kelas]
if lama and lama.obj == rec.obj then rec.asli = lama.asli; rec.buat = lama.buat end
s.bakBaju[kelas] = rec
return true
end
function F.shBajuPasang(kelas, id)
local s = S.share
s.baju[kelas] = id
if not s.model then F.catat("share: pakaian disimpan, dipasang saat target siap"); return true end
local ok = F.shBajuTerap(kelas, id)
F.catat("share " .. kelas .. " " .. tostring(id) .. (ok and "" or " gagal"))
return ok
end
function F.shBajuLepasObj()
local s = S.share
for _, rec in pairs(s.bakBaju) do
pcall(function()
if rec.buat then rec.obj:Destroy() elseif rec.obj and rec.obj.Parent then rec.obj[rec.prop] = rec.asli end
end)
end
s.bakBaju = {}
end
function F.shBajuLepas()
local s = S.share
F.shBajuLepasObj()
s.baju = {}
F.catat("share: pakaian dilepas")
end
function F.shFacePulih()
local s = S.share
for d, tr in pairs(s.bakFace or {}) do pcall(function() if d.Parent then d.Transparency = tr end end) end
s.bakFace = nil
end
function F.shHeadTerap()
local s = S.share; local m = s.model
if s.headConn then s.headConn:Disconnect(); s.headConn = nil end
pcall(function() RS:UnbindFromRenderStep("KronozShHead") end)
if not m then return end
local hd = m:FindFirstChild("Head")
if s.head then
if hd then
if s.bakHead == nil then s.bakHead = hd.Transparency end
hd.Transparency = 1
s.bakFace = s.bakFace or setmetatable({}, {__mode = "k"})
for _, d in ipairs(hd:GetChildren()) do
if d:IsA("Decal") or d:IsA("Texture") then
if s.bakFace[d] == nil then s.bakFace[d] = d.Transparency end
d.Transparency = 1
end
end
end
F.wajahAksesoris(m, 1)
s.bakFace = s.bakFace or setmetatable({}, {__mode = "k"})
local function paksa()
local mm = s.model
local h2 = mm and mm:FindFirstChild("Head")
if not h2 then return end
if h2.Transparency ~= 1 then h2.Transparency = 1 end
pcall(function() h2.LocalTransparencyModifier = 1 end)
for _, d in ipairs(h2:GetChildren()) do
if (d:IsA("Decal") or d:IsA("Texture")) and d.Transparency ~= 1 then
if s.bakFace[d] == nil then s.bakFace[d] = d.Transparency end
d.Transparency = 1
end
end
F.wajahAksesoris(mm, 1)
end
paksa()
s.headConn = RS.Heartbeat:Connect(paksa)
pcall(function() RS:BindToRenderStep("KronozShHead", 2001, paksa) end)
elseif s.bakHead ~= nil then
if hd then hd.Transparency = s.bakHead; pcall(function() hd.LocalTransparencyModifier = 0 end) end
s.bakHead = nil
F.shFacePulih()
F.wajahAksesoris(m, 0)
end
end
function F.shHeadSet(v)
if v and not S.share.target then F.notif("Share Outfit", "Set target dulu (isi nama lalu tekan Set)", 3); S.share.head = false; return false end
if v and not S.share.model then F.notif("Share Outfit", "Badan target belum termuat, tunggu sebentar", 3) end
S.share.head = v and true or false
F.shHeadTerap()
F.catat("share headless " .. (S.share.head and "ON" or "OFF"))
end
function F.shNamaHum(custom)
local s = S.share
s.bakNamaTab = s.bakNamaTab or setmetatable({}, {__mode = "k"})
local daftar = {}
for _, mm in ipairs({s.model, s.real, s.target and s.target.Character}) do
if mm then
local hum = mm:FindFirstChildOfClass("Humanoid")
if hum then daftar[hum] = true end
end
end
if custom then
for hum in pairs(daftar) do
if s.bakNamaTab[hum] == nil then s.bakNamaTab[hum] = hum.DisplayName end
if hum.DisplayName ~= custom then hum.DisplayName = custom end
end
else
for hum, asli in pairs(s.bakNamaTab) do pcall(function() if hum.Parent then hum.DisplayName = asli end end) end
s.bakNamaTab = setmetatable({}, {__mode = "k"})
end
end
function F.shNamaSapu(custom)
local s = S.share
local p = s.target
if not p then return 0 end
local nm, dn = string.lower(p.Name), string.lower(p.DisplayName or "")
local akar = {}
local pg = me:FindFirstChildOfClass("PlayerGui"); if pg then table.insert(akar, pg) end
local okC, cg = pcall(function() return game:GetService("CoreGui") end)
if okC and cg then table.insert(akar, cg) end
if s.model then table.insert(akar, s.model) end
if p.Character and p.Character ~= s.model then table.insert(akar, p.Character) end
local jumlah = 0
for _, root in ipairs(akar) do
for _, d in ipairs(root:GetDescendants()) do
if (d:IsA("TextLabel") or d:IsA("TextButton")) and not F.diUI(d) then
local tampil = d:GetAttribute("KzShTampil")
if tampil ~= nil and d.Text ~= tampil then
d:SetAttribute("KzShAsli", nil); d:SetAttribute("KzShTampil", nil)
tampil = nil
end
if tampil ~= nil then
if custom then
jumlah = jumlah + 1
else
d.Text = d:GetAttribute("KzShAsli") or d.Text
d:SetAttribute("KzShAsli", nil); d:SetAttribute("KzShTampil", nil)
end
elseif custom then
local raw = d.Text or ""
local t2 = string.lower(trim((string.gsub(raw, "<[^>]->", ""))))
local pakaiAt = string.sub(t2, 1, 1) == "@"
t2 = string.gsub(t2, "^@", "")
local pakaiTitik = string.sub(t2, -1) == ":"
t2 = trim((string.gsub(t2, ":$", "")))
if t2 ~= "" and (t2 == nm or t2 == dn) then
local baru = custom
if pakaiAt then baru = "@" .. (string.gsub(custom, "%s", "")) end
if pakaiTitik then baru = baru .. ":" end
d:SetAttribute("KzShAsli", raw)
d:SetAttribute("KzShTampil", baru)
d.Text = baru
jumlah = jumlah + 1
end
end
end
end
end
return jumlah
end
function F.shNamaTerap()
local s = S.share
if not s.nama or not s.target then return end
pcall(F.shNamaHum, s.nama)
local ok, n = pcall(F.shNamaSapu, s.nama)
if ok and n and n > 0 and not s.namaLapor then s.namaLapor = true; F.catat("share: nama target ketemu di layar " .. n .. " baris") end
end
function F.shNamaPulih()
local s = S.share
pcall(F.shNamaHum, nil)
pcall(F.shNamaSapu, nil)
s.namaLapor = nil
end
function F.shNamaSet(teks)
local s = S.share
teks = trim((string.gsub(tostring(teks or ""), "[<>]", "")))
if teks == "" then s.nama = nil; F.shNamaPulih(); return true end
if not s.target then F.notif("Share Outfit", "Set target dulu (isi nama lalu tekan Set)", 3); return false end
s.nama = string.sub(teks, 1, 24)
s.namaLapor = nil
F.shNamaTerap()
F.catat("share: nama target jadi " .. s.nama)
return true
end
function F.shKorBersih(sisi, pulih)
local s = S.share; local st = s.stK[sisi]; local m = s.model
F.korClearS(st)
if pulih and m and m.Parent and st.bakM == m then
for _, c in ipairs(st.bakSepatu or {}) do pcall(function() c.Parent = m end) end
end
st.bakSepatu = {}; st.bakM = nil
end
function F.shKorTerap(sisi)
local s = S.share; local m = s.model; local st = s.stK[sisi]
if not m then return false end
F.shKorBersih(sisi, false)
st.bakM = m; st.bakSepatu = {}
local ok, info
if m:FindFirstChild(sisi .. "UpperLeg") then ok, info = F.korR15(m, sisi, st) end
if not ok then ok, info = F.korR6(m, sisi, st) end
if not ok then F.catat("share korblox " .. sisi .. " gagal: " .. tostring(info)); return false end
F.korSepatu(m, sisi, st)
st.conn = RS.Heartbeat:Connect(function()
for p in pairs(st.hid) do if p.Parent and p.Transparency ~= 1 then p.Transparency = 1 end end
end)
F.catat("share korblox " .. sisi .. " ON (" .. tostring(info) .. ")")
return true
end
function F.shKorSet(sisi, v)
local s = S.share
if v and not s.target then F.notif("Share Outfit", "Set target dulu (isi nama lalu tekan Set)", 3); s.korOn[sisi] = false; return false end
s.korOn[sisi] = v and true or false
if not v then F.shKorBersih(sisi, true); F.catat("share korblox " .. sisi .. " OFF"); return true end
if not s.model then F.catat("share: korblox disimpan, dipasang saat target siap"); return true end
local ok = F.shKorTerap(sisi)
if not ok then s.korOn[sisi] = false end
return ok
end
function F.shAksAda(id)
for _, it in ipairs(S.share.acc) do if it.id == id then return it end end
return nil
end
function F.shAksPasang(it)
local m = S.share.model
if not m then return false, "target belum siap" end
local obj = muat(it.id)
if not obj then return false, "aset " .. tostring(it.id) .. " gagal dimuat" end
local ok, info = F.pasangAks(m, obj, it)
if ok and it.obj then pcall(F.efekTerapkan, it.obj, it.cfg) end
return ok, info
end
function F.shAksTambah(id, nama)
local s = S.share
if not s.target then F.catat("share: set target dulu"); return false end
if C.POSISI and C.POSISI[id] then F.catat("share: aksesoris " .. tostring(id) .. " belum didukung"); return false end
if F.shAksAda(id) then return true end
local it = {id = id, nama = nama or ("Aksesoris " .. tostring(id)), cfg = F.cfgBaru()}
if not s.model then table.insert(s.acc, it); F.catat("share: disimpan, dipasang saat target siap"); return true end
local ok, info = F.shAksPasang(it)
if not ok then F.catat("share: " .. it.nama .. " gagal (" .. tostring(info) .. ")"); return false end
table.insert(s.acc, it)
F.catat("share: " .. it.nama .. " dipasang")
return true
end
function F.shAksLepas(id)
local s = S.share
for i, it in ipairs(s.acc) do
if it.id == id then
table.remove(s.acc, i)
F.lepasObj(it)
F.catat("share: " .. tostring(it.nama) .. " dilepas")
return true
end
end
return false
end
function F.shAksUlang(it)
F.lepasObj(it)
local ok, info = F.shAksPasang(it)
if not ok then F.catat("share: " .. tostring(it.nama) .. " gagal (" .. tostring(info) .. ")") end
end
function F.shAksUlangTunda(it)
it.tunda = (it.tunda or 0) + 1
local n = it.tunda
task.delay(0.15, function()
if it.tunda == n then F.aman(function() F.shAksUlang(it) end) end
end)
end
function F.shLepasEfek(pulih)
local s = S.share
for _, sisi in ipairs({"Right", "Left"}) do F.shKorBersih(sisi, pulih) end
for _, it in ipairs(s.acc) do F.lepasObj(it) end
if s.headConn then s.headConn:Disconnect(); s.headConn = nil end
pcall(function() RS:UnbindFromRenderStep("KronozShHead") end)
if pulih then
local m = s.model
if m and m.Parent and s.bakHead ~= nil then
local hd = m:FindFirstChild("Head")
if hd then hd.Transparency = s.bakHead end
F.wajahAksesoris(m, 0)
end
F.shFacePulih()
F.shBajuLepasObj()
F.shNamaPulih()
else
s.bakFace = nil; s.bakNama = nil; s.labelBak = nil
end
s.bakHead = nil; s.bakBaju = {}
end
function F.shTerapkanSemua()
local s = S.share
if not s.model then return end
for kelas, id in pairs(s.baju) do pcall(F.shBajuTerap, kelas, id) end
F.shHeadTerap()
for _, sisi in ipairs({"Right", "Left"}) do
if s.korOn[sisi] then pcall(F.shKorTerap, sisi) end
end
for _, it in ipairs(s.acc) do
it.coba = 0
local ok, info = F.shAksPasang(it)
if not ok then F.catat("share: " .. tostring(it.nama) .. " gagal (" .. tostring(info) .. ")") end
end
end
function F.shBusy(fn)
local s = S.share
s.busy = true
local ok, e = pcall(fn)
s.busy = false
if not ok then error(e, 0) end
end
function F.shSetTarget(p)
local s = S.share
F.shBusy(function()
if s.model then F.shLepasEfek(true) end
F.shRigBongkar(true); s.rigMode = nil
s.target = p
for _ = 1, 12 do
s.model = F.shModel()
if s.model then break end
task.wait(0.25)
end
if s.model then F.rigExtra[s.model] = true end
F.shTerapkanSemua()
end)
F.catat("share: target " .. tostring(p.Name))
end
function F.shReset()
local s = S.share
F.shBusy(function()
F.shLepasEfek(true)
F.shRigBongkar(true)
if s.real == nil and s.rigMode then s.model = F.shModel() end
s.rigMode = nil
s.model = F.shModel()
s.acc = {}; s.baju = {}; s.head = false; s.nama = nil
s.korOn = {Right = false, Left = false}
end)
F.catat("share: outfit target dikembalikan")
end
F.SH_BADAN = {Head = true, Torso = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
UpperTorso = true, LowerTorso = true, LeftUpperArm = true, LeftLowerArm = true, LeftHand = true, RightUpperArm = true, RightLowerArm = true, RightHand = true,
LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true, RightUpperLeg = true, RightLowerLeg = true, RightFoot = true, HumanoidRootPart = true}
function F.shRigBongkar(pulih)
local s = S.share
if s.rigConn then s.rigConn:Disconnect(); s.rigConn = nil end
if pulih and s.real and s.real.Parent then
for _, d in ipairs(s.real:GetDescendants()) do
if d:IsA("BasePart") then pcall(function() d.LocalTransparencyModifier = 0 end) end
end
end
if s.overlay then pcall(function() s.overlay:Destroy() end) end
s.overlay = nil
if pulih then s.real = nil end
end
function F.shRigSembunyi()
local real = S.share.real
if not real or not real.Parent then return end
for _, d in ipairs(real:GetDescendants()) do
if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
pcall(function() if d.LocalTransparencyModifier ~= 1 then d.LocalTransparencyModifier = 1 end end)
end
end
end
function F.shRigPose()
local s = S.share
local real, ov = s.real, s.overlay
if not real or not real.Parent or not ov or not ov.Parent then return end
local function P(m, n) local x = m:FindFirstChild(n); return (x and x:IsA("BasePart")) and x or nil end
local function dariAtas(pos, atas, kananHint)
local u = atas.Unit
local r = kananHint - u * kananHint:Dot(u)
if r.Magnitude < 0.001 then r = Vector3.new(1, 0, 0) - u * u.X end
r = r.Unit
return CFrame.fromMatrix(pos, r, u, r:Cross(u))
end
local akarR, akarO = P(real, "HumanoidRootPart"), P(ov, "HumanoidRootPart")
if akarR and akarO then akarO.CFrame = akarR.CFrame end
if s.rigMode == "R6" then
local ut, lt, hd = P(real, "UpperTorso"), P(real, "LowerTorso"), P(real, "Head")
if not (ut and lt and hd) then return end
local tor, oh = P(ov, "Torso"), P(ov, "Head")
if tor then tor.CFrame = ut.CFrame * CFrame.new(0, -lt.Size.Y / 2, 0) end
if oh then oh.CFrame = hd.CFrame end
for _, sisi in ipairs({"Right", "Left"}) do
local ua, tangan, lengan = P(real, sisi .. "UpperArm"), P(real, sisi .. "Hand"), P(ov, sisi .. " Arm")
if ua and tangan and lengan then
local bahu = ua.CFrame * Vector3.new(0, ua.Size.Y / 2, 0)
local ujung = tangan.CFrame * Vector3.new(0, -tangan.Size.Y / 2, 0)
lengan.CFrame = dariAtas((bahu + ujung) / 2, bahu - ujung, ua.CFrame.RightVector)
end
local ul, kaki, tungkai = P(real, sisi .. "UpperLeg"), P(real, sisi .. "Foot"), P(ov, sisi .. " Leg")
if ul and kaki and tungkai then
local pinggul = ul.CFrame * Vector3.new(0, ul.Size.Y / 2, 0)
local ujung = kaki.CFrame * Vector3.new(0, -kaki.Size.Y / 2, 0)
tungkai.CFrame = dariAtas((pinggul + ujung) / 2, pinggul - ujung, ul.CFrame.RightVector)
end
end
else
local tor, hd = P(real, "Torso"), P(real, "Head")
if not (tor and hd) then return end
local ut, lt, oh = P(ov, "UpperTorso"), P(ov, "LowerTorso"), P(ov, "Head")
if ut and lt then
ut.CFrame = tor.CFrame * CFrame.new(0, lt.Size.Y / 2, 0)
lt.CFrame = tor.CFrame * CFrame.new(0, -ut.Size.Y / 2, 0)
end
if oh then oh.CFrame = hd.CFrame end
local function ruas(sumber, a, b, c)
if not (sumber and a and b and c) then return end
local L = sumber.Size.Y
local total = a.Size.Y + b.Size.Y + c.Size.Y
local cum = 0
for _, x in ipairs({a, b, c}) do
local f = (cum + x.Size.Y / 2) / total
x.CFrame = sumber.CFrame * CFrame.new(0, L / 2 - f * L, 0)
cum = cum + x.Size.Y
end
end
for _, sisi in ipairs({"Right", "Left"}) do
ruas(P(real, sisi .. " Arm"), P(ov, sisi .. "UpperArm"), P(ov, sisi .. "LowerArm"), P(ov, sisi .. "Hand"))
ruas(P(real, sisi .. " Leg"), P(ov, sisi .. "UpperLeg"), P(ov, sisi .. "LowerLeg"), P(ov, sisi .. "Foot"))
end
end
end
function F.shRigBangun(tipe)
local s = S.share
if not s.target then return false, "target belum ada" end
local desc, err
do
local sumber = s.real or F.shModel()
local humS = sumber and sumber:FindFirstChildOfClass("Humanoid")
if humS then
local okA, dA = pcall(function() return humS:GetAppliedDescription() end)
if okA and dA then desc = dA end
end
end
if not desc then desc, err = CLONE.getDesc(s.target.UserId) end
if not desc then return false, "gagal ambil data avatar: " .. tostring(err) end
local enumTipe = (tipe == "R6") and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
local okM, ref = pcall(function()
if tipe == "R15" and CLONE.buildR15 then
local b = CLONE.buildR15(desc, enumTipe)
if b then return b end
end
return Players:CreateHumanoidModelFromDescription(desc, enumTipe)
end)
if not okM or not ref then return false, "gagal buat model " .. tipe .. ": " .. tostring(ref) end
ref.Name = "KronozRig_" .. tostring(s.target.Name)
for _, d in ipairs(ref:GetDescendants()) do
if d:IsA("Script") or d:IsA("LocalScript") then pcall(function() d:Destroy() end) end
if d:IsA("BasePart") then
d.CanCollide = false
pcall(function() d.CanTouch = false end)
if d.Parent == ref and F.SH_BADAN[d.Name] then d.Anchored = true else d.Massless = true end
end
end
local hum = ref:FindFirstChildOfClass("Humanoid")
if hum then
pcall(function()
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
end)
end
local folder = workspace:FindFirstChild("KronozRig")
if not folder then folder = Instance.new("Folder"); folder.Name = "KronozRig"; folder.Parent = workspace end
ref.Parent = folder
s.overlay = ref
F.rigExtra[ref] = true
F.shRigPose()
s.rigConn = RS.RenderStepped:Connect(function() pcall(F.shRigPose) end)
return true
end
function F.shRigSet(tipe)
local s = S.share
if not s.target then F.notif("Share Outfit", "Set target dulu (isi nama lalu tekan Set)", 3); return false end
local real = s.real or F.shModel()
if not real then F.notif("Share Outfit", "Badan target belum termuat, tunggu sebentar", 3); return false end
local asliTipe = F.rigTipe(real)
F.shBusy(function()
F.shLepasEfek(true)
F.shRigBongkar(true)
s.rigMode = nil
s.model = real
if tipe ~= "asli" and tipe ~= asliTipe then
s.real = real
s.rigMode = tipe
local ok, err = F.shRigBangun(tipe)
if ok then
s.model = s.overlay
F.shRigSembunyi()
else
s.rigMode = nil; s.real = nil; s.model = real
F.notif("Share Outfit", tostring(err), 5)
end
elseif tipe ~= "asli" then
F.notif("Share Outfit", "badan target sudah " .. tostring(tipe), 3)
end
if s.model then F.rigExtra[s.model] = true end
F.shTerapkanSemua()
end)
F.catat("share: rig target " .. tostring(s.rigMode or "asli"))
return true
end
function F.shTick()
local s = S.share
if s.busy or not s.target then return end
if not s.target.Parent then
F.shBusy(function()
F.shLepasEfek(false)
F.shRigBongkar(false)
s.model = nil; s.target = nil; s.rigMode = nil; s.real = nil
end)
F.catat("share: target keluar dari server")
F.segarkanUI()
return
end
local real = F.shModel()
if s.nama then pcall(F.shNamaTerap) end
if s.rigMode then
if real ~= s.real or not s.overlay or not s.overlay.Parent then
F.shBusy(function()
F.shLepasEfek(false)
F.shRigBongkar(false)
s.real = real
s.model = nil
if real then
task.wait(0.6)
local ok, err = F.shRigBangun(s.rigMode)
if ok then
s.model = s.overlay
F.shRigSembunyi()
F.shTerapkanSemua()
else
F.catat("share: rig gagal dibangun ulang (" .. tostring(err) .. ")")
s.rigMode = nil; s.model = real
end
end
end)
F.segarkanUI()
return
end
F.shRigSembunyi()
elseif real ~= s.model then
F.shBusy(function()
F.shLepasEfek(false)
s.model = real
if real then
F.rigExtra[real] = true
task.wait(0.6)
F.shTerapkanSemua()
end
end)
F.segarkanUI()
return
end
local m = s.model
if m then
for _, it in ipairs(s.acc) do
if (not it.obj or not it.obj.Parent) and (it.coba or 0) < 3 then
it.coba = (it.coba or 0) + 1
F.lepasObj(it)
F.shAksPasang(it)
end
end
end
end
function F.shJaga()
local idLoop = (S.shareLoop or 0) + 1
S.shareLoop = idLoop
task.spawn(function()
while S.shareLoop == idLoop and S.alive do
task.wait(S.share.nama and 0.5 or 1)
local ok, e = pcall(F.shTick)
if not ok then F.catat("share: " .. string.sub(tostring(e), 1, 90)) end
end
end)
end
function F.shSetSimpan(nama)
local s = S.share
local d = {nama = nama, acc = {}, baju = {}, head = s.head, kr = s.korOn.Right, kl = s.korOn.Left}
for _, it in ipairs(s.acc) do
table.insert(d.acc, {id = it.id, nama = it.nama, ox = it.cfg.ox, oy = it.cfg.oy, oz = it.cfg.oz, skala = it.cfg.skala})
end
for k, v in pairs(s.baju) do d.baju[k] = v end
for i, x in ipairs(s.sets) do
if x.nama == nama then table.remove(s.sets, i); break end
end
table.insert(s.sets, d)
F.shSimpan()
F.catat("share: set '" .. nama .. "' disimpan")
end
function F.shSetPakai(d)
local s = S.share
if not s.target then F.catat("share: set target dulu"); return end
F.shBusy(function()
F.shLepasEfek(true)
s.acc = {}; s.baju = {}
s.head = d.head == true
s.korOn = {Right = d.kr == true, Left = d.kl == true}
for _, a in ipairs(d.acc or {}) do
local cfg = F.cfgBaru()
cfg.ox = tonumber(a.ox) or 0; cfg.oy = tonumber(a.oy) or 0; cfg.oz = tonumber(a.oz) or 0; cfg.skala = tonumber(a.skala) or 1
table.insert(s.acc, {id = tonumber(a.id), nama = tostring(a.nama or a.id), cfg = cfg})
end
for k, v in pairs(d.baju or {}) do
if tonumber(v) then s.baju[k] = tonumber(v) end
end
F.shTerapkanSemua()
end)
F.catat("share: set '" .. tostring(d.nama) .. "' dipakai")
end
function F.pgShare(page)
local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = t, TextColor3 = OR, Font = FB, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Share Outfit 2.0", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
if not F.izin("fake") then
local kunci = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = ROW, Text = "Share Outfit khusus VVIP dan ADMIN. Masukkan key VVIP atau ADMIN untuk membuka.", TextColor3 = MUT, Font = FM, TextSize = 12, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(kunci)
return
end
F.shMuat()
local s = S.share
local ket = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = ROW, Text = "Ubah outfit pemain lain di server. Hanya terlihat di layarmu, pemain lain tidak ikut berubah.", TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(ket)
local statusLbl, segarStatus, gridRender, setRender, adjSegar
sec("TARGET")
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Target Pemain", TextColor3 = TXT, Font = FM, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local boxTarget = F.barisIsi(page, nx, "Username / display name...", "Set", function(box)
local p, err = F.shCari(box.Text)
if not p then F.catat("share: " .. tostring(err)); F.notif("Share Outfit", tostring(err), 3); return end
F.shSetTarget(p)
box.Text = ""
segarStatus(); gridRender(); setRender()
local m = S.share.model
F.notif("Share Outfit", "Target: " .. tostring(p.DisplayName) .. (m and (" (" .. tostring(F.rigTipe(m) or "?") .. ")") or " - badan belum siap"), 3)
end)
statusLbl = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Belum ada target", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = nx()}, page)
local chipP = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, LayoutOrder = nx()}, page)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, chipP)
local sigPemain = ""
local function pemainRender()
local ids = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= me then table.insert(ids, p.UserId) end end
local sig = table.concat(ids, ",")
if sig == sigPemain then return end
sigPemain = sig
for _, c in ipairs(chipP:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
local i = 0
for _, p in ipairs(Players:GetPlayers()) do
if p ~= me then
i = i + 1
local b = mk("TextButton", {Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = ROW, Text = tostring(p.DisplayName), TextColor3 = TXT, Font = FM, TextSize = 11, AutoButtonColor = false, LayoutOrder = i}, chipP)
rnd(b, 9)
mk("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, b)
b.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
if not p.Parent then F.catat("share: pemain sudah keluar"); return end
F.shSetTarget(p); segarStatus(); gridRender(); setRender()
F.notif("Share Outfit", "Target: " .. tostring(p.DisplayName), 2)
end)
end)
end
end
if i == 0 then
mk("TextLabel", {Size = UDim2.new(0, 220, 0, 26), BackgroundTransparency = 1, Text = "Belum ada pemain lain di server", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, chipP)
end
end
pemainRender()
task.spawn(function()
local idp = (S.sharePemainLoop or 0) + 1
S.sharePemainLoop = idp
while S.sharePemainLoop == idp and chipP.Parent and S.alive do
task.wait(3)
pcall(pemainRender)
end
end)
sec("NAMA TARGET")
F.barisIsi(page, nx, "Nama tampil baru...", "Ganti", function(box)
if not s.target then F.notif("Share Outfit", "set target dulu", 3); return end
if trim(box.Text) == "" then F.notif("Share Outfit", "isi nama baru dulu", 3); return end
F.shNamaSet(box.Text)
F.notif("Share Outfit", "nama target diganti (hanya di layarmu)", 3)
end)
local bNamaPulih = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "KEMBALIKAN NAMA", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bNamaPulih)
bNamaPulih.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.shNamaSet("") end) end)
sec("TIPE RIG TARGET")
local rigRow = mk("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, rigRow)
local rigBtn = {}
local function rigWarna()
local aktif = s.rigMode or "asli"
for k, b in pairs(rigBtn) do b.BackgroundColor3 = (k == aktif) and ACT or ROW end
end
for i, pr in ipairs({{"asli", "Asli"}, {"R15", "Jadi R15"}, {"R6", "Jadi R6"}}) do
local b = mk("TextButton", {Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = ROW, Text = pr[2], TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = i}, rigRow)
rnd(b, 9); rigBtn[pr[1]] = b
b.MouseButton1Click:Connect(function()
task.spawn(F.aman, function() F.shRigSet(pr[1]); rigWarna(); segarStatus(); gridRender(); F.segarkanUI() end)
end)
end
F.daftarSegar(rigWarna); rigWarna()
sec("TEMAN - KARAKTER")
F.togelDesk(page, nx, "Korblox Kanan", "Kaki kanan Korblox - otomatis R6 & R15", function() return s.korOn.Right end, function(v) F.shKorSet("Right", v) end)
F.togelDesk(page, nx, "Korblox Kiri", "Kaki kiri Korblox - otomatis R6 & R15", function() return s.korOn.Left end, function(v) F.shKorSet("Left", v) end)
F.togelDesk(page, nx, "Headless", "Hilangkan kepala & wajah - otomatis R6 & R15", function() return s.head end, function(v) F.shHeadSet(v) end)
sec("PAKAIAN CLASSIC")
local function pasangBaju(kelas, id) return F.shBajuPasang(kelas, id) end
local function cekBaju(kelas) return s.baju[kelas] ~= nil end
F.kotakPakaian(page, nx, "Baju (Shirt)", "shirt", pasangBaju, cekBaju)
F.kotakPakaian(page, nx, "Celana (Pants)", "pants", pasangBaju, cekBaju)
F.kotakPakaian(page, nx, "T-Shirt (Graphic)", "tshirt", pasangBaju, cekBaju)
local bLepasBaju = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "LEPAS PAKAIAN", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bLepasBaju)
bLepasBaju.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.shBajuLepas(); F.segarkanUI() end) end)
sec("SET TEMAN")
F.barisIsi(page, nx, "Nama set...", "Simpan", function(box)
local nama = trim(box.Text)
if nama == "" then F.catat("share: isi nama set dulu"); return end
F.shSetSimpan(nama)
box.Text = ""
setRender()
end)
local setWadah = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, setWadah)
setRender = function()
for _, c in ipairs(setWadah:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
if #s.sets == 0 then
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Belum ada set tersimpan", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, setWadah)
return
end
for i, d in ipairs(s.sets) do
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = i}, setWadah)
rnd(r)
mk("TextLabel", {Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = tostring(d.nama), TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r)
local bP = mk("TextButton", {Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -134, 0.5, -12), BackgroundColor3 = ACT, Text = "Pakai", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, r)
rnd(bP, 8)
local bH = mk("TextButton", {Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -68, 0.5, -12), BackgroundColor3 = BTN, Text = "Hapus", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, r)
rnd(bH, 8)
bP.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.shSetPakai(d); segarStatus(); gridRender(); F.segarkanUI() end) end)
bH.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
for k, x in ipairs(s.sets) do if x == d then table.remove(s.sets, k); break end end
F.shSimpan(); setRender()
end)
end)
end
end
setRender()
sec("TEMAN - AKSESORIS")
local baris = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
local bSemua = mk("TextButton", {Size = UDim2.new(0, 72, 1, 0), BackgroundColor3 = ACT, Text = "Semua", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, baris)
rnd(bSemua, 9)
local bFavF = mk("TextButton", {Size = UDim2.new(0, 72, 1, 0), Position = UDim2.new(0, 78, 0, 0), BackgroundColor3 = ROW, Text = "Favorit", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, baris)
rnd(bFavF, 9)
local jumlahLbl = mk("TextLabel", {Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -90, 0, 0), BackgroundTransparency = 1, Text = "0 item", TextColor3 = MUT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right}, baris)
local cariRow = mk("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(cariRow)
local boxCari = mk("TextBox", {Size = UDim2.new(1, -20, 1, -10), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = "", PlaceholderText = "Cari nama / ID...", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, cariRow)
F.barisIsi(page, nx, "Asset ID / link", "Tambah", function(box)
local id = F.asetDari(box.Text)
if not id then F.catat("share: isi Asset ID angka dulu"); return end
if C.POSISI and C.POSISI[id] then F.catat("share: aksesoris " .. tostring(id) .. " belum didukung"); return end
if not F.shLibAda(id) then
local d = {id = id, nama = "Aksesoris " .. tostring(id), fav = false}
table.insert(s.lib, d)
F.shSimpan()
F.shNamaAmbil(id, function(nama) d.nama = nama; F.shSimpan(); pcall(gridRender) end)
end
box.Text = ""
gridRender()
end)
local kisi = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIGridLayout", {CellSize = UDim2.new(0.32, 0, 0, 186), CellPadding = UDim2.new(0.0133, 0, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, kisi)
local function filterWarna()
bSemua.BackgroundColor3 = (s.filter == "all") and ACT or ROW
bFavF.BackgroundColor3 = (s.filter == "fav") and ACT or ROW
end
gridRender = function()
for _, c in ipairs(kisi:GetChildren()) do if not c:IsA("UIGridLayout") then c:Destroy() end end
local q = string.lower(trim(s.cari or ""))
local tampil, i = 0, 0
for _, d in ipairs(s.lib) do
local lolos = true
if s.filter == "fav" and not d.fav then lolos = false end
if lolos and q ~= "" then
lolos = (string.find(string.lower(d.nama), q, 1, true) ~= nil) or (string.find(tostring(d.id), q, 1, true) ~= nil)
end
if lolos then
tampil = tampil + 1; i = i + 1
local pasang = F.shAksAda(d.id) ~= nil
local k = mk("Frame", {BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = i}, kisi)
rnd(k, 12); mk("UIStroke", {Color = BRD, Thickness = 1}, k)
local gambar = mk("ImageLabel", {Size = UDim2.new(1, -16, 0, 80), Position = UDim2.new(0, 8, 0, 8), BackgroundColor3 = BG, BorderSizePixel = 0, Image = "rbxthumb://type=Asset&id=" .. tostring(d.id) .. "&w=150&h=150", ScaleType = Enum.ScaleType.Fit}, k)
rnd(gambar, 10)
local bf = mk("TextButton", {Size = UDim2.new(0, 28, 0, 18), Position = UDim2.new(0, 12, 0, 12), BackgroundColor3 = d.fav and Color3.fromRGB(75, 12, 17) or BTN, Text = "FAV", TextColor3 = d.fav and OR or MUT, Font = FB, TextSize = 9, AutoButtonColor = false, ZIndex = 3}, k)
rnd(bf, 6)
mk("TextLabel", {Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 0, 92), BackgroundTransparency = 1, Text = d.nama, TextColor3 = TXT, Font = FM, TextSize = 10, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Center}, k)
local bPasang = mk("TextButton", {Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 126), BackgroundColor3 = pasang and BTN or ACT, Text = pasang and "Lepas" or "Pasang", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, k)
rnd(bPasang, 8)
local sel = (s.pilih == d.id)
local bPilih = mk("TextButton", {Size = UDim2.new(0.5, -11, 0, 24), Position = UDim2.new(0, 8, 0, 156), BackgroundColor3 = sel and ACT or BTN, Text = "Pilih", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, k)
rnd(bPilih, 8)
local bHapus = mk("TextButton", {Size = UDim2.new(0.5, -11, 0, 24), Position = UDim2.new(0.5, 3, 0, 156), BackgroundColor3 = Color3.fromRGB(75, 12, 17), Text = "Hapus", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, k)
rnd(bHapus, 8)
bf.MouseButton1Click:Connect(function()
task.spawn(F.aman, function() d.fav = not d.fav; F.shSimpan(); gridRender() end)
end)
bPasang.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
if F.shAksAda(d.id) then F.shAksLepas(d.id) else F.shAksTambah(d.id, d.nama) end
gridRender(); segarStatus(); if adjSegar then adjSegar() end
end)
end)
bPilih.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
s.pilih = d.id
if not F.shAksAda(d.id) then F.shAksTambah(d.id, d.nama) end
gridRender(); segarStatus(); if adjSegar then adjSegar() end
end)
end)
bHapus.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
F.shAksLepas(d.id)
for kk, x in ipairs(s.lib) do if x == d then table.remove(s.lib, kk); break end end
if s.pilih == d.id then s.pilih = nil end
F.shSimpan(); gridRender(); segarStatus(); if adjSegar then adjSegar() end
end)
end)
end
end
if tampil == 0 then
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = (s.filter == "fav") and "Belum ada favorit" or "Tidak ada item", TextColor3 = MUT, Font = FM, TextSize = 11, LayoutOrder = 1, TextWrapped = true}, kisi)
end
jumlahLbl.Text = tostring(#s.lib) .. " item"
filterWarna()
end
bSemua.MouseButton1Click:Connect(function() s.filter = "all"; gridRender() end)
bFavF.MouseButton1Click:Connect(function() s.filter = "fav"; gridRender() end)
boxCari:GetPropertyChangedSignal("Text"):Connect(function() s.cari = boxCari.Text; gridRender() end)
sec("ATUR ITEM TERPILIH")
local pilihLbl = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Belum ada item dipilih. Tekan Pilih pada kartu.", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = nx()}, page)
local function itPilih() return s.pilih and F.shAksAda(s.pilih) or nil end
adjSegar = function()
local it = itPilih()
pilihLbl.Text = it and ("Terpilih: " .. tostring(it.nama)) or "Belum ada item dipilih. Tekan Pilih pada kartu."
F.segarkanUI()
end
local function slider(nama, lo, hi, kunci, fm, satuan)
F.sliderBuat(page, nx, nama, lo, hi,
function() local it = itPilih(); return it and it.cfg[kunci] or (kunci == "skala" and 1 or 0) end,
function(v) local it = itPilih(); if it then it.cfg[kunci] = math.floor(v * 100 + 0.5) / 100 end end,
fm, satuan,
function() local it = itPilih(); if it then F.shAksUlangTunda(it) end end)
end
slider("Geser kiri/kanan", -3, 3, "ox", "%.2f", " stud")
slider("Geser naik/turun", -3, 3, "oy", "%.2f", " stud")
slider("Geser depan/belakang", -3, 3, "oz", "%.2f", " stud")
slider("Ukuran item", 0.2, 3, "skala", "%.2f", "x")
local function sliderEfek(nama, kunci)
F.sliderBuat(page, nx, nama, 0.5, 8,
function() local it = itPilih(); return it and it.cfg[kunci] or 1 end,
function(v) local it = itPilih(); if it then it.cfg[kunci] = math.floor(v * 10 + 0.5) / 10 end end,
"%.1f", "x",
function() local it = itPilih(); if it and it.obj then pcall(F.efekTerapkan, it.obj, it.cfg) end end)
end
sliderEfek("Kepadatan efek", "rate")
sliderEfek("Tebal efek", "size")
local bReset = mk("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = ACT, Text = "KEMBALIKAN OUTFIT TARGET", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(bReset)
bReset.MouseButton1Click:Connect(function()
task.spawn(F.aman, function() F.shReset(); gridRender(); segarStatus(); F.segarkanUI() end)
end)
local foot = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
segarStatus = function()
local m = s.model
local tipe = m and (F.rigTipe(m) or "?") or "-"
local nama = s.target and tostring(s.target.DisplayName) or "-"
statusLbl.Text = s.target and ("Target: " .. nama .. " (@" .. tostring(s.target.Name) .. ")" .. (m and "" or " - badan belum siap")) or "Belum ada target"
statusLbl.TextColor3 = s.target and TXT or MUT
foot.Text = "Rig: " .. tipe .. "  |  Item: " .. tostring(#s.acc) .. "  |  Teman: " .. nama
end
F.daftarSegar(segarStatus)
segarStatus(); gridRender(); filterWarna()
F.shJaga()
end
F.EVADE_SRC = [=====[
local API = (function(...)
if not game:IsLoaded() then game.Loaded:Wait() end
if _G.EVADE_UNLOCK_CLEAN then pcall(_G.EVADE_UNLOCK_CLEAN) end
local UNLOCK = {
Emote = true,
Unusual = true,
CarryAnimation = true,
Nametag = true,
Cosmetic = true,
Character = true,
}
pcall(function()
local c = _G.EVADE_UNLOCK_CONFIG
if type(c) == "table" then
for k, v in pairs(c) do
if UNLOCK[k] ~= nil then UNLOCK[k] = v and true or false end
end
end
end)
local USE_GAME_FLOW = true
local KEEP_EMOTE_ON_MOVE = true
local STOP_ON_KEY = true
local DEBUG_TAP = false
local DEBUG_WHEEL = true
local EMOTE_SLOTS = 6
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local on, dirty, alive = false, false, true
local restore, failed = {}, 0
local InvMod, PkgMod, Registry, EmoteUI, EmoteClass
pcall(function() InvMod = require(RS.Client.Services.UserData.Inventory) end)
pcall(function() PkgMod = require(RS.Shared.Marketplace.UserOwnsPackage) end)
pcall(function() Registry = require(RS.Items.Registry) end)
pcall(function() EmoteUI = require(RS.Services.UI.PopupService.Types.Emote) end)
pcall(function() EmoteClass = require(RS.Objects.Items.Emote) end)
local origGetEquipped = InvMod and InvMod.GetEquipped
local cv, lastT, lastV = nil, 0, false
local function scanCaller()
for lvl = 1, 8 do
local src = debug.info(lvl, "s")
if src == nil then break end
if type(src) == "string" and (src:find("Menu", 1, true) or src:find("SlotBuilder", 1, true)) then
return true
end
end
return false
end
local function menuOpen()
local now = os.clock()
if now - lastT < 0.2 then return lastV end
lastT = now
if not (cv and cv.Parent) then
cv = nil
local pg = player:FindFirstChildOfClass("PlayerGui")
if pg then
for _, d in ipairs(pg:GetDescendants()) do
if d.Name == "CharacterView" and d:IsA("Frame") then cv = d break end
end
end
end
local v
if cv then
local g = cv:FindFirstAncestorOfClass("ScreenGui")
v = cv.Visible and (g == nil or g.Enabled) and cv.AbsoluteSize.X > 0
else
local ok, r = pcall(scanCaller)
v = ok and r or false
end
lastV = v
return v
end
local unlockKey = {}
for k, v in pairs(UNLOCK) do
if v then unlockKey[k:lower()] = true end
end
local function slotBase(s)
s = tostring(s):lower()
s = s:gsub("_%d+$", "")
s = s:gsub("slot$", "")
return s
end
local function slotAllowed(s)
if s == nil then return false end
return unlockKey[slotBase(s)] == true
end
local function allChars(plr)
local list, seen = {}, {}
if not plr then return list end
local function add(m)
if m and m:IsA("Model") and m.Parent and not seen[m] and m:FindFirstChild("Head") then
seen[m] = true
table.insert(list, m)
end
end
local function addAll(folder)
if not folder then return end
for _, ch in ipairs(folder:GetChildren()) do
if ch.Name == plr.Name then add(ch) end
end
end
addAll(workspace:FindFirstChild("Rigs"))
addAll(workspace:FindFirstChild("Players"))
addAll(workspace:FindFirstChild("PlayerCache"))
local gm = workspace:FindFirstChild("Game")
addAll(gm and gm:FindFirstChild("Players"))
add(plr.Character)
add(workspace:FindFirstChild(plr.Name))
return list
end
local function rigOf(char)
if not char then return nil end
if not char:FindFirstChild("Head") then return nil end
if char:FindFirstChild("UpperTorso") then return "R15" end
return "R6"
end
local EFF = {
ParticleEmitter = true, Beam = true, Trail = true,
PointLight = true, SpotLight = true, SurfaceLight = true,
Fire = true, Smoke = true, Sparkles = true,
}
local function hasEffect(inst)
if EFF[inst.ClassName] then return true end
for _, d in ipairs(inst:GetDescendants()) do
if EFF[d.ClassName] then return true end
end
return false
end
local function isWeldLike(o)
return o:IsA("JointInstance") or o:IsA("WeldConstraint")
end
local function isExtra(ex)
if isWeldLike(ex) then return false end
return ex:IsA("BasePart") or ex:IsA("Accessory") or ex:IsA("Model") or hasEffect(ex)
end
local function firstPart(inst)
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("BasePart") then return d end
end
return nil
end
local function norm(s)
return (tostring(s):lower():gsub("[^%w]", ""))
end
local function childSig(inst)
local t = {}
for _, c in ipairs(inst:GetChildren()) do table.insert(t, c.Name) end
table.sort(t)
return table.concat(t, ",")
end
local function signature(mod)
local sig = {}
for _, mname in ipairs({"Character", "CharacterClassic"}) do
local model = mod:FindFirstChild(mname)
if model then
for _, tpart in ipairs(model:GetChildren()) do
if tpart:IsA("BasePart") then
for _, ex in ipairs(tpart:GetChildren()) do
if isExtra(ex) then
table.insert(sig, {
part = tpart.Name, cls = ex.ClassName,
name = ex.Name, cs = childSig(ex),
})
end
end
end
end
end
end
return sig
end
local function modHasEffect(mod)
for _, mname in ipairs({"Character", "CharacterClassic"}) do
local model = mod:FindFirstChild(mname)
if model and hasEffect(model) then return true end
end
return false
end
local idIndex, nameIndex, idxBuilt = {}, {}, false
local function buildModIndex()
if idxBuilt then return end
idxBuilt = true
local root = RS:FindFirstChild("Items")
if not root then return end
for _, o in ipairs(root:GetDescendants()) do
if o:IsA("ModuleScript") and (o:FindFirstChild("Character") or o:FindFirstChild("CharacterClassic")) then
local id = o:GetAttribute("ID")
if id ~= nil then
idIndex[id] = o
local n = tonumber(id)
if n then idIndex[n] = o end
end
local k = norm(o.Name)
if not nameIndex[k] then nameIndex[k] = o end
end
end
end
local function moduleForId(id)
buildModIndex()
if idIndex[id] then return idIndex[id] end
if not Registry then return nil end
local ok, cfg = pcall(Registry.GetConfig, id)
if ok and type(cfg) == "table" then
for _, f in ipairs({"Name", "DisplayName", "ItemName", "Title"}) do
local v = cfg[f]
if type(v) == "string" then
local m = nameIndex[norm(v)]
if m then return m end
end
end
end
return nil
end
local function uPlace(char, mod)
local rig = rigOf(char)
local model = mod:FindFirstChild(rig == "R15" and "Character" or "CharacterClassic")
or mod:FindFirstChild("Character")
or mod:FindFirstChild("CharacterClassic")
if not model then return {} end
local placed, map = {}, {}
local function regMap(orig, clone)
map[orig] = clone
local od, cd = orig:GetDescendants(), clone:GetDescendants()
for i = 1, #od do map[od[i]] = cd[i] end
end
for _, tpart in ipairs(model:GetChildren()) do
if tpart:IsA("BasePart") then
local cpart = char:FindFirstChild(tpart.Name)
if cpart and cpart:IsA("BasePart") then
map[tpart] = cpart
local extras, extraSet = {}, {}
for _, ex in ipairs(tpart:GetChildren()) do
if isExtra(ex) then
table.insert(extras, ex)
extraSet[ex] = true
end
end
local joined = {}
for _, ex in ipairs(tpart:GetChildren()) do
if isWeldLike(ex) and not ex:IsA("Motor6D") then
local p0, p1
pcall(function() p0, p1 = ex.Part0, ex.Part1 end)
if extraSet[p0] or extraSet[p1] then
table.insert(extras, ex)
if extraSet[p1] then joined[p1] = true end
if extraSet[p0] then joined[p0] = true end
end
end
end
for _, ex in ipairs(extras) do
local ok, clone = pcall(function() return ex:Clone() end)
if ok and clone then
regMap(ex, clone)
table.insert(placed, {orig = ex, clone = clone, cpart = cpart, tpart = tpart})
end
end
for _, ex in ipairs(extras) do
if ex:IsA("BasePart") then
for _, d in ipairs(ex:GetDescendants()) do
if isWeldLike(d) then joined[ex] = true break end
end
end
end
for _, rec in ipairs(placed) do
if rec.tpart == tpart and rec.orig:IsA("BasePart") and not joined[rec.orig] then
rec.needWeld = true
end
end
end
end
end
local function remap(root)
local all = root:GetDescendants()
table.insert(all, root)
for _, inst in ipairs(all) do
if inst:IsA("Beam") or inst:IsA("Trail") then
for _, p in ipairs({"Attachment0", "Attachment1"}) do
local v = inst[p]
if v and map[v] then inst[p] = map[v] end
end
elseif isWeldLike(inst) then
for _, p in ipairs({"Part0", "Part1"}) do
local v = inst[p]
if v and map[v] then inst[p] = map[v] end
end
end
end
end
local result = {}
for _, rec in ipairs(placed) do
local c = rec.clone
pcall(function()
remap(c)
local parts = c:GetDescendants()
table.insert(parts, c)
for _, d in ipairs(parts) do
if d:IsA("BasePart") then
d.Anchored = false
d.CanCollide = false
d.CanTouch = false
d.CanQuery = false
d.Massless = true
end
end
c:SetAttribute("DLXU", true)
c.Parent = rec.cpart
if rec.needWeld and c:IsA("BasePart") then
local w = Instance.new("Weld")
w.Name = "DLXU_Weld"
w.Part0 = rec.cpart
w.Part1 = c
w.C0 = rec.tpart.CFrame:Inverse() * rec.orig.CFrame
w.Parent = c
elseif c:IsA("Model") or c:IsA("Accessory") then
local hasJoint = false
for _, d in ipairs(c:GetDescendants()) do
if isWeldLike(d) then hasJoint = true break end
end
if not hasJoint then
local o = rec.orig
local oroot = (o:IsA("Model") and o.PrimaryPart)
or o:FindFirstChild("Handle") or firstPart(o)
local croot = oroot and map[oroot]
if croot and croot:IsA("BasePart") then
local w = Instance.new("Weld")
w.Name = "DLXU_Weld"
w.Part0 = rec.cpart
w.Part1 = croot
w.C0 = rec.tpart.CFrame:Inverse() * oroot.CFrame
w.Parent = croot
end
end
end
end)
table.insert(result, c)
end
return result
end
local allIds, allSet, bySlot, catOf = {}, {}, {}, {}
local itemOk, allowedList = {}, nil
local CAT_BY_BASE = {emote = "Emotes", cosmetic = "Cosmetics", unusual = "Cosmetics",
carryanimation = "CarryAnimations", nametag = "Nametags"}
local function buildSets()
if #allIds > 0 then return end
for id, e in pairs(Registry.GetAll()) do
allSet[id] = true
allIds[#allIds + 1] = id
catOf[id] = e.Categories
end
table.sort(allIds)
end
local function itemAllowed(id)
local c = itemOk[id]
if c ~= nil then return c end
local ok = false
if allSet[id] and Registry then
local s, cfg = pcall(Registry.GetConfig, id)
if s and type(cfg) == "table" and type(cfg.EquipInfo) == "table"
and cfg.EquipInfo.SlotType ~= nil then
ok = unlockKey[slotBase(cfg.EquipInfo.SlotType)] == true
end
end
itemOk[id] = ok
return ok
end
local function getAllowedIds()
if allowedList then return allowedList end
allowedList = {}
for _, id in ipairs(allIds) do
if itemAllowed(id) then allowedList[#allowedList + 1] = id end
end
return allowedList
end
local function matchSlot(id, slot)
local s, cfg = pcall(Registry.GetConfig, id)
if not (s and type(cfg) == "table" and type(cfg.EquipInfo) == "table") then return false end
local st = cfg.EquipInfo.SlotType
if st == nil then return false end
return st == slot or slotBase(st) == slotBase(slot)
end
local function slotList(slot)
local list = bySlot[slot]
if list then return list end
list = {}
local want = CAT_BY_BASE[slotBase(slot)]
for _, id in ipairs(allIds) do
local ok = true
if want then
ok = false
for _, c in ipairs(catOf[id] or {}) do
if c == want then ok = true break end
end
end
if ok and matchSlot(id, slot) then
list[#list + 1] = id
end
end
if #list == 0 and want then
for _, id in ipairs(allIds) do
if matchSlot(id, slot) then
list[#list + 1] = id
end
end
end
if #list == 0 and slotBase(slot) == "unusual" then
buildModIndex()
local seenId = {}
for id, mod in pairs(idIndex) do
if type(id) == "number" and allSet[id] and not seenId[id] then
local okS, has = pcall(modHasEffect, mod)
if okS and has then
seenId[id] = true
itemOk[id] = true
list[#list + 1] = id
end
end
end
table.sort(list)
end
print("[EvadeUnlock] slot '" .. tostring(slot) .. "': " .. #list .. " item")
bySlot[slot] = list
return list
end
local function patch(tbl, name, make)
if type(tbl) ~= "table" then failed += 1 return end
local orig = tbl[name]
if type(orig) ~= "function" then failed += 1 return end
local wrapper = make(orig)
pcall(function() if setreadonly then setreadonly(tbl, false) end end)
pcall(function() tbl[name] = wrapper end)
if tbl[name] ~= wrapper then failed += 1 return end
table.insert(restore, function()
pcall(function() if setreadonly then setreadonly(tbl, false) end end)
pcall(function() tbl[name] = orig end)
end)
end
local function patchOpt(tbl, name, make)
if type(tbl) ~= "table" or type(tbl[name]) ~= "function" then return end
patch(tbl, name, make)
end
local function isUnusualSlotName(k)
return tostring(k):lower():find("unusual", 1, true) ~= nil
end
local function isVis(k)
k = tostring(k)
local n = k:match("^EmoteSlot_(%d+)$")
if n and tonumber(n) > EMOTE_SLOTS then return false end
return slotAllowed(k)
end
local fake = {}
local function realEq(slot)
if not origGetEquipped then return 0 end
local ok, r = pcall(origGetEquipped, slot)
return (ok and type(r) == "number") and r or 0
end
local OV = {}
OV.Nametag = function()
return fake.NametagSlot
end
OV.CarryAnimation = function()
return fake.CarryAnimationSlot
end
local realTerm = {}
local function emoteMap()
local map = {}
local real = realTerm.Emotes
for _, p in ipairs(type(real) == "table" and real or {}) do
if type(p) == "table" and p[1] and p[1] <= EMOTE_SLOTS then map[p[1]] = p[2] end
end
if on then
for i = 1, EMOTE_SLOTS do
local v = fake["EmoteSlot_" .. i]
if v ~= nil then map[i] = (v ~= 0) and v or nil end
end
end
return map
end
OV.Emotes = function()
local any = false
for i = 1, EMOTE_SLOTS do
if fake["EmoteSlot_" .. i] ~= nil then any = true break end
end
if not any then return nil end
local map, out = emoteMap(), {}
for i = 1, EMOTE_SLOTS do
if map[i] then out[#out + 1] = {i, map[i]} end
end
return out
end
local DEFAULT = {Emotes = {}, Nametag = 0, CarryAnimation = 0}
local reg, regCls
local function regValid()
if not reg then return false end
local ok, v = pcall(function()
local p = reg.Parent
return p and p.Character and p.Character:IsDescendantOf(workspace)
end)
return ok and v == true
end
local function findReg()
if not getgc then return nil end
local found
pcall(function()
for _, t in ipairs(getgc(true)) do
if type(t) == "table" and rawget(t, "UpdatePeriod") ~= nil
and type(rawget(t, "Data")) == "table" and type(rawget(t, "ToSend")) == "table" then
local p = rawget(t, "Parent")
if type(p) == "table" then
local ok, l = pcall(function() return p.Local end)
if ok and l == true then found = t break end
end
end
end
end)
return found
end
local printedKeys = false
local CHAR_TERMS = {"Character", "CharacterSkin", "Skin", "CharacterId"}
local function attach(r)
local mt = getmetatable(r)
local cls = mt and mt.__index
if type(cls) ~= "table" or type(cls.SetTerm) ~= "function" then return false end
reg, regCls = r, cls
pcall(function()
local data = r.Data
if not printedKeys then
printedKeys = true
local ks = {}
for k in pairs(data) do ks[#ks + 1] = tostring(k) end
table.sort(ks)
print("[EvadeUnlock] Data keys: " .. table.concat(ks, ", "))
end
if unlockKey.character then
local found = false
for _, name in ipairs(CHAR_TERMS) do
if OV[name] == nil and type(data[name]) == "number" then
OV[name] = function() return fake.CharacterSlot end
DEFAULT[name] = 0
found = true
print("[EvadeUnlock] Character term: " .. name)
break
elseif OV[name] ~= nil then
found = true
break
end
end
if not found then
print("[EvadeUnlock] Character term tidak ketemu di Data keys")
end
end
end)
for term in pairs(OV) do realTerm[term] = r.Data[term] end
rawset(r, "SetTerm", function(self, term, val)
local f = OV[term]
if f then
realTerm[term] = val
if on then
local o = f(val)
if o ~= nil then val = o end
end
end
return cls.SetTerm(self, term, val)
end)
return true
end
local emoteInst, lastGc = nil, 0
local function findEmoteUI()
if emoteInst then
local ok, alive_ = pcall(function() return emoteInst.Frame and emoteInst.Frame.Parent end)
if ok and alive_ then return emoteInst end
emoteInst = nil
end
if not (getgc and EmoteUI) then return nil end
if os.clock() - lastGc < 3 then return nil end
lastGc = os.clock()
pcall(function()
for _, t in ipairs(getgc(true)) do
if type(t) == "table" and getmetatable(t) == EmoteUI and rawget(t, "Frame") ~= nil then
emoteInst = t
break
end
end
end)
return emoteInst
end
local ICON_HINT = {"icon", "image", "thumb", "preview", "render", "sprite", "picture"}
local function normImage(v)
if type(v) == "number" and v > 0 then return "rbxassetid://" .. tostring(math.floor(v)) end
if type(v) == "string" and v ~= "" then
if v:match("^%d+$") then return "rbxassetid://" .. v end
if v:find("rbxasset", 1, true) or v:find("http", 1, true) then return v end
end
return nil
end
local function findIcon(t, depth)
for k, v in pairs(t) do
if type(k) == "string" then
local lk = k:lower()
for _, h in ipairs(ICON_HINT) do
if lk:find(h, 1, true) then
local img = normImage(v)
if img then return img end
break
end
end
end
end
if depth < 2 then
for _, v in pairs(t) do
if type(v) == "table" then
local r = findIcon(v, depth + 1)
if r then return r end
end
end
end
return nil
end
local iconCache, nameCache, iconWarned = {}, {}, {}
local emoteModById, emoteModBuilt = {}, false
local function emoteModuleFor(id)
if not emoteModBuilt then
emoteModBuilt = true
local root = RS:FindFirstChild("Items")
if root then
for _, o in ipairs(root:GetDescendants()) do
if o.Parent and o.Parent.Name == "Emotes" then
local oid = o:GetAttribute("ID")
if oid ~= nil then
emoteModById[oid] = o
local n = tonumber(oid)
if n then emoteModById[n] = o end
end
end
end
end
end
return emoteModById[id]
end
local function iconFromInstance(inst)
local t = {}
for k, v in pairs(inst:GetAttributes()) do t[k] = v end
local img = findIcon(t, 0)
if img then return img end
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("ImageLabel") or d:IsA("ImageButton") then
local im = normImage(d.Image)
if im then return im end
elseif d:IsA("Decal") or d:IsA("Texture") then
local im = normImage(d.Texture)
if im then return im end
elseif d:IsA("StringValue") or d:IsA("IntValue") or d:IsA("NumberValue") then
local ln = d.Name:lower()
for _, h in ipairs(ICON_HINT) do
if ln:find(h, 1, true) then
local im = normImage(d.Value)
if im then return im end
break
end
end
end
end
return nil
end
local function cfgOf(id)
if not Registry then return nil end
local ok, cfg = pcall(Registry.GetConfig, id)
if ok and type(cfg) == "table" then return cfg end
return nil
end
local function iconOf(id)
local c = iconCache[id]
if c ~= nil then return c or nil end
local cfg = cfgOf(id)
local img = cfg and findIcon(cfg, 0) or nil
if not img then
local m = emoteModuleFor(id)
if m then
local okI, r = pcall(iconFromInstance, m)
if okI then img = r end
end
end
if not img and cfg and not iconWarned[id] then
iconWarned[id] = true
local ks = {}
for k in pairs(cfg) do ks[#ks + 1] = tostring(k) end
table.sort(ks)
print("[EvadeUnlock] ikon tidak ketemu untuk ID " .. tostring(id) .. ", key config: " .. table.concat(ks, ", "))
end
iconCache[id] = img or false
return img
end
local function nameOf(id)
local c = nameCache[id]
if c ~= nil then return c or nil end
local cfg = cfgOf(id)
local nm
if cfg then
for _, f in ipairs({"Name", "DisplayName", "ItemName", "Title"}) do
if type(cfg[f]) == "string" then nm = cfg[f] break end
end
end
nameCache[id] = nm or false
return nm
end
local wheelDumped, wheelIconWarned = false, false
local function dumpWheel(frame)
if wheelDumped or not DEBUG_WHEEL then return end
wheelDumped = true
local n = 0
print("[EvadeUnlock] === struktur roda emote ===")
for _, d in ipairs(frame:GetDescendants()) do
n += 1
if n > 160 then print("[EvadeUnlock] ...dipotong") break end
local extra = ""
if d:IsA("TextLabel") or d:IsA("TextButton") then extra = " text='" .. d.Text .. "'" end
if d:IsA("ImageLabel") or d:IsA("ImageButton") then extra = " image='" .. tostring(d.Image) .. "'" end
print("[EvadeUnlock] " .. d:GetFullName():gsub("^.-%.PlayerGui%.", "") .. " [" .. d.ClassName .. "]" .. extra)
end
end
local MAX_ICON_AREA = 260 * 260
local function pickImage(container, skip, capArea)
local best, bestArea = nil, -1
for _, d in ipairs(container:GetDescendants()) do
if d ~= skip and (d:IsA("ImageLabel") or d:IsA("ImageButton")) then
local ln = d.Name:lower()
local area = d.AbsoluteSize.X * d.AbsoluteSize.Y
if area > 0 and (not capArea or area <= MAX_ICON_AREA) then
local score = area
if ln:find("icon", 1, true) or ln:find("image", 1, true) or ln:find("thumb", 1, true)
or ln:find("emote", 1, true) or ln:find("render", 1, true) then
score += 1e6
end
if score > bestArea then best, bestArea = d, score end
end
end
end
return best
end
local function setIcon(img, ic)
if img.Image == ic then return end
img.ImageRectOffset = Vector2.new(0, 0)
img.ImageRectSize = Vector2.new(0, 0)
img.Image = ic
img.ImageTransparency = 0
img.ImageColor3 = Color3.new(1, 1, 1)
end
local function fixWheelIcons(ui)
local frame = ui and ui.Frame
if not (frame and frame.Parent) then return end
local wants = {}
for i = 1, EMOTE_SLOTS do
local id = fake["EmoteSlot_" .. i]
if on and type(id) == "number" and id ~= 0 then
local nm, ic = nameOf(id), iconOf(id)
if nm and ic then wants[norm(nm)] = ic end
end
end
if next(wants) == nil then return end
dumpWheel(frame)
local hitAny = false
for _, d in ipairs(frame:GetDescendants()) do
if d:IsA("TextLabel") or d:IsA("TextButton") then
local ic = wants[norm(d.Text)]
if ic then
local cur, img = d.Parent, nil
for _ = 1, 4 do
if not cur or cur == frame then break end
img = pickImage(cur, d, true) or pickImage(cur, d, false)
if img then break end
cur = cur.Parent
end
if img then
hitAny = true
setIcon(img, ic)
end
end
end
end
if not hitAny and not wheelIconWarned then
wheelIconWarned = true
print("[EvadeUnlock] tidak ada label nama di roda yang cocok dengan emote fake "
.. "(nama di config != nama di roda). Cek print 'struktur roda emote' di atas.")
end
end
local function syncWheel()
local ui = findEmoteUI()
if ui then
pcall(function() ui:SetEquipped(emoteMap()) end)
pcall(fixWheelIcons, ui)
task.delay(0.3, function() if alive then pcall(fixWheelIcons, ui) end end)
task.delay(1.2, function() if alive then pcall(fixWheelIcons, ui) end end)
end
end
local function applyAll()
if regValid() then
for term in pairs(OV) do
local real = realTerm[term]
if real == nil then real = DEFAULT[term] end
if real ~= nil then
pcall(function() reg:SetTerm(term, real) end)
end
end
end
syncWheel()
end
local PL_SLOTS = {"UnusualSlot", "CosmeticSlot_1", "CosmeticSlot_2"}
local ST = {}
for _, s in ipairs(PL_SLOTS) do
ST[s] = {
target = nil, mod = nil, rec = {},
sigByName = {}, sigFor = nil,
silenced = setmetatable({}, {__mode = "k"}),
}
end
local uWarned = {}
local uLast = 0
local function destroyList(list)
for _, o in ipairs(list) do pcall(function() o:Destroy() end) end
end
local function silenceTree(root, store)
local list = root:GetDescendants()
table.insert(list, root)
for _, o in ipairs(list) do
pcall(function()
if o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail")
or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") or o:IsA("Light") then
if o.Enabled then
if store[o] == nil then store[o] = {prop = "Enabled", val = true} end
o.Enabled = false
if o:IsA("ParticleEmitter") then o:Clear() end
end
elseif o:IsA("BasePart") then
if o.Transparency < 1 then
if store[o] == nil then store[o] = {prop = "Transparency", val = o.Transparency} end
o.Transparency = 1
end
end
end)
end
end
local function restoreSilenced(store)
local items = {}
for o, rec in pairs(store) do table.insert(items, {o, rec}) end
for _, it in ipairs(items) do
pcall(function() it[1][it[2].prop] = it[2].val end)
store[it[1]] = nil
end
end
local function clearRec(st)
for _, rec in pairs(st.rec) do destroyList(rec.list) end
st.rec = {}
end
local function slotStop(st)
clearRec(st)
restoreSilenced(st.silenced)
st.sigByName, st.sigFor = {}, nil
st.target, st.mod = nil, nil
end
local function recValid(rec, now)
if not rec then return false end
if #rec.list == 0 then return (now - rec.t) < 1.5 end
for _, o in ipairs(rec.list) do
if not o.Parent then return false end
end
return true
end
local function slotTick(s, st, now)
if not (on and slotAllowed(s) and fake[s] ~= nil) then
if st.target ~= nil or next(st.rec) or st.sigFor ~= nil or next(st.silenced) then
slotStop(st)
end
return
end
local id = fake[s]
local realId = realEq(s)
local target = (type(id) == "number" and id ~= 0) and id or nil
if target ~= st.target then
clearRec(st)
st.target = target
st.mod = target and moduleForId(target) or nil
if target then
if st.mod then
print("[EvadeUnlock] " .. s .. " -> " .. st.mod.Name)
elseif not uWarned[target] then
uWarned[target] = true
warn("[EvadeUnlock] " .. s .. ": modul tidak ketemu untuk ID " .. tostring(target))
end
end
end
local chars = allChars(player)
local needSilence = realId ~= 0 and realId ~= target
if needSilence then
if st.sigFor ~= realId then
restoreSilenced(st.silenced)
st.sigByName, st.sigFor = {}, realId
local rm = moduleForId(realId)
if rm then
for _, sg in ipairs(signature(rm)) do
local l = st.sigByName[sg.name]
if not l then l = {} st.sigByName[sg.name] = l end
table.insert(l, sg)
end
end
end
for _, c in ipairs(chars) do
for _, d in ipairs(c:GetDescendants()) do
local lst = st.sigByName[d.Name]
if lst and d:GetAttribute("DLXU") ~= true then
local par = d.Parent
for _, sg in ipairs(lst) do
if par and par.Name == sg.part and d.ClassName == sg.cls
and childSig(d) == sg.cs then
silenceTree(d, st.silenced)
break
end
end
end
end
end
elseif st.sigFor ~= nil then
restoreSilenced(st.silenced)
st.sigByName, st.sigFor = {}, nil
end
if st.mod and target ~= realId then
for ch, rec in pairs(st.rec) do
if not ch.Parent then
destroyList(rec.list)
st.rec[ch] = nil
end
end
for _, char in ipairs(chars) do
local rec = st.rec[char]
if not recValid(rec, now) then
if rec then destroyList(rec.list) end
local ok, res = pcall(uPlace, char, st.mod)
st.rec[char] = {list = (ok and res) or {}, t = now}
end
end
elseif next(st.rec) then
clearRec(st)
end
end
local function placeTick()
local now = tick()
if now - uLast < 0.5 then return end
uLast = now
for _, s in ipairs(PL_SLOTS) do
pcall(slotTick, s, ST[s], now)
end
end
local function placeStopAll()
for _, s in ipairs(PL_SLOTS) do pcall(slotStop, ST[s]) end
end
local uConn = RunService.Heartbeat:Connect(function()
pcall(placeTick)
end)
local pendingFake, pendingT = nil, 0
local gameFlowActive, gameBase = false, nil
local activeEmote, flowT = nil, 0
local localPlaying = false
local curEmote = 0
local lastKeyAct = 0
local function charDataEvent()
local rem = RS:FindFirstChild("Remotes")
local rg = rem and rem:FindFirstChild("Registry")
local ev = rg and rg:FindFirstChild("UpdateCharacterDataRegistry")
if not ev then
local old = RS:FindFirstChild("Events")
ev = old and old:FindFirstChild("UpdateCharacterDataRegistry")
end
return ev
end
local function sendEmote(id)
local ch = player.Character
local tag = ch and ch:GetAttribute("Tag")
if tag and typeof(firesignal) == "function" and typeof(buffer) == "table" then
local ok = pcall(function()
local tb = buffer.create(2)
buffer.writeu16(tb, 0, tag)
firesignal(charDataEvent().OnClientEvent,
{buffer.fromstring("\24\1"), id, tb})
end)
if ok then return true end
end
if regValid() then
return (pcall(function() reg:SetTerm("Emote", id) end))
end
return false
end
local function stopLocal()
if not localPlaying then return end
localPlaying = false
curEmote = 0
sendEmote(0)
end
local function stopAny()
local did = false
if localPlaying then
stopLocal()
did = true
end
if gameFlowActive then
local e = activeEmote
pendingFake, gameFlowActive, activeEmote = nil, false, nil
if e then pcall(function() e:Deactivate() end) end
sendEmote(0)
did = true
end
return did
end
local function isMoving()
local moving = false
pcall(function()
local d = reg and reg.Data and reg.Data.RelativeMoveDirection
if typeof(d) == "Vector3" and d.Magnitude > 0.1 then moving = true end
end)
if not moving then
pcall(function()
local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if h and h.MoveDirection.Magnitude > 0.1 then moving = true end
end)
end
return moving
end
local function pickBase()
local real = realTerm.Emotes
if type(real) ~= "table" then return nil end
for _, p in ipairs(real) do
if type(p) == "table" and p[1] and p[2] and p[2] ~= 0
and fake["EmoteSlot_" .. tostring(p[1])] == nil then
return p[1]
end
end
return nil
end
local installed = false
local function install()
if installed then return end
installed = true
failed = 0
buildSets()
patch(InvMod, "Owns", function(orig) return function(id, ...)
if on and menuOpen() and itemAllowed(id) then return true end
return orig(id, ...)
end end)
patch(InvMod, "OwnedIds", function(orig) return function(...)
local r = orig(...)
if on and menuOpen() then
local out, seen = {}, {}
if type(r) == "table" then
for _, id in ipairs(r) do
if not seen[id] then seen[id] = true out[#out + 1] = id end
end
end
for _, id in ipairs(getAllowedIds()) do
if not seen[id] then seen[id] = true out[#out + 1] = id end
end
return out
end
return r
end end)
patch(InvMod, "GetOwnedBySlotType", function(orig) return function(slot, ...)
if on and menuOpen() and slotAllowed(slot) then
local l = slotList(slot)
if #l > 0 then return l end
end
return orig(slot, ...)
end end)
patch(InvMod, "IsSlotAvailable", function(orig) return function(a, b, ...)
if on and menuOpen() and (slotAllowed(a) or slotAllowed(b)) then return true end
return orig(a, b, ...)
end end)
patch(InvMod, "Equip", function(orig) return function(slot, id, ...)
if on and menuOpen() and isVis(slot)
and (id == nil or id == 0 or itemAllowed(id)) then
fake[slot] = id or 0
if isUnusualSlotName(slot) then fake.UnusualSlot = id or 0 end
dirty = true
return
end
return orig(slot, id, ...)
end end)
patch(InvMod, "GetEquipped", function(orig) return function(slot, ...)
if on and fake[slot] ~= nil and menuOpen() then return fake[slot] end
return orig(slot, ...)
end end)
patch(InvMod, "GetLoadout", function(orig) return function(...)
local r = orig(...)
if on and next(fake) and menuOpen() then
local c = {}
for k, v in pairs(r or {}) do c[k] = v end
for slot, id in pairs(fake) do c[slot] = (id ~= 0) and id or nil end
return c
end
return r
end end)
patch(InvMod, "IsEquipped", function(orig) return function(id, ...)
if on and next(fake) and menuOpen() then
for slot, v in pairs(fake) do
if v == id then return true, slot end
end
end
return orig(id, ...)
end end)
for _, n in ipairs({"Owns", "Peek", "OwnsViaProduct", "OwnsViaPackage"}) do
patch(PkgMod, n, function(orig) return function(a, ...)
if on and menuOpen() and type(a) == "number" and itemAllowed(a) then return true end
return orig(a, ...)
end end)
end
patchOpt(EmoteClass, "Activate", function(orig) return function(self, ...)
local r = orig(self, ...)
pcall(function()
if not pendingFake then return end
if os.clock() - pendingT > 1.5 then pendingFake = nil return end
if self.Character ~= player.Character then return end
local animations = self.Animations
local anim = animations and animations.Animation
if not anim or not anim.IsPlaying or anim.Speed <= 0 then return end
local fid = pendingFake
pendingFake = nil
gameFlowActive = true
activeEmote, flowT = self, os.clock()
sendEmote(fid)
end)
return r
end end)
patchOpt(EmoteClass, "Deactivate", function(orig) return function(self, ...)
local r = orig(self, ...)
pcall(function()
if self.Character == player.Character then
local wasActive = gameFlowActive
if self == activeEmote then activeEmote = nil end
if wasActive and KEEP_EMOTE_ON_MOVE and isMoving() then
else
gameFlowActive = false
if wasActive and os.clock() - flowT > 0.5 then sendEmote(0) end
end
end
end)
return r
end end)
patch(EmoteUI, "KeyActivated", function(orig) return function(self, slot)
lastKeyAct = os.clock()
local id = on and fake["EmoteSlot_" .. tostring(slot)]
if not (id and id ~= 0) then return orig(self, slot) end
if localPlaying then stopLocal() return end
if USE_GAME_FLOW and EmoteClass then
if gameFlowActive and gameBase then
pendingFake = nil
if activeEmote == nil then
stopAny()
return
end
local r = orig(self, gameBase)
task.delay(0.35, function()
if alive and gameFlowActive then pcall(stopAny) end
end)
return r
end
local base = pickBase()
if base then
gameBase = base
pendingFake, pendingT = id, os.clock()
return orig(self, base)
end
end
task.spawn(function()
local cur = 0
pcall(function() cur = reg and reg.Data and reg.Data.Emote or 0 end)
if cur ~= 0 then sendEmote(0) task.wait(0.1) end
local ok, can = pcall(function() return self:CanActivate(true) end)
if ok and can then
localPlaying = sendEmote(id) and true or false
if localPlaying then curEmote = id flowT = os.clock() end
pcall(function()
self.LastActivated = tick()
self.DisableFlag:Fire("Emote")
end)
else
pcall(function() self.DisableFlag:Fire("Emote") end)
end
end)
end end)
for _, n in ipairs({"Cancel", "CancelEmote", "StopEmote", "Stop", "Deactivate"}) do
patchOpt(EmoteUI, n, function(orig) return function(...)
if on and localPlaying then stopLocal() end
return orig(...)
end end)
end
end
local pressT, pressHit = 0, false
local function isPress(i)
return i.UserInputType == Enum.UserInputType.Touch
or i.UserInputType == Enum.UserInputType.MouseButton1
end
local function tapOnEmoteGui(pos)
local pg = player:FindFirstChildOfClass("PlayerGui")
if not pg then return false end
local inset = Vector2.new(0, 0)
pcall(function() inset = GuiService:GetGuiInset() end)
local found, names = false, {}
local tries = {Vector2.new(pos.X, pos.Y), Vector2.new(pos.X - inset.X, pos.Y - inset.Y)}
for _, p in ipairs(tries) do
local ok, objs = pcall(function() return pg:GetGuiObjectsAtPosition(p.X, p.Y) end)
if ok and objs then
for _, o in ipairs(objs) do
local cur = o
while cur and cur ~= pg do
names[#names + 1] = cur.Name
if string.find(string.lower(cur.Name), "emote", 1, true) then found = true end
cur = cur.Parent
end
end
end
if found then break end
end
if DEBUG_TAP then
print("[EvadeUnlock] tap: " .. table.concat(names, " < "))
end
return found
end
local c1 = UIS.InputBegan:Connect(function(i)
if not (on and localPlaying and isPress(i)) then return end
pressT = os.clock()
pressHit = tapOnEmoteGui(i.Position)
end)
local c2 = UIS.InputEnded:Connect(function(i)
if not (pressHit and isPress(i)) then return end
pressHit = false
local t0 = pressT
task.delay(0.25, function()
if localPlaying and lastKeyAct < t0 then stopLocal() end
end)
end)
local MOVE_KEYS = {
[Enum.KeyCode.Space] = true,
}
local c3 = UIS.InputBegan:Connect(function(i, processed)
if not (STOP_ON_KEY and on and (localPlaying or gameFlowActive)) then return end
if processed or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
if not MOVE_KEYS[i.KeyCode] then return end
if os.clock() - flowT < 0.4 then return end
pcall(stopAny)
end)
task.spawn(function()
local lastScan, backoff = 0, 2
while alive do
task.wait(localPlaying and 0.15 or 1)
if localPlaying then
local ch = player.Character
if not ch or not ch.Parent then
stopLocal()
elseif not KEEP_EMOTE_ON_MOVE and isMoving() then
stopLocal()
end
end
if installed then
if (on or dirty) and (next(fake) or dirty) then
if not regValid() then
if os.clock() - lastScan >= backoff then
lastScan = os.clock()
local r = findReg()
if r and attach(r) then backoff = 2 dirty = true else backoff = 5 end
end
end
if dirty then
dirty = false
applyAll()
end
end
if on and next(fake) and emoteInst then
pcall(fixWheelIcons, emoteInst)
end
end
end
end)
local charConn = player.CharacterRemoving:Connect(function()
localPlaying, curEmote = false, 0
pendingFake, gameFlowActive, activeEmote = nil, false, nil
end)
local API = {}
local function setOn(v)
v = v and true or false
if not (InvMod and Registry and PkgMod) then
return false, "Bukan di Evade / modul tidak ketemu"
end
if v == on then return true end
on = v
if on then
install()
else
pcall(stopAny)
pendingFake, gameFlowActive, activeEmote = nil, false, nil
end
dirty = true
return true
end
function API.Enable() return setOn(true) end
function API.Disable() return setOn(false) end
function API.Toggle() return setOn(not on) end
function API.IsOn() return on end
function API.IsBusy()
if localPlaying or gameFlowActive then return true end
return pendingFake ~= nil and (os.clock() - pendingT) <= 1.5
end
function API.Failed() return failed end
local function clean()
alive = false
on = false
localPlaying = false
pendingFake, gameFlowActive = nil, false
pcall(function() uConn:Disconnect() end)
pcall(placeStopAll)
pcall(applyAll)
pcall(function() if reg then rawset(reg, "SetTerm", nil) end end)
for _, r in ipairs(restore) do r() end
table.clear(restore)
pcall(function() c1:Disconnect() end)
pcall(function() c2:Disconnect() end)
pcall(function() c3:Disconnect() end)
pcall(function() charConn:Disconnect() end)
_G.EVADE_UNLOCK = nil
_G.EVADE_UNLOCK_CLEAN = nil
end
API.Clean = clean
_G.EVADE_UNLOCK = API
_G.EVADE_UNLOCK_CLEAN = clean
if _G.EVADE_UNLOCK_AUTOSTART ~= false then
local ok, msg = API.Enable()
if not ok then warn("[EvadeUnlock] " .. tostring(msg)) end
end
return API
end)(...)
]=====]
function F.evadeAPI()
if S.evadeAPI then return true, S.evadeAPI end
_G.EVADE_UNLOCK_AUTOSTART = false
_G.EVADE_UNLOCK_CONFIG = {Emote = true, Unusual = false, CarryAnimation = false, Nametag = false, Cosmetic = false, Character = false}
local fn, err = loadstring(F.EVADE_SRC .. "\nreturn API")
if not fn then return false, "gagal memuat: " .. tostring(err) end
local ok, api = pcall(fn)
_G.EVADE_UNLOCK_AUTOSTART = nil
_G.EVADE_UNLOCK_CONFIG = nil
if not ok or type(api) ~= "table" then return false, "gagal jalan: " .. tostring(api) end
S.evadeAPI = api
return true, api
end
function F.pgEvade(page)
local n = 0
local function nx() n = n + 1; return n end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Evade Emote", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local ket = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = ROW, Text = "Khusus Evade. Nyalakan, lalu buka menu emote di inventory: semua emote bisa dipilih, dipasang di slot, dan dipakai. Hanya visual di layarmu, tidak ada yang benar-benar terbuka di akunmu.", TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(ket)
F.togelDesk(page, nx, "Unlock semua emote", "Visual saja, hanya bekerja di Evade", function() return S.evadeOn == true end, function(v)
if v then
local ok, api = F.evadeAPI()
if not ok then
S.evadeOn = false
F.catat("evade: " .. tostring(api))
F.notif("Evade Emote", tostring(api), 4)
return
end
local ok2, msg = api.Enable()
if ok2 == false then
S.evadeOn = false
F.catat("evade: " .. tostring(msg))
F.notif("Evade Emote", tostring(msg), 4)
return
end
S.evadeOn = true
F.catat("evade: unlock semua emote ON")
F.notif("Evade Emote", "ON. Buka menu emote di inventory", 3)
else
S.evadeOn = false
if S.evadeAPI then pcall(S.evadeAPI.Disable) end
F.catat("evade: unlock semua emote OFF")
end
end)
local status = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
F.daftarSegar(function()
if S.evadeOn and S.evadeAPI then
local gagal = 0
pcall(function() gagal = S.evadeAPI.Failed() end)
status.Text = "ON" .. (gagal > 0 and (" (" .. gagal .. " patch gagal)") or "")
else
status.Text = "OFF"
end
end)
end
local function pgFaker(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end
local function toggle(nama, get, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); mk("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b); local sw = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF}, b); rnd(sw, 10); local kn = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, sw); rnd(kn, 7); local function p() local s = get(); TS:Create(sw, SPRING, {BackgroundColor3 = s and OR or OFF}):Play(); TS:Create(kn, SPRING, {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() end; p(); S.ui.segar = S.ui.segar or {}; table.insert(S.ui.segar, p); b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() fn(not (get() and true or false)); p() end) end) end
sec("Fake verified")
toggle("Fake verified (lokal)", function() return S.centang == true end, function(v) F.centangSet(v) end)
sec("Custom name (lokal)")
box(MUT).Text = "Ganti nama yang tampil di layar kamu: leaderboard dan nametag karakter. Cuma kelihatan di layar kamu, nama asli di server tidak berubah. Maks 24 huruf."
local boxNama = mk("TextBox", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", PlaceholderText = "nama baru", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, ClearTextOnFocus = false, LayoutOrder = nx()}, page)
rnd(boxNama)
local tombolNama = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "TERAPKAN NAMA", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tombolNama)
tombolNama.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.namaSet(boxNama.Text) end) end)
local tombolNamaBalik = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "KEMBALI KE NAMA ASLI", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tombolNamaBalik)
tombolNamaBalik.MouseButton1Click:Connect(function() task.spawn(F.aman, function() boxNama.Text = ""; F.namaSet(nil) end) end)
sec("Clone avatar (username)")
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = ROW, Text = "kemungkinan ada bug di sae", TextColor3 = OR, Font = FM, TextSize = 11, LayoutOrder = nx()}, page)
local boxCloneUser = mk("TextBox", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", PlaceholderText = "username, misal Roblox", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, ClearTextOnFocus = false, LayoutOrder = nx()}, page)
rnd(boxCloneUser)
local tombolClone = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "CLONE AVATAR", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tombolClone)
tombolClone.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
local u = trim(boxCloneUser.Text)
if u == "" then F.catat("clone: isi username dulu"); return end
F.catat("clone: ambil avatar " .. u .. "...")
local ok, hasil = F.cloneTerapkan(u)
if ok then F.catat("clone " .. u .. " berhasil: " .. tostring(hasil))
else F.catat("clone: " .. tostring(hasil)) end
end)
end)
local tombolCloneBalik = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "KEMBALIKAN AVATAR SENDIRI", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(tombolCloneBalik)
tombolCloneBalik.MouseButton1Click:Connect(function()
task.spawn(F.aman, function() F.cloneKembalikan(); F.catat("clone: avatar sendiri dikembalikan") end)
end)
local function sliderF(nama, lo, hi, get, set, fmt, satuan)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local lbl = mk("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local track = mk("Frame", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = OFF, BorderSizePixel = 0}, r); rnd(track, 3)
local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = OR, BorderSizePixel = 0}, track); rnd(fill, 3)
local knob = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = BG, BorderSizePixel = 0, ZIndex = 3}, track); rnd(knob, 7)
local hit = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 4}, r)
local function segar()
local v = get(); local f = math.clamp((v - lo) / (hi - lo), 0, 1)
fill.Size = UDim2.new(f, 0, 1, 0); knob.Position = UDim2.new(f, 0, 0.5, 0)
lbl.Text = nama .. ": " .. string.format(fmt, v) .. satuan
end
local tarik = false
local function dariLayar(x)
local f = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
set(lo + f * (hi - lo)); segar()
end
hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = true; dariLayar(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = false end end)
UIS.InputChanged:Connect(function(i) if tarik and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then dariLayar(i.Position.X) end end)
F.daftarSegar(segar); segar()
end
sec("Ukuran & posisi centang")
sliderF("Ukuran centang", 40, 90, function() return math.floor(((S.centangUk or 0.62) * 100) + 0.5) end, function(v) S.centangUk = math.floor(v + 0.5) / 100 end, "%.0f", "%")
sliderF("Geser atas/bawah", -8, 8, function() return S.centangGeser or 0 end, function(v) S.centangGeser = math.floor(v + 0.5) end, "%.0f", " px")
sliderF("Geser kiri/kanan", -20, 40, function() return S.centangGeserX or 0 end, function(v) S.centangGeserX = math.floor(v + 0.5) end, "%.0f", " px")
box(MUT).Text = "Ukuran dan posisi cuma berlaku saat centang biru ON. Cuma tampil di layar kamu, leaderboard game dan pemain lain tidak berubah."
sec("Tiru outfit kita ke pemain (lokal)")
box(MUT).Text = "Pilih pemain di daftar, outfit kamu dipasang di karakter dia, cuma kelihatan di layar kamu. Centang Save supaya outfit tetap ada di dia walau kamu STOP atau ganti pemain. Cuma R15. KEMBALIKAN SEMUA mengembalikan semua pemain, dan RESET ALL juga ikut."
local daftar = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, daftar)
local rowSave = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(rowSave)
local lblSave = mk("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, rowSave)
local swSave = mk("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = OFF}, rowSave); rnd(swSave, 10)
local knSave = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = BG}, swSave); rnd(knSave, 7)
local function segarSave()
local nama = S.tiru.target
local tersimpan = nama and S.tiru.snap[nama] ~= nil
lblSave.Text = "Save outfit ke " .. (nama or "(pilih pemain dulu)")
swSave.BackgroundColor3 = tersimpan and OR or OFF
knSave.Position = tersimpan and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
end
local function segarDaftar()
for _, c in ipairs(daftar:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= me then
local tag = ""
if S.tiru.snap[p.Name] then tag = "  [tersimpan]"
elseif S.tiru.target == p.Name and S.tiru.on then tag = "  [aktif]" end
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = ROW, Text = p.Name .. tag, TextColor3 = TXT, Font = FM, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, daftar)
rnd(b)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.tiruPilih(p.Name); segarDaftar(); segarSave() end) end)
end
end
end
rowSave.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.tiruSimpanToggle(); segarSave(); segarDaftar() end) end)
local function tombol(teks, fn)
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = ROW, Text = teks, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(b)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end)
end
tombol("REFRESH DAFTAR PEMAIN", function() segarDaftar(); segarSave() end)
tombol("STOP (outfit yang di-Save tetap)", function() F.tiruStop(false); segarDaftar(); segarSave() end)
tombol("KEMBALIKAN SEMUA", function() F.tiruStop(true); segarDaftar(); segarSave() end)
segarDaftar(); segarSave()
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Source code clone user by : agoy", TextColor3 = MUT, Font = FM, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = nx()}, page)
end
local function pgLarp(page)
local B = {page = page}; local n = 0; local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
local function slider(nama, lo, hi, get, set, satuan)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
local lbl = mk("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local track = mk("Frame", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = OFF, BorderSizePixel = 0}, r); rnd(track, 3)
local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = OR, BorderSizePixel = 0}, track); rnd(fill, 3)
local knob = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = BG, BorderSizePixel = 0, ZIndex = 3}, track); rnd(knob, 7)
local hit = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 4}, r)
local function segar()
local v = get(); local f = math.clamp((v - lo) / (hi - lo), 0, 1)
fill.Size = UDim2.new(f, 0, 1, 0); knob.Position = UDim2.new(f, 0, 0.5, 0)
lbl.Text = nama .. ": " .. string.format("%.1f", v) .. (satuan or " detik")
end
local tarik = false
local function dariLayar(x)
local f = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
set(lo + f * (hi - lo)); segar()
end
hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = true; dariLayar(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tarik = false end end)
UIS.InputChanged:Connect(function(i) if tarik and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then dariLayar(i.Position.X) end end)
F.daftarSegar(segar); segar()
end
sec("Kecepatan pergantian"); slider("Jeda antar item", 0.1, 3, function() return S.gantiJeda end, function(v) F.gantiSet(v) end)
sec("Preset larp")
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = ROW, Text = "kemungkinan ada bug di sae", TextColor3 = OR, Font = FM, TextSize = 11, LayoutOrder = nx()}, page)
for _, lp in ipairs(C.LARP) do
if lp.tampil then btn(lp.nama, true, function() F.larpPasang(lp) end) end
end
end
function F.pakKunci(it) return it.jenis .. ":" .. tostring(it.id) end
function F.animFavAda(it)
local v = S.animFav and S.animFav[F.pakKunci(it)]
if v == nil then return it.fav == true end
return v == true
end
function F.pakAktif(it)
if it.jenis == "pack" then
local w = S.anim.want
if not w then return false end
if it.zombie then return w.kind == "zombie" end
return w.bundle == it.id
end
return S.emote.id == it.id
end
function F.pakGambar(it)
local tipe = it.thumb or ((it.jenis == "pack") and "BundleThumbnail" or "Asset")
return "rbxthumb://type=" .. tipe .. "&id=" .. tostring(it.id) .. "&w=420&h=420"
end
function F.pakBawaan(jenis)
local hasil = {}
if jenis == "pack" then
table.insert(hasil, {jenis = "pack", id = C.ZOMBIE_R15.idle, nama = "ZOMBIE (R15)", thumb = "Asset", zombie = true, fav = true})
table.insert(hasil, {jenis = "pack", id = C.AURA_BUNDLE, nama = "ENDLESS AURA", fav = true})
table.insert(hasil, {jenis = "pack", id = 2623795, nama = "ADIDAS COMMUNITY", fav = true})
table.insert(hasil, {jenis = "pack", id = 64947377497157, nama = "WORM ANIMATION", fav = true})
else
for _, e in ipairs(C.EMOTE) do table.insert(hasil, {jenis = "emote", id = e.id, nama = e.nama, fav = true}) end
end
return hasil
end
F.pakCacheTipe = {}
function F.pakTipe(id)
local k = tostring(id)
if F.pakCacheTipe[k] then return F.pakCacheTipe[k] end
local d = httpJson("https://economy.roblox.com/v2/assets/" .. k .. "/details")
local t = d and tonumber(d.AssetTypeId)
if t then F.pakCacheTipe[k] = t end
return t
end
function F.httpCoba(url)
if not httpReq then
local okG, txt = pcall(function() return game:HttpGet(url) end)
if okG and type(txt) == "string" and txt ~= "" then
local okJ, d = pcall(function() return HS:JSONDecode(txt) end)
if okJ and type(d) == "table" then return d, nil end
return nil, "JSON tidak valid"
end
return nil, "tidak ada fungsi HTTP di executor"
end
local ok, res = pcall(function() return httpReq({Url = url, Method = "GET"}) end)
if not ok then return nil, "request error: " .. string.sub(tostring(res), 1, 60) end
if type(res) ~= "table" then return nil, "respon kosong" end
if res.StatusCode ~= 200 then return nil, "HTTP " .. tostring(res.StatusCode) .. " " .. string.sub(tostring(res.Body or ""), 1, 60) end
local okJ, d = pcall(function() return HS:JSONDecode(res.Body or "") end)
if okJ and type(d) == "table" then return d, nil end
return nil, "JSON tidak valid"
end
function F.pakEngineCari(jenis)
local AES = game:GetService("AvatarEditorService")
local p = CatalogSearchParams.new()
if jenis == "pack" then
p.BundleTypes = {Enum.BundleType.AvatarAnimations}
else
p.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
end
p.SortType = Enum.CatalogSortType.Relevance
p.IncludeOffSale = true
p.Limit = 30
return AES:SearchCatalog(p)
end
function F.pakBacaHalaman(pages, jenis)
local hasil = {}
for _, info in pairs(pages:GetCurrentPage()) do
local id = tonumber(info.Id or info.id)
local nm = info.Name or info.name
if id and nm and tostring(nm) ~= "" then table.insert(hasil, {jenis = jenis, id = id, nama = tostring(nm), fav = false}) end
end
return hasil
end
function F.pakHttp(jenis, cursor)
local sub = (jenis == "pack") and 38 or 39
local urls = {
"https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=" .. sub .. "&Limit=30&SortType=1&SortAggregation=5",
"https://catalog.roblox.com/v1/search/items/details?Subcategory=" .. sub .. "&Limit=30&SortType=1",
}
local alasan = "tidak diketahui"
for _, dasar in ipairs(urls) do
local url = dasar
if cursor and cursor ~= "" then url = url .. "&Cursor=" .. HS:UrlEncode(cursor) end
local d, why = F.httpCoba(url)
if d and type(d.data) == "table" then
local hasil = {}
for _, it in ipairs(d.data) do
local id = tonumber(it.id)
if id and it.name then table.insert(hasil, {jenis = jenis, id = id, nama = tostring(it.name), fav = false}) end
end
return hasil, d.nextPageCursor
end
alasan = why or "data tidak ada"
end
return nil, alasan
end
function F.pakAmbilHalaman(st)
local nama = (st.jenis == "pack") and "paket" or "emote"
if st.mode == nil then
local okE, pages = pcall(F.pakEngineCari, st.jenis)
if okE and pages then st.mode = "engine"; st.pages = pages; st.halaman = 0
else st.mode = "http"; st.alasanEngine = string.sub(tostring(pages), 1, 80) end
end
local baru = nil
if st.mode == "engine" then
local lanjut = true
if st.halaman > 0 then
local okF, fin = pcall(function() return st.pages.IsFinished end)
if okF and fin == true then st.akhir = true; st.status = "sudah halaman terakhir"; return end
local okN, eN = pcall(function() st.pages:AdvanceToNextPageAsync() end)
if not okN then st.status = "gagal lanjut halaman: " .. string.sub(tostring(eN), 1, 80); return end
end
local okB, lst = pcall(F.pakBacaHalaman, st.pages, st.jenis)
if not okB then st.status = "gagal baca halaman: " .. string.sub(tostring(lst), 1, 80); return end
st.halaman = st.halaman + 1
if #lst == 0 and st.halaman == 1 then
st.mode = "http"; st.alasanEngine = "0 item dari katalog dalam game"
else
baru = lst
local okF2, fin2 = pcall(function() return st.pages.IsFinished end)
if okF2 and fin2 == true then st.akhir = true end
end
end
if st.mode == "http" then
local hasil, info = F.pakHttp(st.jenis, st.cursor)
if not hasil then
st.status = "gagal ambil " .. nama .. " dari Roblox: " .. tostring(info) .. (st.alasanEngine and (" | dalam game: " .. st.alasanEngine) or "")
return
end
baru = hasil
st.cursor = info
if not info or info == "" then st.akhir = true end
end
local sudah = {}
for _, it in ipairs(st.items) do sudah[F.pakKunci(it)] = true end
local tambah = 0
for _, it in ipairs(baru or {}) do
local k = F.pakKunci(it)
if not sudah[k] then table.insert(st.items, it); sudah[k] = true; tambah = tambah + 1 end
end
st.status = "+" .. tambah .. " " .. nama .. " (total " .. #st.items .. ") · sumber: " .. ((st.mode == "engine") and "katalog dalam game" or "HTTP")
F.catat("katalog " .. nama .. ": " .. st.status)
end
function F.pakKlik(it)
if it.jenis == "pack" then
local aktif = F.pakAktif(it)
F.animReset()
if aktif then F.catat("pack dimatikan: " .. it.nama); return end
if it.zombie then F.animZombie() else F.animBundle(it.id, it.nama) end
else
if F.pakAktif(it) then F.emoteStop("dimatikan"); return end
F.emotePlay(it.nama, it.id)
end
end
function F.pakKartu(induk, it, urutan, segar, st)
local aktif = F.pakAktif(it)
local fav = F.animFavAda(it)
local kartu = mk("Frame", {Name = "kartu", Size = UDim2.new(0.48, 0, 0, 80), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = urutan}, induk)
rnd(kartu, 10)
local foto = mk("ImageLabel", {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 6, 0, 6), BackgroundColor3 = BTN, BorderSizePixel = 0, Image = F.pakGambar(it), ScaleType = Enum.ScaleType.Fit}, kartu)
rnd(foto, 8)
mk("TextLabel", {Size = UDim2.new(1, -70, 0, 36), Position = UDim2.new(0, 68, 0, 6), BackgroundTransparency = 1, Text = it.nama, TextColor3 = TXT, Font = FB, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, kartu)
local bOn = mk("TextButton", {Size = UDim2.new(0, 72, 0, 20), Position = UDim2.new(0, 68, 1, -26), BackgroundColor3 = aktif and ACT or BTN, Text = aktif and "MATIKAN" or "PAKAI", TextColor3 = TXT, Font = FB, TextSize = 10, AutoButtonColor = false}, kartu)
rnd(bOn, 6)
local bFav = mk("TextButton", {Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(0, 144, 1, -26), BackgroundColor3 = fav and OR or BTN, Text = "FAV", TextColor3 = TXT, Font = FB, TextSize = 9, AutoButtonColor = false}, kartu)
rnd(bFav, 6)
bOn.MouseButton1Click:Connect(function()
if st.sibuk then return end
task.spawn(function()
st.sibuk = true
local ok, e = pcall(F.pakKlik, it)
st.sibuk = false
if not ok then F.catat("error: " .. string.sub(tostring(e), 1, 120)) end
segar()
end)
end)
bFav.MouseButton1Click:Connect(function()
S.animFav = S.animFav or {}
S.animFav[F.pakKunci(it)] = not F.animFavAda(it)
F.autoSimpan()
segar()
end)
end
local function pgAnim(page)
local n = 0
local function nx() n = n + 1; return n end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Paket & emote", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local baris = mk("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
local tPack = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = ACT, Text = "ANIMATION PACK", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, baris)
rnd(tPack)
local tEmote = mk("TextButton", {Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), BackgroundColor3 = BTN, Text = "EMOTE", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false}, baris)
rnd(tEmote)
local wadah = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page)
local segarSemua = {}
local kolom = {}
local function buatKolom(jenis)
local st = {jenis = jenis, items = F.pakBawaan(jenis), cursor = nil, akhir = false, muat = false, sibuk = false, mode = nil, halaman = 0, status = ""}
local kol = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false}, wadah)
mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, kol)
local lblStatus = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, TextColor3 = MUT, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Text = "", LayoutOrder = 1}, kol)
local grid = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2}, kol)
mk("UIGridLayout", {CellSize = UDim2.new(0.48, 0, 0, 80), CellPadding = UDim2.new(0.04, 0, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, grid)
local tBanyak = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BTN, Text = "LOAD MORE", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = 3}, kol)
rnd(tBanyak)
local render
local function segarTombol()
tBanyak.Text = st.akhir and "SEMUA SUDAH DIMUAT" or (st.muat and "MEMUAT..." or "LOAD MORE")
end
render = function()
for _, c in ipairs(grid:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
local urut = {}
for _, it in ipairs(st.items) do if F.animFavAda(it) then table.insert(urut, it) end end
for _, it in ipairs(st.items) do if not F.animFavAda(it) then table.insert(urut, it) end end
for i, it in ipairs(urut) do F.pakKartu(grid, it, i, render, st) end
lblStatus.Text = st.status
segarTombol()
end
local function muatBanyak()
if st.muat or st.akhir then return end
st.muat = true; st.status = "memuat..."; render()
local ok, e = pcall(F.pakAmbilHalaman, st)
st.muat = false
if not ok then st.status = "error: " .. string.sub(tostring(e), 1, 100) end
render()
end
tBanyak.MouseButton1Click:Connect(function() task.spawn(muatBanyak) end)
table.insert(segarSemua, render)
task.spawn(function()
local sig = nil
while grid.Parent do
local s = (jenis == "pack") and tostring(S.anim.want and (S.anim.want.bundle or S.anim.want.kind) or "-") or tostring(S.emote.id or "-")
if s ~= sig then sig = s; pcall(render) end
task.wait(0.5)
end
end)
task.spawn(muatBanyak)
return kol
end
local kolomPack = buatKolom("pack")
local kolomEmote = buatKolom("emote")
local function pilih(jenis)
kolomPack.Visible = (jenis == "pack"); kolomEmote.Visible = (jenis == "emote")
tPack.BackgroundColor3 = (jenis == "pack") and ACT or BTN
tEmote.BackgroundColor3 = (jenis == "emote") and ACT or BTN
end
tPack.MouseButton1Click:Connect(function() pilih("pack") end)
tEmote.MouseButton1Click:Connect(function() pilih("emote") end)
pilih("pack")
F.pakSegarSemua = function() for _, f in ipairs(segarSemua) do pcall(f) end end
btn("STOP EMOTE", false, function() F.emoteStop("dihentikan") end)
btn("KEMBALIKAN ANIMASI", false, function() F.animReset() end)
end
local function pgEfek(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end
local function wadah() local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page); mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f); return f end
local function stepper(nama, get, dec, inc) local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r); mk("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r); local v = mk("TextLabel", {Size = UDim2.new(0, 44, 1, 0), Position = UDim2.new(1, -96, 0, 0), BackgroundTransparency = 1, Text = get(), TextColor3 = OR, Font = FB, TextSize = 12}, r); local b1 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -50, 0, 4), BackgroundColor3 = OFF, Text = "-", TextColor3 = TXT, Font = FB, TextSize = 14}, r); rnd(b1, 5); local b2 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -24, 0, 4), BackgroundColor3 = OFF, Text = "+", TextColor3 = TXT, Font = FB, TextSize = 14}, r); rnd(b2, 5); b1.MouseButton1Click:Connect(function() dec(); v.Text = get() end); b2.MouseButton1Click:Connect(function() inc(); v.Text = get() end); S.ui.segar = S.ui.segar or {}; table.insert(S.ui.segar, function() v.Text = get() end) end
sec("Item terpilih")
local boxPilih = box(TXT); boxPilih.Text = F.pilihTeks()
F.daftarSegar(function() boxPilih.Text = F.pilihTeks() end)
sec("Efek partikel"); stepper("Kepadatan", function() return F.nilaiPilih("rate", fmt) end, function() F.efekGeser("rate", -0.5) end, function() F.efekGeser("rate", 0.5) end); stepper("Ketebalan", function() return F.nilaiPilih("size", fmt) end, function() F.efekGeser("size", -0.5) end, function() F.efekGeser("size", 0.5) end)
btn("RESET EFEK", false, function() F.efekReset() end)
end
local function pgSetting(page)
local B = {page = page}; local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end
local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end
local function wadah() local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nx()}, page); mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f); return f end
local function ukur(nama, kunci, langkah, ubah)
local def = (kunci == "skala") and 1 or 0
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
mk("TextLabel", {Size = UDim2.new(0.42, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local kurang = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -108, 0.5, -11), BackgroundColor3 = OFF, Text = "-", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(kurang, 5)
local isi = mk("TextBox", {Size = UDim2.new(0, 46, 0, 22), Position = UDim2.new(1, -80, 0.5, -11), BackgroundColor3 = BG, Text = "", PlaceholderText = "0", PlaceholderColor3 = MUT, TextColor3 = OR, Font = FB, TextSize = 12, ClearTextOnFocus = false}, r); rnd(isi, 5)
local tambah = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -28, 0.5, -11), BackgroundColor3 = OFF, Text = "+", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(tambah, 5)
local function segar()
local it = S.pilih
if not it then isi.Text = "-"; return end
if UIS:GetFocusedTextBox() ~= isi then isi.Text = fmt(it.cfg[kunci] or def) end
end
kurang.MouseButton1Click:Connect(function() task.spawn(F.aman, function() ubah(-langkah); segar() end) end)
tambah.MouseButton1Click:Connect(function() task.spawn(F.aman, function() ubah(langkah); segar() end) end)
isi.FocusLost:Connect(function()
local angka = tonumber(isi.Text)
task.spawn(F.aman, function()
if angka then F.itemSet(kunci, angka) end
segar()
end)
end)
F.daftarSegar(segar)
segar()
end
local function swatch(daftar, onPick)
local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 92), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIGridLayout", {CellSize = UDim2.new(0.31, 0, 0, 26), CellPadding = UDim2.new(0.02, 0, 0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, f)
for i, w in ipairs(daftar) do
local b = mk("TextButton", {BackgroundColor3 = w[2], Text = w[1], TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.3, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = i}, f)
rnd(b)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() onPick(w) end) end)
end
return f
end
local function stepper(nama, get, dec, inc)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page); rnd(r)
mk("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = nama, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, r)
local v = mk("TextLabel", {Size = UDim2.new(0, 44, 1, 0), Position = UDim2.new(1, -96, 0, 0), BackgroundTransparency = 1, Text = get(), TextColor3 = OR, Font = FB, TextSize = 12}, r)
local b1 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -50, 0, 4), BackgroundColor3 = OFF, Text = "-", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(b1, 5)
local b2 = mk("TextButton", {Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(1, -24, 0, 4), BackgroundColor3 = OFF, Text = "+", TextColor3 = TXT, Font = FB, TextSize = 14, AutoButtonColor = false}, r); rnd(b2, 5)
local function segar() v.Text = get() end
b1.MouseButton1Click:Connect(function() task.spawn(F.aman, function() dec(); segar() end) end)
b2.MouseButton1Click:Connect(function() task.spawn(F.aman, function() inc(); segar() end) end)
F.daftarSegar(segar)
end
sec("Item terpilih")
local boxPilih = box(TXT); boxPilih.Text = F.pilihTeks()
F.daftarSegar(function() boxPilih.Text = F.pilihTeks() end)
sec("Posisi & besar item")
ukur("Kanan / Kiri", "ox", 0.1, function(d) F.itemGeser("ox", d) end)
ukur("Atas / Bawah", "oy", 0.1, function(d) F.itemGeser("oy", d) end)
ukur("Depan / Belakang", "oz", 0.1, function(d) F.itemGeser("oz", d) end)
ukur("Besar / Kecil", "skala", 0.1, function(d) F.itemSkala(d) end)
box(MUT).Text = "yang diatur hanya item terpilih. item yang belum nyala otomatis dinyalakan. ketik angka lalu enter, atau pakai - / +."
sec("Ukuran UI"); stepper("Besar UI", function() return tostring(math.floor((S.skala or 1) * 100 + 0.5)) .. "%" end, function() F.skalaSet((S.skala or 1) - 0.1) end, function() F.skalaSet((S.skala or 1) + 0.1) end)
sec("Kecerahan UI")
stepper("Kecerahan", function() return tostring(math.floor((S.uiAlpha or 1) * 100 + 0.5)) .. "%" end, function() F.uiAlphaGeser(-0.1) end, function() F.uiAlphaGeser(0.1) end)
btn("KECERAHAN 100%", false, function() F.uiAlphaSet(1) end)
sec("KORBLOX (khusus, terpisah dari setting item)")
stepper("Tinggi kaki", function() return string.format("%.2f", F.korPendAmbil().tinggi) end, function() F.korTinggi(-0.05) end, function() F.korTinggi(0.05) end)
stepper("Kiri / Kanan", function() return string.format("%.2f", F.korPendAmbil().geserX) end, function() F.korGeser("x", -0.05) end, function() F.korGeser("x", 0.05) end)
stepper("Depan / Belakang", function() return string.format("%.2f", F.korPendAmbil().geserZ) end, function() F.korGeser("z", -0.05) end, function() F.korGeser("z", 0.05) end)
btn("APPLY KORBLOX", true, function() F.korTerapkan() end)
btn("RESET KORBLOX", false, function() F.korReset() end)
box(MUT).Text = "Korblox berlaku ke karakter, bukan per item. Geser per 0.05, lalu tekan APPLY KORBLOX. Nyalakan di Karakter > Korblox kaki kanan."
sec("Reset")
btn("RESET SETTING ITEM", false, function() F.itemReset() end); btn("RESET ALL", true, function() F.resetAll() end)
end
local function pgInfo(page) local B = {page = page}; local n = 0; local function nx() n = n + 1; return n end; local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end; local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end; local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end sec("Status"); S.ui.rigBox = box(GOOD); sec("Akses"); box(GOOD).Text = "TANPA KEY | akses penuh | V9"; sec("Credit"); for _, t in ipairs(C.CREDIT) do box(TXT).Text = t end; sec("Saluran wa donatur"); for i = 1, 5 do box(TXT).Text = i .. "." end; box(BAD).Text = C.PERINGATAN; btn("TUTUP SCRIPT", false, function() task.spawn(F.aman, F.tutup) end) end
local function pgSaran(page)
local n = 0
local function nx() n = n + 1; return n end
local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end
sec("Jenis")
local KATEGORI = {"Kritik", "Req fitur", "Lapor bug"}
local pilih = KATEGORI[1]
local barisKat = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, barisKat)
local tombolKat = {}
local kotakMap = nil
local function segarKat()
for _, t in ipairs(tombolKat) do
local aktif = t.nama == pilih
t.b.BackgroundColor3 = aktif and OR or ROW
t.b.TextColor3 = aktif and BLK or TXT
end
if kotakMap then kotakMap.Visible = (pilih == "Lapor bug") end
end
for i, nama in ipairs(KATEGORI) do
local b = mk("TextButton", {Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = ROW, Text = nama, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = i}, barisKat)
rnd(b)
table.insert(tombolKat, {b = b, nama = nama})
b.MouseButton1Click:Connect(function() pilih = nama; segarKat() end)
end
segarKat()
sec("Isi pesan")
local kotak = mk("TextBox", {Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = ROW, Text = "", PlaceholderText = "tulis kritik, saran, atau bug di sini", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, MultiLine = true, TextWrapped = true, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nx()}, page)
rnd(kotak); mk("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6)}, kotak)
kotakMap = mk("TextBox", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, Text = "", PlaceholderText = "nama map (wajib untuk lapor bug)", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 12, ClearTextOnFocus = false, Visible = false, LayoutOrder = nx()}, page)
rnd(kotakMap)
segarKat()
local kirim = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ACT, Text = "[ KIRIM ]", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(kirim)
kirim.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
local teks = trim(kotak.Text)
if teks == "" then F.catat("saran: isi dulu pesannya"); return end
if C.WEBHOOK_SARAN == "" then F.catat("saran: webhook belum diisi di script"); return end
if not httpReq then F.catat("saran: executor tidak punya fungsi request"); return end
local mapTeks = kotakMap and trim(kotakMap.Text) or ""
if pilih == "Lapor bug" and mapTeks == "" then F.catat("saran: isi nama map dulu"); return end
local fieldsEmbed = {{name = "Pemain", value = me.Name, inline = true}}
if pilih == "Lapor bug" then table.insert(fieldsEmbed, {name = "Map", value = mapTeks, inline = true}) end
local warna = ({["Kritik"] = 16753920, ["Req fitur"] = 3447003, ["Lapor bug"] = 15158332})[pilih] or 0
local isi = game:GetService("HttpService"):JSONEncode({username = "KRONOZ LARPER", embeds = {{title = pilih, description = teks, color = warna, fields = fieldsEmbed, footer = {text = "KRONOZ LARPER v9 PREMIUM"}}}})
local ok, res = pcall(httpReq, {Url = C.WEBHOOK_SARAN, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = isi})
if ok and res and (res.StatusCode == 204 or res.StatusCode == 200) then
kotak.Text = ""; if kotakMap then kotakMap.Text = "" end; F.catat("saran: terkirim (" .. pilih .. ")")
else
F.catat("saran: gagal kirim" .. ((ok and res) and (" (status " .. tostring(res.StatusCode) .. ")") or ""))
end
end)
end)
end
local function pgLog(page) local B = {page = page}; local n = 0; local function nx() n = n + 1; return n end; local function sec(t) mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = t, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page) end; local function btn(txt, solid, fn) local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = solid and ACT or BTN, Text = txt, TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(b); b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end); return b end; local function box(w) local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ROW, TextColor3 = w, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page); rnd(l); mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, l); return l end sec("Log"); S.ui.logBox = box(LOGC); S.ui.logBox.Text = table.concat(S.logs, "\n"); btn("SALIN LOG", true, function() if setclipboard then setclipboard(table.concat(S.logs, "\n")) end end); btn("BERSIHKAN LOG", false, function() S.logs = {}; S.ui.logBox.Text = "(kosong)" end) end
local function bangunKunci()
local TS2 = game:GetService("TweenService")
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(640, 360)
local pg = me:WaitForChild("PlayerGui")
local lama = pg:FindFirstChild("KronozGate"); if lama then lama:Destroy() end
local gate = mk("ScreenGui", {Name = "KronozGate", ResetOnSpawn = false, DisplayOrder = 1000, IgnoreGuiInset = true}, pg)
local redup = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0}, gate)
local kotak = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, math.clamp(vp.X - 40, 260, 340), 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = BG, BorderSizePixel = 0}, redup)
rnd(kotak, 18)
mk("UIStroke", {Color = BRD, Thickness = 1, Transparency = 0.2}, kotak)
mk("UIPadding", {PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18)}, kotak)
mk("UIListLayout", {Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder}, kotak)
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = "Halo user, kami akan memberitahu, mungkin di steal an egg(sae) akan ada bug jika kamu menggunakan fitur clone, template larp, jadi kalo ada bug jangan marah marah karna itu memang di sengaja karna mekanisme nya", TextColor3 = TXT, Font = FM, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 1}, kotak)
local baris = mk("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = 2}, kotak)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, baris)
local hijau = mk("TextButton", {Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(46, 170, 90), Text = "Mengerti", TextColor3 = Color3.new(1, 1, 1), Font = FB, TextSize = 14, AutoButtonColor = false, LayoutOrder = 1}, baris)
rnd(hijau, 12)
local merah = mk("TextButton", {Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(210, 55, 55), Text = "Keluar", TextColor3 = Color3.new(1, 1, 1), Font = FB, TextSize = 14, AutoButtonColor = false, LayoutOrder = 2}, baris)
rnd(merah, 12)
local pilihan = nil
hijau.MouseButton1Click:Connect(function() pilihan = true end)
merah.MouseButton1Click:Connect(function() pilihan = false end)
repeat task.wait(0.05) until pilihan ~= nil
if pilihan then
S.premium = true
pcall(function() TS2:Create(redup, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play() end)
task.wait(0.2)
gate:Destroy()
return true
end
S.alive = false
gate:Destroy()
return false
end
local function pasangEfek(b)
if b:GetAttribute("zxFx") or b:GetAttribute("zxTab") then return end
b:SetAttribute("zxFx", true)
local sc = b:FindFirstChild("zxScale") or mk("UIScale", {Name = "zxScale", Scale = 1}, b)
local asal = nil
b.MouseEnter:Connect(function()
asal = b.BackgroundColor3
TS:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = asal:Lerp(Color3.new(1, 1, 1), 0.07)}):Play()
end)
b.MouseLeave:Connect(function()
if asal then TS:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = asal}):Play() end
TS:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Scale = 1}):Play()
end)
b.MouseButton1Down:Connect(function()
TS:Create(sc, TweenInfo.new(0.07, Enum.EasingStyle.Quad), {Scale = 0.96}):Play()
end)
b.MouseButton1Up:Connect(function()
TS:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
end
function F.pgShader(page)
local n = 0; local function nx() n = n + 1; return n end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "Shader", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nx()}, page)
local ket = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = ROW, Text = "Langit map jadi biru cerah dengan awan putih berbentuk kotak, seperti Minecraft klasik. Hanya terlihat di layarmu sendiri.", TextColor3 = MUT, Font = FM, TextSize = 11, TextWrapped = true, LayoutOrder = nx()}, page)
rnd(ket)
mk("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, ket)
local bLangit = mk("TextButton", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = BTN, Text = "", TextColor3 = TXT, Font = FB, TextSize = 12, AutoButtonColor = false, LayoutOrder = nx()}, page); rnd(bLangit, 10)
local function segarLangit() bLangit.Text = "LANGIT MINECRAFT: " .. (S.langitOn == true and "ON" or "OFF") end
bLangit.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.langitSet(S.langitOn ~= true); F.autoSimpan(); segarLangit() end) end)
F.daftarSegar(segarLangit); segarLangit()
end
function F.pgProfil(page)
local n = 0
local function nx() n = n + 1; return n end
local banner = mk("Frame", {Size = UDim2.new(1, 0, 0, 96), BackgroundColor3 = Color3.fromRGB(125, 12, 25), BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(banner, 14)
mk("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 8, 12)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(125, 12, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 55, 70))}), Rotation = 0}, banner)
mk("TextLabel", {Size = UDim2.new(0.7, 0, 0, 30), Position = UDim2.new(0, 16, 0, 18), BackgroundTransparency = 1, Text = "Welcome to KRONOZ", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left}, banner)
mk("TextLabel", {Size = UDim2.new(0.7, 0, 0, 16), Position = UDim2.new(0, 16, 0, 54), BackgroundTransparency = 1, Text = "YOUR WORKSPACE. YOUR CONTROL.", TextColor3 = Color3.fromRGB(230, 190, 195), TextSize = 9, Font = FB, TextXAlignment = Enum.TextXAlignment.Left}, banner)
mk("TextLabel", {Size = UDim2.new(0, 110, 0, 52), Position = UDim2.new(1, -124, 0, 22), BackgroundTransparency = 1, Text = "KZ", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 44, TextXAlignment = Enum.TextXAlignment.Right}, banner)
local kartu = mk("Frame", {Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(kartu, 14)
local foto = mk("ImageLabel", {Size = UDim2.new(0, 58, 0, 58), Position = UDim2.new(0, 14, 0, 13), BackgroundColor3 = BTN, BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(me.UserId) .. "&w=150&h=150"}, kartu)
rnd(foto, 29)
mk("UIStroke", {Color = OR, Thickness = 2}, foto)
local barisNama = mk("Frame", {Size = UDim2.new(1, -92, 0, 38), Position = UDim2.new(0, 84, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0}, kartu)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}, barisNama)
local badgeAdminP = F.badgeAdmin(barisNama)
badgeAdminP.LayoutOrder = 1
local bloki = mk("Frame", {Size = UDim2.new(0, 0, 0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 2}, barisNama)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)}, bloki)
local lblNamaProfil = mk("TextLabel", {Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = string.upper(tostring(me.DisplayName)), TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, bloki)
mk("UISizeConstraint", {MaxSize = Vector2.new(170, 18)}, lblNamaProfil)
local barisUser = mk("Frame", {Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 2}, bloki)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)}, barisUser)
local lblUserProfil = mk("TextLabel", {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "@" .. tostring(me.Name), TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1}, barisUser)
mk("UISizeConstraint", {MaxSize = Vector2.new(170, 16)}, lblUserProfil)
local badgeFakeP = F.centangBadge(barisUser)
badgeFakeP.Name = "KronozBadgeFake"
badgeFakeP.Size = UDim2.new(0, 9, 0, 9)
badgeFakeP.LayoutOrder = 2
local function segarBadge()
badgeAdminP.Visible = S.tier == "admin"
badgeFakeP.Visible = S.centang == true
end
F.daftarSegar(segarBadge)
pcall(segarBadge)
mk("TextLabel", {Size = UDim2.new(1, -92, 0, 16), Position = UDim2.new(0, 84, 0, 50), BackgroundTransparency = 1, Text = "Selamat datang, " .. tostring(me.DisplayName) .. "!", TextColor3 = OR, Font = FB, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, kartu)
local barisStat = mk("Frame", {Size = UDim2.new(1, 0, 0, 84), BackgroundTransparency = 1, LayoutOrder = nx()}, page)
local function kartuStat(i, judul, glif, nilai, sub, titik)
local f = mk("Frame", {Size = UDim2.new(1/3, -4, 1, 0), Position = UDim2.new((i - 1) / 3, 0, 0, 0), BackgroundColor3 = ROW, BorderSizePixel = 0}, barisStat)
rnd(f, 12); mk("UIStroke", {Color = BRD, Thickness = 1}, f)
mk("TextLabel", {Size = UDim2.new(1, -30, 0, 14), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = judul, TextColor3 = MUT, Font = FB, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, f)
if titik then
local titikHijau = mk("Frame", {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(1, -18, 0, 13), BackgroundColor3 = Color3.fromRGB(60, 200, 110), BorderSizePixel = 0}, f)
rnd(titikHijau, 99)
end
local kotak = mk("Frame", {Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 10, 0, 32), BackgroundColor3 = BTN, BorderSizePixel = 0}, f)
rnd(kotak, 10); mk("UIStroke", {Color = OR, Thickness = 1}, kotak)
mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = glif, TextColor3 = OR, Font = FB, TextSize = 11}, kotak)
local lblNilai = mk("TextLabel", {Size = UDim2.new(1, -56, 0, 18), Position = UDim2.new(0, 54, 0, 30), BackgroundTransparency = 1, Text = nilai, TextColor3 = TXT, Font = FB, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, f)
local lblSub = mk("TextLabel", {Size = UDim2.new(1, -56, 0, 14), Position = UDim2.new(0, 54, 0, 50), BackgroundTransparency = 1, Text = sub, TextColor3 = MUT, Font = FM, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, f)
return lblNilai, lblSub
end
kartuStat(1, "STATUS APLIKASI", "OK", "Siap", "Berjalan normal", true)
kartuStat(2, "VERSI", "v", "version 1", "Versi aplikasi", false)
local nilaiSis, subSis = kartuStat(3, "STATUS SISTEM", "~~", "- FPS", "Ping -", true)
local guiProfil = S.ui.gui
local layanan = game:GetService("RunService")
local bingkai = 0
local sambungan = layanan.Heartbeat:Connect(function() bingkai = bingkai + 1 end)
task.spawn(function()
while guiProfil and guiProfil.Parent do
task.wait(1)
local fps = bingkai; bingkai = 0
pcall(segarBadge)
local okPing, ping = pcall(function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
pcall(function()
nilaiSis.Text = tostring(fps) .. " FPS"
subSis.Text = okPing and ("Ping " .. tostring(ping) .. " ms") or "Ping tidak terbaca"
end)
end
sambungan:Disconnect()
end)
local function baris(judul, isi)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(r, 10)
mk("TextLabel", {Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = judul, TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, r)
mk("TextLabel", {Size = UDim2.new(0.6, -24, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundTransparency = 1, Text = isi, TextColor3 = TXT, Font = FB, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd}, r)
end
local umur = "-"
local okU, hari = pcall(function() return me.AccountAge end)
if okU and hari then umur = tostring(hari) .. " hari" end
baris("Nick", tostring(me.DisplayName))
baris("Username", "@" .. tostring(me.Name))
baris("User ID", tostring(me.UserId))
baris("Umur akun", umur)
baris("Script", "KRONOZ version 1")
local aksi = mk("Frame", {Size = UDim2.new(1, 0, 0, 104), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(aksi, 14)
mk("TextLabel", {Size = UDim2.new(1, -28, 0, 18), Position = UDim2.new(0, 14, 0, 10), BackgroundTransparency = 1, Text = "AKSI CEPAT", TextColor3 = OR, Font = FB, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, aksi)
local fila = mk("Frame", {Size = UDim2.new(1, -28, 0, 64), Position = UDim2.new(0, 14, 0, 34), BackgroundTransparency = 1}, aksi)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, fila)
local daftarAksi = {{"AC", "Accesoris", "AKSES"}, {"HS", "Hair & Shirt", "HAIR"}, {"CA", "Copy Ava", "CLONE"}, {"TL", "Template Larp", "LARP"}}
for i, d in ipairs(daftarAksi) do
local b = mk("TextButton", {Size = UDim2.new(0.25, -5, 1, 0), BackgroundColor3 = BTN, Text = "", AutoButtonColor = false, LayoutOrder = i}, fila)
rnd(b, 11)
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 8), BackgroundTransparency = 1, Text = d[1], TextColor3 = OR, Font = FB, TextSize = 13}, b)
mk("TextLabel", {Size = UDim2.new(1, -6, 0, 28), Position = UDim2.new(0, 3, 0, 30), BackgroundTransparency = 1, Text = d[2], TextColor3 = TXT, Font = FM, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center}, b)
local kunci = d[3]
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() if S.ui.tampil then S.ui.tampil(kunci) end end) end)
end
end
F.langitAsli = nil
F.langitGen = 0
F.langitPusat = nil
F.AWAN_JUMLAH = 160
F.AWAN_RADIUS = 800
function F.awanBuat(pusat)
local folder = workspace:FindFirstChild("KRONOZ_Awan")
if not folder then folder = Instance.new("Folder"); folder.Name = "KRONOZ_Awan"; folder.Parent = workspace end
folder:ClearAllChildren()
local r = F.AWAN_RADIUS
for i = 1, F.AWAN_JUMLAH do
local model = Instance.new("Model"); model.Name = "KotakAwan" .. i
local cx = pusat.X + math.random(-r, r)
local cz = pusat.Z + math.random(-r, r)
local cy = 200 + math.random(0, 50)
local putar = CFrame.Angles(0, math.rad(90 * math.random(0, 1)), 0)
for k = 1, math.random(1, 3) do
local p = Instance.new("Part")
p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.CastShadow = false
p.Material = Enum.Material.SmoothPlastic; p.Color = Color3.new(1, 1, 1); p.Transparency = 0.05
p.Size = Vector3.new(math.random(30, 120), math.random(6, 10), math.random(30, 90))
p.CFrame = CFrame.new(cx + math.random(-50, 50), cy + math.random(-3, 3), cz + math.random(-50, 50)) * putar
p.Parent = model
end
model.Parent = folder
end
end
function F.langitSet(on)
if on == true and not F.izin("shader") then F.kunci("shader"); return end
S.langitOn = on == true
F.langitGen = (F.langitGen or 0) + 1
local gen = F.langitGen
local Lt = game:GetService("Lighting")
local okT, awan = pcall(function() return workspace.Terrain.Clouds end)
local lamaAwan = workspace:FindFirstChild("KRONOZ_Awan"); if lamaAwan then lamaAwan:Destroy() end
local lamaAtm = Lt:FindFirstChild("KRONOZ_Langit"); if lamaAtm then lamaAtm:Destroy() end
F.langitPusat = nil
if not S.langitOn then
if F.langitAsli then
if okT and awan and F.langitAsli.awan ~= nil then pcall(function() awan.Enabled = F.langitAsli.awan end) end
for _, o in ipairs(F.langitAsli.buang or {}) do pcall(function() o.Parent = Lt end) end
F.langitAsli = nil
end
F.catat("langit: asli")
return
end
if not F.langitAsli then
local nyalaAwan = nil
if okT and awan then nyalaAwan = awan.Enabled end
F.langitAsli = {awan = nyalaAwan, buang = {}}
end
local function bersih()
for _, o in ipairs(Lt:GetChildren()) do
if (o:IsA("Sky") or o:IsA("Atmosphere")) and o.Name ~= "KRONOZ_Langit" then
table.insert(F.langitAsli.buang, o); pcall(function() o.Parent = nil end)
end
end
if okT and awan then pcall(function() awan.Enabled = false end) end
end
local atm = Instance.new("Atmosphere"); atm.Name = "KRONOZ_Langit"
atm.Color = Color3.fromRGB(124, 176, 255); atm.Decay = Color3.fromRGB(124, 176, 255)
atm.Density = 0.3; atm.Offset = 0; atm.Glare = 0; atm.Haze = 0
atm.Parent = Lt
local function jagaAwan()
local hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
local pos = hrp and hrp.Position or Vector3.new(0, 0, 0)
local titik = Vector3.new(pos.X, 0, pos.Z)
if not F.langitPusat or (titik - F.langitPusat).Magnitude > F.AWAN_RADIUS * 0.5 then
F.langitPusat = titik
F.awanBuat(titik)
end
end
bersih(); jagaAwan()
task.spawn(function()
while S.langitOn and F.langitGen == gen do
task.wait(1.5)
if not (S.langitOn and F.langitGen == gen) then break end
pcall(bersih)
pcall(jagaAwan)
end
end)
F.catat("langit: Minecraft ON")
end
local function pgPengaturan(set)
local NAVX, NAVON = Color3.fromRGB(12, 12, 14), Color3.fromRGB(75, 12, 17)
local urutan = 0
local function nx() urutan = urutan + 1; return urutan end
local kiri = mk("Frame", {Size = UDim2.new(0.34, -6, 1, -6), Position = UDim2.new(0, 6, 0, 0), BackgroundColor3 = ROW, BorderSizePixel = 0}, set)
rnd(kiri, 12)
local daftar = mk("Frame", {Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1}, kiri)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, daftar)
local kanan = mk("Frame", {Size = UDim2.new(0.66, -12, 1, -6), Position = UDim2.new(0.34, 6, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true}, set)
local halaman, tombolKat = {}, {}
local function halamanBaru(nama)
local p = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = OR, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, kanan)
mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, p)
halaman[nama] = p
return p
end
local function baris(page, judul)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(r, 10)
local l = mk("TextLabel", {Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = judul, TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r)
return r, l
end
local function tombolKecil(parent, teks, posisi, ukuran, fn)
local b = mk("TextButton", {Size = UDim2.new(0, ukuran, 0, 24), Position = posisi, BackgroundColor3 = OFF, Text = teks, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, parent)
rnd(b, 6)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end)
return b
end
local function stepper(page, judul, dapat, kurang, tambah)
local r, l = baris(page, judul)
local function segar() l.Text = judul .. "   " .. dapat() end
tombolKecil(r, "-", UDim2.new(1, -62, 0.5, -12), 28, function() kurang(); segar() end)
tombolKecil(r, "+", UDim2.new(1, -30, 0.5, -12), 28, function() tambah(); segar() end)
F.daftarSegar(segar); segar()
end
local function dua(page, judul, kunci, def, txtKiri, txtKanan, fnKiri, fnKanan)
local r = mk("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, page)
rnd(r, 10)
local l = mk("TextLabel", {Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, Text = judul, TextColor3 = TXT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, r)
local function segar()
local it = S.pilih
local v = "-"
if it then local x = it.cfg[kunci]; if type(x) ~= "number" then x = def end; v = fmt(x) end
l.Text = judul .. "   " .. v
end
local function tb(pos, teks, fn)
local b = mk("TextButton", {Size = UDim2.new(0.5, -12, 0, 24), Position = pos, BackgroundColor3 = BTN, Text = teks, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, r)
rnd(b, 6)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() fn(); segar() end) end)
end
tb(UDim2.new(0, 8, 1, -30), txtKiri, fnKiri)
tb(UDim2.new(0.5, 4, 1, -30), txtKanan, fnKanan)
F.daftarSegar(segar); segar()
end
local function tombol(page, teks, fn)
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BTN, Text = teks, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = nx()}, page)
rnd(b, 10)
b.MouseButton1Click:Connect(function() task.spawn(F.aman, fn) end)
end
local function infoItem(page)
local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = ROW, BorderSizePixel = 0, Text = "", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = nx()}, page)
rnd(l, 10)
mk("UIPadding", {PaddingLeft = UDim.new(0, 12)}, l)
local function segar() l.Text = F.pilihTeks() end
F.daftarSegar(segar); segar()
end
local pUI = halamanBaru("UI")
stepper(pUI, "Besar UI", function() return tostring(math.floor((S.skala or 1) * 100 + 0.5)) .. "%" end, function() F.skalaSet((S.skala or 1) - 0.1) end, function() F.skalaSet((S.skala or 1) + 0.1) end)
tombol(pUI, "RESET UKURAN UI", function() F.skalaSet(1) end)
tombol(pUI, "TEMA MERAH (original)", function() F.temaSet("merah") end)
tombol(pUI, "TEMA BIRU", function() F.temaSet("biru") end)
local bAuto = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BTN, Text = "", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = nx()}, pUI); rnd(bAuto, 10)
local function segarAuto() bAuto.Text = "AUTO LOAD: " .. (S.autoLoad ~= false and "ON" or "OFF") end
bAuto.MouseButton1Click:Connect(function() task.spawn(F.aman, function() S.autoLoad = (S.autoLoad == false); F.autoSimpan(); segarAuto() end) end)
F.daftarSegar(segarAuto)
local bExec = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BTN, Text = "", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = nx()}, pUI); rnd(bExec, 10)
local function segarExec() bExec.Text = "AUTO EXECUTE: " .. (S.autoExec == true and "ON" or "OFF") end
bExec.MouseButton1Click:Connect(function() task.spawn(F.aman, function() F.autoExecSet(S.autoExec ~= true); segarExec() end) end)
F.daftarSegar(segarExec); segarExec()
local barisKode = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = ROW, BorderSizePixel = 0, LayoutOrder = nx()}, pUI); rnd(barisKode)
local kodeBox = mk("TextBox", {Size = UDim2.new(1, -16, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = S.autoExecKode or F.AUTO_KODE, PlaceholderText = "kode loader untuk auto execute", PlaceholderColor3 = MUT, TextColor3 = OR, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, barisKode)
kodeBox.FocusLost:Connect(function() task.spawn(F.aman, function() local t = trim(kodeBox.Text); if t ~= "" then S.autoExecKode = t end; F.autoSimpan(); F.catat("kode auto execute disimpan") end) end)
segarAuto()
local pItem = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false}, kanan)
halaman["ITEM"] = pItem
local pilihKol = mk("Frame", {Size = UDim2.new(0.42, -4, 1, 0), BackgroundColor3 = ROW, BorderSizePixel = 0}, pItem)
rnd(pilihKol, 10)
local daftarItem = mk("ScrollingFrame", {Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = MUT, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, pilihKol)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, daftarItem)
table.insert(S.ui.pilihWadah, daftarItem)
F.pilihRender()
local ctrl = mk("ScrollingFrame", {Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.new(0.42, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = OR, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, pItem)
mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, ctrl)
infoItem(ctrl)
dua(ctrl, "Kanan / Kiri", "ox", 0, "KIRI", "KANAN", function() F.itemGeser("ox", -0.1) end, function() F.itemGeser("ox", 0.1) end)
dua(ctrl, "Atas / Bawah", "oy", 0, "BAWAH", "ATAS", function() F.itemGeser("oy", -0.1) end, function() F.itemGeser("oy", 0.1) end)
dua(ctrl, "Depan / Belakang", "oz", 0, "BELAKANG", "DEPAN", function() F.itemGeser("oz", -0.1) end, function() F.itemGeser("oz", 0.1) end)
dua(ctrl, "Besar / Kecil", "skala", 1, "KECIL", "BESAR", function() F.itemSkala(-0.1) end, function() F.itemSkala(0.1) end)
tombol(ctrl, "RESET ITEM", function() F.itemReset() end)
local pEfek = halamanBaru("EFEK")
infoItem(pEfek)
stepper(pEfek, "Tebal efek", function() return F.nilaiPilih("size", fmt) end, function() F.efekGeser("size", -0.5) end, function() F.efekGeser("size", 0.5) end)
stepper(pEfek, "Kepadatan", function() return F.nilaiPilih("rate", fmt) end, function() F.efekGeser("rate", -0.5) end, function() F.efekGeser("rate", 0.5) end)
tombol(pEfek, "RESET EFEK", function() F.efekReset() end)
local pBody = halamanBaru("BODY"); F.r15Panel(pBody)
local KAT = {{"UI", "Ukuran UI"}, {"ITEM", "Item terpilih"}, {"EFEK", "Efek partikel"}, {"BODY", "Body R15"}}
local function pilihKat(nama)
for k, p in pairs(halaman) do p.Visible = (k == nama) end
for k, b in pairs(tombolKat) do
local aktif = (k == nama)
TS:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = aktif and NAVON or NAVX, TextColor3 = aktif and TXT or MUT}):Play()
b.Font = aktif and FB or FM
end
end
for i, k in ipairs(KAT) do
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = NAVX, Text = k[2], TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false, LayoutOrder = i}, daftar)
rnd(b, 8)
mk("UIPadding", {PaddingLeft = UDim.new(0, 10)}, b)
tombolKat[k[1]] = b
local nama = k[1]
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() pilihKat(nama) end) end)
end
pilihKat("UI")
end
local function pgIndex(page)
local daftar, sudah = {}, {}
for _, grup in ipairs({{C.AKSES, "akses"}, {C.GEAR, "gear"}}) do
for _, a in ipairs(grup[1]) do
if not sudah[a[2]] then sudah[a[2]] = true; table.insert(daftar, {nama = a[1], id = a[2], kind = grup[2]}) end
end
end
mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Klik item untuk memilihnya (" .. #daftar .. " item)", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0}, page)
local kisi = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1}, page)
mk("UIGridLayout", {CellSize = UDim2.new(0.31, 0, 0, 150), CellPadding = UDim2.new(0.03, 0, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, kisi)
for i, d in ipairs(daftar) do
local id = d.id
local kotak = mk("TextButton", {BackgroundColor3 = ROW, Text = "", AutoButtonColor = false, LayoutOrder = i}, kisi)
rnd(kotak, 12); mk("UIStroke", {Color = BRD, Thickness = 1}, kotak)
local gambar = mk("ImageLabel", {Size = UDim2.new(1, -14, 0, 96), Position = UDim2.new(0, 7, 0, 7), BackgroundColor3 = BTN, BorderSizePixel = 0, Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=420&h=420", ScaleType = Enum.ScaleType.Fit}, kotak)
rnd(gambar, 10)
mk("TextLabel", {Size = UDim2.new(1, -10, 0, 34), Position = UDim2.new(0, 5, 0, 108), BackgroundTransparency = 1, Text = d.nama, TextColor3 = TXT, Font = FB, TextSize = 10, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Center}, kotak)
kotak.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
if id == 0 then F.catat("index: id tidak valid untuk " .. d.nama); return end
local it = F.addItem(d.nama, id, d.kind)
F.pilihKe(it)
if S.ui.tampil then S.ui.tampil("AKSES") end
end)
end)
end
end
local function bangunUtama()
local tampilTab, subTampil
local TABS = {
{key = "PROFIL", ab = "PF", judul = "Profile", desk = "Info akun kamu dan selamat datang"},
{key = "AKSES", ab = "AC", judul = "Accesoris", desk = "Pilih aksesoris di daftar kiri, atur di kanan"},
{key = "BODY", ab = "BD", judul = "Body", desk = "Korblox, headless, dan body R6"},
{key = "HAIR", ab = "HS", judul = "Hair & Shirt", desk = "Rambut, baju, dan celana"},
{key = "ANIM", ab = "AE", judul = "Animation & Emote", desk = "Emote dan paket animasi"},
{key = "CLONE", ab = "CA", judul = "Copy Ava", desk = "Copy avatar, fake verified, tiru outfit"},
{key = "FAKEP", ab = "FP", judul = "Fake Profil", desk = "Kartu profil palsu dengan fotomu sendiri"},
{key = "SHARE", ab = "SO", judul = "Share Outfit 2.0", desk = "Edit outfit pemain lain, hanya terlihat di layarmu"},
{key = "EVADE", ab = "EV", judul = "Evade Emote", desk = "Unlock semua emote Evade, visual saja"},
{key = "LARP", ab = "TL", judul = "Template Larp", desk = "Template avatar Larp 1-12"},
{key = "SHADER", ab = "SH", judul = "Shader", desk = "Langit Minecraft: awan kotak, langit biru cerah"},
{key = "INDEX", ab = "IX", judul = "Index", desk = "Semua accesoris dengan gambar dan nama"},
}
local ISI = {PROFIL = F.pgProfil, HAIR = pgShirt, ANIM = pgAnim, CLONE = pgFaker, FAKEP = F.pgFakeProfil, SHARE = F.pgShare, EVADE = F.pgEvade, LARP = pgLarp, BODY = pgBody, SHADER = F.pgShader}
local pg = me:WaitForChild("PlayerGui")
local lama = pg:FindFirstChild("KRONOZ"); if lama then lama:Destroy() end
local gui = mk("ScreenGui", {Name = "KRONOZ", ResetOnSpawn = false, DisplayOrder = 999}, pg)
S.ui.gui = gui; pcall(function() gui:SetAttribute("KronozUI", true) end); S.ui.segar = {}; S.ui.pilihWadah = {}; S.ui.halamanList = {}; S.ui.pilihCari = ""
local kam = workspace.CurrentCamera; local vp = kam and kam.ViewportSize or Vector2.new(640, 360)
S.ui.fit = math.clamp(math.min(0.92, (vp.X - 24) / 640, (vp.Y - 24) / 464), 0.5, 0.92)
local W, H = 640, 464
local HEAD_H, GAP, FOOT_H = 52, 6, 66
local SIDE_X = 10
local SIDE_W = math.clamp(math.floor(W * 0.255), 118, 168)
local PANEL_X = SIDE_X + SIDE_W + 10
local TOP = HEAD_H + GAP
local NAV = Color3.fromRGB(12, 12, 14)
local NAV_ON = Color3.fromRGB(75, 12, 17)
local function gradasi(o, kps)
local daftar = {}
for _, k in ipairs(kps) do table.insert(daftar, ColorSequenceKeypoint.new(k[1], k[2])) end
mk("UIGradient", {Color = ColorSequence.new(daftar), Rotation = 0}, o)
end
local root = mk("CanvasGroup", {Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0, math.floor((vp.X - W * S.ui.fit) / 2), 0, math.floor((vp.Y - H * S.ui.fit) / 2)), BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = true, GroupTransparency = 1}, gui)
rnd(root, 19)
mk("UIStroke", {Color = OR, Thickness = 1.5, Transparency = 0}, root)
S.ui.skalaUI = mk("UIScale", {Scale = F.skalaTujuan(0.92)}, root)
local hbg = mk("Frame", {Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundColor3 = BG, BorderSizePixel = 0}, root)
rnd(hbg, 19)
gradasi(hbg, {{0, Color3.fromRGB(35, 8, 12)}, {0.55, Color3.fromRGB(15, 10, 11)}, {1, Color3.fromRGB(8, 8, 9)}})
local head = mk("Frame", {Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundTransparency = 1}, root)
local brand = mk("Frame", {Size = UDim2.new(0, 240, 0, 52), Position = UDim2.new(0, 14, 0, 4), BackgroundTransparency = 1}, head)
local kzLogo = mk("TextLabel", {Size = UDim2.new(0, 78, 0, 46), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, Text = "KZ", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 40, TextXAlignment = Enum.TextXAlignment.Left}, brand)
gradasi(kzLogo, {{0, Color3.fromRGB(220, 20, 35)}, {0.5, Color3.fromRGB(245, 75, 85)}, {1, Color3.fromRGB(255, 255, 255)}})
local kronozLbl = mk("TextLabel", {Size = UDim2.new(0, 150, 0, 24), Position = UDim2.new(0, 80, 0, 7), BackgroundTransparency = 1, Text = "KRONOZ", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left}, brand)
gradasi(kronozLbl, {{0, Color3.fromRGB(225, 35, 48)}, {0.5, Color3.fromRGB(255, 120, 125)}, {1, Color3.fromRGB(255, 255, 255)}})
mk("TextLabel", {Size = UDim2.new(0, 150, 0, 14), Position = UDim2.new(0, 82, 0, 32), BackgroundTransparency = 1, Text = "LETSGO LARPING", TextColor3 = MUT, Font = FB, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left}, brand)
local W_JOIN = W >= 600 and 150 or 112
if W >= 520 then
local bJoin = mk("TextButton", {Size = UDim2.new(0, W_JOIN, 0, 34), Position = UDim2.new(1, -(122 + W_JOIN), 0, 13), BackgroundColor3 = BTN, Text = "JOIN SALURAN WA", TextColor3 = TXT, Font = FB, TextSize = W >= 600 and 12 or 10, AutoButtonColor = false}, head)
rnd(bJoin, 9); mk("UIStroke", {Color = OR, Thickness = 1}, bJoin)
bJoin.MouseButton1Click:Connect(function() task.spawn(F.aman, function() if setclipboard then setclipboard(C.WA_SALURAN) end; F.notif("KRONOZ", "link saluran disalin, buka WhatsApp dan tempel", 4) end) end)
end
local bMin = mk("TextButton", {Size = UDim2.new(0, 30, 0, 34), Position = UDim2.new(1, -78, 0, 13), BackgroundColor3 = BTN, Text = "", AutoButtonColor = false}, head)
rnd(bMin, 9); mk("UIStroke", {Color = BRD, Thickness = 1}, bMin)
mk("Frame", {Size = UDim2.new(0, 14, 0, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = TXT, BorderSizePixel = 0}, bMin)
local bGear = mk("TextButton", {Size = UDim2.new(0, 30, 0, 34), Position = UDim2.new(1, -114, 0, 13), BackgroundColor3 = BTN, Text = "", AutoButtonColor = false}, head)
rnd(bGear, 9); mk("UIStroke", {Color = BRD, Thickness = 1}, bGear)
local gearIkon = mk("Frame", {Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}, bGear)
local cincin = mk("Frame", {Size = UDim2.new(0, 11, 0, 11), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}, gearIkon)
rnd(cincin, 99); mk("UIStroke", {Color = TXT, Thickness = 2}, cincin)
for i = 0, 7 do
local sudut = math.rad(i * 45)
mk("Frame", {Size = UDim2.new(0, 5, 0, 3), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.cos(sudut) * 8, 0.5, math.sin(sudut) * 8), Rotation = i * 45, BackgroundColor3 = TXT, BorderSizePixel = 0}, gearIkon)
end
local bX = mk("TextButton", {Size = UDim2.new(0, 30, 0, 34), Position = UDim2.new(1, -42, 0, 13), BackgroundColor3 = BTN, Text = "×", TextColor3 = OR, Font = FB, TextSize = 20, AutoButtonColor = false}, head)
rnd(bX, 9); mk("UIStroke", {Color = BRD, Thickness = 1}, bX)
geser(head, root, nil)
local TI = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local mini = mk("ImageButton", {Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 10, 0, 40), BackgroundColor3 = BG, Image = "rbxassetid://128967992287891", ScaleType = Enum.ScaleType.Fit, AutoButtonColor = false, Visible = false}, gui)
rnd(mini, 12); mk("UIStroke", {Color = OR, Thickness = 1}, mini)
S.ui.mini = mini
local function minimkan()
mini.Position = root.Position
TS:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
TS:Create(S.ui.skalaUI, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Scale = F.skalaTujuan(0.92)}):Play()
task.delay(0.19, function()
root.Visible = false
mini.Visible = true
end)
end
local function pulihkan()
mini.Visible = false
root.Visible = true
root.GroupTransparency = 1
S.ui.skalaUI.Scale = F.skalaTujuan(0.92)
gui.Enabled = true
TS:Create(root, TI, {GroupTransparency = 0}):Play()
TS:Create(S.ui.skalaUI, SPRING, {Scale = F.skalaTujuan(1)}):Play()
end
bMin.MouseButton1Click:Connect(function() task.spawn(F.aman, minimkan) end)
geser(mini, mini, function() task.spawn(F.aman, pulihkan) end)
local side = mk("Frame", {Position = UDim2.new(0, SIDE_X, 0, TOP), Size = UDim2.new(0, SIDE_W, 0, H - TOP - 10), BackgroundColor3 = NAV, BorderSizePixel = 0}, root)
rnd(side, 15); mk("UIStroke", {Color = Color3.fromRGB(110, 20, 26), Thickness = 1}, side)
local boxCari = mk("TextBox", {Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 8), BackgroundColor3 = BTN, BorderSizePixel = 0, Text = "", PlaceholderText = "Cari...", PlaceholderColor3 = MUT, TextColor3 = TXT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, side)
rnd(boxCari, 10); mk("UIStroke", {Color = BRD, Thickness = 1}, boxCari); mk("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8)}, boxCari)
boxCari:GetPropertyChangedSignal("Text"):Connect(function()
local q = string.lower(trim(boxCari.Text))
S.ui.pilihCari = q
if q ~= "" and tampilTab then tampilTab("AKSES") end
F.pilihRender()
F.cariFitur(boxCari.Text)
end)
local navBox = mk("ScrollingFrame", {Position = UDim2.new(0, 8, 0, 42), Size = UDim2.new(1, -16, 1, -(42 + FOOT_H + 10)), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = OR, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, side)
mk("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, navBox)
local navBtn = {}
for i, t in ipairs(TABS) do
local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = NAV, Text = "", AutoButtonColor = false, LayoutOrder = i}, navBox)
rnd(b, 8); mk("UIStroke", {Color = Color3.fromRGB(110, 20, 26), Thickness = 1}, b)
mk("TextLabel", {Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = t.ab, TextColor3 = OR, Font = FB, TextSize = 11}, b)
local namaLbl = mk("TextLabel", {Size = UDim2.new(1, -46, 1, 0), Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1, Text = t.judul, TextColor3 = MUT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, b)
local kunci = t.key
b.MouseButton1Click:Connect(function() task.spawn(F.aman, function() tampilTab(kunci) end) end)
navBtn[kunci] = {btn = b, nama = namaLbl}
end
local bReset = mk("TextButton", {Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = BTN, Text = "RESET AVATAR", TextColor3 = OR, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = #TABS + 1}, navBox)
rnd(bReset, 8)
bReset.MouseButton1Click:Connect(function() task.spawn(F.aman, F.resetSemua) end)
local foot = mk("Frame", {Position = UDim2.new(0, 10, 1, -(FOOT_H + 10)), Size = UDim2.new(1, -20, 0, FOOT_H), BackgroundColor3 = ROW, BorderSizePixel = 0}, side)
rnd(foot, 12); mk("UIStroke", {Color = BRD, Thickness = 1}, foot)
mk("TextLabel", {Size = UDim2.new(0, 34, 0, 30), Position = UDim2.new(0, 8, 0, 14), BackgroundTransparency = 1, Text = "</>", TextColor3 = OR, Font = FB, TextSize = 15}, foot)
mk("TextLabel", {Size = UDim2.new(1, -56, 0, 18), Position = UDim2.new(0, 46, 0, 10), BackgroundTransparency = 1, Text = "KZ KRONOZ", TextColor3 = TXT, Font = FB, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, foot)
mk("TextLabel", {Size = UDim2.new(1, -56, 0, 16), Position = UDim2.new(0, 46, 0, 28), BackgroundTransparency = 1, Text = "LARP Hub", TextColor3 = MUT, Font = FM, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, foot)
mk("TextLabel", {Size = UDim2.new(1, -56, 0, 14), Position = UDim2.new(0, 46, 0, 46), BackgroundTransparency = 1, Text = "version 1", TextColor3 = OR, Font = FB, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, foot)
local panel = mk("Frame", {Position = UDim2.new(0, PANEL_X, 0, TOP), Size = UDim2.new(0, W - PANEL_X - 10, 0, H - TOP - 10), BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = true}, root)
rnd(panel, 16); mk("UIStroke", {Color = Color3.fromRGB(110, 20, 26), Thickness = 1}, panel)
local crumb = mk("TextLabel", {Size = UDim2.new(1, -28, 0, 26), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, RichText = true, Text = "", TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, panel)
local holder = mk("Frame", {Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -64), BackgroundTransparency = 1, ClipsDescendants = true}, panel)
S.ui.statusBox = mk("TextLabel", {Size = UDim2.new(1, -28, 0, 18), Position = UDim2.new(0, 14, 1, -22), BackgroundTransparency = 1, Text = "siap", TextColor3 = MUT, Font = FM, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, panel)
local utama = {}
local function halamanBuat(key, parent, subNama)
local p = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = MUT, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, parent)
mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, p)
mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, p)
p:SetAttribute("zxKey", key)
if subNama then p:SetAttribute("zxSub", subNama) end
S.ui.halamanList[subNama and (key .. "/" .. subNama) or key] = p
return p
end
for _, t in ipairs(TABS) do
if t.key ~= "AKSES" then
local p = halamanBuat(t.key, holder)
utama[t.key] = p
local fn = ISI[t.key]
if fn then
local ok, e = pcall(fn, p)
if not ok then F.catat("error page " .. t.judul .. ": " .. string.sub(tostring(e), 1, 100)) end
end
end
end
local halSet = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false}, holder)
utama.SETTING = halSet
pgPengaturan(halSet)
local aks = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false}, holder)
utama.AKSES = aks
local kiri = mk("Frame", {Size = UDim2.new(0.4, -6, 1, -6), Position = UDim2.new(0, 6, 0, 0), BackgroundColor3 = ROW, BorderSizePixel = 0}, aks)
rnd(kiri, 12)
local judulKiri = mk("TextLabel", {Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, Text = "DAFTAR ITEM", TextColor3 = OR, Font = FB, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, kiri)
local bKiri = mk("TextButton", {Size = UDim2.new(0, 24, 0, 20), Position = UDim2.new(1, -30, 0, 4), BackgroundColor3 = BTN, Text = "<", TextColor3 = TXT, Font = FB, TextSize = 13, AutoButtonColor = false}, kiri)
rnd(bKiri, 6)
local daftarPilih = mk("ScrollingFrame", {Size = UDim2.new(1, -8, 1, -28), Position = UDim2.new(0, 4, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = MUT, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, kiri)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, daftarPilih)
table.insert(S.ui.pilihWadah, daftarPilih)
F.pilihRender()
local kanan = mk("Frame", {Size = UDim2.new(0.6, -12, 1, 0), Position = UDim2.new(0.4, 6, 0, 0), BackgroundTransparency = 1}, aks)
local kiriBesar = true
local function kiriLayout(animasi)
local ti = animasi and TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) or TweenInfo.new(0)
judulKiri.Visible = kiriBesar; daftarPilih.Visible = kiriBesar
bKiri.Text = kiriBesar and "<" or ">"
if kiriBesar then
TS:Create(kiri, ti, {Size = UDim2.new(0.4, -6, 1, -6)}):Play()
TS:Create(kanan, ti, {Position = UDim2.new(0.4, 6, 0, 0), Size = UDim2.new(0.6, -12, 1, 0)}):Play()
else
TS:Create(kiri, ti, {Size = UDim2.new(0, 34, 1, -6)}):Play()
TS:Create(kanan, ti, {Position = UDim2.new(0, 46, 0, 0), Size = UDim2.new(1, -52, 1, 0)}):Play()
end
end
bKiri.MouseButton1Click:Connect(function() task.spawn(F.aman, function() kiriBesar = not kiriBesar; kiriLayout(true) end) end)
local CARD_BIG, CARD_SMALL = 92, 44
S.infoBesar = true
local kartu = mk("Frame", {Size = UDim2.new(1, 0, 0, CARD_BIG), BackgroundColor3 = ROW, BorderSizePixel = 0, ClipsDescendants = true}, kanan)
rnd(kartu, 12)
mk("TextLabel", {Size = UDim2.new(1, -52, 0, 16), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = "ITEM TERPILIH", TextColor3 = OR, Font = FB, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, kartu)
local bArrow = mk("TextButton", {Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, -36, 0, 4), BackgroundColor3 = BTN, Text = "v", TextColor3 = TXT, Font = FB, TextSize = 13, AutoButtonColor = false}, kartu)
local bFav = mk("TextButton", {Size = UDim2.new(0, 36, 0, 24), Position = UDim2.new(1, -76, 0, 4), BackgroundColor3 = BTN, Text = "FAV", TextColor3 = MUT, Font = FB, TextSize = 10, AutoButtonColor = false}, kartu)
rnd(bFav, 8)
rnd(bArrow, 8)
local infoNama = mk("TextLabel", {Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 12, 0, 22), BackgroundTransparency = 1, Text = "", TextColor3 = TXT, Font = FM, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, kartu)
local bAktif = mk("TextButton", {Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, 50), BackgroundColor3 = ACT, Text = "AKTIFKAN", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false}, kartu)
rnd(bAktif, 10)
local function infoSegar()
local it = S.pilih
if not it then
infoNama.Text = (#S.items == 0) and "belum ada item." or "belum pilih item."
bAktif.Text = "PILIH ITEM DULU"; bAktif.BackgroundColor3 = BTN; bFav.Visible = false
return
end
infoNama.Text = it.nama .. (it.on and "   · nyala" or "   · belum nyala")
bAktif.Text = it.on and "MATIKAN" or "AKTIFKAN"
bAktif.BackgroundColor3 = it.on and BTN or ACT
bFav.Visible = true; bFav.TextColor3 = F.isFav(it) and OR or MUT; bFav.BackgroundColor3 = F.isFav(it) and Color3.fromRGB(75, 12, 17) or BTN
end
table.insert(S.ui.segar, infoSegar)
local chips = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, CARD_BIG + 8), BackgroundColor3 = BG, BackgroundTransparency = 0, ZIndex = 4, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X}, kanan)
mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, chips)
local subBox = mk("Frame", {Size = UDim2.new(1, 0, 1, -(CARD_BIG + 46)), Position = UDim2.new(0, 0, 0, CARD_BIG + 46), BackgroundTransparency = 1, ClipsDescendants = true}, kanan)
local function infoLayout(animasi)
local h = S.infoBesar and CARD_BIG or CARD_SMALL
bArrow.Text = S.infoBesar and "v" or "^"
bAktif.Visible = S.infoBesar
local ti = animasi and TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) or TweenInfo.new(0)
TS:Create(kartu, ti, {Size = UDim2.new(1, 0, 0, h)}):Play()
TS:Create(chips, ti, {Position = UDim2.new(0, 0, 0, h + 8)}):Play()
TS:Create(subBox, ti, {Position = UDim2.new(0, 0, 0, h + 46), Size = UDim2.new(1, 0, 1, -(h + 46))}):Play()
end
bArrow.MouseButton1Click:Connect(function() task.spawn(F.aman, function() S.infoBesar = not S.infoBesar; infoLayout(true) end) end)
bAktif.MouseButton1Click:Connect(function() task.spawn(F.aman, function() if F.pilihWajib() then F.setOn(S.pilih, not S.pilih.on) end; infoSegar() end) end)
bFav.MouseButton1Click:Connect(function() task.spawn(F.aman, function() local it = S.pilih; if not it then return end; F.favAtur(it, not F.isFav(it)); F.pilihRender(); F.catat(it.nama .. (F.isFav(it) and " ditambah favorit" or " dihapus dari favorit")) end) end)
infoLayout(false)
infoSegar()
task.spawn(function() while gui.Parent do task.wait(0.4); pcall(infoSegar) end end)
local SUB = {{"Gear", pgFitur}, {"Hide", pgHide}, {"Info", false}}
local subPage, subChip = {}, {}
for i, s in ipairs(SUB) do
local nama = s[1]
local c = mk("TextButton", {Size = UDim2.new(0, 66, 1, 0), BackgroundColor3 = ROW, Text = nama, TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = i}, chips)
rnd(c, 9)
subChip[nama] = c
local p = halamanBuat("AKSES", subBox, nama)
subPage[nama] = p
if s[2] then
local ok, e = pcall(s[2], p)
if not ok then F.catat("error " .. nama .. ": " .. string.sub(tostring(e), 1, 100)) end
else
local bWA = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BTN, Text = "JOIN SALURAN WA", TextColor3 = TXT, Font = FB, TextSize = 11, AutoButtonColor = false, LayoutOrder = 0}, p)
rnd(bWA, 10)
bWA.MouseButton1Click:Connect(function() task.spawn(F.aman, function() if setclipboard then setclipboard(C.WA_SALURAN) end; F.notif("KRONOZ", "link saluran disalin, buka WhatsApp dan tempel", 4) end) end)
for k, fn in ipairs({pgInfo, pgLog, pgSaran}) do
local w = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = k}, p)
mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, w)
local ok, e = pcall(fn, w)
if not ok then F.catat("error info: " .. string.sub(tostring(e), 1, 100)) end
end
end
c.MouseButton1Click:Connect(function() task.spawn(F.aman, function() subTampil(nama) end) end)
end
subTampil = function(nama)
for _, s in ipairs(SUB) do
local aktif = (s[1] == nama)
subPage[s[1]].Visible = aktif
TS:Create(subChip[s[1]], TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = aktif and OR or ROW, TextColor3 = aktif and BLK or TXT}):Play()
end
end
subTampil("Gear")
S.ui.subTampil = subTampil
tampilTab = function(key)
if key == "INDEX" and utama.INDEX and not S.ui.indexSiap then S.ui.indexSiap = true; local okI, eI = pcall(pgIndex, utama.INDEX); if not okI then F.catat("error index: " .. string.sub(tostring(eI), 1, 100)) end end
for k, c in pairs(utama) do c.Visible = (k == key) end
for k, nb in pairs(navBtn) do
local aktif = (k == key)
TS:Create(nb.btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = aktif and NAV_ON or NAV}):Play()
TS:Create(nb.nama, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = aktif and TXT or MUT}):Play()
nb.nama.Font = aktif and FB or FM
end
for _, t in ipairs(TABS) do
if t.key == key then
crumb.Text = '<font color="#E63B35">' .. t.ab .. '</font>   ' .. (string.gsub(t.judul, "&", "&amp;")) .. '   <font color="#808080">' .. t.desk .. '</font>'
end
end
if key == "SETTING" then
crumb.Text = '<font color="#E63B35">ST</font>   Pengaturan   <font color="#808080">Ukuran UI, item, dan efek</font>'
end
S.ui.aktifTab = key
end
S.ui.tampil = tampilTab
tampilTab("PROFIL")
local tabSebelum = "PROFIL"
local function bukaPengaturan()
if S.ui.aktifTab == "SETTING" then
tampilTab(tabSebelum)
else
tabSebelum = S.ui.aktifTab or "PROFIL"
tampilTab("SETTING")
end
end
bGear.MouseButton1Click:Connect(function() task.spawn(F.aman, bukaPengaturan) end)
bX.MouseButton1Click:Connect(function()
task.spawn(F.aman, function()
TS:Create(root, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
TS:Create(S.ui.skalaUI, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {Scale = F.skalaTujuan(0.92)}):Play()
task.wait(0.17)
F.tutup()
end)
end)
if S.hideConn then S.hideConn:Disconnect() end
S.hideConn = UIS.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == S.hideKey then gui.Enabled = not gui.Enabled end end)
local PEGAS = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
gui.Enabled = true; root.Visible = true
TS:Create(root, PEGAS, {GroupTransparency = 0}):Play()
TS:Create(S.ui.skalaUI, SPRING, {Scale = F.skalaTujuan(1)}):Play()
task.delay(0.6, function()
if root.Parent and not mini.Visible then root.Visible = true; root.GroupTransparency = 0 end
end)
for _, d in ipairs(gui:GetDescendants()) do
if d:IsA("TextButton") then pasangEfek(d) end
end
gui.DescendantAdded:Connect(function(d)
if d:IsA("TextButton") then task.defer(pasangEfek, d) end
end)
F.catat("siap. KRONOZ jalan")
end
F.TINGKAT = {member = 1, vip = 2, vvip = 3, admin = 3}
F.FITUR_MIN = {shader = 2, fake = 3, clone = 3, larpGirl = 3}
F.FITUR_NAMA = {shader = "Shader", fake = "Fake verified / nama palsu", clone = "Clone avatar / tiru outfit", larpGirl = "Larp girl"}
function F.izin(fitur)
local t = F.TINGKAT[S.tier or ""] or 0
if t == 0 then return false end
return t >= (F.FITUR_MIN[fitur] or 1)
end
function F.kunci(fitur)
local min = F.FITUR_MIN[fitur] or 1
local perlu = (min == 3 and "VVIP") or (min == 2 and "VIP") or "member"
F.catat((F.FITUR_NAMA[fitur] or fitur) .. " terkunci untuk key " .. string.upper(S.tier or "-") .. ", butuh key " .. perlu)
end
function F.larpGirl(lp)
return string.find(string.lower(tostring(lp.nama or "")), "girl", 1, true) ~= nil
end
do
local G = (getgenv and getgenv()) or _G
if type(G.KRONOZ_MATI) == "function" then pcall(G.KRONOZ_MATI) end
G.KRONOZ_MATI = function()
S.mati = true; S.alive = false; S.centang = false
pcall(F.bersihBadge)
pcall(function() if S.evadeAPI then S.evadeAPI.Clean(); S.evadeAPI = nil; S.evadeOn = false end end)
end
end
local ok, err = xpcall(function()
task.wait(0.3)
S.tier = __role
if not bangunKunci() then return end
for _, a in ipairs(C.AKSES) do F.addItem(a[1], a[2], "akses").builtin = true end
for _, g in ipairs(C.GEAR) do F.addItem(g[1], g[2], "gear").builtin = true end
bangunUtama()
task.spawn(F.centangSync)
F.catat("key " .. string.upper(S.tier or "-") .. " aktif")
F.jalanPantau()
F.skinMuat()
F.autoJalan()
for _, it in ipairs(S.items) do if it.kind == "gear" and not it.tpl then task.spawn(F.gearMuatTas, it) end end
end, function(e)
return tostring(e) .. "\n" .. debug.traceback()
end)
if not ok then
warn("[KRONOZ] UI ERROR: " .. tostring(err))
pcall(function()
local g = S.ui and S.ui.gui
if g then
g.Enabled = true
for _, c in ipairs(g:GetChildren()) do
if c:IsA("CanvasGroup") then c.Visible = true; c.GroupTransparency = 0 end
end
end
end)
F.notif("KRONOZ ERROR", tostring(err):sub(1, 190), 15)
local p = me:WaitForChild("PlayerGui")
local g = Instance.new("ScreenGui", p); g.Name = "ZenoxError"
local t = Instance.new("TextButton", g); t.Size = UDim2.new(0.85, 0, 0, 200); t.Position = UDim2.new(0.075, 0, 0.5, -100); t.BackgroundColor3 = BLK; t.TextColor3 = BAD; t.Font = Enum.Font.Code; t.TextSize = 11; t.TextWrapped = true; t.Text = "KRONOZ ERROR:\n" .. tostring(err); t.Parent = g
end
