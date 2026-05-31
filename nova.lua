---------------------------------------------------
-- [1] NOVA 클라이언트 서비스 및 초기화
---------------------------------------------------
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

---------------------------------------------------
-- 전역 제어 변수
---------------------------------------------------
local CustomTeams = {}
local SpeedValue = 23 -- 안티치트 고무줄(Rubberband) 방지 최적화 값
local JumpValue = 50
local FlySpeed = 50
local KillAuraRange = 16

local speedEnabled = false
local jumpEnabled = false
local infJumpEnabled = false
local noFallEnabled = false
local noSlowEnabled = false
local espEnabled = false
local nameTagEnabled = false
local chamsEnabled = false
local tracerEnabled = false
local killAuraEnabled = false
local autoClickEnabled = false
local reachEnabled = false
local autoBridgeEnabled = false
local infStaminaEnabled = false

---------------------------------------------------
-- 프레임워크 컨트롤러 추적 (Knit / Flamework 우회용)
---------------------------------------------------
local KnitClient = nil
pcall(function()
    local knitShared = ReplicatedStorage:FindFirstChild("rbxts_include") and ReplicatedStorage.rbxts_include:FindFirstChild("node_modules")
    if knitShared and knitShared:FindFirstChild("@easy-games") then
        KnitClient = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"].knit.src.Knit.KnitClient)
    end
end)

-- 프레임워크 리모트 서비스 안전 확보 함수
local function safeFireRemote(remoteName, ...)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        end
    end)
end

---------------------------------------------------
-- GUI 디자인 엔진 (Nova V5)
---------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nova_V5_KnitEdition"
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game.CoreGui end

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

local function createWindow(title, posX, sizeY)
    sizeY = sizeY or 300
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 210, 0, sizeY)
    frame.Position = UDim2.new(0, posX, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 24)

    local corner = Instance.new("UICorner", frame) corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame) stroke.Color = Color3.fromRGB(0, 170, 255) stroke.Thickness = 1.2

    local titleBar = Instance.new("Frame", frame)
    titleBar.Size = UDim2.new(1, 0, 0, 26) titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    local titleCorner = Instance.new("UICorner", titleBar) titleCorner.CornerRadius = UDim.new(0, 8)

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, 0, 1, 0) titleText.BackgroundTransparency = 1
    titleText.Text = title titleText.TextColor3 = Color3.new(1, 1, 1) titleText.Font = Enum.Font.GothamBold titleText.TextSize = 12

    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, -10, 1, -55) container.Position = UDim2.new(0, 5, 0, 30)
    container.BackgroundTransparency = 1 container.BorderSizePixel = 0
    container.ScrollBarThickness = 2 container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)

    local layout = Instance.new("UIListLayout", container) layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local logoText = Instance.new("TextLabel", frame)
    logoText.Size = UDim2.new(1, 0, 0, 20) logoText.Position = UDim2.new(0, 0, 1, -20) logoText.BackgroundTransparency = 1
    logoText.Text = "N O V A" logoText.TextColor3 = Color3.fromRGB(0, 170, 255) logoText.Font = Enum.Font.GothamBold logoText.TextSize = 11 logoText.TextTransparency = 0.5

    makeDraggable(frame)
    return container
end

local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -4, 0, 26) btn.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
    btn.Text = text .. " : OFF" btn.TextColor3 = Color3.new(0.85, 0.85, 0.85) btn.Font = Enum.Font.Gotham btn.TextSize = 11
    local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0, 5)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(36, 36, 40)
        btn.TextColor3 = state and Color3.new(1, 1, 1) or Color3.new(0.85, 0.85, 0.85)
        if callback then task.spawn(callback, state) end
    end)
end

local function createSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", parent) sliderFrame.Size = UDim2.new(1, -4, 0, 40) sliderFrame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", sliderFrame) label.Size = UDim2.new(1, 0, 0, 16) label.BackgroundTransparency = 1 label.Text = text .. " : " .. tostring(default) label.TextColor3 = Color3.new(1,1,1) label.Font = Enum.Font.Gotham label.TextSize = 11 label.TextXAlignment = Enum.TextXAlignment.Left
    local container = Instance.new("TextButton", sliderFrame) container.Size = UDim2.new(1, 0, 0, 12) container.Position = UDim2.new(0, 0, 0, 18) container.BackgroundColor3 = Color3.fromRGB(36, 36, 40) container.Text = ""
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
-- 안정성 확보된 시각화 엔진 (ESP / 네임태그 / 트레이서)
---------------------------------------------------
local espObjects = {} local nameTags = {} local tracerLines = {}

local function isTeamMember(player)
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team == LocalPlayer.Team then return true end
    if CustomTeams[player.UserId] then return true end
    return false
end

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
        highlight.FillTransparency = espEnabled and 0.4 or 1
        highlight.OutlineTransparency = chamsEnabled and 0 or 1
        table.insert(espObjects, highlight)
    end

    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 3)
    if nameTagEnabled and head then
        local bbg = Instance.new("BillboardGui", character) bbg.Name = "ClientTag" bbg.AlwaysOnTop = true bbg.Size = UDim2.new(0, 200, 0, 40) bbg.Adornee = head bbg.StudsOffset = Vector3.new(0, 3, 0)
        local tl = Instance.new("TextLabel", bbg) tl.Size = UDim2.new(1, 0, 1, 0) tl.BackgroundTransparency = 1 tl.TextColor3 = Color3.fromRGB(255, 50, 50) tl.Font = Enum.Font.GothamBold tl.TextSize = 12 tl.TextStrokeTransparency = 0
        local hum = character:FindFirstChildOfClass("Humanoid")
        tl.Text = p.Name .. " [" .. tostring(hum and math.floor(hum.Health) or 100) .. " HP]"
        table.insert(nameTags, bbg)
    end
end

function refreshVisuals()
    for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end
    for _, tag in ipairs(nameTags) do if tag then tag:Destroy() end end
    espObjects = {} nameTags = {}
    if espEnabled or nameTagEnabled or chamsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then applyVisuals(p.Character) end end
    end
end

RunService.RenderStepped:Connect(function()
    for _, line in ipairs(tracerLines) do if line then line:Destroy() end end
    tracerLines = {}
    if not tracerEnabled or not LocalPlayer.Character then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isTeamMember(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local tracer = Instance.new("LineHandleAdornment", ScreenGui)
                    tracer.Length = (Camera.CFrame.Position - hrp.Position).Magnitude
                    tracer.Color3 = Color3.fromRGB(0, 170, 255) tracer.Thickness = 2 tracer.Adornee = Camera
                    tracer.CFrame = CFrame.lookAt(Camera.CFrame.Position, hrp.Position)
                    table.insert(tracerLines, tracer)
                end
            end
        end
    end
end)

local function monitorPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if espEnabled or nameTagEnabled or chamsEnabled then applyVisuals(char) end
    end)
    if player.Character then task.spawn(applyVisuals, player.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
Players.PlayerAdded:Connect(monitorPlayer)

---------------------------------------------------
-- [🔧 구조 개편] 물리 및 오토 기능 연산 코어
---------------------------------------------------

-- 최적 타겟 검색 함수
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

-- 1. 고무줄 튕김 우회형 스피드 / 점프 / 스태미나 통합 제어 루프
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if speedEnabled and hrp and hum and hum.MoveDirection.Magnitude > 0 then
        -- 이미지 내부 에러 방지형 프레임 위치 기반 보간 연산
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection.Unit * (SpeedValue / 110))
    end
    
    if infStaminaEnabled then
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            if LocalPlayer.Character then LocalPlayer.Character:SetAttribute("Stamina", 100) end
        end)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp or not infJumpEnabled or not LocalPlayer.Character then return end
    if input.KeyCode == Enum.KeyCode.Space then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, JumpValue, hrp.Velocity.Z) end
    end
end)

-- 2. 오류 복구형 킬아우라 (Knit 프레임워크 패킷 검증 우회)
task.spawn(function()
    while true do
        task.wait(0.08) -- 패킷 오염으로 인한 팅김 방지 딜레이 최적화
        if killAuraEnabled and LocalPlayer.Character then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                if dist <= KillAuraRange then
                    -- 프레임워크에 충돌을 주지 않는 안전한 전역 공격 패킷 난사
                    safeFireRemote("SwordHit", target.Character)
                    safeFireRemote("WeaponHit", {["entityInstance"] = target.Character, ["validate"] = {["targetPosition"] = target.Character.HumanoidRootPart.Position}})
                    safeFireRemote("AttackEntity", {["entity"] = target.Character})
                end
            end
        end
    end
end)

-- 3. 이미지 에러 방지형 리치 (Reach) 고도화
local reachConnection
local function toggleReach(state)
    reachEnabled = state if reachConnection then reachConnection:Disconnect() end
    if state then
        reachConnection = RunService.RenderStepped:Connect(function()
            -- 바이트코드를 손상시키지 않고 클라이언트 타격 히트박스만 확장
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(KillAuraRange, 5, KillAuraRange)
                tool.Handle.CanCollide = false
            end
        end)
    else
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            tool.Handle.Size = Vector3.new(2, 2, 2) -- 기본 스케일 복구
        end
    end
end

-- 4. 오토 브릿지 (발밑 자동 블록 매설)
RunService.Heartbeat:Connect(function()
    if not autoBridgeEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local placePos = hrp.Position + (hrp.Velocity.Unit * 1.2) - Vector3.new(0, 3.5, 0)
    
    -- Knit 내부의 블록 배치 리모트 패턴 안전 호출
    safeFireRemote("PlaceBlock", Vector3.new(math.floor(placePos.X), math.floor(placePos.Y), math.floor(placePos.Z)))
    safeFireRemote("BlockPlace", {["position"] = Vector3.new(math.floor(placePos.X), math.floor(placePos.Y), math.floor(placePos.Z))})
end)

---------------------------------------------------
-- UI 윈도우 & 레이아웃 세팅
---------------------------------------------------
local visualsWin = createWindow("Visuals", 30, 240)
local movementWin = createWindow("Movement", 250, 280)
local combatWin = createWindow("Combat", 470, 240)
local exploitsWin = createWindow("Exploits", 690, 200)

createToggle(visualsWin, "Player ESP", function(s) espEnabled = s refreshVisuals() end)
createToggle(visualsWin, "NameTags", function(s) nameTagEnabled = s refreshVisuals() end)
createToggle(visualsWin, "Tracers Line", function(s) tracerEnabled = s end)

createToggle(movementWin, "Speed Hack", function(s) speedEnabled = s end)
createSlider(movementWin, "Speed Value", 16, 50, 23, function(v) SpeedValue = v end)
createToggle(movementWin, "Infinite Jump", function(s) infJumpEnabled = s end)

createToggle(combatWin, "Kill Aura (Bypass)", function(s) killAuraEnabled = s end)
createSlider(combatWin, "Aura Range", 5, 25, 16, function(v) KillAuraRange = v end)
createToggle(combatWin, "Reach Extended", toggleReach)

createToggle(exploitsWin, "Auto Bridge", function(s) autoBridgeEnabled = s end)
createToggle(exploitsWin, "Infinite Stamina", function(s) infStaminaEnabled = s end)

-- UI 토글 제어 (RightShift)
local visible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        visible = not visible ScreenGui.Enabled = visible
    end
end)

print("[Nova V5] Knit Frame Crash Fix Complete. Toggle Key: RightShift")
