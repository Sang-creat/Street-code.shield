local Players, RunService, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Criação da GUI e Janela Principal
local ScreenGui = Instance.new("ScreenGui", (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")))
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TeleportGUI", false

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 240, 0, 360), UDim2.new(0.5, -120, 0.5, -180), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Menu de Teleporte", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

-- Estados do Menu
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopTask = nil

-- Container de Botões de Alternância (Topo)
local TopContainer = Instance.new("Frame", Main)
TopContainer.Size, TopContainer.Position, TopContainer.BackgroundTransparency = UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 40), true
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
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 4)

-- Função de Teleporte em Passos (Tween + Noclip de Longo Alcance)
local function tweenTeleportTo(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local noclip = RunService.Stepped:Connect(function()
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenTime = math.clamp(distance / 400, 0.1, 15)

    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- Gerenciador do LoopGoto Seguro
local function startLoop()
    if loopTask then task.cancel(loopTask) end
    loopTask = task.spawn(function()
        while loopGotoEnabled and activeLoopTarget do
            local tChar = activeLoopTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                tweenTeleportTo(tRoot.CFrame + Vector3.new(0, 3, 0))
            end
            task.wait(0.5)
        end
    end)
end

-- Atualizar Lista de Jogadores Dinamicamente
local function updateList()
    for _, child in ipairs(Scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local Item = Instance.new("Frame", Scroll)
            Item.Size, Item.BackgroundColor3 = UDim2.new(1, 0, 0, 32), Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Item)

            local Btn = Instance.new("TextButton", Item)
            Btn.Size, Btn.BackgroundTransparency, Btn.Text, Btn.TextColor3 = UDim2.new(1, 0, 1, 0), true, "  " .. plr.Name, Color3.new(1, 1, 1)
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 14

            Btn.MouseButton1Click:Connect(function()
                local tChar = plr.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    if loopGotoEnabled then
                        activeLoopTarget = plr
                        startLoop()
                    else
                        tweenTeleportTo(tChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 36)
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
