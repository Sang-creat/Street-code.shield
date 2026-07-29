-- ==========================================
-- SCRIPT: REACH CONTROLLER HUB INDEPENDENTE
-- Funciona sem o Infinite Yield instalado
-- Compatibilidade: Delta Executor (Mobile)
-- ==========================================

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Variáveis de controle
local targetPlayerName = ""
local reachValue = 5
local boxReachValue = 1000
local handlerValue = 1000

local reachActive = false
local boxReachActive = false
local handlerActive = false

-- Conexões de loop para manter as funções ativas
local reachConnection = nil
local boxReachConnection = nil
local handlerConnection = nil

-- Função segura para compatibilidade com executores mobile (Delta)
local function safeFireTouch(handle, hrp)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(handle, hrp, 0)
            firetouchinterest(handle, hrp, 1)
        end)
    else
        -- Método alternativo caso o executor não suporte firetouchinterest nativo
        pcall(function()
            if handle and hrp then
                handle.CFrame = hrp.CFrame
            end
        end)
    end
end

-- Função para pegar a arma equipada atual
local function getEquippedTool()
    local character = localPlayer.Character
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
end

-- ==========================================
-- LÓGICA INTERNA DOS COMANDOS (CÓDIGO NATIVO)
-- ==========================================

-- Função para o REACH padrão (Aumenta o alcance linear da Hitbox da espada)
local function startReach()
    if reachConnection then reachConnection:Disconnect() end
    reachConnection = RunService.Heartbeat:Connect(function()
        if not reachActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local distance = (handle.Position - hrp.Position).Magnitude
                    if distance <= reachValue then
                        safeFireTouch(handle, hrp)
                    end
                end
            end
        end
    end)
end

-- Função para o BOXREACH (Cria uma área massiva de colisão ao seu redor)
local function startBoxReach()
    if boxReachConnection then boxReachConnection:Disconnect() end
    boxReachConnection = RunService.Heartbeat:Connect(function()
        if not boxReachActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local distance = (handle.Position - hrp.Position).Magnitude
                    if distance <= boxReachValue then
                        safeFireTouch(handle, hrp)
                    end
                end
            end
        end
    end)
end

-- Função para o HANDLERSKILL (Foca o alcance massivo apenas no jogador alvo)
local function startHandlerSkill()
    if handlerConnection then handlerConnection:Disconnect() end
    handlerConnection = RunService.Heartbeat:Connect(function()
        if not handlerActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") and targetPlayerName ~= "" then
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local handle = tool.Handle
                local hrp = targetPlayer.Character.HumanoidRootPart
                local distance = (handle.Position - hrp.Position).Magnitude
                if distance <= handlerValue then
                    safeFireTouch(handle, hrp)
                end
            end
        end
    end)
end

-- ==========================================
-- CONSTRUÇÃO DA INTERFACE GRÁFICA (GUI)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IndependentReachHub"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 310)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(33, 37, 43)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "Reach Controller Hub - Custom Standalone"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local TabListContainer = Instance.new("Frame")
TabListContainer.Size = UDim2.new(1, -20, 0, 35)
TabListContainer.Position = UDim2.new(0, 10, 0, 40)
TabListContainer.BackgroundTransparency = 1
TabListContainer.Parent = MainFrame

local TabAlvos = Instance.new("TextButton")
TabAlvos.Size = UDim2.new(0.48, 0, 1, 0)
TabAlvos.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
TabAlvos.Text = "Lista de Alvos (Handler)"
TabAlvos.TextColor3 = Color3.fromRGB(180, 180, 180)
TabAlvos.Font = Enum.Font.SourceSansBold
TabAlvos.TextSize = 14
TabAlvos.Parent = TabListContainer
Instance.new("UICorner", TabAlvos).CornerRadius = UDim.new(0, 6)

local TabControles = Instance.new("TextButton")
TabControles.Size = UDim2.new(0.48, 0, 1, 0)
TabControles.Position = UDim2.new(0.52, 0, 0, 0)
TabControles.BackgroundColor3 = Color3.fromRGB(68, 118, 179)
TabControles.Text = "Controles (3 Funções)"
TabControles.TextColor3 = Color3.fromRGB(255, 255, 255)
TabControles.Font = Enum.Font.SourceSansBold
TabControles.TextSize = 14
TabControles.Parent = TabListContainer
Instance.new("UICorner", TabControles).CornerRadius = UDim.new(0, 6)

local AbaAlvosFrame = Instance.new("ScrollingFrame")
AbaAlvosFrame.Size = UDim2.new(1, -20, 0, 210)
AbaAlvosFrame.Position = UDim2.new(0, 10, 0, 85)
AbaAlvosFrame.BackgroundTransparency = 1
AbaAlvosFrame.Visible = false
AbaAlvosFrame.ScrollBarThickness = 5
AbaAlvosFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = AbaAlvosFrame

local AbaControlesFrame = Instance.new("ScrollingFrame")
AbaControlesFrame.Size = UDim2.new(1, -20, 0, 210)
AbaControlesFrame.Position = UDim2.new(0, 10, 0, 85)
AbaControlesFrame.BackgroundTransparency = 1
AbaControlesFrame.Visible = true
AbaControlesFrame.ScrollBarThickness = 5
AbaControlesFrame.Parent = MainFrame

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.Padding = UDim.new(0, 10)
ControlsLayout.Parent = AbaControlesFrame

TabAlvos.MouseButton1Click:Connect(function()
    AbaAlvosFrame.Visible = true
    AbaControlesFrame.Visible = false
    TabAlvos.BackgroundColor3 = Color3.fromRGB(68, 118, 179)
    TabAlvos.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabControles.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    TabControles.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

TabControles.MouseButton1Click:Connect(function()
    AbaAlvosFrame.Visible = false
    AbaControlesFrame.Visible = true
    TabControles.BackgroundColor3 = Color3.fromRGB(68, 118, 179)
    TabControles.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabAlvos.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    TabAlvos.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

local function refreshPlayerList()
    for _, item in pairs(AbaAlvosFrame:GetChildren()) do
        if item:IsA("TextButton") then item:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local PButton = Instance.new("TextButton")
            PButton.Size = UDim2.new(1, 0, 0, 30)
            PButton.BackgroundColor3 = (targetPlayerName == p.Name) and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(40, 44, 52)
            PButton.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            PButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            PButton.Font = Enum.Font.SourceSans
            PButton.TextSize = 14
            PButton.Parent = AbaAlvosFrame
            Instance.new("UICorner", PButton).CornerRadius = UDim.new(0, 4)
            
            PButton.MouseButton1Click:Connect(function()
                targetPlayerName = p.Name
                refreshPlayerList()
            end)
        end
    end
end
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- ==========================================
-- GERADOR DE COMPONENTES INTERNOS DA ABA 2
-- ==========================================

local function createFunctionRow(nameLabel, defaultValue, toggleCallback, textCallback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 50)
    RowFrame.BackgroundTransparency = 1
    RowFrame.Parent = AbaControlesFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = nameLabel
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = RowFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0, 80, 0, 32)
    TextBox.Position = UDim2.new(0.61, 0, 0.15, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    TextBox.Text = tostring(defaultValue)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 14
    TextBox.Parent = RowFrame
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
    
    TextBox.FocusLost:Connect(function()
        local num = tonumber(TextBox.Text)
        if num then
            textCallback(num)
        end
    end)
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 100, 0, 32)
    ToggleBtn.Position = UDim2.new(0.78, 0, 0.15, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ToggleBtn.Text = "DESLIGADO"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 13
    ToggleBtn.Parent = RowFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
    
    local activeState = false
    ToggleBtn.MouseButton1Click:Connect(function()
        activeState = not activeState
        if activeState then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
            ToggleBtn.Text = "LIGADO"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            ToggleBtn.Text = "DESLIGADO"
        end
        toggleCallback(activeState)
    end)
end

-- Criando os controles na Aba 2
createFunctionRow("Reach Padrão", reachValue, function(state)
    reachActive = state
    if state then startReach() end
end, function(val)
    reachValue = val
end)

createFunctionRow("Box Reach", boxReachValue, function(state)
    boxReachActive = state
    if state then startBoxReach() end
end, function(val)
    boxReachValue = val
end)

createFunctionRow("Handler Skill (Alvo)", handlerValue, function(state)
    handlerActive = state
    if state then startHandlerSkill() end
end, function(val)
    handlerValue = val
end)

AbaControlesFrame.CanvasSize = UDim2.new(0, 0, 0, ControlsLayout.AbsoluteContentSize.Y + 20)
