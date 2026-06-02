local NovaUILib = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- UI 최상위 부모 GUI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaCustom_UI_Library"
if gethui then 
    ScreenGui.Parent = gethui() 
else 
    ScreenGui.Parent = game:GetService("CoreGui") 
end

-- 드래그 앤 드롭 함수
local function makeDraggable(frame)
    local dragging, startPos, startFramePos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true 
            startPos = input.Position 
            startFramePos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(
                startFramePos.X.Scale, startFramePos.X.Offset + delta.X, 
                startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
    end)
end

-- 새로운 윈도우 창 생성
function NovaUILib:CreateWindow(title, posX, sizeY)
    sizeY = sizeY or 300
    posX = posX or 50
    
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 210, 0, sizeY)
    frame.Position = UDim2.new(0, posX, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)

    local corner = Instance.new("UICorner", frame) 
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame) 
    stroke.Color = Color3.fromRGB(0, 170, 255) 
    stroke.Thickness = 1.2

    -- 상단 타이틀 바
    local titleBar = Instance.new("Frame", frame)
    titleBar.Size = UDim2.new(1, 0, 0, 28) 
    titleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    
    local titleCorner = Instance.new("UICorner", titleBar) 
    titleCorner.CornerRadius = UDim.new(0, 8)

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, 0, 1, 0) 
    titleText.BackgroundTransparency = 1
    titleText.Text = title 
    titleText.TextColor3 = Color3.new(1, 1, 1) 
    titleText.Font = Enum.Font.GothamBold 
    titleText.TextSize = 12

    -- 내부 스크롤 영역
    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, -10, 1, -45) 
    container.Position = UDim2.new(0, 5, 0, 35)
    container.BackgroundTransparency = 1 
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2 
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)

    local layout = Instance.new("UIListLayout", container) 
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    makeDraggable(frame)
    
    local WindowElements = {}

    -- 1. 알약 토글 스위치
    function WindowElements:CreateToggle(text, callback)
        local toggleRow = Instance.new("TextButton", container)
        toggleRow.Size = UDim2.new(1, -4, 0, 32) 
        toggleRow.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
        toggleRow.Text = "" 
        toggleRow.AutoButtonColor = false
        
        local rowCorner = Instance.new("UICorner", toggleRow)
        rowCorner.CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", toggleRow)
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 230, 235)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        -- 알약 모양 바 배경
        local switchBg = Instance.new("Frame", toggleRow)
        switchBg.Size = UDim2.new(0, 38, 0, 20)
        switchBg.Position = UDim2.new(1, -46, 0.5, -10)
        switchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        
        local bgCorner = Instance.new("UICorner", switchBg)
        bgCorner.CornerRadius = UDim.new(1, 0)

        -- 화이트 원형 노브
        local knob = Instance.new("Frame", switchBg)
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        
        local knobCorner = Instance.new("UICorner", knob)
        knobCorner.CornerRadius = UDim.new(1, 0)

        local state = false
        local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        toggleRow.MouseButton1Click:Connect(function()
            state = not state
            
            local targetBgColor = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 55)
            local targetKnobPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            
            TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = targetBgColor}):Play()
            TweenService:Create(knob, tweenInfo, {Position = targetKnobPos}):Play()
            
            if callback then callback(state) end
        end)
    end

    -- 2. 클릭 애니메이션 버튼 (파란색 깜빡임 구현 완료)
    function WindowElements:CreateButton(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -4, 0, 28) 
        local defaultColor = Color3.fromRGB(42, 42, 48)
        btn.BackgroundColor3 = defaultColor
        btn.Text = text 
        btn.TextColor3 = Color3.new(1, 1, 1) 
        btn.Font = Enum.Font.GothamMedium 
        btn.TextSize = 11
        
        local btnCorner = Instance.new("UICorner", btn) 
        btnCorner.CornerRadius = UDim.new(0, 5)
        
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Color3.fromRGB(60, 60, 65)
        bStroke.Thickness = 1

        btn.MouseButton1Click:Connect(function()
            -- 누르자마자 0.05초만에 파란색으로 변경 (강렬한 피드백)
            local clickTween = TweenService:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)})
            -- 이후 0.25초 동안 스르륵 원래 색상으로 복귀
            local releaseTween = TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = defaultColor})
            
            clickTween:Play()
            clickTween.Completed:Connect(function()
                releaseTween:Play()
            end)

            if callback then callback() end
        end)
    end

    -- 3. 슬라이더 바
    function WindowElements:CreateSlider(text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame", container) 
        sliderFrame.Size = UDim2.new(1, -4, 0, 42) 
        sliderFrame.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", sliderFrame) 
        label.Size = UDim2.new(1, 0, 0, 18) 
        label.BackgroundTransparency = 1 
        label.Text = text .. " : " .. tostring(default) 
        label.TextColor3 = Color3.new(1, 1, 1) 
        label.Font = Enum.Font.Gotham 
        label.TextSize = 11 
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local sliderBtn = Instance.new("TextButton", sliderFrame) 
        sliderBtn.Size = UDim2.new(1, 0, 0, 12) 
        sliderBtn.Position = UDim2.new(0, 0, 0, 20) 
        sliderBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 40) 
        sliderBtn.Text = ""
        
        local cCorner = Instance.new("UICorner", sliderBtn) 
        cCorner.CornerRadius = UDim.new(0, 4)
        
        local bar = Instance.new("Frame", sliderBtn) 
        local startPercent = (default - min) / (max - min) 
        bar.Size = UDim2.new(startPercent, 0, 1, 0) 
        bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        
        local bCorner = Instance.new("UICorner", bar) 
        bCorner.CornerRadius = UDim.new(0, 4)

        local function updateSlider(input)
            local posX = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1) 
            bar.Size = UDim2.new(posX, 0, 1, 0)
            local value = math.floor(min + (posX * (max - min))) 
            label.Text = text .. " : " .. tostring(value) 
            if callback then callback(value) end
        end
        
        local sliding = false
        sliderBtn.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                sliding = true 
                updateSlider(input) 
            end 
        end)
        UIS.InputChanged:Connect(function(input) 
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then 
                updateSlider(input) 
            end 
        end)
        UIS.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                sliding = false 
            end 
        end)
    end

    return WindowElements
end

-- UI 단축키 토글 시스템 (RightShift)
local uiVisible = true
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        ScreenGui.Enabled = uiVisible
    end
end)

return NovaUILib
