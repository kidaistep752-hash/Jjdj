-- ====================================================================
--  PART 1: MAIN SERVICES & CORE STATE CONFIG
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Полная очистка старых версий интерфейса
if CoreGui:FindFirstChild("SimpleNeonSense") then
    CoreGui.SimpleNeonSense:Destroy()
end

local FILE_NAME = "SimpleNeon_Config.json"
local Config = {
    Speedhack = false, SpeedValue = 16,
    Noclip = false,
    SelectedPlayer = "",
    Target = false,
    GodMode = false,
    InfHealth = false,
    AntiDie = false,
    SpinBot = false,
    SpinSpeed = 30
}

local function saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

local function loadSettings()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
        if success then 
            for k, v in pairs(decoded) do 
                if k ~= "Target" and k ~= "Speedhack" and k ~= "SpinBot" then Config[k] = v end
            end
        end
    end
end
loadSettings()

local SavedPositionBeforeTP = nil
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleNeonSense"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
-- ====================================================================
--  PART 2: MOBILE DRAGGING CORE SYSTEM
-- ====================================================================
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
-- ====================================================================
--  PART 3: STYLISH ROUNDED WINDOW INTERFACE
-- ====================================================================
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0, 140)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "⚙️"
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.fromRGB(186, 85, 211)
OpenButton.Parent = ScreenGui
makeDraggable(OpenButton)

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", OpenButton)
ButtonStroke.Color = Color3.fromRGB(186, 85, 211)
ButtonStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(186, 85, 211)
MainStroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TopLayout = Instance.new("UIListLayout", TopBar)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 20)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
-- ====================================================================
--  PART 4: TAB CREATOR & BASE TOGGLE BUILDER
-- ====================================================================
local pages = {}
local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 75, 0, 30)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.Parent = TopBar

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 0
    Page.Parent = Container

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(120, 120, 120)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    end)
    pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

local pPlayer = createTab("Player")
local pGame = createTab("Game")
local pOther = createTab("Other")
local pSettings = createTab("Settings")

pages["Player"].Page.Visible = true
pages["Player"].Btn.TextColor3 = Color3.fromRGB(186, 85, 211)

local function createRoundedToggle(parent, text, onClick)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    Btn.TextSize = 13
    Btn.TextWrapped = true
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text .. (state and " [ON]" or " [OFF]")
        Btn.TextColor3 = state and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(160, 160, 160)
        onClick(state)
    end)
end
-- ====================================================================
--  PART 5: PLAYER TAB ELEMENTS (SPEEDHACK, SPIN BOT, GODMODES)
-- ====================================================================
local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(1, 0, 0, 32)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Parent = pPlayer

local SpeedArrow = Instance.new("TextButton", SpeedContainer)
SpeedArrow.Size = UDim2.new(0, 25, 1, 0)
SpeedArrow.BackgroundTransparency = 1
SpeedArrow.Text = "▶"
SpeedArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
SpeedArrow.TextSize = 14

local SpeedToggle = Instance.new("TextButton", SpeedContainer)
SpeedToggle.Size = UDim2.new(1, -30, 1, 0)
SpeedToggle.Position = UDim2.new(0, 30, 0, 0)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SpeedToggle.Text = "Speedhack (" .. tostring(Config.SpeedValue) .. ") [OFF]"
SpeedToggle.TextColor3 = Color3.fromRGB(160, 160, 160)
SpeedToggle.TextSize = 13
SpeedToggle.TextWrapped = true
Instance.new("UICorner", SpeedToggle).CornerRadius = UDim.new(0, 6)

local SpeedSliderFrame = Instance.new("Frame", pPlayer)
SpeedSliderFrame.Size = UDim2.new(1, 0, 0, 25)
SpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
SpeedSliderFrame.Visible = false
Instance.new("UICorner", SpeedSliderFrame).CornerRadius = UDim.new(0, 6)

local SpeedBar = Instance.new("Frame", SpeedSliderFrame)
SpeedBar.Size = UDim2.new(1, -20, 0, 4)
SpeedBar.Position = UDim2.new(0, 10, 0, 10)
SpeedBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local SpeedPoint = Instance.new("Frame", SpeedBar)
SpeedPoint.Size = UDim2.new(0, 8, 0, 12)
SpeedPoint.Position = UDim2.new((Config.SpeedValue - 16) / (300 - 16), -4, 0.5, -6)
SpeedPoint.BackgroundColor3 = Color3.fromRGB(186, 85, 211)

SpeedArrow.MouseButton1Click:Connect(function()
    SpeedSliderFrame.Visible = not SpeedSliderFrame.Visible
    SpeedArrow.Text = SpeedSliderFrame.Visible and "▼" or "▶"
end)

SpeedToggle.MouseButton1Click:Connect(function()
    Config.Speedhack = not Config.Speedhack
    saveSettings()
    SpeedToggle.Text = "Speedhack (" .. tostring(Config.SpeedValue) .. ") " .. (Config.Speedhack and "[ON]" or "[OFF]")
    SpeedToggle.TextColor3 = Config.Speedhack and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(160, 160, 160)
end)

local function updateSpeedSlider(input)
    local relX = math.clamp((input.Position.X - SpeedBar.AbsolutePosition.X) / SpeedBar.AbsoluteSize.X, 0, 1)
    SpeedPoint.Position = UDim2.new(relX, -4, 0.5, -6)
    local val = math.floor(16 + (300 - 16) * relX)
    Config.SpeedValue = val
    SpeedToggle.Text = "Speedhack (" .. tostring(val) .. ") " .. (Config.Speedhack and "[ON]" or "[OFF]")
    saveSettings()
end

SpeedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        updateSpeedSlider(input)
        local moveCon
        moveCon = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateSpeedSlider(moveInput)
            end
        end)
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then moveCon:Disconnect() end end)
    end
end)

local SpinContainer = Instance.new("Frame", pPlayer)
SpinContainer.Size = UDim2.new(1, 0, 0, 32)
SpinContainer.BackgroundTransparency = 1

local SpinArrow = Instance.new("TextButton", SpinContainer)
SpinArrow.Size = UDim2.new(0, 25, 1, 0)
SpinArrow.BackgroundTransparency = 1
SpinArrow.Text = "▶"
SpinArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
SpinArrow.TextSize = 14

local SpinToggle = Instance.new("TextButton", SpinContainer)
SpinToggle.Size = UDim2.new(1, -30, 1, 0)
SpinToggle.Position = UDim2.new(0, 30, 0, 0)
SpinToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
SpinToggle.Text = "Spin Bot (" .. tostring(Config.SpinSpeed) .. ") [OFF]"
SpinToggle.TextColor3 = Color3.fromRGB(160, 160, 160)
SpinToggle.TextSize = 13
SpinToggle.TextWrapped = true
Instance.new("UICorner", SpinToggle).CornerRadius = UDim.new(0, 6)

local SpinSliderFrame = Instance.new("Frame", pPlayer)
SpinSliderFrame.Size = UDim2.new(1, 0, 0, 25)
SpinSliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
SpinSliderFrame.Visible = false
Instance.new("UICorner", SpinSliderFrame).CornerRadius = UDim.new(0, 6)

local SpinBar = Instance.new("Frame", SpinSliderFrame)
SpinBar.Size = UDim2.new(1, -20, 0, 4)
SpinBar.Position = UDim2.new(0, 10, 0, 10)
SpinBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local SpinPoint = Instance.new("Frame", SpinBar)
SpinPoint.Size = UDim2.new(0, 8, 0, 12)
SpinPoint.Position = UDim2.new((Config.SpinSpeed - 10) / (150 - 10), -4, 0.5, -6)
SpinPoint.BackgroundColor3 = Color3.fromRGB(186, 85, 211)

SpinArrow.MouseButton1Click:Connect(function()
    SpinSliderFrame.Visible = not SpinSliderFrame.Visible
    SpinArrow.Text = SpinSliderFrame.Visible and "▼" or "▶"
end)

SpinToggle.MouseButton1Click:Connect(function()
    Config.SpinBot = not Config.SpinBot
    saveSettings()
    SpinToggle.Text = "Spin Bot (" .. tostring(Config.SpinSpeed) .. ") " .. (Config.SpinBot and "[ON]" or "[OFF]")
    SpinToggle.TextColor3 = Config.SpinBot and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(160, 160, 160)
end)

local function updateSpinSlider(input)
    local relX = math.clamp((input.Position.X - SpinBar.AbsolutePosition.X) / SpinBar.AbsoluteSize.X, 0, 1)
    SpinPoint.Position = UDim2.new(relX, -4, 0.5, -6)
    local val = math.floor(10 + (150 - 10) * relX)
    Config.SpinSpeed = val
    SpinToggle.Text = "Spin Bot (" .. tostring(val) .. ") " .. (Config.SpinBot and "[ON]" or "[OFF]")
    saveSettings()
end

SpinBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        updateSpinSlider(input)
        local moveCon
        moveCon = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                updateSpinSlider(moveInput)
            end
        end)
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then moveCon:Disconnect() end end)
    end
end)

createRoundedToggle(pPlayer, "Noclip through Walls", function(v) Config.Noclip = v saveSettings() end)
createRoundedToggle(pPlayer, "Ghost God Mode (Ghost)", function(v) 
    Config.GodMode = v 
    if v and LocalPlayer.Character then
        local cam = workspace.CurrentCamera
        local oldCF = cam.CFrame
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.2)
        cam.CFrame = oldCF
    end
end)
createRoundedToggle(pPlayer, "Infinite Health (Loop)", function(v) Config.InfHealth = v end)
createRoundedToggle(pPlayer, "Anti-Die Teleport (Auto TP)", function(v) Config.AntiDie = v end)
-- ====================================================================
--  PART 6: GAME, OTHER & SETTINGS (TARGET ENGINE & MATCHMAKING)
-- ====================================================================
local GameContainer = Instance.new("Frame")
GameContainer.Size = UDim2.new(1, 0, 0, 32)
GameContainer.BackgroundTransparency = 1
GameContainer.Parent = pGame

local TargetToggle = Instance.new("TextButton", GameContainer)
TargetToggle.Size = UDim2.new(1, -35, 1, 0)
TargetToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
TargetToggle.Text = "Target [OFF]"
TargetToggle.TextColor3 = Color3.fromRGB(160, 160, 160)
TargetToggle.TextSize = 13
TargetToggle.TextWrapped = true
Instance.new("UICorner", TargetToggle).CornerRadius = UDim.new(0, 6)

local TargetArrow = Instance.new("TextButton", GameContainer)
TargetArrow.Size = UDim2.new(0, 30, 1, 0)
TargetArrow.Position = UDim2.new(1, -30, 0, 0)
TargetArrow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
TargetArrow.Text = "▶"
TargetArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
Instance.new("UICorner", TargetArrow).CornerRadius = UDim.new(0, 6)

local Dropdown = Instance.new("ScrollingFrame", GameContainer)
Dropdown.Size = UDim2.new(1, 0, 0, 90)
Dropdown.Position = UDim2.new(0, 0, 1, 5)
Dropdown.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Dropdown.Visible = false
Dropdown.ZIndex = 5
Dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
Dropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 6)
Instance.new("UIListLayout", Dropdown)

local function refreshDropdown()
    for _, child in pairs(Dropdown:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local PBtn = Instance.new("TextButton", Dropdown)
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            PBtn.TextSize = 12
            PBtn.ZIndex = 6
            PBtn.MouseButton1Click:Connect(function()
                Config.SelectedPlayer = p.Name
                TargetToggle.Text = "Target: " .. p.Name
                Dropdown.Visible = false
                TargetArrow.Text = "▶"
                saveSettings()
            end)
        end
    end
end

TargetArrow.MouseButton1Click:Connect(function()
    Dropdown.Visible = not Dropdown.Visible
    TargetArrow.Text = Dropdown.Visible and "▼" or "▶"
    if Dropdown.Visible then refreshDropdown() end
end)

TargetToggle.MouseButton1Click:Connect(function()
    if Config.SelectedPlayer == "" then return end
    Config.Target = not Config.Target
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if Config.Target then
        TargetToggle.Text = "Stuck to: " .. Config.SelectedPlayer
        TargetToggle.TextColor3 = Color3.fromRGB(186, 85, 211)
        if myHRP then SavedPositionBeforeTP = myHRP.CFrame end
    else
        TargetToggle.Text = "Target [OFF]"
        TargetToggle.TextColor3 = Color3.fromRGB(160, 160, 160)
        if SavedPositionBeforeTP and myHRP then
            myHRP.CFrame = SavedPositionBeforeTP
            SavedPositionBeforeTP = nil
        end
    end
end)

local RejoinBtn = Instance.new("TextButton", pOther)
RejoinBtn.Size = UDim2.new(1, 0, 0, 32)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
RejoinBtn.Text = "Server Rejoin"
RejoinBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
RejoinBtn.TextSize = 13
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 6)

local PrivateBtn = Instance.new("TextButton", pOther)
PrivateBtn.Size = UDim2.new(1, 0, 0, 32)
PrivateBtn.BackgroundColor3 = Color3.fromRGB(22, 14, 25)
PrivateBtn.BorderSizePixel = 1
PrivateBtn.BorderColor3 = Color3.fromRGB(186, 85, 211)
PrivateBtn.Text = "Private Server Matchmaking"
PrivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrivateBtn.Font = Enum.Font.SourceSansBold
PrivateBtn.TextSize = 13
Instance.new("UICorner", PrivateBtn).CornerRadius = UDim.new(0, 6)

RejoinBtn.MouseButton1Click:Connect(function()
    saveSettings()
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end)

PrivateBtn.MouseButton1Click:Connect(function()
    PrivateBtn.Text = "Scanning active instances..."
    PrivateBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    saveSettings()
    
    local teleportOptions = Instance.new("TeleportOptions")
    local targetJobId = nil
    local lowestPlayers = math.huge
    
    local apiURL = "https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"
    local httpSuccess, httpResult = pcall(function() return game:HttpGet(apiURL) end)
    
    if httpSuccess and httpResult then
        local serverData = HttpService:JSONDecode(httpResult)
        if serverData and serverData.data then
            for _, server in pairs(serverData.data) do
                if server.id ~= game.JobId and server.playing then
                    if server.playing < lowestPlayers then
                        lowestPlayers = server.playing
                        targetJobId = server.id
                    end
                end
            end
        end
    end
    
    if targetJobId then
        PrivateBtn.Text = "Empty server found! Connecting..."
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
    else
        PrivateBtn.Text = "API blocked. Creating new instance..."
        task.wait(1)
        teleportOptions.ShouldReserveServer = false
        local asyncSuccess, asyncError = pcall(function()
            TeleportService:TeleportAsync(game.PlaceId, {LocalPlayer}, teleportOptions)
        end)
        if not asyncSuccess then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    end
end)

local infoLabel = Instance.new("TextLabel", pSettings)
infoLabel.Size = UDim2.new(1, 0, 0, 30)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "All settings auto-save to JSON file"
infoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
infoLabel.TextSize = 12
-- ====================================================================
--  PART 7: PHYSICS CONTROL & RUNTIME TICK ENGINE
-- ====================================================================
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end

    if Config.Speedhack then Hum.WalkSpeed = Config.SpeedValue else Hum.WalkSpeed = 16 end

    if Config.Noclip or Config.Target then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Config.Target and Config.SelectedPlayer ~= "" then
        local victim = Players:FindFirstChild(Config.SelectedPlayer)
        if victim and victim.Character and victim.Character:FindFirstChild("HumanoidRootPart") then
            HRP.CFrame = victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 2.2)
            HRP.Velocity = Vector3.new(0, 0, 0)
        else
            Config.Target = false
            if SavedPositionBeforeTP then HRP.CFrame = SavedPositionBeforeTP SavedPositionBeforeTP = nil end
        end
    end

    if Config.InfHealth then Hum.Health = Hum.MaxHealth end

    if Config.AntiDie and Hum.Health > 0 and Hum.Health < 25 then
        local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
        if spawnLocation then
            HRP.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
        else
            HRP.CFrame = CFrame.new(0, 50, 0)
        end
    end

    local spinObject = HRP:FindFirstChild("NeonSpinBot")
    if Config.SpinBot then
        if not spinObject then
            spinObject = Instance.new("AngularVelocity")
            spinObject.Name = "NeonSpinBot"
            spinObject.MaxTorque = math.huge
            spinObject.Attachment0 = HRP:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", HRP)
            spinObject.Parent = HRP
        end
        spinObject.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
    else
        if spinObject then spinObject:Destroy() end
    end
end)
