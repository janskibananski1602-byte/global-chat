--[[
    JanBlox v1.0.0 (Bug Fix Version)
    Simple, No Animations, Robust HTTP Handling
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local API_URL = "https://global-chat-fr.janskibananski1602.workers.dev"
local VERSION = "v1.0.0"

-- // HTTP COMPATIBILITY //
local http_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not http_request then
    return game.StarterGui:SetCore("SendNotification", {
        Title = "JanBlox Error",
        Text = "Your executor does not support HTTP requests."
    })
end

-- // SAFE REQUEST WRAPPER //
local function APIRequest(endpoint, method, body)
    local response = nil
    local success, err = pcall(function()
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

-- // CLEANUP //
if CoreGui:FindFirstChild("JanBloxFixed") then
    CoreGui.JanBloxFixed:Destroy()
end

-- // UI CREATION //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxFixed"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 1. Loading Frame (Simple, No Animation)
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LoadingFrame.Parent = ScreenGui

local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Text = "Loading JanBlox " .. VERSION .. "..."
LoadingLabel.Size = UDim2.new(1, 0, 1, 0)
LoadingLabel.BackgroundTransparency = 1
LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingLabel.TextSize = 24
LoadingLabel.Parent = LoadingFrame

task.wait(1)
LoadingFrame:Destroy()

-- 2. Main GUI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true -- Important for minimize
MainFrame.Parent = ScreenGui

-- Rounded Corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 6)
TopCorner.Parent = TopBar

-- Fix bottom corners of topbar showing if rounded
local TopBarFiller = Instance.new("Frame")
TopBarFiller.Size = UDim2.new(1, 0, 0, 10)
TopBarFiller.Position = UDim2.new(0, 0, 1, -10)
TopBarFiller.BackgroundColor3 = TopBar.BackgroundColor3
TopBarFiller.BorderSizePixel = 0
TopBarFiller.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Text = "JanBlox " .. VERSION
Title.Size = UDim2.new(0.4, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TopBar

local OnlineText = Instance.new("TextLabel")
OnlineText.Text = "Online: ..."
OnlineText.Size = UDim2.new(0.3, 0, 1, 0)
OnlineText.Position = UDim2.new(0.5, 0, 0, 0)
OnlineText.BackgroundTransparency = 1
OnlineText.TextColor3 = Color3.fromRGB(100, 255, 100)
OnlineText.Font = Enum.Font.Gotham
OnlineText.TextSize = 13
OnlineText.Parent = TopBar

-- Buttons
local function CreateTopBtn(text, offset, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 35, 0, 35)
    btn.Position = UDim2.new(1, offset, 0, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = TopBar
    
    -- Round only the specific corners for style (optional, keeping simple)
    if text == "X" then
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
        local f = Instance.new("Frame"); f.Size = UDim2.new(0,10,1,0); f.BackgroundTransparency=1; f.Parent=btn -- filler
    end
    
    btn.MouseButton1Click:Connect(callback)
end

CreateTopBtn("X", -35, Color3.fromRGB(200, 60, 60), function() ScreenGui:Destroy() end)
CreateTopBtn("-", -70, Color3.fromRGB(80, 80, 80), function()
    if MainFrame.Size.Y.Offset > 40 then
        MainFrame.Size = UDim2.new(0, 550, 0, 35) -- Minimize
    else
        MainFrame.Size = UDim2.new(0, 550, 0, 350) -- Restore
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -35)
Content.Position = UDim2.new(0, 120, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Draggable Logic
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

-- // TAB SYSTEM //
local currentTabFunc = nil

local function ClearContent()
    for _, child in pairs(Content:GetChildren()) do child:Destroy() end
end

local function CreateTabBtn(text, index, func)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 10 + (index * 35))
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = Sidebar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        ClearContent()
        currentTabFunc = func -- Stop old loops if any (advanced logic simplified here)
        func()
    end)
end

-- // TAB 1: GLOBAL CHAT //
local function LoadChat()
    local ChatList = Instance.new("ScrollingFrame")
    ChatList.Size = UDim2.new(1, -10, 1, -50)
    ChatList.Position = UDim2.new(0, 5, 0, 5)
    ChatList.BackgroundTransparency = 1
    ChatList.ScrollBarThickness = 4
    ChatList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ChatList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatList.Parent = Content
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = ChatList

    -- Input
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -10, 0, 35)
    InputFrame.Position = UDim2.new(0, 5, 1, -40)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = Content

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.8, -5, 1, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TextBox.Text = ""
    TextBox.PlaceholderText = "Type here..."
    TextBox.TextColor3 = Color3.new(1,1,1)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.Parent = InputFrame
    local c1 = Instance.new("UICorner"); c1.Parent = TextBox
    
    local SendBtn = Instance.new("TextButton")
    SendBtn.Text = "Send"
    SendBtn.Size = UDim2.new(0.2, -5, 1, 0)
    SendBtn.Position = UDim2.new(0.8, 5, 0, 0)
    SendBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
    SendBtn.TextColor3 = Color3.new(1,1,1)
    SendBtn.Font = Enum.Font.GothamBold
    SendBtn.Parent = InputFrame
    local c2 = Instance.new("UICorner"); c2.Parent = SendBtn

    local function RenderMessage(msgData)
        local MsgFrame = Instance.new("Frame")
        MsgFrame.Size = UDim2.new(1, 0, 0, 0)
        MsgFrame.AutomaticSize = Enum.AutomaticSize.Y -- Auto height
        MsgFrame.BackgroundTransparency = 1
        MsgFrame.LayoutOrder = msgData.timestamp or 0
        MsgFrame.Parent = ChatList

        local UserLabel = Instance.new("TextLabel")
        UserLabel.Text = "[" .. (msgData.username or "Unknown") .. "]:"
        UserLabel.Size = UDim2.new(0, 0, 0, 18)
        UserLabel.AutomaticSize = Enum.AutomaticSize.X
        UserLabel.BackgroundTransparency = 1
        UserLabel.TextColor3 = Color3.fromRGB(80, 180, 255)
        UserLabel.Font = Enum.Font.GothamBold
        UserLabel.TextSize = 13
        UserLabel.TextXAlignment = Enum.TextXAlignment.Left
        UserLabel.Position = UDim2.new(0, 0, 0, 0)
        UserLabel.Parent = MsgFrame

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Text = msgData.content or ""
        ContentLabel.Size = UDim2.new(1, 0, 0, 0) -- Width fills, height auto
        ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextSize = 13
        ContentLabel.TextWrapped = true
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.Position = UDim2.new(0, UserLabel.AbsoluteSize.X + 5, 0, 0)
        ContentLabel.Size = UDim2.new(1, -(UserLabel.AbsoluteSize.X + 5), 0, 0)
        ContentLabel.Parent = MsgFrame
    end

    -- Send Logic
    SendBtn.MouseButton1Click:Connect(function()
        if TextBox.Text == "" then return end
        local txt = TextBox.Text
        TextBox.Text = "" -- Clear visual
        
        task.spawn(function()
            APIRequest("/messages/global", "POST", {
                username = LocalPlayer.Name,
                userId = LocalPlayer.UserId,
                content = txt
            })
            -- Manually refresh after send
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                for _, c in pairs(ChatList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, m in pairs(msgs) do RenderMessage(m) end
            end
        end)
    end)

    -- Auto Loop
    task.spawn(function()
        while ChatList.Parent do
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                -- Basic refresh: clear all and redraw (inefficient but works for simple exploits)
                -- A better way checks IDs, but the API is simple.
                for _, c in pairs(ChatList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, m in pairs(msgs) do RenderMessage(m) end
                ChatList.CanvasPosition = Vector2.new(0, 9999) -- Auto scroll bottom
            end
            task.wait(3) -- Poll every 3 seconds
        end
    end)
end

-- // TAB 2: PROFILE //
local function LoadProfile()
    local PContainer = Instance.new("ScrollingFrame")
    PContainer.Size = UDim2.new(1, 0, 1, 0)
    PContainer.BackgroundTransparency = 1
    PContainer.Parent = Content
    
    -- Avatar
    local Av = Instance.new("ImageLabel")
    Av.Size = UDim2.new(0, 80, 0, 80)
    Av.Position = UDim2.new(0, 10, 0, 10)
    Av.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    Av.Parent = PContainer
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = Av

    local Name = Instance.new("TextLabel")
    Name.Text = LocalPlayer.DisplayName
    Name.Position = UDim2.new(0, 100, 0, 10)
    Name.Size = UDim2.new(0, 200, 0, 25)
    Name.BackgroundTransparency = 1
    Name.TextColor3 = Color3.new(1,1,1)
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 20
    Name.Parent = PContainer

    local User = Instance.new("TextLabel")
    User.Text = "@" .. LocalPlayer.Name
    User.Position = UDim2.new(0, 100, 0, 35)
    User.Size = UDim2.new(0, 200, 0, 20)
    User.BackgroundTransparency = 1
    User.TextColor3 = Color3.fromRGB(150, 150, 150)
    User.TextXAlignment = Enum.TextXAlignment.Left
    User.Font = Enum.Font.Gotham
    User.TextSize = 14
    User.Parent = PContainer

    -- Action Buttons (Mock)
    local function MkBtn(txt, y, col)
        local b = Instance.new("TextButton")
        b.Text = txt
        b.Size = UDim2.new(0.9, 0, 0, 30)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = col
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.Parent = PContainer
        local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,4); cr.Parent = b
        return b
    end
    
    MkBtn("Friends List (View)", 110, Color3.fromRGB(60, 60, 65))
    MkBtn("Blocked Users", 150, Color3.fromRGB(60, 60, 65))
    MkBtn("Device: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"), 190, Color3.fromRGB(40, 40, 40))
end

-- // TAB 3: SETTINGS //
local function LoadSettings()
    local SLabel = Instance.new("TextLabel")
    SLabel.Text = "Settings"
    SLabel.Size = UDim2.new(1,0,0,30)
    SLabel.TextColor3 = Color3.new(1,1,1)
    SLabel.BackgroundTransparency = 1
    SLabel.Parent = Content
    
    local Toggle = Instance.new("TextButton")
    Toggle.Text = "Notifications: ON"
    Toggle.Size = UDim2.new(0.5, 0, 0, 30)
    Toggle.Position = UDim2.new(0.25, 0, 0, 50)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    Toggle.Parent = Content
    local c = Instance.new("UICorner"); c.Parent = Toggle
    
    Toggle.MouseButton1Click:Connect(function()
        if Toggle.Text == "Notifications: ON" then
            Toggle.Text = "Notifications: OFF"
            Toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            Toggle.Text = "Notifications: ON"
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
end

-- // INIT //
CreateTabBtn("Global Chat", 0, LoadChat)
CreateTabBtn("Profile", 1, LoadProfile)
CreateTabBtn("Settings", 2, LoadSettings)

-- Load Default
LoadChat()

-- // GLOBAL ONLINE POLLING //
task.spawn(function()
    while ScreenGui.Parent do
        local data = APIRequest("/online-count", "GET")
        if data and data.count then
            OnlineText.Text = "Online: " .. tostring(data.count)
        else
            OnlineText.Text = "Online: Err"
        end
        task.wait(10)
    end
end)