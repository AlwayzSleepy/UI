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
        ElementPadding = 5,
        ScrollBarThickness = 4,
    }
}

-- Utility functions
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = parent
    return corner
end

-- Enhanced Window Component
local Window = {}
Window.__index = Window

function Window.new(library, title)
    local self = setmetatable({}, Window)
    self.Library = library
    self.Elements = {}
    
    -- Main container setup
    self.Container = CreateElement("Frame", {
        Name = "Window",
        Size = library.Config.DefaultSize,
        Position = UDim2.new(0.5, -library.Config.DefaultSize.X.Offset/2, 0.5, -library.Config.DefaultSize.Y.Offset/2),
        BackgroundColor3 = library.Theme.Background,
        Parent = library.ScreenGui,
        ClipsDescendants = true
    })
    
    AddCorner(self.Container, library.Config.CornerRadius)
    
    -- Title bar with improved styling
    self.TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = library.Theme.Secondary,
        Parent = self.Container
    })
    
    AddCorner(self.TitleBar, library.Config.CornerRadius)
    
    -- Enhanced title label
    self.Title = CreateElement("TextLabel", {
        Name = "Title",
        Text = title or library.Config.DefaultTitle,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Parent = self.TitleBar
    })
    
    -- Improved close button
    self.CloseButton = CreateElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = library.Theme.Text,
        TextSize = 20,
        Font = Enum.Font.SourceSansBold,
        Parent = self.TitleBar
    })
    
    -- Enhanced content container
    self.Content = CreateElement("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = library.Config.ScrollBarThickness,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BorderSizePixel = 0,
        Parent = self.Container
    })
    
    -- Auto-sizing layout
    local layout = CreateElement("UIListLayout", {
        Padding = UDim.new(0, library.Config.ElementPadding),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Content
    })
    
    -- Auto-update content size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    -- Setup window behaviors
    self:MakeDraggable()
    self:SetupCloseButton()
    
    return self
end
-- Window methods
function Window:SetupCloseButton()
    local closeHover = false
    
    self.CloseButton.MouseEnter:Connect(function()
        closeHover = true
        TweenService:Create(self.CloseButton, TweenInfo.new(0.2), {
            TextColor3 = self.Library.Theme.Error
        }):Play()
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        closeHover = false
        TweenService:Create(self.CloseButton, TweenInfo.new(0.2), {
            TextColor3 = self.Library.Theme.Text
        }):Play()
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
end

function Window:Close()
    TweenService:Create(self.Container, TweenInfo.new(0.3), {
        Size = UDim2.new(0, self.Container.Size.X.Offset, 0, 0),
        Position = UDim2.new(
            self.Container.Position.X.Scale,
            self.Container.Position.X.Offset,
            self.Container.Position.Y.Scale,
            self.Container.Position.Y.Offset + (self.Container.Size.Y.Offset/2)
        )
    }):Play()
    wait(0.3)
    self.Container:Destroy()
end

function Window:MakeDraggable()
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.Container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

function Window:AddButton(text, callback)
    local button = CreateElement("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.Library.Theme.Primary,
        Text = text,
        TextColor3 = self.Library.Theme.Text,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 14,
        Parent = self.Content
    })
    
    AddCorner(button, self.Library.Config.CornerRadius)
    
    -- Hover and click effects
    local buttonHover = false
    
    button.MouseEnter:Connect(function()
        buttonHover = true
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Library.Theme.Secondary
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        buttonHover = false
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Library.Theme.Primary
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0.98, 0, 0, 30)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 0, 32)
        }):Play()
        
        if callback then callback() end
    end)
    
    return button
end

function Window:AddToggle(text, default, callback)
    local container = CreateElement("Frame", {
        Name = "Toggle",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = self.Content
    })
    
    local label = CreateElement("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 14,
        Parent = container
    })
    
    local toggleButton = CreateElement("TextButton", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = default and self.Library.Theme.Success or self.Library.Theme.Secondary,
        Text = "",
        Parent = container
    })
    
    AddCorner(toggleButton, UDim.new(0, 10))
    
    local indicator = CreateElement("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = self.Library.Theme.Text,
        Parent = toggleButton
    })
    
    AddCorner(indicator, UDim.new(0, 8))
    
    local value = default or false
    
    local function updateToggle()
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = value and self.Library.Theme.Success or self.Library.Theme.Secondary
        }):Play()
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        updateToggle()
        if callback then callback(value) end
    end)
    
    return {
        Container = container,
        Value = function() return value end,
        Set = function(newValue)
            value = newValue
            updateToggle()
            if callback then callback(value) end
        end
    }
end

function Window:AddSlider(text, min, max, default, callback)
    local container = CreateElement("Frame", {
        Name = "Slider",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Content
    })
    
    local label = CreateElement("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -50, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = self.Library.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 14,
        Parent = container
    })
    
    local valueLabel = CreateElement("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Library.Theme.Text,
        Text = tostring(default or min),
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 14,
        Parent = container
    })
    
    local sliderBG = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.7, 0),
        BackgroundColor3 = self.Library.Theme.Secondary,
        Parent = container
    })
    
    AddCorner(sliderBG, UDim.new(0, 3))
    
    local sliderFill = CreateElement("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Library.Theme.Primary,
        Parent = sliderBG
    })
    
    AddCorner(sliderFill, UDim.new(0, 3))
    
    local value = default or min
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        if callback then callback(value) end
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return {
        Container = container,
        Value = function() return value end,
        Set = function(newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    }
end

-- Main Library Constructor
function UILibrary.new()
    local self = setmetatable({}, {__index = UILibrary})
    
    self.ScreenGui = CreateElement("ScreenGui", {
        Name = "UILibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Try to use CoreGui, fall back to PlayerGui
    pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not self.ScreenGui.Parent then
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


