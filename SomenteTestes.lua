-- Serviços necessários
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Configurações do Gear
local GEAR_ID = 127506257
local GEAR_NAME = "Gear" + GEAR_ID -- Corrigido para concatenação padrão ou string literal
local GEAR_NAME_STR = "Gear" .. GEAR_ID

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
local REMOTE_AVATAR = RemotesFolder and RemotesFolder:WaitForChild("AvatarMainRE", 5)

-- Variáveis de Estado
local isRunning = false
local selectedTarget = nil
local isWaitingTornado = false

-----------------------------------------------------------------
-- INTERFACE GRÁFICA (GUI)
-----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TornadoScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Controle de Tornado - Aim-Lock"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

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
-- FUNÇÕES DE LOGICA E AIM-LOCK
-----------------------------------------------------------------

local function equipGear()
    if not REMOTE_AVATAR then return end
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

local function fireGearPower()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild(GEAR_NAME_STR) then
        local gearItem = character[GEAR_NAME_STR]
        local remoteEvent = gearItem:FindFirstChild("RemoteEvent")
        if remoteEvent then
            pcall(function()
                remoteEvent:FireServer("DO THE THING!!!")
            end)
        end
    end
end

-- Função para virar o personagem diretamente para o alvo (Aim-Lock)
local function aimAtTarget(targetPlayer)
    pcall(function()
        local char = LocalPlayer.Character
        local targetChar = targetPlayer and targetPlayer.Character
        if char and targetChar then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
            
            if rootPart and targetRoot then
                -- Mantém a mesma altura (Y) para o personagem não olhar torto para cima/baixo abruptamente, travando apenas no plano horizontal
                local targetPos = targetRoot.Position
                local currentPos = rootPart.Position
                local lookAtPos = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
                
                rootPart.CFrame = CFrame.new(currentPos, lookAtPos)
            end
        end
    end)
end

local function updatePlayerList()
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

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleButton.Text = "Função: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        ToggleButton.Text = "Função: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        isWaitingTornado = false
    end
end)

-----------------------------------------------------------------
-- TAREFAS DE BACKGROUND (LOOPS)
-----------------------------------------------------------------

-- 1. Auto-Equip a cada 2 segundos
task.spawn(function()
    while true do
        task.wait(2)
        if isRunning then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild(GEAR_NAME_STR) then
                equipGear()
            end
        end
    end
end)

-- 2. Loop principal com Aim-Lock e Disparo Direcionado
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if isRunning and selectedTarget and selectedTarget.Character and not isWaitingTornado then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(GEAR_NAME_STR) then
                isWaitingTornado = true
                
                -- Passo A: Alinha a mira do personagem para o alvo selecionado
                aimAtTarget(selectedTarget)
                task.wait(0.15) -- Pequeno respiro para o servidor registrar a rotação
                
                -- Passo B: Dispara o poder do gear alinhado
                fireGearPower()
                
                -- Aguarda o ciclo do tornado terminar no Workspace para liberar o próximo disparo
                local startTime = tick()
                repeat
                    task.wait(0.5)
                until not Workspace:FindFirstChild("Tornado") or (tick() - startTime) > 4.0 or not isRunning
                
                task.wait(1.0)
                isWaitingTornado = false
            end
        end
    end
end)
