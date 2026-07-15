local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- CONFIGURAÇÃO DA ESPADA ESPECÍFICA
local ESPADA_ID = 94794847
local GEAR_NAME = "Gear" .. tostring(ESPADA_ID)

-- INTERFACE E LAYOUT HORIZONTAL ORIGINAL
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) 
F.Size = UDim2.new(0, 650, 0, 450) 
F.Position = UDim2.new(0.5, -325, 0.5, -225) 
F.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
F.Active = true 
F.Draggable = true

-- Botão de Minimizar Superior (Esquerda)
local OC = Instance.new("TextButton", UI) 
OC.Size = UDim2.new(0, 120, 0, 40) 
OC.Position = UDim2.new(0, 10, 0, 10) 
OC.Text = "Menu (On/Off)"
OC.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
OC.TextColor3 = Color3.fromRGB(255, 255, 255)
OC.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

-- Containers Internos (Lista de Jogadores e Botões de Funções)
local L = Instance.new("ScrollingFrame", F) 
L.Size = UDim2.new(0.3, 0, 1, 0) 
L.Position = UDim2.new(0, 0, 0, 0) 
L.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local C = Instance.new("ScrollingFrame", F) 
C.Size = UDim2.new(0.7, 0, 1, 0) 
C.Position = UDim2.new(0.3, 0, 0, 0) 
C.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Criação dinâmica dos botões no painel
local function mkT(n, v)
    local b = Instance.new("TextButton", C) 
    b.Size = UDim2.new(0, 200, 0, 30)
    b.Text = n .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Position = UDim2.new(0, 10, 0, #C:GetChildren() * 35 - 35)
    b.MouseButton1Click:Connect(function() 
        _G[v] = not _G[v] 
        b.Text = n .. (_G[v] and ": ON" or ": OFF") 
        b.BackgroundColor3 = _G[v] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Estado Inicial das Variáveis
_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.rk = false, false, false, false, false, false, false, false, false, false
_G.targ = nil _G.ringParts = {} _G.lastDisarmTime = 0 _G.cooldownDuration = 3.5 _G.angle = 0

-- Inicialização dos Botões Originais
mkT("Anti-Bring", "ab") 
mkT("Anti-Fling", "af") 
mkT("Anti-Freeze", "afz") 
mkT("Anti-Jail", "aj") 
mkT("Anti-Void", "av")
mkT("LoopGoto", "lg") 
mkT("Goto", "go") 
mkT("Disarm (Auto-Q)", "ds") 
mkT("SuperRing", "sr") 
mkT("Reach", "rk")

-- LOOP 1: AUTO-EQUIP DA ESPADA SELECIONADA (Loop Independente)
task.spawn(function()
    while true do
        local char = LP.Character
        local bp = LP.Backpack
        
        if char and bp then
            local temNoChar = char:FindFirstChild(GEAR_NAME)
            local temNaMochila = bp:FindFirstChild(GEAR_NAME)
            
            -- Se não está em nenhum lugar, solicita ao servidor usando a sintaxe legítima
            if not temNoChar and not temNaMochila then
                RemotoMain:FireServer({["id"] = ESPADA_ID, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(0.3)
            end
            
            -- Se foi gerada na mochila, força a equipá-la na mão do personagem
            if temNaMochila and not temNoChar then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(temNaMochila)
                end
            end
        end
        task.wait(1.5) -- Frequência estável de monitoramento
    end
end)

-- LOOP 2: CONTROLE DE FÍSICA E COMBATE (Heartbeat)
RS.Heartbeat:Connect(function(dt)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart
    
    -- Mecanismo de Defesa (Physics Lock)
    if _G.ab or _G.af or _G.afz or _G.aj or _G.av then
        myHRP.Velocity = Vector3.new(0, 0, 0)
    end
    
    -- Validação do Alvo Selecionado
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        
        -- Movimentação (LoopGoto e Goto)
        if _G.lg then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
        if _G.go then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) _G.go = false end
        
        -- Ataque / Replicação do Poder (Tecla Q no Remote Interno)
        if _G.ds then
            local espada = LP.Character:FindFirstChild(GEAR_NAME)
            if espada then
                local remoteInterno = espada:FindFirstChild("Remote") or espada:FindFirstChild("Client")
                if remoteInterno and (tick() - _G.lastDisarmTime) >= _G.cooldownDuration then
                    remoteInterno:FireServer(Enum.KeyCode.Q)
                    _G.lastDisarmTime = tick()
                end
            end
        end
        
        -- Super Ring Dinâmico Giratório com Colisão Ativa
        if _G.sr then
            _G.angle = _G.angle + (dt * 6) -- Define a velocidade de rotação das peças
            for i = 1, 8 do
                if not _G.ringParts[i] or not _G.ringParts[i].Parent then
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(2.5, 6, 2.5)
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(150, 0, 0)
                    part.Anchored = true
                    part.CanCollide = true -- Mantém a colisão física ligada
                    part.Parent = workspace
                    _G.ringParts[i] = part
                end
                
                local rad = (i / 8) * math.pi * 2 + _G.angle
                -- Calcula a posição ao redor do alvo, fazendo os blocos colidirem e orbitarem ele
                _G.ringParts[i].CFrame = tHRP.CFrame * CFrame.new(math.cos(rad) * 5, 0, math.sin(rad) * 5)
            end
        else
            -- Remove as peças se a função for desligada
            for _, p in pairs(_G.ringParts) do if p.Parent then p:Destroy() end end 
            _G.ringParts = {}
        end
    end
end)

-- Sistema de Atualização da Lista de Jogadores
local function refresh() 
    L:ClearAllChildren() 
    for _, p in pairs(P:GetPlayers()) do 
        if p ~= LP then 
            local b = Instance.new("TextButton", L) 
            b.Size = UDim2.new(1, -10, 0, 40) 
            b.Text = p.Name 
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45) 
            b.MouseButton1Click:Connect(function() _G.targ = p end) 
        end 
    end 
end

P.PlayerAdded:Connect(refresh) 
P.PlayerRemoving:Connect(refresh) 
refresh()
