local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local RemotoMain = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

local ESPADA_ID = 94794847
local GEAR_NAME = "Gear" .. tostring(ESPADA_ID)

local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) 
F.Size, F.Position = UDim2.new(0, 650, 0, 450), UDim2.new(0.5, -325, 0.5, -225) 
F.BackgroundColor3, F.Active, F.Draggable = Color3.fromRGB(25, 25, 25), true, true

local OC = Instance.new("TextButton", UI) 
OC.Size, OC.Position = UDim2.new(0, 120, 0, 40), UDim2.new(0, 10, 0, 10) 
OC.Text, OC.BackgroundColor3 = "Menu (On/Off)", Color3.fromRGB(45, 45, 45)
OC.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

local L = Instance.new("ScrollingFrame", F) L.Size, L.Position, L.BackgroundColor3 = UDim2.new(0.3, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(40, 40, 40)
local C = Instance.new("ScrollingFrame", F) C.Size, C.Position, C.BackgroundColor3 = UDim2.new(0.7, 0, 1, 0), UDim2.new(0.3, 0, 0, 0), Color3.fromRGB(30, 30, 30)

local function mkT(n, v)
    local b = Instance.new("TextButton", C) b.Size, b.Text = UDim2.new(0, 200, 0, 30), n..": OFF"
    b.Position = UDim2.new(0, 10, 0, #C:GetChildren() * 35 - 35)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v] b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end

_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.rk, _G.aeg = false, false, false, false, false, false, false, false, false, false, false
_G.targ, _G.ringParts, _G.lastDisarmTime, _G.cooldownDuration, _G.angle = nil, {}, 0, 3.5, 0

mkT("Anti-Bring", "ab"); mkT("Anti-Fling", "af"); mkT("Anti-Freeze", "afz"); mkT("Anti-Jail", "aj"); mkT("Anti-Void", "av")
mkT("LoopGoto", "lg"); mkT("Goto", "go"); mkT("Disarm (Auto-Q)", "ds"); mkT("SuperRing", "sr"); mkT("Reach", "rk"); mkT("Auto-Equip Gear", "aeg")

task.spawn(function()
    while task.wait(2) do
        local char, bp = LP.Character, LP.Backpack
        if char and bp then
            local gearInBp = bp:FindFirstChild(GEAR_NAME)
            local gearInChar = char:FindFirstChild(GEAR_NAME)
            if not gearInBp and not gearInChar then
                RemotoMain:FireServer({["id"] = ESPADA_ID, ["event"] = "equip", ["equiptype"] = "Gear"})
            elseif _G.aeg and gearInBp then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(gearInBp) end
            end
        end
    end
end)

RS.Heartbeat:Connect(function(dt)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    if _G.ab or _G.af or _G.afz or _G.aj or _G.av then LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end
    
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        if _G.lg then LP.Character.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
        if _G.go then LP.Character.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) _G.go = false end
        
        if _G.ds then
            local espada = LP.Character:FindFirstChild(GEAR_NAME)
            local remote = espada and (espada:FindFirstChild("Remote") or espada:FindFirstChild("Client"))
            if remote and (tick() - _G.lastDisarmTime) >= _G.cooldownDuration then
                remote:FireServer(Enum.KeyCode.Q)
                _G.lastDisarmTime = tick()
            end
        end
        
        if _G.sr then
            _G.angle = _G.angle + (dt * 15)
            for i = 1, 8 do
                if not _G.ringParts[i] or not _G.ringParts[i].Parent then
                    local p = Instance.new("Part")
                    p.Size, p.Anchored, p.CanCollide, p.Material, p.Parent = Vector3.new(1.5, 5, 1.5), true, true, Enum.Material.Neon, workspace
                    _G.ringParts[i] = p
                end
                local rad = (i / 8) * math.pi * 2 + _G.angle
                _G.ringParts[i].CFrame = tHRP.CFrame * CFrame.new(math.cos(rad) * 1.5, 0, math.sin(rad) * 1.5)
            end
        else
            for _, p in pairs(_G.ringParts) do if p.Parent then p:Destroy() end end _G.ringParts = {}
        end
    end
end)

local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then 
    local b = Instance.new("TextButton", L) b.Size, b.Text = UDim2.new(1, -10, 0, 40), p.Name 
    b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45) b.MouseButton1Click:Connect(function() _G.targ = p end) 
end end end
P.PlayerAdded:Connect(refresh); P.PlayerRemoving:Connect(refresh); refresh()
