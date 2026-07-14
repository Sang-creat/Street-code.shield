--[[
    SCRIPT TROLL GUI UNIVERSAL - DELTA EXECUTOR MOBILE
    Versão: 2.0 (Otimizada para FilteringEnabled + Anti-Cheat Bypass)
    Desenvolvido para fins educacionais em engenharia reversa
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

-- CONFIGURAÇÕES DE BYPASS
local BypassSettings = {
    AntiKick = true,
    VelocitySmoothing = true,
    RemoteSpoof = true,
    JitterAmount = 0.5
}

-- VARIÁVEIS GLOBAIS
local Toggles = {}
local Sliders = {}
local TextBoxes = {}
local Functions = {}
local Targets = {Player = nil, Part = nil}
local SoundIds = {}

-- ==================== SISTEMA DE BYPASS ====================
local function BypassAntiCheat(Action)
    local Success, Error = pcall(function()
        if BypassSettings.VelocitySmoothing then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local Root = Character.HumanoidRootPart
                local CurrentVel = Root.Velocity
                Root.Velocity = CurrentVel * 0.99
            end
        end
        
        if BypassSettings.RemoteSpoof and ReplicatedStorage:FindFirstChild("__REMOTE") then
            local SpoofRemote = ReplicatedStorage:FindFirstChild("__REMOTE")
            SpoofRemote:FireServer("Ping", tick())
        end
        
        return Action()
    end)
    
    if not Success and Error then
        warn("[BYPASS] Erro detectado, reiniciando função: " .. tostring(Error))
        return Action()
    end
    return Success
end

-- ==================== SISTEMA DE ÁUDIO ====================
local function PlayMusicForAll(SongId)
    if not SongId or SongId == "" then return end
    
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://" .. tostring(SongId)
    Sound.Volume = 1
    Sound.Looped = false
    Sound.PlayOnRemove = true
    
    -- Replicação via RemoteEvent (se disponível)
    local RemoteEvent = ReplicatedStorage:FindFirstChild("MusicBroadcast")
    if RemoteEvent then
        RemoteEvent:FireServer(SongId)
    else
        -- Fallback: Criar som local para todos os jogadores
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player.Character then
                local CopySound = Sound:Clone()
                CopySound.Parent = Player.Character.Head
                CopySound:Play()
                game:GetService("Debris"):AddItem(CopySound, 10)
            end
        end
    end
    
    Sound:Destroy()
end

-- ==================== SISTEMA DE INTERFACE ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollGUI_Mobile"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 0, 255)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Sombra/Glow
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(150, 0, 255)
Glow.Thickness = 3
Glow.Transparency = 0.5
Glow.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "[DELTA] TROLL GUI v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
Title.BackgroundTransparency = 0.3
Title.Parent = MainFrame

-- Botão Fechar
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

-- Botões de Escala
local ScaleUp = Instance.new("TextButton")
ScaleUp.Size = UDim2.new(0, 25, 0, 25)
ScaleUp.Position = UDim2.new(1, -70, 0, 2)
ScaleUp.Text = "+"
ScaleUp.TextColor3 = Color3.fromRGB(0, 255, 0)
ScaleUp.TextScaled = true
ScaleUp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScaleUp.BackgroundTransparency = 0.3
ScaleUp.Parent = MainFrame
ScaleUp.MouseButton1Click:Connect(function()
    local NewSize = MainFrame.Size.X.Scale + 0.1
    if NewSize <= 0.8 then
        MainFrame.Size = UDim2.new(NewSize, 0, 0, 500)
    end
end)

local ScaleDown = Instance.new("TextButton")
ScaleDown.Size = UDim2.new(0, 25, 0, 25)
ScaleDown.Position = UDim2.new(1, -100, 0, 2)
ScaleDown.Text = "-"
ScaleDown.TextColor3 = Color3.fromRGB(255, 0, 0)
ScaleDown.TextScaled = true
ScaleDown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScaleDown.BackgroundTransparency = 0.3
ScaleDown.Parent = MainFrame
ScaleDown.MouseButton1Click:Connect(function()
    local NewSize = MainFrame.Size.X.Scale - 0.1
    if NewSize >= 0.3 then
        MainFrame.Size = UDim2.new(NewSize, 0, 0, 500)
    end
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
ScrollContainer.ScrollBarThickness = 5

-- Layout para Scroll
local UILayout = Instance.new("UIListLayout")
UILayout.Parent = ScrollContainer
UILayout.Padding = UDim.new(0, 5)
UILayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==================== FUNÇÕES DE INTERFACE ====================
local function CreateCategory(Name, Order)
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
    
    return Category, Content, ContentLayout
end

local function CreateToggle(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size = UDim2.new(0.7, 0, 1, 0)
    LabelTxt.Text = Label
    LabelTxt.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelTxt.TextXAlignment = Enum.TextXAlignment.Left
    LabelTxt.TextScaled = true
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
    ToggleBtn.Position = UDim2.new(0.75, 0, 0, 2)
    ToggleBtn.Text = Default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ToggleBtn.BorderSizePixel = 1
    ToggleBtn.BorderColor3 = Color3.fromRGB(100, 100, 150)
    ToggleBtn.Parent = Frame
    
    local State = Default
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.Text = State and "ON" or "OFF"
        ToggleBtn.TextColor3 = State and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if Callback then Callback(State) end
    end)
    
    return {Frame = Frame, Button = ToggleBtn, GetState = function() return State end}
end

local function CreateSlider(Parent, Label, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size = UDim2.new(1, 0, 0, 18)
    LabelTxt.Text = Label .. ": " .. tostring(Default)
    LabelTxt.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelTxt.TextScaled = true
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Parent = Frame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, 22)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    
    local Value = Default
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 15, 0, 15)
    SliderBtn.Position = UDim2.new((Default - Min) / (Max - Min), -7, 0, -3)
    SliderBtn.Text = ""
    SliderBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
    SliderBtn.BorderSizePixel = 1
    SliderBtn.BorderColor3 = Color3.fromRGB(150, 150, 200)
    SliderBtn.Parent = SliderBar
    
    local Dragging = false
    SliderBtn.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)
    
    SliderBtn.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseMovement) then
            local Pos = Input.Position.X - SliderBar.AbsolutePosition.X
            local Percent = math.clamp(Pos / SliderBar.AbsoluteSize.X, 0, 1)
            Value = Min + (Max - Min) * Percent
            Fill.Size = UDim2.new(Percent, 0, 1, 0)
            SliderBtn.Position = UDim2.new(Percent, -7, 0, -3)
            LabelTxt.Text = Label .. ": " .. math.round(Value * 100) / 100
            if Callback then Callback(Value) end
        end
    end)
    
    return {Frame = Frame, GetValue = function() return Value end}
end

local function CreateTextBox(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size = UDim2.new(0.3, 0, 1, 0)
    LabelTxt.Text = Label
    LabelTxt.TextColor3 = Color3.fromRGB(220, 220, 220)
    LabelTxt.TextXAlignment = Enum.TextXAlignment.Left
    LabelTxt.TextScaled = true
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.65, 0, 1, 0)
    Box.Position = UDim2.new(0.35, 0, 0, 0)
    Box.Text = tostring(Default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.TextScaled = true
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Box.BorderSizePixel = 1
    Box.BorderColor3 = Color3.fromRGB(100, 100, 150)
    Box.Parent = Frame
    Box.FocusLost:Connect(function()
        if Callback then Callback(Box.Text) end
    end)
    
    return {Frame = Frame, Box = Box, GetText = function() return Box.Text end}
end

-- ==================== CRIAÇÃO DAS CATEGORIAS ====================
local Categories = {
    ["⚔️ ADMIN"] = {},
    ["👁️ VISUAL"] = {},
    ["🎯 COMBATE"] = {},
    ["🎵 ÁUDIO"] = {},
    ["🛡️ PROTEÇÃO"] = {}
}

local AdminCat, AdminContent = CreateCategory("⚔️ ADMIN", 1)
local VisualCat, VisualContent = CreateCategory("👁️ VISUAL", 2)
local CombatCat, CombatContent = CreateCategory("🎯 COMBATE", 3)
local AudioCat, AudioContent = CreateCategory("🎵 ÁUDIO", 4)
local ProtectCat, ProtectContent = CreateCategory("🛡️ PROTEÇÃO", 5)

-- ==================== FUNÇÕES ADMINISTRATIVAS ====================
local AdminFunctions = {}

-- Jail
AdminFunctions.Jail = CreateToggle(AdminContent, "🔒 Jail", false, function(state)
    if state then
        local target = Targets.Player or LocalPlayer
        local char = target.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local jail = Instance.new("Part")
            jail.Size = Vector3.new(10, 10, 10)
            jail.Position = pos
            jail.Anchored = true
            jail.Transparency = 0.7
            jail.BrickColor = BrickColor.new("Bright red")
            jail.CanCollide = true
            jail.Parent = workspace
            
            -- Barra de prisão
            for i = 1, 4 do
                local bar = Instance.new("Part")
                bar.Size = Vector3.new(0.5, 10, 0.5)
                bar.Position = pos + Vector3.new(5 * math.cos(math.rad(i * 90)), 0, 5 * math.sin(math.rad(i * 90)))
                bar.Anchored = true
                bar.Transparency = 0.5
                bar.BrickColor = BrickColor.new("Bright red")
                bar.CanCollide = true
                bar.Parent = workspace
                game:GetService("Debris"):AddItem(bar, 30)
            end
            
            char.HumanoidRootPart.CFrame = CFrame.new(pos)
            game:GetService("Debris"):AddItem(jail, 30)
        end
    end
end)

-- Super Ring
AdminFunctions.SuperRing = CreateToggle(AdminContent, "💫 Super Ring", false, function(state)
    if state then
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(20, 1, 20)
        ring.Shape = Enum.PartType.Cylinder
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0.5
        ring.BrickColor = BrickColor.new("Bright blue")
        ring.Parent = workspace
        
        local ring2 = Instance.new("Part")
        ring2.Size = Vector3.new(15, 1, 15)
        ring2.Shape = Enum.PartType.Cylinder
        ring2.Anchored = true
        ring2.CanCollide = false
        ring2.Transparency = 0.3
        ring2.BrickColor = BrickColor.new("Bright yellow")
        ring2.Parent = workspace
        
        spawn(function()
            while Toggles["Super Ring"] and Toggles["Super Ring"].GetState() do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = LocalPlayer.Character.HumanoidRootPart.Position
                    ring.Position = pos
                    ring2.Position = pos
                    ring.Rotation = Vector3.new(0, tick() * 30 % 360, 0)
                    ring2.Rotation = Vector3.new(0, -tick() * 30 % 360, 0)
                    
                    -- Knockback
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - pos).Magnitude
                            if dist < 10 then
                                local hrp = player.Character.HumanoidRootPart
                                hrp.Velocity = (hrp.Position - pos).Unit * 50
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
            ring:Destroy()
            ring2:Destroy()
        end)
    end
end)

-- Anchor
AdminFunctions.Anchor = CreateToggle(AdminContent, "⚓ Anchor", false, function(state)
    if state then
        spawn(function()
            while Toggles["Anchor"].GetState() do
                if Targets.Player and Targets.Player.Character and Targets.Player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Targets.Player.Character.HumanoidRootPart
                    hrp.CFrame = hrp.CFrame
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- ESP
AdminFunctions.ESP = CreateToggle(AdminContent, "👁️ ESP", false, function(state)
    local ESPObjects = {}
    if state then
        spawn(function()
            while Toggles["ESP"].GetState() do
                for _, espObj in pairs(ESPObjects) do
                    espObj:Destroy()
                end
                ESPObjects = {}
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                        
                        if onScreen then
                            local box = Instance.new("Frame")
                            box.Size = UDim2.new(0, 50, 0, 80)
                            box.Position = UDim2.new(0, pos.X - 25, 0, pos.Y - 40)
                            box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            box.BackgroundTransparency = 0.7
                            box.BorderSizePixel = 2
                            box.BorderColor3 = Color3.fromRGB(0, 255, 0)
                            box.Parent = ScreenGui
                            
                            local name = Instance.new("TextLabel")
                            name.Size = UDim2.new(1, 0, 0, 20)
                            name.Position = UDim2.new(0, 0, 1, 0)
                            name.Text = player.Name .. " | " .. math.round((player.Character.Humanoid.Health)) .. "HP"
                            name.TextColor3 = Color3.fromRGB(255, 255, 255)
                            name.TextScaled = true
                            name.BackgroundTransparency = 1
                            name.Parent = box
                            
                            table.insert(ESPObjects, box)
                        end
                    end
                end
                task.wait(0.1)
            end
            
            for _, espObj in pairs(ESPObjects) do
                espObj:Destroy()
            end
        end)
    end
end)

-- Freeze
AdminFunctions.Freeze = CreateToggle(AdminContent, "❄️ Freeze", false, function(state)
    if state then
        spawn(function()
            while Toggles["Freeze"].GetState() do
                if Targets.Player and Targets.Pla
