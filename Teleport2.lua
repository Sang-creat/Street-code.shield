--[[
    SCRIPT DE TELEPORTE MOBILE - DEFINITIVO (Com Interpolação de Longa Distância)
    Otimizado para Delta Executor
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local parentGui = (pcall(function() return CoreGui:IsA("GuiService") end) and CoreGui) or localPlayer:WaitForChild("PlayerGui")

-- Remove GUI anterior se já existir
if parentGui:FindFirstChild("TeleportGUI") then
    parentGui.TeleportGUI:Destroy()
end

local Gui = Instance.new("ScreenGui", parentGui)
Gui.Name, Gui.ResetOnSpawn = "TeleportGUI", false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Main.Draggable = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(100, 0, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 0, 90)
Title.Text = "Menu de Teleporte"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Estados das Chaves
local gotoEnabled = true
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopConnection = nil

-- Função de Teleporte por Interpolação (Tween + Noclip para longas distâncias / 3000+ studs)
local function tweenTeleportTo(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Desativa colisão para atravessar o mapa com segurança durante a interpolação
    local noclip = RunService.Stepped:Connect(function()
        for _, p in ipairs(char:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end)

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / 400 -- Velocidade baseada na lógica que funcionou

    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    noclip:Disconnect()
end

-- Gerenciador do LoopGoto (Repete o teleporte por interpolação periodicamente para o alvo selecionado)
local function startLoopGoto(targetPlr)
    if loopConnection then loopConnection:Disconnect() end
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not loopGotoEnabled or not activeLoopTarget or not activeLoopTarget.Character or not activeLoopTarget.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local tChar = activeLoopTarget.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot then
            tweenTeleportTo(tRoot.CFrame + Vector3.new(0, 3, 0))
            task.wait(1.5) -- Pausa antes de checar/executar o próximo ciclo do loop
        end
    end)
end

-- Container Superior para os Botões de Alternância
local TopContainer = Instance.new("Frame", Main)
TopContainer.Size = UDim2.new(1, -16, 0, 35)
TopContainer.Position = UDim2.new(0, 8, 0, 42)
TopContainer.BackgroundTransparency = 1

local TopLayout = Instance.new("UIListLayout", TopContainer)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.Padding = UDim.new(0, 10)

-- Função para criar os Botões de Toggle (Goto e LoopGoto visíveis)
local function createToggle(name, defaultState, callback)
    local btn = Instance.new("TextButton", TopContainer)
    btn.Size = UDim2.new(0.47, 0, 1, 0)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    btn.Text = name .. ": " .. (defaultState and "LIGADO" or "DESLIGADO")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "LIGADO" or "DESLIGADO")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
        callback(state)
    end)
    return btn
end

createToggle("Goto", true, function(state) 
    gotoEnabled = state 
end)

createToggle("LoopGoto", false, function(state) 
    loopGotoEnabled = state
    if not state then
        activeLoopTarget = nil
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    end
end)

-- Scroll de Jogadores
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -16, 1, -85)
Scroll.Position = UDim2.new(0, 8, 0, 82)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4

local ScrollLayout = Instance.new("UIListLayout", Scroll)
ScrollLayout.Padding = UDim.new(0, 5)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

local updateList

updateList = function()
    for _, c in ipairs(Scroll:GetChildren()) do 
        if c:IsA("Frame") then c:Destroy() end 
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local ItemFrame = Instance.new("Frame", Scroll)
            ItemFrame.Size = UDim2.new(1, 0, 0, 36)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

            -- Botão do Nome do Jogador (Executa o Teleporte por Interpolação)
            local Btn = Instance.new("TextButton", ItemFrame)
            Btn.Size = UDim2.new(1, -40, 1, 0)
            Btn.Position = UDim2.new(0, 0, 0, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = "  " .. plr.Name
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 14
            Btn.TextXAlignment = Enum.TextXAlignment.Left

            -- Círculo / Botão de Seleção do LoopGoto
            local Circle = Instance.new("TextButton", ItemFrame)
            Circle.Size = UDim2.new(0, 30, 0, 30)
            Circle.Position = UDim2.new(1, -33, 0.5, -15)
            Circle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            Circle.Text = (activeLoopTarget == plr) and "✅" or ""
            Circle.TextColor3 = Color3.new(1, 1, 1)
            Circle.TextSize = 12
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            Btn.MouseButton1Click:Connect(function()
                local tChar = plr.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = tChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    
                    if loopGotoEnabled then
                        activeLoopTarget = plr
                        startLoopGoto(plr)
                        updateList()
                    elseif gotoEnabled then
                        tweenTeleportTo(targetCFrame)
                    end
                end
            end)

            Circle.MouseButton1Click:Connect(function()
                if not loopGotoEnabled then return end
                
                if activeLoopTarget == plr then
                    activeLoopTarget = nil
                    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
                else
                    activeLoopTarget = plr
                    startLoopGoto(plr)
                end
                updateList()
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 41)
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
