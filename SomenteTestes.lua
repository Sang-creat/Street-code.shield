-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local espContainer = nil
local updateConnection = nil

-- Criar a Interface Gráfica (Botão Flutuante) automaticamente
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IY_ESP_GUI"
screenGui.ResetOnSpawn = false

-- Proteção para injetar no CoreGui (funciona em executores mobile como Delta)
pcall(function()
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Botão de Ligar/Desligar
local textButton = Instance.new("TextButton")
textButton.Name = "ToggleButton"
textButton.Size = UDim2.new(0, 120, 0, 45)
textButton.Position = UDim2.new(0, 50, 0, 50) -- Posição no canto superior esquerdo (você pode arrastar se preferir)
textButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
textButton.TextSize = 16
textButton.Font = Enum.Font.SourceSansBold
textButton.Text = "ESP: OFF"
textButton.Active = true
textButton.Draggable = true -- Permite arrastar o botão pela tela no mobile!
textButton.Parent = screenGui

-- Arredondar as bordas do botão para ficar bonito
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = textButton

-- Função para criar a estrutura visual do ESP
local function createIYTag(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		local root = char:WaitForChild("HumanoidRootPart", 3)
		local hum = char:WaitForChild("Humanoid", 3)
		if not root or not hum or not espContainer then return end

		-- Cria ou limpa tag existente no container
		local existing = espContainer:FindFirstChild(player.Name)
		if existing then existing:Destroy() end

		-- Estrutura de BillboardGui
		local billboard = Instance.new("BillboardGui")
		billboard.Name = player.Name
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.Adornee = root
		billboard.Parent = espContainer

		-- Label de Nome/Nick
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextSize = 14
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.Parent = billboard

		-- Label de Informações (HP e Distância)
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
		infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
		infoLabel.BackgroundTransparency = 1
		infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		infoLabel.TextStrokeTransparency = 0
		infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		infoLabel.TextSize = 13
		infoLabel.Font = Enum.Font.SourceSansBold
		infoLabel.Parent = billboard

		-- Loop de atualização em tempo real
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not espEnabled or not billboard or not billboard.Parent or not char:IsDescendantOf(workspace) then
				connection:Disconnect()
				return
			end

			local localChar = LocalPlayer.Character
			local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

			if root and hum and localRoot then
				local distance = math.floor((root.Position - localRoot.Position).Magnitude)
				local hp = math.floor(hum.Health)
				infoLabel.Text = "HP: " .. hp .. " | Dist: " .. distance .. " studs"
			else
				infoLabel.Text = "HP: N/A | Dist: N/A studs"
			end
		end)
	end

	if player.Character then
		task.spawn(setupCharacter, player.Character)
	end
	player.CharacterAdded:Connect(setupCharacter)
end

-- Função principal Liga/Desliga
local function toggleESP(state)
	espEnabled = state
	
	if espEnabled then
		espContainer = Instance.new("Folder")
		espContainer.Name = "IY_ESP_Container"
		espContainer.Parent = CoreGui

		for _, p in ipairs(Players:GetPlayers()) do
			createIYTag(p)
		end
		updateConnection = Players.PlayerAdded:Connect(createIYTag)
	else
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end
		if espContainer then
			espContainer:Destroy()
			espContainer = nil
		end
	end
end

-- Evento de clique no botão gerado
textButton.MouseButton1Click:Connect(function()
	local newState = not espEnabled
	toggleESP(newState)
	
	if newState then
		textButton.Text = "ESP: ON"
		textButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		textButton.Text = "ESP: OFF"
		textButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)
