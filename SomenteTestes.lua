local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Status: OFF"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 15
toggleBtn.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.9, 0, 0, 25)
targetLabel.Position = UDim2.new(0.05, 0, 0.30, 0)
targetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.Text = "Alvo: Nenhum"
targetLabel.Font = Enum.Font.SourceSans
targetLabel.TextSize = 13
targetLabel.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0.9, 0, 0.53, 0)
scrollingFrame.Position = UDim2.new(0.05, 0, 0.41, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

local running = false
local selectedTarget = nil
local gearId = 102705454
local avatarMainRE = ReplicatedStorage:WaitForChild("AvatarMainRE", 5)

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

-- Loop de execução otimizado com varredura universal de ferramenta
task.spawn(function()
    while true do
        if running and selectedTarget and avatarMainRE then
            local character = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            -- Procura o gear tanto no personagem quanto na mochila de forma flexível
            local currentTool = (character and character:FindFirstChild("Gear" .. gearId)) or 
                                (backpack and backpack:FindFirstChild("Gear" .. gearId)) or
                                (character and character:FindFirstChildOfClass("Tool")) or
                                (backpack and backpack:FindFirstChildOfClass("Tool"))

            if not currentTool or not humanoid or humanoid.Health <= 0 then
                pcall(function()
                    avatarMainRE:FireServer({
                        ["id"] = gearId,
                        ["event"] = "equip",
                        ["equiptype"] = "Gear"
                    })
                end)
                task.wait(1.5)
                character = LocalPlayer.Character
                backpack = LocalPlayer.Backpack
            end
            
            -- Reatribui a ferramenta atualizada
            character = LocalPlayer.Character
            backpack = LocalPlayer.Backpack
            local activeTool = (character and character:FindFirstChild("Gear" .. gearId)) or 
                               (backpack and backpack:FindFirstChild("Gear" .. gearId)) or
                               (character and character:FindFirstChildOfClass("Tool"))
            
            if activeTool then
                if activeTool.Parent == backpack then
                    activeTool.Parent = character
                end
                
                -- Executa o Aim-Lock e os disparos em cadeia respeitando o intervalo de 2 segundos
                while running and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") do
                    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = selectedTarget.Character.HumanoidRootPart
                    
                    if myRoot and targetRoot then
                        myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                    end
                    
                    if activeTool and activeTool.Parent == character then
                        pcall(function()
                            activeTool:Activate()
                        end)
                    else
                        break
                    end
                    
                    task.wait(2)
                end
            end
        end
        task.wait(2)
    end
end)
