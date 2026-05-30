local P,R,L = game:GetService("Players"),game:GetService("RunService"),game:GetService("Players").LocalPlayer
local S = Instance.new("ScreenGui", L:WaitForChild("PlayerGui",10)) S.Name = "SV9_L" S.ResetOnSpawn = false
local M = Instance.new("Frame", S) M.Size, M.Position, M.BackgroundColor3, M.Active, M.Draggable = UDim2.new(0,200,0,240), UDim2.new(0.5,-100,0.2,0), Color3.fromRGB(15,15,15), true, true
local act, bData, lastPos = {false,false,false,false}, {{"GOD/ANTI-KICK",Color3.fromRGB(120,0,0),Color3.fromRGB(0,150,0)},{"ANTI-LAG & TAKE",Color3.fromRGB(0,120,120),Color3.fromRGB(0,200,200)},{"NO-RESTRICT",Color3.fromRGB(120,120,0),Color3.fromRGB(0,150,0)},{"ANTI-DMG",Color3.fromRGB(80,0,120),Color3.fromRGB(0,150,0)}}, nil
local btns = {}

for i, d in ipairs(bData) do
    local b = Instance.new("TextButton", M) b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3 = UDim2.new(0.9,0,0.16,0), UDim2.new(0.05,0,0.15+(i-1)*0.2,0), d[2], d[1]..": OFF", Color3.fromRGB(255,255,255)
    b.MouseButton1Click:Connect(function()
        act[i] = not act[i]
        b.BackgroundColor3 = act[i] and d[3] or d[2]
        b.Text = d[1].. (act[i] and ": ON" or ": OFF")
        if i == 2 and act[2] and L.Character and L.Character:FindFirstChild("HumanoidRootPart") then lastPos = L.Character.HumanoidRootPart.Position end
    end)
end

local mt = getrawmetatable(game) local old = mt.__namecall setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if act[1] and (getnamecallmethod() == "Kick" or (getnamecallmethod() == "FireServer" and tostring(self):lower():find("damage"))) then return nil end
    return old(self, ...)
end) setreadonly(mt, true)

R.Stepped:Connect(function()
    local c = L.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") if not c or not r then return end
    if act[1] and h then if h.Health <= 0 then h.Health = 0.1 end h:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end
    if act[3] and h then h.WalkSpeed, h.JumpPower, h.PlatformStand = 16, 50, false end
    if act[2] then r.Velocity, r.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0) if lastPos and (r.Position - lastPos).Magnitude > 10 then r.CFrame = CFrame.new(lastPos) end lastPos = r.Position end
    if act[4] then for _, p in pairs(c:GetChildren()) do if p:IsA("BasePart") and p.CanTouch then p.CanTouch = false end end end
end)
