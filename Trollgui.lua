--[[
    SCRIPT TROLL GUI UNIVERSAL - DELTA EXECUTOR MOBILE
    Versão: 2.1 (Corrigida e Otimizada para Mobile)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- TABELAS GLOBAIS DE CONTROLE
local Toggles = {}
local Targets = {Player = nil, Part = nil}

-- CONFIGURAÇÕES DE BYPASS BÁSICO
local BypassSettings = {
    VelocitySmoothing = true,
}

local function BypassAntiCheat(Action)
    local Success, Error = pcall(function()
        if BypassSettings.VelocitySmoothing then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local Root = Character.HumanoidRootPart
                Root.Velocity = Root.Velocity * 0.99
            end
        end
        return Action()
    end)
    return Success
end

-- ==================== SISTEMA DE INTERFACE ====================
-- Remove interface anterior se já existir para evitar duplicação
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
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 0, 255)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true -- Nota: Em alguns executores mobile o Draggable nativo pode precisar de toque duplo, mas mantido para compatibilidade.

-- Sombra/Glow
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(150, 0, 255)
Glow.Thickness = 2
Glow.Transparency = 0.5
Glow.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "[DELTA] TROLL GUI v2.1"
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

-- Função auxiliar para criar categorias
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

local AdminContent = CreateCategory("⚔️ ADMIN & TROLL")

-- Função otimizada para criar Toggles e registrá-los corretamente
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
    
    -- Retorna um objeto que permite checar o estado atual
    local ToggleObj = {GetState = function() return State end}
    Toggles[Label] = ToggleObj
    return ToggleObj
end

-- ==================== IMPLEMENTAÇÃO DAS FUNÇÕES ====================

-- 1. Jail (Prisão temporária ao redor do alvo)
CreateToggle(AdminContent, "🔒 Jail", false, function(state)
    if state then
        BypassAntiCheat(function()
            local target = Targets.Player or LocalPlayer
            local char = target.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                local jail = Instance.new("Part")
                jail.Size = Vector3.new(8, 8, 8)
                jail.Position = pos
                jail.Anchored = true
                jail.Transparency = 0.8
                jail.BrickColor = BrickColor.new("Bright red")
                jail.CanCollide = true
                jail.Parent = Workspace
                
                char.HumanoidRootPart.CFrame = CFrame.new(pos)
                game:GetService("Debris"):AddItem(jail, 15)
            end
        end)
    end
end)

-- 2. Super Ring (Anéis giratórios de impacto)
CreateToggle(AdminContent, "💫 Super Ring", false, function(state)
    if state then
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(15, 1, 15)
        ring.Shape = Enum.PartType.Cylinder
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0.5
        ring.BrickColor = BrickColor.new("Bright blue")
        ring.Parent = Workspace
        
        task.spawn(function()
            while Toggles["💫 Super Ring"] and Toggles["💫 Super Ring"].GetState() do
                BypassAntiCheat(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = LocalPlayer.Character.HumanoidRootPart.Position
                        ring.Position = pos
                        ring.Orientation = Vector3.new(0, tick() * 50 % 360, 0)
                        
                        -- Empurrar jogadores próximos
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = player.Character.HumanoidRootPart
                                if (hrp.Position - pos).Magnitude < 10 then
                                    hrp.Velocity = (hrp.Position - pos).Unit * 40
                                end
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
            ring:Destroy()
        end)
    end
end)

-- 3. ESP Simples e Otimizado para Mobile
CreateToggle(AdminContent, "👁️ ESP", false, function(state)
    local ESPBoxes = {}
    
    if state then
        task.spawn(function()
            while Toggles["👁️ ESP"] and Toggles["👁️ ESP"].GetState() do
                -- Limpa ESP antigo do ciclo anterior
                for _, box in pairs(ESPBoxes) do
                    if box then box:Destroy() end
                end
                ESPBoxes = {}
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                        local hrp = player.Character.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                        
                        if onScreen then
                            local box = Instance.new("Frame")
                            box.Size = UDim2.new(0, 40, 0, 60)
                            box.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - 30)
                            box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            box.BackgroundTransparency = 0.7
                            box.BorderSizePixel = 1
                            box.BorderColor3 = Color3.fromRGB(0, 255, 0)
                            box.Parent = ScreenGui
                            
                            table.insert(ESPBoxes, box)
                        end
                    end
                end
                task.wait(0.1)
            end
            
            -- Remove tudo ao desativar
            for _, box in pairs(ESPBoxes) do
                if box then box:Destroy() end
            end
        end)
    end
end)

print("[DELTA] Troll GUI carregada com sucesso!")

