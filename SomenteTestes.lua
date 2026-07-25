-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration & State
local GEAR_ID = 102705454
local isTornadoEnabled = false
local selectedTarget = nil
local aimLockConnection = nil
local stoppedTime = 0

-- Remotes
local avatarMainRE = ReplicatedStorage:FindFirstChild("AvatarMainRE", true)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TornadoControllerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Tornado Control - Mobile"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Minimize Button (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- Toggle Tornado Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleBtn.Text = "Tornado: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- Player List Frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -105)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 100)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollingFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Function to update Player List
local function updatePlayerList()
	for _, child in ipairs(ScrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local pBtn = Instance.new("TextButton")
			pBtn.Size = UDim2.new(1, 0, 0, 35)
			pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			pBtn.Text = player.Name
			pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			pBtn.TextSize = 13
			pBtn.Font = Enum.Font.Gotham
			pBtn.Parent = ScrollingFrame

			local pCorner = Instance.new("UICorner")
			pCorner.CornerRadius = UDim.new(0, 4)
			pCorner.Parent = pBtn

			pBtn.MouseButton1Click:Connect(function()
				selectedTarget = player
				for _, b in ipairs(ScrollingFrame:GetChildren()) do
					if b:IsA("TextButton") then
						b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					end
				end
				pBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
			end)
		end
	end
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Minimize / Restore Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	ScrollingFrame.Visible = not minimized
	ToggleBtn.Visible = not minimized
	MainFrame.Size = minimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 380)
	MinBtn.Text = minimized and "+" or "-"
end)

-- Close Permanently Logic
CloseBtn.MouseButton1Click:Connect(function()
	isTornadoEnabled = false
	if aimLockConnection then aimLockConnection:Disconnect() end
	ScreenGui:Destroy()
end)

-- Equip Gear Function
local function equipGear()
	if avatarMainRE then
		pcall(function()
			avatarMainRE:FireServer({
				["id"] = GEAR_ID,
				["event"] = "equip",
				["equiptype"] = "Gear"
			})
		end)
	end
end

-- Rotação Automática com Atraso Suavizada
aimLockConnection = RunService.RenderStepped:Connect(function(dt)
	if isTornadoEnabled and selectedTarget and selectedTarget.Character then
		local targetChar = selectedTarget.Character
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
		
		if targetRoot and myRoot and humanoid then
			local isMoving = humanoid.MoveDirection.Magnitude > 0.1
			
			if isMoving then
				stoppedTime = 0
			else
				stoppedTime = stoppedTime + dt
				
				if stoppedTime >= 0.5 then
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
		stoppedTime = 0
	end
end)

-- Main Tornado Loop Routine (Resiliente a Respawn)
local function startTornadoRoutine()
	task.spawn(function()
		-- Monitor contínuo acoplado ao ciclo de vida do jogador
		while isTornadoEnabled do
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local humanoid = char:WaitForChild("Humanoid", 5)
			
			if humanoid then
				task.wait(1.5) -- Aguarda estabilizar o carregamento do personagem após o reset
				if not isTornadoEnabled then break end
				
				equipGear()
				task.wait(1)
				
				while isTornadoEnabled and humanoid.Health > 0 and LocalPlayer.Character == char do
					-- Verificação a cada 2 segundos se a ferramenta está equipada ou no inventário
					local currentTool = char:FindFirstChildOfClass("Tool")
					local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
					
					local hasGear = currentTool or (backpack and backpack:FindFirstChild("Gear"))
					if not hasGear then
						equipGear()
					end
					
					task.wait(2)
					
					if not isTornadoEnabled or humanoid.Health <= 0 or LocalPlayer.Character ~= char then break end
					
					-- Ativa a ferramenta se estiver na mão
					currentTool = char:FindFirstChildOfClass("Tool")
					if currentTool then
						currentTool:Activate()
					end
					
					-- Manipulação dos tornados criados no workspace
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
			
			-- Aguarda o personagem morrer ou resetar para reiniciar o ciclo limpo
			if isTornadoEnabled and humanoid then
				pcall(function()
					humanoid.Died:Wait()
				end)
			end
			task.wait(1)
		end
	end)
end

-- Toggle Button Logic
ToggleBtn.MouseButton1Click:Connect(function()
	isTornadoEnabled = not isTornadoEnabled
	if isTornadoEnabled then
		ToggleBtn.Text = "Tornado: ON"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		startTornadoRoutine()
	else
		ToggleBtn.Text = "Tornado: OFF"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		stoppedTime = 0
	end
end)
