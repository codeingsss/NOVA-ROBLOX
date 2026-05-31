local NovaUILib = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI 가 존재할 최상위 부모 GUI 생성
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaCustom_UI_Library"
if gethui then 
    ScreenGui.Parent = gethui() 
else 
    ScreenGui.Parent = game:GetService("CoreGui") 
end

-- 드래그 앤 드롭 함수 (창을 마우스로 끌어서 이동)
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

-- [메인 기능] 새로운 윈도우 창 생성
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

    -- 타이틀 바 (상단 바)
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

    -- 내부 스크롤 영역 (아이템이 많아지면 스크롤 가능)
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
    
    -- 내부 컴포넌트 추가를 위한 오브젝트 반환
    local WindowElements = {}

    -- 1. 토글 버튼 추가 함수
    function WindowElements:CreateToggle(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -4, 0, 28) 
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
        btn.Text = text .. " : OFF" 
        btn.TextColor3 = Color3.new(0.9, 0.9, 0.9) 
        btn.Font = Enum.Font.Gotham 
        btn.TextSize = 11
        
        local btnCorner = Instance.new("UICorner", btn) 
        btnCorner.CornerRadius = UDim.new(0, 5)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. " : " .. (state and "ON" or "OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 44)
            btn.TextColor3 = state and Color3.new(1, 1, 1) or Color3.new(0.9, 0.9, 0.9)
            if callback then callback(state) end
        end)
    end

    -- 2. 일반 클릭 버튼 추가 함수
    function WindowElements:CreateButton(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -4, 0, 28) 
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        btn.Text = text 
        btn.TextColor3 = Color3.new(1, 1, 1) 
        btn.Font = Enum.Font.GothamMedium 
        btn.TextSize = 11
        
        local btnCorner = Instance.new("UICorner", btn) 
        btnCorner.CornerRadius = UDim.new(0, 5)
        
        -- 테두리 효과
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Color3.fromRGB(60, 60, 65)
        bStroke.Thickness = 1

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- 3. 슬라이더 바 추가 함수
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

-- RightShift 키를 누르면 전체 UI를 켜고 끌 수 있는 토글 시스템
local uiVisible = true
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        ScreenGui.Enabled = uiVisible
    end
end)

return NovaUILib
