--[[
    JanBlox v1.0.0
    Client-Side Exploit Script
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local API_URL = "https://global-chat-fr.janskibananski1602.workers.dev" -- Your URL
local VERSION = "v1.0.0"

-- // HTTP COMPATIBILITY CHECK //
local requestFunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not requestFunc then
    return game.StarterGui:SetCore("SendNotification", {
        Title = "JanBlox Error",
        Text = "Your executor does not support HTTP requests."
    })
end

-- // CLEANUP PREVIOUS UI //
if CoreGui:FindFirstChild("JanBloxMain") then
    CoreGui.JanBloxMain:Destroy()
end

-- // GUI CREATION //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxMain"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 1. Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "JanBlox " .. VERSION .. " Loading..."
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 24
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.Parent = LoadingFrame

task.wait(1) -- Simulated load
LoadingFrame:Destroy()

-- 2. Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "  JanBlox " .. VERSION
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TopBar

local OnlineLabel = Instance.new("TextLabel")
OnlineLabel.Text = "Online: 0  "
OnlineLabel.Size = UDim2.new(0.5, 0, 1, 0)
OnlineLabel.Position = UDim2.new(0.5, 0, 0, 0)
OnlineLabel.BackgroundTransparency = 1
OnlineLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
OnlineLabel.TextXAlignment = Enum.TextXAlignment.Right
OnlineLabel.Font = Enum.Font.Gotham
OnlineLabel.TextSize = 14
OnlineLabel.Parent = TopBar

-- Buttons (Close/Min)
local function makeBtn(text, x_off, col, callback)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Size = UDim2.new(0, 35, 1, 0)
    b.Position = UDim2.new(1, x_off, 0, 0)
    b.BackgroundColor3 = col
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    b.Parent = TopBar
    b.MouseButton1Click:Connect(callback)
    return b
end

makeBtn("X", -35, Color3.fromRGB(200, 60, 60), function() ScreenGui:Destroy() end)
local minBtn = makeBtn("-", -70, Color3.fromRGB(100, 100, 100), function()
    if MainFrame.Size.Y.Offset > 35 then
        MainFrame.Size = UDim2.new(0, 550, 0, 35)
        MainFrame.ClipsDescendants = true
    else
        MainFrame.Size = UDim2.new(0, 550, 0, 350)
        MainFrame.ClipsDescendants = false
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -130, 1, -35)
Container.Position = UDim2.new(0, 130, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- // LOGIC //

-- Dragging
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif input.UserInputState == Enum.UserInputState.End then
        dragging = false
    end
end)

-- Pages Logic
local function clearContainer()
    for _,v in pairs(Container:GetChildren()) do v:Destroy() end
end

local function CreateTab(name, y_pos, callback)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, y_pos * 30)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.Parent = Sidebar
    btn.MouseButton1Click:Connect(callback)
end

-- Chat System
local function LoadChat()
    clearContainer()
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 6
    Scroll.Parent = Container
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Scroll
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)

    -- Input
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.8, -10, 0, 35)
    Box.Position = UDim2.new(0, 5, 1, -40)
    Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Box.PlaceholderText = "Say something..."
    Box.TextColor3 = Color3.new(1,1,1)
    Box.Parent = Container

    local Send = Instance.new("TextButton")
    Send.Text = "Send"
    Send.Size = UDim2.new(0.2, -5, 0, 35)
    Send.Position = UDim2.new(0.8, 5, 1, -40)
    Send.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Send.TextColor3 = Color3.new(1,1,1)
    Send.Parent = Container

    -- Function to refresh chat
    local function fetchMessages()
        local s, r = pcall(function()
            return requestFunc({Url = API_URL .. "/messages/global", Method = "GET"})
        end)
        if s and r.Body then
            -- Clear old
            for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            
            local data = HttpService:JSONDecode(r.Body)
            for _, msg in pairs(data) do
                local msgFrame = Instance.new("Frame")
                msgFrame.Size = UDim2.new(1, 0, 0, 25)
                msgFrame.BackgroundTransparency = 1
                msgFrame.Parent = Scroll
                
                local name = Instance.new("TextButton") -- Clickable name for profile
                name.Text = "[" .. msg.username .. "]: "
                name.Size = UDim2.new(0, 0, 1, 0)
                name.AutomaticSize = Enum.AutomaticSize.X
                name.BackgroundTransparency = 1
                name.TextColor3 = Color3.fromRGB(100, 200, 255)
                name.Font = Enum.Font.GothamBold
                name.TextSize = 14
                name.Parent = msgFrame
                
                local content = Instance.new("TextLabel")
                content.Text = msg.content
                content.Position = UDim2.new(0, 0, 0, 0)
                content.Size = UDim2.new(1, 0, 1, 0)
                content.BackgroundTransparency = 1
                content.TextColor3 = Color3.new(1,1,1)
                content.TextXAlignment = Enum.TextXAlignment.Left
                content.Font = Enum.Font.Gotham
                content.TextSize = 14
                content.Parent = msgFrame
                
                -- Adjust layout
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    content.Position = UDim2.new(0, name.AbsoluteSize.X + 5, 0, 0)
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
                end)
            end
        end
    end

    Send.MouseButton1Click:Connect(function()
        if Box.Text == "" then return end
        local msg = Box.Text
        Box.Text = "" -- Clear immediately
        
        -- Send to Workers
        requestFunc({
            Url = API_URL .. "/messages/global",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                username = LocalPlayer.Name,
                userId = LocalPlayer.UserId,
                content = msg
            })
        })
        task.wait(0.2)
        fetchMessages()
    end)
    
    -- Auto refresh loop
    task.spawn(function()
        while Container:IsDescendantOf(game) do
            fetchMessages()
            task.wait(2)
        end
    end)
end

-- Profile System
local function LoadProfile()
    clearContainer()
    local pFrame = Instance.new("Frame")
    pFrame.Size = UDim2.new(1, -20, 1, -20)
    pFrame.Position = UDim2.new(0, 10, 0, 10)
    pFrame.BackgroundTransparency = 1
    pFrame.Parent = Container

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 100, 0, 100)
    icon.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    icon.Parent = pFrame
    
    local name = Instance.new("TextLabel")
    name.Text = LocalPlayer.DisplayName
    name.Position = UDim2.new(0, 110, 0, 0)
    name.TextSize = 22
    name.TextColor3 = Color3.new(1,1,1)
    name.BackgroundTransparency = 1
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Font = Enum.Font.GothamBold
    name.Parent = pFrame
    
    local sub = Instance.new("TextLabel")
    sub.Text = "@" .. LocalPlayer.Name
    sub.Position = UDim2.new(0, 110, 0, 25)
    sub.TextSize = 16
    sub.TextColor3 = Color3.fromRGB(150, 150, 150)
    sub.BackgroundTransparency = 1
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Font = Enum.Font.Gotham
    sub.Parent = pFrame
    
    -- Buttons
    local function mkActBtn(txt, y)
        local b = Instance.new("TextButton")
        b.Text = txt
        b.Size = UDim2.new(0, 120, 0, 30)
        b.Position = UDim2.new(0, 110, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = pFrame
    end
    mkActBtn("Friends", 60)
    mkActBtn("Followers", 95)
    mkActBtn("Block List", 130)
end

-- Initialize Tabs
CreateTab("Global Chat", 0, LoadChat)
CreateTab("My Profile", 1, LoadProfile)
CreateTab("Settings", 2, function() clearContainer() end)

-- Initial Load
LoadChat()

-- Online Counter Poller
task.spawn(function()
    while ScreenGui.Parent do
        local s, r = pcall(function()
            return requestFunc({Url = API_URL .. "/online-count", Method = "GET"})
        end)
        if s and r.Body then
            local d = HttpService:JSONDecode(r.Body)
            if d.count then OnlineLabel.Text = "Online: " .. d.count .. "  " end
        end
        task.wait(5)
    end
end)