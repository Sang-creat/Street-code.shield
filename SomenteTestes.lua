--// Configuração do Ambiente e Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Variáveis de Controle Global (Persistentes para conexões e loops)
getgenv().MacroRunning = getgenv().MacroRunning or false
getgenv().SelectedTarget = getgenv().SelectedTarget or nil
getgenv().VoidModeActive = getgenv().VoidModeActive or false
getgenv().FlingModeActive = getgenv().FlingModeActive or false

-- Ponto seguro no Void (Coordenadas de altura/vazio controladas)
local VOID_POSITION = Vector3.new(0, -450, 0)

-- Limpeza de interface anterior caso já exista
if CoreGui:FindFirstChild("TrollHub_PortoLeste") then
    CoreGui.TrollHub_PortoLeste:Destroy()
end

--// Construção da Interface Gráfica (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHub_PortoLeste"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Porto Leste - Tactical Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Lista de Alvos (ScrollingFrame)
local TargetScroll = Instance.new("ScrollingFrame")
TargetScroll.Size = UDim2.new(0.9, 0, 0, 160)
TargetScroll.Position = UDim2.new(0.05, 0, 0, 50)
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
            pButton.Size = UDim2.new(1, 0, 0, 30)
            pButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            pButton.Text = player.Name
            pButton.TextSize = 14
            pButton.Font = Enum.Font.Gotham
            pButton.Parent = TargetScroll
            
            pButton.MouseButton1Click:Connect(function()
                getgenv().SelectedTarget = player
                pButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            end)
        end
    end
    TargetScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Botão Função 1: Void + Auto-Equip Pós-ForceField + Kill
local BtnVoid = Instance.new("TextButton")
BtnVoid.Size = UDim2.new(0.9, 0, 0, 45)
BtnVoid.Position = UDim2.new(0.05, 0, 0, 225)
BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnVoid.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
BtnVoid.TextSize = 14
BtnVoid.Font = Enum.Font.GothamBold
BtnVoid.Parent = MainFrame

local UICornerBtn1 = Instance.new("UICorner")
UICornerBtn1.CornerRadius = UDim.new(0, 6)
UICornerBtn1.Parent = BtnVoid

-- Botão Função 2: WalkFling + Void Caça Contínua
local BtnFling = Instance.new("TextButton")
BtnFling.Size = UDim2.new(0.9, 0, 0, 45)
BtnFling.Position = UDim2.new(0.05, 0, 0, 280)
BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFling.Text = "Modo WalkFling + Alvo [OFF]"
BtnFling.TextSize = 14
BtnFling.Font = Enum.Font.GothamBold
BtnFling.Parent = MainFrame

local UICornerBtn2 = Instance.new("UICorner")
UICornerBtn2.CornerRadius = UDim.new(0, 6)
UICornerBtn2.Parent = BtnFling

-- Botão de Fechar GUI
local BtnClose = Instance.new("TextButton")
BtnClose.Size = UDim2.new(0.9, 0, 0, 35)
BtnClose.Position = UDim2.new(0.05, 0, 0, 355)
BtnClose.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnClose.Text = "Minimizar / Ocultar"
BtnClose.TextSize = 13
BtnClose.Font = Enum.Font.Gotham
BtnClose.Parent = MainFrame

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = BtnClose

--// Sistema de Anti-Void Base (Mantém seguro no vácuo se ativado)
RunService.Heartbeat:Connect(function()
    if getgenv().VoidModeActive or getgenv().FlingModeActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if hrp.Position.Y < -300 then
                hrp.CFrame = CFrame.new(VOID_POSITION)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

--// Lógica da Função 1: Void -> Espera ForceField cair -> Teleporta com Gear a 1 Stud -> Mata -> Repete
BtnVoid.MouseButton1Click:Connect(function()
    getgenv().VoidModeActive = not getgenv().VoidModeActive
    if getgenv().VoidModeActive then
        getgenv().FlingModeActive = false -- Desativa a outra função para evitar conflito
        BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnFling.Text = "Modo WalkFling + Alvo [OFF]"
        
        BtnVoid.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [ON]"
    else
        BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().VoidModeActive then
            local target = getgenv().SelectedTarget
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local tChar = target.Character
                local tHrp = tChar.HumanoidRootPart
                local tForceField = tChar:FindFirstChildOfClass("ForceField")
                local tHum = tChar:FindFirstChildOfClass("Humanoid")
                
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if tHum and tHum.Health > 0 and myHrp then
                    if tForceField then
                        -- Se o alvo tem ForceField, fica seguro no Void aguardando a queda
                        myHrp.CFrame = CFrame.new(VOID_POSITION)
                        myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    else
                        -- Assim que o ForceField sai, teleporte imediato a 1 stud nas costas
                        local offset = tHrp.CFrame.LookVector * -1
                        myHrp.CFrame = CFrame.new(tHrp.Position + offset + Vector3.new(0, 0, 0), tHrp.Position)
                        
                        -- Aguarda o ciclo de abate e o alvo morrer para puxar de volta ao void
                        repeat
                            task.wait(0.05)
                        until not target.Character or not target.Character:FindFirstChildOfClass("Humanoid") or target.Character.Humanoid.Health <= 0
                        
                        -- Alvo morto, retorna ao void para reiniciar o ciclo
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(VOID_POSITION)
                        end
                    end
                end
            end
        end
    end
end)

--// Lógica da Função 2: WalkFling + Atribuição de Caça Contínua (Bypass ForceField via colisão/void)
BtnFling.MouseButton1Click:Connect(function()
    getgenv().FlingModeActive = not getgenv().FlingModeActive
    if getgenv().FlingModeActive then
        getgenv().VoidModeActive = false -- Desativa a outra função
        BtnVoid.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnVoid.Text = "Modo Void + Auto-Kill [OFF]"
        
        BtnFling.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnFling.Text = "Modo WalkFling + Alvo [ON]"
    else
        BtnFling.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnFling.Text = "Modo WalkFling + Alvo [OFF]"
    end
end)

-- Motor de WalkFling Dinâmico (Gera torque e velocidade de colisão severa)
RunService.Stepped:Connect(function()
    if getgenv().FlingModeActive then
        local target = getgenv().SelectedTarget
        local myChar = LocalPlayer.Character
        if target and target.Character and myChar then
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar:FindFirstChildOfClass("Humanoid")
            
            if tHrp and myHrp and myHum then
                -- Gruda na posição do alvo gerando instabilidade física (Fling)
                myHrp.CFrame = tHrp.CFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(30000, 30000, 30000)
                myHrp.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                myHum.PlatformStand = true
            end
        end
    end
end)

-- Ação do botão de fechar/minimizar interface
local minimized = false
BtnClose.MouseButton1Click:Connect(function()
    minimized = not minimized
    TargetScroll.Visible = not minimized
    BtnVoid.Visible = not minimized
    BtnFling.Visible = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 80)
        BtnClose.Text = "Restaurar Painel"
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 420)
        BtnClose.Text = "Minimizar / Ocultar"
    end
end)
