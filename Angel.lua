local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))

-- Botão de Abrir/Fechar Flutuante
local ToggleBtn = Instance.new("TextButton", UI)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.Text = "MENU"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
ToggleBtn.Draggable = true

-- Janela Principal Arrastável
local F = Instance.new("Frame", UI)
F.Size = UDim2.new(0, 250, 0, 300)
F.Position = UDim2.new(0.2, 0, 0.2, 0)
F.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
F.Visible = false
F.Draggable = true

local L = Instance.new("ScrollingFrame", F)
L.Size = UDim2.new(1, 0, 0.4, 0)
L.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local C = Instance.new("ScrollingFrame", F)
C.Size = UDim2.new(1, 0, 0.6, 0)
C.Position = UDim2.new(0, 0, 0.4, 0)
C.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
C.CanvasSize = UDim2.new(0, 0, 2.5, 0)

ToggleBtn.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

local function mkT(n, v)
    local b = Instance.new("TextButton", C)
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Text = n..": OFF"
    b.Position = UDim2.new(0, 5, 0, #C:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() 
        _G[v] = not _G[v]
        b.Text = n..(_G[v] and ": ON" or ": OFF") 
    end)
end

-- Variáveis Globais
_G.af, _G.sr, _G.rk, _G.aeg = false, false, false, false
_G.targ = nil

mkT("Anti-Fling", "af"); mkT("Cage-Trava", "sr")
mkT("Box-Reach", "rk"); mkT("Auto-Equip", "aeg")

-- Loop de Proteção e Ataque
RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart

    -- Anti-Fling Pro
    if _G.af then 
        myHRP.RotVelocity = Vector3.zero
        myHRP.Velocity = Vector3.zero 
    end

    -- Cage Trava (Body-Trap com Reset de Colisão)
    if _G.sr and _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        for _, p in pairs(LP.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = true end 
        end
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1)
    else
        for _, p in pairs(LP.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end
end)

-- Sistema de seleção de alvos
local function refresh()
    L:ClearAllChildren()
    for _,p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = Instance.new("TextButton", L)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.Text = p.Name
            b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45)
            b.MouseButton1Click:Connect(function() _G.targ = p end)
        end 
    end
end
P.PlayerAdded:Connect(refresh); P.PlayerRemoving:Connect(refresh); refresh()
