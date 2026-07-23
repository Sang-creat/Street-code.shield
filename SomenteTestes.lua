local Players, RunService, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local parentGui = (pcall(function() return CoreGui:IsA("GuiService") end) and CoreGui) or localPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("TornadoHub") then
    parentGui.TornadoHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", parentGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TornadoHub", false

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 260, 0, 420), UDim2.new(0.5, -130, 0.5, -210), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Teleguiado de Tornado", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

-- Variáveis de Configuração e Alvo
local selectedTarget = nil
local gearTornadoID = 127506257
local remoteAvatar = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AvatarMainRE")

-- Status do Alvo Selecionado (Topo)
local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size, StatusLabel.Position, StatusLabel.BackgroundColor3, StatusLabel.Text, StatusLabel.TextColor3 = UDim2.new(1, -10, 0, 28), UDim2.new(0, 5, 0, 40), Color3.fromRGB(40, 40, 40), "Alvo: Nenhum selecionado", Color3.new(1, 1, 0), Enum.Font.SourceSansBold
Instance.new("UICorner", StatusLabel)

-- Botão de Auto-Equip e Disparo Teleguiado
local FireBtn = Instance.new("TextButton", Main)
FireBtn.Size, FireBtn.Position, FireBtn.BackgroundColor3, FireBtn.Text, FireBtn.TextColor3, FireBtn.Font = UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 75), Color3.fromRGB(0, 100, 160), "EQUIPAR & DISPARAR NO ALVO", Color3.new(1, 1, 1), Enum.Font.SourceSansBold
Instance.new("UICorner", FireBtn)

-- Lógica Robusta de Auto-Equip e Disparo com Tolerância a Latência
local function equipAndFireTornado()
    if not remoteAvatar then
        StatusLabel.Text = "Erro: Remote AvatarMainRE não achado!"
        StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        return
    end

    StatusLabel.Text = "Equipando gear..."
    StatusLabel.TextColor3 = Color3.new(1, 0.5, 0)

    -- 1. Dispara o Remote para equipar o gear
    remoteAvatar:FireServer({["id"] = gearTornadoID, ["event"] = "equip", ["equiptype"] = "Gear"})

    -- 2. Aguarda o personagem e a pasta do gear aparecerem com segurança (Timeout de 2 segundos)
    task.spawn(function()
        local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local gearName = "Gear" .. gearTornadoID
        local gearFolder = nil

        local startTime = tick()
        while tick() - startTime < 2 do
            gearFolder = char:FindFirstChild(gearName)
            if gearFolder then break end
            task.wait(0.05)
        end

        if gearFolder then
            -- 3. Procura o RemoteEvent interno do gear (ou usa pcall para disparar)
            local remoteEvent = gearFolder:FindFirstChild("RemoteEvent") or gearFolder:FindFirstChildOfClass("RemoteEvent")
            
            if remoteEvent then
                local args = {
                    [1] = "DO THE THING!!!"
                }
                pcall(function()
                    remoteEvent:FireServer(unpack(args))
                end)
                StatusLabel.Text = "Tornado disparado com sucesso!"
                StatusLabel.TextColor3 = Color3.new(0, 1, 0)
            else
                StatusLabel.Text = "Erro: RemoteEvent interno não achado!"
                StatusLabel.TextColor3 = Color3.new(1, 0, 0)
            end
        else
            StatusLabel.Text = "Erro: O servidor demorou para equipar!"
            StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
end

FireBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        StatusLabel.Text = "Selecione um alvo na lista!"
        StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        return
    end
    equipAndFireTornado()
end)

-- Lista de Jogadores (ScrollingFrame)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency, Scroll.ScrollBarThickness = UDim2.new(1, -10, 1, -120), UDim2.new(0, 5, 0, 115), true, 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- MONITOR DE TORNADO (Intercepta, altera velocidade, força e direciona para o alvo)
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Tornado" and selectedTarget then
        task.spawn(function()
            -- Pequeno atraso para garantir que a física (BodyVelocity) já foi criada no objeto pelo jogo
            task.wait(0.05)
            
            local tChar = selectedTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            
            if tRoot and child and child.Parent then
                local bodyVel = child:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then
                    local direction = (tRoot.Position - child.Position).Unit
                    bodyVel.Velocity = direction * 220 -- Velocidade turbinada do teleguiado
                end
                
                pcall(function()
                    child.CFrame = CFrame.new(child.Position, tRoot.Position)
                end)
            end
        end)
    end
end)

-- Atualizar Lista de Jogadores Dinamicamente
local function updateList()
    for _, child in ipairs(Scroll:GetChildren()) do 
        if child:IsA("Frame") then child:Destroy() end 
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local Item = Instance.new("Frame", Scroll)
            Item.Size = UDim2.new(1, -12, 0, 36)
            Item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Item)

            val = Item -- apenas escopo local seguro
            local Btn = Instance.new("TextButton", Item)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = "  " + plr.Name -- Correção opcional de string para evitar conflito
            Btn.Text = "  " .. plr.Name
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Font = Enum.Font.SourceSansBold
            Btn.TextSize = 14

            Btn.MouseButton1Click:Connect(function()
                selectedTarget = plr
                StatusLabel.Text = "Alvo: " .. plr.Name
                StatusLabel.TextColor3 = Color3.new(0, 1, 0)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
