-- Espera o jogo carregar completamente antes de abrir o menu
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Inicialização das Variáveis Globais de Controle
_G.AutoFarmLevel = false
_G.AutoAttack = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Carrega a Kavo Library Oficial via loadstring (Layout profissional)
local KavoLibrary = loadstring(game:HttpGet("https://githubusercontent.com"))()
-- Cria a Janela Principal (Tema "Midnight" Escuro)
local Window = KavoLibrary.CreateLib("Meu Script Hub", "Midnight")

-- =======================================================
-- ABA 1: AUTO FARM
-- =======================================================
local FarmTab = Window:NewTab("Auto Farm")
local FarmSection = FarmTab:NewSection("Configurações de Farm")

-- Toggle para ativar/desativar o Ataque Automático
FarmSection:NewToggle("Auto Ataque", "Faz o seu personagem clicar infinitamente", function(state)
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
                task.wait(0.1) -- Pausa de segurança para não travar o executor
            end
        end)
    end
end)

-- Toggle Base para o Auto Farm de Level
FarmSection:NewToggle("Auto Farm de Level", "Ativa o farm automatizado de NPCs", function(state)
    _G.AutoFarmLevel = state
    if state then
        print("Auto Farm de Level Ativado!")
    else
        print("Auto Farm de Level Desativado!")
    end
end)

-- =======================================================
-- ABA 2: TELEPORTES (Lógica por Coordenadas CFrame)
-- =======================================================
local TeleportTab = Window:NewTab("Teleportes")
local TeleportSection = TeleportTab:NewSection("Viajar Entre os Mares")

local function teleportarPara(cframeAlvo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cframeAlvo
    end
end

-- CORREÇÃO AQUI: Fechamento correto das funções anônimas da Kavo Library
TeleportSection:NewButton("Primeiro Mar (Mundo Inicial)", "Te move para as coordenadas do Primeiro Mar", function()
    teleportarPara(CFrame.new(994, 15, -1412)) 
end)

TeleportSection:NewButton("Segundo Mar", "Te move para as coordenadas do Segundo Mar", function()
    teleportarPara(CFrame.new(-25, 15, -10)) 
end)

TeleportSection:NewButton("Terceiro Mar", "Te move para as coordenadas do Terceiro Mar", function()
    teleportarPara(CFrame.new(500, 15, 500)) 
end)

-- =======================================================
-- ABA 3: STATUS & SISTEMA
-- =======================================================
local StatusTab = Window:NewTab("Status")
local StatusSection = StatusTab:NewSection("Informações do Usuário")

-- Mostra o nome do jogador atualizado na interface
StatusSection:NewLabel("Jogador Conectado: " .. player.Name)
StatusSection:NewLabel("ID do Usuário: " .. player.UserId)

-- Botão para fechar o menu completamente se precisar esconder a tela
StatusSection:NewButton("Fechar Hub", "Destrói a interface gráfica", function()
    KavoLibrary:DestroyGui()
end)
