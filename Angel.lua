local P, RS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", UI); ToggleBtn.Size = UDim2.new(0, 50, 0, 50); ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25); ToggleBtn.Text = "MENU"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255); ToggleBtn.Draggable = true

local F = Instance.new("Frame", UI); F.Size = UDim2.new(0, 250, 0, 350); F.Position = UDim2.new(0.2, 0, 0.2, 0); F.BackgroundColor3 = Color3.fromRGB(20, 20, 20); F.Visible = false; F.Draggable = true
local L = Instance.new("ScrollingFrame", F); L.Size = UDim2.new(1, 0, 0.4, 0); L.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local C = Instance.new("ScrollingFrame", F); C.Size = UDim2.new(1, 0, 0.6, 0); C.Position = UDim2.new(0, 0, 0.4, 0); C.BackgroundColor3 = Color3.fromRGB(30, 30, 30); C.CanvasSize = UDim2.new(0,0, 4.0, 0)

ToggleBtn.MouseButton1Click:Connect(function() F.Visible = not F.Visible end)

local function mkT(n, v)
    local b = Instance.new("TextButton", C); b.Size = UDim2.new(1, -10, 0, 40); b.Text = n..": OFF"; b.Position = UDim2.new(0, 5, 0, #C:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() _G[v] = not _G[v]; b.Text = n..(_G[v] and ": ON" or ": OFF") end)
end

_G.ab, _G.af, _G.afz, _G.aj, _G.av, _G.lg, _G.go, _G.ds, _G.sr, _G.aeg, _G.esp = false, false, false, false, false, false, false, false, false, false, false
_G.targ = nil

mkT("Anti-Bring", "ab"); mkT("Anti-Fling", "af"); mkT("Anti-Freeze", "afz"); mkT("Anti-Jail", "aj"); mkT("Anti-Void", "av")
mkT("LoopGoto", "lg"); mkT("Goto", "go"); mkT("Disarm", "ds"); mkT("Cage-Trava", "sr"); mkT("Auto-Equip", "aeg"); mkT("ESP", "esp")

-- LÓGICA DE AUTO-EQUIP PERSISTENTE
local function handleAutoEquip()
    if _G.aeg and LP.Character then
        local tool = LP.Backpack:FindFirstChildOfClass("Tool")
        if tool and not LP.Character:FindFirstChildOfClass("Tool") then
            LP.Character.Humanoid:EquipTool(tool)
        end
    end
end

LP.CharacterAdded:Connect(function() task.wait(1) handleAutoEquip() end)

RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LP.Character.HumanoidRootPart
    
    handleAutoEquip() -- Mantém a checagem ativa mas não trava em loop de equip

    if _G.ds and _G.targ and _G.targ.Character then
        for _, item in pairs(_G.targ.Character:GetChildren()) do
            if item:IsA("Tool") then item.Parent = LP.Backpack end
        end
    end

    -- ESP SYSTEM
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local head = p.Character:FindFirstChild("Head")
            if _G.esp and head and not head:FindFirstChild("ESP_TAG") then
                local bill = Instance.new("BillboardGui", head); bill.Name = "ESP_TAG"; bill.Size = UDim2.new(0, 200, 0, 50); bill.AlwaysOnTop = true
                Instance.new("TextLabel", bill).Size = UDim2.new(1,0,1,0); Instance.new("Highlight", p.Character).Name = "ESP_HIGH"
            elseif not _G.esp then
                if head:FindFirstChild("ESP_TAG") then head.ESP_TAG:Destroy() end
                if p.Character:FindFirstChild("ESP_HIGH") then p.Character.ESP_HIGH:Destroy() end
            end
        end
    end

    -- Estabilização de Trava (Cage)
    if _G.targ and _G.targ.Character and _G.targ.Character:FindFirstChild("HumanoidRootPart") then
        local tHRP = _G.targ.Character.HumanoidRootPart
        if _G.lg then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
        if _G.go then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); _G.go = false end
        
        if _G.sr then
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 0)
            myHRP.Velocity = Vector3.zero; myHRP.RotVelocity = Vector3.zero
            if LP.Character.Humanoid then LP.Character.Humanoid.PlatformStand = true end 
        else
            if LP.Character.Humanoid then LP.Character.Humanoid.PlatformStand = false end
        end
    end
end)

local function refresh() L:ClearAllChildren() for _,p in pairs(P:GetPlayers()) do if p ~= LP then 
    local b = Instance.new("TextButton", L); b.Size = UDim2.new(1, -10, 0, 40); b.Text = p.Name; b.Position = UDim2.new(0, 5, 0, #L:GetChildren() * 45 - 45)
    b.MouseButton1Click:Connect(function() _G.targ = p end) 
end end end
P.PlayerAdded:Connect(refresh); P.PlayerRemoving:Connect(refresh); refresh()
