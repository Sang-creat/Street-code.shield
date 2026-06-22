-- =============================================
-- MOD MENU PARA ROBLOX - Delta Executor Optimized
-- Desenvolvido por Grok (especialista Lua Roblox)
-- Usa Orion Library (leve e estável)
-- =============================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Delta Mod Menu - Grok Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DeltaModMenu",
    IntroEnabled = true,
    IntroText = "Carregando Mod Menu..."
})

-- Variáveis Globais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local connections = {}
local loops = {}

-- Função auxiliar para limpar conexões
local function cleanup()
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, loop in pairs(loops) do
        pcall(function() loop:Disconnect() end)
    end
    table.clear(connections)
    table.clear(loops)
end

-- =============================================
-- TAB: LOCAL PLAYER
-- =============================================
local LocalTab = Window:MakeTab({
    Name = "Local Player",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- God Mode
local godModeEnabled = false
LocalTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(value)
        godModeEnabled = value
        if value then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
            table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(char)
                if godModeEnabled then
                    local hum = char:WaitForChild("Humanoid")
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end
            end))
        end
    end
})

-- Anti-Fling / Anti-Void / Anti-Jail / Anti-Freeze
LocalTab:AddToggle({
    Name = "Anti Fling + Anti Void",
    Default = false,
    Callback = function(value)
        if value then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0,0,0)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
            local antiConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Anti Fling
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    
                    -- Anti Void
                    if hrp.Position.Y < -100 then
                        hrp.CFrame = CFrame.new(0, 100, 0)
                    end
                end
            end)
            table.insert(loops, antiConn)
        else
            cleanup()
        end
    end
})

LocalTab:AddToggle({
    Name = "Anti Freeze / Anti Jail",
    Default = false,
    Callback = function(value)
        if value then
            local antiFreeze = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        hum.Sit = false
                    end
                    -- Remove possíveis jails/barreiras próximas
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:IsA("Part") and (obj.Name:lower():find("jail") or obj.Name:lower():find("barrier")) then
                            if (obj.Position - char.PrimaryPart.Position).Magnitude < 50 then
                                pcall(function() obj:Destroy() end)
                            end
                        end
                    end
                end
            end)
            table.insert(loops, antiFreeze)
        end
    end
})

-- =============================================
-- TAB: COMBAT
-- =============================================
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483363412",
    PremiumOnly = false
})

-- Kill Aura
local killAuraEnabled = false
local killAuraRange = 20
CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(value)
        killAuraEnabled = value
        if value then
            local auraLoop = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = plr.Character.HumanoidRootPart
                        if (targetRoot.Position - root.Position).Magnitude <= killAuraRange then
                            -- Simples fire (depende do jogo, ajuste conforme necessário)
                            local humanoid = plr.Character:FindFirstChild("Humanoid")
                            if humanoid then
                                humanoid:TakeDamage(100)
                            end
                        end
                    end
                end
            end)
            table.insert(loops, auraLoop)
        end
    end
})

CombatTab:AddSlider({
    Name = "Kill Aura Range",
    Min = 5,
    Max = 100,
    Default = 20,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "studs",
    Callback = function(value)
        killAuraRange = value
    end
})

-- Reach
local reachEnabled = false
CombatTab:AddToggle({
    Name = "Reach (Hitbox Expand)",
    Default = false,
    Callback = function(value)
        reachEnabled = value
        if value then
            local reachConn = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                handle.Size = Vector3.new(20, 20, 20) -- Ajuste conforme jogo
                                handle.Transparency = 0.7
                            end
                        end
                    end
                end
            end)
            table.insert(loops, reachConn)
        end
    end
})

-- Box Reach (mais agressivo)
CombatTab:AddToggle({
    Name = "Box Reach",
    Default = false,
    Callback = function(value)
        if value then
            local boxConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    root.Size = Vector3.new(15, 15, 15)
                    root.Transparency = 0.6
                end
            end)
            table.insert(loops, boxConn)
        end
    end
})

-- Loop Kill / Loop Bring
local selectedPlayer = nil
CombatTab:AddDropdown({
    Name = "Selecione Jogador",
    Default = "Nenhum",
    Options = (function()
        local opts = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr \~= LocalPlayer then table.insert(opts, plr.Name) end
        end
        return opts
    end)(),
    Callback = function(value)
        selectedPlayer = Players:FindFirstChild(value)
    end
})

CombatTab:AddButton({
    Name = "Loop Kill (Selected)",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local targetChar = selectedPlayer.Character
            local loopKill = RunService.Heartbeat:Connect(function()
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetChar.HumanoidRootPart
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        -- Teleporta para cima e mata (método comum)
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 5, 0)
                    end
                end
            end)
            table.insert(loops, loopKill)
            OrionLib:MakeNotification({Name = "Loop Kill", Content = "Ativado em " .. selectedPlayer.Name, Time = 3})
        end
    end
})

CombatTab:AddButton({
    Name = "Loop Bring (Selected)",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local targetChar = selectedPlayer.Character
            local loopBring = RunService.Heartbeat:Connect(function()
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetChar.HumanoidRootPart
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -5)
                    end
                end
            end)
            table.insert(loops, loopBring)
        end
    end
})

-- =============================================
-- TAB: UTILITY
-- =============================================
local UtilityTab = Window:MakeTab({
    Name = "Utility",
    Icon = "rbxassetid://4483364070",
    PremiumOnly = false
})

UtilityTab:AddButton({
    Name = "Invisibilidade (Self + Tools)",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name \~= "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, p in pairs(tool:GetDescendants()) do
                        if p:IsA("BasePart") then p.Transparency = 1 end
                    end
                end
            end
        end
    end
})

UtilityTab:AddButton({
    Name = "Reverter Invisibilidade",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
})

-- =============================================
-- TAB: TROLLING
-- =============================================
local TrollingTab = Window:MakeTab({
    Name = "Trolling",
    Icon = "rbxassetid://4483364491",
    PremiumOnly = false
})

-- Freeze Player
TrollingTab:AddButton({
    Name = "Freeze (Selected)",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local hum = selectedPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.PlatformStand = true
            end
        end
    end
})

-- Float
TrollingTab:AddButton({
    Name = "Float (Selected)",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 20, 0)
                bv.Parent = root
            end
        end
    end
})

-- Jail (Barreira simples)
TrollingTab:AddButton({
    Name = "Jail (Selected)",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for i = 1, 8 do
                    local wall = Instance.new("Part")
                    wall.Size = Vector3.new(20, 20, 1)
                    wall.Anchored = true
                    wall.Transparency = 0.5
                    wall.Color = Color3.new(1,0,0)
                    wall.CFrame = root.CFrame * CFrame.Angles(0, math.rad(i*45), 0) * CFrame.new(0, 0, 10)
                    wall.Parent = Workspace
                end
            end
        end
    end
})

-- Loop ForceField
local forceFieldLoop = nil
TrollingTab:AddToggle({
    Name = "Loop ForceField (Self)",
    Default = false,
    Callback = function(value)
        if value then
            forceFieldLoop = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and not char:FindFirstChild("ForceField") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                end
            end)
            table.insert(loops, forceFieldLoop)
        else
            if forceFieldLoop then forceFieldLoop:Disconnect() end
        end
    end
})

-- =============================================
-- Finalização
-- =============================================
OrionLib:Init()

-- Cleanup ao destruir
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Orion" then
        cleanup()
    end
end)

print("✅ Mod Menu carregado com sucesso! Use com responsabilidade no Delta Executor.")
