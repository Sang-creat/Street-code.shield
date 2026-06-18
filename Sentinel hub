local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configurações de estado
local Settings = { 
    AntiLevitacao = false, 
    GhostJitter = false, 
    AutoEvasao = false 
}

-- Criando a UI com ResetOnSpawn = false para persistir após morte
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "SentinelHub"
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 140)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite mover a janela

local function createBtn(text, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = text .. (Settings[key] and ": ON" or ": OFF")
    end)
end

createBtn("Anti-Levitacao", "AntiLevitacao")
createBtn("Ghost Jitter", "GhostJitter")
createBtn("Auto-Evasao", "AutoEvasao")

-- Lógica unificada executada a cada frame (Heartbeat)
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Anti-Levitação: Destrói forças que tentam te erguer/jogar
    if Settings.AntiLevitacao and hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyAngularVelocity") or v:IsA("LinearVelocity") then 
                v:Destroy() 
            end
        end
    end
    
    -- 2. Ghost Jitter: Pequena variação na posição para "quebrar" mira de teleporte
    if Settings.GhostJitter and hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-0.02, 0.02), 0, math.random(-0.02, 0.02))
    end
    
    -- 3. Auto-Evasão: Teleporta para cima se alguém chegar perto
    if Settings.AutoEvasao and hrp then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < 12 then 
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 25, 0)
                end
            end
        end
    end
end)
