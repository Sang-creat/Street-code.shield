local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- CONFIGURAÇÃO DO GEAR
local GEAR_ID = "94794847" 
local GEAR_NAME = "Gear" .. GEAR_ID

-- INTERFACE
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) F.Size, F.Position, F.BackgroundColor3 = UDim2.new(0,650,0,450), UDim2.new(0.5,-325,0.5,-225), Color3.fromRGB(25,25,25)
F.Active, F.Draggable = true, true
local OC = Instance.new("TextButton", UI) OC.Size, OC.Position, OC.Text = UDim2.new(0,100,0,40), UDim2.new(0,10,0,10), "Menu"
OC.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

-- VARIÁVEIS DE CONTROLE
_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.rk = false, false, false, false, false, false, false, false, false, false
_G.targ = nil _G.ringParts = {} _G.lastDisarmTime = 0 _G.cooldownDuration = 3.5 _G.lastCheckTime = 0

local L = Instance.new("ScrollingFrame", F) L.Size, L.Position, L.BackgroundColor3 = UDim2.new(0.3,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(40,40,40)
local C = Instance.new("ScrollingFrame", F) C.Size, C.Position, C.BackgroundColor3 = UDim2.new(0.7,0,1,0), UDim2.new(0.3,0,0,0), Color3.fromRGB(30,30,30)

local function mkT(n, v)
    local b = Instance.new("TextButton", C) b.Size, b.Text = UDim2.new(0,200,0,30), n..": OFF"
    b.Position = UDim2.new(0,10,0,#C:GetChildren()*35-35)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v] b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end

mkT("Anti-Bring", "ab") mkT("Anti-Fling", "af") mkT("Anti-Freeze", "afz") mkT("Anti-Jail", "aj") mkT("Anti-Void", "av")
mkT("LoopGoto", "lg") mkT("Goto", "go") mkT("Disarm (Auto-Equip)", "ds") mkT("SuperRing", "sr") mkT("Reach", "rk")

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    
    -- 1. AUTO-EQUIP (Verificação a cada 2 segundos)
    if (tick() - _G.lastCheckTime) >= 2 then
        if not LP.Character:FindFirstChild(GEAR_NAME) then
            local tool = LP.Backpack:FindFirstChild(GEAR_NAME)
            if tool then LP.Character.Humanoid:EquipTool(tool) end
        end
        _G.lastCheckTime = tick()
    end
    
    -- 2. DEFESAS
    if _G.ab or _G.af or _G.afz or _G.aj or _G.av then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
    end
    
    -- 3. AÇÕES OFENSIVAS
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tP = _G.targ.Character.HumanoidRootPart
        
        if _G.lg then LP.Character.HumanoidRootPart.CFrame = tP.CFrame * CFrame.new(0,0,3) end
        if _G.go then LP.Character.HumanoidRootPart.CFrame = tP.CFrame * CFrame.new(0,0,3) _G.go = false end
        
        -- DISARM (Usa o cooldown e o Remote capturado)
        if _G.ds then 
            local gear = LP.Character:FindFirstChild(GEAR_NAME)
            local remote = gear and (gear:FindFirstChild("Remote") or gear:FindFirstChild("Client"))
            if remote and (tick() - _G.lastDisarmTime) >= _G.cooldownDuration then
                remote:FireServer(Enum.KeyCode.Q)
                _G.lastDisarmTime = tick()
            end
        end
        
        -- SUPER RING
        if _G.sr then 
            for i = 1, 8 do
                if not _G.ringParts[i] or not _G.ringParts[i].Parent then
                    _G.ringParts[i] = Instance.new("Part", workspace)
                    _G.ringParts[i].Size, _G.ringParts[i].Anchored, _G.ringParts[i].CanCollide = Vector3.new(2,5,2), true, true
                end
                local angle = (i / 8) * math.pi * 2
                _G.ringParts[i].CFrame = tP.CFrame + Vector3.new(math.cos(angle)*5, 0, math.sin(angle)*5)
            end
        else
            for _, p in pairs(_G.ringParts) do p:Destroy() end _G.ringParts = {}
        end
    end
end)

local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then 
    local b = Instance.new("TextButton", L) b.Size, b.Text = UDim2.new(1,-10,0,40), p.Name 
    b.Position = UDim2.new(0,5,0,#L:GetChildren()*45-45) b.MouseButton1Click:Connect(function() _G.targ = p end) 
end end end
P.PlayerAdded:Connect(refresh) P.PlayerRemoving:Connect(refresh) refresh()
