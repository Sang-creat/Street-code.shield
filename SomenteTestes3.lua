--// Configuração do Ambiente e Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// Variáveis de Controle Global e de Estado (WalkFling + Hub)
getgenv().SelectedTarget = getgenv().SelectedTarget or nil
getgenv().VoidModeActive = getgenv().VoidModeActive or false
getgenv().FlingModeActive = getgenv().FlingModeActive or false

-- Variáveis específicas do WalkFling (Infinite Yield Otimizado para Pulo)
local walkFlingEnabled = false
local heartbeatConnection = nil
local characterAddedConnection = nil

local VOID_POSITION = Vector3.new(0, -450, 0)
local lastTargetPosition = CFrame.new(0, 5, 0)

-- Limpeza de interface anterior
if CoreGui:FindFirstChild("TrollHub_PortoLeste") then
    CoreGui.TrollHub_PortoLeste:Destroy()
end

--// ====================================================================
--// LÓGICA DO WALKFLING CORRIGIDA (LIBERANDO O PULO E MOVIMENTO)
--// ====================================================================

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function startWalkFlingLogic()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = getRoot(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root then return end
    
    local movel = 1
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not walkFlingEnabled then
            if heartbeatConnection then heartbeatConnection:Disconnect() end
            return
        end
        
        if character and character.Parent and root and root.Parent then
            -- Se o player estiver pulando ou no ar, damos folga no eixo Y para o pulo funcionar
            local currentVelocity = root.AssemblyLinearVelocity
            local isJumping = humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall)
            
            if isJumping then
                -- Mantém a velocidade horizontal para o fling continuar se encostar em alguém, mas deixa o Y livre para pular
                root.AssemblyLinearVelocity = Vector3.new(currentVelocity.X * 50, currentVelocity.Y, currentVelocity.Z * 50)
            else
                -- Lógica normal de fling do IY modificada para não travar o andar
                root.AssemblyLinearVelocity = Vector3.new(currentVelocity.X * 5000, movel * 5000, currentVelocity.Z * 5000)
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
    
    local character = LocalPlayer.Character
    if character then
        local root = getRoot(character)
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Gerenciador de Renascimento (Respawn / Persistência do WalkFling)
local function monitorCharacter()
    if characterAddedConnection then characterAddedConnection:Disconnect() end
    
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        if walkFlingEnabled then
            task.wait(0.5)
            if walkFlingEnabled then
                startWalkFlingLogic()
            end
        end
    end)
end

monitorCharacter()

--// Construção da Interface Gráfica (GUI) Adaptada para Mobile
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHub_PortoLeste"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Botão Flutuante Superior Direito (Abrir/Fechar o Menu)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(1, -55, 0, 15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "HUB"
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local UICornerToggle = Instance.new("UICorner")
UICornerToggle.CornerRadius = UDim.new(0, 8)
UICornerToggle.Parent = ToggleButton

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 465)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Sistema de Arrastar com o dedo (Mobile Draggable)
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Porto Leste - Tactical Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Lista de Alvos
local TargetScroll = Instance.new("ScrollingFrame")
TargetScroll.Size = UDim2.new(0.9, 0, 0, 150)
TargetScroll.Position = UDim2.new(0.05, 0, 0, 45)
TargetScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TargetScroll.BorderSizePixel = 0
TargetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TargetScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = TargetScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdatePlayerList()
    for _, child in ipairs(TargetScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pButton = Instance.new("TextButton")
            pButton.Size = UDim2.new(1, 0, 0, 35)
            pButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            pButton.Text = player.Name
            pButton.TextSize = 14
            pButton.Font = Enum.Font.Gotham
            pButton.Parent = TargetScroll
            
            pButton.MouseButton1Click:Connect(function()
                getgenv().SelectedTarget = player
                for _, b in ipairs(TargetScroll:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
                end
                pButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            end)
        end
    end
    TargetScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Botões da Interface
local BtnVoid = Instance.new("TextButton")
BtnVoid.Size = UDim2.new(0.9, 0, 0, 40)
BtnVoid.Position = UDim2.new(0.05, 0, 0, 205)
BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnVoid.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
BtnVoid.TextSize = 13
BtnVoid.Font = Enum.Font.GothamBold
BtnVoid.Parent = MainFrame
Instance.new("UICorner", BtnVoid).CornerRadius = UDim.new(0, 6)

local BtnFling = Instance.new("TextButton")
BtnFling.Size = UDim2.new(0.9, 0, 0, 40)
BtnFling.Position = UDim2.new(0.05, 0, 0, 252)
BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFling.Text = "Modo Trava + Alvo [OFF]"
BtnFling.TextSize = 13
BtnFling.Font = Enum.Font.GothamBold
BtnFling.Parent = MainFrame
Instance.new("UICorner", BtnFling).CornerRadius = UDim.new(0, 6)

local BtnWalkFling = Instance.new("TextButton")
BtnWalkFling.Size = UDim2.new(0.9, 0, 0, 40)
BtnWalkFling.Position = UDim2.new(0.05, 0, 0, 299)
BtnWalkFling.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BtnWalkFling.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnWalkFling.Text = "WalkFling IY [OFF]"
BtnWalkFling.TextSize = 13
BtnWalkFling.Font = Enum.Font.GothamBold
BtnWalkFling.Parent = MainFrame
Instance.new("UICorner", BtnWalkFling).CornerRadius = UDim.new(0, 6)

local BtnClose = Instance.new("TextButton")
BtnClose.Size = UDim2.new(0.9, 0, 0, 35)
BtnClose.Position = UDim2.new(0.05, 0, 0, 355)
BtnClose.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnClose.Text = "Desativar e Fechar Script"
BtnClose.TextSize = 12
BtnClose.Font = Enum.Font.Gotham
BtnClose.Parent = MainFrame
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 6)

--// Sistema de Anti-Void Base
RunService.Heartbeat:Connect(function()
    if getgenv().VoidModeActive or getgenv().FlingModeActive then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -300 then
                hrp.CFrame = CFrame.new(VOID_POSITION)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

--// Lógica da Função 1 (Void + Auto-Kill)
BtnVoid.MouseButton1Click:Connect(function()
    getgenv().VoidModeActive = not getgenv().VoidModeActive
    if getgenv().VoidModeActive then
        getgenv().FlingModeActive = false
        BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnFling.Text = "Modo Trava + Alvo [OFF]"
        
        BtnVoid.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [ON]"
    else
        BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
        
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = lastTargetPosition + Vector3.new(0, 3, 0)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().VoidModeActive then
            local target = getgenv().SelectedTarget
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local tChar = target.Character
                local tHrp = tChar.HumanoidRootPart
                local tForceField = tChar:FindFirstChildOfClass("ForceField")
                local tHum = tChar:FindFirstChildOfClass("Humanoid")
                
                lastTargetPosition = tHrp.CFrame
                
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if tHum and tHum.Health > 0 and myHrp then
                    if tForceField then
                        myHrp.CFrame = CFrame.new(VOID_POSITION)
                        myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    else
                        local offset = tHrp.CFrame.LookVector * -1
                        myHrp.CFrame = CFrame.new(tHrp.Position + offset + Vector3.new(0, 0, 0), tHrp.Position)
                        
                        local startTime = tick()
                        local successKill = false
                        
                        repeat
                            task.wait(0.05)
                            if not target.Character or not target.Character:FindFirstChildOfClass("Humanoid") or target.Character.Humanoid.Health <= 0 then
                                successKill = true
                                break
                            end
                            if tick() - startTime > 3.7 then
                                break
                            end
                        until not getgenv().VoidModeActive
                        
                        local currentMyChar = LocalPlayer.Character
                        if currentMyChar and currentMyChar:FindFirstChild("HumanoidRootPart") then
                            currentMyChar.HumanoidRootPart.CFrame = CFrame.new(VOID_POSITION)
                        end
                        
                        if not successKill then
                            task.wait(3)
                        end
                    end
                end
            end
        end
    end
end)

--// Lógica da Função 2 (Modo Trava)
BtnFling.MouseButton1Click:Connect(function()
    getgenv().FlingModeActive = not getgenv().FlingModeActive
    if getgenv().FlingModeActive then
        getgenv().VoidModeActive = false
        BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
        
        BtnFling.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnFling.Text = "Modo Trava + Alvo [ON]"
    else
        BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnFling.Text = "Modo Trava + Alvo [OFF]"
        
        local myChar = LocalPlayer.Character
        if myChar then
            local myHum = myChar:FindFirstChildOfClass("Humanoid")
            if myHum then myHum.PlatformStand = false end
        end
    end
end)

RunService.Stepped:Connect(function()
    if getgenv().FlingModeActive then
        local target = getgenv().SelectedTarget
        local myChar = LocalPlayer.Character
        if target and target.Character and myChar then
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar:FindFirstChildOfClass("Humanoid")
            
            if tHrp and myHrp and myHum then
                myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 1.5)
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHum.PlatformStand = false
            end
        end
    end
end)

--// Botão WalkFling Otimizado
BtnWalkFling.MouseButton1Click:Connect(function()
    walkFlingEnabled = not walkFlingEnabled
    
    if walkFlingEnabled then
        BtnWalkFling.Text = "WalkFling IY [ON]"
        BtnWalkFling.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        startWalkFlingLogic()
    else
        BtnWalkFling.Text = "WalkFling IY [OFF]"
        BtnWalkFling.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        stopWalkFlingLogic()
    end
end)

-- Botão de fechar definitivo
BtnClose.MouseButton1Click:Connect(function()
    getgenv().VoidModeActive = false
    getgenv().FlingModeActive = false
    stopWalkFlingLogic()
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
    end
    
    local myChar = LocalPlayer.Character
    if myChar then
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum then myHum.PlatformStand = false end
    end
    ScreenGui:Destroy()
end)
