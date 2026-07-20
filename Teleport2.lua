local Players, RunService, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService")
local lp = Players.LocalPlayer

local Gui = Instance.new("ScreenGui", (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")))
Gui.Name, Gui.ResetOnSpawn = "TeleportGUI", false

local Main = Instance.new("Frame", Gui)
Main.Size, Main.Position, Main.BackgroundColor3, Main.Draggable, Main.Active = UDim2.new(0, 240, 0, 340), UDim2.new(0.5, -120, 0.5, -170), Color3.fromRGB(30, 30, 30), true, true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.BackgroundColor3, Title.Text, Title.TextColor3, Title.Font = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 45, 45), "Menu de Teleporte", Color3.new(1, 1, 1), Enum.Font.SourceSansBold

local gotoEnabled = true
local loopGotoEnabled = false
local activeLoopTarget = nil
local loopConnection = nil

-- Função de Teleporte por Múltiplos Saltos (Waypoints para distâncias longas)
local function multiStepTeleport(targetCF)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local noclip = RunService.Stepped:Connect(function()
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    local startPos, targetPos = root.Position, targetCF.Position
    local steps = math.ceil((targetPos - startPos).Magnitude / 400)

    for i = 1, steps do
        local intermediatePos = startPos:Lerp(targetPos, i / steps)
        local tween = TweenService:Create(root, TweenInfo.new((root.Position - intermediatePos).Magnitude / 400, Enum.EasingStyle.Linear), {CFrame = CFrame.new(intermediatePos) * (targetCF - targetPos)})
        tween:Play()
        tween.Completed:Wait()
    end
    noclip:Disconnect()
end

-- Função para iniciar/gerenciar o loop nas costas com aproximação suave
local function startLoopGoto(targetPlr)
    if loopConnection then loopConnection:Disconnect() end
    
    -- Aproximação inicial suave caso esteja longe
    if targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        local backCF = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
        multiStepTeleport(backCF)
    end
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not loopGotoEnabled or not activeLoopTarget or not activeLoopTarget.Character or not activeLoopTarget.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetRoot = activeLoopTarget.Character:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            -- Mantém grudado nas costas a 1 stud de distância de forma contínua
            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
        end
    end)
end

local function createToggle(name, posX, defaultState, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Font = UDim2.new(0, 110, 0, 25), posX, Color3.fromRGB(50, 50, 50), "", Color3.new(1, 1, 1), Enum.Font.SourceSans
    local label = Instance.new("TextLabel", btn)
    label.Size, label.BackgroundTransparency, label.TextColor3, label.TextSize = UDim2.new(1, 0, 1, 0), true, Color3.new(1, 1, 1), 12
    
    local state = defaultState
    local function update()
        label.Text = name .. ": " .. (state and "LIGADO" or "DESLIGADO")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end
    update()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        callback(state)
    end)
    return btn
end

createToggle("Goto", UDim2.new(0, 5, 0, 40), true, function(state) gotoEnabled = state end)
createToggle("LoopGoto", UDim2.new(0, 125, 0, 40), false, function(state) 
    loopGotoEnabled = state
    if not state then
        activeLoopTarget = nil
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    else
        if activeLoopTarget then startLoopGoto(activeLoopTarget) end
    end
end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size, Scroll.Position, Scroll.BackgroundTransparency, Scroll.ScrollBarThickness = UDim2.new(1, -10, 1, -75), UDim2.new(0, 5, 0, 70), true, 6
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 4)

local updateList

updateList = function()
    for _, c in ipairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local ItemFrame = Instance.new("Frame", Scroll)
            ItemFrame.Size, ItemFrame.BackgroundTransparency = UDim2.new(1, -6, 0, 30), true

            local Btn = Instance.new("TextButton", ItemFrame)
            Btn.Size, Btn.Position, Btn.BackgroundColor3, Btn.Text, Btn.TextColor3 = UDim2.new(1, -35, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(50, 50, 50), plr.Name, Color3.new(1, 1, 1)
            Instance.new("UICorner", Btn)

            local Circle = Instance.new("TextButton", ItemFrame)
            Circle.Size, Circle.Position, Circle.BackgroundColor3, Circle.Text, Circle.TextColor3 = UDim2.new(0, 30, 1, 0), UDim2.new(1, -30, 0, 0), Color3.fromRGB(40, 40, 40), "", Color3.new(1, 1, 1)
            Circle.Visible = loopGotoEnabled
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            Circle.Text = (loopGotoEnabled and activeLoopTarget == plr) and "✅" or ""

            Btn.MouseButton1Click:Connect(function()
                local tChar = plr.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    local backCF = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                    
                    if loopGotoEnabled then
                        activeLoopTarget = plr
                        startLoopGoto(plr)
                        updateList()
                    elseif gotoEnabled then
                        multiStepTeleport(backCF)
                    end
                end
            end)

            Circle.MouseButton1Click:Connect(function()
                if not loopGotoEnabled then return end
                
                if activeLoopTarget == plr then
                    activeLoopTarget = nil
                    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
                else
                    activeLoopTarget = plr
                    startLoopGoto(plr)
                end
                updateList()
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 34)
end

lp.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if loopGotoEnabled and activeLoopTarget then
        startLoopGoto(activeLoopTarget)
    end
end)

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
