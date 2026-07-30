-- ==========================================
-- TESTE ISOLADO: 6ª ABA (FLY & ESP CORRIGIDOS E ESTÁVEIS)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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
Title.Text = "Teste - 6ª Aba (Fly & ESP Ajustados)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
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

-- ================= 4. FLY (CORRIGIDO E FLUIDO - IY STYLE) =================
local flyRow = Instance.new("Frame", Scroll)
flyRow.Size = UDim2.new(0.9, 0, 0, 40)
flyRow.BackgroundTransparency = 1

local flyLbl = Instance.new("TextLabel", flyRow)
flyLbl.Size = UDim2.new(0.4, 0, 1, 0)
flyLbl.Text = "Fly (IY Original)"
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

local IYConnection
local UserInputService = game:GetService("UserInputService")

flyBtn.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    if flyActive then
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
        flyBtn.Text = "ON"
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end
            
            if IYConnection then IYConnection:Disconnect() end
            
            local bg = Instance.new("BodyGyro", root)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = root.CFrame
            
            local bv = Instance.new("BodyVelocity", root)
            bv.velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            IYConnection = RunService.RenderStepped:Connect(function()
                if not flyActive then
                    bg:Destroy()
                    bv:Destroy()
                    if IYConnection then IYConnection:Disconnect() end
                    return
                end
                
                local currentRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
                local currentHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                
                if currentRoot and currentHum then
                    currentHum.PlatformStand = true
                    bg.cframe = Camera.CFrame
                    
                    local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
                    local backward = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
                    local left = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
                    local right = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                    local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
                    local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0
                    
                    local moveDir = (Camera.CFrame.LookVector * (forward + backward)) + (Camera.CFrame.RightVector * (left + right)) + (Vector3.new(0, 1, 0) * (up + down))
                    
                    if moveDir.Magnitude > 0 then
                        bv.velocity = moveDir.Unit * flySpeed
                    else
                        bv.velocity = Vector3.new(0, 0.1, 0)
                    end
                end
            end)
        end)
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        flyBtn.Text = "OFF"
        pcall(function()
            if IYConnection then IYConnection:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                if root then
                    for _, v in ipairs(root:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                            v:Destroy()
                        end
                    end
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
            end
        end)
    end
end)

-- ================= 5. ANTILAG =================
createToggleRow("AntiLag", function(state)
    if state then
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true
        end)
    end
end)

-- ================= 6. ESP (COMPLETO E ROBUSTO - ESTILO IY) =================
createToggleRow("ESP (Jogadores)", function(state)
    espActive = state
    if not state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local espFolder = plr.Character:FindFirstChild("IY_ESP")
                if espFolder then espFolder:Destroy() end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not espActive then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head") or hrp
            
            if hrp and hum then
                local espFolder = char:FindFirstChild("IY_ESP")
                if not espFolder then
                    espFolder = Instance.new("Folder")
                    espFolder.Name = "IY_ESP"
                    espFolder.Parent = char
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Box"
                    highlight.Adornee = char
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Info"
                    billboard.Adornee = head
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = espFolder
                    
                    local textLabel = Instance.new("TextLabel", billboard)
                    textLabel.Name = "Text"
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextSize = 14
                    textLabel.Parent = billboard
                end
                
                local highlight = espFolder:FindFirstChild("Box")
                local textLabel = espFolder:FindFirstChild("Info") and espFolder.Info:FindFirstChild("Text")
                
                if highlight and textLabel then
                    -- Determina cor (Verde se for do mesmo time, Vermelho para inimigos)
                    local espColor = Color3.fromRGB(255, 0, 0)
                    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                        espColor = Color3.fromRGB(0, 255, 0)
                    end
                    
                    highlight.FillColor = espColor
                    textLabel.TextColor3 = espColor
                    
                    local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    textLabel.Text = string.format("%s\nVida: %d | Dist: %d", plr.Name, math.floor(hum.Health), distance)
                end
            end
        end
    end
end)

print("Aba 6 carregada com correções definitivas de Fly e ESP!")
