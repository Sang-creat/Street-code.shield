local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Estado do ESP (Começa desligado ou ligado, você decide)
local espEnabled = true

-- Criar a Interface Gráfica (Botão Liga/Desliga)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReachESP_UI"
ScreenGui.ResetOnSpawn = false
-- Tenta injetar no CoreGui para ficar protegido, se falhar vai para PlayerGui
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 160, 0, 45)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "ESP Reach: [ON]"
ToggleButton.Parent = ScreenGui

-- Função do Botão
ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "ESP Reach: [ON]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    else
        ToggleButton.Text = "ESP Reach: [OFF]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        -- Limpa tudo ao desligar
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        if handle:FindFirstChild("ExpandedReachBox") then handle.ExpandedReachBox:Destroy() end
                        if handle:FindFirstChild("ReachInfoTag") then handle.ReachInfoTag:Destroy() end
                    end
                end
            end
        end
    end
end)

-- Função principal do ESP
local function updateExpandedReachESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local character = player.Character
    local tool = character:FindFirstChildOfClass("Tool")
    
    if espEnabled and tool then
        local handle = tool:FindFirstChild("Handle")
        if handle then
            -- 1. Gerenciar a Caixa Tridimensional Real
            local boxVisual = handle:FindFirstChild("ExpandedReachBox")
            if not boxVisual then
                boxVisual = Instance.new("BoxHandleAdornee")
                boxVisual.Name = "ExpandedReachBox"
                boxVisual.Adornee = handle
                boxVisual.AlwaysOnTop = true
                boxVisual.Color3 = Color3.fromRGB(255, 40, 40)
                boxVisual.Transparency = 0.65
                boxVisual.ZIndex = 10
                boxVisual.Parent = handle
            end
            -- Aplica as dimensões reais da hitbox modificada pelo reach
            boxVisual.Size = handle.Size
            boxVisual.CFrame = handle.CFrame

            -- 2. Gerenciar o Texto Informativo (Distância, Dono e Tamanho)
            local infoTag = handle:FindFirstChild("ReachInfoTag")
            local textLabel
            
            if not infoTag then
                infoTag = Instance.new("BillboardGui")
                infoTag.Name = "ReachInfoTag"
                infoTag.Adornee = handle
                infoTag.Size = UDim2.new(0, 200, 0, 60)
                infoTag.StudsOffset = Vector3.new(0, 3, 0) -- Flutua um pouco acima da caixa
                infoTag.AlwaysOnTop = true
                
                textLabel = Instance.new("TextLabel")
                textLabel.Name = "Text"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0 -- Borda preta no texto para leitura clara
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.Parent = infoTag
                
                infoTag.Parent = handle
            else
                textLabel = infoTag:FindFirstChild("Text")
            end

            -- Calcula a distância entre você e a espada do inimigo
            local distance = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - handle.Position).Magnitude)
            end

            -- Formata o tamanho para números inteiros bonitos
            local sizeX = math.floor(handle.Size.X + 0.5)
            local sizeY = math.floor(handle.Size.Y + 0.5)
            local sizeZ = math.floor(handle.Size.Z + 0.5)

            -- Atualiza o texto em tempo real
            if textLabel then
                textLabel.Text = string.format("👤 %s\n📏 Dist: %d Studs\n📦 Tam: [%d, %d, %d]", 
                    player.Name, distance, sizeX, sizeY, sizeZ)
            end
        end
    else
        -- Se desativado ou sem ferramenta, limpa os elementos daquele player
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                if handle:FindFirstChild("ExpandedReachBox") then handle.ExpandedReachBox:Destroy() end
                if handle:FindFirstChild("ReachInfoTag") then handle.ReachInfoTag:Destroy() end
            end
        end
    end
end

-- Loop de execução contínua
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        pcall(function()
            updateExpandedReachESP(player)
        end)
    end
end)
