-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local espContainer = nil
local updateConnection = nil

-- Função para criar a estrutura visual do ESP
local function createIYTag(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		-- Proteção contra demorarem para carregar (evita travamentos)
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

-- Vinculação segura ao Botão da Interface (Evita erro se executado direto no executor)
local textButton = script and script.Parent and (script.Parent:IsA("TextButton") or script.Parent:IsA("ImageButton")) and script.Parent or nil

if textButton then
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
else
	-- Caso rode via executor sem botão, liga o ESP automaticamente para testes
	toggleESP(true)
end
