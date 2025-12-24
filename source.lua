--[[
    JanBlox v1.0.0 (Compact & Draggable)
    - Size: 480x320 (Smaller)
    - TopBar drags the GUI
    - Minimize Button is draggable
    - Real Online Count & Real Profile Data
    - Boxy Design (No Rounded Corners)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local API_URL = "https://global-chat-fr.janskibananski1602.workers.dev"
local VERSION = "v1.0.0"

-- Settings
local Settings = {
    AutoScroll = true,
    Notifications = true
}

-- // HTTP CHECK //
local http_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not http_request then
    if Settings.Notifications then
        StarterGui:SetCore("SendNotification", {Title="JanBlox", Text="Executor missing HTTP support!"})
    end
    return
end

-- // API WRAPPER //
local function APIRequest(endpoint, method, body)
    local response = nil
    local success, _ = pcall(function()
        local headers = {["Content-Type"] = "application/json"}
        local options = {
            Url = API_URL .. endpoint,
            Method = method or "GET",
            Headers = headers
        }
        if body then options.Body = HttpService:JSONEncode(body) end
        response = http_request(options)
    end)

    if success and response and response.Body then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        if decodeSuccess then return decoded end
    end
    return nil
end

-- // UI CLEANUP //
if CoreGui:FindFirstChild("JanBloxCompact") then
    CoreGui.JanBloxCompact:Destroy()
end

-- // UI SETUP //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxCompact"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 1. LOADING SCREEN (Compact)
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 50
LoadingFrame.Parent = ScreenGui

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 0, 4)
LoadingBar.Position = UDim2.new(0, 0, 0.5, 10)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "JanBlox Loading..."
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.Position = UDim2.new(0, 0, 0, -10)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextSize = 18
LoadingText.Parent = LoadingFrame

-- Fake Load
for i = 1, 5 do
    LoadingBar.Size = UDim2.new(i/5, 0, 0, 4)
    task.wait(0.4)
end
LoadingFrame:Destroy()

-- // DRAGGABLE FUNCTION //
local function MakeDraggable(targetFrame, handle)
    handle = handle or targetFrame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        elseif input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

-- 2. FLOATING BUTTON (Draggable)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 40, 0, 40)
MiniBtn.Position = UDim2.new(0, 20, 0.5, -20)
MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MiniBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
MiniBtn.BorderSizePixel = 2
MiniBtn.Text = "JB"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.SourceSansBold
MiniBtn.TextSize = 18
MiniBtn.Visible = false -- Hidden by default
MiniBtn.Parent = ScreenGui

MakeDraggable(MiniBtn, MiniBtn) -- Make the button itself draggable

-- 3. MAIN GUI (Smaller Size: 480x320)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 110, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Top Bar (Draggable Handle)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderColor3 = Color3.fromRGB(50, 50, 50)
TopBar.BorderSizePixel = 1
TopBar.Parent = MainFrame

MakeDraggable(MainFrame, TopBar) -- Dragging TopBar moves MainFrame

local Title = Instance.new("TextLabel")
Title.Text = " JANBLOX " .. VERSION
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = TopBar

local OnlineLbl = Instance.new("TextLabel")
OnlineLbl.Text = "Online: -- "
OnlineLbl.Size = UDim2.new(0.3, 0, 1, 0)
OnlineLbl.Position = UDim2.new(0.5, 0, 0, 0)
OnlineLbl.BackgroundTransparency = 1
OnlineLbl.TextColor3 = Color3.fromRGB(0, 255, 100)
OnlineLbl.TextXAlignment = Enum.TextXAlignment.Right
OnlineLbl.Font = Enum.Font.SourceSansBold
OnlineLbl.TextSize = 14
OnlineLbl.Parent = TopBar

-- Window Controls
local function WinBtn(txt, x, col, cb)
    local b = Instance.new("TextButton")
    b.Text = txt
    b.Size = UDim2.new(0, 30, 1, 0)
    b.Position = UDim2.new(1, x, 0, 0)
    b.BackgroundColor3 = col
    b.BorderColor3 = col
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.Parent = TopBar
    b.MouseButton1Click:Connect(cb)
end

WinBtn("X", -30, Color3.fromRGB(180, 50, 50), function() ScreenGui:Destroy() end)

-- Minimize Logic
local function ToggleUI(mode)
    if mode == "min" then
        MainFrame.Visible = false
        MiniBtn.Visible = true
    else
        MainFrame.Visible = true
        MiniBtn.Visible = false
    end
end
WinBtn("_", -60, Color3.fromRGB(60, 60, 60), function() ToggleUI("min") end)
MiniBtn.MouseButton1Click:Connect(function() ToggleUI("open") end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderColor3 = Color3.fromRGB(50, 50, 50)
Sidebar.BorderSizePixel = 1
Sidebar.Parent = MainFrame

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -110, 1, -30)
Content.Position = UDim2.new(0, 110, 0, 30)
Content.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

local function ClearContent()
    for _,v in pairs(Content:GetChildren()) do v:Destroy() end
end

local function TabBtn(txt, idx, cb)
    local b = Instance.new("TextButton")
    b.Text = txt
    b.Size = UDim2.new(1, 0, 0, 35)
    b.Position = UDim2.new(0, 0, 0, idx * 36)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BorderColor3 = Color3.fromRGB(60, 60, 60)
    b.BorderSizePixel = 1
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.Parent = Sidebar
    b.MouseButton1Click:Connect(function() ClearContent(); cb() end)
end

-- // TAB: CHAT //
local function LoadChat()
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(1, 0, 1, -35)
    List.BackgroundTransparency = 1
    List.BorderSizePixel = 0
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.CanvasSize = UDim2.new(0,0,0,0)
    List.ScrollBarThickness = 5
    List.Parent = Content
    
    local Layout = Instance.new("UIListLayout"); Layout.Padding = UDim.new(0,4); Layout.Parent = List
    local Pad = Instance.new("UIPadding"); Pad.PaddingLeft = UDim.new(0,4); Pad.PaddingTop = UDim.new(0,4); Pad.Parent = List

    local Inp = Instance.new("TextBox")
    Inp.Size = UDim2.new(0.75, -4, 0, 30)
    Inp.Position = UDim2.new(0, 2, 1, -33)
    Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Inp.BorderColor3 = Color3.fromRGB(80, 80, 80)
    Inp.BorderSizePixel = 1
    Inp.Text = ""
    Inp.PlaceholderText = " Message..."
    Inp.TextColor3 = Color3.new(1,1,1)
    Inp.Font = Enum.Font.SourceSans
    Inp.TextSize = 14
    Inp.TextXAlignment = Enum.TextXAlignment.Left
    Inp.Parent = Content

    local Send = Instance.new("TextButton")
    Send.Text = "SEND"
    Send.Size = UDim2.new(0.25, -4, 0, 30)
    Send.Position = UDim2.new(0.75, 2, 1, -33)
    Send.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Send.BorderColor3 = Color3.fromRGB(0, 120, 255)
    Send.TextColor3 = Color3.new(1,1,1)
    Send.Font = Enum.Font.SourceSansBold
    Send.TextSize = 14
    Send.Parent = Content

    local function Add(d)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.Size = UDim2.new(1, 0, 0, 0)
        f.AutomaticSize = Enum.AutomaticSize.Y
        f.Parent = List
        
        local t = Instance.new("TextLabel")
        t.Text = string.format("[%s]: %s", d.username or "?", d.content or "")
        t.Size = UDim2.new(1, -8, 0, 0)
        t.AutomaticSize = Enum.AutomaticSize.Y
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1,1,1)
        t.TextWrapped = true
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Font = Enum.Font.SourceSans
        t.TextSize = 14
        t.Parent = f
    end

    Send.MouseButton1Click:Connect(function()
        if Inp.Text == "" then return end
        local m = Inp.Text; Inp.Text = ""
        task.spawn(function()
            APIRequest("/messages/global", "POST", {username = LocalPlayer.Name, content = m})
            local r = APIRequest("/messages/global", "GET")
            if r then
                for _,v in pairs(List:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                for _,v in pairs(r) do Add(v) end
                if Settings.AutoScroll then List.CanvasPosition = Vector2.new(0, 99999) end
            end
        end)
    end)

    task.spawn(function()
        while List.Parent do
            local r = APIRequest("/messages/global", "GET")
            if r then
                local c = 0; for _,v in pairs(List:GetChildren()) do if v:IsA("Frame") then c=c+1 end end
                if c ~= #r then
                    for _,v in pairs(List:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                    for _,v in pairs(r) do Add(v) end
                    if Settings.AutoScroll then List.CanvasPosition = Vector2.new(0, 99999) end
                end
            end
            task.wait(4)
        end
    end)
end

-- // TAB: PROFILE //
local function LoadProfile()
    local S = Instance.new("ScrollingFrame")
    S.Size = UDim2.new(1, 0, 1, 0)
    S.BackgroundTransparency = 1
    S.BorderSizePixel = 0
    S.Parent = Content

    local P = Instance.new("ImageLabel")
    P.Size = UDim2.new(0, 80, 0, 80)
    P.Position = UDim2.new(0, 10, 0, 10)
    P.BackgroundColor3 = Color3.fromRGB(40,40,40)
    P.BorderColor3 = Color3.fromRGB(120,120,120)
    P.BorderSizePixel = 1
    P.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    P.Parent = S

    local function L(txt, y, sz)
        local l = Instance.new("TextLabel")
        l.Text = txt
        l.Position = UDim2.new(0, 100, 0, y)
        l.Size = UDim2.new(0, 200, 0, 20)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1,1,1)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.SourceSansBold
        l.TextSize = sz
        l.Parent = S
    end

    L(LocalPlayer.DisplayName, 15, 20)
    L("@"..LocalPlayer.Name, 40, 16)
    L("ID: "..LocalPlayer.UserId, 65, 14)
    L("Age: "..LocalPlayer.AccountAge.." Days", 82, 14)
end

-- // TAB: SETTINGS //
local function LoadSettings()
    local L = Instance.new("UIListLayout"); L.Padding = UDim.new(0, 8); L.Parent = Content
    local P = Instance.new("UIPadding"); P.PaddingTop = UDim.new(0, 10); P.PaddingLeft = UDim.new(0, 10); P.Parent = Content

    local function Toggle(txt, key)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        b.BorderColor3 = Color3.fromRGB(100,100,100)
        b.Text = txt .. ": " .. (Settings[key] and "ON" or "OFF")
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 14
        b.Parent = Content
        b.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            b.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            b.Text = txt .. ": " .. (Settings[key] and "ON" or "OFF")
        end)
    end

    local function Act(txt, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(50,50,50)
        b.BorderColor3 = Color3.fromRGB(100,100,100)
        b.Text = txt
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 14
        b.Parent = Content
        b.MouseButton1Click:Connect(cb)
    end

    Toggle("Auto Scroll", "AutoScroll")
    Toggle("Notifications", "Notifications")
    Act("Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

TabBtn("CHAT", 0, LoadChat)
TabBtn("PROFILE", 1, LoadProfile)
TabBtn("SETTINGS", 2, LoadSettings)
LoadChat()

-- // ONLINE POLL //
task.spawn(function()
    while ScreenGui.Parent do
        local data = APIRequest("/online-count", "GET")
        if data and data.count then
            OnlineLbl.Text = "Online: " .. tostring(data.count) .. " "
        end
        task.wait(10)
    end
end)