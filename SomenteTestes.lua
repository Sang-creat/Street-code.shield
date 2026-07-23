local Players, RunService, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local parentGui = (pcall(function() return CoreGui:IsA("GuiService") end) and CoreGui) or localPlayer:WaitForChild("PlayerGui")

-- Remove GUI anterior para evitar duplicidade
if parentGui:FindFirstChild("TeleportGUI") then
    parentGui.TeleportGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", parentGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TeleportGUI", false

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 260, 0, 380), UDim2.new(0.5, -130, 0.5, -190), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Menu de Teleporte Global", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

-- Estados do Menu
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopTask = nil
local isTeleporting = false

-- Container de Botões de Alternância (Topo)
local TopContainer = Instance.new("Frame", Main)
TopContainer.Size, TopContainer.Position, TopContainer.BackgroundTransparency = UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 42), true
local TopLayout = Instance.new("UIListLayout", TopContainer)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.Padding = UDim.new(0, 5)

-- Botão Toggle LoopGoto (Liga/Desliga)
local LoopToggleBtn = Instance.new("TextButton", TopContainer)
LoopToggleBtn.Size, LoopToggleBtn.BackgroundColor3, LoopToggleBtn.Text, LoopToggleBtn.TextColor3, LoopToggleBtn.Font = UDim2.new(1, 0, 1, 0), Color3.fromRGB(120, 0, 0), "LoopGoto: DESLIGADO", Color3.new(1, 1, 1), Enum.Font.SourceSansBold
Instance.new("UICorner", LoopToggleBtn)

LoopToggleBtn.MouseButton1Click:Connect(function()
    loopGotoEnabled = not loopGotoEnabled
    if loopGotoEnabled then
        LoopToggleBtn.Text = "LoopGoto: LIGADO"
        LoopToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        LoopToggleBtn.Text = "LoopGoto: DESLIGADO"
        LoopToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        activeLoopTarget = nil
        if loopTask then task.cancel(loopTask) loopTask = nil end
    end
end)

-- Lista de Jogadores (ScrollingFrame)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency, Scroll.ScrollBarThickness = UDim2.new(1, -10, 1, -85), UDim2.new(0, 5, 0, 80), true, 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Atualiza o tamanho da rolagem automaticamente baseada nos elementos gerados
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- FUNÇÃO CHAVE: Forçar o carregamento da área via BuildRE antes de interagir
local function forceLoadArea(targetPosition)
    local buildRE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("BuildRE")
    if buildRE then
        local args = {
            [1] = "ReplicationFocus",
            [2] = true,
            [3] = targetPosition
        }
        pcall(function()
            buildRE:FireServer(unpack(args))
        end)
    end
end

-- Função de Teleporte em Passos Segura (Com Noclip e Anti-Travamento)
local function tweenTeleportTo(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isTeleporting then return end

    isTeleporting = true

    -- Força o carregamento da região de destino imediatamente antes do Tween
    forceLoadArea(targetCFrame.Position)
    task.wait(0.15)

    local noclip = RunService.Stepped:Connect(function()
        if char and char.Parent then
            for _, p in ipairs(char:GetDescendants()) do 
                if p:IsA("BasePart") then p.CanCollide = false end 
            end
        end
    end)

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenTime = math.clamp(distance / 400, 0.1, 15)

    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    
    pcall(function()
        tween.Completed:Wait()
    end)

    if noclip then noclip:Disconnect() end
    isTeleporting = false
end

-- Gerenciador do LoopGoto Seguro
local function startLoop()
    if loopTask then task.cancel(loopTask) end
    loopTask = task.spawn(function()
        while loopGotoEnabled and activeLoopTarget do
            local tChar = activeLoopTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                forceLoadArea(tRoot.Position)
                tweenTeleportTo(tRoot.CFrame + Vector3.new(0, 3, 0))
            end
            task.wait(0.4)
        end
    end)
end

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

            local Btn = Instance.new("TextButton", Item)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = "  " .. plr.Name
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Font = Enum.Font.SourceSansBold
            Btn.TextSize = 14

            Btn.MouseButton1Click:Connect(function()
                local tChar = plr.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    if loopGotoEnabled then
                        activeLoopTarget = plr
                        startLoop()
                    else
                        tweenTeleportTo(tRoot.CFrame + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
