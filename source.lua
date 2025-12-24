--[[
    Global Chat Script
    Mobile Friendly + Modern UI
]]

local SERVER_URL = "https://global-chat-api-0qdb.onrender.com" -- CHANGE THIS!

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerName = player.Name

-- Check if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variables
local lastMessageId = 0
local isMinimized = false
local chatEnabled = true

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlobalChatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Destroy existing
if game:GetService("CoreGui"):FindFirstChild("GlobalChatGui") then
    game:GetService("CoreGui"):FindFirstChild("GlobalChatGui"):Destroy()
end

ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, isMobile and 280 or 320, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 80, 200)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "💬 Global Chat"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = isMobile and 14 or 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Online Counter
local OnlineLabel = Instance.new("TextLabel")
OnlineLabel.Size = UDim2.new(0, 50, 0, 20)
OnlineLabel.Position = UDim2.new(0, 12, 1, 2)
OnlineLabel.BackgroundTransparency = 1
OnlineLabel.Text = "🟢 0"
OnlineLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
OnlineLabel.TextSize = 12
OnlineLabel.Font = Enum.Font.Gotham
OnlineLabel.TextXAlignment = Enum.TextXAlignment.Left
OnlineLabel.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -16, 1, -90)
ContentFrame.Position = UDim2.new(0, 8, 0, 42)
ContentFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Scroll Frame for messages
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -8, 1, -8)
ScrollFrame.Position = UDim2.new(0, 4, 0, 4)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = ContentFrame

local MsgLayout = Instance.new("UIListLayout")
MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
MsgLayout.Padding = UDim.new(0, 4)
MsgLayout.Parent = ScrollFrame

local MsgPadding = Instance.new("UIPadding")
MsgPadding.PaddingTop = UDim.new(0, 4)
MsgPadding.PaddingBottom = UDim.new(0, 4)
MsgPadding.Parent = ScrollFrame

-- Input Frame
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -16, 0, 36)
InputFrame.Position = UDim2.new(0, 8, 1, -44)
InputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
InputFrame.BorderSizePixel = 0
InputFrame.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputFrame

-- Text Input
local TextInput = Instance.new("TextBox")
TextInput.Size = UDim2.new(1, -56, 1, -8)
TextInput.Position = UDim2.new(0, 8, 0, 4)
TextInput.BackgroundTransparency = 1
TextInput.Text = ""
TextInput.PlaceholderText = "Type message..."
TextInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
TextInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TextInput.TextSize = isMobile and 14 or 15
TextInput.Font = Enum.Font.Gotham
TextInput.TextXAlignment = Enum.TextXAlignment.Left
TextInput.ClearTextOnFocus = false
TextInput.Parent = InputFrame

-- Send Button
local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 44, 0, 28)
SendBtn.Position = UDim2.new(1, -48, 0, 4)
SendBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
SendBtn.Text = "➤"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 18
SendBtn.Font = Enum.Font.GothamBold
SendBtn.Parent = InputFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 6)
SendCorner.Parent = SendBtn

-- Dragging System (Works on Mobile & PC)
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = newPos}):Play()
    end
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- Button Hover Effects
local function addHover(btn, hoverColor, normalColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

addHover(CloseBtn, Color3.fromRGB(255, 80, 80), Color3.fromRGB(200, 60, 60))
addHover(MinBtn, Color3.fromRGB(100, 100, 255), Color3.fromRGB(80, 80, 200))
addHover(SendBtn, Color3.fromRGB(100, 255, 140), Color3.fromRGB(80, 200, 120))

-- Minimize/Maximize
local normalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, normalSize.X.Offset, 0, 36)
        }):Play()
        MinBtn.Text = "+"
        ContentFrame.Visible = false
        InputFrame.Visible = false
        OnlineLabel.Visible = false
    else
        ContentFrame.Visible = true
        InputFrame.Visible = true
        OnlineLabel.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = normalSize
        }):Play()
        MinBtn.Text = "—"
    end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    chatEnabled = false
    ScreenGui:Destroy()
end)

-- Message Functions
local messageOrder = 0

local function addMessage(username, message, isSystem)
    messageOrder = messageOrder + 1
    
    local MsgFrame = Instance.new("Frame")
    MsgFrame.Size = UDim2.new(1, -8, 0, 0)
    MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
    MsgFrame.BackgroundColor3 = isSystem and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(30, 30, 45)
    MsgFrame.BorderSizePixel = 0
    MsgFrame.LayoutOrder = messageOrder
    MsgFrame.Parent = ScrollFrame
    
    local MsgCorner = Instance.new("UICorner")
    MsgCorner.CornerRadius = UDim.new(0, 6)
    MsgCorner.Parent = MsgFrame
    
    local MsgPadding = Instance.new("UIPadding")
    MsgPadding.PaddingLeft = UDim.new(0, 8)
    MsgPadding.PaddingRight = UDim.new(0, 8)
    MsgPadding.PaddingTop = UDim.new(0, 6)
    MsgPadding.PaddingBottom = UDim.new(0, 6)
    MsgPadding.Parent = MsgFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 14)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = isSystem and "⚙️ System" or ("👤 " .. username)
    NameLabel.TextColor3 = isSystem and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(130, 180, 255)
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = MsgFrame
    
    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, 0, 0, 0)
    MsgLabel.AutomaticSize = Enum.AutomaticSize.Y
    MsgLabel.Position = UDim2.new(0, 0, 0, 16)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    MsgLabel.TextSize = isMobile and 13 or 14
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true
    MsgLabel.Parent = MsgFrame
    
    -- Limit messages
    local children = ScrollFrame:GetChildren()
    local msgCount = 0
    for _, child in ipairs(children) do
        if child:IsA("Frame") then
            msgCount = msgCount + 1
        end
    end
    
    if msgCount > 50 then
        for _, child in ipairs(children) do
            if child:IsA("Frame") then
                child:Destroy()
                break
            end
        end
    end
    
    -- Auto scroll
    task.wait(0.1)
    ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.AbsoluteCanvasSize.Y)
end

-- HTTP Functions
local function request(method, endpoint, data)
    local success, result = pcall(function()
        if method == "GET" then
            return game:HttpGet(SERVER_URL .. endpoint)
        else
            return (syn and syn.request or http and http.request or request)({
                Url = SERVER_URL .. endpoint,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            }).Body
        end
    end)
    
    if success then
        local decoded = pcall(function() return HttpService:JSONDecode(result) end)
        if decoded then
            return HttpService:JSONDecode(result)
        end
    end
    return nil
end

-- Fallback for different executors
local function httpPost(url, data)
    local success, response = pcall(function()
        -- Try syn.request first (Synapse)
        if syn and syn.request then
            return syn.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            }).Body
        -- Try http.request (some other executors)
        elseif http and http.request then
            return http.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            }).Body
        -- Try request (Fluxus, etc)
        elseif request then
            return request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            }).Body
        -- Try http_request
        elseif http_request then
            return http_request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            }).Body
        end
    end)
    
    if success and response then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if decodeSuccess then
            return decoded
        end
    end
    return nil
end

local function httpGet(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if decodeSuccess then
            return decoded
        end
    end
    return nil
end

-- Send Message
local function sendMessage(msg)
    if msg == "" then return end
    
    local result = httpPost(SERVER_URL .. "/send", {
        username = playerName,
        message = msg
    })
    
    if not result or not result.success then
        addMessage("System", "Failed to send message!", true)
    end
end

-- Fetch Messages
local function fetchMessages()
    local result = httpGet(SERVER_URL .. "/messages?after=" .. lastMessageId)
    
    if result and result.success then
        for _, msg in ipairs(result.messages) do
            if msg.id > lastMessageId then
                addMessage(msg.username, msg.message, false)
                lastMessageId = msg.id
            end
        end
    end
end

-- Ping Server (for online count)
local function pingServer()
    local result = httpPost(SERVER_URL .. "/ping", {
        username = playerName
    })
    
    if result and result.success then
        OnlineLabel.Text = "🟢 " .. result.online
    end
end

-- Send Button
SendBtn.MouseButton1Click:Connect(function()
    local msg = TextInput.Text
    TextInput.Text = ""
    sendMessage(msg)
end)

-- Enter Key to Send
TextInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local msg = TextInput.Text
        TextInput.Text = ""
        sendMessage(msg)
    end
end)

-- Main Loop
addMessage("System", "Connected to Global Chat!", true)
addMessage("System", "You: " .. playerName, true)

-- Fetch and ping loops
task.spawn(function()
    while chatEnabled and ScreenGui.Parent do
        pcall(fetchMessages)
        task.wait(2) -- Fetch every 2 seconds
    end
end)

task.spawn(function()
    while chatEnabled and ScreenGui.Parent do
        pcall(pingServer)
        task.wait(15) -- Ping every 15 seconds
    end
end)

print("Global Chat loaded successfully!")
