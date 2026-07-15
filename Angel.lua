local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local Remoto = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AvatarMainRE")
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI) F.Size, F.Position, F.BackgroundColor3 = UDim2.new(0,500,0,300), UDim2.new(0.5,-250,0.5,-150), Color3.fromRGB(30,30,30)
F.Active, F.Draggable = true, true
local OC = Instance.new("TextButton", UI) OC.Size, OC.Position, OC.Text = UDim2.new(0,100,0,40), UDim2.new(0,10,0,10), "Menu"
OC.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

_G.ak, _G.ds, _G.lg, _G.inv = false, false, false, false
_G.targ = nil

local L = Instance.new("ScrollingFrame", F) L.Size, L.Position, L.BackgroundColor3 = UDim2.new(0.5,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(40,40,40)
local C = Instance.new("ScrollingFrame", F) C.Size, C.Position, C.BackgroundColor3 = UDim2.new(0.5,0,1,0), UDim2.new(0.5,0,0,0), Color3.fromRGB(30,30,30)

local function mkT(n, v)
    local b = Instance.new("TextButton", C) b.Size, b.Text = UDim2.new(1,-10,0,30), n..": OFF"
    b.Position = UDim2.new(0,5,0,#C:GetChildren()*35-35)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v] b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end
mkT("Anti-Knock", "ak") mkT("Disarm (Remote)", "ds") mkT("LoopGoto", "lg") mkT("Invisible", "inv")

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    
    -- Invisibilidade (Local)
    if _G.inv then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 1 end if v:IsA("Accessory") then v:Destroy() end end end
    
    -- Disarm via Remote
    if _G.ds and _G.targ then
        Remoto:FireServer({["event"] = "unequip", ["equiptype"] = "Gear"})
    end
    
    -- LoopGoto
    if _G.lg and _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = _G.targ.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
    end
end)

local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then local b = Instance.new("TextButton", L) b.Size, b.Text = UDim2.new(1,-10,0,40), "Target: "..p.Name b.Position = UDim2.new(0,5,0,#L:GetChildren()*45-45) b.MouseButton1Click:Connect(function() _G.targ = p end) end end end
P.PlayerAdded:Connect(refresh) P.PlayerRemoving:Connect(refresh) refresh()
