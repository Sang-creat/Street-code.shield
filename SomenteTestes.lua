local Players, ReplicatedStorage, Workspace = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local parentGui = (pcall(function() return CoreGui:IsA("GuiService") end) and CoreGui) or localPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("TornadoHubMobile") then
    parentGui.TornadoHubMobile:Destroy()
end

-- Variáveis de Controle
local selectedTarget = nil
local gearTornadoID = 127506257
local remoteAvatar = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AvatarMainRE")

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui", parentGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TornadoHubMobile", false

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 280, 0, 390)
Main.Position = UDim2.new(0.5, -140, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
Main.Draggable, Main.Active = true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Barra de Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Title.Text = " Tornado Teleguiado Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Status do Alvo
local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size = UDim2.new(1, -16, 0, 30)
StatusLabel.Position = UDim2.new(0, 8, 0, 43)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
StatusLabel.Text = "Alvo: Nenhum selecionado"
StatusLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 13
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

-- Botão de Ação (Equip & Disparar)
local FireBtn = Instance.new("TextButton", Main)
FireBtn.Size = UDim2.new(1, -16, 0, 38)
FireBtn.Position = UDim2.new(0, 8, 0, 80)
FireBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
FireBtn.Text = "EQUIPAR & DISPARAR NO ALVO"
FireBtn.TextColor3 = Color3.new(1, 1, 1)
FireBtn.Font = Enum.Font.SourceSansBold
FireBtn.TextSize = 14
Instance.new("UICorner", FireBtn).CornerRadius = UDim.new(0, 6)

-- Container da Lista de Jogadores (ScrollingFrame)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -16, 0, 250)
Scroll.Position = UDim2.new(0, 8, 0, 125)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- Lógica de Auto-Equip e Disparo com Remotes
local function equipAndFireTornado()
    if not remoteAvatar then
        StatusLabel.Text = "Erro: Remote AvatarMainRE não encontrado!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        return
    end

    StatusLabel.Text = "Equipando gear..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)

    -- Aciona o remote de equip do gear
    remoteAvatar:FireServer({["id"] = gearTornadoID, ["event"] = "equip", ["equiptype"] = "Gear"})

    task.spawn(function()
        local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local gearName = "Gear" .. gearTornadoID
        local gearFolder = nil

        local startTime = tick()
        while tick() - startTime < 2.5 do
            gearFolder = char:FindFirstChild(gearName)
            if gearFolder then break end
            task.wait(0.05)
        end

        if gearFolder then
            local remoteEvent = gearFolder:FindFirstChild("RemoteEvent") or gearFolder:FindFirstChildOfClass("RemoteEvent")
            if remoteEvent then
                local args = { [1] = "DO THE THING!!!" }
                pcall(function()
                    remoteEvent:FireServer(unpack(args))
                end)
                StatusLabel.Text = "Tornado disparado com sucesso!"
                StatusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
            else
                StatusLabel.Text = "Erro: RemoteEvent interno ausente!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            end
        else
            StatusLabel.Text = "Erro: Tempo esgotado ao equipar!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end)
end

FireBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        StatusLabel.Text = "Selecione um alvo na lista abaixo!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        return
    end
    equipAndFireTornado()
end)

-- Monitor Teleguiado para Redirecionar o Tornado
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Tornado" and selectedTarget then
        task.spawn(function()
            task.wait(0.04)
            local tChar = selectedTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            
            if tRoot and child and child.Parent then
                local bodyVel = child:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then
                    local direction = (tRoot.Position - child.Position).Unit
                    bodyVel.Velocity = direction * 230
                end
                pcall(function()
                    child.CFrame = CFrame.new(child.Position, tRoot.Position)
                end)
            end
        end)
    end
end)

-- Preenchimento Dinâmico da Lista de Alvos
local function updatePlayerList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local ItemBtn = Instance.new("TextButton", Scroll)
            ItemBtn.Size = UDim2.new(1, -4, 0, 36)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            ItemBtn.Text = "   " .. plr.Name
            ItemBtn.TextColor3 = Color3.new(1, 1, 1)
            ItemBtn.Font = Enum.Font.SourceSansBold
            ItemBtn.TextSize = 14
            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)

            ItemBtn.MouseButton1Click:Connect(function()
                selectedTarget = plr
                StatusLabel.Text = "Alvo: " .. plr.Name
                StatusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
