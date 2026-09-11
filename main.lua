-- Espera o jogo carregar completamente
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Variáveis de Controle Global
_G.AutoAttack = false
_G.AutoFarmLevel = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") -- CORREÇÃO: Usando a pasta correta do jogador

-- Deleta o Hub anterior se ele já estiver aberto para não acumular na tela
if playerGui:FindFirstChild("HubNativo") then
    playerGui.HubNativo:Destroy()
end

-- 1. CRIAR A INTERFACE VISUAL NATIVA
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AttackToggle = Instance.new("TextButton")
local FarmToggle = Instance.new("TextButton")
local TeleportButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

-- Configurações da Janela Principal
ScreenGui.Name = "HubNativo"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Azul escuro/Midnight
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite mover com o mouse

-- Título do Menu
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MEU HUB NATIVO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Botão 1: Auto Ataque
AttackToggle.Name = "AttackToggle"
AttackToggle.Parent = MainFrame
AttackToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho
AttackToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
AttackToggle.Size = UDim2.new(0.9, 0, 0, 40)
AttackToggle.Font = Enum.Font.SourceSans
AttackToggle.Text = "Auto Ataque: DESLIGADO"
AttackToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AttackToggle.TextSize = 16

AttackToggle.MouseButton1Click:Connect(function()
    _G.AutoAttack = not _G.AutoAttack
    if _G.AutoAttack then
        AttackToggle.Text = "Auto Ataque: LIGADO"
        AttackToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Verde
        
        task.spawn(function()
            while _G.AutoAttack do
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
                task.wait(0.1)
            end
        end)
    else
        AttackToggle.Text = "Auto Ataque: DESLIGADO"
        AttackToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Botão 2: Auto Farm Level
FarmToggle.Name = "FarmToggle"
FarmToggle.Parent = MainFrame
FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmToggle.Position = UDim2.new(0.05, 0, 0.4, 0)
FarmToggle.Size = UDim2.new(0.9, 0, 0, 40)
FarmToggle.Font = Enum.Font.SourceSans
FarmToggle.Text = "Auto Farm: DESLIGADO"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.TextSize = 16

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmLevel = not _G.AutoFarmLevel
    if _G.AutoFarmLevel then
        FarmToggle.Text = "Auto Farm: LIGADO"
        FarmToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        FarmToggle.Text = "Auto Farm: DESLIGADO"
        FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Botão 3: Teleporte Café (Segundo Mar)
TeleportButton.Name = "TeleportButton"
TeleportButton.Parent = MainFrame
TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
TeleportButton.Position = UDim2.new(0.05, 0, 0.6, 0)
TeleportButton.Size = UDim2.new(0.9, 0, 0, 40)
TeleportButton.Font = Enum.Font.SourceSans
TeleportButton.Text = "Teleportar para o Café"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextSize = 16

TeleportButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-25, 15, -10)
    end
end)

-- Botão 4: Fechar Menu
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
CloseButton.Position = UDim2.new(0.05, 0, 0.8, 0)
CloseButton.Size = UDim2.new(0.9, 0, 0, 40)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "FECHAR HUB"
CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextSize = 16

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
