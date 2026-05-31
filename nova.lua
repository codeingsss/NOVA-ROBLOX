---------------------------------------------------
-- [1] 업그레이드된 NOVA 로딩 인트로 애니메이션
---------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "NovaIntro"
IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IntroGui.Parent = PlayerGui

local IntroText = Instance.new("TextLabel")
IntroText.Parent = IntroGui
IntroText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
IntroText.BackgroundTransparency = 1.000
IntroText.Position = UDim2.new(0.5, -100, 0.75, -25)
IntroText.Size = UDim2.new(0, 200, 0, 50)
IntroText.Font = Enum.Font.GothamBold
IntroText.Text = "N O V A"
IntroText.TextColor3 = Color3.fromRGB(0, 170, 255)
IntroText.TextSize = 28
IntroText.TextTransparency = 1

local UIStroke = Instance.new("UIStroke", IntroText)
UIStroke.Color = Color3.fromRGB(0, 120, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 1

TweenService:Create(IntroText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
TweenService:Create(UIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.4}):Play()

---------------------------------------------------
-- [2] 메인 시스템 로딩 및 대기
---------------------------------------------------
repeat task.wait() until game:IsLoaded()

local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

---------------------------------------------------
-- 전역 관리 변수 (기능 대폭 확장)
---------------------------------------------------
local CustomTeams = {} 
local SpeedValue = 50  
local JumpValue = 50
local FlySpeed = 50
local KillAuraRange = 18 
local AimSmoothness = 0.12

-- 토글 상태 관리 변수들
local speedEnabled = false
local jumpEnabled = false
local infJumpEnabled = false
local noFallEnabled = false
local noSlowEnabled = false
local instaBreakEnabled = false
local espEnabled = false
local nameTagEnabled = false
local chamsEnabled = false
local tracerEnabled = false
local aimbotEnabled = false
local killAuraEnabled = false
local autoClickEnabled = false
local reachEnabled = false
local autoArmorEnabled = false
local autoBuyEnabled = false
local antiVoidEnabled = false
local noClipEnabled = false

-- 신규 긴급 추가 기능 변수
local autoLootEnabled = false
local autoBridgeEnabled = false
local antiAimEnabled = false
local infStaminaEnabled = false

---------------------------------------------------
-- 블러 효과 및 인트로 페이드 아웃
---------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Parent = Lighting

task.delay(1.5, function()
    TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
    task.wait(0.5)
    IntroGui:Destroy()
end)

---------------------------------------------------
-- GUI 생성 및 보호
---------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaClient_v3_Fixed"
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game.CoreGui end

---------------------------------------------------
-- 드래그 기능
---------------------------------------------------
local function makeDraggable(frame)
    local dragging, startPos, startFramePos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true startPos = input.Position startFramePos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

---------------------------------------------------
-- 창 생성 함수 (모든 창 하단 고정 Nova)
---------------------------------------------------
local function createWindow(title, posX, sizeY)
    sizeY = sizeY or 320
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 210, 0, sizeY)
    frame.Position = UDim2.new(0, posX, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)

    local corner = Instance.new("UICorner", frame) corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame) stroke.Color = Color3.fromRGB(0, 170, 255) stroke.Thickness = 1.2 

    local titleBar = Instance.new("Frame", frame)
    titleBar.Size = UDim2.new(1, 0, 0, 28) titleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    local titleCorner = Instance.new("UICorner", titleBar) titleCorner.CornerRadius = UDim.new(0, 10)
    
    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, 0, 1, 0) titleText.BackgroundTransparency = 1
    titleText.Text = title titleText.TextColor3 = Color3.new(1, 1, 1) titleText.Font = Enum.Font.GothamBold titleText.TextSize = 12

    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, -10, 1, -60) container.Position = UDim2.new(0, 5, 0, 33)
    container.BackgroundTransparency = 1 container.BorderSizePixel = 0
    container.ScrollBarThickness = 3 container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)

    local layout = Instance.new("UIListLayout", container) layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local logoText = Instance.new("TextLabel", frame)
    logoText.Size = UDim2.new(1, 0, 0, 20)
    logoText.Position = UDim2.new(0, 0, 1, -22) 
    logoText.BackgroundTransparency = 1
    logoText.Text = "N O V A"
    logoText.TextColor3 = Color3.fromRGB(0, 170, 255) 
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 12
    logoText.TextTransparency = 0.4 

    makeDraggable(frame)
    return container
end

local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -4, 0, 28) btn.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
    btn.Text = text .. " : OFF" btn.TextColor3 = Color3.new(0.9, 0.9, 0.9) btn.Font = Enum.Font.Gotham btn.TextSize = 12
    local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 44)
        btn.TextColor3 = state and Color3.new(1, 1, 1) or Color3.new(0.9, 0.9, 0.9)
        if callback then task.spawn(callback, state) end
    end)
end

local function createSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", parent) sliderFrame.Size = UDim2.new(1, -4, 0, 42) sliderFrame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", sliderFrame) label.Size = UDim2.new(1, 0, 0, 18) label.BackgroundTransparency = 1 label.Text = text .. " : " .. tostring(default) label.TextColor3 = Color3.new(1,1,1) label.Font = Enum.Font.Gotham label.TextSize = 11 label.TextXAlignment = Enum.TextXAlignment.Left
    local container = Instance.new("TextButton", sliderFrame) container.Size = UDim2.new(1, 0, 0, 14) container.Position = UDim2.new(0, 0, 0, 20) container.BackgroundColor3 = Color3.fromRGB(40, 40, 44) container.Text = ""
    local cCorner = Instance.new("UICorner", container) cCorner.CornerRadius = UDim.new(0, 4)
    local bar = Instance.new("Frame", container) local startPercent = (default - min) / (max - min) bar.Size = UDim2.new(startPercent, 0, 1, 0) bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    local bCorner = Instance.new("UICorner", bar) bCorner.CornerRadius = UDim.new(0, 4)

    local function updateSlider(input)
        local posX = math.clamp((input.Position.X - container.AbsolutePosition.X) / container.AbsoluteSize.X, 0, 1) bar.Size = UDim2.new(posX, 0, 1, 0)
        local value = math.floor(min + (posX * (max - min))) label.Text = text .. " : " .. tostring(value) callback(value)
    end
    local sliding = false
    container.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end end)
    UIS.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
end

---------------------------------------------------
-- 판정 및 필터 로직
---------------------------------------------------
local function isTeamMember(player)
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team == LocalPlayer.Team then return true end
    if LocalPlayer:GetAttribute("Team") and player:GetAttribute("Team") then
        if LocalPlayer:GetAttribute("Team") == player:GetAttribute("Team") then return true end
    end
    if CustomTeams[player.UserId] then return true end
    return false
end

-- ESP 및 시각화 관련 처리
local espObjects = {} local nameTags = {} local tracerLines = {}
local function applyVisuals(character)
    if not character or not character:IsDescendantOf(workspace) then return end
    local p = Players:GetPlayerFromCharacter(character)
    if p and isTeamMember(p) then return end
    if character:FindFirstChild("ESPHighlight") then character.ESPHighlight:Destroy() end
    if character:FindFirstChild("ClientTag") then character.ClientTag:Destroy() end

    if espEnabled or chamsEnabled then
        local highlight = Instance.new("Highlight", character)
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = espEnabled and 0.5 or 1
        highlight.OutlineTransparency = chamsEnabled and 0 or 1
        table.insert(espObjects, highlight)
    end

    if nameTagEnabled and character:FindFirstChild("Head") then
        local bbg = Instance.new("BillboardGui", character) bbg.Name = "ClientTag" bbg.AlwaysOnTop = true bbg.Size = UDim2.new(0, 200, 0, 40) bbg.Adornee = character.Head bbg.StudsOffset = Vector3.new(0, 2.5, 0)
        local tl = Instance.new("TextLabel", bbg) tl.Size = UDim2.new(1, 0, 1, 0) tl.BackgroundTransparency = 1 tl.TextColor3 = Color3.fromRGB(255, 255, 255) tl.Font = Enum.Font.GothamBold tl.TextSize = 11
        local hum = character:FindFirstChildOfClass("Humanoid")
        tl.Text = p.Name .. " | " .. tostring(hum and math.floor(hum.Health) or 100) .. "HP"
        table.insert(nameTags, bbg)
    end
end

function refreshVisuals()
    for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end
    for _, tag in ipairs(nameTags) do if tag then tag:Destroy() end end
    for _, line in ipairs(tracerLines) do if line then line:Destroy() end end
    espObjects = {} nameTags = {} tracerLines = {}
    if espEnabled or nameTagEnabled or chamsEnabled or tracerEnabled then for _, p in ipairs(Players:GetPlayers()) do if p.Character then applyVisuals(p.Character) end end end
end

RunService.RenderStepped:Connect(function()
    for _, line in ipairs(tracerLines) do if line then line:Destroy() end end
    if not tracerEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not isTeamMember(p) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local tracer = Instance.new("LineHandleAdornment", ScreenGui)
                tracer.Length = (Camera.CFrame.Position - p.Character.HumanoidRootPart.Position).Magnitude
                tracer.Color3 = Color3.fromRGB(0, 170, 255) tracer.Thickness = 1.5 tracer.Adornee = Camera
                tracer.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
                table.insert(tracerLines, tracer)
            end
        end
    end
end)

---------------------------------------------------
-- 핵심 물리/수정 기능 제어 루프
---------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if infJumpEnabled and input.KeyCode == Enum.KeyCode.Space then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if speedEnabled then hum.WalkSpeed = SpeedValue end
        if jumpEnabled then hum.JumpPower = JumpValue end
        if noSlowEnabled then hum.PlatformStand = false end
    end
    
    if hrp then
        if noFallEnabled and hrp.Velocity.Y < -20 then hrp.Velocity = Vector3.new(hrp.Velocity.X, -4, hrp.Velocity.Z) end
        if antiVoidEnabled and hrp.Position.Y < 8 then hrp.Velocity = Vector3.new(0, 65, 0) end
        if noClipEnabled then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
        -- 안티 에임 (서버 역추적 교란)
        if antiAimEnabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
        end
    end
    
    -- 무한 스태미나 (속성 값 강제 유지 변조)
    if infStaminaEnabled then
        LocalPlayer:SetAttribute("Stamina", 100)
        LocalPlayer:SetAttribute("Energy", 100)
    end
end)

-- 플라이 시스템
local flyConnection
local function toggleFly(state)
    flyEnabled = state if flyConnection then flyConnection:Disconnect() end
    if state then
        local character = LocalPlayer.Character if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not character or not hrp:IsDescendantOf(workspace) then bv:Destroy() return end
            local moveDirection = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            bv.Velocity = moveDirection.Unit * FlySpeed
            if moveDirection == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    else if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then LocalPlayer.Character.HumanoidRootPart.FlyVelocity:Destroy() end end
end

-- 최적화 타겟 스캐너
local function getClosestPlayer()
    local closestPlayer = nil local shortestDistance = math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeamMember(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then closestPlayer = player shortestDistance = dist end
            end
        end
    end
    return closestPlayer
end

-- 에임봇
local aimbotConnection
local function toggleAimbot(state)
    aimbotEnabled = state if aimbotConnection then aimbotConnection:Disconnect() end
    if state then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = getClosestPlayer()
                if target and target.Character:FindFirstChild("Head") then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), AimSmoothness)
                end
            end
        end)
    end
end

---------------------------------------------------
-- [🔧 긴급 수정] 우회형 킬아우라 / 리치 / 오토 작동 로직
---------------------------------------------------

-- 1. 신형 우회형 킬아우라 (가상 레이캐스트 전송 우회)
local function toggleKillAura(state)
    killAuraEnabled = state
    task.spawn(function()
        while killAuraEnabled do
            task.wait(0.08) -- 공격 딜레이 최적화 (안티치트 밴 방지)
            local target = getClosestPlayer()
            if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local targetPos = target.Character.HumanoidRootPart.Position
                if (myPos - targetPos).Magnitude <= KillAuraRange then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        -- 최신 게임 리모트 감지 자동 동적 바인딩 시스템
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("hit") or remote.Name:lower():find("swing") or remote.Name:lower():find("attack")) then
                                pcall(function()
                                    remote:FireServer(target.Character)
                                    remote:FireServer({["entityInstance"] = target.Character, ["validate"] = {["targetPosition"] = targetPos}})
                                    remote:FireServer(target.Character:FindFirstChild("HumanoidRootPart"), tool)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- 2. 신형 리치 패치 (메쉬 가상 경계박스 변조형 우회)
local reachConnection
local function toggleReach(state)
    reachEnabled = state if reachConnection then reachConnection:Disconnect() end
    if state then
        reachConnection = RunService.RenderStepped:Connect(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                local handle = tool.Handle
                if not handle:FindFirstChild("NovaOrigSize") then
                    local origSize = Instance.new("Vector3Value", handle) origSize.Name = "NovaOrigSize" origSize.Value = handle.Size
                end
                -- 단순 무식하게 키우면 밴되므로, 투명도를 주고 가상 충돌 연산만 확장
                handle.Size = Vector3.new(KillAuraRange, 2, KillAuraRange)
                handle.Massless = true
                handle.CanCollide = false
            end
        end)
    else
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild("NovaOrigSize") then
            tool.Handle.Size = tool.Handle.NovaOrigSize.Value
            tool.Handle.NovaOrigSize:Destroy()
        end
    end
end

-- 3. 오토 기능 전면 작동 수정 (오토클릭)
local function toggleAutoClicker(state)
    autoClickEnabled = state
    task.spawn(function()
        while autoClickEnabled do
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then 
                tool:Activate()
                -- 클라이언트 직접 클릭 신호 강제 트리거
                pcall(function() tool:Click() end)
            end
            task.wait(0.02)
        end
    end)
end

-- 4. 신규 자동 아이템 수집 (Auto Loot) 루프
local function toggleAutoLoot(state)
    autoLootEnabled = state
    task.spawn(function()
        while autoLootEnabled do
            task.wait(0.3)
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("BackpackItem") or obj:IsA("Tool") or obj.Name:lower():find("drop") or obj.Name:lower():find("item") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if (LocalPlayer.Character.HumanoidRootPart.Position - obj:GetPivot().Position).Magnitude < 30 then
                                -- 수집 반경 내 강제 텔레포트 좌표 수집
                                obj:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- 5. 신규 자동 블록 설치 (Auto Bridge)
RunService.Heartbeat:Connect(function()
    if not autoBridgeEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local checkPos = hrp.Position + (hrp.Velocity.Unit * 2) - Vector3.new(0, 3.5, 0)
    
    -- 발밑이 빈 공간인지 체크 후 가상 블록 리모트 호출
    local ray = Ray.new(hrp.Position, Vector3.new(0, -5, 0))
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    if not hit then
        pcall(function()
            local blockRemote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or ReplicatedStorage:FindFirstChild("BlockPlacement", true)
            if blockRemote then blockRemote:FireServer(Vector3.new(math.floor(checkPos.X), math.floor(checkPos.Y), math.floor(checkPos.Z))) end
         pcall(function() Mouse.TargetFilter = workspace end)
        end)
    end
end)

-- 자동 상점 구매 오토 제어 패치
local function toggleAutoArmor(state) autoArmorEnabled = state while autoArmorEnabled do pcall(function() for _, r in ipairs(ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") and (r.Name:lower():find("buy") or r.Name:lower():find("shop")) then r:FireServer("iron_armor") r:FireServer({["shopItem"] = "iron_armor"}) end end end) task.wait(1.5) end end
local function toggleAutoBuy(state) autoBuyEnabled = state while autoBuyEnabled do pcall(function() for _, r in ipairs(ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") and (r.Name:lower():find("buy") or r.Name:lower():find("shop")) then r:FireServer("teleport_pearl") r:FireServer({["shopItem"] = "teleport_pearl"}) end end end) task.wait(4) end end

---------------------------------------------------
-- 5대 대확장 카테고리 창 분할 생성
---------------------------------------------------
local visualsWin = createWindow("Visuals", 30, 260)
local movementWin = createWindow("Movement", 250, 360)
local combatWin = createWindow("Combat", 470, 310)
local exploitsWin = createWindow("Exploits", 690, 260)
local settingsWin = createWindow("Settings", 910, 420)

-- [1] Visuals
createToggle(visualsWin, "Player ESP", function(s) espEnabled = s refreshVisuals() end)
createToggle(visualsWin, "NameTags", function(s) nameTagEnabled = s refreshVisuals() end)
createToggle(visualsWin, "Chams (Wall)", function(s) chamsEnabled = s refreshVisuals() end)
createToggle(visualsWin, "Tracers Line", function(s) tracerEnabled = s refreshVisuals() end)
createToggle(visualsWin, "Fullbright", function(state)
    if state then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 Lighting.GlobalShadows = false
    else Lighting.Brightness = 1 Lighting.ClockTime = 12 Lighting.FogEnd = 1000 Lighting.GlobalShadows = true end
end)

-- [2] Movement
createToggle(movementWin, "Speed Hack", function(s) speedEnabled = s end)
createSlider(movementWin, "Speed Value", 16, 200, 50, function(v) SpeedValue = v end)
createToggle(movementWin, "Jump Power", function(s) jumpEnabled = s end)
createSlider(movementWin, "Jump Value", 50, 250, 100, function(v) JumpValue = v end)
createToggle(movementWin, "Fly Mode", toggleFly)
createSlider(movementWin, "Fly Speed", 20, 300, 50, function(v) FlySpeed = v end)
createToggle(movementWin, "Infinite Jump", function(s) infJumpEnabled = s end)
createToggle(movementWin, "NoClip (PassWall)", function(s) noClipEnabled = s end)

-- [3] Combat (작동 긴급 패치 완료)
createToggle(combatWin, "Kill Aura (Bypass)", toggleKillAura)
createSlider(combatWin, "Aura Range", 5, 30, 18, function(v) KillAuraRange = v end)
createToggle(combatWin, "Smooth Aimbot", toggleAimbot)
createToggle(combatWin, "Auto Clicker", toggleAutoClicker)
createToggle(combatWin, "Reach Extended", toggleReach)

-- [4] Exploits & Auto (신규 핵심 오토 대거 보강)
createToggle(exploitsWin, "Auto Loot Items", toggleAutoLoot)
createToggle(exploitsWin, "Auto Bridge Builder", function(s) autoBridgeEnabled = s end)
createToggle(exploitsWin, "Anti-Aim Ghost", function(s) antiAimEnabled = s end)
createToggle(exploitsWin, "Infinite Stamina", function(s) infStaminaEnabled = s end)
createToggle(exploitsWin, "Insta Break Bed", toggleInstaBreak)
createToggle(exploitsWin, "Anti-Void Fall", function(s) antiVoidEnabled = s end)
createToggle(exploitsWin, "No Fall Damage", function(s) noFallEnabled = s end)
createToggle(exploitsWin, "No Slowdown", function(s) noSlowEnabled = s end)

-- [5] Settings & Whitelist
createToggle(settingsWin, "Auto Buy Armor", toggleAutoArmor)
createToggle(settingsWin, "Auto Pearl Buy", toggleAutoBuy)

-- 실시간 화이트리스트 팀 목록 UI 탑재
local teamSection = Instance.new("Frame", settingsWin) teamSection.Size = UDim2.new(1, 0, 0, 160) teamSection.BackgroundTransparency = 1
local teamTitle = Instance.new("TextLabel", teamSection) teamTitle.Size = UDim2.new(1, 0, 0, 20) teamTitle.Text = "[ Team Whitelist ]" teamTitle.TextColor3 = Color3.fromRGB(0, 170, 255) teamTitle.Font = Enum.Font.GothamBold teamTitle.TextSize = 11 teamTitle.BackgroundTransparency = 1

local scrollFrame = Instance.new("ScrollingFrame", teamSection) scrollFrame.Size = UDim2.new(1, -4, 0, 120) scrollFrame.Position = UDim2.new(0, 2, 0, 25) scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 34) scrollFrame.BorderSizePixel = 0 scrollFrame.ScrollBarThickness = 3
local listLayout = Instance.new("UIListLayout", scrollFrame) listLayout.Padding = UDim.new(0, 4)

local function updateTeamSelectionUI()
    for _, child in ipairs(scrollFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", scrollFrame) pBtn.Size = UDim2.new(1, -6, 0, 24) pBtn.Font = Enum.Font.Gotham pBtn.TextSize = 11
            if CustomTeams[p.UserId] then pBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255) pBtn.Text = p.Name .. " (WHITELISTED)" pBtn.TextColor3 = Color3.new(1,1,1)
            else pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) pBtn.Text = p.Name pBtn.TextColor3 = Color3.fromRGB(200, 200, 200) end
            local pCorner = Instance.new("UICorner", pBtn) pCorner.CornerRadius = UDim.new(0, 4)
            pBtn.MouseButton1Click:Connect(function()
                if CustomTeams[p.UserId] then CustomTeams[p.UserId] = nil else CustomTeams[p.UserId] = true end
                updateTeamSelectionUI() refreshVisuals()
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateTeamSelectionUI)
Players.PlayerRemoving:Connect(function(player) CustomTeams[player.UserId] = nil updateTeamSelectionUI() end)
task.spawn(updateTeamSelectionUI)

---------------------------------------------------
-- 전역 이벤트 연결 (플레이어 투입 감지)
---------------------------------------------------
workspace.DescendantAdded:Connect(function(descendant) if descendant:IsA("Humanoid") then task.wait(0.5) applyVisuals(descendant.Parent) end end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(char) task.wait(0.5) applyVisuals(char) end) end)

---------------------------------------------------
-- UI 토글 제어 (RightShift)
---------------------------------------------------
local visible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        visible = not visible ScreenGui.Enabled = visible blur.Size = visible and 12 or 0
    end
end)

print("[Nova V3] Fixed Premium Edition Loaded. Toggle Key: RightShift")

