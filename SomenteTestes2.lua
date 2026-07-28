--[[\
    Infinite Yield - Reach, BoxReach & HandlerSkill GUI Adaptada
    Otimizado para Delta Mobile (Estrutura em Abas e Isolada)
]]--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Remove GUI anterior se já existir
if CoreGui:FindFirstChild("IYCustomReachGUI") then
    CoreGui.IYCustomReachGUI:Destroy()
end

-- Estados globais das funções (Baseados no Infinite Yield original)
local ReachConfig = {
    Reach = {Enabled = false, Size = 5},
    BoxReach = {Enabled = false, Size = 5},
    Handler = {Enabled = false, Size = 5}
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
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Topbar / Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "  Infinite Yield - Reach Controller Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Barra de Abas (Navegação)
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

-- Container dos Conteúdos das Abas
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 10, 0, 80)
ContentContainer.Size = UDim2.new(1, -20, 1, -90)

-- Criador de Abas
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

-- Aba 1: Jogadores
local PlayersTab, PlayersBtn = createTab("Lista de Jogadores", 1)
PlayersBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180) -- Deixa ativa por padrão
PlayersTab.Visible = true

-- Aba 2: Controles Técnicos (Reach, BoxReach, HandlerSkill)
local ControlsTab, ControlsBtn = createTab("Controles (Reach / Box / Handler)", 2)

-- Função para popular a lista de jogadores na Aba 1
local function renderPlayerList()
    for _, child in ipairs(PlayersTab:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerRow = Instance.new("Frame")
            PlayerRow.Parent = PlayersTab
            PlayerRow.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            PlayerRow.Size = UDim2.new(1, -6, 0, 40)

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 6)
            RowCorner.Parent = PlayerRow

            local PNameLabel = Instance.new("TextLabel")
            PNameLabel.Parent = PlayerRow
            PNameLabel.BackgroundTransparency = 1
            PNameLabel.Position = UDim2.new(0, 12, 0, 0)
            PNameLabel.Size = UDim2.new(1, -20, 1, 0)
            PNameLabel.Font = Enum.Font.GothamSemibold
            PNameLabel.Text = player.Name
            PNameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            PNameLabel.TextSize = 13
            PNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
    PlayersTab.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 48)
end

renderPlayerList()
Players.PlayerAdded:Connect(renderPlayerList)
Players.PlayerRemoving:Connect(renderPlayerList)

-- Função para criar os painéis de controle individuais na Aba 2
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
    TextBox.Size = UDim2.new(0, 120, 0, 30)
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
    ToggleBtn.Position = UDim2.new(0, 145, 0, 35)
    ToggleBtn.Size = UDim2.new(0, 240, 0, 30)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "OFF (Desativado)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn

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

    ControlsTab.CanvasSize = UDim2.new(0, 0, 0, ControlsTab.AbsoluteContentSize.Y + 20)
end

-- Monta os blocos individuais na Aba 2 exatamente como solicitado
createControlPanel("Função: Reach (Infinite Yield)", "Reach", 5)
createControlPanel("Função: BoxReach (Infinite Yield)", "BoxReach", 10)
createControlPanel("Função: HandlerSkill (Infinite Yield)", "Handler", 5)

-- Lógica central de execução idêntica ao IY (Atua apenas quando o jogador segura uma ferramenta)
RunService.Stepped:Connect(function()
    local localChar = LocalPlayer.Character
    if not localChar then return end
    
    local tool = localChar:FindFirstChildOfClass("Tool")
    if not tool then return end -- Só executa se estiver com ferramenta (espada) na mão

    -- Lógica do Reach / BoxReach / Handler estruturada pelas propriedades nativas do IY
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            if ReachConfig.Reach.Enabled then
                part.Size = Vector3.new(ReachConfig.Reach.Size, ReachConfig.Reach.Size, ReachConfig.Reach.Size)
                part.CanCollide = false
            end
            if ReachConfig.BoxReach.Enabled then
                part.Size = Vector3.new(ReachConfig.BoxReach.Size, ReachConfig.BoxReach.Size, ReachConfig.BoxReach.Size)
                part.CanCollide = false
            end
            if ReachConfig.Handler.Enabled then
                part.Size = Vector3.new(ReachConfig.Handler.Size, ReachConfig.Handler.Size, ReachConfig.Handler.Size)
                part.CanCollide = false
            end
        end
    end
end)
