local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Fifulent = {}

--// Utils
local Utility = {}
local Tweening = {}

function Utility:GetIcon(icon_id)
    if not icon_id then return "" end
    if string.find(tostring(icon_id), "rbxassetid://") then
        return icon_id
    end
    return "rbxassetid://" .. tostring(icon_id)
end

function Utility:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        frame.Position = targetPos
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Tweening.Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

--// Theme Manager
local Theme = {
    Accent = Color3.fromRGB(0, 122, 255), -- iOS Blue default
    Acrylic = true,
    Background = Color3.fromRGB(20, 20, 20),
    Container = Color3.fromRGB(30, 30, 30),
    Element = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    Outline = Color3.fromRGB(60, 60, 60),
    Font = Enum.Font.Gotham, -- Or similar modern font
    BoldFont = Enum.Font.GothamBold,
}

local function GetTheme()
    return Theme
end

--// Config System
local ConfigManager = {
    Settings = {}
}

function ConfigManager:Save(name)
    local json = HttpService:JSONEncode(self.Settings)
    if writefile then
        writefile(name .. ".json", json)
    end
end

function ConfigManager:Load(name)
    if isfile and isfile(name .. ".json") then
        local json = readfile(name .. ".json")
        self.Settings = HttpService:JSONDecode(json)
        return true
    end
    return false
end

--// UI Elements Support
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Outline
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://8992230677" -- Classic rounded shadow
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.SliceCenter = Rect.new(85, 85, 427, 427)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 0.6
    shadow.Parent = parent
end

--// Main Library Functions
function Fifulent:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Fifulent UI"
    local SubTitle = options.SubTitle or ""
    local TabWidth = options.TabWidth or 160
    local LibrarySize = options.Size or UDim2.fromOffset(650, 400)
    
    -- Update theme if provided
    if options.Theme then
        for k, v in pairs(options.Theme) do
            Theme[k] = v
        end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Fifulent_" .. Title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if gethui then
        ScreenGui.Parent = gethui()
    elseif CoreGui:FindFirstChild("RobloxGui") then
         ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromScale(0,0) -- Animate in
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    CreateCorner(MainFrame, 10)
    CreateStroke(MainFrame, Theme.Outline, 1)
    
    -- Acrylic/Blur Effect
    if options.Acrylic then
       MainFrame.BackgroundTransparency = 0.1
       local BlurImage = Instance.new("ImageLabel")
       BlurImage.Size = UDim2.fromScale(1, 1)
       BlurImage.BackgroundTransparency = 1
       BlurImage.Image = "rbxassetid://8992230677" -- Placeholder noise
       BlurImage.ImageTransparency = 0.96
       BlurImage.ZIndex = 0
       BlurImage.Parent = MainFrame
    end

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame
    
    Utility:MakeDraggable(MainFrame, Header)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Theme.BoldFont
    TitleLabel.TextSize = 16
    TitleLabel.Parent = Header

    if SubTitle ~= "" then
        local SubTitleLabel = Instance.new("TextLabel")
        SubTitleLabel.Name = "SubTitle"
        SubTitleLabel.Size = UDim2.new(0, 200, 1, 0)
        SubTitleLabel.Position = UDim2.new(0, 15 + TitleLabel.TextBounds.X + 10, 0, 0)
        SubTitleLabel.BackgroundTransparency = 1
        SubTitleLabel.Text = SubTitle
        SubTitleLabel.TextColor3 = Theme.SubText
        SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubTitleLabel.Font = Theme.Font
        SubTitleLabel.TextSize = 14
        SubTitleLabel.Parent = Header
    end

    -- Controls
    local ControlHolder = Instance.new("Frame")
    ControlHolder.Name = "Controls"
    ControlHolder.Size = UDim2.new(0, 60, 1, 0)
    ControlHolder.Position = UDim2.new(1, -65, 0, 0)
    ControlHolder.BackgroundTransparency = 1
    ControlHolder.Parent = Header
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(0, 30, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.SubText
    CloseBtn.Font = Theme.Font
    CloseBtn.TextSize = 16
    CloseBtn.Parent = ControlHolder
    CloseBtn.MouseButton1Click:Connect(function()
        local t = Tweening.Tween(MainFrame, TweenInfo.new(0.3), {Size = UDim2.fromScale(0,0)})
        t.Completed:Wait()
        ScreenGui:Destroy()
    end)
    CloseBtn.MouseEnter:Connect(function() Tweening.Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(240, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() Tweening.Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}) end)
    
     -- Content Area
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, TabWidth, 1, -45)
    Sidebar.Position = UDim2.new(0, 10, 0, 40)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 2
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.Parent = MainFrame
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local PagesHolder = Instance.new("Frame")
    PagesHolder.Name = "Pages"
    PagesHolder.Size = UDim2.new(1, -TabWidth - 25, 1, -50)
    PagesHolder.Position = UDim2.new(0, TabWidth + 20, 0, 45)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent = MainFrame
    
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Animate Open
    Tweening.Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = LibrarySize})
    
    -- Notifications
    local NotifyHolder = Instance.new("Frame")
    NotifyHolder.Name = "Notifications"
    NotifyHolder.Size = UDim2.new(0, 300, 1, 0)
    NotifyHolder.Position = UDim2.new(1, -310, 0, -20)
    NotifyHolder.AnchorPoint = Vector2.new(0, 0)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.Parent = ScreenGui
    
    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifyLayout.Padding = UDim.new(0, 5)
    NotifyLayout.Parent = NotifyHolder
    
    function Fifulent:Notify(opts)
        opts = opts or {}
        local title = opts.Title or "Notification"
        local content = opts.Content or "Content"
        local duration = opts.Duration or 3
        
        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Size = UDim2.new(0, 260, 0, 70)
        Toast.BackgroundColor3 = Theme.Container
        Toast.BackgroundTransparency = 1 -- Animate in
        Toast.Parent = NotifyHolder
        CreateCorner(Toast, 8)
        
        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, -20, 0, 25)
        TTitle.Position = UDim2.new(0, 10, 0, 5)
        TTitle.BackgroundTransparency = 1
        TTitle.Text = title
        TTitle.TextColor3 = Theme.Text
        TTitle.Font = Theme.BoldFont
        TTitle.TextSize = 14
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.TextTransparency = 1
        TTitle.Parent = Toast
        
        local TContent = Instance.new("TextLabel")
        TContent.Size = UDim2.new(1, -20, 0, 35)
        TContent.Position = UDim2.new(0, 10, 0, 30)
        TContent.BackgroundTransparency = 1
        TContent.Text = content
        TContent.TextColor3 = Theme.SubText
        TContent.Font = Theme.Font
        TContent.TextSize = 13
        TContent.TextXAlignment = Enum.TextXAlignment.Left
        TContent.TextTransparency = 1
        TContent.TextWrapped = true
        TContent.Parent = Toast
        
        -- Animation IN
        Tweening.Tween(Toast, TweenInfo.new(0.5), {BackgroundTransparency = 0.1})
        Tweening.Tween(TTitle, TweenInfo.new(0.5), {TextTransparency = 0})
        Tweening.Tween(TContent, TweenInfo.new(0.5), {TextTransparency = 0})
        
        task.delay(duration, function()
             -- Animation OUT
            local close = Tweening.Tween(Toast, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            Tweening.Tween(TTitle, TweenInfo.new(0.5), {TextTransparency = 1})
            Tweening.Tween(TContent, TweenInfo.new(0.5), {TextTransparency = 1})
            close.Completed:Wait()
            Toast:Destroy()
        end)
    end
    
    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local TabName = tabOpts.Name or "Tab"
        local TabIcon = tabOpts.Icon or ""
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = Sidebar
        
        CreateCorner(TabButton, 6)
        
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 10, 0, 6)
        Icon.BackgroundTransparency = 1
        Icon.Image = Utility:GetIcon(TabIcon)
        Icon.ImageColor3 = Theme.SubText
        Icon.Parent = TabButton
        if TabIcon == "" then Icon.Visible = false end
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 1, 0)
        Label.Position = UDim2.new(0, TabIcon ~= "" and 38 or 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = TabName
        Label.TextColor3 = Theme.SubText
        Label.Font = Theme.Font
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = TabButton
        
        -- Tab Content Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.Parent = PagesHolder
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local TabObj = {}
        
        function TabObj:Activate()
            -- Reset others
            for _, t in pairs(Window.Tabs) do
                Tweening.Tween(t.UI.Label, TweenInfo.new(0.3), {TextColor3 = Theme.SubText})
                Tweening.Tween(t.UI.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.SubText})
                Tweening.Tween(t.UI.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1})
                t.Page.Visible = false
            end
            
            -- Active State
            Tweening.Tween(Label, TweenInfo.new(0.3), {TextColor3 = Theme.Text})
            Tweening.Tween(Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.Text})
            Tweening.Tween(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.92, BackgroundColor3 = Theme.Text})
            
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0,0)
        end
        
        TabButton.MouseButton1Click:Connect(function()
            TabObj:Activate()
        end)
        
        -- Store in window
        TabObj.UI = {Button=TabButton, Label=Label, Icon=Icon}
        TabObj.Page = Page
        table.insert(Window.Tabs, TabObj)
        
        -- Auto select first
        if #Window.Tabs == 1 then
            TabObj:Activate()
        end
        
        function TabObj:CreateSection(secName)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = secName or "Section"
            SectionFrame.Size = UDim2.new(1, -4, 0, 30)
            SectionFrame.BackgroundColor3 = Theme.Container         
            SectionFrame.BackgroundTransparency = 0
            SectionFrame.Parent = Page
            CreateCorner(SectionFrame, 8)
            
            local SecTitle = Instance.new("TextLabel")
            SecTitle.Size = UDim2.new(1, -20, 0, 30)
            SecTitle.Position = UDim2.new(0, 10, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = secName or ""
            SecTitle.TextColor3 = Theme.SubText
            SecTitle.Font = Theme.BoldFont
            SecTitle.TextSize = 13
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = SectionFrame
            
            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.Position = UDim2.new(0, 10, 0, 35)
            Container.BackgroundTransparency = 1
            Container.Parent = SectionFrame
            
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 6)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Parent = Container
            
            local function Resize()
                Container.Size = UDim2.new(1, -20, 0, ContainerLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, -4, 0, ContainerLayout.AbsoluteContentSize.Y + 45)
            end
            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)
            
            local SectionObj = {}
            
            --// ELEMENTS
            
            function SectionObj:CreateLabel(text)
                local Lab = Instance.new("TextLabel")
                Lab.Size = UDim2.new(1, 0, 0, 20)
                Lab.BackgroundTransparency = 1
                Lab.Text = text
                Lab.TextColor3 = Theme.SubText
                Lab.Font = Theme.Font
                Lab.TextSize = 14
                Lab.TextXAlignment = Enum.TextXAlignment.Left
                Lab.Parent = Container
                Resize()
            end
            
            function SectionObj:CreateButton(bOpts)
                bOpts = bOpts or {}
                local Text = bOpts.Name or "Button"
                local Callback = bOpts.Callback or function() end
                
                local Btn = Instance.new("TextButton")
                Btn.Name = Text
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Theme.Element
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.Parent = Container
                CreateCorner(Btn, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -20, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Text = Text
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Btn
                
                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.new(0, 16, 0, 16)
                Icon.Position = UDim2.new(1, -26, 0.5, -8) -- Right side
                Icon.BackgroundTransparency = 1
                Icon.Image = "rbxassetid://10709791437" -- Pointer/Click icon
                Icon.ImageColor3 = Theme.SubText
                Icon.Parent = Btn
                
                Btn.MouseEnter:Connect(function()
                    Tweening.Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(Theme.Element.R*255 + 10, Theme.Element.G*255 + 10, Theme.Element.B*255 + 10)})
                end)
                Btn.MouseLeave:Connect(function()
                    Tweening.Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element})
                end)
                Btn.MouseButton1Click:Connect(function()
                     -- Click effect
                    local t = Tweening.Tween(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -5, 0, 30)}) -- shrink
                    t.Completed:Wait()
                    Tweening.Tween(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 32)}) -- restore
                    Callback()
                end)
                Resize()
            end
            
            function SectionObj:CreateToggle(tOpts)
                tOpts = tOpts or {}
                local Name = tOpts.Name or "Toggle"
                local Default = tOpts.Default or false
                local Callback = tOpts.Callback or function() end
                local ConfigName = tOpts.ConfigName
                
                local State = Default
                if ConfigName and ConfigManager.Settings[ConfigName] ~= nil then
                    State = ConfigManager.Settings[ConfigName]
                end

                local ContainerBtn = Instance.new("TextButton")
                ContainerBtn.Name = Name
                ContainerBtn.Size = UDim2.new(1, 0, 0, 32)
                ContainerBtn.BackgroundColor3 = Theme.Element
                ContainerBtn.Text = ""
                ContainerBtn.AutoButtonColor = false
                ContainerBtn.Parent = Container
                CreateCorner(ContainerBtn, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -60, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = ContainerBtn
                
                -- Switch BG
                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 40, 0, 20)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(60, 60, 60)
                Switch.Parent = ContainerBtn
                CreateCorner(Switch, 10)
                
                -- Knob
                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Switch
                CreateCorner(Knob, 8)
                
                local function UpdateState(notify)
                    State = not State
                    Callback(State)
                    if ConfigName then
                        ConfigManager.Settings[ConfigName] = State
                    end
                    
                    if State then
                        Tweening.Tween(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent})
                        Tweening.Tween(Knob, TweenInfo.new(0.3), {Position = UDim2.new(1, -18, 0.5, -8)})
                    else
                        Tweening.Tween(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
                        Tweening.Tween(Knob, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -8)})
                    end
                end
                
                ContainerBtn.MouseButton1Click:Connect(function() UpdateState(true) end)
                Resize()
                
                return {
                    Set = function(val)
                         State = not val
                         UpdateState(false)
                    end,
                    Value = State
                }
            end
            
            function SectionObj:CreateSlider(sOpts)
                sOpts = sOpts or {}
                local Name = sOpts.Name or "Slider"
                local Min = sOpts.Min or 0
                local Max = sOpts.Max or 100
                local Default = sOpts.Default or Min
                local Suffix = sOpts.Suffix or ""
                local Callback = sOpts.Callback or function() end
                
                local Value = math.clamp(Default, Min, Max)
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = Name
                SliderFrame.Size = UDim2.new(1, 0, 0, 45)
                SliderFrame.BackgroundColor3 = Theme.Element
                SliderFrame.Parent = Container
                CreateCorner(SliderFrame, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(0, 200, 0, 20)
                Title.Position = UDim2.new(0, 10, 0, 5)
                Title.BackgroundTransparency = 1
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 50, 0, 20)
                ValueLabel.Position = UDim2.new(1, -60, 0, 5)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Value) .. Suffix
                ValueLabel.TextColor3 = Theme.SubText
                ValueLabel.Font = Theme.Font
                ValueLabel.TextSize = 14
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(1, -20, 0, 4)
                Bar.Position = UDim2.new(0, 10, 0, 30)
                Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Bar.Parent = SliderFrame
                CreateCorner(Bar, 2)
                
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.Parent = Bar
                CreateCorner(Fill, 2)
                
                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(1, -6, 0.5, -6)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Fill
                CreateCorner(Knob, 6)
                
                local Dragging = false
                
                local function Update(input)
                    local sizeX = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local newVal = math.floor(Min + ((Max - Min) * sizeX))
                    
                    Value = newVal
                    ValueLabel.Text = tostring(Value) .. Suffix
                    Fill.Size = UDim2.new(sizeX, 0, 1, 0)
                    Callback(Value)
                end
                
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(input)
                    end
                end)
                
                Knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                Resize()
            end
            
            function SectionObj:CreateDropdown(dOpts)
                dOpts = dOpts or {}
                local Name = dOpts.Name or "Dropdown"
                local List = dOpts.Options or {}
                local Multi = dOpts.Multi or false
                local Callback = dOpts.Callback or function() end
                
                -- State
                local Selected = Multi and {} or nil
                local Open = false
                
                local DropFrame = Instance.new("Frame")
                DropFrame.Name = Name
                DropFrame.Size = UDim2.new(1, 0, 0, 36)
                DropFrame.BackgroundColor3 = Theme.Element
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = Container
                CreateCorner(DropFrame, 6)
                
                local HeaderBtn = Instance.new("TextButton")
                HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Text = ""
                HeaderBtn.Parent = DropFrame
                
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(0, 150, 0, 36)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = HeaderBtn
                
                local Status = Instance.new("TextLabel")
                Status.Size = UDim2.new(1, -180, 0, 36)
                Status.Position = UDim2.new(0, 160, 0, 0)
                Status.BackgroundTransparency = 1
                Status.Text = "None"
                Status.TextColor3 = Theme.SubText
                Status.Font = Theme.Font
                Status.TextSize = 13
                Status.TextXAlignment = Enum.TextXAlignment.Right
                Status.TextTruncate = Enum.TextTruncate.AtEnd
                Status.Parent = HeaderBtn
                
                local Arrow = Instance.new("ImageLabel")
                Arrow.Size = UDim2.new(0, 16, 0, 16)
                Arrow.Position = UDim2.new(1, -25, 0.5, -8)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = "rbxassetid://6031091004" -- arrow down
                Arrow.Parent = HeaderBtn
                
                local OptionContainer = Instance.new("Frame")
                OptionContainer.Size = UDim2.new(1, 0, 0, 0)
                OptionContainer.Position = UDim2.new(0, 0, 0, 36)
                OptionContainer.BackgroundTransparency = 1
                OptionContainer.Parent = DropFrame
                
                local OptLayout = Instance.new("UIListLayout")
                OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptLayout.Parent = OptionContainer
                
                local function Refresh()
                    -- Clear old
                    for _, c in pairs(OptionContainer:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    
                    for _, opt in pairs(List) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 30)
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.Text = "   " .. opt
                        OptBtn.TextColor3 = Theme.SubText
                        OptBtn.Font = Theme.Font
                        OptBtn.TextSize = 13
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.Parent = OptionContainer
                        
                        -- Selection Logic
                        local isSel = false
                        if Multi then
                             if table.find(Selected, opt) then isSel = true end
                        else
                             if Selected == opt then isSel = true end
                        end
                        
                        if isSel then
                            OptBtn.TextColor3 = Theme.Accent
                        end
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            if Multi then
                                if table.find(Selected, opt) then
                                    table.remove(Selected, table.find(Selected, opt))
                                else
                                    table.insert(Selected, opt)
                                end
                                Status.Text = table.concat(Selected, ", ")
                                Callback(Selected)
                            else
                                Selected = opt
                                Status.Text = opt
                                Callback(Selected)
                                -- Close on single select
                                Open = false
                                Tweening.Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 36)})
                                Tweening.Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                                Resize()
                            end
                            Refresh() -- Refresh colors
                        end)
                    end
                    
                    -- Re-size option container
                    OptionContainer.Size = UDim2.new(1, 0, 0, OptLayout.AbsoluteContentSize.Y)
                end
                
                HeaderBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Refresh()
                    local targetH = Open and (36 + OptionContainer.Size.Y.Offset) or 36
                    Tweening.Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetH)})
                    Tweening.Tween(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0})
                    Resize() -- Update section
                end)
                
                Resize()
            end
            
            function SectionObj:CreateColorPicker(cOpts)
                local Name = cOpts.Name or "Color Picker"
                local DefColor = cOpts.Default or Color3.new(1,1,1)
                
                local CPFrame = Instance.new("Frame")
                CPFrame.Size = UDim2.new(1, 0, 0, 32)
                CPFrame.BackgroundColor3 = Theme.Element
                CPFrame.Parent = Container
                CreateCorner(CPFrame, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -50, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = CPFrame
                
                local Preview = Instance.new("Frame")
                Preview.Size = UDim2.new(0, 40, 0, 20)
                Preview.Position = UDim2.new(1, -50, 0.5, -10)
                Preview.BackgroundColor3 = DefColor
                Preview.Parent = CPFrame
                CreateCorner(Preview, 4)
                
                Resize()
            end
            
            function SectionObj:CreateKeybind(kOpts)
                local Name = kOpts.Name or "Keybind"
                local DefKey = kOpts.Default or Enum.KeyCode.E
                local Callback = kOpts.Callback or function() end
                
                local BindFrame = Instance.new("Frame")
                BindFrame.Size = UDim2.new(1, 0, 0, 32)
                BindFrame.BackgroundColor3 = Theme.Element
                BindFrame.Parent = Container
                CreateCorner(BindFrame, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Text = Name
                Title.Size = UDim2.new(0, 150, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Theme.Text
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = BindFrame
                
                local BindBtn = Instance.new("TextButton")
                BindBtn.Size = UDim2.new(0, 80, 0, 24)
                BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
                BindBtn.BackgroundColor3 = Theme.Container
                BindBtn.Text = DefKey.Name
                BindBtn.TextColor3 = Theme.SubText
                BindBtn.Parent = BindFrame
                CreateCorner(BindBtn, 4)
                
                local listening = false
                
                BindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    BindBtn.Text = "..."
                    UserInputService.InputBegan:Once(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            DefKey = input.KeyCode
                            BindBtn.Text = DefKey.Name
                            listening = false
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and input.KeyCode == DefKey then
                        Callback()
                    end
                end)
                Resize()
            end
            
             function SectionObj:CreateInput(iOpts)
                local Name = iOpts.Name or "Input"
                local Callback = iOpts.Callback or function() end
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 40)
                InputFrame.BackgroundColor3 = Theme.Element
                InputFrame.Parent = Container
                CreateCorner(InputFrame, 6)
                
                local Title = Instance.new("TextLabel")
                Title.Text = Name
                Title.Size = UDim2.new(0, 100, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Theme.Text
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = InputFrame
                
                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(0, 150, 0, 26)
                Box.Position = UDim2.new(1, -160, 0.5, -13)
                Box.BackgroundColor3 = Theme.Container
                Box.TextColor3 = Theme.Text
                Box.Text = ""
                Box.PlaceholderText = "Type here..."
                Box.Parent = InputFrame
                CreateCorner(Box, 4)
                
                Box.FocusLost:Connect(function(enter)
                    Callback(Box.Text)
                end)
                Resize()
            end

            return SectionObj
        end
        
        return TabObj
    end
    
    return Window
end

return Fifulent
