local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")
local GEAR_NAME = "Gear94794847"

-- UI E INTERFACE
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) 
F.Size = UDim2.new(0, 300, 0, 400); F.Position = UDim2.new(0.5, -150, 0.5, -200)
F.BackgroundColor3 = Color3.fromRGB(25, 25, 25); F.Active = true; F.Draggable = true

local L = Instance.new("ScrollingFrame", F) 
L.Size = UDim2.new(1, 0, 0.4, 0); L.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local C = Instance.new("ScrollingFrame", F) 
C.Size = UDim2.new(1, 0, 0.6, 0); C.Position = UDim2.new(0, 0, 0.4, 0); C.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function mkT(n, v)
    local b = Instance.new("TextButton", C)
    b.Size = UDim2.new(1, -10, 0, 40); b.Text = n..": OFF"
    b.Position = UDim2.new(0, 5, 0, #C:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() 
        _G[v] = not _G[v]
        b.Text = n..(_G[v] and ": ON" or ": OFF") 
    end)
end

-- CONTROLES GLOBAIS
_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.rk, _G.aeg = false, false, false, false, false, false, false, false, false, false, false
_G.targ = nil

mkT("Anti-Bring", "ab"); mkT("Anti-Fling", "af"); mkT("Anti-Freeze", "afz")
mkT("Anti-Jail", "aj"); mkT("Anti-Void", "av"); mkT("LoopGoto", "lg")
mkT("Goto", "go"); mkT("Disarm", "ds"); mkT("Cage-Trava", "sr")
mkT("Box-Reach", "rk"); mkT("Auto-Equip", "aeg")

-- LOOP PRINCIPAL
RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart

    -- Anti-Fling Pro
    if _G.af then 
        myHRP.RotVelocity = Vector3.zero
        myHRP.Velocity = Vector3.zero 
    end

    -- Proteções de Movimento
    if _G.ab or _G.afz or _G.aj or _G.av then 
        myHRP.Velocity = Vector3.zero 
    end

    -- Cage Trava (Corrigido)
    if _G.sr and _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        -- Força a colisão para prender o alvo
        for _, p in pairs(LP.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = true end 
        end
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1)
    else
        -- Reseta colisão ao desativar para não ficar travado andando
        for _, p in pairs(LP.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end
end)

-- LISTA DE PLAYERS
local function refresh()
    L:ClearAllChildren()
    for _,p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = Instance.new("TextButton", L)
            b.Size = UDim2.new(1, -10, 0, 40); b.Text = "Alvo: "..p.Name
            b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45)
            b.MouseButton1Click:Connect(function() _G.targ = p end)
        end 
    end
end
P.PlayerAdded:Connect(refresh); P.PlayerRemoving:Connect(refresh); refresh()
