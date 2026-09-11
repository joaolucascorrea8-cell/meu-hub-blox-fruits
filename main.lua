-- Espera o jogo carregar completamente antes de rodar
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- =======================================================
-- MEMÓRIA DO KAITUN: ESTADO GLOBAL DE AUTOMAÇÕES
-- =======================================================
_G.FastAttack = false
_G.AutoAttack = false
_G.AutoFarmLevel = false
_G.AutoChest = false
_G.AutoFruitSniper = false
_G.AutoStoreFruits = false
_G.VelocidadeVoo = 160 
_G.BlackScreen = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove Hub duplicado na tela para não travar
if playerGui:FindFirstChild("MegaKaitunHub") then
    playerGui.MegaKaitunHub:Destroy()
end

-- =======================================================
-- MOTORES DE SEGURANÇA E MOVIMENTAÇÃO (TWEEN + NOCLIP)
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

-- Mecânica de Noclip dos Kaituns
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

-- Sistema de Disparo de Comandos Seguros
local function dispararRemote(tipo, caminho, ...)
    local args = {...}
    local sucesso, resultado = pcall(function()
        if tipo == "Function" then return caminho:InvokeServer(unpack(args))
        elseif tipo == "Event" then caminho:FireServer(unpack(args)) end
    end)
    return sucesso, resultado
end

-- =======================================================
-- CONSTRUÇÃO DA INTERFACE VISUAL NATIVA DO HUB
-- =======================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaKaitunHub"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 440, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.Size = UDim2.new(1, 0, 0, 40)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "  ⚡ KAITUN SUPREME HUB - TUDO-EM-UM"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 130, 1, -40)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.Size = UDim2.new(1, -130, 1, -40)

local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Parent = ScreenGui
BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
BlackScreenFrame.Visible = false

local BlackScreenLabel = Instance.new("TextLabel")
BlackScreenLabel.Parent = BlackScreenFrame
BlackScreenLabel.BackgroundTransparency = 1
BlackScreenLabel.Position = UDim2.new(0.3, 0, 0.45, 0)
BlackScreenLabel.Size = UDim2.new(0, 300, 0, 50)
BlackScreenLabel.Font = Enum.Font.SourceSansBold
BlackScreenLabel.Text = "MODO ECONOMIA ATIVO (KAITUN RUNNING)\nClique na tela para desativar"
BlackScreenLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
BlackScreenLabel.TextSize = 16

local function criarPagina()
    local page = Instance.new("ScrollingFrame")
    page.Parent = ContentContainer
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 1.6, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    return page
end

local PageFarm = criarPagina()
local PageFruits = criarPagina()
local PageShop = criarPagina()
local PageConfig = criarPagina()

local function abrirAba(paginaAtiva)
    PageFarm.Visible = false; PageFruits.Visible = false; PageShop.Visible = false; PageConfig.Visible = false
    paginaAtiva.Visible = true
end

local function criarBotaoAba(texto, posIndex, pagina)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.Position = UDim2.new(0.05, 0, 0, (posIndex * 42) - 32)
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(function() abrirAba(pagina) end)
end

criarBotaoAba("⚔️ Auto Farm", 1, PageFarm)
criarBotaoAba("🍎 Auto Fruit", 2, PageFruits)
criarBotaoAba("🛒 Auto Shop", 3, PageShop)
criarBotaoAba("⚙️ Otimização", 4, PageConfig)
abrirAba(PageFarm)

local function criarToggle(parent, texto, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto .. ": DESLIGADO"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    
    local ativo = false
    btn.MouseButton1Click:Connect(function()
        ativo = not ativo
        btn.Text = ativo and (texto .. ": LIGADO") or (texto .. ": DESLIGADO")
        btn.BackgroundColor3 = ativo and Color3.fromRGB(50, 140, 50) or Color3.fromRGB(180, 50, 50)
        callback(ativo)
    end)
end

local function criarBotaoSimples(parent, texto, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(callback)
end

-- ABA 1: COMBATE E AUTO FARM
criarToggle(PageFarm, "Fast Attack (Ataque Rápido)", 15, function(state)
    _G.FastAttack = state
    if state then
        task.spawn(function()
            while _G.FastAttack do
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        pcall(function()
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        end)
                    end
                end
                task.wait(0.01)
            end
        end)
    end
end)

criarToggle(PageFarm, "Auto Farm Level (Voo)", 65, function(state)
    _G.AutoFarmLevel = state
    if state then
        task.spawn(function()
            while _G.AutoFarmLevel do
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, npc in pairs(workspace.Enemies:GetChildren()) do
                        if not _G.AutoFarmLevel then break end
                        if npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
                            _G.FastAttack = true
                            voarPara(npc.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0))
                            task.wait(0.3)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        _G.FastAttack = false
    end
end)

criarToggle(PageFarm, "Auto Chest Farm (Baús)", 115, function(state)
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
                                task.wait(0.3)
                            end
                        end
