local Players, RunService, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Criação da GUI e Janela Principal
local ScreenGui = Instance.new("ScreenGui", (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")))
ScreenGui.Name, ScreenGui.ResetOnSpawn = "TeleportGUI", false

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 220, 0, 300), UDim2.new(0.5, -110, 0.5, -150), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Menu de Teleporte", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

-- Lista (ScrollingFrame)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency, Scroll.ScrollBarThickness = UDim2.new(1, -10, 1, -45), UDim2.new(0, 5, 0, 40), true, 6
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 4)

-- Função de Teleporte em Passos (Tween + Noclip)
local function tweenTeleportTo(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local noclip = RunService.Stepped:Connect(function()
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    local tween = TweenService:Create(root, TweenInfo.new((root.Position - targetCFrame.Position).Magnitude / 400), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- Atualizar Lista de Jogadores
local function updateList()
    for _, child in ipairs(Scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local Btn = Instance.new("TextButton", Scroll)
            Btn.Size, Btn.BackgroundColor3, Btn.Text, Btn.TextColor3 = UDim2.new(1, -6, 0, 30), Color3.fromRGB(50, 50, 50), plr.Name, Color3.new(1, 1, 1)
            Btn.MouseButton1Click:Connect(function()
                local tChar = plr.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    tweenTeleportTo(tChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
                end
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 34)
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
