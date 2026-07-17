-- HUB DE EQUIPAMENTO E GERENCIAMENTO DE ESTADO - MOBILE VERSION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local p = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AvatarMainRE")

-- Configuração dos Grupos
local Groups = {
    {Name = "DEFESA", Color = Color3.fromRGB(52, 152, 219), Gears = {94794847, 236441643, 80661504}},
    {Name = "ESPADAS", Color = Color3.fromRGB(231, 76, 60), Gears = {102705454, 108158379, 1208300505}},
    {Name = "1-ATAQUE BÁSICO", Color = Color3.fromRGB(46, 204, 113), Gears = {26017478, 70476425, 1208300505}},
    {Name = "2-ATAQUE INDIRETO", Color = Color3.fromRGB(241, 196, 15), Gears = {127506257, 108158379, 70476425}},
    {Name = "3-ATAQUE DIRETO OP", Color = Color3.fromRGB(155, 89, 182), Gears = {127506257, 268586231, 1117745433}},
    {Name = "INVISIBILIDADE", Color = Color3.fromRGB(149, 165, 166), Special = true, CapaID = 129471121}
}

-- Variável Global de Estado
_G.ActiveGroup = nil

-- Função de Equipar comum
local function equipSet(gears)
    for _, id in ipairs(gears) do
        remote:FireServer({["id"] = id, ["event"] = "equip", ["equiptype"] = "Gear"})
        task.wait(0.2)
    end
end

-- Lógica Especial da Capa (Grupo 6)
local function handleInvis()
    while _G.ActiveGroup == "INVISIBILIDADE" do
        if p.Character then
            -- Espera o ForceField acabar para não bugar o estado
            local ff = p.Character:FindFirstChild("ForceField")
            if ff then
                repeat task.wait(0.5) until not p.Character:FindFirstChild("ForceField")
            end
            
            -- Equipa a capa
            remote:FireServer({["id"] = 129471121, ["event"] = "equip", ["equiptype"] = "Gear"})
            task.wait(2.5) -- Tempo para bugar a invisibilidade
            -- Remove a capa para manter o estado bugado
            remote:FireServer({["id"] = 129471121, ["event"] = "unequip", ["equiptype"] = "Gear"})
            
            task.wait(5) -- Delay de segurança
        end
        task.wait(1)
    end
end

-- UI Setup Mobile
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 350)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true 

-- Criação dos Botões
for i, g in ipairs(Groups) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, (i-1)*50 + 10)
    btn.BackgroundColor3 = g.Color
    btn.Text = g.Name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        _G.ActiveGroup = g.Name
        if g.Special then
            task.spawn(handleInvis)
        else
            equipSet(g.Gears)
        end
    end)
end
