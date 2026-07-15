local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) 
F.Size, F.Position, F.BackgroundColor3, F.Active, F.Draggable = UDim2.new(0,220,0,400), UDim2.new(0.5,-110,0.5,-200), Color3.fromRGB(30,30,30), true, true

-- Toggle de visibilidade
local OpenClose = Instance.new("TextButton", UI)
OpenClose.Size, OpenClose.Position, OpenClose.Text = UDim2.new(0, 100, 0, 40), UDim2.new(0, 10, 0, 10), "Menu ON/OFF"
OpenClose.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

-- Variáveis de Estado
local antiBring, antiKnock = false, false

-- Criação de botões de controle
local function createToggle(name, stateVar)
    local btn = Instance.new("TextButton", F)
    btn.Size, btn.Text = UDim2.new(1, -10, 0, 40), name .. ": OFF"
    btn.Position = UDim2.new(0, 5, 0, #F:GetChildren() * 45)
    btn.MouseButton1Click:Connect(function()
        _G[stateVar] = not _G[stateVar]
        btn.Text = name .. (_G[stateVar] and ": ON" or ": OFF")
    end)
    return btn
end

_G.antiBring, _G.antiKnock = false, false
createToggle("Anti-Bring", "antiBring")
createToggle("Anti-Knock", "antiKnock")

-- Lista de Jogadores
local L = Instance.new("ScrollingFrame", F) 
L.Size, L.Position, L.BackgroundColor3, L.CanvasSize = UDim2.new(1,0,0,150), UDim2.new(0,0,0,150), Color3.fromRGB(40,40,40), UDim2.new(0,0,2,0)

local function tp(t)
    local r = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    if LP.Character and r then LP.Character.HumanoidRootPart.CFrame = r.CFrame * CFrame.new(0,0,3) end
end

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    -- Lógica Anti-Bring
    if _G.antiBring then
        for _, o in pairs(LP.Character:GetDescendants()) do
            if (o:IsA("Weld") or o:IsA("WeldConstraint")) and o.Name ~= "RootJoint" then o:Destroy() end
        end
    end
    -- Lógica Anti-Empurrão
    if _G.antiKnock then
        for _, p in pairs(P:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < 2 then p.Character.HumanoidRootPart.Velocity = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Unit * 50 end
            end
        end
    end
end)

local function refresh()
    L:ClearAllChildren()
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP then
            local b = Instance.new("TextButton", L)
            b.Size, b.Position, b.Text = UDim2.new(1,-10,0,40), UDim2.new(0,5,0,#L:GetChildren()*45), "TP: "..p.Name
            b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(60,60,60), Color3.new(1,1,1)
            b.MouseButton1Click:Connect(function() tp(p) end)
        end
    end
end

P.PlayerAdded:Connect(refresh) 
P.PlayerRemoving:Connect(refresh) 
refresh()
