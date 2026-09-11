-- init.lua
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Comando que vai buscar o seu script principal na internet
loadstring(game:HttpGet("LINK_DO_SEU_GITHUB_AQUI"))()
