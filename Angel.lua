local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")
local ESPADA_ID = 94794847
local GEAR_NAME = "Gear" .. tostring(ESPADA_ID)

-- UI E INTERFACE MOBILE
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", UI); ToggleBtn.Size = UDim2.new(0, 50, 0, 50); ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25); ToggleBtn.Text = "MENU"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255); ToggleBtn.Draggable = true

local F = Instance.new("Frame", UI); F.Size = UDim2.new(0, 250, 0, 350); F.Position = UDim2.new(0.2, 0, 0.2, 0); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); F.Visible = false; F.Draggable = true
local L = Instance.new("ScrollingFrame", F); L.Size = UDim2.new(1, 0, 0.4, 0); L.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local C = Instance.new("ScrollingFrame", F); C.Size = UDim2.new(1, 0, 0.6, 0); C.Position = UDim2.new(0, 0, 0.4, 0); C.BackgroundColor3 = Color3.fromRGB(30, 30, 30); C.CanvasSize = UDim2.new(0,0, 3.5, 0)

ToggleBtn.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

local function mkT(n, v)
    local b = Instance.new("TextButton", C); b.Size = UDim2.new(1, -10, 0, 40); b.Text = n..": OFF"; b.Position = UDim2.new(0, 5, 0, #C:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v]; b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end

-- CONTROLES GLOBAIS
_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.rk, _G.aeg = false, false, false, false, false, false, false, false, false, false, false
_G.targ, _G.lastDisarmTime, _G.cooldownDuration, _G.reachValue, _G.boxReachPart = nil, 0, 3.5, 20, nil

mkT("Anti-Bring", "ab"); mkT("Anti-Fling", "af"); mkT("Anti-Freeze", "afz"); mkT("Anti-Jail", "aj"); mkT("Anti-Void", "av")
mkT("LoopGoto", "lg"); mkT("Goto", "go"); mkT("Disarm", "ds"); mkT("Cage-Trava", "sr"); mkT("Box-Reach", "rk"); mkT("Auto-Equip", "aeg")

-- AUTO-EQUIP LOOP
task.spawn(function()
    while task.wait(2) do
        local char, bp = LP.Character, LP.Backpack
        if char and bp then
            local gearInBp = bp:FindFirstChild(GEAR_NAME)
            local gearInChar = char:FindFirstChild(GEAR_NAME)
            if not gearInBp and not gearInChar then RemotoMain:FireServer({["id"] = ESPADA_ID, ["event"] = "equip", ["equiptype"] = "Gear"})
            elseif _G.aeg and gearInBp then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum:EquipTool(gearInBp) end end
        end
    end
end)

-- LOOP PRINCIPAL
RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart

    -- Anti-Fling & Defesas
    if _G.af then myHRP.RotVelocity = Vector3.zero; myHRP.Velocity = Vector3.zero end
    if _G.ab or _G.afz or _G.aj or _G.av then myHRP.Velocity = Vector3.zero end

    -- BOX REACH
    if _G.rk then
        if not _G.boxReachPart then _G.boxReachPart = Instance.new("Part", workspace); _G.boxReachPart.Anchored = true; _G.boxReachPart.CanCollide = false; _G.boxReachPart.Transparency = 0.8 end
        _G.boxReachPart.Size = Vector3.new(_G.reachValue, 5, _G.reachValue); _G.boxReachPart.CFrame = myHRP.CFrame * CFrame.new(0, 0, -(_G.reachValue/2))
    elseif _G.boxReachPart then _G.boxReachPart:Destroy(); _G.boxReachPart = nil end

    -- ALVO E TRAVA
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        if _G.lg then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
        if _G.go then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); _G.go = false end
        
        if _G.ds then
            local espada = LP.Character:FindFirstChild(GEAR_NAME)
            local remote = espada and (espada:FindFirstChild("Remote") or espada:FindFirstChild("Client"))
            if remote and (tick() - _G.lastDisarmTime) >= _G.cooldownDuration then remote:FireServer(Enum.KeyCode.Q); _G.lastDisarmTime = tick() end
        end
        
        if _G.sr then
            for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1)
        else
            for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end
end)

-- LISTA DE PLAYERS
local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then 
    local b = Instance.new("TextButton", L); b.Size = UDim2.new(1, -10, 0, 40); b.Text = p.Name; b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() _G.targ = p end) 
end end end
P.PlayerAdded:Connect(refresh); P.PlayerRemoving:Connect(refresh); refresh()
