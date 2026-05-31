--==================================================================================================
-- [SYSTEM] NOVA PREMIUM UNIVERSAL & RIVALS AGRESSIVE INSTANT-LOCK EDITION (ENGLISH UI)
--==================================================================================================
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/codeingsss/NOVA-ROBLOX/refs/heads/main/novaui.lua"))()

--[ Services ]--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

--[ Configuration State Table ]--
local Config = {
    -- Combat
    SilentAimbot = false,
    AimLock = false,
    AimbotFOV = 100,
    ShowFOV = false,
    TriggerBot = false,
    TargetPart = "Head",
    WallbangCheck = false,
    AntiAim = false,
    AntiAimSpeed = 45,
    KillAura = false,
    KillAuraRange = 15,
    InstantKill = false,
    
    -- Gun Mods
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    RapidFire = false,
    RapidFireRate = 0.01,
    InstantReload = false,
    AlwaysAutomatic = false,
    NoWeaponSway = false,
    FastFireRate = false,
    BulletVelocity = 1000,
    UnlockSkins = false,
    
    -- Visuals (ESP)
    EspPlayers = false,
    EspBoxes = false,
    EspTracers = false,
    EspNames = false,
    EspDistance = false,
    EspHealth = false,
    EspChams = false,
    EspRadar = false,
    EspMaxDistance = 2000,
    EspColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(0, 255, 255),
    
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    FlyMode = false,
    FlySpeed = 50,
    NoClip = false,
    BunnyHop = false,
    TpBehind = false,
    
    -- Automation
    AutoFarmCoins = false,
    AutoQueue = false,
    AutoAccept = false,
    AutoClaim = false,
    AutoBuyCases = false,
    AutoOpenCases = false,
    AutoGG = false,
    AntiAfk = false,
    AutoRespawn = false,
    CompleteQuests = false,
    
    -- Misc
    FieldOfView = 70,
    Fullbright = false,
    RemoveTextures = false,
    DisableShadows = false,
    ChatSpammer = false,
    ChatSpamText = "Nova Premium UI on top!",
    FpsBooster = false
}

--[ Cache & Drawing Garbage Collector ]--
local ESPCache = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 60, 60)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

--==================================================================================================
-- [CORE MATHEMATICS & UTILITIES]
--==================================================================================================

local function IsPlayerVisible(targetChar, targetPart)
    if not Config.WallbangCheck then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestTarget()
    local target = nil
    local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(Config.TargetPart)
            
            if humanoid and part and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local distance = (screenPos - mouseLocation).Magnitude
                    
                    if distance < shortestDistance and distance <= Config.AimbotFOV then
                        if IsPlayerVisible(char, part) then
                            shortestDistance = distance
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

--==================================================================================================
-- [ESP GRAPHICS ENGINE]
--==================================================================================================
local function CreateESP(player)
    if ESPCache[player] then return end
    
    local structures = {
        Box = Drawing.new("Square"),
        Outline = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarOutline = Drawing.new("Line")
    }
    
    structures.Box.Visible = false
    structures.Box.Color = Config.BoxColor
    structures.Box.Thickness = 1
    structures.Box.Filled = false
    
    structures.Outline.Visible = false
    structures.Outline.Color = Color3.fromRGB(0, 0, 0)
    structures.Outline.Thickness = 3
    structures.Outline.Filled = false
    
    structures.Tracer.Visible = false
    structures.Tracer.Color = Config.TracerColor
    structures.Tracer.Thickness = 1
    
    structures.Name.Visible = false
    structures.Name.Color = Color3.fromRGB(255, 255, 255)
    structures.Name.Size = 13
    structures.Name.Center = true
    structures.Name.Outline = true
    
    structures.Distance.Visible = false
    structures.Distance.Color = Color3.fromRGB(240, 240, 100)
    structures.Distance.Size = 11
    structures.Distance.Center = true
    structures.Distance.Outline = true
    
    structures.HealthBar.Visible = false
    structures.HealthBar.Thickness = 1
    
    structures.HealthBarOutline.Visible = false
    structures.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    structures.HealthBarOutline.Thickness = 3
    
    ESPCache[player] = structures
end

local function RemoveESP(player)
    if ESPCache[player] then
        for _, drawing in pairs(ESPCache[player]) do
            drawing.Visible = false
            drawing:Remove()
        end
        ESPCache[player] = nil
    end
end

local function UpdateESPEngine()
    for player, drawings in pairs(ESPCache) do
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end
        
        local char = player.Character
        if not char then
            drawings.Box.Visible = false
            drawings.Outline.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
            drawings.Distance.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBarOutline.Visible = false
            continue
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = localHrp and (hrp.Position - localHrp.Position).Magnitude or 0
            
            if onScreen and distance <= Config.EspMaxDistance then
                local sizeX = 2000 / hrpPos.Z
                local sizeY = 3000 / hrpPos.Z
                local posX = hrpPos.X - sizeX / 2
                local posY = hrpPos.Y - sizeY / 2
                
                if Config.EspBoxes then
                    drawings.Outline.Size = Vector2.new(sizeX, sizeY)
                    drawings.Outline.Position = Vector2.new(posX, posY)
                    drawings.Outline.Visible = true
                    
                    drawings.Box.Size = Vector2.new(sizeX, sizeY)
                    drawings.Box.Position = Vector2.new(posX, posY)
                    drawings.Box.Color = Config.BoxColor
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                    drawings.Outline.Visible = false
                end
                
                if Config.EspTracers then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    drawings.Tracer.Color = Config.TracerColor
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                if Config.EspNames then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(hrpPos.X, posY - 15)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
                
                if Config.EspDistance then
                    drawings.Distance.Text = math.floor(distance) .. " studs"
                    drawings.Distance.Position = Vector2.new(hrpPos.X, posY + sizeY + 5)
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end
                
                if Config.EspHealth then
                    local healthPct = humanoid.Health / humanoid.MaxHealth
                    local barHeight = sizeY * healthPct
                    
                    drawings.HealthBarOutline.From = Vector2.new(posX - 6, posY + sizeY)
                    drawings.HealthBarOutline.To = Vector2.new(posX - 6, posY)
                    drawings.HealthBarOutline.Visible = true
                    
                    drawings.HealthBar.From = Vector2.new(posX - 6, posY + sizeY)
                    drawings.HealthBar.To = Vector2.new(posX - 6, posY + sizeY - barHeight)
                    drawings.HealthBar.Color = Color3.fromRGB(255 - (255 * healthPct), 255 * healthPct, 0)
                    drawings.HealthBar.Visible = true
                else
                    drawings.HealthBar.Visible = false
                    drawings.HealthBarOutline.Visible = false
                end
                
                if Config.EspChams then
                    local highlight = char:FindFirstChild("NovaChams") or Instance.new("Highlight")
                    highlight.Name = "NovaChams"
                    highlight.Parent = char
                    highlight.FillColor = Config.EspColor
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.Enabled = true
                else
                    if char:FindFirstChild("NovaChams") then char.NovaChams:Destroy() end
                end
            else
                drawings.Box.Visible = false
                drawings.Outline.Visible = false
                drawings.Tracer.Visible = false
                drawings.Name.Visible = false
                drawings.Distance.Visible = false
                drawings.HealthBar.Visible = false
                drawings.HealthBarOutline.Visible = false
                if char:FindFirstChild("NovaChams") then char.NovaChams:Destroy() end
            end
        else
            drawings.Box.Visible = false
            drawings.Outline.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
            drawings.Distance.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBarOutline.Visible = false
            if char:FindFirstChild("NovaChams") then char.NovaChams:Destroy() end
        end
    end
end

--==================================================================================================
-- [THREADS & RUNTIME LOOPS SYSTEM]
--==================================================================================================

RunService.RenderStepped:Connect(function()
    if Config.ShowFOV then
        FOVCircle.Radius = Config.AimbotFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    -- [★하드 고정 복구★] 이전의 부자연스럽지만 즉각적이고 정확한 하드 록온 로직으로 교체되었습니다.
    if Config.SilentAimbot or (Config.AimLock and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        local currentTarget = GetClosestTarget()
        if currentTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
        end
    end
    
    if Config.TriggerBot then
        local targetObject = LocalPlayer:GetMouse().Target
        if targetObject and targetObject.Parent then
            local enemyPlayer = Players:GetPlayerFromCharacter(targetObject.Parent)
            if enemyPlayer and enemyPlayer ~= LocalPlayer then
                local hum = targetObject.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    mouse1click()
                end
            end
        end
    end
    
    UpdateESPEngine()
end)

RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    if Config.NoClip then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if Config.FlyMode and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local directionVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then directionVector = directionVector + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then directionVector = directionVector - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then directionVector = directionVector - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then directionVector = directionVector + Camera.CFrame.RightVector end
        
        if directionVector.Magnitude > 0 then
            hrp.Velocity = directionVector.Unit * Config.FlySpeed
        else
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
        hrp.Anchored = false
    end
    
    if Config.AntiAim and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.AntiAimSpeed), 0)
    end
    
    if Config.KillAura then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = player.Character.HumanoidRootPart
                local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local distance = (targetHrp.Position - myHrp.Position).Magnitude
                    if distance <= Config.KillAuraRange then
                        local punchEvent = ReplicatedStorage:FindFirstChild("PunchEvent") or ReplicatedStorage:FindFirstChild("HitRemote")
                        if punchEvent and punchEvent:IsA("RemoteEvent") then
                            punchEvent:FireServer(player.Character)
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        if Config.AutoRespawn then
            task.wait(0.1)
            local respawnRemote = ReplicatedStorage:FindFirstChild("Respawn") or ReplicatedStorage:FindFirstChild("LoadCharacter")
            if respawnRemote and respawnRemote:IsA("RemoteFunction") then
                respawnRemote:InvokeServer()
            elseif respawnRemote and respawnRemote:IsA("RemoteEvent") then
                respawnRemote:FireServer()
            end
        end
    end)
end)

LocalPlayer.Idled:Connect(function()
    if Config.AntiAfk then
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

--==================================================================================================
-- [GUI INTERFACE CONSTRUCTORS]
--==================================================================================================

----------------------------------------------------------------------------------------------------
-- CATEGORY 1: COMBAT SYSTEM
----------------------------------------------------------------------------------------------------
local CombatWin = Nova:CreateWindow("Combat", 20, 550)

CombatWin:CreateToggle("Silent Aimbot", function(s) Config.SilentAimbot = s end)
CombatWin:CreateToggle("Aim Lock", function(s) Config.AimLock = s end)
CombatWin:CreateSlider("Aimbot FOV Range", 10, 800, 100, function(v) Config.AimbotFOV = v end)
CombatWin:CreateToggle("Render FOV Circle", function(s) Config.ShowFOV = s end)
CombatWin:CreateToggle("Trigger Bot", function(s) Config.TriggerBot = s end)
CombatWin:CreateToggle("Prioritize Head", function(s) Config.TargetPart = s and "Head" or "HumanoidRootPart" end)
CombatWin:CreateToggle("Wallbang Check", function(s) Config.WallbangCheck = s end)
CombatWin:CreateToggle("Anti Aim Spinbot", function(s) Config.AntiAim = s end)
CombatWin:CreateSlider("Spinbot Speed", 10, 180, 45, function(v) Config.AntiAimSpeed = v end)
CombatWin:CreateToggle("Kill Aura", function(s) Config.KillAura = s end)
CombatWin:CreateSlider("Kill Aura Range", 5, 50, 15, function(v) Config.KillAuraRange = v end)
CombatWin:CreateToggle("Damage Expander", function(s) Config.InstantKill = s end)

----------------------------------------------------------------------------------------------------
-- CATEGORY 2: GUN MODS ENGINE
----------------------------------------------------------------------------------------------------
local GunWin = Nova:CreateWindow("Gun Mods", 230, 550)

GunWin:CreateToggle("No Recoil", function(s) 
    Config.NoRecoil = s
    task.spawn(function()
        while Config.NoRecoil do
            task.wait()
            local currentWeapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if currentWeapon and currentWeapon:FindFirstChild("WeaponConfig") then
                local cfg = currentWeapon.WeaponConfig
                if cfg:FindFirstChild("Recoil") then cfg.Recoil.Value = 0 end
            end
        end
    end)
end)

GunWin:CreateToggle("No Spread", function(s) 
    Config.NoSpread = s
    task.spawn(function()
        while Config.NoSpread do
            task.wait()
            local currentWeapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if currentWeapon and currentWeapon:FindFirstChild("WeaponConfig") then
                local cfg = currentWeapon.WeaponConfig
                if cfg:FindFirstChild("Spread") then cfg.Spread.Value = 0 end
            end
        end
    end)
end)

GunWin:CreateToggle("Infinite Ammo", function(s) 
    Config.InfiniteAmmo = s 
    task.spawn(function()
        while Config.InfiniteAmmo do
            task.wait()
            pcall(function()
                local clientState = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("WeaponGui")
                if clientState then
                    local ammoVar = clientState:FindFirstChild("Ammo") or clientState:FindFirstChild("CurrentAmmo")
                    if ammoVar and ammoVar:IsA("ValueBase") then ammoVar.Value = 999 end
                end
            end)
        end
    end)
end)

GunWin:CreateToggle("Rapid Fire", function(s) Config.RapidFire = s end)
GunWin:CreateToggle("Instant Reload", function(s) Config.InstantReload = s end)
GunWin:CreateToggle("Always Automatic", function(s) Config.AlwaysAutomatic = s end)
GunWin:CreateToggle("No Weapon Sway", function(s) Config.NoWeaponSway = s end)
GunWin:CreateToggle("Fast Fire Rate", function(s) Config.FastFireRate = s end)
GunWin:CreateSlider("Bullet Velocity", 100, 10000, 1000, function(v) Config.BulletVelocity = v end)
GunWin:CreateButton("Unlock All Weapon Skins", function() Config.UnlockSkins = true end)
GunWin:CreateToggle("Muzzle Flash Disable", function(s) end)
GunWin:CreateToggle("Laser Sight Override", function(s) end)

----------------------------------------------------------------------------------------------------
-- CATEGORY 3: VISUALS ENGINE
----------------------------------------------------------------------------------------------------
local VisualWin = Nova:CreateWindow("Visuals", 440, 550)

VisualWin:CreateToggle("Player Chams", function(s) Config.EspChams = s end)
VisualWin:CreateToggle("Bounding Box ESP", function(s) Config.EspBoxes = s end)
VisualWin:CreateToggle("Directional Snaplines", function(s) Config.EspTracers = s end)
VisualWin:CreateToggle("Nametag Render", function(s) Config.EspNames = s end)
VisualWin:CreateToggle("Distance Track", function(s) Config.EspDistance = s end)
VisualWin:CreateToggle("Health Metrics", function(s) Config.EspHealth = s end)
VisualWin:CreateSlider("Max Visibility Matrix", 100, 10000, 2000, function(v) Config.EspMaxDistance = v end)
VisualWin:CreateButton("Theme Crimson Red", function() 
    Config.BoxColor = Color3.fromRGB(255, 0, 50)
    Config.TracerColor = Color3.fromRGB(255, 0, 50)
    Config.EspColor = Color3.fromRGB(255, 0, 50)
end)
VisualWin:CreateButton("Theme Neon Cyan", function() 
    Config.BoxColor = Color3.fromRGB(0, 255, 255)
    Config.TracerColor = Color3.fromRGB(0, 255, 255)
    Config.EspColor = Color3.fromRGB(0, 255, 255)
end)
VisualWin:CreateButton("Purge ESP Drawings", function() 
    for _, item in pairs(Players:GetPlayers()) do RemoveESP(item) task.wait() CreateESP(item) end 
end)
VisualWin:CreateToggle("Radar Overlay", function(s) Config.EspRadar = s end)
VisualWin:CreateToggle("Crosshair Customizer", function(s) end)

----------------------------------------------------------------------------------------------------
-- CATEGORY 4: MOVEMENT PARAMETERS
----------------------------------------------------------------------------------------------------
local MoveWin = Nova:CreateWindow("Movement", 650, 550)

MoveWin:CreateSlider("WalkSpeed Override", 16, 500, 16, function(v) 
    Config.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
MoveWin:CreateSlider("JumpPower Override", 50, 600, 50, function(v) 
    Config.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
MoveWin:CreateToggle("Infinite Jump", function(s) Config.InfJump = s end)
MoveWin:CreateToggle("Noclip Matrix", function(s) Config.NoClip = s end)
MoveWin:CreateToggle("Fly Mode Engine", function(s) Config.FlyMode = s end)
MoveWin:CreateSlider("Flight Velocity Speed", 10, 500, 50, function(v) Config.FlySpeed = v end)
MoveWin:CreateToggle("Bunny Hop Auto Trigger", function(s) 
    Config.BunnyHop = s
    task.spawn(function()
        while Config.BunnyHop do
            task.wait()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                    LocalPlayer.Character.Humanoid.Jump = true
                end
            end
        end
    end)
end)
MoveWin:CreateButton("Teleport Behind Enemy", function() 
    local currentClosest = GetClosestTarget()
    if currentClosest and currentClosest.Parent and currentClosest.Parent:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = currentClosest.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5)
    end
end)
MoveWin:CreateButton("Instant Suicide", function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end)
MoveWin:CreateButton("Return To Map Center", function() 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end)
MoveWin:CreateToggle("Speed Anti Ban Bypass", function(s) end)
MoveWin:CreateToggle("Super Slide Glitch", function(s) end)

----------------------------------------------------------------------------------------------------
-- CATEGORY 5: ROBOTIC AUTOMATION
----------------------------------------------------------------------------------------------------
local AutoWin = Nova:CreateWindow("Automation", 860, 550)

AutoWin:CreateToggle("Auto Farm Match Coins", function(s) Config.AutoFarmCoins = s end)
AutoWin:CreateToggle("Auto Queue Matchmaking", function(s) Config.AutoQueue = s end)
AutoWin:CreateToggle("Auto Accept Match Invite", function(s) Config.AutoAccept = s end)
AutoWin:CreateToggle("Auto Claim Battlepass", function(s) Config.AutoClaim = s end)
AutoWin:CreateToggle("Auto Purchase Weapon Cases", function(s) Config.AutoBuyCases = s end)
AutoWin:CreateToggle("Auto Instant Open Cases", function(s) Config.AutoOpenCases = s end)
AutoWin:CreateToggle("Auto Spammer Chat GG", function(s) Config.AutoGG = s end)
AutoWin:CreateToggle("Anti AFK Security Mode", function(s) Config.AntiAfk = s end)
AutoWin:CreateToggle("Auto Fast Respawn Loop", function(s) Config.AutoRespawn = s end)
AutoWin:CreateButton("Trigger Complete Quests", function() Config.CompleteQuests = true end)
AutoWin:CreateToggle("Auto Equip Best Weapon", function(s) end)
AutoWin:CreateToggle("Auto Report Counter System", function(s) end)

----------------------------------------------------------------------------------------------------
-- CATEGORY 6: MISCELLANEOUS ENVIRONMENT
----------------------------------------------------------------------------------------------------
local MiscWin = Nova:CreateWindow("Misc", 1070, 550)

MiscWin:CreateSlider("Camera Field Of View", 70, 140, 70, function(v) Camera.FieldOfView = v end)
MiscWin:CreateToggle("Fullbright Phase", function(s) 
    Config.Fullbright = s
    if Config.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(130, 130, 130)
    end
end)
MiscWin:CreateToggle("Annihilate Map Textures", function(s) 
    Config.RemoveTextures = s
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Texture") or item:IsA("Decal") then
            item.Transparency = Config.RemoveTextures and 1 or 0
        end
    end
end)
MiscWin:CreateToggle("Global Shadows Blocker", function(s) 
    Config.DisableShadows = s
    Lighting.GlobalShadows = not Config.DisableShadows
end)
MiscWin:CreateToggle("Chat Text Spammer Thread", function(s) 
    Config.ChatSpammer = s
    task.spawn(function()
        while Config.ChatSpammer do
            task.wait(2.5)
            local sayEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
            if sayEvent then
                sayEvent:FireServer(Config.ChatSpamText, "All")
            end
        end
    end)
end)
MiscWin:CreateButton("Hardware FPS Limit Unlocker", function() if setfpscap then setfpscap(360) end end)
MiscWin:CreateButton("Force Rejoin Active Instance", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
MiscWin:CreateButton("Server Hop Engine", function() 
    pcall(function()
        local serverList = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(serverList.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)
MiscWin:CreateButton("Copy Official Discord Invite", function() if setclipboard then setclipboard("https://discord.gg/nova-premium") end end)
MiscWin:CreateButton("Terminate System Unload UI", function() 
    Config.ShowFOV = false
    Config.EspBoxes = false
    Config.EspTracers = false
    Config.EspNames = false
    Config.EspDistance = false
    Config.EspHealth = false
    Config.EspChams = false
    FOVCircle:Destroy()
    for p, _ in pairs(ESPCache) do RemoveESP(p) end
end)

print("Nova Premium UI Hard-Lock Config Loaded.")
