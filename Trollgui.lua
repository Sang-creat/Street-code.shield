--[[
    SCRIPT TROLL GUI UNIVERSAL - DELTA EXECUTOR MOBILE
    Versão: 2.6 (Correção de Layout da Barra Superior e Fixação Física do Super Ring)
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

local AvatarRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AvatarMainRE")

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
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
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

-- Barra de Título Corrigida (Com espaço livre para os botões)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 0, 35)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Text = "TROLL GUI v2.6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- Fundo da Barra Superior
local TopBarBg = Instance.new("Frame")
TopBarBg.Size = UDim2.new(1, 0, 0, 35)
TopBarBg.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
TopBarBg.BackgroundTransparency = 0.3
TopBarBg.ZIndex = 0
TopBarBg.Parent = MainFrame

-- Botão de Fechar (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 2)
CloseBtn.ZIndex = 2
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.TextScaled = true
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Botão de Minimizar (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -66, 0, 2)
MinimizeBtn.ZIndex = 2
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
MinimizeBtn.TextScaled = true
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.BackgroundTransparency = 0.3
MinimizeBtn.Parent = MainFrame

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child:IsA("ScrollingFrame") then
            child.Visible = not isMinimized
        end
    end
    MainFrame.Size = isMinimized and UDim2.new(0, 320, 0, 35) or UDim2.new(0, 320, 0, 460)
    MinimizeBtn.Text = isMinimized and "+" or "-"
end)

-- Container de Scroll Principal
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -10, 1, -45)
ScrollContainer.Position = UDim2.new(0, 5, 0, 40)
ScrollContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollContainer.BackgroundTransparency = 0.5
ScrollContainer.BorderSizePixel = 0
ScrollContainer.Parent = MainFrame
ScrollContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollContainer.ScrollBarThickness = 5

local UILayout = Instance.new("UIListLayout")
UILayout.Parent = ScrollContainer
UILayout.Padding = UDim.new(0, 8)
UILayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateCategory(Name, Height)
    local Category = Instance.new("Frame")
    Category.Size = UDim2.new(1, 0, 0, Height)
    Category.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Category.BackgroundTransparency = 0.2
    Category.BorderSizePixel = 1
    Category.BorderColor3 = Color3.fromRGB(80, 80, 150)
    Category.Parent = ScrollContainer
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, 0, 0, 25)
    TitleLbl.Text = Name
    TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 255)
    TitleLbl.TextScaled = true
    TitleLbl.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    TitleLbl.BackgroundTransparency = 0.2
    TitleLbl.Parent = Category
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -4, 1, -28)
    Content.Position = UDim2.new(0, 2, 0, 28)
    Content.BackgroundTransparency = 1
    Content.Parent = Category
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = Content
    ContentLayout.Padding = UDim.new(0, 3)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return Content
end

local TargetContent = CreateCategory("👥 SELECIONAR ALVO", 130)
local AdminContent = CreateCategory("⚔️ TROLL & COMBATE", 180)

-- ==================== LISTA DE JOGADORES ====================
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 22)
TargetLabel.Text = "Alvo Atual: NENHUM"
TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TargetLabel.TextScaled = true
TargetLabel.BackgroundTransparency = 1
TargetLabel.Parent = TargetContent

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 95)
PlayerScroll.Position = UDim2.new(0, 0, 0, 25)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.Parent = TargetContent
PlayerScroll.ScrollBarThickness = 4

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Parent = PlayerScroll
PlayerLayout.Padding = UDim.new(0, 2)

local function UpdatePlayerList()
    for _, child in ipairs(PlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            count = count + 1
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -5, 0, 26)
            Btn.Text = "  " .. plr.Name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            Btn.Parent = PlayerScroll
            
            Btn.MouseButton1Click:Connect(function()
                Targets.Player = plr
                TargetLabel.Text = "Alvo: " .. plr.Name
            end)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

local function CreateToggle(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size = UDim2.new(0.65, 0, 1, 0)
    LabelTxt.Text = " " .. Label
    LabelTxt.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelTxt.TextXAlignment = Enum.TextXAlignment.Left
    LabelTxt.TextSize = 12
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 55, 0, 22)
    ToggleBtn.Position = UDim2.new(0.72, 0, 0, 3)
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

CreateToggle(AdminContent, "🔒 Freeze Alvo (Real)", false, function(state)
    if state then
        task.spawn(function()
            local lockedPos = nil
            while Toggles["🔒 Freeze Alvo (Real)"] and Toggles["🔒 Freeze Alvo (Real)"].GetState() do
                local target = Targets.Player
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local root = target.Character.HumanoidRootPart
                    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                    
                    if not lockedPos then lockedPos = root.CFrame end
                    root.CFrame = lockedPos
                    root.Velocity = Vector3.new(0, 0, 0)
                    if humanoid then humanoid.PlatformStand = true end
                else
                    lockedPos = nil
                end
                task.wait(0.05)
            end
            local target = Targets.Player
            if target and target.Character then
                local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.PlatformStand = false end
            end
        end)
    end
end)

CreateToggle(AdminContent, "👁️ ESP Completo", false, function(state)
    local ESPData = {}
    if state then
        task.spawn(function()
            while Toggles["👁️ ESP Completo"] and Toggles["👁️ ESP Completo"].GetState() do
                for _, obj in pairs(ESPData) do if obj then obj:Destroy() end end
                ESPData = {}
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local root = char.HumanoidRootPart
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        
                        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                        local hp = humanoid and math.floor(humanoid.Health) or 0
                        local maxHp = humanoid and math.floor(humanoid.MaxHealth) or 100
                        
                        if onScreen then
                            local infoLbl = Instance.new("TextLabel")
                            infoLbl.Size = UDim2.new(0, 140, 0, 45)
                            infoLbl.Position = UDim2.new(0, pos.X - 70, 0, pos.Y - 50)
                            infoLbl.BackgroundTransparency = 0.5
                            infoLbl.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                            infoLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                            infoLbl.TextSize = 11
                            infoLbl.Text = string.format("%s\nDist: %d studs\nHP: %d/%d", player.Name, dist, hp, maxHp)
                            infoLbl.Parent = ScreenGui
                            table.insert(ESPData, infoLbl)
                        end
                    end
                end
                task.wait(0.1)
            end
            for _, obj in pairs(ESPData) do if obj then obj:Destroy() end end
        end)
    end
end)

-- SUPER RING CORRIGIDO (Ancorado temporariamente para não cair no chão)
CreateToggle(AdminContent, "💫 Super Ring Defensivo", false, function(state)
    if state then
        task.spawn(function()
            local gearIdDefesa = 268586231
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdDefesa, ["event"] = "equip", ["equiptype"] = "Gear"})
            end
            task.wait(0.5)
            
            local angle = 0
            while Toggles["💫 Super Ring Defensivo"] and Toggles["💫 Super Ring Defensivo"].GetState() do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local gearName = "Gear" .. gearIdDefesa
                    local gearInstance = char:FindFirstChild(gearName) or LocalPlayer.Backpack:FindFirstChild(gearName)
                    
                    if gearInstance and gearInstance:FindFirstChild("Handle") then
                        local handle = gearInstance.Handle
                        if gearInstance.Parent ~= Workspace then
                            gearInstance.Parent = Workspace
                        end
                        
                        -- Trava a física para flutuar sem cair no chão
                        handle.Anchored = true
                        handle.CanCollide = true
                        
                        angle = angle + 30
                        local rad = math.rad(angle)
                        local radius = 2
                        local x = root.Position.X + math.cos(rad) * radius
                        local z = root.Position.Z + math.sin(rad) * radius
                        
                        handle.CFrame = CFrame.new(Vector3.new(x, root.Position.Y + 0.5, z), root.Position)
                        
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local pRoot = p.Character.HumanoidRootPart
                                if (pRoot.Position - handle.Position).Magnitude < 3.5 then
                                    pRoot.Velocity = (pRoot.Position - root.Position).Unit * 80 + Vector3.new(0, 35, 0)
                                end
                            end
                        end
                    end
                end
                task.wait(0.02)
            end
            
            -- Desancora antes de devolver para evitar bugs de inventário
            local gearInstance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gear" .. gearIdDefesa) or Workspace:FindFirstChild("Gear" .. gearIdDefesa)
            if gearInstance and gearInstance:FindFirstChild("Handle") then
                gearInstance.Handle.Anchored = false
            end
            
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdDefesa, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end)
    end
end)

-- ESPADA TELEGUIADA EM LOOP CORRIGIDA
CreateToggle(AdminContent, "🚀 Espada Teleguiada (Loop)", false, function(state)
    if state then
        task.spawn(function()
            local gearIdAtaque = 268586231
            
            while Toggles["🚀 Espada Teleguiada (Loop)"] and Toggles["🚀 Espada Teleguiada (Loop)"].GetState() do
                local target = Targets.Player
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    if AvatarRemote then
                        AvatarRemote:FireServer({["id"] = gearIdAtaque, ["event"] = "equip", ["equiptype"] = "Gear"})
                    end
                    task.wait(0.6)
                    
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local gearName = "Gear" .. gearIdAtaque
                    local gearInstance = char and (char:FindFirstChild(gearName) or LocalPlayer.Backpack:FindFirstChild(gearName))
                    
                    if root and gearInstance then
                        if gearInstance.Parent == LocalPlayer.Backpack then
                            gearInstance.Parent = char
                        end
                        local handle = gearInstance:FindFirstChild("Handle")
                        if handle then
                            gearInstance.Parent = Workspace
                            handle.Anchored = false
                            handle.CanCollide = true
                            
                            local targetRoot = target.Character.HumanoidRootPart
                            local distanciaTotal = (root.Position - targetRoot.Position).Magnitude
                            
                            local blocos = math.ceil(distanciaTotal / 400)
                            local tempoVoo = math.clamp(blocos * 0.7, 0.4, 10)
                            
                            local tweenInfo = TweenInfo.new(tempoVoo, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(handle, tweenInfo, {
                                CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
                            })
                            
                            tween:Play()
                            pcall(function() tween.Completed:Wait() end)
                            
                            task.wait(0.2)
                            if gearInstance and gearInstance.Parent then
                                gearInstance:Destroy()
                            end
                        end
                    end
                end
                task.wait(1.5)
            end
        end)
    end
end)

print("[DELTA] Troll GUI v2.6 Carregada com Sucesso!")
