local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Estado da função (Começa desligada)
local hitboxEspAtivo = false
local conexoesRastreio = {}

-- Função para limpar os ESPs criados
local function limparTudo()
    for _, conn in pairs(conexoesRastreio) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    conexoesRastreio = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local box = p.Character:FindFirstChild("TrollHubBox")
            local gui = p.Character:FindFirstChild("TrollHubInfo")
            if box then box:Destroy() end
            if gui then gui:Destroy() end
        end
    end
end

-- Função principal do Hitbox ESP
local function iniciarHitboxESP()
    if not hitboxEspAtivo then return end

    local function rastrearJogador(player)
        if player == LocalPlayer then return end

        local conexao
        conexao = RunService.RenderStepped:Connect(function()
            if not hitboxEspAtivo then
                conexao:Disconnect()
                return
            end

            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then 
                return 
            end

            local rootPart = character.HumanoidRootPart
            local tool = character:FindFirstChildOfClass("Tool")
            local handle = tool and tool:FindFirstChild("Handle")

            if handle then
                -- 1. Cria ou atualiza a Caixa Visual (SelectionBox)
                local selectionBox = character:FindFirstChild("TrollHubBox")
                if not selectionBox then
                    selectionBox = Instance.new("SelectionBox")
                    selectionBox.Name = "TrollHubBox"
                    selectionBox.Adornee = handle
                    selectionBox.Color3 = Color3.fromRGB(255, 0, 0) -- Vermelho de alerta
                    selectionBox.LineThickness = 0.08
                    selectionBox.Parent = character
                else
                    selectionBox.Adornee = handle -- Garante que acompanha caso mude de mão
                end

                -- 2. Cria ou atualiza o Texto Flutuante (BillboardGui)
                local billboard = character:FindFirstChild("TrollHubInfo")
                local textLabel
                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "TrollHubInfo"
                    billboard.Size = UDim2.new(0, 220, 0, 60)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = character

                    textLabel = Instance.new("TextLabel")
                    textLabel.Name = "InfoText"
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0 -- Borda preta para legibilidade
                    textLabel.TextSize = 13
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Parent = billboard
                else
                    textLabel = billboard:FindFirstChild("InfoText")
                end

                -- 3. Calcula Distância e Tamanho com segurança
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    local size = handle.Size
                    
                    if textLabel then
                        -- Corrigido de string.Format para string.format (minúsculo)
                        textLabel.Text = string.format("[%s]\nDist: %d Studs\nTamanho: %.1f, %.1f, %.1f", 
                            player.Name, math.floor(dist), size.X, size.Y, size.Z)
                    end
                end
            else
                -- Remove a caixa e o texto se o jogador NÃO estiver com ferramenta equipada
                local box = character:FindFirstChild("TrollHubBox")
                local gui = character:FindFirstChild("TrollHubInfo")
                if box then box:Destroy() end
                if gui then gui:Destroy() end
            end
        end)

        table.insert(conexoesRastreio, conexao)
    end

    -- Aplica nos jogadores atuais
    for _, p in ipairs(Players:GetPlayers()) do
        rastrearJogador(p)
    end

    -- Monitora entrada de novos jogadores
    local playerAddedConn = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            if hitboxEspAtivo then
                task.wait(1)
                rastrearJogador(p)
            end
        end)
    end)
    table.insert(conexoesRastreio, playerAddedConn)

    -- Monitora o respawn dos jogadores atuais
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(conexoesRastreio, p.CharacterAdded:Connect(function()
                if hitboxEspAtivo then
                    task.wait(1)
                    rastrearJogador(p)
                end
            end))
        end
    end
end

-- ==========================================
-- INTERFACE DO BOTÃO (TROLLHUB)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHubUI"
ScreenGui.Parent = CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "HitboxESP_Button"
ToggleButton.Size = UDim2.new(0, 160, 0, 45)
ToggleButton.Position = UDim2.new(0, 50, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Hitbox ESP: [OFF]"
ToggleButton.Parent = ScreenGui

ToggleButton.Active = true
ToggleButton.Draggable = true

-- Ação do Botão
ToggleButton.MouseButton1Click:Connect(function()
    hitboxEspAtivo = not hitboxEspAtivo

    if hitboxEspAtivo then
        ToggleButton.Text = "Hitbox ESP: [ON]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        iniciarHitboxESP()
    else
        ToggleButton.Text = "Hitbox ESP: [OFF]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        limparTudo()
    end
end)

-- Persistência caso você (dono do script) morra e renasça
LocalPlayer.CharacterAdded:Connect(function()
    if hitboxEspAtivo then
        task.wait(1)
        iniciarHitboxESP()
    end
end)
