-- Serviços necessários
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Configurações do Gear
local GEAR_ID = 127506257
local GEAR_NAME = "Gear" .. GEAR_ID
local REMOTE_AVATAR = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- Variáveis de Estado
local isRunning = false
local selectedTarget = nil
local lastShotTick = 0
local COOLDOWN_TIME = 3.5 -- Ajuste conforme o cooldown real do gear no jogo

-----------------------------------------------------------------
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
-----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TornadoScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Controle de Tornado - RP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Botão ON/OFF
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleButton.Text = "Função: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

-- Label Lista de Alvos
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.9, 0, 0, 25)
TargetLabel.Position = UDim2.new(0.05, 0, 0, 105)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Selecione o Alvo (Clique no Jogador):"
TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetLabel.TextSize = 14
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = MainFrame

-- ScrollingFrame para Lista de Jogadores
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(0.9, 0, 0, 185)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0, 135)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollingFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

-----------------------------------------------------------------
-- FUNÇÕES DE LOGICA DO SCRIPT
-----------------------------------------------------------------

-- Função para equipar o gear via Remote capturado
local function equipGear()
    local args = {
        [1] = {
            ["id"] = GEAR_ID,
            ["event"] = "equip",
            ["equiptype"] = "Gear"
        }
    }
    pcall(function()
        REMOTE_AVATAR:FireServer(unpack(args))
    end)
end

-- Função para disparar o poder do gear
local function fireGearPower()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild(GEAR_NAME) then
        local gearItem = character[GEAR_NAME]
        local remoteEvent = gearItem:FindFirstChild("RemoteEvent")
        if remoteEvent then
            pcall(function()
                remoteEvent:FireServer("DO THE THING!!!")
            end)
        end
    end
end

-- Atualizar dinamicamente a lista de jogadores na UI
local function updatePlayerList()
    -- Limpar botões antigos
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pButton = Instance.new("TextButton")
            pButton.Size = UDim2.new(1, -10, 0, 30)
            pButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pButton.Text = player.Name
            pButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            pButton.TextSize = 14
            pButton.Font = Enum.Font.SourceSans
            pButton.Parent = ScrollingFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = pButton

            pButton.MouseButton1Click:Connect(function()
                selectedTarget = player
                -- Destacar visualmente o alvo selecionado
                for _, btn in ipairs(ScrollingFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end
                end
                pButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            end)
        end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Botão Liga/Desliga
ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleButton.Text = "Função: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        ToggleButton.Text = "Função: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-----------------------------------------------------------------
-- TAREFAS DE BACKGROUND (LOOP INTELIGENTE)
-----------------------------------------------------------------

-- 1. Checagem e Auto-Equip a cada 2 segundos (caso morra ou perca o item)
task.spawn(function()
    while true do
        task.wait(2)
        if isRunning then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild(GEAR_NAME) then
                equipGear()
            end
        end
    end
end)

-- 2. Loop principal de Disparo e Direcionamento para o Alvo
task.spawn(function()
    while true-- Ticks e pausas estruturadas para evitar sobrecarga
    task.wait(0.5)
    
    if isRunning and selectedTarget and selectedTarget.Character then
        local targetChar = selectedTarget.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild(GEAR_NAME) then
            -- Verifica se o cooldown permitira o disparo
            if tick() - lastShotTick >= COOLDOWN_TIME then
                -- Dispara o poder
                fireGearPower()
                lastShotTick = tick()
                
                -- Aguarda a renderização e aparição do modelo "Tornado" no Workspace
                local tornadoInstance = nil
                local startTime = tick()
                
                repeat
                    tornadoInstance = Workspace:FindFirstChild("Tornado")
                    task.wait(0.05)
                until tornadoInstance or (tick() - startTime) > 1.5 -- Timeout de 1.5s para achar
                
                -- Se o tornado formou no workspace e temos um alvo válido, teleporta/direciona instantaneamente para o CFrame do alvo
                if tornadoInstance and targetRoot then
                    task.wait(0.2) -- Tempo hábil para o script nativo do jogo carregar o BodyForce/BodyVelocity
                    
                    if tornadoInstance:IsA("Model") then
                        trySetModelCFrame(tornadoInstance, targetRoot.CFrame + Vector3.new(0, 3, 0))
                    elseif tornadoInstance:IsA("BasePart") then
                        tornadoInstance.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
end
end)

-- Função auxiliar segura para mover o modelo inteiro do Tornado para o alvo
function trySetModelCFrame(model, targetCFrame)
    pcall(function()
        if model.PrimaryPart then
            model:SetPrimaryPartCFrame(targetCFrame)
        else
            -- Se não tiver PrimaryPart definida, move a primeira parte encontrada ou o corpo principal
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CFrame = targetCFrame
                    break
                end
            end
        end
    end)
end
