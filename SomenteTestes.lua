local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Função que aplica o Anti-Touch em tudo que é parte física do personagem
local function applyAntiTouch(character)
    -- Garante que o personagem carregou o essencial antes de começar
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return end

    -- Conecta um evento para monitorar tudo que entra ou é modificado no personagem
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            descendant.CanTouch = false
        end
    end)

    -- Varre todas as partes que já existem no personagem neste momento
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanTouch = false
        end
    end
end

-- Roda continuamente a cada frame para garantir que nenhum script externo (ou do jogo) 
-- tente reativar o CanTouch das suas partes e bagunce a sua proteção.
RunService.Stepped:Connect(function()
    local character = localPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanTouch == true then
                part.CanTouch = false
            end
        end
    end
end)

-- Gerencia quando o jogador renasce (morre e cria um novo corpo)
localPlayer.CharacterAdded:Connect(function(newCharacter)
    task.defer(function()
        applyAntiTouch(newCharacter)
    end)
end)

-- Aplica imediatamente caso o script seja injetado com o jogo já rodando
if localPlayer.Character then
    applyAntiTouch(localPlayer.Character)
end

