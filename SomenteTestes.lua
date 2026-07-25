local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Evita duplicidade se injetar duas vezes
if CoreGui:FindFirstChild("TornadoGUI") then
    CoreGui.TornadoGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TornadoGUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 300)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Permite arrastar a janela na tela do celular
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Auto Tornado - Delta"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

-- Botão de Toggle (Liga/Desliga)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Status: OFF"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- Lista de Jogadores (ScrollingFrame para toque mobile)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
scrollingFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

local running = false
local selectedTarget = nil
local avatarMainRE = ReplicatedStorage:WaitForChild("AvatarMainRE")

toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggleBtn.Text = "Status: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        toggleBtn.Text = "Status: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Atualiza a lista dinamicamente
local function updatePlayerList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -10, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Text = player.Name
            pBtn.Font = Enum.Font.SourceSans
            pBtn.TextSize = 14
            pBtn.Parent = scrollingFrame
            
            pBtn.MouseButton1Click:Connect(function()
                selectedTarget = player
                pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
                task.spawn(function()
                    task.wait(0.5)
                    pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end)
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Loop principal de Equip + Aim-Lock + Disparo
task.spawn(function()
    while true do
        if running and selectedTarget then
            -- 1. Equipa o gear
            pcall(function()
                avatarMainRE:FireServer({
                    ["id"] = 102705454,
                    ["event"] = "equip",
                    ["equiptype"] = "Gear"
                })
            end)
            
            task.wait(1) -- Tempo de carregamento
            
            local character = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            local tool = character and character:FindFirstChild("Gear102705454") or backpack:FindFirstChild("Gear102705454")
            
            if tool and tool.Parent == backpack then
                tool.Parent = character
            end
            
            -- Disparos em cadeia enquanto ligado e o alvo for válido
            while running and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") do
                local myRoot = character and character:FindFirstChild("HumanoidRootPart")
                local targetRoot = selectedTarget.Character.HumanoidRootPart
                
                -- Aim-Lock instantâneo para o alvo selecionado
                if myRoot then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                end
                
                -- Simula o toque para disparar o tornado
                if tool and tool.Parent == character then
                    pcall(function()
                        tool:Activate()
                    end)
                end
                
                task.wait(2) -- Delay entre os tornados
            end
        end
        task.wait(0.5)
    end
end)

