local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) F.Size, F.Position, F.BackgroundColor3, F.Active, F.Draggable = UDim2.new(0,220,0,500), UDim2.new(0.5,-110,0.5,-250), Color3.fromRGB(30,30,30), true, true
local OC = Instance.new("TextButton", UI) OC.Size, OC.Position, OC.Text = UDim2.new(0,100,0,40), UDim2.new(0,10,0,10), "Menu"
OC.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

_G.ab, _G.ak, _G.fr, _G.jl, _G.ds, _G.lg = false, false, false, false, false, false
_G.targ = nil

local function mkT(n, v)
    local b = Instance.new("TextButton", F) b.Size, b.Text = UDim2.new(1,-10,0,30), n..": OFF"
    b.Position = UDim2.new(0,5,0,#F:GetChildren()*35-35)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v] b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end
mkT("Anti-Bring", "ab") mkT("Anti-Knock", "ak") mkT("Freeze", "fr") mkT("Jail", "jl") mkT("Disarm", "ds") mkT("LoopGoto", "lg")

local L = Instance.new("ScrollingFrame", F) L.Size, L.Position, L.CanvasSize = UDim2.new(1,0,0,220), UDim2.new(0,0,0,210), UDim2.new(0,0,2,0)

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if _G.ab then for _,o in pairs(LP.Character:GetDescendants()) do if (o:IsA("Weld") or o:IsA("WeldConstraint")) and o.Name ~= "RootJoint" then o:Destroy() end end end
    
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local p = _G.targ.Character.HumanoidRootPart
        if _G.lg then LP.Character.HumanoidRootPart.CFrame = p.CFrame * CFrame.new(0,0,3) end
        if _G.fr then p.CFrame = p.CFrame end -- Força a posição (Anti-Freeze local)
        if _G.jl then 
            for _,v in pairs({Vector3.new(0,0,5), Vector3.new(0,0,-5), Vector3.new(5,0,0), Vector3.new(-5,0,0)}) do 
                local part = Instance.new("Part", workspace) part.Size = Vector3.new(1, 10, 10) part.Position = p.Position + v part.Anchored = true 
                game.Debris:AddItem(part, 0.1) -- Limpeza automática para performance
            end 
        end
    end

    for _,p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if _G.ak and dist < 2 then p.Character.HumanoidRootPart.Velocity = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Unit * 50 end
            if _G.ds and dist < 10 then for _,i in pairs(p.Character:GetChildren()) do if i:IsA("Tool") then i.Parent = LP.Backpack end end end
        end
    end
end)

local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then local b = Instance.new("TextButton", L) b.Size, b.Position, b.Text = UDim2.new(1,-10,0,40), UDim2.new(0,5,0,#L:GetChildren()*45), "Target: "..p.Name b.MouseButton1Click:Connect(function() _G.targ = p end) end end end
P.PlayerAdded:Connect(refresh) P.PlayerRemoving:Connect(refresh) refresh()
