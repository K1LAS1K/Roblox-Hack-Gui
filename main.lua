--[[
  KILASIK GUI - Advanced Game Control Interface
  This script creates a feature-rich GUI with many commands and features
  
  Usage: Paste the code into your executor and run it
  
  Key System: Requires a valid key to use. Get the key from our Discord server.
  
  Credit: KILASIK
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local NetworkClient = game:GetService("NetworkClient")
local GuiService = game:GetService("GuiService")

-- Key System
local KEY_CODE = "KILASIK2025" -- Key code
local DISCORD_LINK = "https://discord.gg/PHxN8nadgk" -- Discord server link
local keyVerified = false

-- Basic variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera
local guiCreated = false
local guiVisible = false
local minimized = false
local miniSize = false
local activeTab = "Main"
local favoriteCommands = {}
local resizingGui = false
local originalGuiSize = UDim2.new(0, 550, 0, 350)
local minGuiSize = UDim2.new(0, 400, 0, 250)

-- Key Binds Storage
local keyBindSettings = {
    -- Default keybinds
    Fly = {key = "F", enabled = false},
    Noclip = {key = "N", enabled = false},
    Speed = {key = "LeftShift", enabled = false},
    ESP = {key = "E", enabled = false},
    Aimbot = {key = "B", enabled = false},
    ClickTP = {key = "LeftControl", enabled = false},
    Reset = {key = "R", enabled = false},
    InfiniteJump = {key = "Space", enabled = false}
}

-- Speed and character control
local walkSpeed = 16
local jumpPower = 50
local infiniteJump = false
local noclip = false
local flying = false
local flySpeed = 2
local xray = false
local espSettings = {
    enabled = false,
    boxes = true,
    names = true,
    distances = true,
    teamCheck = true,
    teamColor = true,
    tracers = false,
    chams = false,
    showHealthBar = true,
    maxDistance = 1000
}

local aimbotSettings = {
    enabled = false,
    teamCheck = true,
    visibilityCheck = true,
    aimPart = "Head",
    sensitivity = 0.5,
    fovSize = 100,
    showFOV = true,
    toggleKey = "B",
    wallbangEnabled = false
}

local aimbotTarget = nil
local selectedPlayers = {}
local selectedParts = {}

-- GUI Colors
local colors = {
    background = Color3.fromRGB(25, 25, 30),
    header = Color3.fromRGB(35, 35, 40),
    button = Color3.fromRGB(45, 45, 55),
    buttonHover = Color3.fromRGB(55, 55, 65),
    buttonSelected = Color3.fromRGB(65, 105, 225),
    text = Color3.fromRGB(240, 240, 240),
    highlight = Color3.fromRGB(65, 105, 225),
    warning = Color3.fromRGB(200, 60, 60),
    success = Color3.fromRGB(60, 180, 75),
    neutralLight = Color3.fromRGB(70, 70, 85),
    neutralDark = Color3.fromRGB(40, 40, 50),
    shadow = Color3.fromRGB(15, 15, 20),
    categoryBG = Color3.fromRGB(30, 30, 35),
    favorite = Color3.fromRGB(255, 215, 0)
}

-- All Commands
local commands = {
    -- Main commands
    {name = "Speed", desc = "Set character walk speed", category = "Character", func = function(speed) setWalkSpeed(tonumber(speed) or 16) end, canFavorite = true},
    {name = "JumpPower", desc = "Set character jump power", category = "Character", func = function(power) setJumpPower(tonumber(power) or 50) end, canFavorite = true},
    {name = "InfiniteJump", desc = "Jump infinitely", category = "Character", func = function() toggleInfiniteJump() end, canFavorite = true},
    {name = "Fly", desc = "Toggle fly mode", category = "Character", func = function() toggleFly() end, canFavorite = true},
    {name = "Noclip", desc = "Walk through walls", category = "Character", func = function() toggleNoclip() end, canFavorite = true},
    {name = "XRay", desc = "Make walls transparent", category = "Vision", func = function() toggleXRay() end, canFavorite = true},
    {name = "ESP", desc = "Highlight players and objects", category = "ESP", func = function() toggleESP() end, canFavorite = true},
    {name = "ESP Boxes", desc = "Toggle ESP boxes", category = "ESP", func = function() toggleESPOption("boxes") end, canFavorite = true},
    {name = "ESP Names", desc = "Toggle ESP names", category = "ESP", func = function() toggleESPOption("names") end, canFavorite = true},
    {name = "ESP Tracers", desc = "Toggle ESP tracers", category = "ESP", func = function() toggleESPOption("tracers") end, canFavorite = true},
    {name = "ESP TeamCheck", desc = "Toggle ESP team check", category = "ESP", func = function() toggleESPOption("teamCheck") end, canFavorite = true},
    {name = "ESP TeamColor", desc = "Toggle ESP team color", category = "ESP", func = function() toggleESPOption("teamColor") end, canFavorite = true},
    {name = "ESP Chams", desc = "Toggle ESP chams", category = "ESP", func = function() toggleESPOption("chams") end, canFavorite = true},
    {name = "ESP HealthBar", desc = "Toggle ESP health bars", category = "ESP", func = function() toggleESPOption("showHealthBar") end, canFavorite = true},
    {name = "Aimbot", desc = "Auto aim at players", category = "Combat", func = function() toggleAimbot() end, canFavorite = true},
    {name = "Teleport", desc = "Teleport to mouse position", category = "Teleport", func = function() teleportToMouse() end, canFavorite = true},
    {name = "ClickTP", desc = "Click to teleport (Ctrl+Click)", category = "Teleport", func = function() toggleClickTP() end, canFavorite = true},
    {name = "TpToPlayer", desc = "Teleport to a specific player", category = "Teleport", func = function() openPlayerSelectionMenu("tp") end, canFavorite = true},
    {name = "GetPosition", desc = "Copy current position", category = "Teleport", func = function() copyPosition() end, canFavorite = true},
    {name = "Reset", desc = "Reset character", category = "Character", func = function() resetCharacter() end, canFavorite = true},
    {name = "Rejoin", desc = "Rejoin the same server", category = "Utility", func = function() rejoinServer() end, canFavorite = true},
    {name = "NoFog", desc = "Remove fog", category = "Vision", func = function() removeFog() end, canFavorite = true},
    {name = "FullBright", desc = "Full brightness", category = "Vision", func = function() enableFullBright() end, canFavorite = true},
    {name = "Invisible", desc = "Make character invisible", category = "Character", func = function() makeInvisible() end, canFavorite = true},
    {name = "RemoveMesh", desc = "Remove meshes", category = "Character", func = function() removeMeshes() end, canFavorite = true},
    
    -- Combat commands
    {name = "Aimbot Settings", desc = "Configure aimbot options", category = "Combat", func = function() openAimbotSettings() end, canFavorite = true},
    {name = "Aimbot FOV", desc = "Set aimbot field of view", category = "Combat", func = function(size) setAimbotFOV(tonumber(size) or 100) end, canFavorite = true},
    {name = "Wallbang", desc = "Shoot through walls", category = "Combat", func = function() toggleWallbang() end, canFavorite = true},
    {name = "KillAura", desc = "Auto hit nearby players", category = "Combat", func = function() toggleKillAura() end, canFavorite = true},
    {name = "InfiniteAmmo", desc = "Unlimited ammo", category = "Combat", func = function() giveInfiniteAmmo() end, canFavorite = true},
    {name = "GodMode", desc = "Try god mode", category = "Combat", func = function() attemptGodMode() end, canFavorite = true},
    {name = "AutoFarm", desc = "Auto collect resources", category = "Utility", func = function() toggleAutoFarm() end, canFavorite = true},
    {name = "Reach", desc = "Increase weapon reach", category = "Combat", func = function() increaseReach() end, canFavorite = true},
    
    -- Animation commands
    {name = "Zombie", desc = "Play zombie animation", category = "Animations", func = function() playAnimation("zombie") end, canFavorite = true},
    {name = "Ninja", desc = "Play ninja animation", category = "Animations", func = function() playAnimation("ninja") end, canFavorite = true},
    {name = "Robot", desc = "Play robot animation", category = "Animations", func = function() playAnimation("robot") end, canFavorite = true},
    {name = "Dab", desc = "Play dab animation", category = "Animations", func = function() playAnimation("dab") end, canFavorite = true},
    {name = "Floss", desc = "Play floss dance", category = "Animations", func = function() playAnimation("floss") end, canFavorite = true},
    {name = "Groove", desc = "Play groove dance", category = "Animations", func = function() playAnimation("groove") end, canFavorite = true},
    {name = "Lay", desc = "Play lay animation", category = "Animations", func = function() playAnimation("lay") end, canFavorite = true},
    {name = "Sit", desc = "Play sit animation", category = "Animations", func = function() playAnimation("sit") end, canFavorite = true},
    {name = "Superhero", desc = "Play superhero animation", category = "Animations", func = function() playAnimation("superhero") end, canFavorite = true},
    {name = "Spin", desc = "Play spin animation", category = "Animations", func = function() playAnimation("spin") end, canFavorite = true},
    {name = "Punch", desc = "Play punch animation", category = "Animations", func = function() playAnimation("punch") end, canFavorite = true},
    {name = "Dino", desc = "Play dinosaur animation", category = "Animations", func = function() playAnimation("dino") end, canFavorite = true},
    
    -- Troll/Fun commands
    {name = "DanceAnimate", desc = "Play dance animation", category = "Fun", func = function() playDanceAnimation() end, canFavorite = true},
    {name = "FakeChat", desc = "Send fake chat message", category = "Fun", func = function() openFakeChatPrompt() end, canFavorite = true},
    {name = "GiantSize", desc = "Make character giant", category = "Fun", func = function() makeGiantSize() end, canFavorite = true},
    {name = "TinySize", desc = "Make character tiny", category = "Fun", func = function() makeTinySize() end, canFavorite = true},
    {name = "FloatingParts", desc = "Create floating parts", category = "Fun", func = function() createFloatingParts() end, canFavorite = true},
    {name = "SpinCharacter", desc = "Spin your character", category = "Fun", func = function() spinCharacter() end, canFavorite = true},
    {name = "Ultimate Fling", desc = "Advanced fling script", category = "Fun", func = function() loadUltimateFling() end, canFavorite = true},
    {name = "Touch Fling", desc = "Fling players on touch", category = "Fun", func = function() loadTouchFling() end, canFavorite = true},
    
    -- Player commands
    {name = "Spectate", desc = "Spectate a player", category = "Players", func = function() openPlayerSelectionMenu("spectate") end, canFavorite = true},
    {name = "Unspectate", desc = "Stop spectating", category = "Players", func = function() unspectatePlayer() end, canFavorite = true},
    {name = "Goto", desc = "Go to a player", category = "Players", func = function() openPlayerSelectionMenu("goto") end, canFavorite = true},
    {name = "Bring", desc = "Bring a player to you", category = "Players", func = function() openPlayerSelectionMenu("bring") end, canFavorite = true},
    {name = "FlingPlayer", desc = "Fling a player", category = "Players", func = function() openPlayerSelectionMenu("fling") end, canFavorite = true},
    
    -- Tools
    {name = "CopyPosition", desc = "Copy position to clipboard", category = "Utility", func = function() copyPosition() end, canFavorite = true},
    {name = "BTools", desc = "Give building tools", category = "Utility", func = function() giveBTools() end, canFavorite = true},
    {name = "ForceField", desc = "Apply force field", category = "Utility", func = function() applyForceField() end, canFavorite = true},
    {name = "HighJump", desc = "Jump very high", category = "Character", func = function() doHighJump() end, canFavorite = true},
    {name = "SwimMode", desc = "Swim in the air", category = "Character", func = function() toggleSwimMode() end, canFavorite = true},
    
    -- Visual commands
    {name = "Rainbow", desc = "Rainbow character", category = "Visuals", func = function() makeRainbowCharacter() end, canFavorite = true},
    {name = "ClearMap", desc = "Clear the map", category = "Visuals", func = function() clearMap() end, canFavorite = true},
    {name = "LowGraphics", desc = "Low graphics settings", category = "Visuals", func = function() setLowGraphics() end, canFavorite = true},
    {name = "RemoveTextures", desc = "Remove textures", category = "Visuals", func = function() removeTextures() end, canFavorite = true},
    {name = "ShowHitboxes", desc = "Show hitboxes", category = "Visuals", func = function() showHitboxes() end, canFavorite = true},
    
    -- Special commands
    {name = "InfiniteYield", desc = "Load Infinite Yield admin", category = "Utility", func = function() loadInfiniteYield() end, canFavorite = true},
    {name = "AntiAFK", desc = "Prevent AFK kick", category = "Utility", func = function() enableAntiAFK() end, canFavorite = true},
    {name = "FixCamera", desc = "Fix camera issues", category = "Utility", func = function() fixCamera() end, canFavorite = true},
    
    -- Settings commands 
    {name = "Set Keybinds", desc = "Configure keyboard shortcuts", category = "Settings", func = function() openKeyBindSettings() end, canFavorite = true},
    {name = "ESP Settings", desc = "Configure ESP options", category = "Settings", func = function() openESPSettings() end, canFavorite = true},
    {name = "Aimbot Config", desc = "Detailed aimbot configuration", category = "Settings", func = function() openAimbotSettings() end, canFavorite = true},
    {name = "GUI Color", desc = "Change GUI color theme", category = "Settings", func = function() openColorSettings() end, canFavorite = true},
    {name = "GUI Scale", desc = "Adjust GUI size", category = "Settings", func = function() openGuiScaleSettings() end, canFavorite = true},
    {name = "Reset Settings", desc = "Reset all settings to defaults", category = "Settings", func = function() resetAllSettings() end, canFavorite = true}
}

-- Categories
local categories = {
    "Favorites",
    "Main",
    "Character",
    "Combat",
    "ESP",
    "Teleport",
    "Players",
    "Animations",
    "Vision",
    "Utility",
    "Fun",
    "Visuals",
    "Settings"
}

-- =====================
-- Function Definitions
-- =====================

-- Reset character (works when game blocks normal reset)
function resetCharacter()
    if not player.Character then
        setStatus("No character to reset")
        return
    end
    
    -- Method 1: Break joints
    pcall(function()
        player.Character:BreakJoints()
    end)
    
    -- Method A: Set health to 0
    pcall(function()
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end)
    
    -- Method B: Remove humanoid
    pcall(function()
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:Destroy()
        end
    end)
    
    -- Method C: Load character
    pcall(function()
        player:LoadCharacter()
    end)
    
    -- Method D: Remove vital parts
    pcall(function()
        local head = player.Character:FindFirstChild("Head")
        if head then
            head:Destroy()
        end
    end)
    
    setStatus("Character reset")
end

-- Set walk speed
function setWalkSpeed(speed)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    player.Character.Humanoid.WalkSpeed = speed
    walkSpeed = speed
    setStatus("Walk speed set to " .. speed)
end

-- Set jump power
function setJumpPower(power)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    player.Character.Humanoid.JumpPower = power
    jumpPower = power
    setStatus("Jump power set to " .. power)
end

-- Infinite jump
function toggleInfiniteJump()
    infiniteJump = not infiniteJump
    
    if infiniteJump then
        setStatus("Infinite jump enabled")
    else
        setStatus("Infinite jump disabled")
    end
    
    -- Update keybind settings
    keyBindSettings.InfiniteJump.enabled = infiniteJump
    saveSettings()
end

-- Noclip (walk through walls)
function toggleNoclip()
    noclip = not noclip
    
    if noclip then
        if getgenv().NoclipLoop then
            getgenv().NoclipLoop:Disconnect()
        end
        
        getgenv().NoclipLoop = RunService.Stepped:Connect(function()
            if not noclip then 
                getgenv().NoclipLoop:Disconnect()
                getgenv().NoclipLoop = nil
                
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
                return 
            end
            
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        setStatus("Noclip enabled")
    else
        if getgenv().NoclipLoop then
            getgenv().NoclipLoop:Disconnect()
            getgenv().NoclipLoop = nil
        end
        
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        setStatus("Noclip disabled")
    end
    
    -- Update keybind settings
    keyBindSettings.Noclip.enabled = noclip
    saveSettings()
end

-- Fly mode
function toggleFly()
    flying = not flying
    
    if flying then
        -- Start fly code
        if getgenv().FlyPart then
            getgenv().FlyPart:Destroy()
        end
        
        local flyPart = Instance.new("BodyVelocity")
        flyPart.Velocity = Vector3.new(0, 0, 0)
        flyPart.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyPart.Name = "FlyPart"
        getgenv().FlyPart = flyPart
        
        -- Character movement
        local controls = {
            f = false,
            b = false,
            l = false,
            r = false,
            q = false,
            e = false
        }
        
        if getgenv().FlyConnection1 then
            getgenv().FlyConnection1:Disconnect()
        end
        
        if getgenv().FlyConnection2 then
            getgenv().FlyConnection2:Disconnect()
        end
        
        -- Keyboard controls
        getgenv().FlyConnection1 = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then controls.f = true end
            if input.KeyCode == Enum.KeyCode.S then controls.b = true end
            if input.KeyCode == Enum.KeyCode.A then controls.l = true end
            if input.KeyCode == Enum.KeyCode.D then controls.r = true end
            if input.KeyCode == Enum.KeyCode.Q then controls.q = true end
            if input.KeyCode == Enum.KeyCode.E then controls.e = true end
        end)
        
        getgenv().FlyConnection2 = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then controls.f = false end
            if input.KeyCode == Enum.KeyCode.S then controls.b = false end
            if input.KeyCode == Enum.KeyCode.A then controls.l = false end
            if input.KeyCode == Enum.KeyCode.D then controls.r = false end
            if input.KeyCode == Enum.KeyCode.Q then controls.q = false end
            if input.KeyCode == Enum.KeyCode.E then controls.e = false end
        end)
        
        if getgenv().FlyLoop then
            getgenv().FlyLoop:Disconnect()
        end
        
        local function fly()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local flyPartInstance = rootPart:FindFirstChild("FlyPart") or flyPart:Clone()
            flyPartInstance.Parent = rootPart
            
            getgenv().FlyLoop = RunService.Heartbeat:Connect(function()
                if not flying then 
                    getgenv().FlyLoop:Disconnect()
                    getgenv().FlyLoop = nil
                    
                    if flyPartInstance and flyPartInstance.Parent then
                        flyPartInstance:Destroy()
                    end
                    
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.PlatformStand = false
                    end
                    return 
                end
                
                player.Character.Humanoid.PlatformStand = true
                
                local direction = Vector3.new(0, 0, 0)
                
                -- Move based on camera direction
                local lookVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                
                if controls.f then
                    direction = direction + lookVector
                end
                if controls.b then
                    direction = direction - lookVector
                end
                if controls.r then
                    direction = direction + rightVector
                end
                if controls.l then
                    direction = direction - rightVector
                end
                if controls.q then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if controls.e then
                    direction = direction + Vector3.new(0, -1, 0)
                end
                
                if direction.Magnitude > 0 then
                    direction = direction.Unit
                end
                
                flyPartInstance.Velocity = direction * flySpeed * 50
            end)
        end
        
        fly()
        setStatus("Fly mode enabled - Use WASDQE to move")
    else
        -- Disable fly mode
        if getgenv().FlyLoop then
            getgenv().FlyLoop:Disconnect()
            getgenv().FlyLoop = nil
        end
        
        if getgenv().FlyConnection1 then
            getgenv().FlyConnection1:Disconnect()
            getgenv().FlyConnection1 = nil
        end
        
        if getgenv().FlyConnection2 then
            getgenv().FlyConnection2:Disconnect()
            getgenv().FlyConnection2 = nil
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local flyPartInstance = player.Character.HumanoidRootPart:FindFirstChild("FlyPart")
            if flyPartInstance then
                flyPartInstance:Destroy()
            end
        end
        
        if getgenv().FlyPart then
            pcall(function()
                getgenv().FlyPart:Destroy()
            end)
            getgenv().FlyPart = nil
        end
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
        
        setStatus("Fly mode disabled")
    end
    
    -- Update keybind settings
    keyBindSettings.Fly.enabled = flying
    saveSettings()
end

-- X-Ray (see through walls)
function toggleXRay()
    xray = not xray
    
    if xray then
        -- Make walls transparent
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) and part.Transparency < 0.8 and not part:IsA("Terrain") then
                if not part:FindFirstChild("OriginalTransparency") then
                    local originalValue = Instance.new("NumberValue")
                    originalValue.Name = "OriginalTransparency"
                    originalValue.Value = part.Transparency
                    originalValue.Parent = part
                end
                part.Transparency = 0.8
            end
        end
        setStatus("X-Ray enabled")
    else
        -- Restore wall transparency
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:FindFirstChild("OriginalTransparency") then
                part.Transparency = part.OriginalTransparency.Value
                part.OriginalTransparency:Destroy()
            end
        end
        setStatus("X-Ray disabled")
    end
end

-- Toggle specific ESP option
function toggleESPOption(option)
    if option == "boxes" then
        espSettings.boxes = not espSettings.boxes
        setStatus("ESP Boxes: " .. (espSettings.boxes and "Enabled" or "Disabled"))
    elseif option == "names" then
        espSettings.names = not espSettings.names
        setStatus("ESP Names: " .. (espSettings.names and "Enabled" or "Disabled"))
    elseif option == "tracers" then
        espSettings.tracers = not espSettings.tracers
        setStatus("ESP Tracers: " .. (espSettings.tracers and "Enabled" or "Disabled"))
    elseif option == "teamCheck" then
        espSettings.teamCheck = not espSettings.teamCheck
        setStatus("ESP Team Check: " .. (espSettings.teamCheck and "Enabled" or "Disabled"))
    elseif option == "teamColor" then
        espSettings.teamColor = not espSettings.teamColor
        setStatus("ESP Team Color: " .. (espSettings.teamColor and "Enabled" or "Disabled"))
    elseif option == "chams" then
        espSettings.chams = not espSettings.chams
        setStatus("ESP Chams: " .. (espSettings.chams and "Enabled" or "Disabled"))
    elseif option == "showHealthBar" then
        espSettings.showHealthBar = not espSettings.showHealthBar
        setStatus("ESP Health Bars: " .. (espSettings.showHealthBar and "Enabled" or "Disabled"))
    end
    
    -- Apply changes if ESP is active
    if espSettings.enabled then
        updateESP()
    end
    
    -- Save settings
    saveSettings()
end

-- ESP (see players and objects)
function toggleESP()
    espSettings.enabled = not espSettings.enabled
    
    if espSettings.enabled then
        -- Start ESP code
        applyESP()
        
        -- Create update loop
        if getgenv().ESPUpdateLoop then
            getgenv().ESPUpdateLoop:Disconnect()
        end
        
        getgenv().ESPUpdateLoop = RunService.RenderStepped:Connect(function()
            if not espSettings.enabled then
                getgenv().ESPUpdateLoop:Disconnect()
                getgenv().ESPUpdateLoop = nil
                
                -- Clean up ESP elements
                for _, plyr in ipairs(Players:GetPlayers()) do
                    cleanupESP(plyr)
                end
                return
            end
            
            updateESP()
        end)
        
        setStatus("ESP enabled")
    else
        -- Disable ESP code, clean up elements
        if getgenv().ESPUpdateLoop then
            getgenv().ESPUpdateLoop:Disconnect()
            getgenv().ESPUpdateLoop = nil
        end
        
        for _, plyr in ipairs(Players:GetPlayers()) do
            cleanupESP(plyr)
        end
        
        setStatus("ESP disabled")
    end
    
    -- Update keybind settings
    keyBindSettings.ESP.enabled = espSettings.enabled
    saveSettings()
end

-- Apply ESP to all players
function applyESP()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            addESPToPlayer(otherPlayer)
        end
    end
    
    -- Connect to PlayerAdded event to ESP new players
    Players.PlayerAdded:Connect(function(newPlayer)
        if espSettings.enabled and newPlayer ~= player then
            addESPToPlayer(newPlayer)
        end
    end)
end

-- Add ESP to a specific player
function addESPToPlayer(targetPlayer)
    if not targetPlayer.Character then
        -- Wait for character to load
        targetPlayer.CharacterAdded:Connect(function(char)
            if espSettings.enabled then
                createESPForCharacter(targetPlayer, char)
            end
        end)
        return
    end
    
    createESPForCharacter(targetPlayer, targetPlayer.Character)
end

-- Create ESP elements for a character
function createESPForCharacter(targetPlayer, character)
    -- Skip if no character or required parts
    if not character or not character:FindFirstChild("HumanoidRootPart") or 
       not character:FindFirstChild("Humanoid") or not character:FindFirstChild("Head") then
        return
    end
    
    -- Check team status if team check is enabled
    local isFriendly = false
    if espSettings.teamCheck and player.Team and targetPlayer.Team then
        isFriendly = player.Team == targetPlayer.Team
    end
    
    if espSettings.teamCheck and isFriendly then
        -- Don't ESP teammates if team check is on
        return
    end
    
    -- Determine color
    local espColor = Color3.fromRGB(255, 0, 0) -- Enemy (red)
    
    if espSettings.teamColor and targetPlayer.Team then
        espColor = targetPlayer.TeamColor.Color
    elseif isFriendly then
        espColor = Color3.fromRGB(0, 255, 0) -- Friendly (green)
    end
    
    -- Create ESP container
    local espContainer = Instance.new("Folder")
    espContainer.Name = "KILASIK_ESP_Container"
    espContainer.Parent = character
    
    -- Create box ESP
    if espSettings.boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "BoxESP"
        box.Adornee = character.HumanoidRootPart
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = character.HumanoidRootPart.Size + Vector3.new(2, 5, 2)
        box.Transparency = 0.7
        box.Color3 = espColor
        box.Parent = espContainer
    end
    
    -- Create name ESP
    if espSettings.names then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "NameESP"
        nameTag.Adornee = character.Head
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.StudsOffset = Vector3.new(0, 2, 0)
        nameTag.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "PlayerName"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = espColor
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 18
        nameLabel.Parent = nameTag
        
        -- Create distance label
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 20)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "0m"
        distanceLabel.TextColor3 = espColor
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.Font = Enum.Font.SourceSans
        distanceLabel.TextSize = 16
        distanceLabel.Parent = nameTag
        
        nameTag.Parent = espContainer
    end
    
    -- Create health bar
    if espSettings.showHealthBar then
        local healthGui = Instance.new("BillboardGui")
        healthGui.Name = "HealthESP"
        healthGui.Adornee = character.Head
        healthGui.Size = UDim2.new(0, 100, 0, 10)
        healthGui.StudsOffset = Vector3.new(0, 3.5, 0)
        healthGui.AlwaysOnTop = true
        
        local healthBack = Instance.new("Frame")
        healthBack.Name = "Background"
        healthBack.Size = UDim2.new(1, 0, 1, 0)
        healthBack.BackgroundColor3 = Color3.new(0, 0, 0)
        healthBack.BorderSizePixel = 1
        healthBack.BorderColor3 = Color3.new(0, 0, 0)
        healthBack.Parent = healthGui
        
        local healthBar = Instance.new("Frame")
        healthBar.Name = "Bar"
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBack
        
        -- Update health bar based on player's health
        local humanoid = character.Humanoid
        local healthConnection
        
        healthConnection = humanoid.HealthChanged:Connect(function()
            if healthBar and healthBar.Parent then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                
                -- Change color based on health
                if healthPercent > 0.5 then
                    -- Green to yellow gradient
                    local g = 1
                    local r = 2 * (1 - healthPercent)
                    healthBar.BackgroundColor3 = Color3.fromRGB(r * 255, g * 255, 0)
                else
                    -- Yellow to red gradient
                    local r = 1
                    local g = 2 * healthPercent
                    healthBar.BackgroundColor3 = Color3.fromRGB(r * 255, g * 255, 0)
                end
            else
                healthConnection:Disconnect()
            end
        end)
        
        -- Initial health update
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        healthGui.Parent = espContainer
    end
    
    -- Create tracers
    if espSettings.tracers then
        local tracer = Instance.new("Beam")
        tracer.Name = "TracerESP"
        tracer.FaceCamera = true
        tracer.Transparency = NumberSequence.new(0.2)
        tracer.Color = ColorSequence.new(espColor)
        tracer.Width0 = 0.1
        tracer.Width1 = 0.1
        
        -- Create attachments for the beam
        local att1 = Instance.new("Attachment")
        att1.Name = "TracerOrigin"
        att1.Parent = camera.CFrame.Position
        
        local att2 = Instance.new("Attachment")
        att2.Name = "TracerEnd"
        att2.Parent = character.HumanoidRootPart
        
        tracer.Attachment0 = att1
        tracer.Attachment1 = att2
        tracer.Parent = espContainer
    end
    
    -- Create chams (highlights)
    if espSettings.chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ChamsESP"
        highlight.FillColor = espColor
        highlight.OutlineColor = espColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = espContainer
    end
end

-- Clean up ESP for a player
function cleanupESP(target)
    if target.Character then
        -- Remove ESP containers
        for _, obj in ipairs(target.Character:GetChildren()) do
            if obj.Name == "KILASIK_ESP_Container" then
                obj:Destroy()
            end
        end
        
        -- Remove highlights
        local highlight = target.Character:FindFirstChild("KILASIK_ESP_Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

-- Update ESP elements
function updateESP()
    if not espSettings.enabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPos = player.Character.HumanoidRootPart.Position
    
    -- Update ESP for each player
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and
           otherPlayer.Character:FindFirstChild("HumanoidRootPart") and
           otherPlayer.Character:FindFirstChild("Humanoid") then
            
            local character = otherPlayer.Character
            local distance = (character.HumanoidRootPart.Position - playerPos).Magnitude
            
            -- Skip if too far
            if distance > espSettings.maxDistance then
                cleanupESP(otherPlayer)
                continue
            end
            
            -- Check team status
            local isFriendly = false
            if espSettings.teamCheck and player.Team and otherPlayer.Team then
                isFriendly = player.Team == otherPlayer.Team
            end
            
            if espSettings.teamCheck and isFriendly then
                -- Don't ESP teammates if team check is on
                cleanupESP(otherPlayer)
                continue
            end
            
            -- Get or create ESP container
            local espContainer = character:FindFirstChild("KILASIK_ESP_Container")
            if not espContainer then
                addESPToPlayer(otherPlayer)
                espContainer = character:FindFirstChild("KILASIK_ESP_Container")
                if not espContainer then continue end -- Skip if creation failed
            end
            
            -- Update ESP elements
            
            -- Update distance text
            if espSettings.names then
                local nameESP = espContainer:FindFirstChild("NameESP")
                if nameESP then
                    local distanceLabel = nameESP:FindFirstChild("Distance")
                    if distanceLabel then
                        distanceLabel.Text = math.floor(distance) .. "m"
                    end
                end
            end
            
            -- Update tracers
            if espSettings.tracers then
                local tracer = espContainer:FindFirstChild("TracerESP")
                if tracer and tracer:IsA("Beam") then
                    -- Update beam origin to bottom center of screen
                    local viewportSize = camera.ViewportSize
                    local screenCenter = Vector2.new(viewportSize.X/2, viewportSize.Y)
                    local worldPos = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y).Origin
                    
                    if tracer.Attachment0 then
                        tracer.Attachment0.Position = worldPos
                    end
                end
            end
        end
    end
end
-- Open Aimbot settings menu
function openAimbotSettings()
    -- Create settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "AimbotSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 300, 0, 350)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    settingsFrame.BackgroundColor3 = colors.background
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Aimbot Settings"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Settings container
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Size = UDim2.new(1, -20, 1, -40)
    settingsContainer.Position = UDim2.new(0, 10, 0, 35)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.BorderSizePixel = 0
    settingsContainer.ScrollBarThickness = 4
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    settingsContainer.Parent = settingsFrame
    
    -- Settings layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = settingsContainer
    
    -- Add settings
    local yPos = 0
    
    -- 1. Team Check toggle
    addToggleSetting(settingsContainer, "Team Check", aimbotSettings.teamCheck, function(value)
        aimbotSettings.teamCheck = value
        setStatus("Aimbot Team Check: " .. (value and "Enabled" or "Disabled"))
        saveSettings()
    end)
    
    -- 2. Visibility Check toggle
    addToggleSetting(settingsContainer, "Visibility Check", aimbotSettings.visibilityCheck, function(value)
        aimbotSettings.visibilityCheck = value
        setStatus("Aimbot Visibility Check: " .. (value and "Enabled" or "Disabled"))
        saveSettings()
    end)
    
    -- 3. Show FOV Circle toggle
    addToggleSetting(settingsContainer, "Show FOV Circle", aimbotSettings.showFOV, function(value)
        aimbotSettings.showFOV = value
        setStatus("Aimbot FOV Circle: " .. (value and "Shown" or "Hidden"))
        
        if not value and getgenv().FOVCircle then
            getgenv().FOVCircle:Remove()
            getgenv().FOVCircle = nil
        elseif value and aimbotSettings.enabled then
            setAimbotFOV(aimbotSettings.fovSize)
        end
        
        saveSettings()
    end)
    
    -- 4. Wallbang toggle
    addToggleSetting(settingsContainer, "Wallbang", aimbotSettings.wallbangEnabled, function(value)
        aimbotSettings.wallbangEnabled = value
        setStatus("Wallbang: " .. (value and "Enabled" or "Disabled"))
        saveSettings()
    end)
    
    -- 5. FOV Size slider
    addSliderSetting(settingsContainer, "FOV Size", aimbotSettings.fovSize, 10, 500, function(value)
        aimbotSettings.fovSize = value
        setStatus("Aimbot FOV Size: " .. value)
        
        if aimbotSettings.showFOV and aimbotSettings.enabled then
            setAimbotFOV(value)
        end
        
        saveSettings()
    end)
    
    -- 6. Sensitivity slider
    addSliderSetting(settingsContainer, "Sensitivity", aimbotSettings.sensitivity * 100, 1, 100, function(value)
        aimbotSettings.sensitivity = value / 100
        setStatus("Aimbot Sensitivity: " .. value .. "%")
        saveSettings()
    end)
    
    -- 7. Target part dropdown
    local targetParts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    addDropdownSetting(settingsContainer, "Target Part", aimbotSettings.aimPart, targetParts, function(value)
        aimbotSettings.aimPart = value
        setStatus("Aimbot Target Part: " .. value)
        saveSettings()
    end)
    
    -- 8. Toggle Key selector
    addKeyBindSetting(settingsContainer, "Toggle Key", aimbotSettings.toggleKey, function(key)
        aimbotSettings.toggleKey = key
        setStatus("Aimbot Toggle Key set to: " .. key)
        saveSettings()
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        settingsFrame.Parent = gui
    else
        settingsFrame.Parent = player.PlayerGui
    end
    
    -- Auto-size the container
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    return settingsFrame
end

-- Add a toggle setting to a container
function addToggleSetting(container, name, initialValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = colors.neutralDark
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = colors.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = initialValue and colors.success or colors.neutralLight
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(initialValue and 1 or 0, initialValue and -18 or 2, 0.5, -8)
    knob.BackgroundColor3 = colors.text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    
    local toggleValue = initialValue
    
    button.MouseButton1Click:Connect(function()
        toggleValue = not toggleValue
        toggle.BackgroundColor3 = toggleValue and colors.success or colors.neutralLight
        
        -- Animate knob
        local newPos = toggleValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local tween = TweenService:Create(knob, TweenInfo.new(0.2), {Position = newPos})
        tween:Play()
        
        callback(toggleValue)
    end)
    
    frame.Parent = container
    return frame
end

-- Add a slider setting to a container
function addSliderSetting(container, name, initialValue, minValue, maxValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = colors.neutralDark
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = colors.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(initialValue)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = colors.text
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = colors.neutralLight
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = colors.highlight
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((initialValue - minValue) / (maxValue - minValue), -8, 0.5, -8)
    knob.BackgroundColor3 = colors.text
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Slider interaction
    local isDragging = false
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    function updateSlider(mouseX)
        local sliderPosition = math.clamp((mouseX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + sliderPosition * (maxValue - minValue))
        
        -- Update visuals
        sliderFill.Size = UDim2.new(sliderPosition, 0, 1, 0)
        knob.Position = UDim2.new(sliderPosition, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        
        -- Call callback
        callback(value)
    end
    
    frame.Parent = container
    return frame
end

-- Add a dropdown setting to a container
function addDropdownSetting(container, name, initialValue, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = colors.neutralDark
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = colors.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0.5, -10, 0, 30)
    dropdown.Position = UDim2.new(0.5, 0, 0.5, -15)
    dropdown.BackgroundColor3 = colors.button
    dropdown.BorderSizePixel = 0
    dropdown.ClipsDescendants = true
    dropdown.ZIndex = 10
    dropdown.Parent = frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -30, 1, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = initialValue
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextSize = 14
    selectedLabel.TextColor3 = colors.text
    selectedLabel.ZIndex = 11
    selectedLabel.Parent = dropdown
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 14
    arrow.TextColor3 = colors.text
    arrow.ZIndex = 11
    arrow.Parent = dropdown
    
    local dropButton = Instance.new("TextButton")
    dropButton.Size = UDim2.new(1, 0, 1, 0)
    dropButton.BackgroundTransparency = 1
    dropButton.Text = ""
    dropButton.ZIndex = 12
    dropButton.Parent = dropdown
    
    -- Dropdown options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
    optionsFrame.Position = UDim2.new(0, 0, 1, 0)
    optionsFrame.BackgroundColor3 = colors.neutralDark
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 15
    optionsFrame.Parent = dropdown
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsFrame
    
    -- Add options
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        optionButton.BackgroundColor3 = colors.button
        optionButton.BackgroundTransparency = 0.3
        optionButton.Text = option
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.TextColor3 = colors.text
        optionButton.ZIndex = 16
        optionButton.Parent = optionsFrame
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            optionsFrame.Visible = false
            callback(option)
        end)
        
        -- Hover effect
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = colors.buttonHover
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = colors.button
        end)
    end
    
    -- Toggle dropdown
    local dropdownOpen = false
    
    dropButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        optionsFrame.Visible = dropdownOpen
        arrow.Text = dropdownOpen and "▲" or "▼"
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local dropdownPos = dropdown.AbsolutePosition
            local dropdownSize = dropdown.AbsoluteSize
            
            if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
               mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y + (dropdownOpen and optionsFrame.AbsoluteSize.Y or 0) then
                dropdownOpen = false
                optionsFrame.Visible = false
                arrow.Text = "▼"
            end
        end
    end)
    
    frame.Parent = container
    return frame
end

-- Add a key bind setting to a container
function addKeyBindSetting(container, name, initialKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = colors.neutralDark
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = colors.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.5, -10, 0, 30)
    keyButton.Position = UDim2.new(0.5, 0, 0.5, -15)
    keyButton.BackgroundColor3 = colors.button
    keyButton.Text = initialKey
    keyButton.Font = Enum.Font.Gotham
    keyButton.TextSize = 14
    keyButton.TextColor3 = colors.text
    keyButton.BorderSizePixel = 0
    keyButton.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyButton
    
    -- Key binding functionality
    local awaitingInput = false
    
    keyButton.MouseButton1Click:Connect(function()
        if awaitingInput then return end
        
        awaitingInput = true
        keyButton.Text = "Press any key..."
        
        -- Disconnect previous connection if it exists
        if getgenv().KeyBindConnection then
            getgenv().KeyBindConnection:Disconnect()
            getgenv().KeyBindConnection = nil
        end
        
        getgenv().KeyBindConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                keyButton.Text = keyName
                awaitingInput = false
                
                -- Remove the connection
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback(keyName)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyButton.Text = "MouseButton1"
                awaitingInput = false
                
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback("MouseButton1")
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyButton.Text = "MouseButton2"
                awaitingInput = false
                
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback("MouseButton2")
            end
        end)
    end)
    
    frame.Parent = container
    return frame
end

-- Open ESP settings menu
function openESPSettings()
    -- Create settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "ESPSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 300, 0, 350)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    settingsFrame.BackgroundColor3 = colors.background
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "ESP Settings"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Settings container
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Size = UDim2.new(1, -20, 1, -40)
    settingsContainer.Position = UDim2.new(0, 10, 0, 35)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.BorderSizePixel = 0
    settingsContainer.ScrollBarThickness = 4
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    settingsContainer.Parent = settingsFrame
    
    -- Settings layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = settingsContainer
    
    -- Add settings
    local yPos = 0
    
    -- 1. ESP Boxes toggle
    addToggleSetting(settingsContainer, "Show Boxes", espSettings.boxes, function(value)
        espSettings.boxes = value
        setStatus("ESP Boxes: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("boxes")
    end)
    
    -- 2. ESP Names toggle
    addToggleSetting(settingsContainer, "Show Names", espSettings.names, function(value)
        espSettings.names = value
        setStatus("ESP Names: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("names")
    end)
    
    -- 3. ESP Tracers toggle
    addToggleSetting(settingsContainer, "Show Tracers", espSettings.tracers, function(value)
        espSettings.tracers = value
        setStatus("ESP Tracers: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("tracers")
    end)
    
    -- 4. ESP Health Bars toggle
    addToggleSetting(settingsContainer, "Show Health Bars", espSettings.showHealthBar, function(value)
        espSettings.showHealthBar = value
        setStatus("ESP Health Bars: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("showHealthBar")
    end)
    
    -- 5. ESP Team Check toggle
    addToggleSetting(settingsContainer, "Team Check", espSettings.teamCheck, function(value)
        espSettings.teamCheck = value
        setStatus("ESP Team Check: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("teamCheck")
    end)
    
    -- 6. ESP Team Color toggle
    addToggleSetting(settingsContainer, "Use Team Colors", espSettings.teamColor, function(value)
        espSettings.teamColor = value
        setStatus("ESP Team Colors: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("teamColor")
    end)
    
    -- 7. ESP Chams toggle
    addToggleSetting(settingsContainer, "Show Chams", espSettings.chams, function(value)
        espSettings.chams = value
        setStatus("ESP Chams: " .. (value and "Enabled" or "Disabled"))
        toggleESPOption("chams")
    end)
    
    -- 8. ESP Max Distance slider
    addSliderSetting(settingsContainer, "Max Distance", espSettings.maxDistance, 100, 2000, function(value)
        espSettings.maxDistance = value
        setStatus("ESP Max Distance: " .. value)
        saveSettings()
    end)
    
    -- 9. ESP Toggle Key
    addKeyBindSetting(settingsContainer, "Toggle Key", keyBindSettings.ESP.key, function(key)
        keyBindSettings.ESP.key = key
        setStatus("ESP Toggle Key set to: " .. key)
        saveSettings()
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        settingsFrame.Parent = gui
    else
        settingsFrame.Parent = player.PlayerGui
    end
    
    -- Auto-size the container
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    return settingsFrame
end

-- Open key binds settings menu
function openKeyBindSettings()
    -- Create settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "KeyBindSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 350, 0, 400)
    settingsFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    settingsFrame.BackgroundColor3 = colors.background
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Keyboard Shortcuts"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Settings container
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Size = UDim2.new(1, -20, 1, -40)
    settingsContainer.Position = UDim2.new(0, 10, 0, 35)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.BorderSizePixel = 0
    settingsContainer.ScrollBarThickness = 4
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
    settingsContainer.Parent = settingsFrame
    
    -- Settings layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = settingsContainer
    
    -- Add keybind settings
    
    -- Fly keybind
    addKeyBindWithToggle(settingsContainer, "Fly", keyBindSettings.Fly.key, keyBindSettings.Fly.enabled, function(key, enabled)
        keyBindSettings.Fly.key = key
        keyBindSettings.Fly.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= flying then
            toggleFly()
        end
        
        setStatus("Fly keybind set to: " .. key)
        saveSettings()
    end)
    
    -- Noclip keybind
    addKeyBindWithToggle(settingsContainer, "Noclip", keyBindSettings.Noclip.key, keyBindSettings.Noclip.enabled, function(key, enabled)
        keyBindSettings.Noclip.key = key
        keyBindSettings.Noclip.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= noclip then
            toggleNoclip()
        end
        
        setStatus("Noclip keybind set to: " .. key)
        saveSettings()
    end)
    
    -- Speed keybind
    addKeyBindWithToggle(settingsContainer, "Speed Boost", keyBindSettings.Speed.key, keyBindSettings.Speed.enabled, function(key, enabled)
        keyBindSettings.Speed.key = key
        keyBindSettings.Speed.enabled = enabled
        
        -- Apply changes if needed
        if enabled then
            setWalkSpeed(50) -- Speed boost
        else
            setWalkSpeed(16) -- Normal speed
        end
        
        setStatus("Speed keybind set to: " .. key)
        saveSettings()
    end)
    
    -- ESP keybind
    addKeyBindWithToggle(settingsContainer, "ESP", keyBindSettings.ESP.key, keyBindSettings.ESP.enabled, function(key, enabled)
        keyBindSettings.ESP.key = key
        keyBindSettings.ESP.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= espSettings.enabled then
            toggleESP()
        end
        
        setStatus("ESP keybind set to: " .. key)
        saveSettings()
    end)
    
    -- Aimbot keybind
    addKeyBindWithToggle(settingsContainer, "Aimbot", keyBindSettings.Aimbot.key, keyBindSettings.Aimbot.enabled, function(key, enabled)
        keyBindSettings.Aimbot.key = key
        keyBindSettings.Aimbot.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= aimbotSettings.enabled then
            toggleAimbot()
        end
        
        setStatus("Aimbot keybind set to: " .. key)
        saveSettings()
    end)
    
    -- ClickTP keybind
    addKeyBindWithToggle(settingsContainer, "Click Teleport", keyBindSettings.ClickTP.key, keyBindSettings.ClickTP.enabled, function(key, enabled)
        keyBindSettings.ClickTP.key = key
        keyBindSettings.ClickTP.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= getgenv().ClickTPEnabled then
            toggleClickTP()
        end
        
        setStatus("Click Teleport keybind set to: " .. key)
        saveSettings()
    end)
    
    -- Reset keybind
    addKeyBindWithToggle(settingsContainer, "Reset Character", keyBindSettings.Reset.key, keyBindSettings.Reset.enabled, function(key, enabled)
        keyBindSettings.Reset.key = key
        keyBindSettings.Reset.enabled = enabled
        setStatus("Reset Character keybind set to: " .. key)
        saveSettings()
    end)
    
    -- InfiniteJump keybind
    addKeyBindWithToggle(settingsContainer, "Infinite Jump", keyBindSettings.InfiniteJump.key, keyBindSettings.InfiniteJump.enabled, function(key, enabled)
        keyBindSettings.InfiniteJump.key = key
        keyBindSettings.InfiniteJump.enabled = enabled
        
        -- Apply changes if needed
        if enabled ~= infiniteJump then
            toggleInfiniteJump()
        end
        
        setStatus("Infinite Jump keybind set to: " .. key)
        saveSettings()
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        settingsFrame.Parent = gui
    else
        settingsFrame.Parent = player.PlayerGui
    end
    
    -- Auto-size the container
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    return settingsFrame
end

-- Add a keybind with toggle to a container
function addKeyBindWithToggle(container, name, initialKey, initialEnabled, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = colors.neutralDark
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = colors.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Key button
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.35, -10, 0, 30)
    keyButton.Position = UDim2.new(0.4, 0, 0.5, -15)
    keyButton.BackgroundColor3 = colors.button
    keyButton.Text = initialKey
    keyButton.Font = Enum.Font.Gotham
    keyButton.TextSize = 14
    keyButton.TextColor3 = colors.text
    keyButton.BorderSizePixel = 0
    keyButton.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyButton
    
    -- Toggle
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = initialEnabled and colors.success or colors.neutralLight
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(initialEnabled and 1 or 0, initialEnabled and -18 or 2, 0.5, -8)
    knob.BackgroundColor3 = colors.text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggle
    
    -- Key binding functionality
    local awaitingInput = false
    local toggleValue = initialEnabled
    
    keyButton.MouseButton1Click:Connect(function()
        if awaitingInput then return end
        
        awaitingInput = true
        keyButton.Text = "Press any key..."
        
        -- Disconnect previous connection if it exists
        if getgenv().KeyBindConnection then
            getgenv().KeyBindConnection:Disconnect()
            getgenv().KeyBindConnection = nil
        end
        
        getgenv().KeyBindConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                keyButton.Text = keyName
                awaitingInput = false
                
                -- Remove the connection
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback(keyName, toggleValue)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyButton.Text = "MouseButton1"
                awaitingInput = false
                
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback("MouseButton1", toggleValue)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyButton.Text = "MouseButton2"
                awaitingInput = false
                
                getgenv().KeyBindConnection:Disconnect()
                getgenv().KeyBindConnection = nil
                
                callback("MouseButton2", toggleValue)
            end
        end)
    end)
    
    -- Toggle functionality
    toggleButton.MouseButton1Click:Connect(function()
        toggleValue = not toggleValue
        toggle.BackgroundColor3 = toggleValue and colors.success or colors.neutralLight
        
        -- Animate knob
        local newPos = toggleValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local tween = TweenService:Create(knob, TweenInfo.new(0.2), {Position = newPos})
        tween:Play()
        
        callback(keyButton.Text, toggleValue)
    end)
    
    frame.Parent = container
    return frame
end
-- Open GUI scale settings
function openGuiScaleSettings()
    -- Create settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "GuiScaleSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 300, 0, 200)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    settingsFrame.BackgroundColor3 = colors.background
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "GUI Scale Settings"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Settings container
    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(1, -20, 1, -40)
    settingsContainer.Position = UDim2.new(0, 10, 0, 35)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.BorderSizePixel = 0
    settingsContainer.Parent = settingsFrame
    
    -- Info text
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 0, 40)
    infoText.Position = UDim2.new(0, 0, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Adjust the size of the GUI by dragging from the corners"
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 12
    infoText.TextWrapped = true
    infoText.TextColor3 = colors.text
    infoText.Parent = settingsContainer
    
    -- Scale options
    local smallBtn = Instance.new("TextButton")
    smallBtn.Size = UDim2.new(0.3, -10, 0, 40)
    smallBtn.Position = UDim2.new(0, 0, 0, 60)
    smallBtn.BackgroundColor3 = colors.button
    smallBtn.Text = "Small"
    smallBtn.Font = Enum.Font.Gotham
    smallBtn.TextSize = 14
    smallBtn.TextColor3 = colors.text
    smallBtn.BorderSizePixel = 0
    smallBtn.Parent = settingsContainer
    
    local smallBtnCorner = Instance.new("UICorner")
    smallBtnCorner.CornerRadius = UDim.new(0, 6)
    smallBtnCorner.Parent = smallBtn
    
    local mediumBtn = Instance.new("TextButton")
    mediumBtn.Size = UDim2.new(0.3, -10, 0, 40)
    mediumBtn.Position = UDim2.new(0.35, 0, 0, 60)
    mediumBtn.BackgroundColor3 = colors.button
    mediumBtn.Text = "Medium"
    mediumBtn.Font = Enum.Font.Gotham
    mediumBtn.TextSize = 14
    mediumBtn.TextColor3 = colors.text
    mediumBtn.BorderSizePixel = 0
    mediumBtn.Parent = settingsContainer
    
    local mediumBtnCorner = Instance.new("UICorner")
    mediumBtnCorner.CornerRadius = UDim.new(0, 6)
    mediumBtnCorner.Parent = mediumBtn
    
    local largeBtn = Instance.new("TextButton")
    largeBtn.Size = UDim2.new(0.3, -10, 0, 40)
    largeBtn.Position = UDim2.new(0.7, 0, 0, 60)
    largeBtn.BackgroundColor3 = colors.button
    largeBtn.Text = "Large"
    largeBtn.Font = Enum.Font.Gotham
    largeBtn.TextSize = 14
    largeBtn.TextColor3 = colors.text
    largeBtn.BorderSizePixel = 0
    largeBtn.Parent = settingsContainer
    
    local largeBtnCorner = Instance.new("UICorner")
    largeBtnCorner.CornerRadius = UDim.new(0, 6)
    largeBtnCorner.Parent = largeBtn
    
    -- Reset button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, 40)
    resetBtn.Position = UDim2.new(0, 0, 0, 110)
    resetBtn.BackgroundColor3 = colors.highlight
    resetBtn.Text = "Reset to Default"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.TextColor3 = colors.text
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = settingsContainer
    
    local resetBtnCorner = Instance.new("UICorner")
    resetBtnCorner.CornerRadius = UDim.new(0, 6)
    resetBtnCorner.Parent = resetBtn
    
    -- Button functions
    smallBtn.MouseButton1Click:Connect(function()
        local mainFrame = findMainGUI():FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Size = UDim2.new(0, 400, 0, 250)
            saveGuiSettings()
        end
    end)
    
    mediumBtn.MouseButton1Click:Connect(function()
        local mainFrame = findMainGUI():FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Size = UDim2.new(0, 550, 0, 350)
            saveGuiSettings()
        end
    end)
    
    largeBtn.MouseButton1Click:Connect(function()
        local mainFrame = findMainGUI():FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Size = UDim2.new(0, 700, 0, 450)
            saveGuiSettings()
        end
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        local mainFrame = findMainGUI():FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Size = originalGuiSize
            saveGuiSettings()
        end
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        settingsFrame.Parent = gui
    else
        settingsFrame.Parent = player.PlayerGui
    end
    
    return settingsFrame
end

-- Reset all settings to defaults
function resetAllSettings()
    -- Reset ESP settings
    espSettings = {
        enabled = false,
        boxes = true,
        names = true,
        distances = true,
        teamCheck = true,
        teamColor = true,
        tracers = false,
        chams = false,
        showHealthBar = true,
        maxDistance = 1000
    }
    
    -- Reset aimbot settings
    aimbotSettings = {
        enabled = false,
        teamCheck = true,
        visibilityCheck = true,
        aimPart = "Head",
        sensitivity = 0.5,
        fovSize = 100,
        showFOV = true,
        toggleKey = "B",
        wallbangEnabled = false
    }
    
    -- Reset keybind settings
    keyBindSettings = {
        Fly = {key = "F", enabled = false},
        Noclip = {key = "N", enabled = false},
        Speed = {key = "LeftShift", enabled = false},
        ESP = {key = "E", enabled = false},
        Aimbot = {key = "B", enabled = false},
        ClickTP = {key = "LeftControl", enabled = false},
        Reset = {key = "R", enabled = false},
        InfiniteJump = {key = "Space", enabled = false}
    }
    
    -- Reset colors
    colors = {
        background = Color3.fromRGB(25, 25, 30),
        header = Color3.fromRGB(35, 35, 40),
        button = Color3.fromRGB(45, 45, 55),
        buttonHover = Color3.fromRGB(55, 55, 65),
        buttonSelected = Color3.fromRGB(65, 105, 225),
        text = Color3.fromRGB(240, 240, 240),
        highlight = Color3.fromRGB(65, 105, 225),
        warning = Color3.fromRGB(200, 60, 60),
        success = Color3.fromRGB(60, 180, 75),
        neutralLight = Color3.fromRGB(70, 70, 85),
        neutralDark = Color3.fromRGB(40, 40, 50),
        shadow = Color3.fromRGB(15, 15, 20),
        categoryBG = Color3.fromRGB(30, 30, 35),
        favorite = Color3.fromRGB(255, 215, 0)
    }
    
    -- Reset favorites
    favoriteCommands = {}
    
    -- Save all settings
    saveSettings()
    
    -- Recreate GUI for the changes to take effect
    local gui = findMainGUI()
    if gui then
        gui:Destroy()
    end
    
    -- Rebuild GUI
    createMainGUI()
    
    setStatus("All settings reset to defaults")
end

-- Save current GUI settings
function saveGuiSettings()
    local mainFrame = findMainGUI():FindFirstChild("MainFrame")
    if mainFrame then
        pcall(function()
            if writefile then
                local settings = {
                    size = {
                        width = mainFrame.Size.X.Offset,
                        height = mainFrame.Size.Y.Offset
                    }
                }
                
                writefile("KILASIK_gui_settings.json", HttpService:JSONEncode(settings))
            end
        end)
    end
end

-- Load GUI settings
function loadGuiSettings()
    pcall(function()
        if readfile and isfile and isfile("KILASIK_gui_settings.json") then
            local success, settings = pcall(function()
                return HttpService:JSONDecode(readfile("KILASIK_gui_settings.json"))
            end)
            
            if success and settings.size then
                return UDim2.new(0, settings.size.width, 0, settings.size.height)
            end
        end
    end)
    
    return originalGuiSize
end

-- Open color settings menu
function openColorSettings()
    -- Create settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "ColorSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 300, 0, 400)
    settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    settingsFrame.BackgroundColor3 = colors.background
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Active = true
    settingsFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Color Settings"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = settingsFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Settings container
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Size = UDim2.new(1, -20, 1, -40)
    settingsContainer.Position = UDim2.new(0, 10, 0, 35)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.BorderSizePixel = 0
    settingsContainer.ScrollBarThickness = 4
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
    settingsContainer.Parent = settingsFrame
    
    -- Preset themes
    local themesTitle = Instance.new("TextLabel")
    themesTitle.Size = UDim2.new(1, 0, 0, 30)
    themesTitle.BackgroundTransparency = 1
    themesTitle.Text = "Preset Themes"
    themesTitle.Font = Enum.Font.GothamBold
    themesTitle.TextSize = 16
    themesTitle.TextColor3 = colors.text
    themesTitle.Parent = settingsContainer
    
    -- Preset theme buttons
    local themes = {
        {name = "Dark Blue", primary = Color3.fromRGB(35, 35, 50), secondary = Color3.fromRGB(65, 105, 225)},
        {name = "Dark Red", primary = Color3.fromRGB(40, 30, 30), secondary = Color3.fromRGB(180, 60, 60)},
        {name = "Dark Green", primary = Color3.fromRGB(30, 40, 30), secondary = Color3.fromRGB(60, 180, 75)},
        {name = "Dark Purple", primary = Color3.fromRGB(40, 30, 50), secondary = Color3.fromRGB(130, 60, 200)},
        {name = "Neon", primary = Color3.fromRGB(20, 20, 20), secondary = Color3.fromRGB(0, 255, 140)}
    }
    
    local themeButtons = {}
    for i, theme in ipairs(themes) do
        local themeBtn = Instance.new("Frame")
        themeBtn.Size = UDim2.new(0.48, 0, 0, 70)
        themeBtn.Position = UDim2.new(i % 2 == 0 and 0.52 or 0, 0, 0, 40 + math.floor((i-1) / 2) * 80)
        themeBtn.BackgroundColor3 = theme.primary
        themeBtn.BorderSizePixel = 0
        themeBtn.Parent = settingsContainer
        
        local themeBtnCorner = Instance.new("UICorner")
        themeBtnCorner.CornerRadius = UDim.new(0, 6)
        themeBtnCorner.Parent = themeBtn
        
        local themeAccent = Instance.new("Frame")
        themeAccent.Size = UDim2.new(0, 10, 1, 0)
        themeAccent.Position = UDim2.new(0, 0, 0, 0)
        themeAccent.BackgroundColor3 = theme.secondary
        themeAccent.BorderSizePixel = 0
        themeAccent.Parent = themeBtn
        
        local themeAccentCorner = Instance.new("UICorner")
        themeAccentCorner.CornerRadius = UDim.new(0, 6)
        themeAccentCorner.Parent = themeAccent
        
        local coverFrame = Instance.new("Frame")
        coverFrame.Size = UDim2.new(0, 5, 1, 0)
        coverFrame.Position = UDim2.new(0, 5, 0, 0)
        coverFrame.BackgroundColor3 = theme.primary
        coverFrame.BorderSizePixel = 0
        coverFrame.ZIndex = 2
        coverFrame.Parent = themeBtn
        
        local themeName = Instance.new("TextLabel")
        themeName.Size = UDim2.new(1, -20, 1, 0)
        themeName.Position = UDim2.new(0, 20, 0, 0)
        themeName.BackgroundTransparency = 1
        themeName.Text = theme.name
        themeName.Font = Enum.Font.GothamBold
        themeName.TextSize = 16
        themeName.TextColor3 = Color3.fromRGB(255, 255, 255)
        themeName.TextXAlignment = Enum.TextXAlignment.Left
        themeName.Parent = themeBtn
        
        local themeButton = Instance.new("TextButton")
        themeButton.Size = UDim2.new(1, 0, 1, 0)
        themeButton.BackgroundTransparency = 1
        themeButton.Text = ""
        themeButton.Parent = themeBtn
        
        themeButton.MouseButton1Click:Connect(function()
            applyColorTheme(theme.primary, theme.secondary)
        end)
        
        table.insert(themeButtons, themeBtn)
    end
    
    -- Apply button at the bottom
    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(1, 0, 0, 40)
    applyBtn.Position = UDim2.new(0, 0, 0, 550)
    applyBtn.BackgroundColor3 = colors.highlight
    applyBtn.Text = "Apply Colors"
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 16
    applyBtn.TextColor3 = colors.text
    applyBtn.BorderSizePixel = 0
    applyBtn.Parent = settingsContainer
    
    local applyBtnCorner = Instance.new("UICorner")
    applyBtnCorner.CornerRadius = UDim.new(0, 6)
    applyBtnCorner.Parent = applyBtn
    
    applyBtn.MouseButton1Click:Connect(function()
        -- Apply custom colors
        saveSettings()
        
        -- Recreate GUI
        local gui = findMainGUI()
        if gui then
            gui:Destroy()
        end
        
        createMainGUI()
        settingsFrame:Destroy()
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        settingsFrame.Parent = gui
    else
        settingsFrame.Parent = player.PlayerGui
    end
    
    return settingsFrame
end

-- Apply a color theme
function applyColorTheme(primary, secondary)
    -- Update colors
    colors.background = primary
    colors.header = Color3.new(
        primary.R * 1.2,
        primary.G * 1.2,
        primary.B * 1.2
    )
    colors.button = Color3.new(
        primary.R * 1.5,
        primary.G * 1.5, 
        primary.B * 1.5
    )
    colors.buttonHover = Color3.new(
        primary.R * 1.8,
        primary.G * 1.8,
        primary.B * 1.8
    )
    colors.buttonSelected = secondary
    colors.highlight = secondary
    colors.categoryBG = Color3.new(
        primary.R * 1.1,
        primary.G * 1.1,
        primary.B * 1.1
    )
    
    setStatus("Color theme applied")
    saveSettings()
}

-- Save settings to file
function saveSettings()
    pcall(function()
        if writefile then
            local settings = {
                esp = espSettings,
                aimbot = aimbotSettings,
                keyBinds = keyBindSettings,
                favorites = favoriteCommands,
                colors = {
                    background = {colors.background.R, colors.background.G, colors.background.B},
                    header = {colors.header.R, colors.header.G, colors.header.B},
                    button = {colors.button.R, colors.button.G, colors.button.B},
                    buttonHover = {colors.buttonHover.R, colors.buttonHover.G, colors.buttonHover.B},
                    buttonSelected = {colors.buttonSelected.R, colors.buttonSelected.G, colors.buttonSelected.B},
                    highlight = {colors.highlight.R, colors.highlight.G, colors.highlight.B},
                    categoryBG = {colors.categoryBG.R, colors.categoryBG.G, colors.categoryBG.B}
                }
            }
            
            writefile("KILASIK_settings.json", HttpService:JSONEncode(settings))
        end
    end)
end

-- Load settings from file
function loadSettings()
    pcall(function()
        if readfile and isfile and isfile("KILASIK_settings.json") then
            local success, settings = pcall(function()
                return HttpService:JSONDecode(readfile("KILASIK_settings.json"))
            end)
            
            if success then
                -- Load ESP settings
                if settings.esp then
                    for key, value in pairs(settings.esp) do
                        espSettings[key] = value
                    end
                end
                
                -- Load aimbot settings
                if settings.aimbot then
                    for key, value in pairs(settings.aimbot) do
                        aimbotSettings[key] = value
                    end
                end
                
                -- Load keybind settings
                if settings.keyBinds then
                    for key, value in pairs(settings.keyBinds) do
                        keyBindSettings[key] = value
                    end
                end
                
                -- Load favorites
                if settings.favorites then
                    favoriteCommands = settings.favorites
                end
                
                -- Load colors
                if settings.colors then
                    if settings.colors.background then
                        colors.background = Color3.new(
                            settings.colors.background[1],
                            settings.colors.background[2],
                            settings.colors.background[3]
                        )
                    end
                    
                    if settings.colors.header then
                        colors.header = Color3.new(
                            settings.colors.header[1],
                            settings.colors.header[2],
                            settings.colors.header[3]
                        )
                    end
                    
                    if settings.colors.button then
                        colors.button = Color3.new(
                            settings.colors.button[1],
                            settings.colors.button[2],
                            settings.colors.button[3]
                        )
                    end
                    
                    if settings.colors.buttonHover then
                        colors.buttonHover = Color3.new(
                            settings.colors.buttonHover[1],
                            settings.colors.buttonHover[2],
                            settings.colors.buttonHover[3]
                        )
                    end
                    
                    if settings.colors.buttonSelected then
                        colors.buttonSelected = Color3.new(
                            settings.colors.buttonSelected[1],
                            settings.colors.buttonSelected[2],
                            settings.colors.buttonSelected[3]
                        )
                    end
                    
                    if settings.colors.highlight then
                        colors.highlight = Color3.new(
                            settings.colors.highlight[1],
                            settings.colors.highlight[2],
                            settings.colors.highlight[3]
                        )
                    end
                    
                    if settings.colors.categoryBG then
                        colors.categoryBG = Color3.new(
                            settings.colors.categoryBG[1],
                            settings.colors.categoryBG[2],
                            settings.colors.categoryBG[3]
                        )
                    end
                end
            end
        end
    end)
end

-- Set aimbot FOV size
function setAimbotFOV(size)
    aimbotSettings.fovSize = size
    
    -- Update FOV circle if it exists
    if aimbotSettings.enabled and aimbotSettings.showFOV then
        pcall(function()
            -- Remove existing FOV circle
            if getgenv().FOVCircle then
                getgenv().FOVCircle:Remove()
            end
            
            -- Create new FOV circle
            local fovcircle = Drawing.new("Circle")
            fovcircle.Visible = true
            fovcircle.Radius = size
            fovcircle.Thickness = 1
            fovcircle.Transparency = 1
            fovcircle.Color = Color3.fromRGB(255, 255, 255)
            fovcircle.Position = camera.ViewportSize / 2
            
            getgenv().FOVCircle = fovcircle
        end)
    end
    
    setStatus("Aimbot FOV size set to: " .. size)
}

-- Toggle clickTP
function toggleClickTP()
    local clickTPEnabled = not getgenv().ClickTPEnabled
    
    if clickTPEnabled then
        if getgenv().ClickTPConnection then
            getgenv().ClickTPConnection:Disconnect()
            getgenv().ClickTPConnection = nil
        end
        
        getgenv().ClickTPConnection = mouse.Button1Down:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode[keyBindSettings.ClickTP.key]) then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                end
            end
        end)
        setStatus("Click Teleport enabled - " .. keyBindSettings.ClickTP.key .. "+Click to teleport")
    else
        if getgenv().ClickTPConnection then
            getgenv().ClickTPConnection:Disconnect()
            getgenv().ClickTPConnection = nil
        end
        setStatus("Click Teleport disabled")
    end
    
    getgenv().ClickTPEnabled = clickTPEnabled
    keyBindSettings.ClickTP.enabled = clickTPEnabled
    saveSettings()
}

-- Open player selection menu for various commands
function openPlayerSelectionMenu(action)
    -- Create selection frame
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Name = "PlayerSelectionFrame"
    selectionFrame.Size = UDim2.new(0, 300, 0, 350)
    selectionFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    selectionFrame.BackgroundColor3 = colors.background
    selectionFrame.BorderSizePixel = 0
    selectionFrame.Active = true
    selectionFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = selectionFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    
    -- Set title based on action
    if action == "tp" then
        titleLabel.Text = "Teleport to Player"
    elseif action == "spectate" then
        titleLabel.Text = "Spectate Player"
    elseif action == "goto" then
        titleLabel.Text = "Go to Player"
    elseif action == "bring" then
        titleLabel.Text = "Bring Player"
    elseif action == "fling" then
        titleLabel.Text = "Fling Player"
    else
        titleLabel.Text = "Select Player"
    end
    
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = selectionFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Player container
    local playerContainer = Instance.new("ScrollingFrame")
    playerContainer.Size = UDim2.new(1, -20, 1, -40)
    playerContainer.Position = UDim2.new(0, 10, 0, 35)
    playerContainer.BackgroundTransparency = 1
    playerContainer.BorderSizePixel = 0
    playerContainer.ScrollBarThickness = 4
    playerContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    playerContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will adjust based on player count
    playerContainer.Parent = selectionFrame
    
    -- List layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = playerContainer
    
    -- Add players
    local players = Players:GetPlayers()
    
    for i, plr in ipairs(players) do
        if plr ~= player then -- Don't include local player
            local playerButton = Instance.new("Frame")
            playerButton.Size = UDim2.new(1, 0, 0, 50)
            playerButton.BackgroundColor3 = colors.button
            playerButton.BorderSizePixel = 0
            
            local playerCorner = Instance.new("UICorner")
            playerCorner.CornerRadius = UDim.new(0, 6)
            playerCorner.Parent = playerButton
            
            -- Player icon (try to get avatar)
            local playerIcon = Instance.new("ImageLabel")
            playerIcon.Size = UDim2.new(0, 40, 0, 40)
            playerIcon.Position = UDim2.new(0, 5, 0, 5)
            playerIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            playerIcon.BorderSizePixel = 0
            
            -- Try to load player avatar
            pcall(function()
                local userId = plr.UserId
                local thumbType = Enum.ThumbnailType.HeadShot
                local thumbSize = Enum.ThumbnailSize.Size420x420
                local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
                playerIcon.Image = content
            end)
            
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 6)
            iconCorner.Parent = playerIcon
            
            playerIcon.Parent = playerButton
            
            -- Player name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -60, 0.6, 0)
            nameLabel.Position = UDim2.new(0, 55, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.Font = Enum.Font.GothamSemibold
            nameLabel.TextSize = 14
            nameLabel.TextColor3 = colors.text
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = playerButton
            
            -- Player info (team, etc)
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, -60, 0.4, 0)
            infoLabel.Position = UDim2.new(0, 55, 0.6, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 12
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Add team info if available
            if plr.Team then
                infoLabel.Text = "Team: " .. plr.Team.Name
                nameLabel.TextColor3 = plr.TeamColor.Color
            else
                infoLabel.Text = "No Team"
            end
            
            infoLabel.Parent = playerButton
            
            -- Click button
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = playerButton
            
            -- Hover effect
            clickBtn.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = colors.buttonHover
            end)
            
            clickBtn.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = colors.button
            end)
            
            -- Click function based on action
            clickBtn.MouseButton1Click:Connect(function()
                if action == "tp" or action == "goto" then
                    teleportToPlayer(plr.Name)
                elseif action == "spectate" then
                    spectatePlayer(plr.Name)
                elseif action == "bring" then
                    bringPlayer(plr.Name)
                elseif action == "fling" then
                    flingPlayer(plr.Name)
                end
                
                selectionFrame:Destroy()
            end)
            
            playerButton.Parent = playerContainer
        end
    end
    
    -- Adjust canvas size
    playerContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        selectionFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        selectionFrame.Parent = gui
    else
        selectionFrame.Parent = player.PlayerGui
    end
    
    return selectionFrame
end

-- Open fake chat prompt
function openFakeChatPrompt()
    -- Create prompt frame
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = "FakeChatPromptFrame"
    promptFrame.Size = UDim2.new(0, 300, 0, 150)
    promptFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    promptFrame.BackgroundColor3 = colors.background
    promptFrame.BorderSizePixel = 0
    promptFrame.Active = true
    promptFrame.Draggable = true
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = promptFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = colors.header
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Fake Chat Message"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = colors.text
    titleLabel.Parent = promptFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 10)
    titleCover.Position = UDim2.new(0, 0, 1, -10)
    titleCover.BackgroundColor3 = colors.header
    titleCover.BorderSizePixel = 0
    titleCover.ZIndex = 0
    titleCover.Parent = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = colors.warning
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = colors.text
    closeBtn.Parent = titleLabel
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    -- Player name input
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.3, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 10, 0, 40)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Player Name:"
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = colors.text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = promptFrame
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.65, 0, 0, 30)
    nameInput.Position = UDim2.new(0.35, 0, 0, 35)
    nameInput.BackgroundColor3 = colors.neutralDark
    nameInput.BorderSizePixel = 0
    nameInput.PlaceholderText = "Enter player name..."
    nameInput.Text = ""
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextSize = 14
    nameInput.TextColor3 = colors.text
    nameInput.ClearTextOnFocus = false
    nameInput.Parent = promptFrame
    
    local nameInputCorner = Instance.new("UICorner")
    nameInputCorner.CornerRadius = UDim.new(0, 6)
    nameInputCorner.Parent = nameInput
    
    -- Message input
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(0.3, 0, 0, 20)
    messageLabel.Position = UDim2.new(0, 10, 0, 80)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "Message:"
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = colors.text
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = promptFrame
    
    local messageInput = Instance.new("TextBox")
    messageInput.Size = UDim2.new(0.65, 0, 0, 30)
    messageInput.Position = UDim2.new(0.35, 0, 0, 75)
    messageInput.BackgroundColor3 = colors.neutralDark
    messageInput.BorderSizePixel = 0
    messageInput.PlaceholderText = "Enter message..."
    messageInput.Text = ""
    messageInput.Font = Enum.Font.Gotham
    messageInput.TextSize = 14
    messageInput.TextColor3 = colors.text
    messageInput.ClearTextOnFocus = false
    messageInput.Parent = promptFrame
    
    local messageInputCorner = Instance.new("UICorner")
    messageInputCorner.CornerRadius = UDim.new(0, 6)
    messageInputCorner.Parent = messageInput
    
    -- Send button
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(1, -20, 0, 30)
    sendBtn.Position = UDim2.new(0, 10, 0, 115)
    sendBtn.BackgroundColor3 = colors.highlight
    sendBtn.Text = "Send Fake Message"
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 14
    sendBtn.TextColor3 = colors.text
    sendBtn.BorderSizePixel = 0
    sendBtn.Parent = promptFrame
    
    local sendBtnCorner = Instance.new("UICorner")
    sendBtnCorner.CornerRadius = UDim.new(0, 6)
    sendBtnCorner.Parent = sendBtn
    
    -- Send button click function
    sendBtn.MouseButton1Click:Connect(function()
        local playerName = nameInput.Text
        local message = messageInput.Text
        
        if playerName ~= "" and message ~= "" then
            fakeChatMessage(playerName, message)
            promptFrame:Destroy()
        else
            -- Highlight empty fields
            if playerName == "" then
                nameInput.BackgroundColor3 = colors.warning
                delay(0.5, function()
                    nameInput.BackgroundColor3 = colors.neutralDark
                end)
            end
            
            if message == "" then
                messageInput.BackgroundColor3 = colors.warning
                delay(0.5, function()
                    messageInput.BackgroundColor3 = colors.neutralDark
                end)
            end
        end
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        promptFrame:Destroy()
    end)
    
    -- Parent to GUI
    local gui = findMainGUI()
    if gui then
        promptFrame.Parent = gui
    else
        promptFrame.Parent = player.PlayerGui
    end
    
    return promptFrame
end
-- Fake chat message function
function fakeChatMessage(targetName, message)
    local targetPlayer = getPlayerFromName(targetName)
    
    if not targetPlayer then
        targetPlayer = {Name = targetName, TeamColor = BrickColor.new("White")}
    end
    
    -- Find chat GUI
    local chatGui = nil
    
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui.Name:lower():find("chat") then
            chatGui = gui
            break
        end
    end
    
    if not chatGui then
        setStatus("Chat interface not found")
        return
    end
    
    -- Create fake message
    local fakeMessageFrame = Instance.new("Frame")
    fakeMessageFrame.Size = UDim2.new(1, 0, 0, 20)
    fakeMessageFrame.BackgroundTransparency = 1
    
    local fakeMessageText = Instance.new("TextLabel")
    fakeMessageText.Size = UDim2.new(1, 0, 1, 0)
    fakeMessageText.BackgroundTransparency = 1
    fakeMessageText.Font = Enum.Font.SourceSans
    fakeMessageText.TextSize = 16
    fakeMessageText.TextXAlignment = Enum.TextXAlignment.Left
    fakeMessageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Set team colors if available
    if targetPlayer.TeamColor then
        fakeMessageText.TextColor3 = targetPlayer.TeamColor.Color
    end
    
    fakeMessageText.Text = targetPlayer.Name .. ": " .. message
    fakeMessageText.Parent = fakeMessageFrame
    
    -- Add message to chat history
    for _, child in ipairs(chatGui:GetDescendants()) do
        if child:IsA("ScrollingFrame") and child.Name:lower():find("chat") or child.Name:lower():find("message") then
            fakeMessageFrame.Parent = child
            break
        end
    end
    
    setStatus("Fake message sent")
    
    -- Remove message after a while
    delay(10, function()
        if fakeMessageFrame then
            fakeMessageFrame:Destroy()
        end
    end)
}

-- Find main GUI
function findMainGUI()
    local GUIs = player.PlayerGui:GetChildren()
    for _, gui in ipairs(GUIs) do
        if gui.Name == "KILASIKGUI" then
            return gui
        end
    end
    
    -- Also check CoreGui
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name == "KILASIKGUI" then
                return gui
            end
        end
    end)
    
    return nil
}

-- Spectate player
function spectatePlayer(targetName)
    local targetPlayer = getPlayerFromName(targetName)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
        setStatus("Spectating " .. targetPlayer.Name)
    else
        setStatus("Player not found or can't spectate")
    end
}

-- Stop spectating
function unspectatePlayer()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        setStatus("Stopped spectating")
    end
}

-- Get player from name (partial match)
function getPlayerFromName(name)
    name = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(name) then
            return plr
        end
    end
    return nil
}

-- Teleport to player
function teleportToPlayer(targetName)
    local targetPlayer = getPlayerFromName(targetName)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        setStatus("Teleported to " .. targetPlayer.Name)
    else
        setStatus("Player not found or unreachable")
    end
}

-- Teleport to mouse position
function teleportToMouse()
    local mousePos = mouse.Hit.Position
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(mousePos + Vector3.new(0, 5, 0))
        setStatus("Teleported to mouse position")
    else
        setStatus("Teleport failed: Character not found")
    end
}

-- Bring player
function bringPlayer(targetName)
    local targetPlayer = getPlayerFromName(targetName)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        
        -- Note: This function won't work in most games due to client-server architecture
        
        -- Try some common methods that might work in specific games
        
        -- Method 1: Try to change position
        pcall(function()
            targetPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end)
        
        -- Method 2: Try network ownership
        pcall(function()
            if targetPlayer.Character:FindFirstChildOfClass("Tool") then
                local tool = targetPlayer.Character:FindFirstChildOfClass("Tool")
                local handle = tool:FindFirstChild("Handle")
                
                if handle then
                    handle.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end
        end)
        
        -- Method 3: Try to use a vehicle
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("VehicleSeat") and v.Occupant == player.Character.Humanoid then
                    local vehicle = v:FindFirstAncestorOfClass("Model")
                    if vehicle then
                        vehicle:SetPrimaryPartCFrame(targetPlayer.Character.HumanoidRootPart.CFrame)
                    end
                end
            end
        end)
        
        setStatus("Attempted to bring player (note: this usually won't work)")
    else
        setStatus("Player not found or unreachable")
    end
}

-- Fling player
function flingPlayer(targetName)
    local targetPlayer = getPlayerFromName(targetName)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        
        -- Note: This function is game-dependent and might not work in many games
        
        -- Method: Use velocity to launch at player
        local oldPos = player.Character.HumanoidRootPart.CFrame
        
        -- Increase character speed
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local oldWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = 100
        
        -- Run toward target player
        humanoid:MoveTo(targetPlayer.Character.HumanoidRootPart.Position)
        
        -- Create velocity for impact
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = math.huge
        bodyVelocity.Parent = player.Character.HumanoidRootPart
        
        -- Wait and increase impact right after collision
        delay(0.5, function()
            local direction = (targetPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Unit
            bodyVelocity.Velocity = direction * 500
            
            -- Clean up after 1 second and return to original position
            delay(1, function()
                if bodyVelocity and bodyVelocity.Parent then
                    bodyVelocity:Destroy()
                end
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and humanoid then
                    player.Character.HumanoidRootPart.CFrame = oldPos
                    humanoid.WalkSpeed = oldWalkSpeed
                end
            end)
        end)
        
        setStatus("Attempting to fling player (note: this usually won't work well)")
    else
        setStatus("Player not found or unflingable")
    end
}

-- Rejoin server
function rejoinServer()
    setStatus("Rejoining server...")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
}

-- Copy position
function copyPosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local position = player.Character.HumanoidRootPart.Position
        local posText = "Vector3.new(" .. tostring(position.X) .. ", " .. tostring(position.Y) .. ", " .. tostring(position.Z) .. ")"
        
        setclipboard(posText)
        setStatus("Position copied: " .. posText)
    else
        setStatus("Position copy failed")
    end
}

-- Remove fog
function removeFog()
    Lighting.FogStart = 100000
    Lighting.FogEnd = 100000
    setStatus("Fog removed")
}

-- Full brightness
function enableFullBright()
    local oldAmbient = Lighting.Ambient
    local oldBrightness = Lighting.Brightness
    local oldClockTime = Lighting.ClockTime
    
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    
    setStatus("Full brightness enabled")
}

-- Make character invisible
function makeInvisible()
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
        setStatus("Invisibility enabled (semi-invisible)")
    end
}

-- Remove meshes
function removeMeshes()
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("SpecialMesh") or part:IsA("Mesh") or part:IsA("MeshPart") then
                part:Destroy()
            end
        end
        setStatus("Meshes removed")
    end
}

-- Toggle killAura
function toggleKillAura()
    local killAuraEnabled = not (getgenv().KillAuraConnection ~= nil)
    
    if killAuraEnabled then
        local range = 15 -- Hit range
        
        -- KillAura loop
        getgenv().KillAuraConnection = RunService.Heartbeat:Connect(function()
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and player.Character and
                   otherPlayer.Character:FindFirstChild("Humanoid") and
                   otherPlayer.Character.Humanoid.Health > 0 and
                   otherPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   player.Character:FindFirstChild("HumanoidRootPart") then
                    
                    -- Check team if applicable
                    if player.Team and otherPlayer.Team and player.Team == otherPlayer.Team then
                        continue
                    end
                    
                    local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= range then
                        -- Find weapon and hit or slash
                        for _, tool in pairs(player.Character:GetChildren()) do
                            if tool:IsA("Tool") and (tool:FindFirstChild("Handle") or tool:FindFirstChild("Blade")) then
                                -- Try different methods to hit
                                
                                -- Method 1: Direct hit
                                if tool.Name:lower():find("sword") or tool.Name:lower():find("knife") then
                                    tool:Activate()
                                    -- Target the hit
                                    local handlePart = tool:FindFirstChild("Handle") or tool:FindFirstChild("Blade")
                                    if handlePart then
                                        handlePart.CFrame = otherPlayer.Character.HumanoidRootPart.CFrame
                                    end
                                end
                                
                                -- Method 2: Remote event
                                for _, event in pairs(tool:GetDescendants()) do
                                    if event:IsA("RemoteEvent") and (event.Name:lower():find("hit") or event.Name:lower():find("damage")) then
                                        event:FireServer(otherPlayer.Character.HumanoidRootPart)
                                    end
                                end
                                
                                -- Method 3: Try game-specific events
                                for _, event in pairs(ReplicatedStorage:GetDescendants()) do
                                    if event:IsA("RemoteEvent") and (event.Name:lower():find("damage") or event.Name:lower():find("hit")) then
                                        event:FireServer(otherPlayer.Character.HumanoidRootPart)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        setStatus("KillAura enabled - 15 stud range")
    else
        if getgenv().KillAuraConnection then
            getgenv().KillAuraConnection:Disconnect()
            getgenv().KillAuraConnection = nil
        end
        
        setStatus("KillAura disabled")
    end
}

-- Infinite ammo
function giveInfiniteAmmo()
    local gunHook
    pcall(function()
        gunHook = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FireServer" and self.Name:lower():find("ammo") or self.Name:lower():find("bullet") then
                -- Ammo count hook
                return
            end
            
            return gunHook(self, ...)
        end)
    end)
    
    setStatus("Infinite ammo activated (may not work in all games)")
}

-- God Mode (attempt)
function attemptGodMode()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        -- Method 1: Clone Humanoid
        pcall(function()
            local humanoid = player.Character.Humanoid
            local cloneHum = humanoid:Clone()
            humanoid.Name = "1"
            cloneHum.Parent = player.Character
            humanoid:Destroy()
            cloneHum.Name = "Humanoid"
        end)
        
        -- Method 2: Prevent joint breaks
        pcall(function()
            player.Character.Humanoid.BreakJointsOnDeath = false
        end)
        
        -- Method 3: Hook health
        pcall(function()
            local healthHook
            healthHook = hookmetamethod(game, "__index", function(self, key)
                if self == player.Character.Humanoid and key == "Health" then
                    return 100
                end
                return healthHook(self, key)
            end)
        end)
        
        setStatus("God Mode attempted (may not work in all games)")
    end
}

-- Toggle auto farm
function toggleAutoFarm()
    local autoFarmEnabled = not (getgenv().AutoFarmConnection ~= nil)
    
    if autoFarmEnabled then
        -- Common resource names
        local resourceNames = {
            "Coin", "Gem", "Diamond", "Cash", "Money", "Gold", "Silver", "Bronze",
            "Chest", "Crate", "Box", "Ore", "Resource", "Collectible", "Pickup",
            "XP", "Exp", "Experience", "Points", "Token"
        }
        
        getgenv().AutoFarmConnection = RunService.Heartbeat:Connect(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                return
            end
            
            local rootPart = player.Character.HumanoidRootPart
            local closestResource = nil
            local shortestDistance = 50 -- Max distance
            
            -- First search workspace
            for _, child in ipairs(workspace:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("Model") then
                    local isResource = false
                    
                    -- Name check
                    for _, resourceName in ipairs(resourceNames) do
                        if child.Name:lower():find(resourceName:lower()) or 
                           (child.Parent and child.Parent.Name:lower():find(resourceName:lower())) then
                            isResource = true
                            break
                        end
                    end
                    
                    -- Physical property check (shine, rotation, etc.)
                    if not isResource and child:IsA("BasePart") then
                        if child:FindFirstChildOfClass("ParticleEmitter") or
                           child:FindFirstChildOfClass("PointLight") or
                           child:FindFirstChildOfClass("Sparkles") then
                            isResource = true
                        end
                        
                        -- Also check by color
                        if not isResource and (
                            child.BrickColor == BrickColor.new("Bright yellow") or -- Gold/Money color
                            child.BrickColor == BrickColor.new("Bright blue") or   -- Gem color
                            child.BrickColor == BrickColor.new("New Yeller")       -- Money color
                        ) then
                            isResource = true
                        end
                    end
                    
                    if isResource then
                        local targetPosition = child:IsA("Model") and child:GetModelCFrame().Position or child.Position
                        local distance = (targetPosition - rootPart.Position).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestResource = child
                        end
                    end
                end
            end
            
            -- If a resource is found, auto collect
            if closestResource then
                local targetPosition = closestResource:IsA("Model") and closestResource:GetModelCFrame().Position or closestResource.Position
                
                -- Move toward resource
                player.Character.Humanoid:MoveTo(targetPosition)
                
                -- If very close, teleport directly onto it for faster collection
                if shortestDistance < 10 then
                    rootPart.CFrame = CFrame.new(targetPosition)
                end
                
                -- Trigger touch interest
                pcall(function()
                    firetouchinterest(rootPart, closestResource, 0)
                    wait(0.1)
                    firetouchinterest(rootPart, closestResource, 1)
                end)
                
                -- Try remote events
                for _, event in pairs(closestResource:GetDescendants()) do
                    if event:IsA("RemoteEvent") and (event.Name:lower():find("collect") or event.Name:lower():find("pickup") or event.Name:lower():find("grab")) then
                        event:FireServer()
                    end
                end
            end
        end)
        
        setStatus("Auto farm enabled")
    else
        if getgenv().AutoFarmConnection then
            getgenv().AutoFarmConnection:Disconnect()
            getgenv().AutoFarmConnection = nil
        end
        
        setStatus("Auto farm disabled")
    end
}

-- Increase weapon reach
function increaseReach()
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FireServer" and string.find(self.Name:lower(), "hit") or string.find(self.Name:lower(), "damage") then
                -- Check and modify arguments
                for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        -- Increase range
                        args[i] = player.Character.HumanoidRootPart.Position + (v - player.Character.HumanoidRootPart.Position).Unit * 30
                    end
                    
                    if typeof(v) == "Instance" and v:IsA("BasePart") then
                        -- Find closest player
                        local closestPlayer = nil
                        local shortestDistance = 20 -- Increased range
                        
                        for _, otherPlayer in ipairs(Players:GetPlayers()) do
                            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    closestPlayer = otherPlayer
                                end
                            end
                        end
                        
                        if closestPlayer then
                            args[i] = closestPlayer.Character.HumanoidRootPart
                        end
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    setStatus("Weapon reach increased (may not work in all games)")
}

-- Play animation
function playAnimation(animType)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        setStatus("Cannot play animation: character not found")
        return
    end
    
    local animations = {
        zombie = "rbxassetid://616158929",
        ninja = "rbxassetid://656117400",
        robot = "rbxassetid://3716636869",
        dab = "rbxassetid://3303391864",
        floss = "rbxassetid://5917459365",
        groove = "rbxassetid://3303391864",
        lay = "rbxassetid://3152378852",
        sit = "rbxassetid://2506281703",
        superhero = "rbxassetid://616088887",
        spin = "rbxassetid://188632011",
        punch = "rbxassetid://3034348903",
        dino = "rbxassetid://5918726674"
    }
    
    local animId = animations[animType]
    if not animId then
        setStatus("Animation not found: " .. animType)
        return
    end
    
    -- Play the animation
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    
    -- Store the animation track
    if not getgenv().CurrentAnimTrack then
        getgenv().CurrentAnimTrack = nil
    end
    
    -- Stop previous animation if playing
    if getgenv().CurrentAnimTrack and getgenv().CurrentAnimTrack.IsPlaying then
        getgenv().CurrentAnimTrack:Stop()
    end
    
    -- Load and play new animation
    local animTrack = player.Character.Humanoid:LoadAnimation(anim)
    animTrack:Play()
    getgenv().CurrentAnimTrack = animTrack
    
    setStatus(animType .. " animation playing")
}

-- Dance animation
function playDanceAnimation()
    local animations = {
        "rbxassetid://507771019", -- Shuffle
        "rbxassetid://429703734", -- Moonwalk
        "rbxassetid://35654637",  -- Thriller
        "rbxassetid://129423030", -- Breakdance
        "rbxassetid://3189773368" -- Floss
    }
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local animationIndex = math.random(1, #animations)
        local anim = Instance.new("Animation")
        anim.AnimationId = animations[animationIndex]
        
        -- Stop previous animation if playing
        if getgenv().CurrentAnimTrack and getgenv().CurrentAnimTrack.IsPlaying then
            getgenv().CurrentAnimTrack:Stop()
        end
        
        -- Load and play new animation
        local animTrack = player.Character.Humanoid:LoadAnimation(anim)
        animTrack:Play()
        getgenv().CurrentAnimTrack = animTrack
        
        setStatus("Dance animation playing")
    end
}

-- Make character giant
function makeGiantSize()
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 3
            end
        end
        
        if player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.HipHeight = player.Character.Humanoid.HipHeight * 3
        end
        
        setStatus("Character size increased")
    end
}

-- Make character tiny
function makeTinySize()
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 0.5
            end
        end
        
        if player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.HipHeight = player.Character.Humanoid.HipHeight * 0.5
        end
        
        setStatus("Character size decreased")
    end
}

-- Create floating parts
function createFloatingParts()
    local parts = {}
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 0, 255)
    }
    
    -- Create 20 parts
    for i = 1, 20 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1, 1, 1)
        part.Anchored = true
        part.CanCollide = false
        part.BrickColor = BrickColor.new(colors[math.random(1, #colors)])
        part.Material = Enum.Material.Neon
        part.Shape = Enum.PartType.Ball
        part.Parent = workspace
        
        table.insert(parts, part)
    end
    
    -- Orbit parts around player
    local angle = 0
    local radius = 5
    local angleStep = math.pi * 2 / #parts
    local floatingLoop
    
    floatingLoop = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            -- Clean up if character disappears
            for _, part in ipairs(parts) do
                part:Destroy()
            end
            floatingLoop:Disconnect()
            return
        end
        
        angle = angle + 0.03
        
        for i, part in ipairs(parts) do
            local x = math.cos(angle + i * angleStep) * radius
            local y = math.sin(angle * 0.5) * 2 + 4
            local z = math.sin(angle + i * angleStep) * radius
            
            part.Position = player.Character.HumanoidRootPart.Position + Vector3.new(x, y, z)
        end
    end)
    
    -- Clean up after 30 seconds
    delay(30, function()
        floatingLoop:Disconnect()
        for _, part in ipairs(parts) do
            part:Destroy()
        end
    end)
    
    setStatus("Floating parts created (30 seconds)")
}

-- Spin character
function spinCharacter()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local spinSpeed = 10 -- Spin speed
        local isSpinning = true
        
        if getgenv().SpinLoop then
            getgenv().SpinLoop:Disconnect()
            getgenv().SpinLoop = nil
            isSpinning = false
            setStatus("Spinning stopped")
            return
        end
        
        getgenv().SpinLoop = RunService.Heartbeat:Connect(function()
            if not isSpinning or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                if getgenv().SpinLoop then
                    getgenv().SpinLoop:Disconnect()
                    getgenv().SpinLoop = nil
                end
                return
            end
            
            player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end)
        
        setStatus("Character spinning - Run command again to stop")
    end
}

-- Load Ultimate Fling script
function loadUltimateFling()
    setStatus("Loading Ultimate Fling...")
    
    -- Create a frame to host the close button for Ultimate Fling
    local closeFrame = Instance.new("Frame")
    closeFrame.Name = "UltimateFlingCloseFrame"
    closeFrame.Size = UDim2.new(0, 50, 0, 50)
    closeFrame.Position = UDim2.new(0, 10, 0, 10)
    closeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeFrame.BackgroundTransparency = 0.3
    closeFrame.BorderSizePixel = 0
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = closeFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✖"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 24
    closeButton.Parent = closeFrame
    
    -- Add KILASIK credit
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.new(0, 200, 0, 30)
    creditLabel.Position = UDim2.new(0, 70, 0, 20)
    creditLabel.BackgroundTransparency = 0.5
    creditLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    creditLabel.Text = "KILASIK"
    creditLabel.Font = Enum.Font.GothamBold
    creditLabel.TextSize = 18
    creditLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
    creditLabel.BorderSizePixel = 0
    
    local creditCorner = Instance.new("UICorner")
    creditCorner.CornerRadius = UDim.new(0, 5)
    creditCorner.Parent = creditLabel
    
    -- Add close button functionality - when clicked, it will destroy all Ultimate Fling GUI
    closeButton.MouseButton1Click:Connect(function()
        -- Find and destroy the Ultimate Fling GUI
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name:find("Fling") or gui.Name:find("fling") then
                gui:Destroy()
            end
        end
        
        -- Also check CoreGui
        pcall(function()
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui.Name:find("Fling") or gui.Name:find("fling") then
                    gui:Destroy()
                end
            end
        end)
        
        -- Remove our close button frame
        closeFrame:Destroy()
    end)
    
    -- Execute Ultimate Fling script
    loadstring(game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"))()
    
    -- Wait a moment for the GUI to load
    delay(1, function()
        -- Find the Fling GUI that was created
        local flingGui = nil
        
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name:find("Fling") or gui.Name:find("fling") then
                flingGui = gui
                break
            end
        end
        
        if not flingGui then
            -- Check CoreGui as a fallback
            pcall(function()
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui.Name:find("Fling") or gui.Name:find("fling") then
                        flingGui = gui
                        break
                    end
                end
            end)
        end
        
        -- If found, add our close button and credit label
        if flingGui then
            closeFrame.Parent = flingGui
            creditLabel.Parent = flingGui
            
            -- Replace any existing title with KILASIK
            for _, obj in pairs(flingGui:GetDescendants()) do
                if obj:IsA("TextLabel") and (obj.Text:find("Credit") or obj.Text:find("credit") or obj.Text:find("Created")) then
                    obj.Text = "KILASIK"
                    obj.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
                end
            end
        else
            -- If not found, just add to PlayerGui
            closeFrame.Parent = player.PlayerGui
            creditLabel.Parent = player.PlayerGui
        end
    end)
}

-- Load Touch Fling script
function loadTouchFling()
    setStatus("Loading Touch Fling...")
    
    -- Create a frame to host the close button for Touch Fling
    local closeFrame = Instance.new("Frame")
    closeFrame.Name = "TouchFlingCloseFrame"
    closeFrame.Size = UDim2.new(0, 50, 0, 50)
    closeFrame.Position = UDim2.new(0, 10, 0, 10)
    closeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeFrame.BackgroundTransparency = 0.3
    closeFrame.BorderSizePixel = 0
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = closeFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✖"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 24
    closeButton.Parent = closeFrame
    
    -- Add KILASIK credit
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.new(0, 200, 0, 30)
    creditLabel.Position = UDim2.new(0, 70, 0, 20)
    creditLabel.BackgroundTransparency = 0.5
    creditLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    creditLabel.Text = "KILASIK"
    creditLabel.Font = Enum.Font.GothamBold
    creditLabel.TextSize = 18
    creditLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
    creditLabel.BorderSizePixel = 0
    
    local creditCorner = Instance.new("UICorner")
    creditCorner.CornerRadius = UDim.new(0, 5)
    creditCorner.Parent = creditLabel
    
    -- Add close button functionality - when clicked, it will destroy all Touch Fling GUI
    closeButton.MouseButton1Click:Connect(function()
        -- Find and destroy the Touch Fling GUI
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name:find("Touch") or gui.Name:find("touch") or gui.Name:find("Fling") or gui.Name:find("fling") then
                gui:Destroy()
            end
        end
        
        -- Also check CoreGui
        pcall(function()
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui.Name:find("Touch") or gui.Name:find("touch") or gui.Name:find("Fling") or gui.Name:find("fling") then
                    gui:Destroy()
                end
            end
        end)
        
        -- Remove our close button frame
        closeFrame:Destroy()
    end)
    
    -- Execute Touch Fling script
    loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
    
    -- Wait a moment for the GUI to load
    delay(1, function()
        -- Find the Touch Fling GUI that was created
        local touchFlingGui = nil
        
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name:find("Touch") or gui.Name:find("touch") or gui.Name:find("Fling") or gui.Name:find("fling") then
                touchFlingGui = gui
                break
            end
        end
        
        if not touchFlingGui then
            -- Check CoreGui as a fallback
            pcall(function()
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui.Name:find("Touch") or gui.Name:find("touch") or gui.Name:find("Fling") or gui.Name:find("fling") then
                        touchFlingGui = gui
                        break
                    end
                end
            end)
        end
        
        -- If found, add our close button and credit label
        if touchFlingGui then
            closeFrame.Parent = touchFlingGui
            creditLabel.Parent = touchFlingGui
            
            -- Replace any existing title with KILASIK
            for _, obj in pairs(touchFlingGui:GetDescendants()) do
                if obj:IsA("TextLabel") and (obj.Text:find("Credit") or obj.Text:find("credit") or obj.Text:find("Created")) then
                    obj.Text = "KILASIK"
                    obj.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
                end
            end
        else
            -- If not found, just add to PlayerGui
            closeFrame.Parent = player.PlayerGui
            creditLabel.Parent = player.PlayerGui
        end
    end)
}

-- Give building tools
function giveBTools()
    local toolNames = {"Move", "Clone", "Delete", "Grab"}
    
    for _, toolName in ipairs(toolNames) do
        local tool = Instance.new("HopperBin")
        tool.Name = toolName
        tool.BinType = Enum.BinType[toolName]
        tool.Parent = player.Backpack
    end
    
    setStatus("Building tools given")
}

-- Apply force field
function applyForceField()
    if player.Character then
        local forceField = Instance.new("ForceField")
        forceField.Parent = player.Character
        
        setStatus("Force field applied")
    end
}

-- High jump
function doHighJump()
    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
        local jumpForce = 100
        
        -- Check if on ground
        local isOnGround = player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running or
                           player.Character.Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics
        
        if isOnGround then
            -- Apply upward force with BodyVelocity
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, jumpForce, 0)
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = player.Character.HumanoidRootPart
            
            -- Clean up after 0.2 seconds
            delay(0.2, function()
                bodyVelocity:Destroy()
            end)
            
            setStatus("High jump executed")
        else
            setStatus("You must be on the ground to jump")
        end
    end
}

-- Toggle swimming mode
function toggleSwimMode()
    local swimModeEnabled = not (getgenv().SwimModeConnection ~= nil)
    
    if swimModeEnabled then
        getgenv().SwimModeConnection = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Set humanoid state to swimming
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                
                -- 3D movement with WASD
                local moveDirection = player.Character.Humanoid.MoveDirection
                
                if moveDirection.Magnitude > 0 then
                    player.Character.HumanoidRootPart.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(
                        moveDirection.X * 30,
                        moveDirection.Y * 30,
                        moveDirection.Z * 30
                    ))
                else
                    player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        
        setStatus("Swim mode enabled")
    else
        if getgenv().SwimModeConnection then
            getgenv().SwimModeConnection:Disconnect()
            getgenv().SwimModeConnection = nil
        end
        
        -- Return character to normal state
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        setStatus("Swim mode disabled")
    end
}

-- Rainbow character
function makeRainbowCharacter()
    if player.Character then
        local rainbowSpeed = 2
        local hue = 0
        
        if getgenv().RainbowLoop then
            getgenv().RainbowLoop:Disconnect()
            getgenv().RainbowLoop = nil
            
            -- Restore original colors
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part:FindFirstChild("OriginalColor") then
                    part.Color = part.OriginalColor.Value
                    part.OriginalColor:Destroy()
                end
            end
            
            setStatus("Rainbow effect disabled")
            return
        end
        
        -- Store original colors
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not part:FindFirstChild("OriginalColor") then
                    local originalValue = Instance.new("Color3Value")
                    originalValue.Name = "OriginalColor"
                    originalValue.Value = part.Color
                    originalValue.Parent = part
                end
            end
        end
        
        getgenv().RainbowLoop = RunService.Heartbeat:Connect(function()
            if not player.Character then
                getgenv().RainbowLoop:Disconnect()
                getgenv().RainbowLoop = nil
                return
            end
            
            hue = (hue + rainbowSpeed) % 360
            local color = Color3.fromHSV(hue/360, 1, 1)
            
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Color = color
                end
            end
        end)
        
        setStatus("Rainbow character effect applied - Run command again to disable")
    end
}

-- Clear map (potentially harmful!)
function clearMap()
    -- Define what to protect for player and game mechanics safety
    local protectedNames = {
        "Workspace", "Camera", "Terrain", "SpawnLocation", "Players", "Script", "LocalScript", "StarterPack",
        "StarterGui", "StarterPlayer", "TouchTransmitter"
    }
    
    local function isProtected(obj)
        for _, name in ipairs(protectedNames) do
            if obj.Name:find(name) or obj:IsA(name) or obj:IsDescendantOf(Players) then
                return true
            end
        end
        return false
    end
    
    local removedCount = 0
    local maxRemove = 100 -- Safety limit to prevent crashing
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isProtected(obj) and obj:IsA("BasePart") and obj.Anchored then
            obj.Transparency = 1
            obj.CanCollide = false
            removedCount = removedCount + 1
            
            if removedCount >= maxRemove then
                break
            end
        end
    end
    
    setStatus("Hid " .. removedCount .. " map objects (made transparent)")
}

-- Low graphics settings
function setLowGraphics()
    -- Lower graphics quality
    pcall(function()
        settings().Rendering.QualityLevel = 1
    end)
    
    -- Disable shadows and effects
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    
    -- Uncap FPS
    pcall(function()
        setfpscap(9999)
    end)
    
    -- Reduce render distance
    pcall(function()
        settings().Rendering.EagerBulkExecution = false
    end)
    
    -- Simplify objects
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            
            -- Remove special effects
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Smoke") or child:IsA("Fire") then
                    child.Enabled = false
                end
            end
        end
    end
    
    setStatus("Low graphics settings applied")
}

-- Remove textures
function removeTextures()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            
            -- Remove Decal, Texture and other visual elements
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child.Transparency = 1
                end
            end
        end
    end
    
    setStatus("Textures removed")
}

-- Show hitboxes
function showHitboxes()
    local hitboxesEnabled = not (getgenv().HitboxConnection ~= nil)
    
    if hitboxesEnabled then
        local hitboxes = {}
        
        -- Create hitboxes for other players
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local hitbox = Instance.new("BoxHandleAdornment")
                        hitbox.Name = "Hitbox"
                        hitbox.Adornee = part
                        hitbox.Color3 = Color3.fromRGB(255, 0, 0)
                        hitbox.Transparency = 0.7
                        hitbox.AlwaysOnTop = true
                        hitbox.ZIndex = 10
                        hitbox.Size = part.Size
                        hitbox.Parent = part
                        
                        table.insert(hitboxes, hitbox)
                    end
                end
            end
        end
        
        -- Create update loop
        getgenv().HitboxConnection = RunService.Heartbeat:Connect(function()
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- Check character parts for hitboxes
                    for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and not part:FindFirstChild("Hitbox") then
                            local hitbox = Instance.new("BoxHandleAdornment")
                            hitbox.Name = "Hitbox"
                            hitbox.Adornee = part
                            hitbox.Color3 = Color3.fromRGB(255, 0, 0)
                            hitbox.Transparency = 0.7
                            hitbox.AlwaysOnTop = true
                            hitbox.ZIndex = 10
                            hitbox.Size = part.Size
                            hitbox.Parent = part
                            
                            table.insert(hitboxes, hitbox)
                        end
                    end
                end
            end
        end)
        
        setStatus("Hitboxes visible")
    else
        if getgenv().HitboxConnection then
            getgenv().HitboxConnection:Disconnect()
            getgenv().HitboxConnection = nil
        end
        
        -- Clean up all hitboxes
        for _, plyr in ipairs(Players:GetPlayers()) do
            if plyr.Character then
                for _, part in ipairs(plyr.Character:GetDescendants()) do
                    if part:IsA("BoxHandleAdornment") and part.Name == "Hitbox" then
                        part:Destroy()
                    end
                end
            end
        end
        
        setStatus("Hitboxes hidden")
    end
}

-- Load Infinite Yield
function loadInfiniteYield()
    setStatus("Loading Infinite Yield admin...")
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
}

-- Anti AFK
function enableAntiAFK()
    if getgenv().AntiAFKConnection then
        getgenv().AntiAFKConnection:Disconnect()
        getgenv().AntiAFKConnection = nil
    end
    
    getgenv().AntiAFKConnection = player.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        setStatus("Anti-AFK: Prevented kick")
    end)
    
    setStatus("Anti-AFK enabled")
}

-- Fix camera issues
function fixCamera()
    -- Reset camera to default
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
    
    -- Fix camera orientation
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, player.Character.HumanoidRootPart.Position)
    end
    
    setStatus("Camera fixed")
}

-- Toggle a command as favorite
function toggleFavorite(commandName)
    local index = nil
    
    -- Check if already in favorites
    for i, favCommand in ipairs(favoriteCommands) do
        if favCommand == commandName then
            index = i
            break
        end
    end
    
    if index then
        -- Remove from favorites
        table.remove(favoriteCommands, index)
        setStatus(commandName .. " removed from favorites")
    else
        -- Add to favorites
        table.insert(favoriteCommands, commandName)
        setStatus(commandName .. " added to favorites")
    end
    
    -- Save favorites
    if writefile then
        writefile("KILASIK_favorites.json", HttpService:JSONEncode(favoriteCommands))
    end
    
    -- Update favorites tab if active
    local mainGUI = findMainGUI()
    if mainGUI and activeTab == "Favorites" then
        local contentFrame = mainGUI:FindFirstChild("MainFrame"):FindFirstChild("ContentFrame")
        if contentFrame and contentFrame:FindFirstChild("CommandList") then
            updateCommandList("")
        end
    end
}

-- Check if command is favorited
function isCommandFavorite(commandName)
    for _, favCommand in ipairs(favoriteCommands) do
        if favCommand == commandName then
            return true
        end
    end
    return false
}

-- Load favorites
function loadFavorites()
    if readfile and isfile and isfile("KILASIK_favorites.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("KILASIK_favorites.json"))
        end)
        
        if success and typeof(result) == "table" then
            favoriteCommands = result
        end
    end
}

-- Toggle aimbot
function toggleAimbot()
    aimbotSettings.enabled = not aimbotSettings.enabled
    
    if aimbotSettings.enabled then
        -- Create FOV circle if showing
        if aimbotSettings.showFOV then
            pcall(function()
                -- Remove existing FOV circle
                if getgenv().FOVCircle then
                    getgenv().FOVCircle:Remove()
                    getgenv().FOVCircle = nil
                end
                
                -- Create new FOV circle using Drawing library
                local fovcircle = Drawing.new("Circle")
                fovcircle.Visible = true
                fovcircle.Radius = aimbotSettings.fovSize
                fovcircle.Thickness = 1
                fovcircle.Transparency = 1
                fovcircle.Color = Color3.fromRGB(255, 255, 255)
                fovcircle.Position = camera.ViewportSize / 2
                
                getgenv().FOVCircle = fovcircle
            end)
        end
        
        -- Create aimbot update loop
        if getgenv().AimbotUpdateLoop then
            getgenv().AimbotUpdateLoop:Disconnect()
            getgenv().AimbotUpdateLoop = nil
        end
        
        getgenv().AimbotUpdateLoop = RunService.RenderStepped:Connect(function()
            if not aimbotSettings.enabled then
                getgenv().AimbotUpdateLoop:Disconnect()
                getgenv().AimbotUpdateLoop = nil
                
                -- Remove FOV circle
                if getgenv().FOVCircle then
                    getgenv().FOVCircle:Remove()
                    getgenv().FOVCircle = nil
                end
                return
            end
            
            -- Update FOV circle position
            if getgenv().FOVCircle then
                getgenv().FOVCircle.Position = camera.ViewportSize / 2
            end
            
            -- Check for toggle key
            local isKeyDown = false
            
            if UserInputService:IsKeyDown(Enum.KeyCode[aimbotSettings.toggleKey]) then
                isKeyDown = true
            end
            
            if not isKeyDown then
                aimbotTarget = nil
                return
            end
            
            -- Find closest player within FOV
            local closestPlayer = nil
            local closestDistance = math.huge
            local screenCenter = camera.ViewportSize / 2
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and 
                   otherPlayer.Character:FindFirstChild("Humanoid") and 
                   otherPlayer.Character.Humanoid.Health > 0 and
                   otherPlayer.Character:FindFirstChild(aimbotSettings.aimPart) then
                    
                    -- Check team if team check enabled
                    if aimbotSettings.teamCheck and player.Team and otherPlayer.Team and player.Team == otherPlayer.Team then
                        continue
                    end
                    
                    -- Check if target is visible if visibility check enabled
                    if aimbotSettings.visibilityCheck and not isTargetVisible(otherPlayer.Character, aimbotSettings.aimPart) then
                        continue
                    end
                    
                    -- Check if target is within FOV
                    local targetPart = otherPlayer.Character[aimbotSettings.aimPart]
                    local screenPoint = camera:WorldToScreenPoint(targetPart.Position)
                    
                    if screenPoint.Z > 0 then
                        local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        
                        if screenDistance <= aimbotSettings.fovSize then
                            if screenDistance < closestDistance then
                                closestDistance = screenDistance
                                closestPlayer = otherPlayer
                            end
                        end
                    end
                end
            end
            
            -- Aim at the closest player
            if closestPlayer then
                aimbotTarget = closestPlayer
                local targetPart = closestPlayer.Character[aimbotSettings.aimPart]
                
                -- Calculate aim point, adding a bit of smoothing
                local targetPos = targetPart.Position
                local aimPos = camera.CFrame.Position + (targetPos - camera.CFrame.Position).Unit * 1000
                
                -- Apply smoothing
                local currentAim = camera.CFrame.LookVector
                local targetAim = (targetPos - camera.CFrame.Position).Unit
                local smoothedAim = currentAim:Lerp(targetAim, aimbotSettings.sensitivity)
                
                -- Set camera to look at target
                camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + smoothedAim * 1000)
            else
                aimbotTarget = nil
            end
        end)
        
        setStatus("Aimbot enabled - Press " .. aimbotSettings.toggleKey .. " to activate")
    else
        aimbotTarget = nil
        
        -- Cleanup
        if getgenv().AimbotUpdateLoop then
            getgenv().AimbotUpdateLoop:Disconnect()
            getgenv().AimbotUpdateLoop = nil
        end
        
        if getgenv().FOVCircle then
            getgenv().FOVCircle:Remove()
            getgenv().FOVCircle = nil
        end
        
        setStatus("Aimbot disabled")
    end
    
    -- Update keybind settings
    keyBindSettings.Aimbot.enabled = aimbotSettings.enabled
    saveSettings()
}

-- Check if a target is visible (for aimbot)
function isTargetVisible(character, partName)
    if not character or not character:FindFirstChild(partName) or not player.Character or not player.Character:FindFirstChild("Head") then
        return false
    end
    
    local targetPart = character[partName]
    local origin = player.Character.Head.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(character)
    end
    
    return true
}

-- Toggle wallbang
function toggleWallbang()
    aimbotSettings.wallbangEnabled = not aimbotSettings.wallbangEnabled
    setStatus("Wallbang: " .. (aimbotSettings.wallbangEnabled and "Enabled" or "Disabled"))
    saveSettings()
}

-- =====================
-- GUI Creation
-- =====================

-- Create status message display
local statusLabel = nil
function setStatus(text)
    if not statusLabel then return end
    statusLabel.Text = text
    
    -- Reset text after 5 seconds
    delay(5, function()
        if statusLabel and statusLabel.Text == text then
            statusLabel.Text = "Ready"
        end
    end)
}

-- Key verification GUI
function createKeyVerificationGUI()
    -- Try to use CoreGui (some executors won't allow)
    local container = nil
    pcall(function()
        container = game:GetService("CoreGui")
    end)
    
    if not container then
        container = player.PlayerGui
    end
    
    -- Main GUI
    local keyGUI = Instance.new("ScreenGui")
    keyGUI.Name = "KILASIK_KeyVerification"
    keyGUI.ResetOnSpawn = false
    keyGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGUI.Parent = container
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(0, 350, 0, 250)
    background.Position = UDim2.new(0.5, -175, 0.5, -125)
    background.BackgroundColor3 = colors.background
    background.BorderSizePixel = 0
    background.Parent = keyGUI
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = background
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = colors.header
    title.BorderSizePixel = 0
    title.Text = "KILASIK GUI - Key Verification"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = colors.text
    title.Parent = background
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    local titleCoverBar = Instance.new("Frame")
    titleCoverBar.Size = UDim2.new(1, 0, 0, 10)
    titleCoverBar.Position = UDim2.new(0, 0, 1, -10)
    titleCoverBar.BackgroundColor3 = colors.header
    titleCoverBar.BorderSizePixel = 0
    titleCoverBar.ZIndex = 0
    titleCoverBar.Parent = title
    
    -- Description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -40, 0, 40)
    description.Position = UDim2.new(0, 20, 0, 50)
    description.BackgroundTransparency = 1
    description.Text = "You need a valid key to use this GUI."
    description.Font = Enum.Font.Gotham
    description.TextSize = 14
    description.TextWrapped = true
    description.TextColor3 = colors.text
    description.Parent = background
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -40, 0, 35)
    inputBox.Position = UDim2.new(0, 20, 0, 95)
    inputBox.BackgroundColor3 = colors.neutralDark
    inputBox.PlaceholderText = "Enter key here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.Text = ""
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.TextColor3 = colors.text
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = background
    
    local inputBoxCorner = Instance.new("UICorner")
    inputBoxCorner.CornerRadius = UDim.new(0, 6)
    inputBoxCorner.Parent = inputBox
    
    -- Discord button
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(1, -40, 0, 35)
    discordButton.Position = UDim2.new(0, 20, 0, 140)
    discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218) -- Discord color
    discordButton.Text = "Get Key from Discord"
    discordButton.Font = Enum.Font.GothamBold
    discordButton.TextSize = 14
    discordButton.TextColor3 = colors.text
    discordButton.BorderSizePixel = 0
    discordButton.AutoButtonColor = false
    discordButton.Parent = background
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 6)
    discordCorner.Parent = discordButton
    
    -- Verify button
    local verifyButton = Instance.new("TextButton")
    verifyButton.Size = UDim2.new(1, -40, 0, 35)
    verifyButton.Position = UDim2.new(0, 20, 0, 185)
    verifyButton.BackgroundColor3 = colors.highlight
    verifyButton.Text = "Verify"
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.TextSize = 16
    verifyButton.TextColor3 = colors.text
    verifyButton.BorderSizePixel = 0
    verifyButton.AutoButtonColor = false
    verifyButton.Parent = background
    
    local verifyButtonCorner = Instance.new("UICorner")
    verifyButtonCorner.CornerRadius = UDim.new(0, 6)
    verifyButtonCorner.Parent = verifyButton
    
    -- Result label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Size = UDim2.new(1, -40, 0, 20)
    resultLabel.Position = UDim2.new(0, 20, 0, 230)
    resultLabel.BackgroundTransparency = 1
    resultLabel.Text = ""
    resultLabel.Font = Enum.Font.Gotham
    resultLabel.TextSize = 14
    resultLabel.TextColor3 = colors.warning
    resultLabel.Parent = background
    
    -- Button hover effects
    discordButton.MouseEnter:Connect(function()
        discordButton.BackgroundColor3 = Color3.fromRGB(130, 150, 230) -- Lighter Discord color
    end)
    
    discordButton.MouseLeave:Connect(function()
        discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    end)
    
    verifyButton.MouseEnter:Connect(function()
        verifyButton.BackgroundColor3 = Color3.fromRGB(90, 150, 200)
    end)
    
    verifyButton.MouseLeave:Connect(function()
        verifyButton.BackgroundColor3 = colors.highlight
    end)
    
    -- Discord button function
    discordButton.MouseButton1Click:Connect(function()
        setclipboard(DISCORD_LINK)
        resultLabel.Text = "Discord link copied to clipboard!"
        resultLabel.TextColor3 = colors.success
    end)
    
    -- Key verification function
    verifyButton.MouseButton1Click:Connect(function()
        local inputKey = inputBox.Text
        
        if inputKey == KEY_CODE then
            resultLabel.Text = "Key verified! Loading GUI..."
            resultLabel.TextColor3 = colors.success
            
            keyVerified = true
            
            -- Load GUI
            delay(1, function()
                keyGUI:Destroy()
                createMainGUI()
            end)
        else
            resultLabel.Text = "Invalid key! Please try again."
            resultLabel.TextColor3 = colors.warning
            
            -- Error effect
            local originalColor = inputBox.BackgroundColor3
            inputBox.BackgroundColor3 = colors.warning
            delay(0.5, function()
                inputBox.BackgroundColor3 = originalColor
            end)
        end
    end)
    
    return keyGUI
}

-- Create main GUI
function createMainGUI()
    if guiCreated then return end
    
    -- Load settings and favorites
    loadSettings()
    loadFavorites()
    
    -- Try to use CoreGui
    local container = nil
    pcall(function()
        container = game:GetService("CoreGui")
    end)
    
    if not container then
        container = player.PlayerGui
    end
    
    -- Main GUI
    local mainGUI = Instance.new("ScreenGui")
    mainGUI.Name = "KILASIKGUI"
    mainGUI.ResetOnSpawn = false
    mainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGUI.Parent = container
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = loadGuiSettings() -- Load saved size or use default
    mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
    mainFrame.BackgroundColor3 = colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = mainGUI
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    -- Resize handles
    createResizeHandles(mainFrame)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = colors.header
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleCoverBar = Instance.new("Frame")
    titleCoverBar.Size = UDim2.new(1, 0, 0, 10)
    titleCoverBar.Position = UDim2.new(0, 0, 1, -10)
    titleCoverBar.BackgroundColor3 = colors.header
    titleCoverBar.BorderSizePixel = 0
    titleCoverBar.ZIndex = 0
    titleCoverBar.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -150, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "KILASIK GUI"
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextColor3 = colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = colors.warning
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.TextColor3 = colors.text
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = false
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    minimizeButton.BackgroundColor3 = colors.neutralLight
    minimizeButton.Text = "-"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 20
    minimizeButton.TextColor3 = colors.text
    minimizeButton.BorderSizePixel = 0
    minimizeButton.AutoButtonColor = false
    minimizeButton.Parent = titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeButton
    
    -- Mini button (logo mode)
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(0, 30, 0, 30)
    miniButton.Position = UDim2.new(1, -105, 0, 5)
    miniButton.BackgroundColor3 = colors.neutralLight
    miniButton.Text = "□"
    miniButton.Font = Enum.Font.GothamBold
    miniButton.TextSize = 16
    miniButton.TextColor3 = colors.text
    miniButton.BorderSizePixel = 0
    miniButton.AutoButtonColor = false
    miniButton.Parent = titleBar
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 6)
    miniCorner.Parent = miniButton
    
    -- Category tab
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Name = "CategoryFrame"
    categoryFrame.Size = UDim2.new(0, 130, 1, -40)
    categoryFrame.Position = UDim2.new(0, 0, 0, 40)
    categoryFrame.BackgroundColor3 = colors.categoryBG
    categoryFrame.BorderSizePixel = 0
    categoryFrame.Parent = mainFrame
    
    -- Category scroll frame
    local categoryScrollFrame = Instance.new("ScrollingFrame")
    categoryScrollFrame.Name = "CategoryScrollFrame"
    categoryScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    categoryScrollFrame.BackgroundTransparency = 1
    categoryScrollFrame.BorderSizePixel = 0
    categoryScrollFrame.ScrollBarThickness = 4
    categoryScrollFrame.ScrollBarImageColor3 = colors.neutralLight
    categoryScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #categories * 40 + 10) -- Auto-size based on category count
    categoryScrollFrame.Parent = categoryFrame
    
    local categoryButtons = {}
    
    -- Category buttons layout
    local categoryLayout = Instance.new("UIListLayout")
    categoryLayout.Padding = UDim.new(0, 5)
    categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryLayout.Parent = categoryScrollFrame
    
    -- Category buttons
    for i, category in ipairs(categories) do
        local categoryButton = Instance.new("TextButton")
        categoryButton.Name = category .. "Button"
        categoryButton.Size = UDim2.new(1, -20, 0, 35)
        categoryButton.BackgroundColor3 = category == activeTab and colors.buttonSelected or colors.button
        categoryButton.Text = category
        categoryButton.Font = Enum.Font.GothamSemibold
        categoryButton.TextSize = 14
        categoryButton.TextColor3 = colors.text
        categoryButton.BorderSizePixel = 0
        categoryButton.AutoButtonColor = false
        categoryButton.Parent = categoryScrollFrame
        
        local categoryCorner = Instance.new("UICorner")
        categoryCorner.CornerRadius = UDim.new(0, 6)
        categoryCorner.Parent = categoryButton
        
        -- Special color for favorites tab
        if category == "Favorites" then
            categoryButton.BackgroundColor3 = category == activeTab and colors.buttonSelected or colors.favorite
            categoryButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
        
        -- Hover effect
        categoryButton.MouseEnter:Connect(function()
            if activeTab ~= category then
                if category == "Favorites" then
                    categoryButton.BackgroundColor3 = Color3.fromRGB(255, 235, 100) -- Lighter gold
                else
                    categoryButton.BackgroundColor3 = colors.buttonHover
                end
            end
        end)
        
        categoryButton.MouseLeave:Connect(function()
            if activeTab ~= category then
                if category == "Favorites" then
                    categoryButton.BackgroundColor3 = colors.favorite
                else
                    categoryButton.BackgroundColor3 = colors.button
                end
            end
        end)
        
        -- Click function
        categoryButton.MouseButton1Click:Connect(function()
            -- Change active tab
            if activeTab ~= category then
                -- Reset previous button color
                for _, btn in pairs(categoryButtons) do
                    if btn.Text == "Favorites" then
                        btn.BackgroundColor3 = colors.favorite
                        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                    else
                        btn.BackgroundColor3 = colors.button
                        btn.TextColor3 = colors.text
                    end
                end
                
                -- Set new button color
                categoryButton.BackgroundColor3 = colors.buttonSelected
                if category == "Favorites" then
                    categoryButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                else
                    categoryButton.TextColor3 = colors.text
                end
                
                -- Update active tab
                activeTab = category
                
                -- Update content panel
                updateContentPanel()
            end
        end)
        
        categoryButtons[category] = categoryButton
    end
    
    -- Content panel
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -140, 1, -90)
    contentFrame.Position = UDim2.new(0, 135, 0, 45)
    contentFrame.BackgroundColor3 = colors.background
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    -- Search bar
    local searchBar = Instance.new("TextBox")
    searchBar.Name = "SearchBar"
    searchBar.Size = UDim2.new(1, -15, 0, 35)
    searchBar.Position = UDim2.new(0, 5, 0, 5)
    searchBar.BackgroundColor3 = colors.neutralDark
    searchBar.PlaceholderText = "Search commands..."
    searchBar.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBar.Text = ""
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 14
    searchBar.TextColor3 = colors.text
    searchBar.BorderSizePixel = 0
    searchBar.ClearTextOnFocus = false
    searchBar.Parent = contentFrame
    
    local searchBarCorner = Instance.new("UICorner")
    searchBarCorner.CornerRadius = UDim.new(0, 6)
    searchBarCorner.Parent = searchBar
    
    -- Command list
    local commandList = Instance.new("ScrollingFrame")
    commandList.Name = "CommandList"
    commandList.Size = UDim2.new(1, -10, 1, -50)
    commandList.Position = UDim2.new(0, 5, 0, 45)
    commandList.BackgroundTransparency = 1
    commandList.BorderSizePixel = 0
    commandList.ScrollBarThickness = 6
    commandList.ScrollBarImageColor3 = colors.neutralLight
    commandList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be auto-adjusted
    commandList.Parent = contentFrame
    
    -- List layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = commandList
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -135, 0, 30)
    statusBar.Position = UDim2.new(0, 135, 1, -35)
    statusBar.BackgroundColor3 = colors.neutralDark
    statusBar.BorderSizePixel = 0
    statusBar.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusBar
    
    -- Status text
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = colors.text
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar
    
    -- Credit label
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.new(0, 130, 0, 30)
    creditLabel.Position = UDim2.new(0, 0, 1, -30)
    creditLabel.BackgroundColor3 = colors.categoryBG
    creditLabel.Text = "KILASIK"
    creditLabel.Font = Enum.Font.GothamBold
    creditLabel.TextSize = 14
    creditLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
    creditLabel.BorderSizePixel = 0
    creditLabel.Parent = mainFrame
    
    -- Mini logo (for mini mode)
    local miniLogo = Instance.new("Frame")
    miniLogo.Name = "MiniLogo"
    miniLogo.Size = UDim2.new(0, 60, 0, 60)
    miniLogo.Position = UDim2.new(0, 10, 0, 10)
    miniLogo.BackgroundColor3 = colors.header
    miniLogo.Visible = false
    miniLogo.BorderSizePixel = 0
    miniLogo.Active = true
    miniLogo.Draggable = true
    miniLogo.Parent = mainGUI
    
    local miniLogoCorner = Instance.new("UICorner")
    miniLogoCorner.CornerRadius = UDim.new(1, 0) -- Circle
    miniLogoCorner.Parent = miniLogo
    
    local miniLogoText = Instance.new("TextLabel")
    miniLogoText.Size = UDim2.new(1, 0, 1, 0)
    miniLogoText.BackgroundTransparency = 1
    miniLogoText.Text = "K"
    miniLogoText.Font = Enum.Font.GothamBold
    miniLogoText.TextSize = 30
    miniLogoText.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
    miniLogoText.Parent = miniLogo
    
    -- Hover and Click Effects
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = colors.warning
    end)
    
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        minimizeButton.BackgroundColor3 = colors.neutralLight
    end)
    
    miniButton.MouseEnter:Connect(function()
        miniButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    end)
    
    miniButton.MouseLeave:Connect(function()
        miniButton.BackgroundColor3 = colors.neutralLight
    end)
    
    -- Button functions
    closeButton.MouseButton1Click:Connect(function()
        mainGUI:Destroy()
        guiCreated = false
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            contentFrame.Visible = false
            categoryFrame.Visible = false
            statusBar.Visible = false
            creditLabel.Visible = false
            mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 40)
        else
            contentFrame.Visible = true
            categoryFrame.Visible = true
            statusBar.Visible = true
            creditLabel.Visible = true
            mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 350)
        end
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        miniSize = not miniSize
        
        if miniSize then
            -- Switch to mini logo
            mainFrame.Visible = false
            miniLogo.Visible = true
        else
            -- Switch back to full GUI
            mainFrame.Visible = true
            miniLogo.Visible = false
        end
    end)
    
    -- Mini logo click behavior
    miniLogo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            miniSize = false
            mainFrame.Visible = true
            miniLogo.Visible = false
        end
    end)
    
    -- Search function
    searchBar.Changed:Connect(function(prop)
        if prop == "Text" then
            updateCommandList(searchBar.Text)
        end
    end)
    
    -- Update content panel function
    function updateContentPanel()
        updateCommandList(searchBar.Text)
    end
-- Update command list function
function updateCommandList(searchQuery)
    -- Clear list
    for _, child in pairs(commandList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add new commands
    local yOffset = 0
    local buttonHeight = 40
    
    -- Determine which commands to show
    local commandsToShow = {}
    
    if activeTab == "Favorites" then
        -- Show only favorite commands
        for _, cmd in ipairs(commands) do
            if isCommandFavorite(cmd.name) then
                table.insert(commandsToShow, cmd)
            end
        end
    else
        -- Show commands based on category and search
        for _, cmd in ipairs(commands) do
            if (activeTab == "Main" or cmd.category == activeTab) and 
               (searchQuery == "" or string.find(string.lower(cmd.name), string.lower(searchQuery)) or 
                string.find(string.lower(cmd.desc), string.lower(searchQuery))) then
                table.insert(commandsToShow, cmd)
            end
        end
    end
    
    -- Sort alphabetically
    table.sort(commandsToShow, function(a, b)
        return a.name < b.name
    end)
    
    -- Create buttons for each command
    for _, cmd in ipairs(commandsToShow) do
        -- Command button
        local commandButton = Instance.new("Frame")
        commandButton.Name = cmd.name .. "Button"
        commandButton.Size = UDim2.new(1, -10, 0, buttonHeight)
        commandButton.BackgroundColor3 = colors.button
        commandButton.BorderSizePixel = 0
        commandButton.Parent = commandList
        
        local commandCorner = Instance.new("UICorner")
        commandCorner.CornerRadius = UDim.new(0, 6)
        commandCorner.Parent = commandButton
        
        -- Command name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4, -10, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = cmd.name
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = colors.text
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = commandButton
        
        -- Command description
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(0.6, -35, 1, 0)
        descLabel.Position = UDim2.new(0.4, 0, 0, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = cmd.desc
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 12
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = commandButton
        
        -- Background button
        local clickButton = Instance.new("TextButton")
        clickButton.Size = UDim2.new(1, 0, 1, 0)
        clickButton.BackgroundTransparency = 1
        clickButton.Text = ""
        clickButton.ZIndex = 10
        clickButton.Parent = commandButton
        
        -- Favorite button (star)
        if cmd.canFavorite then
            local favButton = Instance.new("TextButton")
            favButton.Size = UDim2.new(0, 25, 0, 25)
            favButton.Position = UDim2.new(1, -30, 0.5, -12.5)
            favButton.BackgroundTransparency = 1
            favButton.Text = "★"
            favButton.Font = Enum.Font.GothamBold
            favButton.TextSize = 18
            favButton.TextColor3 = isCommandFavorite(cmd.name) and colors.favorite or Color3.fromRGB(120, 120, 120)
            favButton.Parent = commandButton
            
            -- Favorite click function
            favButton.MouseButton1Click:Connect(function()
                toggleFavorite(cmd.name)
                favButton.TextColor3 = isCommandFavorite(cmd.name) and colors.favorite or Color3.fromRGB(120, 120, 120)
            end)
        end
        
        -- Button hover effect
        clickButton.MouseEnter:Connect(function()
            commandButton.BackgroundColor3 = colors.buttonHover
        end)
        
        clickButton.MouseLeave:Connect(function()
            commandButton.BackgroundColor3 = colors.button
        end)
        
        -- Click function
        clickButton.MouseButton1Click:Connect(function()
            -- Run command
            if cmd.func then
                cmd.func()
            end
            
            -- Button press effect
            commandButton.BackgroundColor3 = colors.buttonSelected
            wait(0.1)
            commandButton.BackgroundColor3 = colors.button
        end)
        
        yOffset = yOffset + buttonHeight + 5
    end
    
    -- Adjust canvas size
    commandList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end
-- Create resize handles for the GUI
function createResizeHandles(frame)
    local handleSize = 10
    local handles = {}
    
    -- Corner handles
    local positions = {
        {0, 0, "nw-resize"},  -- Top-left
        {1, 0, "ne-resize"},  -- Top-right
        {0, 1, "sw-resize"},  -- Bottom-left
        {1, 1, "se-resize"}   -- Bottom-right
    }
    
    for _, pos in ipairs(positions) do
        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, handleSize, 0, handleSize)
        handle.Position = UDim2.new(pos[1], pos[1] == 0 and 0 or -handleSize, pos[2], pos[2] == 0 and 0 or -handleSize)
        handle.Text = ""
        handle.BackgroundTransparency = 1
        handle.ZIndex = 10
        handle.Parent = frame
        
        -- Cursor style
        if pos[3] then
            handle.MouseEnter:Connect(function()
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
                if resizingGui then return end
                UserInputService.MouseIcon = pos[3]
            end)
            
            handle.MouseLeave:Connect(function()
                if resizingGui then return end
                UserInputService.MouseIcon = ""
            end)
        end
        
        -- Resize logic
        local mode = {x = pos[1], y = pos[2]}
        
        handle.MouseButton1Down:Connect(function()
            resizingGui = true
            local startPos = UserInputService:GetMouseLocation()
            local startSize = frame.AbsoluteSize
            local startPosition = frame.AbsolutePosition
            
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = UserInputService:GetMouseLocation() - startPos
                    local newSize = startSize
                    local newPos = startPosition
                    
                    -- Resize logic based on handle position
                    if mode.x == 0 then  -- Left handles
                        newSize = Vector2.new(startSize.X - delta.X, newSize.Y)
                        newPos = Vector2.new(startPosition.X + delta.X, newPos.Y)
                    elseif mode.x == 1 then  -- Right handles
                        newSize = Vector2.new(startSize.X + delta.X, newSize.Y)
                    end
                    
                    if mode.y == 0 then  -- Top handles
                        newSize = Vector2.new(newSize.X, startSize.Y - delta.Y)
                        newPos = Vector2.new(newPos.X, startPosition.Y + delta.Y)
                    elseif mode.y == 1 then  -- Bottom handles
                        newSize = Vector2.new(newSize.X, startSize.Y + delta.Y)
                    end
                    
                    -- Apply minimum size constraints
                    newSize = Vector2.new(
                        math.max(newSize.X, minGuiSize.X.Offset),
                        math.max(newSize.Y, minGuiSize.Y.Offset)
                    )
                    
                    -- Update frame
                    frame.Position = UDim2.new(
                        0, newPos.X,
                        0, newPos.Y
                    )
                    
                    frame.Size = UDim2.new(
                        0, newSize.X,
                        0, newSize.Y
                    )
                end
            end)
            
            -- Handle mouse release
            local releaseConn
            releaseConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    releaseConn:Disconnect()
                    resizingGui = false
                    UserInputService.MouseIcon = ""
                    
                    -- Save the new GUI size
                    saveGuiSettings()
                end
            end)
        end)
        
        table.insert(handles, handle)
    end
    
    return handles
end
-- Show first category
updateContentPanel()
-- Add key bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if game is processing input
    
    -- GUI toggle hotkey (RightControl)
    if input.KeyCode == Enum.KeyCode.RightControl then
        if miniSize then
            -- If in mini mode, switch to full GUI
            miniSize = false
            mainFrame.Visible = true
            miniLogo.Visible = false
        else
            -- Toggle visibility
            guiVisible = not guiVisible
            mainGUI.Enabled = guiVisible
        end
        return
    end
    
    -- Check key bindings
    local keyName = input.KeyCode.Name
    
    -- Fly toggle
    if keyName == keyBindSettings.Fly.key and keyBindSettings.Fly.enabled ~= flying then
        toggleFly()
    end
    
    -- Noclip toggle
    if keyName == keyBindSettings.Noclip.key and keyBindSettings.Noclip.enabled ~= noclip then
        toggleNoclip()
    end
    
    -- ESP toggle
    if keyName == keyBindSettings.ESP.key and keyBindSettings.ESP.enabled ~= espSettings.enabled then
        toggleESP()
    end
    
    -- Aimbot toggle
    if keyName == keyBindSettings.Aimbot.key and keyBindSettings.Aimbot.enabled ~= aimbotSettings.enabled then
        toggleAimbot()
    end
    
    -- Reset character
    if keyName == keyBindSettings.Reset.key and keyBindSettings.Reset.enabled then
        resetCharacter()
    end
    
    -- Speed boost (on key down)
    if keyName == keyBindSettings.Speed.key and keyBindSettings.Speed.enabled then
        setWalkSpeed(50) -- Boost speed
    end
    
    -- Handle infinite jump
    if keyName == "Space" and infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
-- Handle key release events
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local keyName = input.KeyCode.Name
    
    -- Speed boost (on key up)
    if keyName == keyBindSettings.Speed.key and keyBindSettings.Speed.enabled then
        setWalkSpeed(16) -- Return to normal speed
    end
end)
-- Infinite jump event
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
-- Make GUI visible
mainGUI.Enabled = true
guiCreated = true
guiVisible = true
return mainGUI
end
-- Start GUI
if not keyVerified then
    createKeyVerificationGUI()
else
    createMainGUI()
end
-- Startup message
print("KILASIK GUI loaded! Key: " .. KEY_CODE)
print("Use RightControl to toggle GUI.")
