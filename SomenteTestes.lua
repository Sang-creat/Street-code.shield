local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Remove instâncias antigas para evitar duplicidade
if CoreGui:FindFirstChild("TornadoGUI") then
    CoreGui.TornadoGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TornadoGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 320)
mainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Auto Tornado - Delta"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

-- Botão de Toggle (Liga/Desliga)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Status: OFF"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 15
toggleBtn.Parent = mainFrame

-- Label de Status do Alvo Selecionado
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.9, 0, 0, 25)
targetLabel.Position = UDim2.new(0.05, 0, 0.30, 0)
targetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.Text = "Alvo: Nenhum"
targetLabel.Font = Enum.Font.SourceSans
targetLabel.TextSize = 13
targetLabel.Parent = mainFrame

-- Lista de Jogadores (ScrollingFrame)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
scrollingFrame.Position = UDim2.new(0.05, 0, 0.40, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 6)

-- Atualiza o tamanho do Canvas automaticamente conforme os itens entram
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

local running = false
local selectedTarget = nil
local avatarMainRE = ReplicatedStorage:WaitForChild("AvatarMainRE")

-- Função do Toggle
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

-- Popula a lista de jogadores
local function updatePlayerList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -6, 0, 35)
            pBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Text = player.Name
            pBtn.Font = Enum.Font.SourceSansBold
            pBtn.TextSize = 14
            pBtn.Parent = scrollingFrame
            
            pBtn.MouseButton1Click:Connect(function()
                selectedTarget = player
                targetLabel.Text = "Alvo: " .. player.Name
                targetLabel.TextColor3 = Color3.fromRGB(50, 200, 255)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Loop principal de Equip + Aim-Lock + Disparo
task.spawn(function()
    while true do
        if running and selectedTarget then
            pcall(function()
                avatarMainRE:FireServer({
                    ["id"] = 102705454,
                    ["event"] = "equip",
                    ["equiptype"] = "Gear"
                })
            end)
            
            task.wait(1)
            
            local character = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            local tool = character and character:FindFirstChild("Gear102705454") or backpack:FindFirstChild("Gear102705454")
            
            if tool and tool.Parent == backpack then
                tool.Parent = character
            end
            
            while running and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") do
                local myRoot = character and character:FindFirstChild("HumanoidRootPart")
                local targetRoot = selectedTarget.Character.HumanoidRootPart
                
                if myRoot then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                end
                
                if tool and tool.Parent == character then
                    pcall(function()
                        tool:Activate()
                    end)
                end
                
                task.wait(2)
            end
        end
        task.wait(0.5)
    end
end)
