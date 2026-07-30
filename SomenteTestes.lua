-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") -- Impede que o ESP suma quando seu personagem morre

local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local espContainer = nil
local updateConnection = nil

-- Função para criar a estrutura visual idêntica à do Infinite Yield
local function createIYTag(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		local root = char:WaitForChild("HumanoidRootPart", 5)
		local hum = char:WaitForChild("Humanoid", 5)
		if not root or not hum then return end

		-- Cria ou limpa tag existente no container
		local existing = espContainer:FindFirstChild(player.Name)
		if existing then existing:Destroy() end

		-- Estrutura idêntica de BillboardGui do IY
		local billboard = Instance.new("BillboardGui")
		billboard.Name = player.Name
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.Adornee = root
		billboard.Parent = espContainer

		-- Label de Nome/Nick (Igual ao layout do Infinite Yield)
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Cor padrão branca do IY
		nameLabel.TextStrokeTransparency = 0 -- Borda preta essencial do IY
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextSize = 14
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.Parent = billboard

		-- Label de Informações (HP e Distância em Studs)
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

		-- Loop de atualização em tempo real por personagem (HP e Studs)
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not espEnabled or not billboard or not billboard.Parent or not char:IsDescendantOf(workspace) then
				connection:Disconnect()
				return
			end

			if root and hum and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local distance = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
				local hp = math.floor(hum.Health)
				-- Formatação exata exibida no Infinite Yield (HP: X | Dist: Y studs)
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
		-- Cria um container seguro no CoreGui (assim ele nunca quebra ou some quando você morre)
		espContainer = Instance.new("Folder")
		espContainer.Name = "IY_ESP_Container"
		espContainer.Parent = CoreGui

		-- Ativa para todos os jogadores atuais e futuros
		for _, p in ipairs(Players:GetPlayers()) do
			createIYTag(p)
		end
		updateConnection = Players.PlayerAdded:Connect(createIYTag)
	else
		-- Desativação completa e limpeza total de memória
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

-- Vinculação ao Botão da Interface
local textButton = script.Parent
textButton.MouseButton1Click:Connect(function()
	local newState = not espEnabled
	toggleESP(newState)
	
	-- Mantém o feedback visual do botão conforme o clique
	if newState then
		textButton.Text = "ESP: ON"
		textButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		textButton.Text = "ESP: OFF"
		textButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)
