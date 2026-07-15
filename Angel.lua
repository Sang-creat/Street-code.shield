local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")
local GEAR_NAME = "Gear94794847"

-- UI Principal
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) F.Size = UDim2.new(0, 250, 0, 350); F.Position = UDim2.new(0.1, 0, 0.2, 0); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); F.Draggable = true
local C = Instance.new("ScrollingFrame", F) C.Size = UDim2.new(1, 0, 1, 0); C.CanvasSize = UDim2.new(0, 0, 2, 0)

local function mkT(n, v)
    local b = Instance.new("TextButton", C) b.Size = UDim2.new(1, -20, 0, 40); b.Text = n..": OFF"
    b.Position = UDim2.new(0, 10, 0, #C:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v]; b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end

-- Variáveis e Toggles
_G.af, _G.sr, _G.rk, _G.aeg = false, false, false, false
_G.targ, _G.reachValue = nil, 20

mkT("Anti-Fling Pro", "af"); mkT("Cage-Trava", "sr"); mkT("Box-Reach", "rk"); mkT("Auto-Equip", "aeg")

-- Loop de Proteção e Ataque
RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart

    -- Anti-Fling Pro: Nulifica forças externas
    if _G.af then
        myHRP.RotVelocity = Vector3.zero
        myHRP.Velocity = Vector3.zero
    end

    -- Body-Trap (Cage-Trava)
    if _G.sr and _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        -- Força a colisão para que ele bata em você
        for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1)
    end
end)

-- Sistema de seleção simples
local function refresh() for _,p in pairs(P:GetPlayers()) do if p ~= LP then 
    local b = Instance.new("TextButton", C) b.Text = "Alvo: "..p.Name; b.Size = UDim2.new(1, -20, 0, 30)
    b.MouseButton1Click:Connect(function() _G.targ = p end) 
end end end
refresh()
