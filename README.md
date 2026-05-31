# NOVA-ROBLOX
NOVA ROLBOX BEDWARS SCRIPT

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/codeingsss/NOVA-ROBLOX/refs/heads/main/nova.lua"))()
```

How to use NOVA UI?

```lua
-- Load the Nova UI Library from the GitHub repository
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/codeingsss/NOVA-ROBLOX/refs/heads/main/novaui.lua"))()

-- Create the main window (Parameters: Window Title, X Position Offset, Y Size)
local MyWindow = Nova:CreateWindow("Nova Premium", 100, 250)

-- 1. Create a Click Button
MyWindow:CreateButton("Kill Player (Kill)", function()
    -- Action triggered when the button is clicked
    print("Button Pressed")
end)

-- 2. Create a Toggle Switch
MyWindow:CreateToggle("Infinite Jump (Inf Jump)", function(state)
    -- 'state' is a boolean value (true = ON, false = OFF)
    if state then
        print("Toggle ON: Infinite Jump Activated")
    else
        print("Toggle OFF: Infinite Jump Deactivated")
    end
end)

-- 3. Create a Slider Bar
-- Parameters: Label Text, Minimum Value, Maximum Value, Default Value, Callback Function
MyWindow:CreateSlider("WalkSpeed (Speed)", 16, 200, 16, function(value)
    -- 'value' changes dynamically as the player drags the slider
    print("Slider Changed: Speed set to " .. tostring(value))
    
    -- Example implementation (Uncomment to use):
    -- if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
    --     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    -- end
end)
```
