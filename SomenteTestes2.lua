--[[\
    Infinite Yield - Reach & BoxReach GUI Adapter (Otimizado para Delta)
    Interface gráfica moderna para manipulação de Hitbox por Jogador
]]--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Remove GUI anterior se já existir para evitar duplicatas
if CoreGui:FindFirstChild("IYReachGUI") then
    CoreGui.IYReachGUI:Destroy()
end

-- Criação da ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IYReachGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Janela Principal (Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar a janela na tela

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "  IY Reach & BoxReach Control"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- ScrollingFrame para listar os jogadores
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "PlayerList"
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.Size = UDim2.new(0, 380, 0, 290)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Controle de Estados Ativos de Reach por Jogador
local activeReaches = {}

-- Lógica central baseada no funcionamento do Infinite Yield (Reach / BoxReach / Handler)
game:GetService("RunService").Stepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and activeReaches[player.Name] and activeReaches[player.Name].enabled then
            local targetChar = player.Character
            local localChar = LocalPlayer.Character
            if targetChar and localChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local tool = localChar:FindFirstChildOfClass("Tool")
                
                if targetHrp and tool then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local sizeVal = activeReaches[player.Name].size or 5
                            -- Expande temporariamente a hitbox da ferramenta na direção do alvo (lógica exata do BoxReach/Reach do IY)
                            part.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
                            part.CFrame = targetHrp.CFrame
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

-- Função para construir a linha de interface de cada jogador dinamicamente
local function createPlayerRow(player)
    if player == LocalPlayer then return end

    local Row = Instance.new("Frame")
    Row.Name = player.Name
    Row.Parent = ScrollingFrame
    Row.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Row.Size = UDim2.new(1, -12, 0, 45)

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    -- Nome do Jogador
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = Row
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.Size = UDim2.new(0, 120, 1, 0)
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.Text = player.Name
    NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Caixa de Texto para o Tamanho (Size / Reach Value)
    local SizeBox = Instance.new("TextBox")
    SizeBox.Name = "SizeBox"
    SizeBox.Parent = Row
    SizeBox.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    SizeBox.Position = UDim2.new(0, 135, 0, 8)
    SizeBox.Size = UDim2.new(0, 50, 0, 28)
    SizeBox.Font = Enum.Font.Gotham
    SizeBox.PlaceholderText = "Size"
    SizeBox.Text = "10"
    SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SizeBox.TextSize = 12

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = SizeBox

    -- Botão de Ligar / Desligar (Equivalente ao unreach / unboxreach)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = Row
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ToggleBtn.Position = UDim2.new(0, 195, 0, 8)
    ToggleBtn.Size = UDim2.new(0, 165, 0, 28)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "OFF (Ativar Reach)"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn

    -- Inicializa o estado do player
    activeReaches[player.Name] = {enabled = false, size = 10}

    -- Evento do Botão (Alterna entre Ligar e Desligar estilo "Un")
    ToggleBtn.MouseButton1Click:Connect(function()
        local state = activeReaches[player.Name]
        state.enabled = not state.enabled
        state.size = tonumber(SizeBox.Text) or 10

        if state.enabled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
            ToggleBtn.Text = "ON (Desativar)"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            ToggleBtn.Text = "OFF (Ativar Reach)"
        end
    end)

    -- Atualiza dinamicamente o tamanho caso mude com o botão ligado
    SizeBox.FocusLost:Connect(function()
        if activeReaches[player.Name] then
            activeReaches[player.Name].size = tonumber(SizeBox.Text) or 10
        end
    end)

    -- Atualiza o tamanho do ScrollingFrame dinamicamente
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #ScrollingFrame:GetChildren() * 50)
end

-- Popula a lista inicial de jogadores
for _, p in ipairs(Players:GetPlayers()) do
    createPlayerRow(p)
end

-- Adiciona ou remove jogadores da lista conforme entram/saem do servidor
Players.PlayerAdded:Connect(createPlayerRow)
Players.PlayerRemoving:Connect(function(player)
    activeReaches[player.Name] = nil
    if ScrollingFrame:FindFirstChild(player.Name) then
        ScrollingFrame[player.Name]:Destroy()
    end
end)
