-- ==========================================
-- TESTE ISOLADO: 6ª ABA (PROTEÇÕES + IY FUNCTIONS)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Estados das Funções da 6ª Aba
local antiVoidActive = false
local antiFlingActive = false
local antiTouchedActive = false

-- Variáveis do Fly (Adaptadas)
local flyActive = false
local flySpeed = 2 -- Equivalente a 20 inicial (multiplicado por 10 no núcleo)
local currentBv = nil

local antiLagActive = false

-- Variáveis do ESP (Adaptadas)
local espActive = false
local espContainer = nil
local updateConnection = nil

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
Title.Text = "Teste - 6ª Aba (Proteções & IY)"
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

-- Função auxiliar para criar linhas de botões de liga/desliga com persistência
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

-- ================= 1. ANTIVOID (Loop / Respawn Seguro) =================
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

-- ================= 2. ANTIFLING (Loop / Respawn Seguro) =================
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

-- ================= 3. ANTI TOUCHED (Loop / Respawn Seguro) =================
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

-- ================= 4. FLY (Com TextBox de Velocidade + Mobile Controls) =================
local flyRow = Instance.new("Frame", Scroll)
flyRow.Size = UDim2.new(0.9, 0, 0, 40)
flyRow.BackgroundTransparency = 1

local flyLbl = Instance.new("TextLabel", flyRow)
flyLbl.Size = UDim2.new(0.4, 0, 1, 0)
flyLbl.Text = "Fly (IY Style)"
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

flySpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(flySpeedBox.Text)
    if val then flySpeed = val end
end)

flySpeedBox.FocusLost:Connect(function()
    local val = tonumber(flySpeedBox.Text)
    if not val then
        flySpeedBox.Text = tostring(flySpeed)
    end
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

-- Função auxiliar para capturar o analógico virtual (Delta / Mobile)
local function getMobileMoveVector()
    local activeController = nil
    pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
        local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
        activeController = PlayerModule:GetControls()
    end)
    
    if activeController and activeController.GetMoveVector then
        return activeController:GetMoveVector()
    end
    return Vector3.new(0, 0, 0)
end

local function startFly()
    local torso = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso"))
    if not torso then return end
    
    local cam = Workspace.CurrentCamera

    local bg = Instance.new("BodyGyro", torso)
    bg.Name = "IY_FlyBodyGyro"
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    local bv = Instance.new("BodyVelocity", torso)
    bv.Name = "IY_FlyBodyVelocity"
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    currentBv = bv

    task.spawn(function()
        while flyActive and currentBv == bv do
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
            
            local moveVector = getMobileMoveVector()
            local f = -moveVector.Z  
            local r = moveVector.X   
            
            local calculatedSpeed = flySpeed * 10
            
            if f ~= 0 or r ~= 0 then
                bv.velocity = ((cam.CoordinateFrame.LookVector * f) + ((cam.CoordinateFrame * CFrame.new(r, f * .2, 0).Position) - cam.CoordinateFrame.Position)) * calculatedSpeed
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            bg.cframe = cam.CoordinateFrame
            RunService.RenderStepped:Wait()
        end
        
        if bv and bv.Parent then bv:Destroy() end
        if bg and bg.Parent then bg:Destroy() end
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end)
end

flyBtn.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    if flyActive then
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
        flyBtn.Text = "ON"
        startFly()
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        flyBtn.Text = "OFF"
        currentBv = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    if flyActive then
        task.wait(0.5)
        startFly()
    end
end)

-- ================= 5. ANTILAG (Infinite Yield Style) =================
createToggleRow("AntiLag", function(state)
    antiLagActive = state
    if antiLagActive then
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

-- ================= 6. ESP (Com BillboardGui, HP e Distância) =================
local function createIYTag(player)
    if player == LocalPlayer then return end

    local function setupCharacter(char)
        local root = char:WaitForChild("HumanoidRootPart", 3)
        local hum = char:WaitForChild("Humanoid", 3)
        if not root or not hum or not espContainer then return end

        local existing = espContainer:FindFirstChild(player.Name)
        if existing then existing:Destroy() end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = player.Name
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = root
        billboard.Parent = espContainer

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = billboard

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
        infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.TextStrokeTransparency = 0
        infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        infoLabel.TextSize = 13
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.Parent = billboard

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not espActive or not billboard or not billboard.Parent or not char:IsDescendantOf(Workspace) then
                connection:Disconnect()
                return
            end

            local localChar = LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

            if root and hum and localRoot then
                local distance = math.floor((root.Position - localRoot.Position).Magnitude)
                local hp = math.floor(hum.Health)
                infoLabel.Text = "HP: " .. hp .. " | Dist: " .. distance .. " studs"
            else
                infoLabel.Text = "HP: N/A | Dist: N/A studs"
            end
        end)
    end

    if player.Character then
        task.spawn(setupCharacter, player.Character)
    end
    player.CharacterAdded:Connect(setupCharacter)
end

local function toggleESP(state)
    espActive = state
    
    if espActive then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IY_ESP_Container"
        espContainer.Parent = CoreGui

        for _, p in ipairs(Players:GetPlayers()) do
            createIYTag(p)
        end
        updateConnection = Players.PlayerAdded:Connect(createIYTag)
    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if espContainer then
            espContainer:Destroy()
            espContainer = nil
        end
    end
end

-- Linha do botão de ESP na ScrollFrame
local espRow = Instance.new("Frame", Scroll)
espRow.Size = UDim2.new(0.9, 0, 0, 40)
espRow.BackgroundTransparency = 1

local espLbl = Instance.new("TextLabel", espRow)
espLbl.Size = UDim2.new(0.6, 0, 1, 0)
espLbl.Text = "ESP (Jogadores)"
espLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
espLbl.Font = Enum.Font.SourceSansBold
espLbl.TextSize = 13
espLbl.TextXAlignment = Enum.TextXAlignment.Left
espLbl.BackgroundTransparency = 1

local espBtn = Instance.new("TextButton", espRow)
espBtn.Size = UDim2.new(0, 90, 0, 32)
espBtn.Position = UDim2.new(0.62, 0, 0.1, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
espBtn.Text = "OFF"
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.Font = Enum.Font.SourceSansBold
espBtn.TextSize = 12
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 6)

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleESP(espActive)
    if espActive then
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
        espBtn.Text = "ON"
    else
        espBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        espBtn.Text = "OFF"
    end
end)

print("Aba 6 carregada e atualizada com sucesso!")
