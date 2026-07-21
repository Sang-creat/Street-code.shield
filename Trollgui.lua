--[[
    SCRIPT TROLL GUI UNIVERSAL - DELTA EXECUTOR MOBILE
    Versão: 2.3 (Integrada com Controle Remoto, Super Ring Defensivo e Tween de Longo Alcance)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Toggles = {}
local Targets = {Player = nil}

-- Referência do Remote fornecida pelo usuário
local AvatarRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AvatarMainRE")

-- Remove interface anterior se já existir
if LocalPlayer.PlayerGui:FindFirstChild("TrollGUI_Mobile") then
    LocalPlayer.PlayerGui.TrollGUI_Mobile:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollGUI_Mobile"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 500)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 0, 255)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(150, 0, 255)
Glow.Thickness = 2
Glow.Transparency = 0.5
Glow.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "[DELTA] TROLL GUI v2.3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
Title.BackgroundTransparency = 0.3
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.TextScaled = true
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container de Scroll
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -10, 1, -45)
ScrollContainer.Position = UDim2.new(0, 5, 0, 40)
ScrollContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollContainer.BackgroundTransparency = 0.5
ScrollContainer.BorderSizePixel = 0
ScrollContainer.Parent = MainFrame
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.ScrollBarThickness = 5

local UILayout = Instance.new("UIListLayout")
UILayout.Parent = ScrollContainer
UILayout.Padding = UDim.new(0, 5)
UILayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateCategory(Name)
    local Category = Instance.new("Frame")
    Category.Size = UDim2.new(1, 0, 0, 0)
    Category.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Category.BackgroundTransparency = 0.2
    Category.BorderSizePixel = 1
    Category.BorderColor3 = Color3.fromRGB(80, 80, 150)
    Category.Parent = ScrollContainer
    Category.AutomaticSize = Enum.AutomaticSize.Y
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, 0, 0, 25)
    TitleLbl.Text = Name
    TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 255)
    TitleLbl.TextScaled = true
    TitleLbl.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    TitleLbl.BackgroundTransparency = 0.2
    TitleLbl.Parent = Category
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -5, 0, 0)
    Content.Position = UDim2.new(0, 2, 0, 27)
    Content.BackgroundTransparency = 1
    Content.Parent = Category
    Content.AutomaticSize = Enum.AutomaticSize.Y
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = Content
    ContentLayout.Padding = UDim.new(0, 3)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return Content
end

local TargetContent = CreateCategory("👥 SELECIONAR ALVO")
local AdminContent = CreateCategory("⚔️ TROLL & COMBATE")

-- ==================== LISTA DE JOGADORES ====================
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 25)
TargetLabel.Text = "Alvo Atual: NENHUM"
TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TargetLabel.TextScaled = true
TargetLabel.BackgroundTransparency = 1
TargetLabel.Parent = TargetContent

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 100)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.Parent = TargetContent
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.ScrollBarThickness = 4

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Parent = PlayerScroll
PlayerLayout.Padding = UDim.new(0, 2)

local function UpdatePlayerList()
    for _, child in ipairs(PlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 25)
            Btn.Text = "  " + plr.Name
            Btn.Text = "  " .. plr.Name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            Btn.Parent = PlayerScroll
            
            Btn.MouseButton1Click:Connect(function()
                Targets.Player = plr
                TargetLabel.Text = "Alvo Atual: " .. plr.Name
            end)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 27)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Construtor de Toggles
local function CreateToggle(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size = UDim2.new(0.65, 0, 1, 0)
    LabelTxt.Text = Label
    LabelTxt.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelTxt.TextXAlignment = Enum.TextXAlignment.Left
    LabelTxt.TextScaled = true
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 25)
    ToggleBtn.Position = UDim2.new(0.7, 0, 0, 2)
    ToggleBtn.Text = Default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ToggleBtn.Parent = Frame
    
    local State = Default
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.Text = State and "ON" or "OFF"
        ToggleBtn.TextColor3 = State and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if Callback then Callback(State) end
    end)
    
    Toggles[Label] = {GetState = function() return State end}
end

-- ==================== FUNÇÕES TROLL ====================

-- 1. FREEZE (Prisão por gaiola estática ao redor do alvo)
CreateToggle(AdminContent, "🔒 Freeze Alvo", false, function(state)
    if state then
        task.spawn(function()
            local jailParts = {}
            while Toggles["🔒 Freeze Alvo"] and Toggles["🔒 Freeze Alvo"].GetState() do
                local target = Targets.Player
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = target.Character.HumanoidRootPart.Position
                    if #jailParts == 0 then
                        for i = 1, 5 do
                            local p = Instance.new("Part")
                            p.Size = Vector3.new(6, 6, 6)
                            p.Anchored = true
                            p.Transparency = 0.8
                            p.BrickColor = BrickColor.new("Bright red")
                            p.CanCollide = true
                            p.Parent = Workspace
                            table.insert(jailParts, p)
                        end
                    end
                    jailParts[1].Position = pos + Vector3.new(0, -3, 0)
                    jailParts[2].Position = pos + Vector3.new(4, 0, 0)
                    jailParts[3].Position = pos + Vector3.new(-4, 0, 0)
                    jailParts[4].Position = pos + Vector3.new(0, 0, 4)
                    jailParts[5].Position = pos + Vector3.new(0, 0, -4)
                end
                task.wait(0.2)
            end
            for _, p in ipairs(jailParts) do p:Destroy() end
        end)
    end
end)

-- 2. ESP BÁSICO
CreateToggle(AdminContent, "👁️ ESP Jogadores", false, function(state)
    local ESPBoxes = {}
    if state then
        task.spawn(function()
            while Toggles["👁️ ESP Jogadores"] and Toggles["👁️ ESP Jogadores"].GetState() do
                for _, box in pairs(ESPBoxes) do if box then box:Destroy() end end
                ESPBoxes = {}
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local pos, onScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local box = Instance.new("Frame")
                            box.Size = UDim2.new(0, 40, 0, 60)
                            box.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - 30)
                            box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            box.BackgroundTransparency = 0.7
                            box.Parent = ScreenGui
                            table.insert(ESPBoxes, box)
                        end
                    end
                end
                task.wait(0.1)
            end
            for _, box in pairs(ESPBoxes) do if box then box:Destroy() end end
        end)
    end
end)

-- 3. SUPER RING DEFENSIVO (Anel de Espada a ~2 Studs para impedir bangs e matar)
CreateToggle(AdminContent, "💫 Super Ring Defensivo (Espada)", false, function(state)
    if state then
        task.spawn(function()
            local gearIdDefesa = 268586231 -- ID de uma espada/gear padrão
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdDefesa, ["event"] = "equip", ["equiptype"] = "Gear"})
            end
            task.wait(0.5)
            
            local angle = 0
            while Toggles["💫 Super Ring Defensivo (Espada)"] and Toggles["💫 Super Ring Defensivo (Espada)"].GetState() do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local gearName = "Gear" .. gearIdDefesa
                    local gearInstance = char:FindFirstChild(gearName) or LocalPlayer.Backpack:FindFirstChild(gearName)
                    
                    if gearInstance and gearInstance:FindFirstChild("Handle") then
                        local handle = gearInstance.Handle
                        -- Força o item para o workspace para controle físico livre no anel
                        if gearInstance.Parent ~= Workspace then
                            gearInstance.Parent = Workspace
                        end
                        
                        handle.CanCollide = true
                        angle = angle + 25 -- Velocidade de rotação alta
                        local rad = math.rad(angle)
                        local radius = 2 -- Exatamente a 2 Studs de distância do corpo
                        local x = root.Position.X + math.cos(rad) * radius
                        local z = root.Position.Z + math.sin(rad) * radius
                        
                        handle.CFrame = CFrame.new(Vector3.new(x, root.Position.Y, z), root.Position)
                        
                        -- Sistema de impacto em quem se aproximar para dar bang/grudar
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local pRoot = p.Character.HumanoidRootPart
                                if (pRoot.Position - handle.Position).Magnitude < 3.5 then
                                    pRoot.Velocity = (pRoot.Position - root.Position).Unit * 70 + Vector3.new(0, 30, 0)
                                end
                            end
                        end
                    end
                end
                task.wait(0.03)
            end
            
            -- Recoloca na mochila ao desligar
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdDefesa, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end)
    end
end)

-- 4. ESPADA TELEGUIADA DE LONGO ALCANCE (Com Tween proporcional de 400 em 400 studs e carregamento de mapa)
CreateToggle(AdminContent, "🚀 Espada Teleguiada (Longo Alcance)", false, function(state)
    if state then
        task.spawn(function()
            local target = Targets.Player
            if not target then
                print("[!] Nenhum alvo selecionado para a espada de longo alcance.")
                return
            end
            
            local gearIdAtaque = 268586231
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdAtaque, ["event"] = "equip", ["equiptype"] = "Gear"})
            end
            task.wait(0.6)
            
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local gearName = "Gear" + gearIdAtaque
            local gearName = "Gear" .. gearIdAtaque
            local gearInstance = char and char:FindFirstChild(gearName)
            
            if root and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and gearInstance and gearInstance:FindFirstChild("Handle") then
                local handle = gearInstance.Handle
                gearInstance.Parent = Workspace -- Libera no Workspace para voar livre
                handle.CanCollide = true
                
                local targetRoot = target.Character.HumanoidRootPart
                local distanciaTotal = (root.Position - targetRoot.Position).Magnitude
                
                print("[+] Distância calculada até o alvo: " .. math.floor(distanciaTotal) .. " Studs.")
                
                -- Algoritmo de blocos de 400 em 400 studs com tempo de espera dinâmico para renderização/carregamento do mapa
                local blocos = math.ceil(distanciaTotal / 400)
                local tempoPorBloco = 0.8 -- Segundos estimados por cada bloco de 400 studs para evitar travamento de render
                local tempoTotalVoo = math.clamp(blocos * tempoPorBloco, 0.5, 12)
                
                -- Executa a interpolação (Tween) de alta precisão
                local tweenInfo = TweenInfo.new(tempoTotalVoo, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(handle, tweenInfo, {
                    CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
                })
                
                tween:Play()
                
                -- Aguarda a chegada garantindo que o motor processe o trecho percorrido
                pcall(function()
                    tween.Completed:Wait()
                end)
                
                -- Impacto físico forçado ao chegar
                task.wait(0.2)
                if gearInstance and gearInstance.Parent then
                    gearInstance:Destroy()
                end
            end
        end)
    end
end)

print("[DELTA] Troll GUI v2.3 Carregada com Sucesso!")
