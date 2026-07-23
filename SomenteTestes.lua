local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local parentGui = (pcall(function() return CoreGui:IsA("GuiService") end) and CoreGui) or localPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("SuperRingHub") then
    parentGui.SuperRingHub:Destroy()
end

-- Variáveis de Estado
local isEnabled = false
local selectedTarget = nil
local gearTornadoID = 127506257
local isRunningLoop = false

-- Remotes
local avatarRemote = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("AvatarMainRE", 5)

-- Criação da Interface GUI (Otimizada para Mobile)
local ScreenGui = Instance.new("ScreenGui", parentGui)
ScreenGui.Name = "SuperRingHub"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 290, 0, 410)
Main.Position = UDim2.new(0.5, -145, 0.5, -205)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Main.Draggable = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
Title.Text = "  Super Ring - Tornado Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- Status / Alvo Atual
local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size = UDim2.new(1, -16, 0, 28)
StatusLabel.Position = UDim2.new(0, 8, 0, 46)
StatusLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
StatusLabel.Text = "Alvo: Nenhum selecionado"
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 13
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

-- Botão Liga/Desliga do Super Ring
local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(1, -16, 0, 36)
ToggleBtn.Position = UDim2.new(0, 8, 0, 80)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "SUPER RING: DESLIGADO"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- ScrollingFrame para Lista de Jogadores
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -16, 0, 265)
Scroll.Position = UDim2.new(0, 8, 0, 126)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- Função Principal do Ciclo Super Ring (Equip, Disparar e Guiar)
local function executeSuperRing()
    if not avatarRemote then return end

    -- 1. Equipar o Gear via Remote Adaptado
    local equipArgs = {
        [1] = {
            ["event"] = "EquipGear",
            ["id"] = gearTornadoID
        }
    }
    pcall(function()
        avatarRemote:FireServer(unpack(equipArgs))
    end)

    -- 2. Aguarda o gear aparecer na mão do personagem
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local gearFolder = nil
    local startTime = tick()
    
    while tick() - startTime < 2 do
        gearFolder = char:FindFirstChild("Gear" .. gearTornadoID)
        if gearFolder then break end
        task.wait(0.05)
    end

    if gearFolder then
        local remoteEvent = gearFolder:FindFirstChild("RemoteEvent")
        if remoteEvent then
            -- 3. Disparar o Tornado
            local fireArgs = { [1] = "DO THE THING!!!" }
            pcall(function()
                remoteEvent:FireServer(unpack(fireArgs))
            end)
        end
    end
end

-- Loop de Funcionamento Controlado pela Chave e Alvo
task.spawn(function()
    while true do
        if isEnabled and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            -- Executa o ciclo de disparo
            pcall(function()
                executeSuperRing()
            end)
            
            -- Aguarda o cooldown estimado do gear antes de repetir
            task.wait(3.5) 
        else
            task.wait(0.5)
        end
    end
end)

-- Monitor de Física em Tempo Real no Workspace para o Alvo
Workspace.ChildAdded:Connect(function(child)
    if isEnabled and child.Name == "Tornado" and selectedTarget then
        task.spawn(function()
            task.wait(0.03) -- Tempo hábil para carregar componentes de física
            local tChar = selectedTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            
            if tRoot and child and child.Parent then
                local bodyVel = child:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then
                    local direction = (tRoot.Position - child.Position).Unit
                    bodyVel.Velocity = direction * 250 -- Velocidade ajustada para alta precisão
                end
                
                pcall(function()
                    child.CFrame = CFrame.new(child.Position, tRoot.Position)
                end)
            end
        end)
    end
end)

-- Botão Liga/Desliga
ToggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        ToggleBtn.Text = "SUPER RING: LIGADO"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleBtn.Text = "SUPER RING: DESLIGADO"
    end
end)

-- Atualizador Dinâmico da Lista de Alvos
local function updatePlayerList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local ItemBtn = Instance.new("TextButton", Scroll)
            ItemBtn.Size = UDim2.new(1, -4, 0, 36)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            ItemBtn.Text = "   " .. plr.Name
            ItemBtn.TextColor3 = Color3.new(1, 1, 1)
            ItemBtn.Font = Enum.Font.SourceSansBold
            ItemBtn.TextSize = 14
            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)

            ItemBtn.MouseButton1Click:Connect(function()
                selectedTarget = plr
                StatusLabel.Text = "Alvo: " .. plr.Name
                StatusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
