local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Criação da Interface (GUI)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Nativo do Roblox, funciona bem para mobile

-- Lista de Jogadores
local ScrollingFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollingFrame.Size = UDim2.new(1, 0, 0.8, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

-- Função de Teleporte para as costas
local function teleportBehind(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, 3)
    end
end

-- Lógica do Anti-Empurrão (Distância)
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < 3 then -- Raio de 3 studs
                -- Empurra o inimigo para longe
                local direction = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                player.Character.HumanoidRootPart.Velocity = direction * 50
            end
        end
    end
end)

-- Gerador de botões na lista
for _, player in pairs(Players:GetPlayers()) do
    local btn = Instance.new("TextButton", ScrollingFrame)
    btn.Text = player.Name
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.MouseButton1Click:Connect(function()
        teleportBehind(player)
    end)
end
