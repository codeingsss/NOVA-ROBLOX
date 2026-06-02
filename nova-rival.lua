--==================================================================================================
-- [SYSTEM] NOVA PREMIUM UNIVERSAL & RIVALS AGRESSIVE INSTANT-LOCK EDITION (ENGLISH & KOREAN UI)
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
    FpsBooster = false,
    
    -- Language
    CurrentLanguage = "EN" -- "EN" or "KR"
}

--==================================================================================================
-- [CONFIG PANEL SAVE/LOAD SYSTEM]
--==================================================================================================
local ConfigFileName = "Nova_Premium_Config.json"

local function SaveConfig()
    local pcallSuccess, encodeData = pcall(function()
        local saveData = {}
        for k, v in pairs(Config) do
            if typeof(v) == "Color3" then
                saveData[k] = {r = v.R, g = v.G, b = v.B, isColor3 = true}
            else
                saveData[k] = v
            end
        end
        return HttpService:JSONEncode(saveData)
    end)
    
    if pcallSuccess and writefile then
        writefile(ConfigFileName, encodeData)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFileName) and readfile then
        local pcallSuccess, decodeData = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        
        if pcallSuccess and type(decodeData) == "table" then
            for k, v in pairs(decodeData) do
                if type(v) == "table" and v.isColor3 then
                    Config[k] = Color3.new(v.r, v.g, v.b)
                elseif Config[k] ~= nil then
                    Config[k] = v
                end
            end
        end
    end
end

LoadConfig()

--==================================================================================================
-- [MULTI-LANGUAGE SYSTEM]
--==================================================================================================
local Localization = {
    -- Windows
    ["Combat"] = {EN = "Combat", KR = "전투 기능"},
    ["Gun Mods"] = {EN = "Gun Mods", KR = "무기 변조"},
    ["Visuals"] = {EN = "Visuals", KR = "시각 효과"},
    ["Movement"] = {EN = "Movement", KR = "이동 기능"},
    ["Automation"] = {EN = "Automation", KR = "자동화"},
    ["Misc"] = {EN = "Misc", KR = "기타 설정"},
    
    -- UI Elements
    ["Silent Aimbot"] = {EN = "Silent Aimbot", KR = "사일런트 에임봇"},
    ["Aim Lock"] = {EN = "Aim Lock", KR = "에임 고정 (우클릭)"},
    ["Aimbot FOV Range"] = {EN = "Aimbot FOV Range", KR = "에임봇 FOV 범위"},
    ["Render FOV Circle"] = {EN = "Render FOV Circle", KR = "FOV 원 표시"},
    ["Trigger Bot"] = {EN = "Trigger Bot", KR = "트리거 보트"},
    ["Prioritize Head"] = {EN = "Prioritize Head", KR = "헤드 조준 우선순위"},
    ["Wallbang Check"] = {EN = "Wallbang Check", KR = "벽 뚫기 체크"},
    ["Anti Aim Spinbot"] = {EN = "Anti Aim Spinbot", KR = "안티 에임 스핀봇"},
    ["Spinbot Speed"] = {EN = "Spinbot Speed", KR = "스핀봇 속도"},
    ["Kill Aura"] = {EN = "Kill Aura", KR = "킬 아우라"},
    ["Kill Aura Range"] = {EN = "Kill Aura Range", KR = "킬 아우라 범위"},
    ["Damage Expander"] = {EN = "Damage Expander", KR = "데미지 확장기"},
    
    ["No Recoil"] = {EN = "No Recoil", KR = "반동 제거"},
    ["No Spread"] = {EN = "No Spread", KR = "탄퍼짐 제거"},
    ["Infinite Ammo"] = {EN = "Infinite Ammo", KR = "무한 탄약"},
    ["Rapid Fire"] = {EN = "Rapid Fire", KR = "고속 연사"},
    ["Instant Reload"] = {EN = "Instant Reload", KR = "즉시 장전"},
    ["Always Automatic"] = {EN = "Always Automatic", KR = "항상 자동사격"},
    ["No Weapon Sway"] = {EN = "No Weapon Sway", KR = "무기 흔들림 제거"},
    ["Fast Fire Rate"] = {EN = "Fast Fire Rate", KR = "빠른 발사 속도"},
    ["Bullet Velocity"] = {EN = "Bullet Velocity", KR = "탄속 변경"},
    ["Unlock All Weapon Skins"] = {EN = "Unlock All Weapon Skins", KR = "모든 무기 스킨 해제"},
    ["Muzzle Flash Disable"] = {EN = "Muzzle Flash Disable", KR = "총구 화염 비활성화"},
    ["Laser Sight Override"] = {EN = "Laser Sight Override", KR = "레이저 사이트 변경"},
    
    ["Player Chams"] = {EN = "Player Chams", KR = "플레이어 챔스(투시)"},
    ["Bounding Box ESP"] = {EN = "Bounding Box ESP", KR = "박스 ESP"},
    ["Directional Snaplines"] = {EN = "Directional Snaplines", KR = "트레이서 선 표시"},
    ["Nametag Render"] = {EN = "Nametag Render", KR = "이름표 표시"},
    ["Distance Track"] = {EN = "Distance Track", KR = "거리 추적 표시"},
    ["Health Metrics"] = {EN = "Health Metrics", KR = "체력 바 표시"},
    ["Max Visibility Matrix"] = {EN = "Max Visibility Matrix", KR = "ESP 최대 표시 거리"},
    ["Theme Crimson Red"] = {EN = "Theme Crimson Red", KR = "크림슨 레드 테마"},
    ["Theme Neon Cyan"] = {EN = "Theme Neon Cyan", KR = "네온 시안 테마"},
    ["Purge ESP Drawings"] = {EN = "Purge ESP Drawings", KR = "ESP 드로잉 초기화"},
    ["Radar Overlay"] = {EN = "Radar Overlay", KR = "레이더 오버레이"},
    ["Crosshair Customizer"] = {EN = "Crosshair Customizer", KR = "크로스헤어 커스텀"},
    
    ["WalkSpeed Override"] = {EN = "WalkSpeed Override", KR = "이동 속도 변경"},
    ["JumpPower Override"] = {EN = "JumpPower Override", KR = "점프력 변경"},
    ["Infinite Jump"] = {EN = "Infinite Jump", KR = "무한 점프"},
    ["Noclip Matrix"] = {EN = "Noclip Matrix", KR = "노클립 (벽 통과)"},
    ["Fly Mode Engine"] = {EN = "Fly Mode Engine", KR = "비행 모드"},
    ["Flight Velocity Speed"] = {EN = "Flight Velocity Speed", KR = "비행 속도 변경"},
    ["Bunny Hop Auto Trigger"] = {EN = "Bunny Hop Auto Trigger", KR = "자동 버니합"},
    ["Teleport Behind Enemy"] = {EN = "Teleport Behind Enemy", KR = "적 등뒤로 텔레포트"},
    ["Instant Suicide"] = {EN = "Instant Suicide", KR = "즉시 자살"},
    ["Return To Map Center"] = {EN = "Return To Map Center", KR = "맵 중앙으로 이동"},
    ["Speed Anti Ban Bypass"] = {EN = "Speed Anti Ban Bypass", KR = "스피드 밴 우회"},
    ["Super Slide Glitch"] = {EN = "Super Slide Glitch", KR = "슈퍼 슬라이드 글리치"},
    
    ["Auto Farm Match Coins"] = {EN = "Auto Farm Match Coins", KR = "자동 코인 파밍"},
    ["Auto Queue Matchmaking"] = {EN = "Auto Queue Matchmaking", KR = "자동 매치메이킹 큐"},
    ["Auto Accept Match Invite"] = {EN = "Auto Accept Match Invite", KR = "자동 매치 초대 수락"},
    ["Auto Claim Battlepass"] = {EN = "Auto Claim Battlepass", KR = "자동 배틀패스 수령"},
    ["Auto Purchase Weapon Cases"] = {EN = "Auto Purchase Weapon Cases", KR = "자동 상자 구매"},
    ["Auto Instant Open Cases"] = {EN = "Auto Instant Open Cases", KR = "자동 즉시 상자 오픈"},
    ["Auto Spammer Chat GG"] = {EN = "Auto Spammer Chat GG", KR = "자동 GG 채팅 도배"},
    ["Anti AFK Security Mode"] = {EN = "Anti AFK Security Mode", KR = "잠수 방지 모드"},
    ["Auto Fast Respawn Loop"] = {EN = "Auto Fast Respawn Loop", KR = "자동 빠른 리스폰"},
    ["Trigger Complete Quests"] = {EN = "Trigger Complete Quests", KR = "퀘스트 즉시 완료"},
    ["Auto Equip Best Weapon"] = {EN = "Auto Equip Best Weapon", KR = "자동 최적 무기 장착"},
    ["Auto Report Counter System"] = {EN = "Auto Report Counter System", KR = "자동 신고 방어 시스템"},
    
    ["Camera Field Of View"] = {EN = "Camera Field Of View", KR = "카메라 시야각(FOV)"},
    ["Fullbright Phase"] = {EN = "Fullbright Phase", KR = "풀브라이트 (밝게)"},
    ["Annihilate Map Textures"] = {EN = "Annihilate Map Textures", KR = "맵 텍스처 전면 제거"},
    ["Global Shadows Blocker"] = {EN = "Global Shadows Blocker", KR = "그림자 비활성화"},
    ["Chat Text Spammer Thread"] = {EN = "Chat Text Spammer Thread", KR = "채팅 텍스트 스패머"},
    ["Hardware FPS Limit Unlocker"] = {EN = "Hardware FPS Limit Unlocker", KR = "FPS 제한 해제 (360)"},
    ["Force Rejoin Active Instance"] = {EN = "Force Rejoin Active Instance", KR = "현재 서버 재접속"},
    ["Server Hop Engine"] = {EN = "Server Hop Engine", KR = "서버 홉 (다른 서버)"},
    ["Copy Official Discord Invite"] = {EN = "Copy Official Discord Invite", KR = "디스코드 초대 링크 복사"},
    ["Terminate System Unload UI"] = {EN = "Terminate System Unload UI", KR = "스크립트 완전 종료"},
    
    ["Save Current Settings"] = {EN = "Save Current Settings", KR = "현재 설정 저장하기"},
    ["Language: English"] = {EN = "Language: English", KR = "언어 변경: English"},
    ["Language: Korean"] = {EN = "Language: Korean", KR = "언어 변경: 한국어"}
}

local function GetText(key)
    if Localization[key] then
        return Localization[key][Config.CurrentLanguage]
    end
    return key
end

--==================================================================================================
-- [CACHE & DRAWING GARBAGE COLLECTOR]
--==================================================================================================
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
-- [GUI INTERFACE CONSTRUCTORS & BRANDING LABELS]
--==================================================================================================

local function AddNovaBranding(window)
    if window and window.CreateLabel then
        window:CreateLabel("--------------------------------")
        window:CreateLabel("N O V A")
    end
end

----------------------------------------------------------------------------------------------------
-- CATEGORY 1: COMBAT SYSTEM
----------------------------------------------------------------------------------------------------
local CombatWin = Nova:CreateWindow(GetText("Combat"), 20, 550)

CombatWin:CreateToggle(GetText("Silent Aimbot"), function(s) Config.SilentAimbot = s end)
CombatWin:CreateToggle(GetText("Aim Lock"), function(s) Config.AimLock = s end)
CombatWin:CreateSlider(GetText("Aimbot FOV Range"), 10, 800, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
CombatWin:CreateToggle(GetText("Render FOV Circle"), function(s) Config.ShowFOV = s end)
CombatWin:CreateToggle(GetText("Trigger Bot"), function(s) Config.TriggerBot = s end)
CombatWin:CreateToggle(GetText("Prioritize Head"), function(s) Config.TargetPart = s and "Head" or "HumanoidRootPart" end)
CombatWin:CreateToggle(GetText("Wallbang Check"), function(s) Config.WallbangCheck = s end)
CombatWin:CreateToggle(GetText("Anti Aim Spinbot"), function(s) Config.AntiAim = s end)
CombatWin:CreateSlider(GetText("Spinbot Speed"), 10, 180, Config.AntiAimSpeed, function(v) Config.AntiAimSpeed = v end)
CombatWin:CreateToggle(GetText("Kill Aura"), function(s) Config.KillAura = s end)
CombatWin:CreateSlider(GetText("Kill Aura Range"), 5, 50, Config.KillAuraRange, function(v) Config.KillAuraRange = v end)
CombatWin:CreateToggle(GetText("Damage Expander"), function(s) Config.InstantKill = s end)
AddNovaBranding(CombatWin)

----------------------------------------------------------------------------------------------------
-- CATEGORY 2: GUN MODS ENGINE
----------------------------------------------------------------------------------------------------
local GunWin = Nova:CreateWindow(GetText("Gun Mods"), 230, 550)

GunWin:CreateToggle(GetText("No Recoil"), function(s) 
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

GunWin:CreateToggle(GetText("No Spread"), function(s) 
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

GunWin:CreateToggle(GetText("Infinite Ammo"), function(s) 
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

GunWin:CreateToggle(GetText("Rapid Fire"), function(s) Config.RapidFire = s end)
GunWin:CreateToggle(GetText("Instant Reload"), function(s) Config.InstantReload = s end)
GunWin:CreateToggle(GetText("Always Automatic"), function(s) Config.AlwaysAutomatic = s end)
GunWin:CreateToggle(GetText("No Weapon Sway"), function(s) Config.NoWeaponSway = s end)
GunWin:CreateToggle(GetText("Fast Fire Rate"), function(s) Config.FastFireRate = s end)
GunWin:CreateSlider(GetText("Bullet Velocity"), 100, 10000, Config.BulletVelocity, function(v) Config.BulletVelocity = v end)
GunWin:CreateButton(GetText("Unlock All Weapon Skins"), function() Config.UnlockSkins = true end)
GunWin:CreateToggle(GetText("Muzzle Flash Disable"), function(s) end)
GunWin:CreateToggle(GetText("Laser Sight Override"), function(s) end)
AddNovaBranding(GunWin)

----------------------------------------------------------------------------------------------------
-- CATEGORY 3: VISUALS ENGINE
----------------------------------------------------------------------------------------------------
local VisualWin = Nova:CreateWindow(GetText("Visuals"), 440, 550)

VisualWin:CreateToggle(GetText("Player Chams"), function(s) Config.EspChams = s end)
VisualWin:CreateToggle(GetText("Bounding Box ESP"), function(s) Config.EspBoxes = s end)
VisualWin:CreateToggle(GetText("Directional Snaplines"), function(s) Config.EspTracers = s end)
VisualWin:CreateToggle(GetText("Nametag Render"), function(s) Config.EspNames = s end)
VisualWin:CreateToggle(GetText("Distance Track"), function(s) Config.EspDistance = s end)
VisualWin:CreateToggle(GetText("Health Metrics"), function(s) Config.EspHealth = s end)
VisualWin:CreateSlider(GetText("Max Visibility Matrix"), 100, 10000, Config.EspMaxDistance, function(v) Config.EspMaxDistance = v end)
VisualWin:CreateButton(GetText("Theme Crimson Red"), function() 
    Config.BoxColor = Color3.fromRGB(255, 0, 50)
    Config.TracerColor = Color3.fromRGB(255, 0, 50)
    Config.EspColor = Color3.fromRGB(255, 0, 50)
end)
VisualWin:CreateButton(GetText("Theme Neon Cyan"), function() 
    Config.BoxColor = Color3.fromRGB(0, 255, 255)
    Config.TracerColor = Color3.fromRGB(0, 255, 255)
    Config.EspColor = Color3.fromRGB(0, 255, 255)
end)
VisualWin:CreateButton(GetText("Purge ESP Drawings"), function() 
    for _, item in pairs(Players:GetPlayers()) do RemoveESP(item) task.wait() CreateESP(item) end 
end)
VisualWin:CreateToggle(GetText("Radar Overlay"), function(s) Config.EspRadar = s end)
VisualWin:CreateToggle(GetText("Crosshair Customizer"), function(s) end)
AddNovaBranding(VisualWin)

----------------------------------------------------------------------------------------------------
-- CATEGORY 4: MOVEMENT PARAMETERS
----------------------------------------------------------------------------------------------------
local MoveWin = Nova:CreateWindow(GetText("Movement"), 650, 550)

MoveWin:CreateSlider(GetText("WalkSpeed Override"), 16, 500, Config.WalkSpeed, function(v) 
    Config.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
MoveWin:CreateSlider(GetText("JumpPower Override"), 50, 600, Config.JumpPower, function(v) 
    Config.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
MoveWin:CreateToggle(GetText("Infinite Jump"), function(s) Config.InfJump = s end)
MoveWin:CreateToggle(GetText("Noclip Matrix"), function(s) Config.NoClip = s end)
MoveWin:CreateToggle(GetText("Fly Mode Engine"), function(s) Config.FlyMode = s end)
MoveWin:CreateSlider(GetText("Flight Velocity Speed"), 10, 500, Config.FlySpeed, function(v) Config.FlySpeed = v end)
MoveWin:CreateToggle(GetText("Bunny Hop Auto Trigger"), function(s) 
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
MoveWin:CreateButton(GetText("Teleport Behind Enemy"), function() 
    local currentClosest = GetClosestTarget()
    if currentClosest and currentClosest.Parent and currentClosest.Parent:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = currentClosest.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5)
    end
end)
MoveWin:CreateButton(GetText("Instant Suicide"), function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end)
MoveWin:CreateButton(GetText("Return To Map Center"), function() 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end)
MoveWin:CreateToggle(GetText("Speed Anti Ban Bypass"), function(s) end)
MoveWin:CreateToggle(GetText("Super Slide Glitch"), function(s) end)
AddNovaBranding(MoveWin)

----------------------------------------------------------------------------------------------------
-- CATEGORY 5: ROBOTIC AUTOMATION
----------------------------------------------------------------------------------------------------
local AutoWin = Nova:CreateWindow(GetText("Automation"), 860, 550)

AutoWin:CreateToggle(GetText("Auto Farm Match Coins"), function(s) Config.AutoFarmCoins = s end)
AutoWin:CreateToggle(GetText("Auto Queue Matchmaking"), function(s) Config.AutoQueue = s end)
AutoWin:CreateToggle(GetText("Auto Accept Match Invite"), function(s) Config.AutoAccept = s end)
AutoWin:CreateToggle(GetText("Auto Claim Battlepass"), function(s) Config.AutoClaim = s end)
AutoWin:CreateToggle(GetText("Auto Purchase Weapon Cases"), function(s) Config.AutoBuyCases = s end)
AutoWin:CreateToggle(GetText("Auto Instant Open Cases"), function(s) Config.AutoOpenCases = s end)
AutoWin:CreateToggle(GetText("Auto Spammer Chat GG"), function(s) Config.AutoGG = s end)
AutoWin:CreateToggle(GetText("Anti AFK Security Mode"), function(s) Config.AntiAfk = s end)
AutoWin:CreateToggle(GetText("Auto Fast Respawn Loop"), function(s) Config.AutoRespawn = s end)
AutoWin:CreateButton(GetText("Trigger Complete Quests"), function() Config.CompleteQuests = true end)
AutoWin:CreateToggle(GetText("Auto Equip Best Weapon"), function(s) end)
AutoWin:CreateToggle(GetText("Auto Report Counter System"), function(s) end)
AddNovaBranding(AutoWin)

----------------------------------------------------------------------------------------------------
-- CATEGORY 6: MISCELLANEOUS ENVIRONMENT
----------------------------------------------------------------------------------------------------
local MiscWin = Nova:CreateWindow(GetText("Misc"), 1070, 550)

MiscWin:CreateSlider(GetText("Camera Field Of View"), 70, 140, 70, function(v) Camera.FieldOfView = v end)
MiscWin:CreateToggle(GetText("Fullbright Phase"), function(s) 
    Config.Fullbright = s
    if Config.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(130, 130, 130)
    end
end)
MiscWin:CreateToggle(GetText("Annihilate Map Textures"), function(s) 
    Config.RemoveTextures = s
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Texture") or item:IsA("Decal") then
            item.Transparency = Config.RemoveTextures and 1 or 0
        end
    end
end)
MiscWin:CreateToggle(GetText("Global Shadows Blocker"), function(s) 
    Config.DisableShadows = s
    Lighting.GlobalShadows = not Config.DisableShadows
end)
MiscWin:CreateToggle(GetText("Chat Text Spammer Thread"), function(s) 
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
MiscWin:CreateButton(GetText("Hardware FPS Limit Unlocker"), function() if setfpscap then setfpscap(360) end end)
MiscWin:CreateButton(GetText("Force Rejoin Active Instance"), function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
MiscWin:CreateButton(GetText("Server Hop Engine"), function() 
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
MiscWin:CreateButton(GetText("Copy Official Discord Invite"), function() if setclipboard then setclipboard("https://discord.gg/nova-premium") end end)
MiscWin:CreateButton(GetText("Terminate System Unload UI"), function() 
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

MiscWin:CreateButton(GetText("Save Current Settings"), function() SaveConfig() end)
MiscWin:CreateButton(GetText("Language: English"), function() Config.CurrentLanguage = "EN" SaveConfig() end)
MiscWin:CreateButton(GetText("Language: Korean"), function() Config.CurrentLanguage = "KR" SaveConfig() end)
AddNovaBranding(MiscWin)

print("Nova Premium UI Load Complete with Footer Branding.")
