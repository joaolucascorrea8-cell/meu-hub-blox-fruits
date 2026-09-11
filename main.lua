-- Espera o jogo carregar completamente
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Variáveis Globais de Controle
_G.AutoFruitSniper = false
_G.AutoStoreFruits = false
_G.VelocidadeVoo = 150 -- Velocidade padrão inicial

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Deleta o Hub anterior se ele já estiver aberto
if playerGui:FindFirstChild("FruitHubPremium") then
    playerGui.FruitHubPremium:Destroy()
end

-- Função de Movimentação Suave (Tween) baseada na variável global de velocidade
local function voarPara(cframeAlvo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local distancia = (hrp.Position - cframeAlvo.Position).Magnitude
        
        -- Evita divisão por zero se a velocidade for muito baixa
        local vel = _G.VelocidadeVoo > 0 and _G.VelocidadeVoo or 50
        local duracaoVoo = distancia / vel
        
        local tweenInfo = TweenInfo.new(duracaoVoo, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframeAlvo})
        
        local bV = Instance.new("BodyVelocity")
        bV.Velocity = Vector3.new(0, 0, 0)
        bV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bV.Parent = hrp
        
        tween:Play()
        tween.Completed:Wait()
        
        bV:Destroy()
    end
end

-- Sistema de Noclip Automático
task.spawn(function()
    RunService.Stepped:Connect(function()
        if _G.AutoFruitSniper then
            local character = player.Character
            if character then
                for _, parte in pairs(character:GetDescendants()) do
                    if parte:IsA("BasePart") and parte.CanCollide == true then
                        parte.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- Função para disparar Remotes com segurança
local function dispararRemote(tipo, caminho, ...)
    local sucesso, resultado = pcall(function(...)
        if tipo == "Function" then
            return caminho:InvokeServer(...)
        elseif tipo == "Event" then
            caminho:FireServer(...)
        end
    end, ...)
    return sucesso, resultado
end

-- 1. CRIAR INTERFACE VISUAL NATIVA
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "FruitHubPremium"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 420) -- Aumentado um pouco para caber a barra
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "FRUIT & EVENT AUTOMATION"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 18

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 45)
Container.Size = UDim2.new(1, 0, 1, -95)
Container.CanvasSize = UDim2.new(0, 0, 1.3, 0)
Container.ScrollBarThickness = 6

local function criarBotaoMenu(texto, posicaoY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Container
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posicaoY)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- =======================================================
-- 🎛️ ADICIONANDO A BARRINHA DE VELOCIDADE (SLIDER NATIVA)
-- =======================================================
local SliderFrame = Instance.new("Frame")
local SliderLabel = Instance.new("TextLabel")
local SliderBar = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")

SliderFrame.Name = "SliderFrame"
SliderFrame.Parent = Container
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SliderFrame.Position = UDim2.new(0.05, 0, 0, 15)
SliderFrame.Size = UDim2.new(0.9, 0, 0, 50)

SliderLabel.Name = "SliderLabel"
SliderLabel.Parent = SliderFrame
SliderLabel.BackgroundTransparency = 1
SliderLabel.Size = UDim2.new(1, 0, 0, 25)
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Text = "⚡ VELOCIDADE DO TWEEN: " .. _G.VelocidadeVoo
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 13

SliderBar.Name = "SliderBar"
SliderBar.Parent = SliderFrame
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
SliderBar.Size = UDim2.new(0.9, 0, 0, 8)

SliderButton.Name = "SliderButton"
SliderButton.Parent = SliderBar
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
-- Define a posição inicial com base nos 150 padrão (metade do caminho entre 50 e 300)
SliderButton.Position = UDim2.new(0.4, 0, -0.7, 0)
SliderButton.Size = UDim2.new(0, 15, 0, 18)
SliderButton.Text = ""

-- Lógica para arrastar o botão da barra com o mouse
local arrastando = false
SliderButton.MouseButton1Down:Connect(function() arrastando = true end)

local mouse = player:GetMouse()
mouse.Move:Connect(function()
    if arrastando then
        local posAbsolutaBarra = SliderBar.AbsolutePosition.X
        local tamAbsolutoBarra = SliderBar.AbsoluteSize.X
        local posMouseX = mouse.X
        
        -- Calcula o percentual de onde o mouse está na barra (de 0 a 1)
        local percentual = math.clamp((posMouseX - posAbsolutaBarra) / tamAbsolutoBarra, 0, 1)
        SliderButton.Position = UDim2.new(percentual, -7, -0.7, 0)
        
        -- Converte o percentual para valores de velocidade entre 50 e 300
        local minVel = 50
        local maxVel = 300
        _G.VelocidadeVoo = math.floor(minVel + (percentual * (maxVel - minVel)))
        SliderLabel.Text = "⚡ VELOCIDADE DO TWEEN: " .. _G.VelocidadeVoo
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = false
    end
end)

-- Ajustando a posição vertical (Y) dos outros botões abaixo para dar espaço à barra
criarBotaoMenu("🎁 GIRAR FRUTA ALEATÓRIA (Cousin)", 75, function()
    local gff = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    dispararRemote("Function", gff, "Cousin", "BuyFruit")
end)

criarBotaoMenu("🎉 GIRAR ROCO/FRUTA DO NOVO EVENTO", 125, function()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local eventRemote = remotes:FindFirstChild("EventGacha") or remotes:FindFirstChild("CommF_")
    if eventRemote and eventRemote.Name == "CommF_" then
        dispararRemote("Function", eventRemote, "EventNPC", "Roll")
    elseif eventRemote then
        dispararRemote("Function", eventRemote, "Roll")
    end
end)

local StoreToggle = criarBotaoMenu("📦 AUTO STORE FRUITS: DESLIGADO", 175, function() end)
StoreToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StoreToggle.MouseButton1Click:Connect(function()
    _G.AutoStoreFruits = not _G.AutoStoreFruits
    if _G.AutoStoreFruits then
        StoreToggle.Text = "📦 AUTO STORE FRUITS: LIGADO"
        StoreToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(function()
            while _G.AutoStoreFruits do
                local character = player.Character
                if character then
                    local frutaNaMao = character:FindFirstChildOfClass("Tool")
                    if frutaNaMao and frutaNaMao.Name:match("Fruit") then
                        local storeRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                        dispararRemote("Function", storeRemote, "StoreFruit", frutaNaMao.Name, frutaNaMao)
                    end
                end
                task.wait(1.5)
            end
        end)
    else
        StoreToggle.Text = "📦 AUTO STORE FRUITS: DESLIGADO"
        StoreToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

local SniperToggle = criarBotaoMenu("🍎 FRUIT SNIPER (MAPA): DESLIGADO", 225, function() end)
SniperToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
SniperToggle.MouseButton1Click:Connect(function()
    _G.AutoFruitSniper = not _G.AutoFruitSniper
    if _G.AutoFruitSniper then
        SniperToggle.Text = "🍎 FRUIT SNIPER (MAPA): LIGADO"
        SniperToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(function()
            while _G.AutoFruitSniper do
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, objeto in pairs(workspace:GetChildren()) do
                        if not _G.AutoFruitSniper then break end
                        if objeto:IsA("Model") and (objeto.Name:match("Fruit") or objeto:FindFirstChild("Handle")) then
                            local handle = objeto:FindFirstChild("Handle") or objeto:FindFirstChildOfClass("BasePart")
                            if handle then
                                voarPara(handle.CFrame)
                                task.wait(0.5)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
