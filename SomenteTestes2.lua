-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Variáveis de Controle de Estado
local walkFlingEnabled = false
local heartbeatConnection = nil
local characterAddedConnection = nil

-- ====================================================================
-- LÓGICA DO WALKFLING REPLICADA DO INFINITE YIELD (COM PERSISTÊNCIA)
-- ====================================================================

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function startWalkFlingLogic()
    -- Desconecta loops anteriores para evitar sobreposição
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = getRoot(character)
    
    if not root then return end
    
    local movel = 1
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not walkFlingEnabled then
            if heartbeatConnection then heartbeatConnection:Disconnect() end
            return
        end
        
        -- Garante que o character e a RootPart ainda são válidos no frame atual
        if character and character.Parent and root and root.Parent then
            local currentVelocity = root.AssemblyLinearVelocity
            
            -- Multiplicação física idêntica ao IY para quebrar o cálculo de colisão do Roblox
            root.AssemblyLinearVelocity = currentVelocity * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            
            if character and character.Parent and root and root.Parent then
                root.AssemblyLinearVelocity = currentVelocity
            end
            
            RunService.RenderStepped:Wait()
            if character and character.Parent and root and root.Parent then
                root.AssemblyLinearVelocity = currentVelocity + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        end
    end)
end

local function stopWalkFlingLogic()
    walkFlingEnabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    
    -- Reseta a velocidade para evitar travamentos residuais
    local character = LocalPlayer.Character
    if character then
        local root = getRoot(character)
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Gerenciador de Renascimento (Respawn / Persistência)
local function monitorCharacter()
    if characterAddedConnection then characterAddedConnection:Disconnect() end
    
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        if walkFlingEnabled then
            -- Pequeno delay para garantir que o motor físico carregou a RootPart após o spawn
            task.wait(0.5)
            if walkFlingEnabled then
                startWalkFlingLogic()
            end
        end
    end)
end

-- ====================================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI) SIMPLES
-- ====================================================================

-- Destrói interface antiga se executado novamente
if CoreGui:FindFirstChild("WalkFlingGUI") then
    CoreGui.WalkFlingGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WalkFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame Principal (Janela)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UUDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Lado esquerdo da tela
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar a janela pela tela
MainFrame.Parent = ScreenGui

-- Cantos arredondados para a janela
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- Título da Janela
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleLabel.Text = "IY WalkFling"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Botão de Alternar (ON / OFF)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 160, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Inicialmente vermelho (OFF)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

-- Feedback Visual e Acionamento do Botão
ToggleButton.MouseButton1Click:Connect(function()
    walkFlingEnabled = not walkFlingEnabled
    
    if walkFlingEnabled then
        ToggleButton.Text = "STATUS: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Verde
        startWalkFlingLogic()
    else
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Vermelho
        stopWalkFlingLogic()
    end
end)

-- Iniciar monitoramento de persistência de spawn
monitorCharacter()
