local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local p = Players.LocalPlayer

local playerGui = p:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("TeleportGUI_Gears") then
    playerGui.TeleportGUI_Gears:Destroy()
end

local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- Configuração dos Grupos
local Groups = {
    {Name = "DEFESA", Color = Color3.fromRGB(52, 152, 219), Gears = {94794847, 236441643, 80661504}, Active = false},
    {Name = "ESPADAS", Color = Color3.fromRGB(231, 76, 60), Gears = {102705454, 108158379, 1208300505}, Active = false},
    {Name = "1-ATAQUE BÁSICO", Color = Color3.fromRGB(46, 204, 113), Gears = {26017478, 70476425, 1208300505}, Active = false},
    {Name = "2-ATAQUE INDIRETO", Color = Color3.fromRGB(241, 196, 15), Gears = {127506257, 108158379, 70476425}, Active = false},
    {Name = "3-ATAQUE DIRETO OP", Color = Color3.fromRGB(155, 89, 182), Gears = {127506257, 268586231, 1117745433}, Active = false},
    {Name = "INVISIBILIDADE", Color = Color3.fromRGB(149, 165, 166), Special = true, CapaID = 129471121, Active = false}
}

-- UI Setup Mobile
local ScreenGui = Instance.new("ScreenGui", playerGui)
ScreenGui.Name = "TeleportGUI_Gears"
ScreenGui.ResetOnSpawn = false

-- Botão Flutuante (Abrir/Fechar)
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 50, 0, 35)
ToggleGuiBtn.Position = UDim2.new(0.5, -25, 0, 10)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleGuiBtn.Text = "MENU"
ToggleGuiBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleGuiBtn.Font = Enum.Font.SourceSansBold
ToggleGuiBtn.TextSize = 12
Instance.new("UICorner", ToggleGuiBtn)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 330)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "HUB DE GEARS"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Instance.new("UICorner", Title)

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Desliga os outros grupos ativos
local function deactivateAllExcept(currentGroup)
    for _, g in ipairs(Groups) do
        if g.Name ~= currentGroup.Name and g.Active then
            g.Active = false
        end
    end
end

-- Loop de Equipagem para os Grupos Normais de Armas
local function startGearsLoop(g)
    task.spawn(function()
        while g.Active do
            for _, id in ipairs(g.Gears) do
                if not g.Active then break end
                remote:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(0.2)
            end
            task.wait(5)
        end
    end)
end

-- Lógica exata para a Capa (Executa uma única vez por ativação/respawn respeitando o ForceField)
local function executeInvisBug(g)
    task.spawn(function()
        if not g.Active then return end
        
        local char = p.Character
        if char then
            -- Aguarda o ForceField sumir ao renascer para o bug não falhar
            local ff = char:FindFirstChild("ForceField")
            while ff and g.Active do
                task.wait(0.5)
                ff = char:FindFirstChild("ForceField")
            end
        end

        if not g.Active then return end

        -- 1. Equipa a capa (aparece na mão com a setinha laranja)
        remote:FireServer({["id"] = g.CapaID, ["event"] = "equip", ["equiptype"] = "Gear"})
        
        -- 2. Aguarda os 2.5 segundos para você tocar na tela e ativar a invisibilidade
        local elapsed = 0
        while elapsed < 2.5 and g.Active do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end

        -- 3. Desequipa automaticamente para o bug fixar a invisibilidade
        if g.Active then
            remote:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
        end
    end)
end

-- Criação Dinâmica dos Botões com Chave Liga/Desliga Lateral
for i, g in ipairs(Groups) do
    -- Botão Principal do Grupo
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.68, 0, 0, 42)
    btn.Position = UDim2.new(0.04, 0, 0, (i-1)*46 + 38)
    btn.BackgroundColor3 = g.Color
    btn.Text = g.Name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn)

    -- Botão Chave Lateral (Liga/Desliga individual)
    local toggleKey = Instance.new("TextButton", MainFrame)
    toggleKey.Size = UDim2.new(0.2, 0, 0, 42)
    toggleKey.Position = UDim2.new(0.74, 0, 0, (i-1)*46 + 38)
    toggleKey.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    toggleKey.Text = "OFF"
    toggleKey.TextColor3 = Color3.new(1, 1, 1)
    toggleKey.Font = Enum.Font.SourceSansBold
    toggleKey.TextSize = 12
    Instance.new("UICorner", toggleKey)

    local function updateKeyVisual()
        if g.Active then
            toggleKey.Text = "ON"
            toggleKey.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            toggleKey.Text = "OFF"
            toggleKey.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        end
    end

    -- Ação ao clicar no botão do grupo ou na chave lateral
    local function toggleGroupState()
        g.Active = not g.Active
        
        if g.Active then
            deactivateAllExcept(g)
            if g.Special then
                executeInvisBug(g)
            else
                startGearsLoop(g)
            end
        else
            if g.Special then
                remote:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end
        
        -- Atualiza visualmente todas as chaves da interface
        for _, otherGroup in ipairs(Groups) do
            -- Como iteramos pelos grupos, atualizamos os estados visuais correspondentes
        end
        updateKeyVisual()
        -- Atualiza os demais botões da tela
    end

    btn.MouseButton1Click:Connect(toggleGroupState)
    toggleKey.MouseButton1Click:Connect(toggleGroupState)
end

-- Reconexão automática ao morrer e renascer (Executa o bug da capa de forma segura respeitando o ForceField)
p.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    for _, g in ipairs(Groups) do
        if g.Active and g.Special then
            executeInvisBug(g)
        end
    end
end)
