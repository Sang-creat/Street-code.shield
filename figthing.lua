-- ========================================================
-- MOD MENU OTIMIZADO - Delta Executor (Performance Mode)
-- ========================================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Delta Mod Menu - Otimizado", HidePremium = false, SaveConfig = true, ConfigFolder = "DeltaModMenu"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Gerenciador de Loops para evitar sobrecarga de memória
local activeLoops = {}
local function stopAll()
    for _, conn in pairs(activeLoops) do if conn then conn:Disconnect() end end
    table.clear(activeLoops)
end

-- ========================================================
-- ABAS
-- ========================================================
local LocalTab = Window:MakeTab({Name = "Local Player", Icon = "rbxassetid://4483362458"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483363412"})

-- ========================================================
-- LOCAL PLAYER (Otimizado)
-- ========================================================
LocalTab:AddToggle({Name = "God Mode", Default = false, Callback = function(value)
    if value then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.MaxHealth = math.huge hum.Health = math.huge end
    end
end})

LocalTab:AddToggle({Name = "Anti-Fling / Void", Default = false, Callback = function(value)
    if value then
        activeLoops["Anti"] = RunService.Heartbeat:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                if hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 50, 0) end
            end
        end)
    else stopAll() end
end})

-- ========================================================
-- COMBAT (Otimizado com task.wait e Heartbeat)
-- ========================================================
CombatTab:AddToggle({Name = "Kill Aura", Default = false, Callback = function(value)
    if value then
        activeLoops["Aura"] = RunService.Heartbeat:Connect(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 15 then
                        -- Aqui entra a lógica de dano compatível com o jogo
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        if hum then hum:TakeDamage(1) end 
                    end
                end
            end
        end)
    else stopAll() end
end})

OrionLib:Init()
