-- Serviços necessários
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Remotes (Unificados)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InteractGiftRE = Remotes:WaitForChild("InteractGiftRE")
local SpawnVehiclesRE = Remotes:WaitForChild("SpawnVehiclesRE")
local AvatarMainRE = Remotes:WaitForChild("AvatarMainRE")

-- Variáveis de Estado Globais (Toggles)
local giftFreezeActive = false
local loopBringActive = false
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopTask = nil
local isTeleporting = false
local selectedTargetPlayer = nil
local selectedToolId = "CupCoffee"

-- Grupos de Gears (Mantido com a lógica original exata)
local GearGroups = {
    {Name = "DEFESA", Color = Color3.fromRGB(52, 152, 219), Gears = {94794847, 236441643, 80661504}, Active = false},
    {Name = "ESPADAS", Color = Color3.fromRGB(231, 76, 60), Gears = {99119240, 93136746, 108158379, 268586231}, Active = false},
    {Name = "1-ATAQUE BÁSICO", Color = Color3.fromRGB(46, 204, 113), Gears = {26017478, 70476425, 1208300505}, Active = false},
    {Name = "2-ATAQUE INDIRETO", Color = Color3.fromRGB(241, 196, 15), Gears = {127506257, 108158379, 70476425}, Active = false},
    {Name = "3-ATAQUE DIRETO OP", Color = Color3.fromRGB(155, 89, 182), Gears = {127506257, 268586231, 1117745433}, Active = false},
    {Name = "INVISIBILIDADE", Color = Color3.fromRGB(149, 165, 166), Special = true, CapaID = 129471121, Active = false}
}

-- Remove GUI anterior se já existir para evitar duplicatas
if CoreGui:FindFirstChild("TrollHubMobile") then
    CoreGui.TrollHubMobile:Destroy()
end

-- Criação da ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHubMobile"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botão Flutuante (Abrir/Fechar Hub na Tela)
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 60, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ToggleGuiBtn.Text = "HUB"
ToggleGuiBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleGuiBtn.Font = Enum.Font.SourceSansBold
ToggleGuiBtn.TextSize = 13
Instance.new("UICorner", ToggleGuiBtn)

-- Janela Principal (Arredondada e Arrastável)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Active = true
MainFrame.Draggable = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

-- Barra Superior (Título e Fechar)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Troll Hub - Master Mobile"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sistema de Abas (Navegação Compacta)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.Size = UDim2.new(1, 0, 0, 30)

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Padding = UDim.new(0, 5)

-- Container Geral de Páginas
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 0, 0, 75)
PageContainer.Size = UDim2.new(1, 0, 1, -75)

local function createPage()
    local scroll = Instance.new("ScrollingFrame", PageContainer)
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
    scroll.ScrollBarThickness = 4
    scroll.Visible = false
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    return scroll
end

local PageAlvo = createPage()
local PageTroll = createPage()
local PageGears = createPage()
PageAlvo.Visible = true -- Página inicial padrão

local function switchPage(targetPage)
    PageAlvo.Visible = false
    PageTroll.Visible = false
    PageGears.Visible = false
    targetPage.Visible = true
end

-- Botões das Abas
local function createTabButton(name, targetPage)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Size = UDim2.new(0.31, 0, 0.8, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        switchPage(targetPage)
    end)
end

createTabButton("1. Alvo", PageAlvo)
createTabButton("2. Troll/TP", PageTroll)
createTabButton("3. Gears", PageGears)

-- ================= PAGE 1: SELEÇÃO DE ALVO (Única para todo o Hub) =================
local function createSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.9, 0, 0, 25)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 100, 100)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

createSectionTitle(PageAlvo, "Alvo Selecionado Atualmente:")

local TargetDisplay = Instance.new("TextLabel", PageAlvo)
TargetDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TargetDisplay.Size = UDim2.new(0.9, 0, 0, 32)
TargetDisplay.Font = Enum.Font.SourceSansBold
TargetDisplay.Text = "Nenhum alvo selecionado"
TargetDisplay.TextColor3 = Color3.fromRGB(255, 255, 100)
TargetDisplay.TextSize = 13
Instance.new("UICorner", TargetDisplay).CornerRadius = UDim.new(0, 6)

createSectionTitle(PageAlvo, "Lista de Jogadores no Servidor (Toque para escolher):")

local PlayerListScroll = Instance.new("ScrollingFrame", PageAlvo)
PlayerListScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerListScroll.Size = UDim2.new(0.9, 0, 0, 260)
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
PlayerListScroll.ScrollBarThickness = 4
Instance.new("UICorner", PlayerListScroll).CornerRadius = UDim.new(0, 6)

local UIListPlayers = Instance.new("UIListLayout", PlayerListScroll)
UIListPlayers.SortOrder = Enum.SortOrder.LayoutOrder
UIListPlayers.Padding = UDim.new(0, 4)

local function refreshPlayerList()
    for _, child in ipairs(PlayerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerListScroll)
            pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            pBtn.Size = UDim2.new(1, -4, 0, 30)
            pBtn.Font = Enum.Font.SourceSans
            pBtn.Text = " " .. plr.Name .. " (ID: " .. plr.UserId .. ")"
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 12
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            
            pBtn.MouseButton1Click:Connect(function()
                selectedTargetPlayer = plr
                activeLoopTarget = plr -- Integrado com o sistema de LoopGoto também
                TargetDisplay.Text = "Alvo: " .. plr.Name .. " [" .. plr.UserId .. "]"
            end)
        end
    end
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)


-- ================= PAGE 2: FUNÇÕES DE TROLL E TELEPORTE =================
createSectionTitle(PageTroll, "Controles de Troller e Alvo:")

-- Função de Teleporte em Passos Segura
local function tweenTeleportTo(targetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isTeleporting then return end

    isTeleporting = true
    local noclip = RunService.Stepped:Connect(function()
        if char and char.Parent then
            for _, p in ipairs(char:GetDescendants()) do 
                if p:IsA("BasePart") then p.CanCollide = false end 
            end
        end
    end)

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenTime = math.clamp(distance / 400, 0.1, 15)
    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    pcall(function() tween.Completed:Wait() end)

    if noclip then noclip:Disconnect() end
    isTeleporting = false
end

-- Gerenciador do LoopGoto Seguro
local function startLoopGoto()
    if loopTask then task.cancel(loopTask) end
    loopTask = task.spawn(function()
        while loopGotoEnabled and activeLoopTarget do
            local tChar = activeLoopTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                tweenTeleportTo(tRoot.CFrame + Vector3.new(0, 3, 0))
            end
            task.wait(0.5)
        end
    end)
end

-- Botão 1: LoopGoto / Teleporte Contínuo ao Alvo
local LoopGotoBtn = Instance.new("TextButton", PageTroll)
LoopGotoBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
LoopGotoBtn.Size = UDim2.new(0.9, 0, 0, 36)
LoopGotoBtn.Font = Enum.Font.SourceSansBold
LoopGotoBtn.Text = "LoopGoto (Teleporte p/ Alvo): DESLIGADO"
LoopGotoBtn.TextColor3 = Color3.new(1, 1, 1)
LoopGotoBtn.TextSize = 13
Instance.new("UICorner", LoopGotoBtn).CornerRadius = UDim.new(0, 6)

LoopGotoBtn.MouseButton1Click:Connect(function()
    if not selectedTargetPlayer then
        TargetDisplay.Text = "ERRO: Selecione um alvo na Aba 1!"
        return
    end
    loopGotoEnabled = not loopGotoEnabled
    if loopGotoEnabled then
        LoopGotoBtn.Text = "LoopGoto (Teleporte p/ Alvo): LIGADO"
        LoopGotoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        activeLoopTarget = selectedTargetPlayer
        startLoopGoto()
    else
        LoopGotoBtn.Text = "LoopGoto (Teleporte p/ Alvo): DESLIGADO"
        LoopGotoBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        if loopTask then task.cancel(loopTask) loopTask = nil end
    end
end)

-- Botão 2: Freeze Loop (Drone UAV)
local FreezeToggleBtn = Instance.new("TextButton", PageTroll)
FreezeToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
FreezeToggleBtn.Size = UDim2.new(0.9, 0, 0, 36)
FreezeToggleBtn.Font = Enum.Font.SourceSansBold
FreezeToggleBtn.Text = "Freeze Loop (Drone): OFF"
FreezeToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FreezeToggleBtn.TextSize = 13
Instance.new("UICorner", FreezeToggleBtn).CornerRadius = UDim.new(0, 6)

FreezeToggleBtn.MouseButton1Click:Connect(function()
    if not selectedTargetPlayer then
        TargetDisplay.Text = "ERRO: Selecione um alvo na Aba 1!"
        return
    end

    giftFreezeActive = not giftFreezeActive
    if giftFreezeActive then
        FreezeToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        FreezeToggleBtn.Text = "Freeze Loop (Drone): ON"
        
        task.spawn(function()
            while giftFreezeActive do
                if selectedTargetPlayer and selectedTargetPlayer.Parent and selectedTargetPlayer.UserId then
                    local args = {
                        GiftBox = "UAV",
                        TargetUserId = selectedTargetPlayer.UserId,
                        Action = "GiveGift",
                        ToolId = selectedToolId
                    }
                    pcall(function() InteractGiftRE:FireServer(args) end)
                    task.wait(3.5)
                else
                    task.wait(1)
                end
            end
        end)
    else
        FreezeToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        FreezeToggleBtn.Text = "Freeze Loop (Drone): OFF"
    end
end)

-- Botão 3: LoopBring (Fantasminha)
local LoopBringBtn = Instance.new("TextButton", PageTroll)
LoopBringBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 50)
LoopBringBtn.Size = UDim2.new(0.9, 0, 0, 36)
LoopBringBtn.Font = Enum.Font.SourceSansBold
LoopBringBtn.Text = "LoopBring (Fantasminha): OFF"
LoopBringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopBringBtn.TextSize = 13
Instance.new("UICorner", LoopBringBtn).CornerRadius = UDim.new(0, 6)

LoopBringBtn.MouseButton1Click:Connect(function()
    if not selectedTargetPlayer then
        TargetDisplay.Text = "ERRO: Selecione um alvo na Aba 1!"
        return
    end

    loopBringActive = not loopBringActive
    if loopBringActive then
        LoopBringBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        LoopBringBtn.Text = "LoopBring (Fantasminha): ON"
        
        task.spawn(function()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not loopBringActive then
                    connection:Disconnect()
                    return
                end
                pcall(function()
                    if selectedTargetPlayer.Character and selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHRP = selectedTargetPlayer.Character.HumanoidRootPart
                            local myHRP = LocalPlayer.Character.HumanoidRootPart
                            targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
                        end
                    end
                end)
            end)
        end)
    else
        LoopBringBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 50)
        LoopBringBtn.Text = "LoopBring (Fantasminha): OFF"
    end
end)

-- Botão 4: Spawnar Carro de Teste
local SpawnCarBtn = Instance.new("TextButton", PageTroll)
SpawnCarBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
SpawnCarBtn.Size = UDim2.new(0.9, 0, 0, 36)
SpawnCarBtn.Font = Enum.Font.SourceSansBold
SpawnCarBtn.Text = "Spawnar Carro (GTA_Car_10)"
SpawnCarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnCarBtn.TextSize = 13
Instance.new("UICorner", SpawnCarBtn).CornerRadius = UDim.new(0, 6)

SpawnCarBtn.MouseButton1Click:Connect(function()
    pcall(function() SpawnVehiclesRE:FireServer("GTA_Car_10") end)
end)


-- ================= PAGE 3: HUB DE GEARS / AUTO EQUIP =================
createSectionTitle(PageGears, "Gerenciador Automático de Gears e Bug:")

local function deactivateAllExcept(currentGroup)
    for _, g in ipairs(GearGroups) do
        if g.Name ~= currentGroup.Name and g.Active then
            g.Active = false
        end
    end
end

local function startGearsLoop(g)
    task.spawn(function()
        while g.Active do
            for _, id in ipairs(g.Gears) do
                if not g.Active then break end
                AvatarMainRE:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(0.2)
            end
            task.wait(5)
        end
    end)
end

local function executeInvisBug(g)
    task.spawn(function()
        if not g.Active then return end
        local char = LocalPlayer.Character
        if char then
            local ff = char:FindFirstChild("ForceField")
            while ff and g.Active do
                task.wait(0.5)
                ff = char:FindFirstChild("ForceField")
            end
        end
        if not g.Active then return end
        task.wait(0.5)
        if not g.Active then return end

        AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "equip", ["equiptype"] = "Gear"})
        
        local elapsed = 0
        while elapsed < 2.0 and g.Active do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end

        if g.Active then
            AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
        end
    end)
end

-- Construção dos Botões de Gears com Chave ON/OFF lateral
for _, g in ipairs(GearGroups) do
    local GearContainer = Instance.new("Frame", PageGears)
    GearContainer.BackgroundTransparency = 1
    GearContainer.Size = UDim2.new(0.9, 0, 0, 42)

    local btn = Instance.new("TextButton", GearContainer)
    btn.BackgroundColor3 = g.Color
    btn.Size = UDim2.new(0.72, 0, 1, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = g.Name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local toggleKey = Instance.new("TextButton", GearContainer)
    toggleKey.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    toggleKey.Position = UDim2.new(0.76, 0, 0, 0)
    toggleKey.Size = UDim2.new(0.24, 0, 1, 0)
    toggleKey.Font = Enum.Font.SourceSansBold
    toggleKey.Text = "OFF"
    toggleKey.TextColor3 = Color3.new(1, 1, 1)
    toggleKey.TextSize = 12
    Instance.new("UICorner", toggleKey).CornerRadius = UDim.new(0, 6)

    local function updateKeyVisual()
        if g.Active then
            toggleKey.Text = "ON"
            toggleKey.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            toggleKey.Text = "OFF"
            toggleKey.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        end
    end

    local function toggleGroupState()
        g.Active = not g.Active
        if g.Active then
            deactivateAllExcept(g)
            if g.Special then executeInvisBug(g) else startGearsLoop(g) end
        else
            if g.Special then
                AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end
        updateKeyVisual()
    end

    btn.MouseButton1Click:Connect(toggleGroupState)
    toggleKey.MouseButton1Click:Connect(toggleGroupState)
end

-- Reconexão do Bug da Capa ao Renascer
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    for _, g in ipairs(GearGroups) do
        if g.Active and g.Special then
            executeInvisBug(g)
        end
    end
end)
