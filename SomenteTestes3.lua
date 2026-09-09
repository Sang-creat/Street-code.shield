local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configurações de estado
local Settings = { 
    AntiLevitacao = false, 
    GhostJitter = false, 
    AutoEvasao = false,
    WalkFling = false
}

-- Variáveis de controle do WalkFling
local walkFlingEnabled = false
local heartbeatConnection = nil
local characterAddedConnection = nil

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function startWalkFlingLogic()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    
    local character = Player.Character or Player.CharacterAdded:Wait()
    local root = getRoot(character)
    
    if not root then return end
    
    local movel = 1
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not walkFlingEnabled then
            if heartbeatConnection then heartbeatConnection:Disconnect() end
            return
        end
        
        if character and character.Parent and root and root.Parent then
            local currentVelocity = root.AssemblyLinearVelocity
            
            root.AssemblyLinearVelocity = currentVelocity * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            
            if character and character.Parent and root and root.Parent then
                root.AssemblyLinearVelocity = currentVelocity
            end
            
            RunService.RenderStepped:Wait()
            if character and character.Parent and root and root.Parent then
                root.AssemblyLinearVelocity = currentVelocity + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        end
    end)
end

local function stopWalkFlingLogic()
    walkFlingEnabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    
    local character = Player.Character
    if character then
        local root = getRoot(character)
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Monitoramento de persistência de spawn para o WalkFling
if characterAddedConnection then characterAddedConnection:Disconnect() end
characterAddedConnection = Player.CharacterAdded:Connect(function(newCharacter)
    if walkFlingEnabled then
        task.wait(0.5)
        if walkFlingEnabled then
            startWalkFlingLogic()
        end
    end
end)

-- Criando a UI com ResetOnSpawn = false para persistir após morte
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "SentinelHub"
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 180) -- Altura aumentada para caber 4 botões
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
        if key == "WalkFling" then
            walkFlingEnabled = not walkFlingEnabled
            Settings[key] = walkFlingEnabled
            btn.Text = text .. (walkFlingEnabled and ": ON" or ": OFF")
            
            if walkFlingEnabled then
                startWalkFlingLogic()
            else
                stopWalkFlingLogic()
            end
        else
            Settings[key] = not Settings[key]
            btn.Text = text .. (Settings[key] and ": ON" or ": OFF")
        end
    end)
end

createBtn("Anti-Levitacao", "AntiLevitacao")
createBtn("Ghost Jitter", "GhostJitter")
createBtn("Auto-Evasao", "AutoEvasao")
createBtn("Walk Fling", "WalkFling")

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
