-- Espera o jogo carregar completamente
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- =======================================================
-- CONFIGURAÇÕES E ESTADO GLOBAL
-- =======================================================
_G.AutoAttack = false
_G.AutoFarmLevel = false
_G.AutoChest = false
_G.AutoFruitSniper = false
_G.AutoStoreFruits = false
_G.VelocidadeVoo = 150 -- Controlado pela barrinha

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove Hub duplicado
if playerGui:FindFirstChild("MegaHubBloxFruits") then
    playerGui.MegaHubBloxFruits:Destroy()
end

-- =======================================================
-- FUNÇÕES DE MOVIMENTAÇÃO E SEGURANÇA (TWEEN + NOCLIP)
-- =======================================================
local function voarPara(cframeAlvo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local distancia = (hrp.Position - cframeAlvo.Position).Magnitude
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

-- Ativa Noclip se o Farm de Baús ou de Frutas estiver ligado
task.spawn(function()
    RunService.Stepped:Connect(function()
        if _G.AutoChest or _G.AutoFruitSniper or _G.AutoFarmLevel then
            local character = player.Character
            if character then
                for _, parte in pairs(character:GetDescendants()) do
                    if parte:IsA("BasePart") then
                        parte.CanCollide = false
                    end
                end
            end
        end
    end)
end)

local function dispararRemote(tipo, caminho, ...)
    local sucesso, resultado = pcall(function(...)
        if tipo == "Function" then return caminho:InvokeServer(...)
        elseif tipo == "Event" then caminho:FireServer(...) end
    end, ...)
    return sucesso, resultado
end

-- =======================================================
-- CRIAÇÃO DA INTERFACE VISUAL (DESIGN AVANÇADO)
-- =======================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaHubBloxFruits"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.Size = UDim2.new(1, 0, 0, 40)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "  PREMIUM MEGA HUB - TUDO-EM-UM"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Menu Lateral de Abas
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 120, 1, -40)

-- Container de Conteúdo Principal
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 120, 0, 40)
ContentContainer.Size = UDim2.new(1, -120, 1, -40)

-- Criar as Páginas de Conteúdo (Scrolling)
local function criarPagina()
    local page = Instance.new("ScrollingFrame")
    page.Parent = ContentContainer
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    return page
end

local PageFarm = criarPagina()
local PageFruits = criarPagina()
local PageConfig = criarPagina()

-- Função de alternar Abas
local function abrirAba(paginaAtiva)
    PageFarm.Visible = false
    PageFruits.Visible = false
    PageConfig.Visible = false
    paginaAtiva.Visible = true
end

-- Botões da Sidebar
local function criarBotaoAba(texto, posIndex, pagina)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Position = UDim2.new(0.05, 0, 0, (posIndex * 40) - 30)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(function() abrirAba(pagina) end)
end

criarBotaoAba("⚔️ Auto Farm", 1, PageFarm)
criarBotaoAba("🍎 Frutas", 2, PageFruits)
criarBotaoAba("⚙️ Ajustes", 3, PageConfig)
abrirAba(PageFarm) -- Abre na aba de Farm por padrão

-- Função Auxiliar para Criar Componentes dentro das Páginas
local function criarToggle(parent, texto, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto .. ": DESLIGADO"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    
    local ativo = false
    btn.MouseButton1Click:Connect(function()
        ativo = not ativo
        if ativo then
            btn.Text = texto .. ": LIGADO"
            btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        else
            btn.Text = texto .. ": DESLIGADO"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        callback(ativo)
    end)
end

local function criarBotaoSimples(parent, texto, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(callback)
end

-- =======================================================
-- CONFIGURAÇÃO DOS COMPONENTES DAS ABAS
-- =======================================================

-- --- ABA 1: AUTO FARM ---
criarToggle(PageFarm, "Auto Ataque / Click", 15, function(state)
    _G.AutoAttack = state
    if state then
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
    end
end)

criarToggle(PageFarm, "Auto Farm Level (Base)", 65, function(state)
    _G.AutoFarmLevel = state
    if state then
        task.spawn(function()
            while _G.AutoFarmLevel do
                -- Lógica Base de detecção de inimigos próximos
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, npc in pairs(workspace.Enemies:GetChildren()) do
                        if not _G.AutoFarmLevel then break end
                        if npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
                            -- Voa até o NPC e fica em cima dele atacando
                            _G.AutoAttack = true
                            voarPara(npc.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0))
                            task.wait(0.5)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        _G.AutoAttack = false
    end
end)

criarToggle(PageFarm, "Auto Chest Farm (Dinheiro)", 115, function(state)
    _G.AutoChest = state
    if state then
        task.spawn(function()
            while _G.AutoChest do
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, objeto in pairs(workspace:GetDescendants()) do
                        if not _G.AutoChest then break end
                        if objeto:IsA("TouchTransmitter") and objeto.Parent and objeto.Parent.Name:match("Chest") then
                            local bauPart = objeto.Parent
                            if bauPart:IsA("BasePart") then
                                voarPara(bauPart.CFrame)
                                task.wait(0.4)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- --- ABA 2: FRUTAS ---
criarBotaoSimples(PageFruits, "🎁 Girar Fruta (Cousin)", 15, function()
    local gff = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    dispararRemote("Function", gff, "Cousin", "BuyFruit")
end)

criarBotaoSimples(PageFruits, "🎉 Girar Novo Evento (Gacha)", 65, function()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
