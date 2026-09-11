-- Espera o jogo carregar completamente
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Inicialização das Variáveis Globais de Controle
_G.AutoFarmLevel = false
_G.AutoAttack = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Carrega a Orion Library Oficial via loadstring (Mais estável e moderna)
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Cria a Janela Principal do Hub
local Window = OrionLib:MakeWindow({
    Name = "Meu Script Hub (Orion Edition)", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "OrionBloxFruits"
})

-- =======================================================
-- ABA 1: AUTO FARM
-- =======================================================
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggle para ativar/desativar o Ataque Automático
FarmTab:AddToggle({
    Name = "Auto Ataque",
    Default = false,
    Callback = function(state)
        _G.AutoAttack = state
        if state then
            task.spawn(function()
                while _G.AutoAttack do
                    local character = player.Character
                    if character then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                    task.wait(0.1) -- Pausa de segurança
                end
            end)
        end
    end    
})

-- Toggle Base para o Auto Farm de Level
FarmTab:AddToggle({
    Name = "Auto Farm de Level",
    Default = false,
    Callback = function(state)
        _G.AutoFarmLevel = state
        if state then
            print("Auto Farm de Level Ativado!")
        else
            print("Auto Farm de Level Desativado!")
        end
    end    
})

-- =======================================================
-- ABA 2: TELEPORTES
-- =======================================================
local TeleportTab = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local function teleportarPara(cframeAlvo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cframeAlvo
    end
end

TeleportTab:AddButton({
    Name = "Primeiro Mar (Mundo Inicial)",
    Callback = function()
        teleportarPara(CFrame.new(994, 15, -1412))
    end
})

TeleportTab:AddButton({
    Name = "Segundo Mar",
    Callback = function()
        teleportarPara(CFrame.new(-25, 15, -10))
    end
})

TeleportTab:AddButton({
    Name = "Terceiro Mar",
    Callback = function()
        teleportarPara(CFrame.new(500, 15, 500))
    end
})

-- =======================================================
-- ABA 3: STATUS
-- =======================================================
local StatusTab = Window:MakeTab({
    Name = "Status",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

StatusTab:AddLabel("Jogador: " .. player.Name)
StatusTab:AddLabel("ID: " .. player.UserId)

-- Botão para fechar o menu
StatusTab:AddButton({
    Name = "Fechar Hub",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Inicializa a interface gráfica na tela
OrionLib:Init()
