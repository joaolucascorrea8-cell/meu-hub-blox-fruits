-- Espera o jogo carregar completamente
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Variáveis de Controle Global
_G.AutoAttack = false
_G.AutoChest = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuração da Velocidade do Voo (100 a 150 é o limite seguro para não dar lag ou ban)
local VelocidadeVoo = 120 

-- Deleta o Hub anterior se ele já estiver aberto
if playerGui:FindFirstChild("HubNativo") then
    playerGui.HubNativo:Destroy()
end

-- Função Otimizada de Movimentação Suave (Tween)
local function voarPara(cframeAlvo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        
        -- Calcula a distância exata para ajustar o tempo do voo automaticamente
        local distancia = (hrp.Position - cframeAlvo.Position).Magnitude
        local duracaoVoo = distancia / VelocidadeVoo
        
        -- Cria o movimento linear suave
        local tweenInfo = TweenInfo.new(duracaoVoo, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframeAlvo})
        
        -- Desativa a gravidade temporariamente para o personagem não cair enquanto voa
        local bV = Instance.new("BodyVelocity")
        bV.Velocity = Vector3.new(0, 0, 0)
        bV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bV.Parent = hrp
        
        tween:Play()
        tween.Completed:Wait() -- Espera o personagem chegar fisicamente ao baú
        
        bV:Destroy() -- Remove a trava de gravidade após chegar
    end
end

-- 1. CRIAR A INTERFACE VISUAL NATIVA
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AttackToggle = Instance.new("TextButton")
local ChestToggle = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "HubNativo"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

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
AttackToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        AttackToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
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

-- Botão 2: Auto Chest com Tween Anti-Ban seguro
ChestToggle.Name = "ChestToggle"
ChestToggle.Parent = MainFrame
ChestToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ChestToggle.Position = UDim2.new(0.05, 0, 0.4, 0)
ChestToggle.Size = UDim2.new(0.9, 0, 0, 40)
ChestToggle.Font = Enum.Font.SourceSans
ChestToggle.Text = "Auto Chest: DESLIGADO"
ChestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ChestToggle.TextSize = 16

ChestToggle.MouseButton1Click:Connect(function()
    _G.AutoChest = not _G.AutoChest
    if _G.AutoChest then
        ChestToggle.Text = "Auto Chest: LIGADO"
        ChestToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        task.spawn(function()
            while _G.AutoChest do
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local encontrouBau = false
                    
                    for _, objeto in pairs(workspace:GetDescendants()) do
                        if not _G.AutoChest then break end
                        
                        -- Procura gatilhos de toque de baús ativos no mapa
                        if objeto:IsA("TouchTransmitter") and objeto.Parent and objeto.Parent.Name:match("Chest") then
                            local bauPart = objeto.Parent
                            if bauPart:IsA("BasePart") then
                                encontrouBau = true
                                
                                -- Executa o voo suave até a posição exata do baú
                                voarPara(bauPart.CFrame)
                                task.wait(0.3) -- Tempo para o servidor computar o dinheiro coletado
                            end
                        end
                    end
                    
                    -- Se limpou o mapa inteiro, aguarda o respawn geral de baús
                    if not encontrouBau then
                        task.wait(5)
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        ChestToggle.Text = "Auto Chest: DESLIGADO"
        ChestToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Botão 3: Fechar Menu
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
CloseButton.Position = UDim2.new(0.05, 0, 0.7, 0)
CloseButton.Size = UDim2.new(0.9, 0, 0, 40)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "FECHAR HUB"
CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextSize = 16

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
