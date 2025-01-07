local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UILibrary = {
    Theme = {
        Primary = Color3.fromRGB(41, 128, 185),
        Secondary = Color3.fromRGB(44, 62, 80),
        Background = Color3.fromRGB(52, 73, 94),
        Text = Color3.fromRGB(236, 240, 241),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15),
        Info = Color3.fromRGB(52, 152, 219),
        Accent = Color3.fromRGB(155, 89, 182),
        Border = Color3.fromRGB(44, 62, 80),
    },
    Windows = {},
    Config = {
        DefaultSize = UDim2.new(0, 600, 0, 400),
        DefaultTitle = "UI Library",
        DefaultDraggable = true,
        DefaultResizable = true,
        DefaultMinSize = Vector2.new(200, 200),
        DefaultMaxSize = Vector2.new(800, 600),
        NotificationDuration = 3,
        NotificationPosition = UDim2.new(1, -320, 1, -100),
        AnimationDuration = 0.3,
        CornerRadius = UDim.new(0, 6),
    }
}

-- Window Component
local Window = {}
Window.__index = Window

function Window.new(library, title)
    local self = setmetatable({}, Window)
    self.Library = library
    
    self.Container = Instance.new("Frame")
    self.Container.Name = "Window"
    self.Container.Size = library.Config.DefaultSize
    self.Container.Position = UDim2.new(0.5, -library.Config.DefaultSize.X.Offset/2, 0.5, -library.Config.DefaultSize.Y.Offset/2)
    self.Container.BackgroundColor3 = library.Theme.Background
    self.Container.Parent = library.ScreenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = library.Config.CornerRadius
    corner.Parent = self.Container
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = library.Theme.Secondary
    self.TitleBar.Parent = self.Container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = library.Config.CornerRadius
    titleCorner.Parent = self.TitleBar
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Text = title or library.Config.DefaultTitle
    self.Title.Size = UDim2.new(1, -60, 1, 0)
    self.Title.Position = UDim2.new(0, 10, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.TextColor3 = library.Theme.Text
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 0)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = library.Theme.Text
    self.CloseButton.TextSize = 20
    self.CloseButton.Parent = self.TitleBar
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.Container:Destroy()
    end)
    
    -- Content
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -20, 1, -40)
    self.Content.Position = UDim2.new(0, 10, 0, 35)
    self.Content.BackgroundTransparency = 1
    self.Content.ScrollBarThickness = 4
    self.Content.ScrollingDirection = Enum.ScrollingDirection.Y
    self.Content.Parent = self.Container
    
    -- Auto layout for content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = self.Content
    
    -- Make window draggable
    self:MakeDraggable()
    
    return self
end

function Window:MakeDraggable()
    local dragging, dragInput, dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            self.Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Window:AddButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = self.Library.Theme.Primary
    button.Text = text
    button.TextColor3 = self.Library.Theme.Text
    button.Parent = self.Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Library.Config.CornerRadius
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Library.Theme.Secondary
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Library.Theme.Primary
        }):Play()
    end)
    
    return button
end

function Window:AddToggle(text, default, callback)
    local container = Instance.new("Frame")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Library.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0.5, -10)
    toggle.BackgroundColor3 = default and self.Library.Theme.Success or self.Library.Theme.Secondary
    toggle.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = self.Library.Theme.Text
    indicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = indicator
    
    local value = default or false
    
    local function updateVisual()
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = value and self.Library.Theme.Success or self.Library.Theme.Secondary
        }):Play()
    end
    
    toggle.MouseButton1Click:Connect(function()
        value = not value
        updateVisual()
        if callback then callback(value) end
    end)
    
    return toggle
end

function Window:AddSlider(text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Library.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = self.Library.Theme.Text
    valueLabel.Text = tostring(default or min)
    valueLabel.Parent = container
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, 0, 0, 6)
    sliderBG.Position = UDim2.new(0, 0, 0.7, 0)
    sliderBG.BackgroundColor3 = self.Library.Theme.Secondary
    sliderBG.Parent = container
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Library.Theme.Primary
    sliderFill.Parent = sliderBG
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = sliderBG
    
    local cornerFill = corner:Clone()
    cornerFill.Parent = sliderFill
    
    local value = default or min
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        if callback then callback(value) end
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    return container
end

function Window:AddDropdown(text, options, callback)
    local container = Instance.new("Frame")
    container.Name = "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundColor3 = self.Library.Theme.Secondary
    container.Parent = self.Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Library.Config.CornerRadius
    corner.Parent = container
    
    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(1, 0, 1, 0)
    selected.BackgroundTransparency = 1
    selected.Text = text
    selected.TextColor3 = self.Library.Theme.Text
    selected.Parent = container
    
    local optionsList = Instance.new("Frame")
    optionsList.Size = UDim2.new(1, 0, 0, 0)
    optionsList.Position = UDim2.new(0, 0, 1, 0)
    optionsList.BackgroundColor3 = self.Library.Theme.Secondary
    optionsList.Visible = false
    optionsList.ZIndex = 2
    optionsList.Parent = container
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = self.Library.Config.CornerRadius
    optionsCorner.Parent = optionsList
    
    local function refreshOptions()
        for _, child in pairs(optionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for i, option in ipairs(options) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 30)
                        button.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            button.BackgroundColor3 = self.Library.Theme.Secondary
            button.Text = option
            button.TextColor3 = self.Library.Theme.Text
            button.ZIndex = 2
            button.Parent = optionsList
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = self.Library.Config.CornerRadius
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                selected.Text = option
                optionsList.Visible = false
                if callback then callback(option) end
            end)
        end
    end
    
    selected.MouseButton1Click:Connect(function()
        optionsList.Visible = not optionsList.Visible
        if optionsList.Visible then
            optionsList.Size = UDim2.new(1, 0, 0, #options * 30)
            refreshOptions()
        end
    end)
    
    return container
end

function Window:AddTextbox(placeholder, callback)
    local container = Instance.new("Frame")
    container.Name = "Textbox"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundColor3 = self.Library.Theme.Secondary
    container.Parent = self.Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Library.Config.CornerRadius
    corner.Parent = container
    
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, -20, 1, 0)
    textbox.Position = UDim2.new(0, 10, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.TextColor3 = self.Library.Theme.Text
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = self.Library.Theme.Text:Lerp(Color3.new(0,0,0), 0.5)
    textbox.Text = ""
    textbox.Parent = container
    
    if callback then
        textbox.FocusLost:Connect(function(enterPressed)
            callback(textbox.Text, enterPressed)
        end)
    end
    
    return container
end

function Window:AddNotification(text, notificationType, duration)
    duration = duration or self.Library.Config.NotificationDuration
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, 20, 1, -70)
    notification.BackgroundColor3 = self.Library.Theme[notificationType or "Info"]
    notification.Parent = self.Library.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Library.Config.CornerRadius
    corner.Parent = notification
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = text
    text.TextColor3 = self.Library.Theme.Text
    text.TextWrapped = true
    text.Parent = notification
    
    -- Slide in
    TweenService:Create(notification, TweenInfo.new(0.5), {
        Position = UDim2.new(1, -320, 1, -70)
    }):Play()
    
    -- Auto remove
    task.delay(duration, function()
        TweenService:Create(notification, TweenInfo.new(0.5), {
            Position = UDim2.new(1, 20, 1, -70)
        }):Play()
        task.wait(0.5)
        notification:Destroy()
    end)
end

-- Main Library Constructor
function UILibrary.new()
    local self = setmetatable({}, {__index = UILibrary})
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.ResetOnSpawn = false
    
    -- Try to use CoreGui, fall back to PlayerGui if needed
    local success, result = pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return self
end

function UILibrary:CreateWindow(title)
    local window = Window.new(self, title)
    table.insert(self.Windows, window)
    return window
end

return UILibrary

