--[[
    JanBlox v1.0.0
    - Real HTTP Networking
    - Draggable GUI & Draggable Minimized Button
    - Real LocalPlayer Statistics
    - Global Chat & Settings
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local API_URL = "https://global-chat-fr.janskibananski1602.workers.dev"
local VERSION = "v1.0.0"

-- Settings Cache
local Settings = {
    AutoScroll = true,
    Notifications = true
}

-- // HTTP CHECK //
local http_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not http_request then
    game.StarterGui:SetCore("SendNotification", {
        Title = "JanBlox Error",
        Text = "Your executor does not support HTTP requests. Script stopped."
    })
    return
end

-- // API WRAPPER //
local function APIRequest(endpoint, method, body)
    local response = nil
    local success, err = pcall(function()
        local headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "JanBlox-Client/" .. VERSION
        }
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
if CoreGui:FindFirstChild("JanBloxMain") then
    CoreGui.JanBloxMain:Destroy()
end

-- // UI CONSTRUCTION //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxMain"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "Loading JanBlox " .. VERSION .. "..."
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 24
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Parent = LoadingFrame

task.wait(1)
LoadingFrame:Destroy()

-- // DRAGGABLE LOGIC (UNIVERSAL) //
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        elseif input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

-- 2. Floating Minimize Button
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 30, 0.5, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Text = "JB"
MiniBtn.TextSize = 20
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.Visible = false -- Hidden by default
MiniBtn.AutoButtonColor = false
MiniBtn.Parent = ScreenGui

local MiniStroke = Instance.new("UIStroke"); MiniStroke.Color = Color3.fromRGB(80, 80, 80); MiniStroke.Thickness = 2; MiniStroke.Parent = MiniBtn
local MiniCorner = Instance.new("UICorner"); MiniCorner.CornerRadius = UDim.new(0, 12); MiniCorner.Parent = MiniBtn

MakeDraggable(MiniBtn, MiniBtn) -- Make the button draggable

-- 3. Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 6); MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 6); TopCorner.Parent = TopBar
local TopFiller = Instance.new("Frame"); TopFiller.Size = UDim2.new(1,0,0,10); TopFiller.Position=UDim2.new(0,0,1,-10); TopFiller.BackgroundColor3=TopBar.BackgroundColor3; TopFiller.BorderSizePixel=0; TopFiller.Parent=TopBar

MakeDraggable(MainFrame, TopBar) -- Make the main window draggable

local Title = Instance.new("TextLabel")
Title.Text = "  JanBlox " .. VERSION
Title.Size = UDim2.new(0.4, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TopBar

local OnlineText = Instance.new("TextLabel")
OnlineText.Text = "Online: ...  "
OnlineText.Size = UDim2.new(0.3, 0, 1, 0)
OnlineText.Position = UDim2.new(0.45, 0, 0, 0)
OnlineText.BackgroundTransparency = 1
OnlineText.TextColor3 = Color3.fromRGB(0, 255, 120)
OnlineText.TextXAlignment = Enum.TextXAlignment.Right
OnlineText.Font = Enum.Font.Gotham
OnlineText.TextSize = 13
OnlineText.Parent = TopBar

-- Window Controls
local function CreateControlBtn(text, xOff, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(1, xOff, 0, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = TopBar
    
    if text == "X" then
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
        local f = Instance.new("Frame"); f.Size = UDim2.new(0,5,1,0); f.BackgroundTransparency=1; f.Parent=btn
    end
    
    btn.MouseButton1Click:Connect(callback)
end

-- Close
CreateControlBtn("X", -40, Color3.fromRGB(220, 60, 60), function()
    ScreenGui:Destroy()
end)

-- Minimize Logic
local function ToggleState(state)
    if state == "min" then
        MainFrame.Visible = false
        MiniBtn.Visible = true
    else
        MainFrame.Visible = true
        MiniBtn.Visible = false
    end
end

CreateControlBtn("-", -80, Color3.fromRGB(70, 70, 70), function()
    ToggleState("min")
end)

MiniBtn.MouseButton1Click:Connect(function()
    ToggleState("open")
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -130, 1, -40)
Content.Position = UDim2.new(0, 130, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Tab System
local function ClearContent()
    for _, child in pairs(Content:GetChildren()) do child:Destroy() end
end

local function CreateTabBtn(text, index, func)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 10 + (index * 40))
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Sidebar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        ClearContent()
        func()
    end)
end

-- // TAB: GLOBAL CHAT //
local function LoadChat()
    local ChatScroll = Instance.new("ScrollingFrame")
    ChatScroll.Size = UDim2.new(1, -10, 1, -55)
    ChatScroll.Position = UDim2.new(0, 5, 0, 5)
    ChatScroll.BackgroundTransparency = 1
    ChatScroll.ScrollBarThickness = 4
    ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatScroll.CanvasSize = UDim2.new(0,0,0,0)
    ChatScroll.Parent = Content
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.Parent = ChatScroll

    -- Input Area
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -10, 0, 40)
    InputFrame.Position = UDim2.new(0, 5, 1, -45)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = Content

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.8, -5, 1, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TextBox.Text = ""
    TextBox.PlaceholderText = "Type message..."
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

    local function RenderMsg(data)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.Parent = ChatScroll
        
        local nameTag = Instance.new("TextLabel")
        nameTag.Text = "[" .. (data.username or "?") .. "]:"
        nameTag.Font = Enum.Font.GothamBold
        nameTag.TextColor3 = Color3.fromRGB(100, 200, 255)
        nameTag.TextSize = 14
        nameTag.Size = UDim2.new(0, 0, 0, 18)
        nameTag.AutomaticSize = Enum.AutomaticSize.X
        nameTag.BackgroundTransparency = 1
        nameTag.Parent = frame
        
        local msgContent = Instance.new("TextLabel")
        msgContent.Text = data.content or ""
        msgContent.Font = Enum.Font.Gotham
        msgContent.TextColor3 = Color3.new(1,1,1)
        msgContent.TextSize = 14
        msgContent.TextWrapped = true
        msgContent.TextXAlignment = Enum.TextXAlignment.Left
        msgContent.BackgroundTransparency = 1
        msgContent.AutomaticSize = Enum.AutomaticSize.Y
        msgContent.Position = UDim2.new(0, nameTag.AbsoluteSize.X + 6, 0, 0)
        msgContent.Size = UDim2.new(1, -(nameTag.AbsoluteSize.X + 6), 0, 0)
        msgContent.Parent = frame
    end

    -- Send Action
    SendBtn.MouseButton1Click:Connect(function()
        if TextBox.Text:gsub("%s+", "") == "" then return end
        local txt = TextBox.Text
        TextBox.Text = ""
        
        task.spawn(function()
            APIRequest("/messages/global", "POST", {
                username = LocalPlayer.Name,
                userId = LocalPlayer.UserId,
                content = txt
            })
            -- Instant refresh
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                for _,c in pairs(ChatScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _,m in pairs(msgs) do RenderMsg(m) end
                if Settings.AutoScroll then ChatScroll.CanvasPosition = Vector2.new(0, 99999) end
            end
        end)
    end)

    -- Auto Refresh Loop
    task.spawn(function()
        while ChatScroll.Parent do
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                -- Check if we need to redraw
                local currentChildren = 0
                for _,c in pairs(ChatScroll:GetChildren()) do if c:IsA("Frame") then currentChildren = currentChildren + 1 end end
                
                if #msgs ~= currentChildren then
                    for _,c in pairs(ChatScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    for _,m in pairs(msgs) do RenderMsg(m) end
                    if Settings.AutoScroll then ChatScroll.CanvasPosition = Vector2.new(0, 99999) end
                end
            end
            task.wait(2.5)
        end
    end)
end

-- // TAB: PROFILE (REAL DATA) //
local function LoadProfile()
    local PScroll = Instance.new("ScrollingFrame")
    PScroll.Size = UDim2.new(1, 0, 1, 0)
    PScroll.BackgroundTransparency = 1
    PScroll.Parent = Content
    
    -- Real Avatar
    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 80, 0, 80)
    AvatarImg.Position = UDim2.new(0, 15, 0, 15)
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    AvatarImg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    AvatarImg.Parent = PScroll
    local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(1,0); ac.Parent = AvatarImg
    
    -- Real Names
    local DispName = Instance.new("TextLabel")
    DispName.Text = LocalPlayer.DisplayName
    DispName.Font = Enum.Font.GothamBold
    DispName.TextSize = 22
    DispName.TextColor3 = Color3.new(1,1,1)
    DispName.TextXAlignment = Enum.TextXAlignment.Left
    DispName.Position = UDim2.new(0, 110, 0, 15)
    DispName.Size = UDim2.new(0, 200, 0, 25)
    DispName.BackgroundTransparency = 1
    DispName.Parent = PScroll
    
    local UserName = Instance.new("TextLabel")
    UserName.Text = "@" .. LocalPlayer.Name
    UserName.Font = Enum.Font.Gotham
    UserName.TextSize = 16
    UserName.TextColor3 = Color3.fromRGB(150, 150, 150)
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.Position = UDim2.new(0, 110, 0, 40)
    UserName.Size = UDim2.new(0, 200, 0, 20)
    UserName.BackgroundTransparency = 1
    UserName.Parent = PScroll
    
    -- Real Stats
    local function CreateStat(text, y)
        local l = Instance.new("TextLabel")
        l.Text = text
        l.Size = UDim2.new(1, -20, 0, 20)
        l.Position = UDim2.new(0, 15, 0, y)
        l.Font = Enum.Font.Gotham
        l.TextColor3 = Color3.fromRGB(200, 200, 200)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BackgroundTransparency = 1
        l.TextSize = 14
        l.Parent = PScroll
    end
    
    CreateStat("User ID: " .. LocalPlayer.UserId, 110)
    CreateStat("Account Age: " .. LocalPlayer.AccountAge .. " days", 135)
    CreateStat("Membership: " .. tostring(LocalPlayer.MembershipType), 160)
    
    -- Action Button
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Text = "Copy Profile Link"
    ActionBtn.Size = UDim2.new(0, 150, 0, 30)
    ActionBtn.Position = UDim2.new(0, 15, 0, 200)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    ActionBtn.TextColor3 = Color3.new(1,1,1)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Parent = PScroll
    local abc = Instance.new("UICorner"); abc.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile")
            ActionBtn.Text = "Copied!"
            task.wait(1)
            ActionBtn.Text = "Copy Profile Link"
        end
    end)
end

-- // TAB: SETTINGS //
local function LoadSettings()
    local SList = Instance.new("UIListLayout")
    SList.Padding = UDim.new(0, 10)
    SList.Parent = Content
    
    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.PaddingTop = UDim.new(0, 10)
    Pad.Parent = Content
    
    local function CreateToggle(text, settingName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 60, 60)
        btn.Text = text .. ": " .. (Settings[settingName] and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = Content
        local c = Instance.new("UICorner"); c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Settings[settingName] = not Settings[settingName]
            btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 60, 60)
            btn.Text = text .. ": " .. (Settings[settingName] and "ON" or "OFF")
        end)
    end
    
    local function CreateAction(text, col, func)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.BackgroundColor3 = col
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = Content
        local c = Instance.new("UICorner"); c.Parent = btn
        btn.MouseButton1Click:Connect(func)
    end

    CreateToggle("Chat Auto-Scroll", "AutoScroll")
    CreateToggle("Show Notifications", "Notifications")
    
    CreateAction("Rejoin Server", Color3.fromRGB(0, 100, 200), function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- // INITIALIZE //
CreateTabBtn("Global Chat", 0, LoadChat)
CreateTabBtn("My Profile", 1, LoadProfile)
CreateTabBtn("Settings", 2, LoadSettings)
LoadChat()

-- // ONLINE POLLER //
task.spawn(function()
    while ScreenGui.Parent do
        local data = APIRequest("/online-count", "GET")
        if data and data.count then
            OnlineText.Text = "Online: " .. tostring(data.count) .. "  "
        end
        task.wait(10)
    end
end)