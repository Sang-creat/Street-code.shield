-- ==========================================
-- SCRIPT: TROLL HUB MOBILE - MASTER + COMBATE + 5ª ABA (TORNADOS E PAINTBALL) [CORRIGIDO]
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Remotes (Com verificação segura)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local InteractGiftRE = Remotes and Remotes:FindFirstChild("InteractGiftRE")
local SpawnVehiclesRE = Remotes and Remotes:FindFirstChild("SpawnVehiclesRE")
local AvatarMainRE = Remotes and Remotes:FindFirstChild("AvatarMainRE")

-- Variáveis de Estado Globais (Toggles)
local giftFreezeActive = false
local loopBringActive = false
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopTask = nil
local isTeleporting = false
local selectedTargetPlayer = nil

-- Variáveis do Sistema de Combate / Reach
local reachValue = 5
local boxReachValue = 1000
local handlerValue = 1000

local reachActive = false
local boxReachActive = false
local handlerActive = false

local reachConnection = nil
local boxReachConnection = nil
local handlerConnection = nil

-- Variáveis de Estado da 5ª Aba (Super Ring 1, Super Ring 2, Paintball)
local isTornado1Enabled = false
local tornado1StoppedTime = 0
local tornado1AimConn = nil

local isTornado2Running = false
local isWaitingTornado2 = false

local isPaintballEnabled = false
local paintballStoppedTime = 0
local paintballAimConn = nil

-- Grupos de Gears
local GearGroups = {
    {Name = "DEFESA", Color = Color3.fromRGB(52, 152, 219), Gears = {94794847, 236441643, 80661504}, Active = false},
    {Name = "ESPADAS", Color = Color3.fromRGB(231, 76, 60), Gears = {99119240, 93136746, 108158379, 268586231}, Active = false},
    {Name = "1-ATAQUE BÁSICO", Color = Color3.fromRGB(46, 204, 113), Gears = {26017478, 70476425, 1208300505}, Active = false},
    {Name = "2-ATAQUE INDIRETO", Color = Color3.fromRGB(241, 196, 15), Gears = {127506257, 108158379, 70476425}, Active = false},
    {Name = "3-ATAQUE DIRETO OP", Color = Color3.fromRGB(155, 89, 182), Gears = {127506257, 268586231, 1117745433}, Active = false},
    {Name = "INVISIBILIDADE", Color = Color3.fromRGB(149, 165, 166), Special = true, CapaID = 129471121, Active = false}
}

-- Remove GUI anterior se já existir
if CoreGui:FindFirstChild("TrollHubMobile") then
    CoreGui.TrollHubMobile:Destroy()
end

-- Criação da ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHubMobile"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botão Flutuante
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 60, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ToggleGuiBtn.Text = "HUB"
ToggleGuiBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleGuiBtn.Font = Enum.Font.SourceSansBold
ToggleGuiBtn.TextSize = 13
Instance.new("UICorner", ToggleGuiBtn)

-- Janela Principal
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

-- Barra Superior
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

-- Sistema de Abas
local TabBar = Instance.new("Frame", MainFrame)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.Size = UDim2.new(1, 0, 0, 30)

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Padding = UDim.new(0, 2)

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
    return scroll, layout
end

local PageAlvo = createPage()
local PageTroll = createPage()
local PageGears = createPage()
local PageCombat, CombatLayout = createPage()
local PageExtra, ExtraLayout = createPage()
PageAlvo.Visible = true

local function switchPage(targetPage)
    PageAlvo.Visible = false
    PageTroll.Visible = false
    PageGears.Visible = false
    PageCombat.Visible = false
    PageExtra.Visible = false
    targetPage.Visible = true
end

local function createTabButton(name, targetPage)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Size = UDim2.new(0.19, 0, 0.8, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        switchPage(targetPage)
    end)
end

createTabButton("1.Alvo", PageAlvo)
createTabButton("2.Troll", PageTroll)
createTabButton("3.Gears", PageGears)
createTabButton("4.Comb", PageCombat)
createTabButton("5.Extra", PageExtra)

-- ================= PAGE 1: SELEÇÃO DE ALVO =================
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

createSectionTitle(PageAlvo, "Lista de Jogadores no Servidor:")

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
                activeLoopTarget = plr
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
                if selectedTargetPlayer and selectedTargetPlayer.Parent and selectedTargetPlayer.UserId and InteractGiftRE then
                    local args = {
                        GiftBox = "UAV",
                        TargetUserId = selectedTargetPlayer.UserId,
                        Action = "GiveGift",
                        ToolId = "CupCoffee"
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

local SpawnCarBtn = Instance.new("TextButton", PageTroll)
SpawnCarBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
SpawnCarBtn.Size = UDim2.new(0.9, 0, 0, 36)
SpawnCarBtn.Font = Enum.Font.SourceSansBold
SpawnCarBtn.Text = "Spawnar Carro (GTA_Car_10)"
SpawnCarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnCarBtn.TextSize = 13
Instance.new("UICorner", SpawnCarBtn).CornerRadius = UDim.new(0, 6)

SpawnCarBtn.MouseButton1Click:Connect(function()
    if SpawnVehiclesRE then
        pcall(function() SpawnVehiclesRE:FireServer("GTA_Car_10") end)
    end
end)

-- ================= PAGE 3: HUB DE GEARS =================
createSectionTitle(PageGears, "Gerenciador Automático de Gears:")

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
                if AvatarMainRE then
                    pcall(function() AvatarMainRE:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"}) end)
                end
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
        if not g.Active or not AvatarMainRE then return end
        task.wait(0.5)
        if not g.Active then return end

        pcall(function() AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "equip", ["equiptype"] = "Gear"}) end)
        
        local elapsed = 0
        while elapsed < 2.0 and g.Active do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end

        if g.Active then
            pcall(function() AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"}) end)
        end
    end)
end

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
            if g.Special and AvatarMainRE then
                pcall(function() AvatarMainRE:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"}) end)
            end
        end
        updateKeyVisual()
    end

    btn.MouseButton1Click:Connect(toggleGroupState)
    toggleKey.MouseButton1Click:Connect(toggleGroupState)
end

-- ================= PAGE 4: COMBATE / REACH CONTROLLER =================
createSectionTitle(PageCombat, "Configurações de Combate e Alcance:")

local function safeFireTouch(handle, hrp)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(handle, hrp, 0)
            firetouchinterest(handle, hrp, 1)
        end)
    else
        pcall(function()
            if handle and hrp then
                handle.CFrame = hrp.CFrame
            end
        end)
    end
end

local function getEquippedTool()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
end

local function startReach()
    if reachConnection then reachConnection:Disconnect() end
    reachConnection = RunService.Heartbeat:Connect(function()
        if not reachActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local distance = (handle.Position - hrp.Position).Magnitude
                    if distance <= reachValue then
                        safeFireTouch(handle, hrp)
                    end
                end
            end
        end
    end)
end

local function startBoxReach()
    if boxReachConnection then boxReachConnection:Disconnect() end
    boxReachConnection = RunService.Heartbeat:Connect(function()
        if not boxReachActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local distance = (handle.Position - hrp.Position).Magnitude
                    if distance <= boxReachValue then
                        safeFireTouch(handle, hrp)
                    end
                end
            end
        end
    end)
end

local function startHandlerSkill()
    if handlerConnection then handlerConnection:Disconnect() end
    handlerConnection = RunService.Heartbeat:Connect(function()
        if not handlerActive then return end
        local tool = getEquippedTool()
        if tool and tool:FindFirstChild("Handle") and selectedTargetPlayer and selectedTargetPlayer.Parent then
            local targetChar = selectedTargetPlayer.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local handle = tool.Handle
                local hrp = targetChar.HumanoidRootPart
                local distance = (handle.Position - hrp.Position).Magnitude
                if distance <= handlerValue then
                    safeFireTouch(handle, hrp)
                end
            end
        end
    end)
end

local function createCombatRow(nameLabel, defaultValue, toggleCallback, textCallback)
    local RowFrame = Instance.new("Frame", PageCombat)
    RowFrame.Size = UDim2.new(0.9, 0, 0, 50)
    RowFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", RowFrame)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Text = nameLabel
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local TextBox = Instance.new("TextBox", RowFrame)
    TextBox.Size = UDim2.new(0, 65, 0, 32)
    TextBox.Position = UDim2.new(0.52, 0, 0.15, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    TextBox.Text = tostring(defaultValue)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 13
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
    
    TextBox.FocusLost:Connect(function()
        local num = tonumber(TextBox.Text)
        if num then
            textCallback(num)
        end
    end)
    
    local ToggleBtn = Instance.new("TextButton", RowFrame)
    ToggleBtn.Size = UDim2.new(0, 85, 0, 32)
    ToggleBtn.Position = UDim2.new(0.74, 0, 0.15, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 12
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
    
    local activeState = false
    ToggleBtn.MouseButton1Click:Connect(function()
        if nameLabel:find("Handler") and not selectedTargetPlayer then
            TargetDisplay.Text = "ERRO: Selecione um alvo na Aba 1!"
            return
        end
        
        activeState = not activeState
        if activeState then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
            ToggleBtn.Text = "ON"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            ToggleBtn.Text = "OFF"
        end
        toggleCallback(activeState)
    end)
end

createCombatRow("Reach Padrão", reachValue, function(state)
    reachActive = state
    if state then startReach() end
end, function(val)
    reachValue = val
end)

createCombatRow("Box Reach", boxReachValue, function(state)
    boxReachActive = state
    if state then startBoxReach() end
end, function(val)
    boxReachValue = val
end)

createCombatRow("Handler Skill", handlerValue, function(state)
    handlerActive = state
    if state then startHandlerSkill() end
end, function(val)
    handlerValue = val
end)

-- ================= PAGE 5: FUNÇÕES EXTRAS =================
createSectionTitle(PageExtra, "Funções Especiais (Dependem da Aba 1):")

-- Super Ring 1
local function equipGearTornado1()
    if AvatarMainRE then
        pcall(function()
            AvatarMainRE:FireServer({
                ["id"] = 102705454,
                ["event"] = "equip",
                ["equiptype"] = "Gear"
            })
        end)
    end
end

if tornado1AimConn then tornado1AimConn:Disconnect() end
tornado1AimConn = RunService.RenderStepped:Connect(function(dt)
    if isTornado1Enabled and selectedTargetPlayer and selectedTargetPlayer.Character then
        local targetChar = selectedTargetPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if targetRoot and myRoot and humanoid then
            local isMoving = humanoid.MoveDirection.Magnitude > 0.1
            if isMoving then
                tornado1StoppedTime = 0
            else
                tornado1StoppedTime = tornado1StoppedTime + dt
                if tornado1StoppedTime >= 0.5 then
                    local currentPos = myRoot.Position
                    local lookAtPos = Vector3.new(targetRoot.Position.X, currentPos.Y, targetRoot.Position.Z)
                    if (lookAtPos - currentPos).Magnitude > 1 then
                        local targetCFrame = CFrame.lookAt(currentPos, lookAtPos)
                        myRoot.CFrame = myRoot.CFrame:Lerp(targetCFrame, math.clamp(dt * 6, 0, 1))
                    end
                end
            end
        end
    else
        tornado1StoppedTime = 0
    end
end)

local function startTornado1Routine()
    task.spawn(function()
        while isTornado1Enabled do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid", 5)
            
            if humanoid then
                task.wait(1.5)
                if not isTornado1Enabled then break end
                
                equipGearTornado1()
                task.wait(1)
                
                while isTornado1Enabled and humanoid.Health > 0 and LocalPlayer.Character == char do
                    local currentTool = char:FindFirstChildOfClass("Tool")
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    
                    local hasGear = false
                    if currentTool then
                        hasGear = true
                    elseif backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                hasGear = true
                                break
                            end
                        end
                    end
                    
                    if not hasGear then
                        equipGearTornado1()
                    end
                    
                    task.wait(2)
                    if not isTornado1Enabled or humanoid.Health <= 0 or LocalPlayer.Character ~= char then break end
                    
                    currentTool = char:FindFirstChildOfClass("Tool")
                    if currentTool then
                        currentTool:Activate()
                    end
                    
                    task.spawn(function()
                        local radius = 10 
                        local angle = tick() * 5 

                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if (obj.Name == "TornadoMesh" or obj:FindFirstChild("TornadoMesh")) and not obj:GetAttribute("CircularSet") then
                                obj:SetAttribute("CircularSet", true)
                                local myChar = LocalPlayer.Character
                                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                
                                if myRoot and obj:IsA("BasePart") then
                                    local offsetX = math.cos(angle) * radius
                                    local offsetZ = math.sin(angle) * radius
                                    local targetPos = myRoot.Position + Vector3.new(offsetX, 0, offsetZ)
                                    obj.CFrame = CFrame.new(targetPos)
                                end

                                local mesh = obj:FindFirstChild("Mesh") or obj:FindFirstChildWhichIsA("SpecialMesh")
                                if mesh and not mesh:GetAttribute("ScaledCustom") then
                                    mesh:SetAttribute("ScaledCustom", true)
                                    mesh.Scale = Vector3.new(7, 9, 7)
                                end
                            end
                        end
                    end)
                end
            end
            
            if isTornado1Enabled and humanoid then
                pcall(function()
                    humanoid.Died:Wait()
                end)
            end
            task.wait(1)
        end
    end)
end

-- Super Ring 2
local GEAR_ID_2 = 127506257
local GEAR_NAME_STR_2 = "Gear" .. GEAR_ID_2

local function equipGearTornado2()
    if not AvatarMainRE then return end
    local args = {
        [1] = {
            ["id"] = GEAR_ID_2,
            ["event"] = "equip",
            ["equiptype"] = "Gear"
        }
    }
    pcall(function()
        AvatarMainRE:FireServer(unpack(args))
    end)
end

local function fireGearPower2()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild(GEAR_NAME_STR_2) then
        local gearItem = character[GEAR_NAME_STR_2]
        local remoteEvent = gearItem:FindFirstChild("RemoteEvent")
        if remoteEvent then
            pcall(function()
                remoteEvent:FireServer("DO THE THING!!!")
            end)
        end
    end
end

local function aimAtTarget2(targetPlayer)
    pcall(function()
        local char = LocalPlayer.Character
        local targetChar = targetPlayer and targetPlayer.Character
        if char and targetChar then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
            
            if rootPart and targetRoot then
                local targetPos = targetRoot.Position
                local currentPos = rootPart.Position
                local lookAtPos = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
                rootPart.CFrame = CFrame.new(currentPos, lookAtPos)
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        if isTornado2Running then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild(GEAR_NAME_STR_2) then
                equipGearTornado2()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if isTornado2Running and selectedTargetPlayer and selectedTargetPlayer.Character and not isWaitingTornado2 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(GEAR_NAME_STR_2) then
                isWaitingTornado2 = true
                aimAtTarget2(selectedTargetPlayer)
                task.wait(0.1)
                fireGearPower2()
                
                local waitTime = 0
                while waitTime < 1.3 and isTornado2Running do
                    task.wait(0.1)
                    waitTime = waitTime + 0.1
                end
                isWaitingTornado2 = false
            end
        end
    end
end)

-- Paintball
local GEAR_ID_PB = 26017478

local function equipGearPaintball()
    if AvatarMainRE then
        pcall(function()
            AvatarMainRE:FireServer({
                ["id"] = GEAR_ID_PB,
                ["event"] = "equip",
                ["equiptype"] = "Gear"
            })
        end)
    end
end

if paintballAimConn then paintballAimConn:Disconnect() end
paintballAimConn = RunService.RenderStepped:Connect(function(dt)
    if isPaintballEnabled and selectedTargetPlayer and selectedTargetPlayer.Character then
        local targetChar = selectedTargetPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if targetRoot and myRoot and humanoid then
            local isMoving = humanoid.MoveDirection.Magnitude > 0.1
            if isMoving then
                paintballStoppedTime = 0
            else
                paintballStoppedTime = paintballStoppedTime + dt
                if paintballStoppedTime >= 0.5 then
                    local currentPos = myRoot.Position
                    local lookAtPos = Vector3.new(targetRoot.Position.X, currentPos.Y, targetRoot.Position.Z)
                    if (lookAtPos - currentPos).Magnitude > 1 then
                        local targetCFrame = CFrame.lookAt(currentPos, lookAtPos)
                        myRoot.CFrame = myRoot.CFrame:Lerp(targetCFrame, math.clamp(dt * 6, 0, 1))
                    end
                end
            end
        end
    else
        paintballStoppedTime = 0
    end
end)

local function startPaintballRoutine()
    task.spawn(function()
        while isPaintballEnabled do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid", 5)
            
            if humanoid then
                task.wait(1.5)
                if not isPaintballEnabled then break end
                
                equipGearPaintball()
                task.wait(1)
                
                while isPaintballEnabled and humanoid.Health > 0 and LocalPlayer.Character == char do
                    task.wait(0.1)
                    if not isPaintballEnabled or humanoid.Health <= 0 or LocalPlayer.Character ~= char then break end
                    
                    if selectedTargetPlayer and selectedTargetPlayer.Character then
                        local targetRoot = selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local gearTool = nil
                        
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") and (item.Name:match(tostring(GEAR_ID_PB)) or item:FindFirstChild("WeaponEvent")) then
                                gearTool = item
                                break
                            end
                        end
                        
                        if not gearTool then
                            gearTool = char:FindFirstChildOfClass("Tool")
                        end
                        
                        if targetRoot and gearTool then
                            local weaponEvent = gearTool:FindFirstChild("WeaponEvent")
                            if weaponEvent then
                                pcall(function()
                                    weaponEvent:FireServer(targetRoot.Position)
                                end)
                            end
                        end
                    end
                end
            end
            
            if isPaintballEnabled and humanoid then
                pcall(function()
                    humanoid.Died:Wait()
                end)
            end
            task.wait(2)
            if isPaintballEnabled then
                equipGearPaintball()
            end
        end
    end)
end

-- Criação dos botões da 5ª Aba
local function createExtraRow(nameLabel, toggleCallback)
    local RowFrame = Instance.new("Frame", PageExtra)
    RowFrame.Size = UDim2.new(0.9, 0, 0, 42)
    RowFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", RowFrame)
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Text = nameLabel
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local ToggleBtn = Instance.new("TextButton", RowFrame)
    ToggleBtn.Size = UDim2.new(0, 110, 0, 34)
    ToggleBtn.Position = UDim2.new(0.58, 0, 0.1, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 12
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
    
    local activeState = false
    ToggleBtn.MouseButton1Click:Connect(function()
        if not selectedTargetPlayer then
            TargetDisplay.Text = "ERRO: Selecione um alvo na Aba 1!"
            return
        end
        
        activeState = not activeState
        if activeState then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
            ToggleBtn.Text = "ON"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            ToggleBtn.Text = "OFF"
        end
        toggleCallback(activeState)
    end)
end

createExtraRow("Super Ring 1", function(state)
    isTornado1Enabled = state
    if state then
        startTornado1Routine()
    else
        tornado1StoppedTime = 0
    end
end)

createExtraRow("Super Ring 2", function(state)
    isTornado2Running = state
    if not state then
        isWaitingTornado2 = false
    end
end)

createExtraRow("Paintball", function(state)
    isPaintballEnabled = state
    if state then
        startPaintballRoutine()
    else
        paintballStoppedTime = 0
    end
end)

PageCombat.CanvasSize = UDim2.new(0, 0, 0, CombatLayout.AbsoluteContentSize.Y + 20)
PageExtra.CanvasSize = UDim2.new(0, 0, 0, ExtraLayout.AbsoluteContentSize.Y + 20)
