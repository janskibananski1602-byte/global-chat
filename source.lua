--[[
    JanBlox v1.0.0 (Strict Boxy Edition)
    - No UICorners (Sharp Edges)
    - Advanced Error Handling
    - Long Loading Sequence
    - Double Draggable (Window + Mini Button)
    - Real Data Only
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

-- Settings Cache
local Settings = {
    AutoScroll = true,
    Notifications = true
}

-- // ERROR HANDLER //
local function NotifyError(msg)
    if Settings.Notifications then
        StarterGui:SetCore("SendNotification", {
            Title = "JanBlox Error",
            Text = msg,
            Duration = 5
        })
    end
    warn("[JanBlox Error]: " .. msg)
end

-- // HTTP COMPATIBILITY //
local http_request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
if not http_request then
    NotifyError("Executor missing HTTP support!")
    return
end

-- // API WRAPPER //
local function APIRequest(endpoint, method, body)
    local response = nil
    local success, err = pcall(function()
        local headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "JanBlox/" .. VERSION
        }
        local options = {
            Url = API_URL .. endpoint,
            Method = method or "GET",
            Headers = headers
        }
        if body then options.Body = HttpService:JSONEncode(body) end
        response = http_request(options)
    end)

    if not success then
        NotifyError("Connection Failed: " .. tostring(err))
        return nil
    end

    if response.StatusCode ~= 200 then
        NotifyError("API Error: " .. tostring(response.StatusCode))
        return nil
    end

    if response.Body then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        if decodeSuccess then 
            return decoded 
        else
            NotifyError("Failed to parse JSON data.")
        end
    end
    return nil
end

-- // UI CLEANUP //
if CoreGui:FindFirstChild("JanBloxBoxy") then
    CoreGui.JanBloxBoxy:Destroy()
end

-- // UI CONSTRUCTION //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxBoxy"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. LONG LOADING SCREEN
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 0, 5)
LoadingBar.Position = UDim2.new(0, 0, 0.5, 20)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Text = "Initializing..."
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.Position = UDim2.new(0, 0, 0, -20)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 20
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.Parent = LoadingFrame

-- Loading Sequence (No Tweens, just loops)
local stages = {"Connecting to Cloudflare...", "Handshaking...", "Fetching Profile...", "Loading UI..."}
for i = 1, 4 do
    LoadingText.Text = stages[i]
    LoadingBar.Size = UDim2.new(i/4, 0, 0, 5)
    task.wait(0.8) -- Total ~3.2 seconds
end
task.wait(0.5)
LoadingFrame:Destroy()

-- // DRAG LOGIC (Universal) //
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

-- 2. FLOATING MINIMIZE BUTTON (Boxy)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 40, 0, 40)
MiniBtn.Position = UDim2.new(0, 20, 0.5, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MiniBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
MiniBtn.BorderSizePixel = 2
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Text = "JB"
MiniBtn.TextSize = 18
MiniBtn.Font = Enum.Font.SourceSansBold
MiniBtn.Visible = false -- Hidden initially
MiniBtn.Parent = ScreenGui

MakeDraggable(MiniBtn, MiniBtn)

-- 3. MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 120, 255) -- Blue Border Accent
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderColor3 = Color3.fromRGB(50, 50, 50)
TopBar.BorderSizePixel = 1
TopBar.Parent = MainFrame

MakeDraggable(MainFrame, TopBar)

local Title = Instance.new("TextLabel")
Title.Text = " JANBLOX " .. VERSION
Title.Size = UDim2.new(0.4, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = TopBar

local OnlineText = Instance.new("TextLabel")
OnlineText.Text = "Online: --  "
OnlineText.Size = UDim2.new(0.3, 0, 1, 0)
OnlineText.Position = UDim2.new(0.5, 0, 0, 0)
OnlineText.BackgroundTransparency = 1
OnlineText.TextColor3 = Color3.fromRGB(0, 255, 100)
OnlineText.TextXAlignment = Enum.TextXAlignment.Right
OnlineText.Font = Enum.Font.SourceSans
OnlineText.TextSize = 14
OnlineText.Parent = TopBar

-- Control Buttons
local function CreateCtrlBtn(text, xOff, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 35, 1, 0)
    btn.Position = UDim2.new(1, xOff, 0, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = TopBar
    btn.MouseButton1Click:Connect(callback)
end

CreateCtrlBtn("X", -35, Color3.fromRGB(180, 50, 50), function() ScreenGui:Destroy() end)

-- Minimize Logic
local function ToggleState(mode)
    if mode == "min" then
        MainFrame.Visible = false
        MiniBtn.Visible = true
    else
        MainFrame.Visible = true
        MiniBtn.Visible = false
    end
end

CreateCtrlBtn("_", -70, Color3.fromRGB(60, 60, 60), function() ToggleState("min") end)
MiniBtn.MouseButton1Click:Connect(function() ToggleState("open") end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderColor3 = Color3.fromRGB(50, 50, 50)
Sidebar.BorderSizePixel = 1
Sidebar.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -35)
Content.Position = UDim2.new(0, 140, 0, 35)
Content.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- Tab System
local function ClearContent()
    for _, child in pairs(Content:GetChildren()) do child:Destroy() end
end

local function CreateTab(text, index, func)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, index * 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Sidebar
    
    btn.MouseButton1Click:Connect(function()
        ClearContent()
        func()
    end)
end

-- // TAB 1: GLOBAL CHAT //
local function LoadChat()
    local ChatBox = Instance.new("ScrollingFrame")
    ChatBox.Size = UDim2.new(1, -2, 1, -42)
    ChatBox.Position = UDim2.new(0, 1, 0, 1)
    ChatBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ChatBox.BorderSizePixel = 0
    ChatBox.ScrollBarThickness = 6
    ChatBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatBox.CanvasSize = UDim2.new(0,0,0,0)
    ChatBox.Parent = Content
    
    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)
    UIList.Parent = ChatBox

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.8, -2, 0, 40)
    Input.Position = UDim2.new(0, 1, 1, -41)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Input.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Input.BorderSizePixel = 1
    Input.Text = ""
    Input.PlaceholderText = " Type your message..."
    Input.TextColor3 = Color3.new(1,1,1)
    Input.Font = Enum.Font.SourceSans
    Input.TextSize = 16
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.Parent = Content

    local Send = Instance.new("TextButton")
    Send.Text = "SEND"
    Send.Size = UDim2.new(0.2, -2, 0, 40)
    Send.Position = UDim2.new(0.8, 1, 1, -41)
    Send.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Send.BorderColor3 = Color3.fromRGB(0, 120, 255)
    Send.BorderSizePixel = 1
    Send.TextColor3 = Color3.new(1,1,1)
    Send.Font = Enum.Font.SourceSansBold
    Send.TextSize = 14
    Send.Parent = Content

    local function AddMsg(data)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.Parent = ChatBox
        
        local txt = Instance.new("TextLabel")
        txt.Text = string.format("[%s]: %s", data.username or "?", data.content or "")
        txt.Size = UDim2.new(1, -10, 0, 0)
        txt.Position = UDim2.new(0, 5, 0, 0)
        txt.AutomaticSize = Enum.AutomaticSize.Y
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.SourceSans
        txt.TextSize = 14
        txt.TextWrapped = true
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = frame
    end

    Send.MouseButton1Click:Connect(function()
        if Input.Text == "" then return end
        local msg = Input.Text
        Input.Text = ""
        
        task.spawn(function()
            APIRequest("/messages/global", "POST", {
                username = LocalPlayer.Name,
                userId = LocalPlayer.UserId,
                content = msg
            })
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                for _,c in pairs(ChatBox:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _,m in pairs(msgs) do AddMsg(m) end
                if Settings.AutoScroll then ChatBox.CanvasPosition = Vector2.new(0, 99999) end
            end
        end)
    end)

    task.spawn(function()
        while ChatBox.Parent do
            local msgs = APIRequest("/messages/global", "GET")
            if msgs then
                -- Lazy refresh
                local count = 0
                for _,c in pairs(ChatBox:GetChildren()) do if c:IsA("Frame") then count=count+1 end end
                if count ~= #msgs then
                    for _,c in pairs(ChatBox:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    for _,m in pairs(msgs) do AddMsg(m) end
                    if Settings.AutoScroll then ChatBox.CanvasPosition = Vector2.new(0, 99999) end
                end
            end
            task.wait(4)
        end
    end)
end

-- // TAB 2: REAL PROFILE //
local function LoadProfile()
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.Parent = Content

    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(0, 100, 0, 100)
    Img.Position = UDim2.new(0, 20, 0, 20)
    Img.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Img.BorderColor3 = Color3.fromRGB(255,255,255)
    Img.BorderSizePixel = 1
    Img.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
    Img.Parent = Scroll

    local function Label(txt, y, size)
        local l = Instance.new("TextLabel")
        l.Text = txt
        l.Position = UDim2.new(0, 130, 0, y)
        l.Size = UDim2.new(0, 200, 0, 20)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1,1,1)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.SourceSansBold
        l.TextSize = size
        l.Parent = Scroll
    end

    Label(LocalPlayer.DisplayName, 20, 24)
    Label("@" .. LocalPlayer.Name, 50, 18)
    Label("ID: " .. LocalPlayer.UserId, 80, 14)
    Label("Age: " .. LocalPlayer.AccountAge .. " days", 100, 14)
    
    local function StatBox(txt, y)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.9, 0, 0, 40)
        f.Position = UDim2.new(0.05, 0, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(40,40,40)
        f.BorderColor3 = Color3.fromRGB(60,60,60)
        f.BorderSizePixel = 1
        f.Parent = Scroll
        
        local t = Instance.new("TextLabel")
        t.Text = txt
        t.Size = UDim2.new(1, -10, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1,1,1)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Font = Enum.Font.SourceSans
        t.TextSize = 16
        t.Parent = f
    end
    
    StatBox("Client Version: " .. VERSION, 140)
    StatBox("Exploit: " .. (identifyexecutor and identifyexecutor() or "Unknown"), 190)
end

-- // TAB 3: SETTINGS //
local function LoadSettings()
    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 10)
    List.Parent = Content
    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 10)
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.Parent = Content

    local function Toggle(txt, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 40)
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        btn.BorderColor3 = Color3.fromRGB(200,200,200)
        btn.BorderSizePixel = 1
        btn.Text = txt .. ": " .. (Settings[key] and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = Content
        
        btn.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            btn.Text = txt .. ": " .. (Settings[key] and "ON" or "OFF")
        end)
    end
    
    local function Action(txt, func)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.BorderColor3 = Color3.fromRGB(80,80,80)
        btn.BorderSizePixel = 1
        btn.Text = txt
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = Content
        btn.MouseButton1Click:Connect(func)
    end

    Toggle("Chat Auto-Scroll", "AutoScroll")
    Toggle("Error Notifications", "Notifications")
    Action("Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    Action("Copy API URL", function() if setclipboard then setclipboard(API_URL) end end)
end

-- // INIT //
CreateTab("GLOBAL CHAT", 0, LoadChat)
CreateTab("PROFILE", 1, LoadProfile)
CreateTab("SETTINGS", 2, LoadSettings)
LoadChat()

-- // ONLINE POLL //
task.spawn(function()
    while ScreenGui.Parent do
        local data = APIRequest("/online-count", "GET")
        if data and data.count then
            OnlineText.Text = "Online: " .. tostring(data.count) .. "  "
        else
            OnlineText.Text = "Online: ERR  "
        end
        task.wait(10)
    end
end)