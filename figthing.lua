-- Script Mobile: Network Ownership Manipulator (Código de Rua)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Função para requisitar Network Ownership
local function requestOwnership(part)
    if part and part:IsA("BasePart") then
        -- Tenta forçar o network ownership para o jogador local
        -- Nota: Isso só funciona se o objeto for propriedade do servidor mas tiver física dinãmica
        pcall(function()
            settings().Physics.AllowSleep = false
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
        end)
    end
end

-- ========================================================
-- MOD MENU UI (Versão Mobile - Draggable)
-- ========================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "Network Mobile Mod", HidePremium = false, SaveConfig = true, ConfigFolder = "DeltaMobile"})

local CombatTab = Window:MakeTab({Name = "Physics Combat", Icon = "rbxassetid://4483363412"})

-- Função para "Travar" ou "Levitar" jogador (via Network)
CombatTab:AddTextbox({
    Name = "Target Username",
    Default = "",
    Callback = function(Value)
        local target = Players:FindFirstChild(Value)
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                requestOwnership(hrp)
                hrp.Velocity = Vector3.new(0, 50, 0) -- Força para cima
            end
        end
    end
})

-- Voo Estilo Super-Herói
local flying = false
CombatTab:AddToggle({Name = "Hero Flight (Vel: 50)", Callback = function(v)
    flying = v
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if flying and hrp then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        bv.Velocity = hrp.CFrame.lookVector * 50
        spawn(function()
            while flying do task.wait() bv.Velocity = hrp.CFrame.lookVector * 50 end
            bv:Destroy()
        end)
    end
end})

OrionLib:Init()
