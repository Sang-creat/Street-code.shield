-- Interface Mobile para Delta - Infinite Yield Fly Integration (100% Mobile Fix)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Variáveis de Estado do Voo (Baseadas no IY original)
local FLYING = false
local flySpeed = 20

-- Criando a ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IYFlyMobile_Delta_Fixed"
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Frame Principal da UI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 55)
MainFrame.Position = UDim2.new(0, 50, 0, 150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Botão Liga/Desliga (Toggle)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "FLY: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- TextBox de Velocidade
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 90, 0, 35)
SpeedBox.Position = UDim2.new(0, 120, 0, 10)
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBox.Text = tostring(flySpeed)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextScaled = true
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = SpeedBox

-- Função de Injeção: Captura os inputs do analógico virtual do Roblox (Mobile Controller)
local function getMobileMoveVector()
	local activeController = nil
	-- Tenta puxar o módulo de controle nativo do Roblox Player
	pcall(function()
		local PlayerScripts = player:WaitForChild("PlayerScripts")
		local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
		activeController = PlayerModule:GetControls()
	end)
	
	if activeController and activeController.GetMoveVector then
		return activeController:GetMoveVector()
	end
	return Vector3.new(0, 0, 0)
end

-- Núcleo do Comando Fly Original (Infinite Yield Adaptado para Inputs Mobile)
local function startFly()
	local torso = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso"))
	if not torso then return end
    
	local cam = workspace.CurrentCamera
	local speed = flySpeed

	local bg = Instance.new("BodyGyro", torso)
	bg.P = 9e4
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.cframe = torso.CFrame
    
	local bv = Instance.new("BodyVelocity", torso)
	bv.velocity = Vector3.new(0, 0.1, 0)
	bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

	task.spawn(function()
		while FLYING do
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.PlatformStand = true end
            
			-- Captura a direção exata para onde o analógico mobile está apontado
			local moveVector = getMobileMoveVector()
			local f = -moveVector.Z  -- Frente/Trás
			local r = moveVector.X   -- Esquerda/Direita
            
			if f ~= 0 or r ~= 0 then
				bv.velocity = ((cam.CoordinateFrame.LookVector * f) + ((cam.CoordinateFrame * CFrame.new(r, f * .2, 0).Position) - cam.CoordinateFrame.Position)) * speed
			else
				bv.velocity = Vector3.new(0, 0.1, 0)
			end
			bg.cframe = cam.CoordinateFrame
			RunService.RenderStepped:Wait()
		end
        
		-- Limpeza ao desligar o voo
		bv:Destroy()
		bg:Destroy()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end)
end

-- Função de Controle do Loop de Persistência (Morte/Respawn)
local function toggleFlight(state)
	FLYING = state
	if FLYING then
		ToggleBtn.Text = "FLY: ON"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
		startFly()
	else
		ToggleBtn.Text = "FLY: OFF"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	end
end

-- Evento do Botão
ToggleBtn.MouseButton1Click:Connect(function()
	toggleFlight(not FLYING)
end)

-- Atualização de Velocidade pela TextBox
SpeedBox.FocusLost:Connect(function()
	local num = tonumber(SpeedBox.Text)
	if num then
		flySpeed = num
	else
		SpeedBox.Text = tostring(flySpeed)
	end
end)

-- Loop contínuo para garantir o re-engajamento ao renascer se o estado for ON
player.CharacterAdded:Connect(function(newChar)
	newChar:WaitForChild("HumanoidRootPart")
	if FLYING then
		task.wait(0.5) -- Tempo hábil para carregar o novo personagem completamente
		startFly()
	end
end)
