-- HUB DE EQUIPAMENTO E GERENCIAMENTO DE ESTADO - MOBILE VERSION (FIXED)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local p = Players.LocalPlayer
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
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true 

-- Botão para Abrir/Fechar a Interface
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleGuiBtn.Position = UDim2.new(0.5, -20, 0, 10)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleGuiBtn.Text = "MENU"
ToggleGuiBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleGuiBtn.Font = Enum.Font.SourceSansBold
ToggleGuiBtn.TextSize = 14

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Desliga loops ativos de outros grupos ao ativar um novo (Opcional, garante estabilidade)
local function deactivateAllExcept(currentGroup)
    for _, g in ipairs(Groups) do
        if g.Name ~= currentGroup.Name and g.Active then
            g.Active = false
        end
    end
end

-- Funções de Execução em Loop
local function startGearsLoop(g)
    task.spawn(function()
        while g.Active do
            for _, id in ipairs(g.Gears) do
                if not g.Active then break end
                remote:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(0.2)
            end
            task.wait(5) -- Intervalo de re-equipagem do loop global
        end
    end)
end

local function startInvisLoop(g)
    task.spawn(function()
        while g.Active do
            if p.Character then
                local ff = p.Character:FindFirstChild("ForceField")
                if ff then
                    repeat task.wait(0.5) until not p.Character:FindFirstChild("ForceField") or not g.Active
                end
                
                if not g.Active then break end
                
                remote:FireServer({["id"] = g.CapaID, ["event"] = "equip", ["equiptype"] = "Gear"})
                task.wait(2.5) 
                
                if not g.Active then 
                    remote:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
                    break 
                end
                
                remote:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
                task.wait(5) 
            end
            task.wait(1)
        end
    end)
end

-- Criação Dinâmica dos Botões com chave Liga/Desliga integrado
for i, g in ipairs(Groups) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, (i-1)*50 + 10)
    btn.BackgroundColor3 = g.Color
    btn.Text = "[OFF] " .. g.Name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    btn.MouseButton1Click:Connect(function()
        g.Active = not g.Active
        
        if g.Active then
            deactivateAllExcept(g)
            btn.Text = "[ON] " .. g.Name
            
            if g.Special then
                startInvisLoop(g)
            else
                startGearsLoop(g)
            end
        else
            btn.Text = "[OFF] " .. g.Name
            -- Se for o da capa, envia um unequip preventivo imediato ao desligar
            if g.Special then
                remote:FireServer({["id"] = g.CapaID, ["event"] = "unequip", ["equiptype"] = "Gear"})
            end
        end
        
        -- Atualiza visualmente o texto dos outros botões caso tenham sido desligados
        for _, otherBtn in ipairs(MainFrame:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                for _, groupData do
                    if "[ON] " .. groupData.Name == otherBtn.Text and not groupData.Active then
                        otherBtn.Text = "[OFF] " .. groupData.Name
                    end
                end
            end
        end
    end)
end
