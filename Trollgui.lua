--[[
    SCRIPT TROLL GUI UNIVERSAL - DELTA EXECUTOR MOBILE
    Versão: 2.4 (Correção da Lista de Jogadores e Layout Mobile)
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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "[DELTA] TROLL GUI v2.4"
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
local AdminContent = CreateCategory("⚔️ TROLL & COMBATE", 160)

-- ==================== LISTA DE JOGADORES CORRIGIDA ====================
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
            Btn.Text = "  " .. plr.Name -- Correção do operador de string
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

-- Construtor de Toggles Seguro
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
                            box.Size = UDim2.new(0, 35, 0, 50)
                            box.Position = UDim2.new(0, pos.X - 17, 0, pos.Y - 25)
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
                        
                        handle.CanCollide = true
                        angle = angle + 25
                        local rad = math.rad(angle)
                        local radius = 2
                        local x = root.Position.X + math.cos(rad) * radius
                        local z = root.Position.Z + math.sin(rad) * radius
                        
                        handle.CFrame = CFrame.new(Vector3.new(x, root.Position.Y, z), root.Position)
                        
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
            
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdDefesa, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end)
    end
end)

CreateToggle(AdminContent, "🚀 Espada Teleguiada", false, function(state)
    if state then
        task.spawn(function()
            local target = Targets.Player
            if not target then
                print("[!] Nenhum alvo selecionado.")
                return
            end
            
            local gearIdAtaque = 268586231
            if AvatarRemote then
                AvatarRemote:FireServer({["id"] = gearIdAtaque, ["event"] = "equip", ["equiptype"] = "Gear"})
            end
            task.wait(0.6)
            
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local gearName = "Gear" .. gearIdAtaque
            local gearInstance = char and char:FindFirstChild(gearName)
            
            if root and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and gearInstance and gearInstance:FindFirstChild("Handle") then
                local handle = gearInstance.Handle
                gearInstance.Parent = Workspace
                handle.CanCollide = true
                
                local targetRoot = target.Character.HumanoidRootPart
                local distanciaTotal = (root.Position - targetRoot.Position).Magnitude
                
                local blocos = math.ceil(distanciaTotal / 400)
                local tempoTotalVoo = math.clamp(blocos * 0.8, 0.5, 12)
                
                local tweenInfo = TweenInfo.new(tempoTotalVoo, Enum.EasingStyle.Linear)
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
        end)
    end
end)

print("[DELTA] Troll GUI v2.4 Carregada com Sucesso!")
