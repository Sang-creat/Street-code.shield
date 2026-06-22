-- ========================================================
-- MOD MENU INTEGRADO E SEGURO (Delta Optimized)
-- ========================================================

local function initializeModMenu()
    -- Tenta carregar a biblioteca Orion com tratamento de erro
    local OrionLib
    local success, err = pcall(function()
        OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    end)

    if not success then
        warn("Erro ao carregar a biblioteca Orion: " .. tostring(err))
        return
    end

    local Window = OrionLib:MakeWindow({Name = "Delta Mod Menu - Seguro", HidePremium = false, SaveConfig = true, ConfigFolder = "DeltaModMenu"})

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
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
    -- FUNÇÕES
    -- ========================================================
    LocalTab:AddToggle({Name = "God Mode", Default = false, Callback = function(value)
        if value then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.MaxHealth = math.huge hum.Health = math.huge end
        end
    end})

    CombatTab:AddToggle({Name = "Kill Aura", Default = false, Callback = function(value)
        if value then
            activeLoops["Aura"] = RunService.Heartbeat:Connect(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 15 then
                            local hum = plr.Character:FindFirstChild("Humanoid")
                            if hum then hum:TakeDamage(1) end 
                        end
                    end
                end
            end)
        else stopAll() end
    end})

    OrionLib:Init()
end

-- Inicia o processo
initializeModMenu()
