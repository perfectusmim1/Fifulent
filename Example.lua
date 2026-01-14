local Library
if script and script.Parent and script.Parent:FindFirstChild("Library") then
    Library = require(script.Parent.Library)
else
    -- Fallback or placeholder for the user to fill functionality if running standalone
    warn("Library module not found in script.Parent. Please ensure Library.lua is present.")
    return
end

local Window = Library:CreateWindow({
    Title = "Fifulent Demo",
    SubTitle = "by Vanta",
    TabWidth = 160,
    Theme = {
        Accent = Color3.fromRGB(0, 255, 128), -- Custom Green Accent
        Acrylic = true
    }
})

--// Tabs
local Tabs = {
    Main = Window:CreateTab({ Name = "Main", Icon = "rbxassetid://6031075931" }), -- Home icon
    Combat = Window:CreateTab({ Name = "Combat", Icon = "rbxassetid://6031090990" }), -- Sword icon
    Visuals = Window:CreateTab({ Name = "Visuals", Icon = "rbxassetid://6031075929" }), -- Eye icon
    Settings = Window:CreateTab({ Name = "Settings", Icon = "rbxassetid://6031057805" }) -- Cog icon
}

--// Main Tab
local Section1 = Tabs.Main:CreateSection("Showcase")

Section1:CreateLabel("Welcome to Fifulent UI Library.")

Section1:CreateButton({
    Name = "Notify Me",
    Callback = function()
        Library:Notify({
            Title = "Hello!",
            Content = "This is a toast notification.",
            Duration = 3
        })
    end
})

Section1:CreateButton({
    Name = "Destructive Action",
    Callback = function()
        Library:Notify({
            Title = "Warning",
            Content = "You clicked a button!",
            Duration = 2
        })
    end
})

local Toggle1 = Section1:CreateToggle({
    Name = "Enable Feature",
    Default = true,
    Callback = function(state)
        print("Toggle 1 State:", state)
    end
})

Section1:CreateToggle({
    Name = "Silent Aim",
    Default = false,
    ConfigName = "SilentAim", -- Auto save key
    Callback = function(state)
        print("Silent Aim:", state)
    end
})

--// Combat Tab
local Section2 = Tabs.Combat:CreateSection("Aimbot Settings")

Section2:CreateSlider({
    Name = "FOV Radius",
    Min = 0,
    Max = 360,
    Default = 90,
    Suffix = "°",
    Callback = function(val)
        print("FOV:", val)
    end
})

Section2:CreateSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(val)
        print("Smoothness:", val)
    end
})

Section2:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(val)
        print("Aim Part:", val)
    end
})

Section2:CreateDropdown({
    Name = "Target Mode",
    Options = {"Distance", "Health", "FOV"},
    Multi = true,
    Callback = function(val)
        print("Modes:", table.concat(val, ", "))
    end
})

--// Visuals Tab
local Section3 = Tabs.Visuals:CreateSection("ESP Colors")

Section3:CreateColorPicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(col)
        print("Color:", col)
    end
})

Section3:CreateColorPicker({
    Name = "Team Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(col)
        print("Color:", col)
    end
})

--// Settings Tab
local Section4 = Tabs.Settings:CreateSection("Configuration")

Section4:CreateKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Library:Notify({Title = "Keybind", Content = "Right Control Pressed"})
    end
})

Section4:CreateInput({
    Name = "Custom Config Name",
    Callback = function(text)
        print("Input:", text)
    end
})

Section4:CreateButton({
    Name = "Save Config",
    Callback = function()
        Library:Notify({Title = "Config", Content = "Saved settings!"})
    end
})

Library:Notify({
    Title = "Loaded",
    Content = "The script has been loaded successfully.",
    Duration = 5
})
