--[[
    A197 | Larping Avatar (v4)  - Delta Android
    Clone avatar = logika KingAgoy (CreateHumanoidModelFromDescription + tukar karakter,
    animasi driver, copy R6/R15 di tempat, emote, auto-apply respawn, aksesoris Weld manual).
    Semua perubahan client-side. Katalog: dibuat oleh Roblox, urut termahal.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- re-execute = loop lama otomatis berhenti
local genv = (getgenv and getgenv()) or _G
local RUN_ID = os.clock()
genv.A197_RUN = RUN_ID

------------------------------------------------------------------
-- UI helper
------------------------------------------------------------------
local BG = Color3.fromRGB(22, 22, 32)
local PANEL = Color3.fromRGB(34, 34, 48)
local ACCENT = Color3.fromRGB(110, 90, 255)
local WHITE = Color3.new(1, 1, 1)

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local order = 0
local function nx() order += 1 return order end

local function trim(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end

local host = (gethui and gethui()) or game:GetService("CoreGui")
for _, h in ipairs({host, LP:FindFirstChild("PlayerGui")}) do
    local old = h and h:FindFirstChild("A197")
    if old then old:Destroy() end
end

local gui = new("ScreenGui", {
    Name = "A197", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
local okParent = pcall(function() gui.Parent = host end)
if not okParent or not gui.Parent then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
local W = math.floor(math.clamp(vp.X - 20, 260, 340))
local H = math.floor(math.clamp(vp.Y - 40, 280, 440))

local main = new("Frame", {
    Name = "Main", Size = UDim2.fromOffset(W, H),
    Position = UDim2.new(0.5, -math.floor(W / 2), 0.5, -math.floor(H / 2)),
    BackgroundColor3 = BG, BorderSizePixel = 0, Active = true,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, main)

local bar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = PANEL, BorderSizePixel = 0,
}, main)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, bar)
new("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Text = "A197", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
}, bar)

local function barBtn(txt, x, fn)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(26, 22), Position = UDim2.new(1, x, 0, 5),
        BackgroundColor3 = BG, Text = txt, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = 14,
    }, bar)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
    b.Activated:Connect(fn)
end

local body = new("Frame", {
    Size = UDim2.new(1, 0, 1, -32), Position = UDim2.fromOffset(0, 32),
    BackgroundTransparency = 1,
}, main)

do -- drag
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local status = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 8, 1, -24),
    BackgroundTransparency = 1, Text = "Siap.", TextColor3 = Color3.fromRGB(170, 170, 190),
    Font = Enum.Font.Gotham, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, body)
local function say(t) status.Text = tostring(t) end

local function btn(parent, text, fn)
    local b = new("TextButton", {
        Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = PANEL, Text = text,
        TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextWrapped = true, LayoutOrder = nx(),
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
    b.Activated:Connect(function()
        task.spawn(function()
            local ok, err = pcall(fn)
            if not ok then say("Error: " .. tostring(err)) end
        end)
    end)
    return b
end

local function box(parent, placeholder)
    local t = new("TextBox", {
        Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Color3.fromRGB(28, 28, 40),
        TextColor3 = WHITE, PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(130, 130, 150), Text = "",
        ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13,
        LayoutOrder = nx(),
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, t)
    return t
end

-- tab bar (bisa digeser ke samping, karena tab-nya banyak)
local tabBar = new("ScrollingFrame", {
    Size = UDim2.new(1, -12, 0, 26), Position = UDim2.fromOffset(6, 4),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(),
    ScrollingDirection = Enum.ScrollingDirection.X,
}, body)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local content = new("Frame", {
    Size = UDim2.new(1, -12, 1, -64), Position = UDim2.fromOffset(6, 36),
    BackgroundTransparency = 1, ClipsDescendants = true,
}, body)

local pages, tabBtns, onShow = {}, {}, {}

local function showTab(name)
    for k, pg in pairs(pages) do
        pg.Visible = (k == name)
        tabBtns[k].BackgroundColor3 = (k == name) and ACCENT or PANEL
    end
    local f = onShow[name]
    if f then onShow[name] = nil task.spawn(f) end
end

local function makePage(name)
    local p = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(), Visible = false,
    }, content)
    new("UIListLayout", {
        Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, p)
    local tb = new("TextButton", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = PANEL, Text = name, TextColor3 = WHITE,
        Font = Enum.Font.GothamMedium, TextSize = 12, LayoutOrder = nx(),
    }, tabBar)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, tb)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, tb)
    pages[name], tabBtns[name] = p, tb
    tb.Activated:Connect(function() showTab(name) end)
    return p
end


------------------------------------------------------------------
-- HTTP + katalog Roblox
------------------------------------------------------------------
local httpReq = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)

local function httpGet(url)
    if httpReq then
        local ok, res = pcall(httpReq, {Url = url, Method = "GET"})
        if ok and res then
            if res.StatusCode == 200 then return res.Body end
            return nil, "HTTP " .. tostring(res.StatusCode)
        end
    end
    local ok, bodyText = pcall(function() return game:HttpGet(url) end)
    if ok and bodyText then return bodyText end
    return nil, "Request gagal (executor tidak support HTTP?)"
end

-- urutan: 1 = Termahal, 2 = Terlaris, 3 = Relevan
local SORTS = {{"Termahal", 5}, {"Terlaris", 2}, {"Relevan", 0}}
local catCache = {}

-- Parameter resmi (create.roblox.com/docs/projects/assets/api):
-- Category 11=Accessories 3=Clothing 4=BodyParts 12=AvatarAnimations
-- Subcategory 19=Accessories 56=ClassicShirts 57=ClassicPants 37=Bundles 38=AnimationBundles 39=Emote 15=Heads
-- CreatorTargetId=1 & CreatorType=1  -> dibuat oleh Roblox (akun "Roblox")
-- SortType 5 = harga tertinggi dulu
-- mode 1 = lengkap (kreator Roblox + urut harga)
-- mode 2 = tanpa filter kreator di URL (disaring di client)
-- mode 3 = tanpa urut harga (disortir di client)
-- mode 4 = tanpa Subcategory
-- mode 5 = minimal (Category + Limit saja)
local function buildUrl(t, kw, cursor, sortType, mode)
    local q = {"Category=" .. t.cat, "Limit=30"}
    if t.sub and mode <= 3 then table.insert(q, "Subcategory=" .. t.sub) end
    if mode <= 4 then
        table.insert(q, "SortType=" .. ((mode >= 3) and 0 or sortType))
        table.insert(q, "SortAggregation=5")
    end
    if mode == 1 and not t.anyCreator then
        table.insert(q, "CreatorTargetId=1")
        table.insert(q, "CreatorType=1")
    end
    if kw ~= "" then table.insert(q, "Keyword=" .. HttpService:UrlEncode(kw)) end
    if cursor then table.insert(q, "Cursor=" .. HttpService:UrlEncode(cursor)) end
    return "https://catalog.roblox.com/v1/search/items/details?" .. table.concat(q, "&")
end

local function fetchCatalog(t, kw, cursor, sortType, startMode)
    local lastErr = "unknown"
    for mode = startMode or 1, 5 do
        local url = buildUrl(t, kw, cursor, sortType, mode)
        local hit = catCache[url]
        if hit then return hit[1], hit[2], mode end
        local raw, err = httpGet(url)
        if raw then
            local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(data) == "table" then
                local items = data.data or {}
                catCache[url] = {items, data.nextPageCursor}
                return items, data.nextPageCursor, mode
            end
            lastErr = "Respons tidak valid"
        else
            lastErr = (err or lastErr) .. " (mode " .. mode .. ")"
        end
    end
    return nil, lastErr
end

local function priceOf(it) return tonumber(it.price) or tonumber(it.lowestPrice) or -1 end

local function fmtPrice(p)
    if p < 0 then return "-" end
    if p == 0 then return "Gratis" end
    local s = tostring(math.floor(p))
    local out = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
    if out:sub(1, 1) == "." then out = out:sub(2) end
    return "R$ " .. out
end

local function isRoblox(it)
    if it.creatorTargetId ~= nil then return tonumber(it.creatorTargetId) == 1 end
    if it.creatorName ~= nil then return it.creatorName == "Roblox" end
    return true
end

local function filterItems(items, t)
    local allow = t.allow or {Asset = true}
    local out = {}
    for _, it in ipairs(items) do
        if it.id and allow[it.itemType]
            and (t.anyCreator or isRoblox(it))
            and (not t.at or not it.assetType or t.at[it.assetType]) then
            table.insert(out, it)
        end
    end
    return out
end

-- galeri kartu (gambar + nama + harga). Dibuat bertahap supaya tidak lag.
local function makeBrowser(page, ph, types, onPick, extra, defSort, isOn)
    local B = {idx = 1, sort = defSort or 1, cursor = nil, kw = "", busy = false, gen = 0, mode = 1, cards = {}}
    local grid, moreBtn, typeBtn, sortBtn
    local sbox = box(page, ph)

    local function clear()
        B.cards = {}
        for _, ch in ipairs(grid:GetChildren()) do
            if ch:IsA("GuiButton") then ch:Destroy() end
        end
    end

    function B.refresh()
        if not isOn then return end
        for _, c in ipairs(B.cards) do
            if c.btn.Parent then
                c.btn.BackgroundColor3 = isOn(c.it) and Color3.fromRGB(40, 120, 70) or PANEL
            end
        end
    end

    local function addCard(it)
        local card = new("TextButton", {
            BackgroundColor3 = PANEL, Text = "", LayoutOrder = nx(),
        }, grid)
        new("UICorner", {CornerRadius = UDim.new(0, 8)}, card)
        local kind = (it.itemType == "Bundle") and "BundleThumbnail" or "Asset"
        new("ImageLabel", {
            Size = UDim2.new(1, -8, 0, 60), Position = UDim2.fromOffset(4, 3),
            BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit,
            Image = "rbxthumb://type=" .. kind .. "&id=" .. it.id .. "&w=150&h=150",
        }, card)
        new("TextLabel", {
            Size = UDim2.new(1, -6, 0, 24), Position = UDim2.fromOffset(3, 64),
            BackgroundTransparency = 1, Text = it.name or tostring(it.id),
            TextColor3 = WHITE, Font = Enum.Font.Gotham, TextSize = 10,
            TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd,
            TextYAlignment = Enum.TextYAlignment.Top,
        }, card)
        new("TextLabel", {
            Size = UDim2.new(1, -6, 0, 12), Position = UDim2.fromOffset(3, 90),
            BackgroundTransparency = 1, Text = fmtPrice(priceOf(it)),
            TextColor3 = Color3.fromRGB(120, 220, 140), Font = Enum.Font.GothamMedium,
            TextSize = 10,
        }, card)
        table.insert(B.cards, {btn = card, it = it})
        if isOn and isOn(it) then card.BackgroundColor3 = Color3.fromRGB(40, 120, 70) end
        card.Activated:Connect(function()
            task.spawn(function()
                local ok, err = pcall(onPick, it, types[B.idx])
                if not ok then say("Error: " .. tostring(err)) end
                B.refresh()
            end)
        end)
    end

    function B.search(kw, more)
        if B.busy then return say("Tunggu sebentar...") end
        kw = trim(kw)
        local t = types[B.idx]
        if not more and kw:match("^%d+$") then
            local ok, err = pcall(onPick, {id = tonumber(kw), name = "ID " .. kw, itemType = t.numType or "Asset"}, t)
            if not ok then say("Error: " .. tostring(err)) end
            return B.refresh()
        end
        B.busy = true
        B.gen += 1
        local gen = B.gen
        local ok, err = pcall(function()
            if not more then B.cursor = nil B.kw = kw B.mode = 1 clear() end
            say("Mencari di katalog Roblox...")
            local sortType = SORTS[B.sort][2]
            local items, nextCur, mode = fetchCatalog(t, B.kw, more and B.cursor or nil, sortType, more and B.mode or 1)
            if not items then say("Gagal: " .. tostring(nextCur)) return end
            B.mode = mode
            local list = filterItems(items, t)
            B.cursor = nextCur
            if sortType == 5 then
                table.sort(list, function(a, b) return priceOf(a) > priceOf(b) end)
            end
            for i, it in ipairs(list) do
                if gen ~= B.gen then break end
                addCard(it)
                if i % 6 == 0 then task.wait() end
            end
            moreBtn.Visible = (B.cursor ~= nil)
            say(#list > 0 and ("Ditemukan " .. #list .. " item (" .. SORTS[B.sort][1] .. "). Tap untuk pakai.")
                or "Tidak ada hasil")
        end)
        B.busy = false
        if not ok then say("Error: " .. tostring(err)) end
    end

    sbox.FocusLost:Connect(function(enter)
        if enter then task.spawn(B.search, sbox.Text, false) end
    end)

    if #types > 1 then
        typeBtn = btn(page, "Jenis: " .. types[1].label .. " (tap ganti)", function()
            B.idx = B.idx % #types + 1
            typeBtn.Text = "Jenis: " .. types[B.idx].label .. " (tap ganti)"
            B.search(sbox.Text, false)
        end)
    end
    sortBtn = btn(page, "Urut: " .. SORTS[B.sort][1] .. " (tap ganti)", function()
        B.sort = B.sort % #SORTS + 1
        sortBtn.Text = "Urut: " .. SORTS[B.sort][1] .. " (tap ganti)"
        B.search(sbox.Text, false)
    end)
    btn(page, "Cari", function() B.search(sbox.Text, false) end)
    if extra then extra(page) end

    grid = new("Frame", {
        Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = nx(),
    }, page)
    new("UIGridLayout", {
        CellSize = UDim2.new(1 / 3, -4, 0, 106), CellPadding = UDim2.fromOffset(4, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, grid)

    moreBtn = btn(page, "Muat lebih banyak", function() B.search("", true) end)
    moreBtn.Visible = false
    return B
end

------------------------------------------------------------------
-- CLONE ENGINE (logika KingAgoy, diambil apa adanya)
------------------------------------------------------------------
local Clone = (function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer

local function log(...) print("[A197]", ...) end
local function notify(title, text)
    pcall(say, tostring(title) .. ": " .. string.sub(tostring(text), 1, 120))
end

local running = true

-- state (sama seperti KingAgoy)
local real = nil
local fake = nil
local lastUserId = nil
local lastBuilder = nil
local buildR15Model = nil
local inPlaceBackup = {}
local inPlaceUserId = nil
local lastEmotes = {}
local ownEmoteData = nil
local emoteTrack = nil
local emoteConn = nil
local emoteLoop = nil
local emoteStopOnMove = true
local emoteSpeed = 1
local emoteHum = nil
local emoteMirrorConn = nil
local setupEmoteSupport = nil
local stopEmoteSupport = nil
local savedLeg = nil
local ours = {}
local copying = false
local autoApply = true
local AutoApplyToggle = nil
local reapplyBusy = false
local reapplyTimes = {}
local MAX_REAPPLY = 3
local REAPPLY_WINDOW = 60
local customName = nil
local prevCustomName = nil
local trackedGuis = {}

local ACCESSORIES = {}
local accOn = {}
local accSettings = {}
local accRT = {}
local accByKey = {}

-- override dari tab Shirt / Body / Animasi (dipasang ke HumanoidDescription sebelum clone dibuat)
local OV = {}
local function descHook(d)
    for k, v in pairs(OV) do
        pcall(function() d[k] = v end)
    end
    return d
end

-- fitur Headless/Korblox milik KingAgoy tidak dipakai di A197
local function restoreToggleEffects() end
local function turnOffToggles() end


-- >>> GameRoot
-- ===== PENJAGA DATA GAME DI HumanoidRootPart (mis. "headpos" milik Evade) =====
-- Script map Evade membaca HumanoidRootPart.headpos tiap frame. Model avatar hasil copy
-- tidak punya itu, jadi error terus-menerus. Penjaga ini jalan tiap frame:
--   * karakter asli: ingat Attachment/Value/Folder yang ada di HumanoidRootPart-nya
--   * model hasil copy: kalau ada yang hilang, pasang lagi (dan "headpos" selalu dijamin ada)
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

-- >>> Target
-- ===== TARGET =====
local function getUserId(target)
    -- link profil: https://www.roblox.com/users/123456/profile
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

-- >>> Cam+Nametag
-- ===== COPY AVATAR (tukar karakter dengan model avatar target) =====
local function setCamera(model)
    local cam = workspace.CurrentCamera
    local hum = model and model:FindFirstChildOfClass("Humanoid")
    if cam and hum then
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = hum
    end
end

-- ===== NAMETAG BILLBOARDGUI MILIK GAME =====
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

-- Semua BillboardGui di sebuah karakter + yang sudah kita pantau
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

-- Ganti nama aslimu di teks nametag dengan display name palsu
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

-- Kembalikan teks nametag dari display name palsu ke display name asli
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

-- Nametag buatan game menempel di karakter asli (yang kita sembunyikan).
-- Salin ke model avatar baru supaya nametag tetap muncul di atas kepala.
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

-- Nametag yang disimpan di tempat lain (workspace/PlayerGui) tapi menempel
-- ke karakter asli lewat Adornee: arahkan ke model avatar baru.
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

    -- cara nama/darah ditampilkan (game yang pakai nametag sendiri biasanya mematikan bawaan Roblox)
    pcall(function()
        to.DisplayDistanceType = from.DisplayDistanceType
        to.NameDisplayDistance = from.NameDisplayDistance
        to.HealthDisplayType = from.HealthDisplayType
        to.HealthDisplayDistance = from.HealthDisplayDistance
    end)
end

-- >>> Targets
-- ===== TARGET TAMPILAN KARAKTER =====
-- Beberapa game (mis. Evade) menaruh karakter di folder khusus (workspace.Game.Players)
-- atau memakai model tampilan terpisah dari player.Character. Supaya Headless, Korblox,
-- aksesoris, dan Copy Avatar tetap kena, efeknya dipasang ke SEMUA model milik kita:
--   1) player.Character
--   2) model yang sedang diikuti kamera (kalau dekat dengan karakter kita)
--   3) model bernama sama dengan username/display name kita di workspace (sampai 3 tingkat folder)
local extraTargets = {}
local lastTargetScan = -10
local pinnedTarget = nil -- model tampilan yang ditemukan lewat fallback Humanoid (copy avatar)

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

    -- model yang diikuti kamera, hanya kalau posisinya dekat karakter kita
    -- (supaya tidak ikut mengubah pemain lain saat spectate)
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
                -- player.Character kosong (game yang menaruh karakter di tempat lain):
                -- percaya model kamera selama bukan milik pemain lain
                local owner = Players:GetPlayerFromCharacter(m)
                if owner == nil or owner == player then
                    consider(m)
                end
            end
        end
    end

    -- model bernama sama dengan kita (cari di workspace & folder-foldernya)
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

-- >>> Anim
-- ===== ANIMASI (dikontrol script sendiri, tanpa script Animate) =====
-- ID bawaan Roblox (dipakai kalau animasi target/game tidak bisa dimuat)
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

-- name: nama internal | field: properti di HumanoidDescription (hanya R15)
-- folder/anim: lokasi Animation di script Animate milik game (cadangan)
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

-- Asset animasi di avatar bukan animasi langsung, tapi paket berisi objek Animation
-- (seperti struktur script Animate). ID animasi aslinya ada di dalam paket itu.
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
        warn("[KingAgoy] Gagal membaca asset animasi " .. tostring(assetId) .. " (GetObjects/LoadAsset tidak tersedia di executor ini)")
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

    -- 1) animasi milik avatar target
    if isR15 and info.field then
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

    -- 2) animasi dari script Animate karakter asli (animasi game)
    if srcAnimate then
        local folder = srcAnimate:FindFirstChild(info.folder)
        local anim = folder and folder:FindFirstChild(info.anim)
        if anim and anim:IsA("Animation") then
            add(anim.AnimationId, "animasi game")
        end
    end

    -- 3) animasi bawaan Roblox
    add(defaults[info.name], "bawaan Roblox")

    return list
end

-- Coba tiap kandidat sampai ada yang benar-benar termuat (Length > 0)
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

-- Ambang kecepatan (studs/detik) untuk animasi lari.
-- Jalan biasa Roblox = 16. Lari dipakai kalau kecepatan di atas RUN_SPEED_ENTER
-- dan kembali ke jalan kalau turun di bawah RUN_SPEED_EXIT.
-- Kalau di game-mu lari terlalu cepat/lambat berubah, ubah dua angka ini.
local RUN_SPEED_ENTER = 20
local RUN_SPEED_EXIT = 17
local WALK_ANIM_BASE = 16 -- kecepatan di mana animasi jalan diputar normal (1x)
local RUN_ANIM_BASE = 24  -- kecepatan di mana animasi lari diputar normal (1x)

-- Pemutar animasi: meniru logika script Animate bawaan Roblox
-- (kecepatan dari event Humanoid.Running, jeda sebelum animasi jatuh,
-- hysteresis idle/walk, dan kecepatan animasi dihaluskan supaya tidak patah-patah)
local animGen = 0
local function startAnimDriver(model, hum, root, tracks)
    animGen = animGen + 1
    local myGen = animGen
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
        if not running or myGen ~= animGen or model.Parent == nil or hum.Parent ~= model then
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
            -- animasi jatuh baru dimulai setelah 0.2 detik (hindari kedip di tanah tidak rata)
            play("fall", 1)
        else
            -- di tanah, atau melayang sebentar (< 0.2 detik)
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
                    warn("[KingAgoy] Animasi run tidak termuat, memakai animasi walk")
                end

                local mode = "walk"
                local target = speed / WALK_ANIM_BASE
                if useRun and tracks.run then
                    mode = "run"
                    target = speed / RUN_ANIM_BASE
                end

                -- ganti walk <-> run: langsung ke kecepatan baru, lalu haluskan
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
        log("Animasi di avatar target -> idle=" .. tostring(desc.IdleAnimation)
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
            warn("[KingAgoy] Animasi " .. info.name .. " gagal dimuat")
        end
    end

    log("Semua animasi selesai diproses")
end

-- >>> Copy
-- ===== COPY AVATAR (tukar karakter dengan model avatar target) =====
-- Tipe rig (R6/R15) dibaca dari bentuk badan kalau Humanoid tidak ditemukan
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

-- Cari karakter sumber + Humanoid-nya. Urutan: player.Character, Humanoid yang diikuti kamera,
-- model bernama sama dengan kita (mis. di workspace.Game.Players milik Evade), lalu model
-- tanpa Humanoid yang tipe rig-nya dibaca dari bentuk badan.
-- Return: model, humanoid (boleh nil), rigType
local function findSourceCharacter()
    local mine = player.Character

    -- 1) player.Character (Humanoid langsung atau lebih dalam)
    if mine then
        local hum = mine:FindFirstChildOfClass("Humanoid") or mine:FindFirstChildWhichIsA("Humanoid", true)
        if hum then
            return mine, hum, hum.RigType
        end
    end

    -- 2) Humanoid yang diikuti kamera (bukan milik pemain lain)
    local cam = workspace.CurrentCamera
    local subject = cam and cam.CameraSubject
    if subject and subject:IsA("Humanoid") and subject.Parent then
        local owner = Players:GetPlayerFromCharacter(subject.Parent)
        if owner == nil or owner == player then
            return subject.Parent, subject, subject.RigType
        end
    end

    -- 3) model bernama sama dengan kita
    pcall(scanExtraTargets)
    for _, t in ipairs(extraTargets) do
        local hum = t:FindFirstChildOfClass("Humanoid") or t:FindFirstChildWhichIsA("Humanoid", true)
        if hum then
            return t, hum, hum.RigType
        end
    end

    -- 4) tanpa Humanoid: tipe rig dari bentuk badan
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

-- Emote akun sendiri (diambil sekali lalu disimpan)
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

-- Game seperti Evade menaruh data buatan sendiri di karakter asli (mis. Attachment/Value
-- "headpos" di HumanoidRootPart yang dibaca script map untuk cek air & soundscape).
-- Model avatar baru tidak punya itu, jadi script map error. Di sini semua Attachment,
-- Value, Folder, Configuration, dan Attribute milik game disalin ke model baru.
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

    -- laporan: isi karakter asli (supaya kelihatan apa saja yang dicari script map)
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

    -- cadangan: Evade membaca "headpos" di HumanoidRootPart (cek air / soundscape).
    -- Kalau setelah semua disalin masih belum ada, buat Attachment di posisi kepala.
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

local function copyAvatarInner(userId, builder)
    -- Di lobby game (mis. Evade) player.Character = nil dan game memakai rig terpisah.
    -- Mengisi player.Character di sini membuat script map error terus & UI game ter-reset.
    if not player.Character then
        return false, "Belum ada karakter game (lobby). Masuk ke round dulu, atau pakai rig lobby (R6/R15 di tempat)"
    end
    local found, srcHum, rigType
    if real then
        -- sudah pernah di-copy: karakter asli yang disimpan jadi acuan
        local h = real:FindFirstChildOfClass("Humanoid") or real:FindFirstChildWhichIsA("Humanoid", true)
        if h then
            found, srcHum, rigType = real, h, h.RigType
        end
    end
    if not found then
        found, srcHum, rigType = findSourceCharacter()
    end

    local current = found
    if real and player.Character then
        current = player.Character -- model yang sedang dipakai (posisi terbarunya jadi acuan)
    end
    local source = real or current
    if not current or not rigType then
        return false, "Karakter/Humanoid tidak ditemukan"
    end
    if srcHum and srcHum.Health <= 0 then
        return false, "Karakter sedang mati, tunggu respawn"
    end

    local desc, descErr = getDescription(userId)
    if desc then desc = descHook(desc) end
    if not desc then
        return false, "Gagal ambil data avatar: " .. tostring(descErr)
    end

    local isR15 = rigType == Enum.HumanoidRigType.R15

    -- R15: model baru dibuat dengan EMOTE MILIKMU (bukan emote target), supaya menu emote
    -- Roblox / emote yang kamu punya tetap bisa dipakai setelah copy
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

    -- Roblox membuat model avatar lengkap (body, rambut, aksesori, pakaian, skala)
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
            warn("[KingAgoy] Gagal menyalin data game: " .. tostring(listT))
        end
    end
    pcall(function()
        model:PivotTo(current:GetPivot() * CFrame.new(0, 2, 0))
    end)

    -- bersihkan efek toggle di karakter asli sebelum disembunyikan
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

    -- sembunyikan karakter asli (hanya di sisi kita, server tidak berubah)
    if real and real.Parent ~= nil then
        real.Parent = nil
    end
    if oldFake then
        oldFake:Destroy()
    end

    -- animasi: dikontrol script ini sendiri (tidak memakai script Animate)
    task.spawn(function()
        setupAnimations(model, newHum, newRoot, desc, source, isR15)
    end)

    -- emote (R15): menu emote Roblox + emote milik map ikut jalan di model baru
    if isR15 and setupEmoteSupport then
        pcall(setupEmoteSupport, model, newHum, source)
    end

    -- nametag buatan game (BillboardGui): salin/arahkan ke model baru
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

local function copyAvatar(userId, builder)
    if copying then
        return false, "Copy sedang berjalan, tunggu sebentar"
    end

    copying = true
    local ok, a, b = pcall(copyAvatarInner, userId, builder)
    copying = false

    if not ok then
        return false, "Error: " .. tostring(a)
    end
    return a, b
end

-- >>> InPlace
-- ===== COPY AVATAR R6 "DI TEMPAT" (karakter & isi map TIDAK diganti) =====
-- Karakter asli tetap dipakai, jadi Tool (mis. alat pancing), script Animate, animasi map,
-- dan semua yang tersambung ke karakter tetap utuh. Yang diubah hanya TAMPILAN:
-- Accessory, Shirt/Pants/ShirtGraphic, CharacterMesh, BodyColors, wajah, bentuk kepala, warna part.
-- Tampilan asli dicadangkan dulu supaya bisa dikembalikan lewat Reset.
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
        return -- karakter sudah hilang, tidak ada yang perlu dikembalikan
    end

    local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true)

    -- buang hasil copy
    for _, c in ipairs(model:GetChildren()) do
        if c:GetAttribute("KA_Copy") then
            c:Destroy()
        end
    end
    local head = model:FindFirstChild("Head")
    -- buang titik sambung (Attachment) / mesh / decal hasil copy di semua part badan
    for _, p in ipairs(model:GetChildren()) do
        if p:IsA("BasePart") then
            for _, c in ipairs(p:GetChildren()) do
                if c:GetAttribute("KA_Copy") then
                    c:Destroy()
                end
            end
        end
    end

    -- kembalikan badan R15 (mesh, ukuran, warna, sambungan)
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

    -- kembalikan tampilan asli
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
        pcall(restoreInPlace, model)
        any = true
    end
    inPlaceBackup = {}
    inPlaceUserId = nil
    return any
end

-- Pasang 1 aksesoris ke karakter: cari pasangan Attachment (HairAttachment, HatAttachment, dll)
-- lalu pastikan ada Weld yang benar ke part karakter kita (bukan ke model referensi).
local function attachAccessoryInPlace(model, acc)
    local handle = acc:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        acc.Parent = model
        return
    end

    -- weld lama menunjuk ke model referensi: buang
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

    -- cari pasangan attachment: attachment di Handle + attachment bernama sama di part karakter
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
    task.wait() -- beri kesempatan engine membuat weld sendiri

    -- sudah ada weld yang benar (ke part karakter kita)?
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
        -- cadangan: puncak kepala
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

-- R15 di tempat: salin mesh/texture/warna/ukuran tiap part badan, Motor6D (proporsi) dan
-- Attachment dari model referensi ke model yang ada. Nilai asli dicadangkan di rec.r15.
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

local function applyAppearanceInPlace(model, userId)
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

    local desc, descErr = getDescription(userId)
    if desc then desc = descHook(desc) end
    if not desc then
        return false, "Gagal ambil data avatar: " .. tostring(descErr)
    end

    -- model referensi (tidak ditaruh di workspace, hanya dibaca lalu dibuang)
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

    -- bersihkan copy sebelumnya + efek Headless/Korblox supaya cadangan bersih
    pcall(restoreInPlace, model)
    pcall(restoreToggleEffects, model)

    local rec = {items = {}, colors = {}, headMesh = nil, face = nil}
    inPlaceBackup[model] = rec

    -- 1) pindahkan tampilan lama ke cadangan (Tool & script TIDAK disentuh)
    for _, c in ipairs(model:GetChildren()) do
        if isAppearanceItem(c) and not c:GetAttribute("KA_Copy") then
            table.insert(rec.items, c)
            c.Parent = nil
        end
    end

    -- 1b) titik sambung aksesoris (HairAttachment, HatAttachment, dll) yang belum ada di karakter map
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

    -- 2) salin pakaian, warna kulit, CharacterMesh, dan aksesoris dari target
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

    -- 3) kepala: bentuk + wajah
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

    -- 4) warna tiap part badan
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

-- >>> R15
-- ===== COPY AVATAR R15 (method berbeda: bangun body per slot + paksa warna) =====
-- Beda dengan method biasa yang cuma 1x CreateHumanoidModelFromDescription:
--   1) bikin model R15 dengan AssetTypeVerification.Always
--   2) tiap slot body (Head/Torso/Arm/Leg) dicek ulang lewat model mini berisi slot itu saja;
--      kalau MeshId / SurfaceAppearance di model utama beda, diganti pakai hasil model mini
--   3) warna kulit tiap bagian dipaksa sama dengan HumanoidDescription target
--   4) hasil akhir dibandingkan dengan GetAppliedDescription dan selisihnya dicetak ke console
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
    -- rig bukan R15: pakai method biasa
    if rigType ~= Enum.HumanoidRigType.R15 then
        return Players:CreateHumanoidModelFromDescription(desc, rigType)
    end

    -- 1) model utama
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

    -- 2) cek ulang tiap slot body lewat model mini
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

                        -- SurfaceAppearance (tekstur body bundle Rthro/dll)
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
                warn("[KingAgoy] R15 slot " .. slot.prop .. " gagal dicek: " .. tostring(ref))
            end
        end
    end

    -- 3) paksa warna kulit
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

    -- 4) bandingkan dengan GetAppliedDescription (hanya laporan ke console)
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

-- >>> Acc
local function statusName(status)
    if status == nil then
        return "tidak diketahui"
    end
    local ok, name = pcall(function()
        return status.Name
    end)
    if ok and name then
        return tostring(name)
    end
    return tostring(status)
end

local function statusOk(status)
    return status == nil or statusName(status) == "Success"
end

local function fetchStatus(inst, contentId)
    pcall(function()
        ContentProvider:PreloadAsync({inst})
    end)
    local ok, status = pcall(function()
        return ContentProvider:GetAssetFetchStatus(contentId)
    end)
    if ok then
        return status
    end
    return nil
end

-- Kalau ID yang diberikan ternyata ID item/aksesoris (bukan mesh), baca isinya
local function extractFromAsset(assetId)
    local ok, objs = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if not ok or type(objs) ~= "table" then
        return nil, nil
    end

    local meshId = nil
    local texId = nil
    for _, obj in ipairs(objs) do
        local list = obj:GetDescendants()
        table.insert(list, obj)
        for _, d in ipairs(list) do
            if not meshId then
                if d:IsA("MeshPart") then
                    meshId = d.MeshId
                    texId = d.TextureID
                elseif d:IsA("SpecialMesh") then
                    meshId = d.MeshId
                    texId = d.TextureId
                end
            end
        end
        pcall(function()
            obj:Destroy()
        end)
    end
    return meshId, texId
end

-- Ringkasan efek (partikel, cahaya, suara, dll) di dalam sebuah objek
local function summarizeEffects(root)
    local counts = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Sparkles") or d:IsA("Fire") or d:IsA("Smoke")
        or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Light") or d:IsA("Sound") then
            counts[d.ClassName] = (counts[d.ClassName] or 0) + 1
        end
    end

    local parts = {}
    for name, n in pairs(counts) do
        table.insert(parts, name .. " x" .. tostring(n))
    end
    if #parts == 0 then
        return "tidak ada efek"
    end
    return table.concat(parts, ", ")
end

-- Baca aksesoris asli dari asset (lengkap dengan efeknya)
-- Muat asset: GetObjects dulu, kalau gagal pakai InsertService:LoadAsset
local function loadAssetObjects(assetId)
    local ok, objs = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if ok and type(objs) == "table" and #objs > 0 then
        return true, objs
    end

    local ok2, model = pcall(function()
        return game:GetService("InsertService"):LoadAsset(assetId)
    end)
    if ok2 and model then
        return true, {model}
    end
    return false, objs
end

local function loadAccTemplate(def)
    local ok, objs = loadAssetObjects(def.assetId)
    if not ok or type(objs) ~= "table" then
        warn("[KingAgoy] Gagal membaca asset " .. def.label .. " (" .. tostring(def.assetId)
            .. ") lewat GetObjects: " .. tostring(objs))
        return nil
    end

    local found = nil
    for _, obj in ipairs(objs) do
        if not found then
            if obj:IsA("Accessory") then
                found = obj
            else
                found = obj:FindFirstChildWhichIsA("Accessory", true)
            end
        end
    end

    if not found then
        for _, obj in ipairs(objs) do
            if not found then
                local h = obj:FindFirstChild("Handle", true)
                if h and h:IsA("BasePart") then
                    found = h.Parent
                end
            end
        end
    end

    if not found then
        warn("[KingAgoy] Asset " .. def.label .. " tidak berisi aksesoris dengan Handle")
        return nil
    end

    if found:FindFirstChildWhichIsA("WrapLayer", true) then
        warn("[A197] " .. def.label .. " = layered clothing, tidak didukung")
        return nil
    end

    -- aksesoris avatar tidak butuh script: buang demi keamanan
    for _, d in ipairs(found:GetDescendants()) do
        if d:IsA("LuaSourceContainer") then
            d:Destroy()
        end
    end

    found.Parent = nil
    local handle = found:FindFirstChild("Handle")
    log(def.label .. ": aksesoris asli dibaca dari asset " .. tostring(def.assetId)
        .. " | Handle=" .. (handle and handle.ClassName or "tidak ada")
        .. " | efek: " .. summarizeEffects(found))
    return found
end

local function resolveAccAssets(def)
    local rt = accRT[def.key]
    if rt.assets or rt.resolving then
        return
    end
    rt.resolving = true

    local mesh = def.mesh
    local texture = def.texture

    -- 1) aksesoris asli (dengan efek)
    rt.triedAt = os.clock()
    rt.template = loadAccTemplate(def)
    if rt.template then
        rt.assets = {mesh = mesh, texture = texture}
        rt.resolving = false
        return
    end

    if not def.mesh or def.mesh == "" then
        rt.assets = {mesh = "", texture = ""}
        rt.failed = true
        rt.resolving = false
        accOn[def.key] = false
        notify("Aksesoris", "Gagal memuat " .. tostring(def.label))
        return
    end

    -- 2) cadangan: cek mesh + texture
    local test = Instance.new("SpecialMesh")
    test.MeshType = Enum.MeshType.FileMesh
    test.MeshId = mesh
    test.TextureId = texture
    local meshStatus = fetchStatus(test, mesh)
    local texStatus = fetchStatus(test, texture)
    test:Destroy()

    log(def.label .. " (cadangan): status mesh=" .. statusName(meshStatus) .. ", texture=" .. statusName(texStatus))

    if not statusOk(meshStatus) then
        local idOnly = string.match(def.mesh, "(%d+)")
        local m, t = extractFromAsset(idOnly)
        if m and m ~= "" then
            mesh = m
            if t and t ~= "" then
                texture = t
            end
            log(def.label .. ": ID dibaca dari isi asset -> " .. tostring(mesh) .. " | " .. tostring(texture))
        else
            warn("[KingAgoy] Mesh " .. def.label .. " gagal dimuat (status " .. statusName(meshStatus)
                .. "). ID mungkin salah atau tidak bisa dimuat di game ini.")
        end
    elseif not statusOk(texStatus) then
        warn("[KingAgoy] Texture " .. def.label .. " gagal dimuat (status " .. statusName(texStatus) .. ")")
    end

    rt.assets = {mesh = mesh, texture = texture}
    rt.resolving = false
end

local function currentAccAssets(def)
    local rt = accRT[def.key]
    if rt.assets then
        return rt.assets
    end
    return {mesh = def.mesh, texture = def.texture}
end

-- Bagian badan tempat aksesoris menempel: kepala (default) atau torso (slot shoulder)
local function getAccBase(character, def)
    if def and def.slot == "shoulder" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    local rt = def and accRT[def.key]
    local tpl = rt and rt.template
    local handle = tpl and tpl:FindFirstChild("Handle")
    if handle then
        local list = {}
        local hat = handle:FindFirstChild("HatAttachment")
        if hat and hat:IsA("Attachment") then
            table.insert(list, hat)
        end
        for _, a in ipairs(handle:GetChildren()) do
            if a:IsA("Attachment") and a ~= hat then
                table.insert(list, a)
            end
        end
        for _, a in ipairs(list) do
            for _, p in ipairs(character:GetChildren()) do
                if p:IsA("BasePart") then
                    local x = p:FindFirstChild(a.Name)
                    if x and x:IsA("Attachment") then
                        return p
                    end
                end
            end
        end
    end
    return character:FindFirstChild("Head")
end

-- Titik sambung: pakai attachment yang namanya sama di Handle dan di bagian badan
-- (HatAttachment dulu untuk kepala), seperti cara Roblox memasang aksesoris.
-- Slot "shoulder" memakai LeftShoulderAttachment (pundak kiri avatar).
local function accAlignment(head, handle, def)
    if def and def.slot == "shoulder" then
        local att = handle:FindFirstChild("LeftShoulderAttachment")
        if att and att:IsA("Attachment") then
            local baseAtt = head:FindFirstChild("LeftShoulderAttachment")
            if baseAtt and baseAtt:IsA("Attachment") then
                return baseAtt.CFrame, att.CFrame
            end
        end
        -- cadangan: pojok kiri atas torso (kiri avatar = sisi -X)
        local sz = head.Size
        local handleCF = CFrame.new()
        if att and att:IsA("Attachment") then
            handleCF = att.CFrame
        end
        return CFrame.new(-sz.X / 2, sz.Y / 2 - 0.2, 0), handleCF
    end

    local order = {}
    local hatAtt = handle:FindFirstChild("HatAttachment")
    if hatAtt and hatAtt:IsA("Attachment") then
        table.insert(order, hatAtt)
    end
    for _, a in ipairs(handle:GetChildren()) do
        if a:IsA("Attachment") and a ~= hatAtt then
            table.insert(order, a)
        end
    end

    for _, a in ipairs(order) do
        local headAtt = head:FindFirstChild(a.Name)
        if headAtt and headAtt:IsA("Attachment") then
            return headAtt.CFrame, a.CFrame
        end
    end

    -- cadangan: puncak kepala
    local headCF = CFrame.new(0, head.Size.Y / 2, 0)
    local hat = head:FindFirstChild("HatAttachment")
    if hat and hat:IsA("Attachment") then
        headCF = hat.CFrame
    end
    return headCF, CFrame.new()
end

-- Simpan ukuran asli Handle supaya slider ukuran bisa dihitung dari situ
local function prepareHandle(handle)
    if handle:IsA("MeshPart") then
        if typeof(handle:GetAttribute("KA_OrigSize")) ~= "Vector3" then
            handle:SetAttribute("KA_OrigSize", handle.Size)
        end
    else
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and typeof(mesh:GetAttribute("KA_OrigScale")) ~= "Vector3" then
            mesh:SetAttribute("KA_OrigScale", mesh.Scale)
        end
    end
end

local function applyAccScale(handle, scale)
    if handle:IsA("MeshPart") then
        local orig = handle:GetAttribute("KA_OrigSize")
        if typeof(orig) == "Vector3" then
            local sz = orig * scale
            if handle.Size ~= sz then
                handle.Size = sz
            end
        end
    else
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            local orig = mesh:GetAttribute("KA_OrigScale")
            if typeof(orig) ~= "Vector3" then
                orig = Vector3.new(1, 1, 1)
            end
            local sc = orig * scale
            if mesh.Scale ~= sc then
                mesh.Scale = sc
            end
        end
    end
end

local function updateAcc(character, container, def)
    local head = getAccBase(character, def)
    local handle = container:FindFirstChild("Handle")
    if not head or not handle then
        return
    end

    local s = accSettings[def.key]

    local weld = handle:FindFirstChild("KA_AccWeld")
    if weld and weld:IsA("Weld") then
        if weld.Part0 ~= head then
            weld.Part0 = head
        end
        local headCF, handleCF = accAlignment(head, handle, def)
        local c0 = headCF * CFrame.new(0, s.height, -s.forward)
        if weld.C0 ~= c0 then
            weld.C0 = c0
        end
        if weld.C1 ~= handleCF then
            weld.C1 = handleCF
        end
    end

    applyAccScale(handle, s.scale)

    -- cara cadangan: ikuti ID mesh/texture terbaru
    if container:GetAttribute("KA_Source") == "fallback" then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            local assets = currentAccAssets(def)
            if mesh.MeshId ~= assets.mesh then
                mesh.MeshId = assets.mesh
            end
            if mesh.TextureId ~= assets.texture then
                mesh.TextureId = assets.texture
            end
        end
    end
end

-- Salinan aksesoris asli (lengkap dengan efek)
local function buildTemplateContainer(def)
    local template = accRT[def.key].template
    if not template then
        return nil
    end

    local clone = template:Clone()
    local handle = clone:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        clone:Destroy()
        return nil
    end

    local container = Instance.new("Model")
    container.Name = def.name
    for _, child in ipairs(clone:GetChildren()) do
        child.Parent = container
    end
    clone:Destroy()

    container:SetAttribute("KA_Source", "template")
    return container
end

-- Cadangan: Part + SpecialMesh biasa
local function buildFallbackContainer(def)
    local assets = currentAccAssets(def)

    local container = Instance.new("Model")
    container.Name = def.name

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Parent = container

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = assets.mesh
    mesh.TextureId = assets.texture
    mesh.Parent = handle

    container:SetAttribute("KA_Source", "fallback")
    return container
end

local function createAcc(character, def)
    local head = getAccBase(character, def)
    if not head then
        return
    end

    local container = buildTemplateContainer(def)
    if not container and def.mesh and def.mesh ~= "" then
        container = buildFallbackContainer(def)
    end
    if not container then
        return
    end

    local handle = container:FindFirstChild("Handle")
    if not handle then
        container:Destroy()
        return
    end

    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then
            d.CanCollide = false
            d.CanTouch = false
            d.CanQuery = false
            d.Massless = true
            d.Anchored = false
        elseif d.Name == "AccessoryWeld" then
            d:Destroy()
        end
    end

    local s = accSettings[def.key]

    prepareHandle(handle)
    applyAccScale(handle, s.scale)

    local headCF, handleCF = accAlignment(head, handle, def)
    local weld = Instance.new("Weld")
    weld.Name = "KA_AccWeld"
    weld.Part0 = head
    weld.Part1 = handle
    weld.C0 = headCF * CFrame.new(0, s.height, -s.forward)
    weld.C1 = handleCF
    weld.Parent = handle

    handle.CFrame = head.CFrame * weld.C0 * weld.C1:Inverse()
    container.Parent = character

    local rt = accRT[def.key]
    rt.createCount = rt.createCount + 1
    if rt.createCount <= 5 then
        log(def.label .. " dipasang (" .. tostring(container:GetAttribute("KA_Source")) .. ") di "
            .. character.Name .. " | posisi " .. tostring(handle.Position))
    end
end

local function ensureAcc(character, def)
    local rt = accRT[def.key]

    -- baca aksesoris asli dulu (di latar belakang), maksimal ditunggu 6 detik
    if not rt.assets then
        if not rt.resolving then
            rt.started = os.clock()
            task.spawn(function()
                local okR, errR = pcall(resolveAccAssets, def)
                if not okR then
                    warn("[KingAgoy] resolve " .. def.label .. " error: " .. tostring(errR))
                    rt.resolving = false
                    rt.assets = rt.assets or {mesh = def.mesh, texture = def.texture}
                end
            end)
        end
        if os.clock() - rt.started < 6 then
            return
        end
    end

    -- template asli gagal dibaca tadi (mis. jaringan/asset lambat): coba lagi tiap 10 detik
    if rt.assets and not rt.template and not rt.resolving and not rt.failed and os.clock() - (rt.triedAt or 0) > 10 then
        rt.triedAt = os.clock()
        rt.resolving = true
        task.spawn(function()
            local okT, t = pcall(loadAccTemplate, def)
            if okT and t then
                rt.template = t
            end
            rt.resolving = false
        end)
    end

    local container = character:FindFirstChild(def.name)
    if container then
        -- kalau aksesoris asli baru siap, ganti cara cadangan dengan yang asli
        local isTemplate = container:GetAttribute("KA_Source") == "template"
        if isTemplate ~= (rt.template ~= nil) then
            container:Destroy()
            container = nil
        end
    end

    if container then
        updateAcc(character, container, def)
    else
        createAcc(character, def)
    end
end

-- Jalankan ensureAcc dan tampilkan error (tidak disembunyikan)
local function runAcc(character, def)
    local ok, err = pcall(ensureAcc, character, def)
    local rt = accRT[def.key]
    if not ok and tostring(err) ~= rt.lastErr then
        rt.lastErr = tostring(err)
        warn("[KingAgoy] " .. def.label .. " error: " .. rt.lastErr)
        notify(def.label .. " error", rt.lastErr)
    end
end

local function removeAcc(character, def)
    if not character then
        return
    end
    local container = character:FindFirstChild(def.name)
    if container then
        container:Destroy()
    end
end

local function removeAccEverywhere(def)
    pcall(removeAcc, player.Character, def)
    pcall(removeAcc, real, def)
    pcall(removeAcc, fake, def)
    for _, t in ipairs(visualTargets()) do
        pcall(removeAcc, t, def)
    end
end

local function removeAllAccessories()
    for _, def in ipairs(ACCESSORIES) do
        accOn[def.key] = false
        removeAccEverywhere(def)
    end
end

-- >>> Emote
-- ===== EMOTE (bisa emote apa pun: nama, asset id, atau link katalog) =====
-- Input yang diterima:
--   1) nama emote yang dipakai avatar target terakhir (mis. "Dance")
--   2) nama bawaan: wave, point, cheer, laugh, dance, dance2, dance3
--   3) angka asset id (emote katalog maupun id animasi langsung)
--   4) link katalog: https://www.roblox.com/catalog/123456/...
-- Emote katalog adalah paket berisi objek Animation, jadi id animasi aslinya dibaca dari dalam asset.
local EMOTE_PRESETS = {
    wave = 507770239,
    point = 507770453,
    cheer = 507770677,
    laugh = 507770818,
    dance = 507771019,
    dance2 = 507776043,
    dance3 = 507777268,
}

local function resolveEmoteId(text)
    text = string.match(tostring(text or ""), "^%s*(.-)%s*$")
    if text == nil or text == "" then
        return nil
    end
    local lower = text:lower()

    for name, ids in pairs(lastEmotes) do
        if tostring(name):lower() == lower then
            local id = type(ids) == "table" and ids[1] or ids
            if tonumber(id) then
                return tonumber(id), "emote target: " .. tostring(name)
            end
        end
    end

    if EMOTE_PRESETS[lower] then
        return EMOTE_PRESETS[lower], "bawaan: " .. lower
    end

    local n = tonumber(string.match(text, "catalog/(%d+)"))
        or tonumber(string.match(text, "library/(%d+)"))
        or tonumber(string.match(text, "^rbxassetid://(%d+)$"))
        or tonumber(text)
    if n then
        return n, "id " .. tostring(n)
    end
    return nil
end

local function stopEmote()
    if emoteConn then
        pcall(function()
            emoteConn:Disconnect()
        end)
        emoteConn = nil
    end
    if emoteTrack then
        local t = emoteTrack
        emoteTrack = nil
        pcall(function()
            t:Stop(0.2)
        end)
    end
end

local function playEmote(text)
    local model = player.Character
    local hum = model and (model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true))
    if not hum then
        return false, "Humanoid tidak ditemukan"
    end
    if hum.Health <= 0 then
        return false, "Karakter sedang mati"
    end

    local id, label = resolveEmoteId(text)
    if not id then
        return false, "Emote tidak dikenali (pakai nama, asset id, atau link katalog)"
    end

    stopEmote()

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    -- kandidat: isi asset (id animasi asli) dulu, lalu id langsung
    local candidates = {}
    local seen = {}
    local function add(aid, lbl)
        if aid and aid ~= "" and not seen[aid] then
            seen[aid] = true
            table.insert(candidates, {id = aid, label = lbl})
        end
    end
    for _, a in ipairs(readAnimationAsset(id)) do
        add(a.id, "isi asset " .. tostring(id) .. " (" .. tostring(a.name) .. ")")
    end
    add("rbxassetid://" .. tostring(id), "langsung")

    local track, usedId, usedLabel = loadTrack(animator, candidates)
    if not track then
        return false, "Emote gagal dimuat (asset bukan animasi / tidak bisa dimuat di game ini)"
    end

    if emoteLoop ~= nil then
        track.Looped = emoteLoop
    end
    pcall(function()
        track.Priority = Enum.AnimationPriority.Action4 -- di atas animasi game & animasi jalan/idle
    end)
    track:Play(0.2)
    track:AdjustSpeed(emoteSpeed)
    emoteTrack = track
    log("Emote diputar [" .. tostring(label) .. " | " .. tostring(usedLabel) .. "]: " .. tostring(usedId))

    emoteConn = RunService.Heartbeat:Connect(function()
        if not running or player.Character ~= model or model.Parent == nil or hum.Health <= 0 then
            stopEmote()
            return
        end
        if emoteTrack ~= track or not track.IsPlaying then
            stopEmote()
            return
        end
        if emoteStopOnMove and hum.MoveDirection.Magnitude > 0.1 then
            stopEmote()
        end
    end)

    return true, "memutar emote (" .. tostring(label) .. ")"
end

-- Prioritas animasi yang dianggap emote (animasi jalan/idle bawaan game memakai Core/Idle/Movement)
local EMOTE_PRIORITIES = {
    [Enum.AnimationPriority.Action] = true,
    [Enum.AnimationPriority.Action2] = true,
    [Enum.AnimationPriority.Action3] = true,
    [Enum.AnimationPriority.Action4] = true,
}

-- Salin animasi emote yang diputar game pada karakter ASLI (yang disembunyikan)
-- ke model baru, supaya emote map (mis. Tanpa Nama) tetap kelihatan di karakter kita.
local function mirrorTrack(model, hum, track)
    if not running or hum.Parent ~= model then
        return
    end

    local okP, prio = pcall(function()
        return track.Priority
    end)
    if not okP or not EMOTE_PRIORITIES[prio] then
        return
    end

    local anim = track.Animation
    local animator = hum:FindFirstChildOfClass("Animator")
    if not anim or not animator then
        return
    end

    local okL, t = pcall(function()
        return animator:LoadAnimation(anim)
    end)
    if not okL or not t then
        return
    end

    pcall(function()
        t.Priority = prio
        t.Looped = track.Looped
    end)
    t:Play(0.1)
    pcall(function()
        t:AdjustSpeed(track.Speed)
    end)

    local stopConn = nil
    stopConn = track.Stopped:Connect(function()
        if stopConn then
            stopConn:Disconnect()
        end
        pcall(function()
            t:Stop(0.2)
        end)
    end)
end

stopEmoteSupport = function()
    if emoteMirrorConn then
        pcall(function()
            emoteMirrorConn:Disconnect()
        end)
        emoteMirrorConn = nil
    end
    emoteHum = nil
    stopEmote()
end

setupEmoteSupport = function(model, hum, realModel)
    stopEmoteSupport()
    emoteHum = hum

    -- 1) PlayEmote lewat BindableFunction "Animate.PlayEmote" (cara script Animate bawaan Roblox)
    if not model:FindFirstChild("Animate") then
        local folder = Instance.new("Folder")
        folder.Name = "Animate"
        local bf = Instance.new("BindableFunction")
        bf.Name = "PlayEmote"
        bf.OnInvoke = function(name)
            local ok = playEmote(name)
            return ok, emoteTrack
        end
        bf.Parent = folder
        folder.Parent = model
    end

    -- 2) emote milik map: animasi emote yang diputar pada karakter asli disalin ke model baru
    local realHum = realModel and (realModel:FindFirstChildOfClass("Humanoid")
        or realModel:FindFirstChildWhichIsA("Humanoid", true))
    local realAnimator = realHum and realHum:FindFirstChildOfClass("Animator")
    if realAnimator then
        emoteMirrorConn = realAnimator.AnimationPlayed:Connect(function(track)
            task.spawn(mirrorTrack, hum.Parent, hum, track)
        end)
    end

    log("Emote siap | emote milikmu: " .. tostring((function()
        local n = 0
        for _ in pairs(lastEmotes) do
            n = n + 1
        end
        return n
    end)()))
end

-- >>> Respawn
-- Respawn dari server: bersihkan hasil copy lama, lalu terapkan ulang otomatis
-- (dengan penjaga supaya tidak pernah looping)
local charConn = player.CharacterAdded:Connect(function(char)
    if not running then
        return
    end

    -- karakter buatan kita sendiri / karakter asli yang kita simpan: abaikan
    if ours[char] or char == fake or char == real then
        return
    end

    log("Karakter baru dari server: " .. tostring(char.Name))

    -- mode copy R6 di tempat: karakter baru dari server -> terapkan ulang tampilan di karakter itu
    if inPlaceUserId and not fake then
        inPlaceBackup = {} -- karakter lama sudah hilang, cadangannya tidak berlaku lagi

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

    -- batas anti-loop: maksimal MAX_REAPPLY kali dalam REAPPLY_WINDOW detik
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
        warn("[KingAgoy] Respawn berulang terdeteksi, Auto Apply dimatikan")
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

-- ===== COPY (isi sama dengan handleCopy KingAgoy, tanpa Rayfield) =====
local function copyUser(userId)
    turnOffToggles()
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
    if not ok then warn("[A197] Copy gagal: " .. tostring(info)) end
    return ok, info
end

-- ===== AKSESORIS: tambah / lepas satu per satu =====
local function accEnsureDef(id, name, assetType)
    local key = tostring(id)
    local def = accByKey[key]
    if not def then
        def = {
            key = key, label = name or key, name = "KA_" .. key,
            assetId = tonumber(id), slot = (assetType == 44) and "shoulder" or nil,
        }
        accByKey[key] = def
        table.insert(ACCESSORIES, def)
        accSettings[key] = {scale = 1, height = 0, forward = 0}
        accRT[key] = {template = nil, assets = nil, resolving = false, started = 0, createCount = 0, lastErr = nil}
    end
    return def
end

local function accAdd(id, name, assetType)
    local def = accEnsureDef(id, name, assetType)
    local rt = accRT[def.key]
    if not rt.template then
        rt.assets = nil
        rt.failed = nil
        rt.resolving = false
    end
    rt.lastErr = nil
    accOn[def.key] = true
end

local function accRemove(id)
    local def = accByKey[tostring(id)]
    if not def then return end
    accOn[def.key] = false
    removeAccEverywhere(def)
end

local function accIsOn(id)
    return accOn[tostring(id)] == true
end

local function accList()
    local out = {}
    for _, def in ipairs(ACCESSORIES) do
        if accOn[def.key] then table.insert(out, def) end
    end
    return out
end

-- ===== LOOP AKSESORIS (sama dengan loop KingAgoy, hanya bagian aksesoris) =====
task.spawn(function()
    while running do
        if os.clock() - lastTargetScan > 3 then
            lastTargetScan = os.clock()
            pcall(scanExtraTargets)
        end
        local any = false
        for _, def in ipairs(ACCESSORIES) do
            if accOn[def.key] then any = true break end
        end
        if any then
            for _, visual in ipairs(visualTargets()) do
                for _, def in ipairs(ACCESSORIES) do
                    if accOn[def.key] then runAcc(visual, def) end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- re-execute script -> engine lama berhenti
task.spawn(function()
    while running do
        if genv.A197_RUN ~= RUN_ID then
            running = false
            pcall(function() GameRoot.conn:Disconnect() end)
            break
        end
        task.wait(1)
    end
end)

return {
    copyUser = copyUser,
    getUserId = getUserId,
    resetAvatar = function()
        OV = {}
        return resetAvatar()
    end,
    isActive = function() return fake ~= nil or inPlaceUserId ~= nil end,
    currentTarget = function() return lastUserId or inPlaceUserId or player.UserId end,
    clearOverrides = function() OV = {} end,
    setOverride = function(k, v) OV[k] = v end,
    getOverride = function(k) return OV[k] end,
    setAuto = function(v) autoApply = v and true or false reapplyTimes = {} end,
    getAuto = function() return autoApply end,
    playEmote = playEmote,
    stopEmote = stopEmote,
    setEmoteStopOnMove = function(v) emoteStopOnMove = v and true or false end,
    getEmoteStopOnMove = function() return emoteStopOnMove end,
    accAdd = accAdd,
    accRemove = accRemove,
    accIsOn = accIsOn,
    accList = accList,
    accClear = removeAllAccessories,
}
end)()


------------------------------------------------------------------
-- Halaman
------------------------------------------------------------------
local pEmote = makePage("Emote")
local pAvatar = makePage("Avatar")
local pAcc = makePage("Aksesoris")
local pShirt = makePage("Shirt")
local pAnim = makePage("Animasi")
local pBody = makePage("Body")

-- jalankan ulang clone dengan override terbaru (Shirt / Body / Animasi)
local function recopy(okMsg)
    local uid = Clone.currentTarget()
    say("Menerapkan...")
    local ok, info = Clone.copyUser(uid)
    say(ok and (okMsg or "Terpasang (lokal)") or ("Gagal: " .. tostring(info)))
end

-- bundle -> HumanoidDescription (outfit) milik bundle itu
local function bundleDesc(bundleId)
    local raw, err = httpGet("https://catalog.roblox.com/v1/bundles/" .. bundleId .. "/details")
    if not raw then return nil, err end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(data) ~= "table" then return nil, "Respons bundle tidak valid" end
    local outfitId
    for _, it in ipairs(data.items or {}) do
        if it.type == "UserOutfit" then outfitId = it.id break end
    end
    if not outfitId then return nil, "Bundle tidak punya outfit" end
    local ok2, od = pcall(function() return Players:GetHumanoidDescriptionFromOutfitId(outfitId) end)
    if not ok2 or not od then return nil, "Gagal ambil data bundle" end
    return od
end

-- ---------------- Emote ----------------
local stopMoveBtn
local emoB = makeBrowser(pEmote, "Cari emote (nama) atau ID", {
    {label = "Emote", cat = 12, sub = 39, anyCreator = true, numType = "Asset"},
}, function(it)
    say("Memuat " .. tostring(it.name or it.id) .. "...")
    local ok, info = Clone.playEmote(tostring(it.id))
    say(ok and ("Emote: " .. tostring(it.name or it.id)) or ("Gagal: " .. tostring(info)))
end, function(page)
    btn(page, "Stop emote", function()
        Clone.stopEmote()
        say("Emote dihentikan")
    end)
    stopMoveBtn = btn(page, "Stop saat bergerak: ON", function()
        Clone.setEmoteStopOnMove(not Clone.getEmoteStopOnMove())
        stopMoveBtn.Text = "Stop saat bergerak: " .. (Clone.getEmoteStopOnMove() and "ON" or "OFF")
    end)
end, 3)
onShow["Emote"] = function() emoB.search("", false) end

-- ---------------- Avatar ----------------
local userBox = box(pAvatar, "Username / UserId / link profil")
btn(pAvatar, "Copy Avatar", function()
    local id = Clone.getUserId(trim(userBox.Text))
    if not id then return say("User tidak ditemukan") end
    say("Mengambil avatar " .. id .. "...")
    Clone.clearOverrides()
    local ok, info = Clone.copyUser(id)
    say(ok and ("Avatar " .. id .. ": " .. tostring(info)) or ("Gagal: " .. tostring(info)))
end)
local autoBtn
autoBtn = btn(pAvatar, "Auto Apply saat respawn: ON", function()
    Clone.setAuto(not Clone.getAuto())
    autoBtn.Text = "Auto Apply saat respawn: " .. (Clone.getAuto() and "ON" or "OFF")
end)
btn(pAvatar, "Reset Avatar (kembali asli)", function()
    local ok, info = Clone.resetAvatar()
    say(tostring(info))
end)

-- ---------------- Aksesoris (bisa ON/OFF satu per satu) ----------------
local accB
local wornFrame
local function refreshWorn()
    if not wornFrame then return end
    for _, ch in ipairs(wornFrame:GetChildren()) do
        if ch:IsA("GuiObject") then ch:Destroy() end
    end
    local list = Clone.accList()
    if #list == 0 then return end
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 0,
        Text = "Dipakai (tap untuk lepas):", TextColor3 = Color3.fromRGB(170, 170, 190),
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, wornFrame)
    for i, def in ipairs(list) do
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(40, 120, 70),
            Text = "OFF  x  " .. tostring(def.label), TextColor3 = WHITE,
            Font = Enum.Font.GothamMedium, TextSize = 11, LayoutOrder = i,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, wornFrame)
        new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
        b.Activated:Connect(function()
            Clone.accRemove(def.key)
            refreshWorn()
            if accB then accB.refresh() end
            say("Dilepas: " .. tostring(def.label))
        end)
    end
end

accB = makeBrowser(pAcc, "Cari aksesoris (nama) atau ID", {
    {label = "Aksesoris", cat = 11, sub = 19, allow = {Asset = true}},
}, function(it)
    if Clone.accIsOn(it.id) then
        Clone.accRemove(it.id)
        say("Dilepas: " .. tostring(it.name or it.id))
    else
        Clone.accAdd(it.id, it.name or tostring(it.id), it.assetType)
        say("Memasang " .. tostring(it.name or it.id) .. "...")
    end
    refreshWorn()
    -- kalau item gagal dimuat, status ON otomatis dimatikan oleh engine: segarkan tampilan
    task.delay(6, function()
        refreshWorn()
        if accB then accB.refresh() end
    end)
end, function(page)
    wornFrame = new("Frame", {
        Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = nx(),
    }, page)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, wornFrame)
    btn(page, "Lepas SEMUA aksesoris", function()
        Clone.accClear()
        refreshWorn()
        if accB then accB.refresh() end
        say("Semua aksesoris dilepas")
    end)
end, 1, function(it) return Clone.accIsOn(it.id) end)
onShow["Aksesoris"] = function() accB.search("", false) end

-- ---------------- Shirt ----------------
local shirtB = makeBrowser(pShirt, "Cari baju/celana (nama) atau ID", {
    {label = "Shirt", cat = 3, sub = 56, at = {[11] = true}, prop = "Shirt"},
    {label = "Pants", cat = 3, sub = 57, at = {[12] = true}, prop = "Pants"},
}, function(it, t)
    local prop = (t and t.prop) or "Shirt"
    Clone.setOverride(prop, it.id)
    say("Memasang " .. tostring(it.name or it.id) .. "...")
    recopy("Terpasang: " .. tostring(it.name or it.id) .. " (lokal)")
end, function(page)
    btn(page, "Reset baju & celana", function()
        Clone.setOverride("Shirt", nil)
        Clone.setOverride("Pants", nil)
        if Clone.isActive() then recopy("Baju dikembalikan") else say("Tidak ada perubahan") end
    end)
end, 1, function(it)
    return Clone.getOverride("Shirt") == it.id or Clone.getOverride("Pants") == it.id
end)
onShow["Shirt"] = function() shirtB.search("", false) end

-- ---------------- Animasi ----------------
local ANIM_FIELDS = {"IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation",
    "FallAnimation", "ClimbAnimation", "SwimAnimation"}
local animB = makeBrowser(pAnim, "Cari animation pack (nama) atau ID bundle", {
    {label = "Animation Pack", cat = 12, sub = 38, allow = {Bundle = true}, numType = "Bundle"},
}, function(it)
    say("Mengambil animation pack...")
    local od, err = bundleDesc(it.id)
    if not od then return say(tostring(err)) end
    local n = 0
    for _, f in ipairs(ANIM_FIELDS) do
        local v = 0
        pcall(function() v = od[f] end)
        if type(v) == "number" and v > 0 then
            Clone.setOverride(f, v)
            n += 1
        end
    end
    if n == 0 then return say("Bundle ini bukan animation pack") end
    Clone.setOverride("_animPack", it.id)
    recopy("Animation pack terpasang: " .. tostring(it.name or it.id))
end, function(page)
    btn(page, "Reset animasi asli", function()
        for _, f in ipairs(ANIM_FIELDS) do Clone.setOverride(f, nil) end
        Clone.setOverride("_animPack", nil)
        if Clone.isActive() then recopy("Animasi dikembalikan") else say("Tidak ada perubahan") end
    end)
end, 1, function(it) return Clone.getOverride("_animPack") == it.id end)
onShow["Animasi"] = function() animB.search("", false) end

-- ---------------- Body ----------------
local BODY_PROPS = {[17] = "Head", [18] = "Face", [27] = "Torso", [28] = "RightArm",
    [29] = "LeftArm", [30] = "LeftLeg", [31] = "RightLeg"}
local BODY_FIELDS = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Face"}
local SCALE_FIELDS = {"HeightScale", "WidthScale", "HeadScale", "DepthScale", "ProportionScale", "BodyTypeScale"}
-- Korless = kepala hilang (Headless Head) + kaki kanan Korblox Deathspeaker
local KORLESS_HEAD = 134082579
local KORLESS_LEG = 139607718
local korlessPrev = nil
btn(pBody, "Apply Korless (kepala hilang + Korblox kaki kanan)", function()
    if not korlessPrev then
        korlessPrev = {head = Clone.getOverride("Head"), leg = Clone.getOverride("RightLeg")}
    end
    Clone.setOverride("Head", KORLESS_HEAD)
    Clone.setOverride("RightLeg", KORLESS_LEG)
    Clone.setOverride("_korless", true)
    say("Memasang Korless...")
    recopy("Korless terpasang (lokal)")
end)
btn(pBody, "Reset Korless", function()
    local prev = korlessPrev or {}
    Clone.setOverride("Head", prev.head)
    Clone.setOverride("RightLeg", prev.leg)
    Clone.setOverride("_korless", nil)
    korlessPrev = nil
    if Clone.isActive() then recopy("Korless dilepas") else say("Tidak ada perubahan") end
end)

local bodyB = makeBrowser(pBody, "Cari body / head (nama) atau ID bundle", {
    {label = "Body Bundle", cat = 4, sub = 37, allow = {Bundle = true}, numType = "Bundle"},
    {label = "Head", cat = 4, sub = 15, allow = {Asset = true}, at = {[17] = true}},
}, function(it)
    say("Memasang body " .. tostring(it.name or it.id) .. "...")
    if it.itemType == "Bundle" then
        local od, err = bundleDesc(it.id)
        if not od then return say(tostring(err)) end
        for _, f in ipairs(BODY_FIELDS) do
            local v = 0
            pcall(function() v = od[f] end)
            if type(v) == "number" and v > 0 then Clone.setOverride(f, v) end
        end
        for _, f in ipairs(SCALE_FIELDS) do
            local v
            pcall(function() v = od[f] end)
            if type(v) == "number" then Clone.setOverride(f, v) end
        end
        Clone.setOverride("_bodyPack", it.id)
    else
        local prop = BODY_PROPS[it.assetType or 17]
        if not prop then return say("Jenis item tidak dikenal") end
        Clone.setOverride(prop, it.id)
        Clone.setOverride("_bodyPack", it.id)
    end
    recopy("Body terpasang: " .. tostring(it.name or it.id) .. " (lokal)")
end, function(page)
    btn(page, "Reset body", function()
        for _, f in ipairs(BODY_FIELDS) do Clone.setOverride(f, nil) end
        for _, f in ipairs(SCALE_FIELDS) do Clone.setOverride(f, nil) end
        Clone.setOverride("_bodyPack", nil)
        if Clone.isActive() then recopy("Body dikembalikan") else say("Tidak ada perubahan") end
    end)
end, 1, function(it) return Clone.getOverride("_bodyPack") == it.id end)
onShow["Body"] = function() bodyB.search("", false) end

------------------------------------------------------------------
-- Tombol bar
------------------------------------------------------------------
local mini = false
barBtn("-", -62, function()
    mini = not mini
    body.Visible = not mini
    main.Size = mini and UDim2.fromOffset(W, 32) or UDim2.fromOffset(W, H)
end)
barBtn("X", -32, function()
    pcall(Clone.stopEmote)
    gui:Destroy()
end)

showTab("Emote")
say("A197 v4 siap. Geser tab ke samping untuk Shirt / Animasi / Body.")
