-- JanBlox v1.0.0
-- Simple, No Animations, All Devices Compatible
-- Features: Loading, UI, Minimizable, Closable, Online Count, Global Chat, Profiles, Social

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local API_URL = "https://global-chat-api-0qdb.onrender.com"

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JanBloxUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "JanBlox v1.0.0 | Online: 0"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = TitleBar

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Chat Area
local ChatBox = Instance.new("ScrollingFrame")
ChatBox.Size = UDim2.new(1, -20, 0.7, 0)
ChatBox.Position = UDim2.new(0, 10, 0, 10)
ChatBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ChatBox.CanvasSize = UDim2.new(0, 0, 5, 0)
ChatBox.Parent = Content

local ChatInput = Instance.new("TextBox")
ChatInput.Size = UDim2.new(1, -80, 0, 30)
ChatInput.Position = UDim2.new(0, 10, 0.7, 20)
ChatInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ChatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatInput.PlaceholderText = "Type message..."
ChatInput.Text = ""
ChatInput.Parent = Content

local SendBtn = Instance.new("TextButton")
SendBtn.Text = "Send"
SendBtn.Size = UDim2.new(0, 60, 0, 30)
SendBtn.Position = UDim2.new(1, -70, 0.7, 20)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.Parent = Content

-- Functions
local function updateOnlineCount()
    spawn(function()
        while wait(10) do
            local success, response = pcall(function()
                return HttpService:GetAsync(API_URL .. "/online-count")
            end)
            if success then
                local data = HttpService:JSONDecode(response)
                TitleLabel.Text = "JanBlox v1.0.0 | Online: " .. (data.count or 0)
            end
        end
    end)
end

local function fetchMessages()
    spawn(function()
        while wait(3) do
            local success, response = pcall(function()
                return HttpService:GetAsync(API_URL .. "/messages/global")
            end)
            if success then
                local msgs = HttpService:JSONDecode(response)
                -- Clear and redraw (Simple approach)
                for _, v in pairs(ChatBox:GetChildren()) do v:Destroy() end
                local yOffset = 0
                for _, m in ipairs(msgs) do
                    local msgLabel = Instance.new("TextLabel")
                    msgLabel.Text = "[" .. m.username .. "]: " .. m.content
                    msgLabel.Size = UDim2.new(1, 0, 0, 20)
                    msgLabel.Position = UDim2.new(0, 5, 0, yOffset)
                    msgLabel.BackgroundTransparency = 1
                    msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
                    msgLabel.Parent = ChatBox
                    yOffset = yOffset + 20
                end
            end
        end
    end)
end

SendBtn.MouseButton1Click:Connect(function()
    local text = ChatInput.Text
    if text ~= "" then
        local data = {
            userId = LocalPlayer.UserId,
            username = LocalPlayer.Name,
            content = text,
            channel = "global"
        }
        pcall(function()
            HttpService:PostAsync(API_URL .. "/send-message", HttpService:JSONEncode(data))
        end)
        ChatInput.Text = ""
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 400, 0, 30)
        Content.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 300)
        Content.Visible = true
        MinBtn.Text = "-"
    end
end)

-- Initialize
updateOnlineCount()
fetchMessages()

-- Heartbeat status
spawn(function()
    while wait(60) do
        pcall(function()
            HttpService:PostAsync(API_URL .. "/update-status", HttpService:JSONEncode({
                userId = LocalPlayer.UserId,
                username = LocalPlayer.Name
            }))
        end)
    end
end)

print("JanBlox v1.0.0 Loaded!")
