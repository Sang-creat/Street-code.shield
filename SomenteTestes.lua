--[[\
    Blindagem Defensiva Completa (Anti-Bring + Anti-Gear)
    Otimizado para Executor Delta
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("[Blindagem Total]: Escudo Anti-Bring e Anti-Gear ativado com sucesso!")

local lastValidPosition = nil

-- Função para inicializar ouvintes de assento no personagem
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    
    if hrp then
        lastValidPosition = hrp.CFrame
    end

    if humanoid then
        -- Proteção contra o truque do veículo/moto
        humanoid.Seated:Connect(function(isSeated)
            if isSeated then
                humanoid.Sit = false
                task.wait()
                if hrp and lastValidPosition then
                    hrp.CFrame = lastValidPosition + Vector3.new(0, 5, 0)
                end
            end
        end)
    end

    -- Evita que ferramentas indesejadas fiquem presas no inventário/personagem
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Parent = LocalPlayer.Backpack
        end
    end)
end

-- Aplica no personagem atual e em futuros respawns
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Loop único de monitoramento contínuo (Heartbeat) para performance máxima
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid then
        if humanoid.Health <= 0 then
            lastValidPosition = nil
            return
        end

        if not lastValidPosition then
            lastValidPosition = hrp.CFrame
        end

        -- 1. CAMADA ANTI-BRING / GOTO / LOOPBRING
        local distanceMoved = (hrp.Position - lastValidPosition.Position).Magnitude

        if distanceMoved > 15 and not humanoid.Sit then
            humanoid.PlatformStand = true
            hrp.CFrame = lastValidPosition
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            
            task.delay(0.1, function()
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end)
        else
            if hrp.Velocity.Magnitude < 50 and not humanoid.Sit then
                lastValidPosition = hrp.CFrame
            end
        end

        -- 2. CAMADA ANTI-GEAR / ANTI-TOUCH (Anula colisão de espadas e objetos próximos)
        for _, part in ipairs(workspace:GetPartsInPart(hrp)) do
            if part.Parent and part.Parent ~= character and not Players:GetPlayerFromCharacter(part.Parent) then
                if part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
