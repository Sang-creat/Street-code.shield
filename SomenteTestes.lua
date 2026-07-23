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
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 260, 0, 400), UDim2.new(0.5, -130, 0.5, -200), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Teleguiado de Tornado", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

-- Variável do Alvo Selecionado
local selectedTarget = nil

local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size, StatusLabel.Position, StatusLabel.BackgroundColor3, StatusLabel.Text, StatusLabel.TextColor3 = UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 40), Color3.fromRGB(40, 40, 40), "Alvo: Nenhum selecionado", Color3.new(1, 1, 0), Enum.Font.SourceSans
Instance.new("UICorner", StatusLabel)

-- Lista de Jogadores
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency, Scroll.ScrollBarThickness = UDim2.new(1, -10, 1, -125), UDim2.new(0, 5, 0, 75), true, 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- MONITOR DE TORNADO (Intercepta e redireciona para o alvo selecionado)
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Tornado" and selectedTarget then
        task.spawn(function()
            local tChar = selectedTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            
            if tRoot then
                local bodyVel = child:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then
                    -- Redireciona a velocidade do tornado diretamente para a posição do alvo em alta velocidade
                    local direction = (tRoot.Position - child.Position).Unit
                    bodyVel.Velocity = direction * 150 -- Velocidade customizada do teleguiado
                end
                
                -- Ajusta a rotação para olhar pro alvo
                pcall(function()
                    child.CFrame = CFrame.new(child.Position, tRoot.Position)
                end)
            end
        end)
    end
end)

-- Atualizar Lista de Jogadores
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

            local Btn = Instance.new("TextButton", Item)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
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
