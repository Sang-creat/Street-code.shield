-- Interface Mobile para Delta - Infinite Yield ESP Integration
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local ESP_ENABLED = false
local espConnections = {}
local trackedPlayers = {}

-- Criando a ScreenGui principal para o Botão
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IYESPMobile_Delta"
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Frame Principal da UI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 120, 0, 55)
MainFrame.Position = UDim2.new(0, 50, 0, 220) -- Posicionado logo abaixo do frame de Fly
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Botão Liga/Desliga (Toggle ESP)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "ESP: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- Remove o ESP de um jogador específico
local function removeESP(p)
	if trackedPlayers[p] then
		for _, v in pairs(trackedPlayers[p]) do
			if v then pcall(function() v:Destroy() end) end
		end
		trackedPlayers[p] = nil
	end
end

-- Código de Renderização Estética Original do Infinite Yield
local function applyESP(p)
	if p == player then return end
	removeESP(p)

	local objects = {}
	
	local function setupCharacter(char)
		task.wait(0.1)
		removeESP(p)
		if not ESP_ENABLED then return end

		local torso = char:WaitForChild("HumanoidRootPart", 5) or char:WaitForChild("Torso", 5) or char:WaitForChild("UpperTorso", 5)
		local head = char:WaitForChild("Head", 5)
		local humanoid = char:WaitForChild("Humanoid", 5)

		if torso and head and humanoid then
			-- Estética Original do IY: Caixas Adornment (Vermelha/Verde baseada no time ou padrão)
			local boxColor = (p.Team ~= player.Team) and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
			if not p.Team then boxColor = Color3.fromRGB(170, 0, 0) end -- Vermelho padrão se sem time

			-- Caixa do Tronco
			local torsoBox = Instance.new("BoxHandleAdornment")
			torsoBox.Size = torso.Size + Vector3.new(0.1, 0.1, 0.1)
			torsoBox.Color3 = boxColor
			torsoBox.Transparency = 0.5
			torsoBox.AlwaysOnTop = true
			torsoBox.ZIndex = 5
			torsoBox.Adornee = torso
			torsoBox.Parent = CoreGui
			table.insert(objects, torsoBox)

			-- Caixa da Cabeça
			local headBox = Instance.new("BoxHandleAdornment")
			headBox.Size = head.Size + Vector3.new(0.1, 0.1, 0.1)
			headBox.Color3 = boxColor
			headBox.Transparency = 0.5
			headBox.AlwaysOnTop = true
			headBox.ZIndex = 5
			headBox.Adornee = head
			headBox.Parent = CoreGui
			table.insert(objects, headBox)

			-- Painel de Informações Original (BillboardGui)
			local bbg = Instance.new("BillboardGui")
			bbg.Size = UDim2.new(0, 200, 0, 50)
			bbg.Adornee = head
			bbg.AlwaysOnTop = true
			bbg.ExtentsOffset = Vector3.new(0, 3, 0)
			bbg.Parent = CoreGui
			table.insert(objects, bbg)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextStrokeTransparency = 0
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 14
			label.Parent = bbg

			-- Loop de Atualização das Informações (Nick, HP e Distância)
			local connection
			connection = RunService.RenderStepped:Connect(function()
				if not ESP_ENABLED or not char.Parent or not humanoid or not torso then
					connection:Disconnect()
					return
				end
				
				local myTorso = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso"))
				local distance = myTorso and math.floor((torso.Position - myTorso.Position).Magnitude) or 0
				local health = math.floor(humanoid.Health)
				
				-- Formatação exata de exibição de dados do Infinite Yield
				label.Text = string.format("%s\nHP: %d | Dist: %d studs", p.Name, health, distance)
			end)
			
			table.insert(objects, connection)
			trackedPlayers[p] = objects
		end
	end

	if p.Character then task.spawn(setupCharacter, p.Character) end
	local chAdded = p.CharacterAdded:Connect(function(char) setupCharacter(char) end)
	local chRemoving = p.CharacterRemoving:Connect(function() removeESP(p) end)
	
	espConnections[p] = {chAdded, chRemoving}
end

-- Ativa ou Desativa o Mecanismo de Loop Completo do ESP
local function toggleESP(state)
	ESP_ENABLED = state
	if ESP_ENABLED then
		ToggleBtn.Text = "ESP: ON"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
		
		for _, p in pairs(Players:GetPlayers()) do
			applyESP(p)
		end
		
		-- Eventos para novos jogadores
		table.insert(espConnections, Players.PlayerAdded:Connect(applyESP))
		table.insert(espConnections, Players.PlayerRemoving:Connect(function(p)
			removeESP(p)
			if espConnections[p] then
				espConnections[p][1]:Disconnect()
				espConnections[p][2]:Disconnect()
				espConnections[p] = nil
			end
		end))
	else
		ToggleBtn.Text = "ESP: OFF"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		
		-- Desconecta todos os listeners gerais e limpa adornos
		for _, c in pairs(espConnections) do
			if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
		end
		for p, entry in pairs(espConnections) do
			if typeof(entry) == "table" then
				entry[1]:Disconnect()
				entry[2]:Disconnect()
			end
		end
		
		espConnections = {}
		for p, _ in pairs(trackedPlayers) do removeESP(p) end
	end
end

-- Vinculo com o clique do botão Mobile
ToggleBtn.MouseButton1Click:Connect(function()
	toggleESP(not ESP_ENABLED)
end)
