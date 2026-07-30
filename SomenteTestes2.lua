-- ==========================================
-- TESTE ISOLADO: 6ª ABA (FLY E IY CORRIGIDOS)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Estados das Funções da 6ª Aba
local antiVoidActive = false
local antiFlingActive = false
local antiTouchedActive = false

local flyActive = false
local flySpeed = 50
local antiLagActive = false
local espActive = false

-- Variáveis de Controle do Motor de Voo
local IY_CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local flyConnection = nil
local flyBV = nil
local flyBG = nil

-- Janela de Teste Isolada para a 6ª Aba
if CoreGui:FindFirstChild("TestAba6Gui") then
    CoreGui.TestAba6Gui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TestAba6Gui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 420)
Frame.Position = UDim2.new(0.5, -160, 0.5, -210)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Title.Text = "Teste - 6ª Aba (Fly Corrigido)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
Scroll.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Scroll)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local function createToggleRow(name, callback)
    local row = Instance.new("Frame", Scroll)
    row.Size = UDim2.new(0.9, 0, 0, 40)
    row.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 90, 0, 32)
    btn.Position = UDim2.new(0.62, 0, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            btn.Text = "OFF"
        end
        callback(state)
    end)
end

-- ================= 1. ANTIVOID =================
createToggleRow("Antivoid", function(state)
    antiVoidActive = state
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if antiVoidActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -50 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    end
end)

-- ================= 2. ANTIFLING =================
createToggleRow("Antifling", function(state)
    antiFlingActive = state
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if antiFlingActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                            if pRoot and (hrp.Position - pRoot.Position).Magnitude < 5 then
                                pRoot.Velocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ================= 3. ANTI TOUCHED =================
createToggleRow("Anti Touched (Espadas)", function(state)
    antiTouchedActive = state
end)

RunService.Heartbeat:Connect(function()
    if antiTouchedActive then
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, part in ipairs(Workspace:GetPartsInPart(hrp)) do
                    if part.Parent and part.Parent ~= char and not Players:GetPlayerFromCharacter(part.Parent) then
                        if part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end)

-- ================= MOTOR DE VOO CORRIGIDO E ADAPTADO =================
local function startFly()
    pcall(function()
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end)
    
    local char = LocalPlayer.Character
    if not char then return end
    local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not torso or not hum then return end

    flyActive = true
    hum.PlatformStand = true

    flyBG = Instance.new("BodyGyro", torso)
    flyBG.P = 9e4
    flyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.cframe = torso.CFrame

    flyBV = Instance.new("BodyVelocity", torso)
    flyBV.velocity = Vector3.new(0, 0.1, 0)
    flyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not torso or not torso.Parent or not hum or hum.Health <= 0 then return end
            
            local moveDir = hum.MoveDirection
            local camCF = Camera.CFrame
            local vel = Vector3.new(0, 0.1, 0)

            -- Suporte tanto para comandos de tecla (PC) quanto para o analógico/movimento do Mobile
            if IY_CONTROL.F + IY_CONTROL.B ~= 0 or IY_CONTROL.L + IY_CONTROL.R ~= 0 then
                vel = ((camCF.LookVector * (IY_CONTROL.F + IY_CONTROL.B)) + (camCF.RightVector * (IY_CONTROL.L + IY_CONTROL.R))) * flySpeed
            elseif moveDir.Magnitude > 0 then
                vel = moveDir * flySpeed
            end

            flyBV.velocity = vel
            flyBG.cframe = camCF
        end)
    end)
end

local function stopFly()
    flyActive = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end)
end

-- Captura de Teclado (Opcional para PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not flyActive then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then IY_CONTROL.F = 1
    elseif key == Enum.KeyCode.S then IY_CONTROL.B = -1
    elseif key == Enum.KeyCode.A then IY_CONTROL.L = -1
    elseif key == Enum.KeyCode.D then IY_CONTROL.R = 1
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then IY_CONTROL.F = 0
    elseif key == Enum.KeyCode.S then IY_CONTROL.B = 0
    elseif key == Enum.KeyCode.A then IY_CONTROL.L = 0
    elseif key == Enum.KeyCode.D then IY_CONTROL.R = 0
    end
end)

-- UI do Fly com TextBox
local flyRow = Instance.new("Frame", Scroll)
flyRow.Size = UDim2.new(0.9, 0, 0, 40)
flyRow.BackgroundTransparency = 1

local flyLbl = Instance.new("TextLabel", flyRow)
flyLbl.Size = UDim2.new(0.4, 0, 1, 0)
flyLbl.Text = "Fly (IY Speed)"
flyLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
flyLbl.Font = Enum.Font.SourceSansBold
flyLbl.TextSize = 13
flyLbl.TextXAlignment = Enum.TextXAlignment.Left
flyLbl.BackgroundTransparency = 1

local flySpeedBox = Instance.new("TextBox", flyRow)
flySpeedBox.Size = UDim2.new(0, 45, 0, 32)
flySpeedBox.Position = UDim2.new(0.42, 0, 0.1, 0)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
flySpeedBox.Text = tostring(flySpeed)
flySpeedBox.TextColor3 = Color3.new(1, 1, 1)
flySpeedBox.Font = Enum.Font.SourceSans
flySpeedBox.TextSize = 12
Instance.new("UICorner", flySpeedBox).CornerRadius = UDim.new(0, 4)

flySpeedBox.FocusLost:Connect(function()
    local val = tonumber(flySpeedBox.Text)
    if val then flySpeed = val end
end)

local flyBtn = Instance.new("TextButton", flyRow)
flyBtn.Size = UDim2.new(0, 85, 0, 32)
flyBtn.Position = UDim2.new(0.58, 0, 0.1, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
flyBtn.Text = "OFF"
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 12
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 6)

flyBtn.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    if flyActive then
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
        flyBtn.Text = "ON"
        startFly()
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        flyBtn.Text = "OFF"
        stopFly()
    end
end)
