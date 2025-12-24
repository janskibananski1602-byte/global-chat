--[[
    JanBlox v1.0.0
    - Full Global Chat & Profile System
    - Minimize hides window and shows a draggable "JB" button
    - No Animations
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local API_URL = "https://global-chat-fr.janskibananski1602.workers.dev"
local VERSION = "v1.0.0"

-- // HTTP CHECK //
local http_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not http_request then
    return game.StarterGui:SetCore("SendNotification", {
        Title = "JanBlox Error",
        Text = "Your executor does not support HTTP requests."
    })
end

-- // API WRAPPER //
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
if CoreGui:FindFirstChild("JanBloxMain") then
    CoreGui.JanBloxMain:Destroy()
end

-- // GUI SETUP //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxMain"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- // 1. LOADING SCREEN //
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LoadingFrame.ZIndex = 10
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

-- // 2. FLOATING BUTTON (For Minimize) //
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 20, 0.5, -25)
MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Text = "JB"
MiniBtn.TextSize = 20
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.Visible = false -- Hidden by default
MiniBtn.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner"); MiniCorner.CornerRadius = UDim.new(0, 12); MiniCorner.Parent = MiniBtn
local MiniStroke = Instance.new("UIStroke"); MiniStroke.Color = Color3.fromRGB(80, 80, 80); MiniStroke.Thickness = 2; MiniStroke.Parent = MiniBtn

-- // 3. MAIN WINDOW //
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 6); TopCorner.Parent = TopBar
local TopFiller = Instance.new("Frame"); TopFiller.Size = UDim2.new(1,0,0,10); TopFiller.Position=UDim2.new(0,0,1,-10); TopFiller.BackgroundColor3=TopBar.BackgroundColor3; TopFiller.BorderSizePixel=0; TopFiller.Parent=TopBar

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

-- // MINIMIZE LOGIC //
local function ToggleWindow(state)
    if state == "min" then
        MainFrame.Visible = false
        MiniBtn.Visible = true
    else
        MainFrame.Visible = true
        MiniBtn.Visible = false
    end
end

-- Buttons
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,6); cc.Parent=CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
MinBtn.MouseButton1Click:Connect(function() ToggleWindow("min") end)

MiniBtn.MouseButton1Click:Connect(function() ToggleWindow("open") end)

-- // DRAGGING //
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end
MakeDraggable(MainFrame, TopBar)
MakeDraggable(MiniBtn, MiniBtn)

-- Sidebar & Content
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -35)
Content.Position = UDim2.new(0, 120, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

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
    btn.MouseButton1Click:Connect(function() ClearContent(); func() end)
end

-- // CHAT //
local function LoadChat()
    local ChatList = Instance.new("ScrollingFrame")
    ChatList.Size = UDim2.new(1, -10, 1, -50)
    ChatList.Position = UDim2.new(0, 5, 0, 5)
    ChatList.BackgroundTransparency = 1
    ChatList.ScrollBarThickness = 4
    ChatList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatList.Parent = Content
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = ChatList

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
        MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
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
        UserLabel.Parent = MsgFrame

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Text = msgData.content or ""
        ContentLabel.Size = UDim2.new(1, -(UserLabel.AbsoluteSize.X + 10), 0, 0)
        ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
        ContentLabel.Position = UDim2.new(0, UserLabel.AbsoluteSize.X + 5, 0, 0)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextSize = 13
        ContentLabel.TextWrapped = true
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.Parent = MsgFrame
    end

    SendBtn.MouseButton1Click:Connect(function()
        if TextBox.Text == "" then return end
        local txt = TextBox.Text
        TextBox.Text = ""
        task.spawn(function()
            APIRequest("/messages/global", "POST", {username = LocalPlayer.Name, content = txt})
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                for _, c in pairs(ChatList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, m in pairs(msgs) do RenderMessage(m) end
            end
        end)
    end)

    task.spawn(function()
        while ChatList.Parent do
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                for _, c in pairs(ChatList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, m in pairs(msgs) do RenderMessage(m) end
                ChatList.CanvasPosition = Vector2.new(0, 9999)
            end
            task.wait(3)
        end
    end)
end

-- // PROFILE //
local function LoadProfile()
    local PContainer = Instance.new("ScrollingFrame")
    PContainer.Size = UDim2.new(1, 0, 1, 0)
    PContainer.BackgroundTransparency = 1
    PContainer.Parent = Content
    
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
    User.Parent = PContainer
    
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
    end
    MkBtn("Friends List", 110, Color3.fromRGB(60,60,65))
    MkBtn("Blocked Users", 150, Color3.fromRGB(60,60,65))
end

-- // SETTINGS //
local function LoadSettings()
    local SLabel = Instance.new("TextLabel")
    SLabel.Text = "Notifications"
    SLabel.Size = UDim2.new(1,0,0,30)
    SLabel.TextColor3 = Color3.new(1,1,1)
    SLabel.BackgroundTransparency = 1
    SLabel.Font = Enum.Font.GothamBold
    SLabel.Parent = Content
    
    local Toggle = Instance.new("TextButton")
    Toggle.Text = "Enabled"
    Toggle.Size = UDim2.new(0.5, 0, 0, 30)
    Toggle.Position = UDim2.new(0.25, 0, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    Toggle.Parent = Content
    local c = Instance.new("UICorner"); c.Parent = Toggle
    Toggle.MouseButton1Click:Connect(function()
        if Toggle.Text == "Enabled" then
            Toggle.Text = "Disabled"; Toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            Toggle.Text = "Enabled"; Toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
end

CreateTabBtn("Global Chat", 0, LoadChat)
CreateTabBtn("Profile", 1, LoadProfile)
CreateTabBtn("Settings", 2, LoadSettings)
LoadChat()

-- // POLLING //
task.spawn(function()
    while ScreenGui.Parent do
        local data = APIRequest("/online-count", "GET")
        if data and data.count then OnlineText.Text = "Online: " .. tostring(data.count) end
        task.wait(10)
    end
end)