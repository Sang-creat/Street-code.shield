--[[\
    Infinite Yield - Reach, BoxReach & HandlerSkill Corrigido e Funcional
    Otimizado para Delta Mobile
]]--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Remove GUI anterior se já existir
if CoreGui:FindFirstChild("IYCustomReachGUI") then
    CoreGui.IYCustomReachGUI:Destroy()
end

-- Configurações globais ligadas aos interruptores da UI
local ReachConfig = {
    Reach = {Enabled = false, Size = 5},
    BoxReach = {Enabled = false, Size = 5},
    Handler = {Enabled = false, Size = 5},
    SelectedTarget = nil
}

-- Criação da ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IYCustomReachGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
MainFrame.Size = UDim2.new(0, 420, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "  Infinite Yield - Reach Controller Hub (Fix)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Barra de Abas
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 10, 0, 42)
TabBar.Size = UDim2.new(1, -20, 0, 32)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)

-- Container dos Conteúdos
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 10, 0, 80)
ContentContainer.Size = UDim2.new(1, -20, 1, -90)

-- Função para criar abas
local function createTab(name, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Btn"
    TabButton.Parent = TabBar
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TabButton.Size = UDim2.new(0, 195, 1, 0)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 13
    TabButton.LayoutOrder = order

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabButton

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = ContentContainer
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.ScrollBarThickness = 5
    TabContent.Visible = false

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = TabContent
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)

    TabButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        for _, child in ipairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        end
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    end)

    return TabContent, TabButton
end

-- Aba 1: Lista de Alvos (Para HandlerSkill)
local PlayersTab, PlayersBtn = createTab("Lista de Alvos (Handler)", 1)
PlayersBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
PlayersTab.Visible = true

-- Aba 2: Controles Técnicos Separados
local ControlsTab, ControlsBtn = createTab("Controles (3 Funções)", 2)

-- Popula a Lista de Jogadores na Aba 1
local function renderPlayerList()
    for _, child in ipairs(PlayersTab:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerRow = Instance.new("Frame")
            PlayerRow.Parent = PlayersTab
            PlayerRow.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            PlayerRow.Size = UDim2.new(1, -6, 0, 42)

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 6)
            RowCorner.Parent = PlayerRow

            local PNameLabel = Instance.new("TextLabel")
            PNameLabel.Parent = PlayerRow
            PNameLabel.BackgroundTransparency = 1
            PNameLabel.Position = UDim2.new(0, 12, 0, 0)
            PNameLabel.Size = UDim2.new(0, 200, 1, 0)
            PNameLabel.Font = Enum.Font.GothamSemibold
            PNameLabel.Text = player.Name
            PNameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            PNameLabel.TextSize = 13
            PNameLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SelectBtn = Instance.new("TextButton")
            SelectBtn.Parent = PlayerRow
            SelectBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            SelectBtn.Position = UDim2.new(1, -145, 0, 6)
            SelectBtn.Size = UDim2.new(0, 135, 0, 30)
            SelectBtn.Font = Enum.Font.GothamBold
            SelectBtn.Text = "Selecionar Alvo"
            SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SelectBtn.TextSize = 11

            local SelectCorner = Instance.new("UICorner")
            SelectCorner.CornerRadius = UDim.new(0, 4)
            SelectCorner.Parent = SelectBtn

            SelectBtn.MouseButton1Click:Connect(function()
                ReachConfig.SelectedTarget = player
                for _, c in ipairs(PlayersTab:GetChildren()) do
                    if c:IsA("Frame") and c:FindFirstChild("TextButton") then
                        c.TextButton.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
                        c.TextButton.Text = "Selecionar Alvo"
                    end
                end
                SelectBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                SelectBtn.Text = "Alvo: " .. player.Name
            end)
        end
    end
    PlayersTab.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 50)
end

renderPlayerList()
Players.PlayerAdded:Connect(renderPlayerList)
Players.PlayerRemoving:Connect(renderPlayerList)

-- Função para criar os 3 painéis de controle individuais na Aba 2
local function createControlPanel(title, configKey, defaultSize)
    local Panel = Instance.new("Frame")
    Panel.Parent = ControlsTab
    Panel.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Panel.Size = UDim2.new(1, -6, 0, 75)

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 6)
    PanelCorner.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Parent = Panel
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = Panel
    TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    TextBox.Position = UDim2.new(0, 12, 0, 35)
    TextBox.Size = UDim2.new(0, 110, 0, 30)
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderText = "Tamanho"
    TextBox.Text = tostring(defaultSize)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 12

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = TextBox

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Panel
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ToggleBtn.Position = UDim2.new(0, 132, 0, 35)
    ToggleBtn.Size = UDim2.new(0, 255, 0, 30)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "OFF (Desativado)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn

    ToggleBtn.MouseButton1Child = false
    ToggleBtn.MouseButton1Click:Connect(function()
        ReachConfig[configKey].Enabled = not ReachConfig[configKey].Enabled
        ReachConfig[configKey].Size = tonumber(TextBox.Text) or defaultSize

        if ReachConfig[configKey].Enabled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
            ToggleBtn.Text = "ON (Ativo)"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            ToggleBtn.Text = "OFF (Desativado)"
        end
    end)

    TextBox.FocusLost:Connect(function()
        ReachConfig[configKey].Size = tonumber(TextBox.Text) or defaultSize
    end)

    local layout = ControlsTab:FindFirstChildOfClass("UIListLayout")
    if layout then
        ControlsTab.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end
end

-- Cria os painéis exatos para os 3 comandos
createControlPanel("Função: Reach (IY)", "Reach", 5)
createControlPanel("Função: BoxReach (IY)", "BoxReach", 10)
createControlPanel("Função: HandlerSkill (Requer Alvo na Aba 1)", "Handler", 5)

-- Lógica central em tempo real estritamente vinculada aos botões da UI e à ferramenta ativa
RunService.Stepped:Connect(function()
    local localChar = LocalPlayer.Character
    if not localChar then return end
    
    local tool = localChar:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- Itera sobre todas as partes da ferramenta equipada (Handle / Lâmina)
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            -- 1. Comando Reach Ativo
            if ReachConfig.Reach.Enabled then
                local s = ReachConfig.Reach.Size
                part.Size = Vector3.new(s, s, s)
                part.CanCollide = false
            end

            -- 2. Comando BoxReach Ativo
            if ReachConfig.BoxReach.Enabled then
                local s = ReachConfig.BoxReach.Size
                part.Size = Vector3.new(s, s, s)
                part.CanCollide = false
            end

            -- 3. Comando HandlerSkill Ativo (Exige o Alvo selecionado na Aba 1)
            if ReachConfig.Handler.Enabled and ReachConfig.SelectedTarget then
                local targetChar = ReachConfig.SelectedTarget.Character
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = targetChar.HumanoidRootPart
                    local s = ReachConfig.Handler.Size
                    part.Size = Vector3.new(s, s, s)
                    part.CFrame = targetHrp.CFrame
                    part.CanCollide = false
                end
            end
        end
    end
end)
