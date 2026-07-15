local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- CONFIGURAÇÃO DE GEARS (Adicione seus IDs aqui)
local Gears = {268586231, 127506257, 70476425}

-- UI MINIMIZÁVEL
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) F.Size, F.Position = UDim2.new(0, 300, 0, 300), UDim2.new(0.5, -150, 0.5, -150)
F.BackgroundColor3, F.Active, F.Draggable = Color3.fromRGB(20, 20, 20), true, true
local ToggleBtn = Instance.new("TextButton", UI) ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 100, 0, 30), UDim2.new(0, 10, 0, 10)
ToggleBtn.Text = "Minimizar/Abrir"
ToggleBtn.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

-- VARIÁVEIS DE CONTROLE
_G.targ = nil _G.ringParts = {} _G.angle = 0
_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.ds, _G.sr = false, false, false, false, false, false, false, false

-- AUTO-EQUIP LOOPER (Integrado)
task.spawn(function()
    while task.wait(2) do
        for _, id in pairs(Gears) do
            local name = "Gear"..id
            if not LP.Backpack:FindFirstChild(name) and not LP.Character:FindFirstChild(name) then
                RemotoMain:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(0.2)
            end
        end
    end
end)

-- LOOP PRINCIPAL
RS.Heartbeat:Connect(function(dt)
    if not LP.Character then return end
    
    -- Defesas
    if _G.ab or _G.af or _G.afz or _G.aj or _G.av then LP.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end
    
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tP = _G.targ.Character.HumanoidRootPart
        
        -- LoopGoto
        if _G.lg then LP.Character.HumanoidRootPart.CFrame = tP.CFrame * CFrame.new(0,0,3) end
        
        -- Super Ring Giratório
        if _G.sr then
            _G.angle = _G.angle + (dt * 5) -- Velocidade do giro
            for i = 1, 8 do
                if not _G.ringParts[i] or not _G.ringParts[i].Parent then
                    _G.ringParts[i] = Instance.new("Part", workspace)
                    _G.ringParts[i].Size, _G.ringParts[i].Anchored, _G.ringParts[i].CanCollide = Vector3.new(2,5,2), true, true
                end
                local rad = (i / 8) * math.pi * 2 + _G.angle
                _G.ringParts[i].CFrame = tP.CFrame * CFrame.new(math.cos(rad) * 6, 0, math.sin(rad) * 6)
            end
        else
            for _, p in pairs(_G.ringParts) do p:Destroy() end _G.ringParts = {}
        end
        
        -- Disarm (Simples: se ligado, tenta disparar o Q no gear equipado)
        if _G.ds then
            local currentGear = LP.Character:FindFirstChildOfClass("Tool")
            if currentGear and currentGear:FindFirstChild("Remote") then
                currentGear.Remote:FireServer(Enum.KeyCode.Q)
            end
        end
    end
end)
