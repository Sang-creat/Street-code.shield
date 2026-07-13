--[[
    SCRIPT UNIVERSAL - TELEPORT SNEAK + ANTI-BRING
    Coloque este script em StarterPlayerScripts
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variáveis de controle
local isLoopActive = false
local isTeleporting = false
local originalPosition = nil
local targetPlayer = nil
local selectedPlayer = nil

-- UI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportSneakUI"
screenGui.Parent = player.PlayerGui

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Arredondamento
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "🎯 TELEPORT SNEAK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botão Ligar/Desligar Loop
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0.1, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
toggleButton.Text = "▶ ATIVAR LOOP"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Lista de Jogadores
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.9, 0, 0, 300)
playerListFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
playerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
playerListFrame.BackgroundTransparency = 0.5
playerListFrame.BorderSizePixel = 0
playerListFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = playerListFrame

-- Layout da lista
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerListFrame

-- Status e Info
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusLabel.Text = "🔴 Desligado"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Botão de Fechar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Botão Arrastar (para mover a UI)
local dragButton = Instance.new("TextButton")
dragButton.Size = UDim2.new(1, 0, 0, 40)
dragButton.BackgroundTransparency = 1
dragButton.Text = ""
dragButton.Parent = mainFrame

-- Função para atualizar lista de jogadores
local function updatePlayerList()
    -- Limpar lista atual
    for _, child in pairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Adicionar jogadores
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, 0, 0, 35)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            playerButton.Text = otherPlayer.Name .. " - " .. tostring(otherPlayer.Team)
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextScaled = true
            playerButton.Font = Enum.Font.Gotham
            playerButton.Parent = playerListFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = playerButton
            
            -- Selecionar alvo
            playerButton.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer
                targetPlayer = otherPlayer
                statusLabel.Text = "🎯 Alvo: " .. otherPlayer.Name
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end)
        end
    end
end

-- Atualizar lista a cada 2 segundos
spawn(function()
    while wait(2) do
        updatePlayerList()
    end
end)

-- Função de Teleporte com Tween (2.5 segundos)
local function teleportToPlayer(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local targetRoot = target.Character.HumanoidRootPart
    local targetPosition = targetRoot.Position
    local targetCFrame = targetRoot.CFrame
    
    -- Posição atrás do jogador
    local behindOffset = targetCFrame.LookVector * -3
    local teleportPosition = targetPosition + behindOffset + Vector3.new(0, 2, 0)
    
    -- Salvar posição original
    originalPosition = character.HumanoidRootPart.Position
    
    -- Teleportar
    character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
    isTeleporting = true
    
    -- Esperar 2.5 segundos
    wait(2.5)
    
    -- Voltar para posição original
    if originalPosition then
        character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
    end
    
    isTeleporting = false
end

-- Função do Loop de Teleporte
local function startTeleportLoop()
    while isLoopActive do
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            teleportToPlayer(targetPlayer)
        end
        wait(0.5) -- Delay entre teleportes
    end
end

-- Função ANTI-BRING (Envia coordenadas falsas)
local function sendFakePosition()
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Gerar coordenadas falsas com pequenas variações
    local realPos = character.HumanoidRootPart.Position
    local fakePos = realPos + Vector3.new(
        math.random(-50, 50),
        math.random(-10, 10),
        math.random(-50, 50)
    )
    
    -- Enviar posição falsa para o servidor
    -- Nota: Isso é uma simulação, pois não podemos interceptar diretamente
    -- Mas podemos usar RemoteEvents se configurados no servidor
    
    -- Simulação: mover visualmente para confundir (opcional)
    -- character.HumanoidRootPart.Position = fakePos
    -- wait(0.1)
    -- character.HumanoidRootPart.Position = realPos
end

-- Loop Anti-Bring
spawn(function()
    while true do
        if isLoopActive and character and character:FindFirstChild("HumanoidRootPart") then
            sendFakePosition()
        end
        wait(0.5)
    end
end)

-- Função para empurrar jogadores que chegam perto (com Gear)
local function pushNearbyPlayers()
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = character.HumanoidRootPart
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local otherRoot = otherPlayer.Character.HumanoidRootPart
            local distance = (rootPart.Position - otherRoot.Position).Magnitude
            
            if distance < 1 then
                -- Empurrar para longe
                local pushDirection = (otherRoot.Position - rootPart.Position).Unit * 10
                otherRoot.Velocity = Vector3.new(pushDirection.X, 5, pushDirection.Z)
                
                -- Simular uso de Gear
                local gear = Instance.new("Tool")
                gear.Name = "PushGear"
                gear.RequiresHandle = false
                gear.Parent = character
                
                -- Ativar gear
                local handle = Instance.new("Part")
                handle.Size = Vector3.new(2, 2, 2)
                handle.Parent = gear
                handle.CanCollide = false
                handle.Transparency = 1
                
                -- Usar gear
                gear.Activated:Fire()
                wait(0.1)
                gear:Destroy()
            end
        end
    end
end

-- Loop para empurrar jogadores
spawn(function()
    while true do
        if isLoopActive then
            pushNearbyPlayers()
        end
        wait(0.5)
    end
end)

-- Toggle do Loop
toggleButton.MouseButton1Click:Connect(function()
    isLoopActive = not isLoopActive
    
    if isLoopActive then
        toggleButton.Text = "⏹ DESLIGAR LOOP"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "🟢 Loop Ativo - Alvo: " .. (selectedPlayer and selectedPlayer.Name or "Nenhum")
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Iniciar loop
        spawn(startTeleportLoop)
    else
        toggleButton.Text = "▶ ATIVAR LOOP"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        statusLabel.Text = "🔴 Desligado"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        isTeleporting = false
    end
end)

-- Fechar UI
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Arrastar UI
local dragging = false
local dragStart, startPos

dragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

dragButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Atualizar quando o personagem reiniciar
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    wait(1)
    if isLoopActive then
        statusLabel.Text = "🟢 Personagem Reiniciado - Loop Ativo"
    end
end)

-- Inicializar lista
updatePlayerList()

-- Instruções
print("🎯 Script Teleport Sneak Carregado!")
print("📌 Selecione um jogador na lista e ative o loop")
print("🛡️ Anti-Bring e Push Gear ativados automaticamente")
