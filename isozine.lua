-- Isozine - ImGui-style Menu Library for Roblox
-- Version 1.0.0
-- Inspired by Dear ImGui by Omar Cornut

local Isozine = {}
Isozine.__index = Isozine
Isozine.Version = "1.0.0"

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local WINDOW_PADDING = 8
local FRAME_PADDING = 4
local ITEM_SPACING = 4
local ITEM_INNER_SPACING = 4
local INDENT_SPACING = 21
local SCROLLBAR_SIZE = 14
local GRAB_MIN_SIZE = 10
local WINDOW_ROUNDING = 4
local FRAME_ROUNDING = 2
local GRAB_ROUNDING = 2

-- Colors (ImGui Dark Theme)
local Colors = {
    Text = Color3.fromRGB(255, 255, 255),
    TextDisabled = Color3.fromRGB(128, 128, 128),
    WindowBg = Color3.fromRGB(15, 15, 15),
    ChildBg = Color3.fromRGB(0, 0, 0),
    PopupBg = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(110, 110, 128),
    BorderShadow = Color3.fromRGB(0, 0, 0),
    FrameBg = Color3.fromRGB(41, 74, 122),
    FrameBgHovered = Color3.fromRGB(66, 150, 250),
    FrameBgActive = Color3.fromRGB(66, 150, 250),
    TitleBg = Color3.fromRGB(10, 10, 10),
    TitleBgActive = Color3.fromRGB(41, 74, 122),
    TitleBgCollapsed = Color3.fromRGB(0, 0, 0),
    MenuBarBg = Color3.fromRGB(36, 36, 36),
    ScrollbarBg = Color3.fromRGB(5, 5, 5),
    ScrollbarGrab = Color3.fromRGB(79, 79, 79),
    ScrollbarGrabHovered = Color3.fromRGB(105, 105, 105),
    ScrollbarGrabActive = Color3.fromRGB(130, 130, 130),
    CheckMark = Color3.fromRGB(66, 150, 250),
    SliderGrab = Color3.fromRGB(66, 150, 250),
    SliderGrabActive = Color3.fromRGB(117, 138, 204),
    Button = Color3.fromRGB(66, 150, 250),
    ButtonHovered = Color3.fromRGB(66, 150, 250),
    ButtonActive = Color3.fromRGB(15, 135, 250),
    Header = Color3.fromRGB(66, 150, 250),
    HeaderHovered = Color3.fromRGB(66, 150, 250),
    HeaderActive = Color3.fromRGB(15, 135, 250),
    Separator = Color3.fromRGB(110, 110, 128),
    SeparatorHovered = Color3.fromRGB(26, 102, 191),
    SeparatorActive = Color3.fromRGB(10, 102, 191),
    ResizeGrip = Color3.fromRGB(66, 150, 250),
    ResizeGripHovered = Color3.fromRGB(66, 150, 250),
    ResizeGripActive = Color3.fromRGB(15, 135, 250),
    Tab = Color3.fromRGB(46, 89, 148),
    TabHovered = Color3.fromRGB(66, 150, 250),
    TabActive = Color3.fromRGB(51, 105, 173),
    TabUnfocused = Color3.fromRGB(18, 35, 58),
    TabUnfocusedActive = Color3.fromRGB(36, 66, 107),
}

-- State Management
local State = {
    Windows = {},
    ActiveWindow = nil,
    HoveredWindow = nil,
    FocusedWindow = nil,
    DraggedWindow = nil,
    CurrentWindow = nil,
    MousePos = Vector2.new(0, 0),
    MouseDelta = Vector2.new(0, 0),
    MouseDown = {},
    KeysDown = {},
    FrameCount = 0,
    DeltaTime = 0,
    IDStack = {},
    CurrentID = 0,
}

-- Helper Functions
local function CreateUID()
    State.CurrentID = State.CurrentID + 1
    return "ID_" .. State.CurrentID
end

local function PushID(id)
    table.insert(State.IDStack, id)
end

local function PopID()
    table.remove(State.IDStack)
end

local function GetID(label)
    local id = label or CreateUID()
    for _, stackID in ipairs(State.IDStack) do
        id = stackID .. "_" .. id
    end
    return id
end

local function IsMouseHoveringRect(pos, size)
    local mp = State.MousePos
    return mp.X >= pos.X and mp.X <= pos.X + size.X and
           mp.Y >= pos.Y and mp.Y <= pos.Y + size.Y
end

local function CreateFrame(parent, name, props)
    local frame = Instance.new("Frame")
    frame.Name = name or "Frame"
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    for k, v in pairs(props or {}) do
        frame[k] = v
    end
    
    return frame
end

local function CreateTextLabel(parent, text, props)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = text or ""
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    for k, v in pairs(props or {}) do
        label[k] = v
    end
    
    return label
end

local function CreateTextButton(parent, text, props)
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Text = text or ""
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextColor3 = Colors.Text
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    for k, v in pairs(props or {}) do
        btn[k] = v
    end
    
    return btn
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title, config)
    local self = setmetatable({}, Window)
    
    self.Title = title or "Window"
    self.ID = GetID(title)
    self.Pos = config.Pos or Vector2.new(100, 100)
    self.Size = config.Size or Vector2.new(400, 300)
    self.MinSize = config.MinSize or Vector2.new(200, 100)
    self.Collapsed = false
    self.Open = true
    self.Focused = false
    self.Flags = config.Flags or {}
    
    self.ContentOffset = Vector2.new(0, 0)
    self.ContentSize = Vector2.new(0, 0)
    self.ScrollY = 0
    self.ScrollMaxY = 0
    
    self.CursorPos = Vector2.new(WINDOW_PADDING, WINDOW_PADDING + 20)
    self.CursorStartPos = self.CursorPos
    
    self:CreateGUI()
    
    State.Windows[self.ID] = self
    
    return self
end

function Window:CreateGUI()
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "IsozineWindow_" .. self.Title
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    -- Main window frame
    self.Frame = CreateFrame(self.ScreenGui, "WindowFrame", {
        Position = UDim2.new(0, self.Pos.X, 0, self.Pos.Y),
        Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
        BackgroundColor3 = Colors.WindowBg,
        ClipsDescendants = true,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, WINDOW_ROUNDING)
    corner.Parent = self.Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = self.Frame
    
    -- Title bar
    self.TitleBar = CreateFrame(self.Frame, "TitleBar", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Colors.TitleBg,
    })
    
    self.TitleLabel = CreateTextLabel(self.TitleBar, self.Title, {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Close button
    self.CloseButton = CreateTextButton(self.TitleBar, "X", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = Colors.TitleBg,
        TextColor3 = Colors.Text,
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.Open = false
        self.ScreenGui:Destroy()
    end)
    
    -- Content container
    self.ContentFrame = CreateFrame(self.Frame, "Content", {
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 1, -20),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })
    
    -- Scrolling frame
    self.ScrollFrame = CreateFrame(self.ContentFrame, "ScrollContent", {
        Size = UDim2.new(1, -SCROLLBAR_SIZE, 1, 0),
        BackgroundTransparency = 1,
    })
    
    -- Scrollbar
    self.ScrollbarBg = CreateFrame(self.ContentFrame, "ScrollbarBg", {
        Position = UDim2.new(1, -SCROLLBAR_SIZE, 0, 0),
        Size = UDim2.new(0, SCROLLBAR_SIZE, 1, 0),
        BackgroundColor3 = Colors.ScrollbarBg,
    })
    
    self.ScrollbarGrab = CreateFrame(self.ScrollbarBg, "ScrollbarGrab", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.ScrollbarGrab,
    })
    
    local grabCorner = Instance.new("UICorner")
    grabCorner.CornerRadius = UDim.new(0, GRAB_ROUNDING)
    grabCorner.Parent = self.ScrollbarGrab
    
    -- Resize grip
    if not self.Flags.NoResize then
        self.ResizeGrip = CreateFrame(self.Frame, "ResizeGrip", {
            Position = UDim2.new(1, -15, 1, -15),
            Size = UDim2.new(0, 15, 0, 15),
            BackgroundColor3 = Colors.ResizeGrip,
            BackgroundTransparency = 0.5,
        })
    end
    
    self:SetupEvents()
end

function Window:SetupEvents()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    -- Title bar dragging
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
            State.DraggedWindow = self
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            State.DraggedWindow = nil
        end
    end)
    
    -- Resize grip
    if self.ResizeGrip then
        self.ResizeGrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                resizeStart = input.Position
                startSize = self.Frame.Size
            end
        end)
        
        self.ResizeGrip.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end
    
    -- Mouse movement
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging and dragStart then
                local delta = input.Position - dragStart
                self.Frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
            
            if resizing and resizeStart then
                local delta = input.Position - resizeStart
                local newWidth = math.max(self.MinSize.X, startSize.X.Offset + delta.X)
                local newHeight = math.max(self.MinSize.Y, startSize.Y.Offset + delta.Y)
                self.Frame.Size = UDim2.new(0, newWidth, 0, newHeight)
                self.Size = Vector2.new(newWidth, newHeight)
            end
        end
    end)
    
    -- Focus management
    self.Frame.InputBegan:Connect(function()
        State.FocusedWindow = self
        self.Focused = true
    end)
end

function Window:Begin()
    if not self.Open then return false end
    
    State.CurrentWindow = self
    self.CursorPos = Vector2.new(WINDOW_PADDING, WINDOW_PADDING)
    
    -- Clear previous frame content
    for _, child in ipairs(self.ScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    PushID(self.ID)
    
    return true
end

function Window:End()
    PopID()
    
    -- Update scrollbar
    local contentHeight = self.CursorPos.Y + WINDOW_PADDING
    self.ContentSize = Vector2.new(self.Size.X, contentHeight)
    self.ScrollMaxY = math.max(0, contentHeight - (self.Size.Y - 20))
    
    if self.ScrollMaxY > 0 then
        self.ScrollbarBg.Visible = true
        local grabHeight = math.max(GRAB_MIN_SIZE, (self.Size.Y - 20) * ((self.Size.Y - 20) / contentHeight))
        local grabPos = (self.ScrollY / self.ScrollMaxY) * ((self.Size.Y - 20) - grabHeight)
        self.ScrollbarGrab.Size = UDim2.new(1, 0, 0, grabHeight)
        self.ScrollbarGrab.Position = UDim2.new(0, 0, 0, grabPos)
    else
        self.ScrollbarBg.Visible = false
    end
    
    State.CurrentWindow = nil
end

function Window:AdvanceCursor(height)
    self.CursorPos = Vector2.new(self.CursorPos.X, self.CursorPos.Y + height + ITEM_SPACING)
end

-- Widget Functions
function Isozine.Begin(title, open, flags)
    local config = {
        Pos = Vector2.new(100, 100),
        Size = Vector2.new(400, 300),
        Flags = flags or {}
    }
    
    local window = Window.new(title, config)
    return window:Begin()
end

function Isozine.End()
    if State.CurrentWindow then
        State.CurrentWindow:End()
    end
end

function Isozine.Text(text)
    local window = State.CurrentWindow
    if not window then return end
    
    local label = CreateTextLabel(window.ScrollFrame, text, {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
    })
    
    window:AdvanceCursor(20)
end

function Isozine.Button(label, size)
    local window = State.CurrentWindow
    if not window then return false end
    
    size = size or Vector2.new(120, 25)
    
    local btn = CreateTextButton(window.ScrollFrame, label, {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(0, size.X, 0, size.Y),
        BackgroundColor3 = Colors.Button,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = btn
    
    local clicked = false
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Colors.ButtonHovered
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Colors.Button
    end)
    
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = Colors.ButtonActive
    end)
    
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = Colors.ButtonHovered
    end)
    
    btn.MouseButton1Click:Connect(function()
        clicked = true
    end)
    
    window:AdvanceCursor(size.Y)
    
    return clicked
end

function Isozine.Checkbox(label, checked)
    local window = State.CurrentWindow
    if not window then return checked end
    
    local id = GetID(label)
    local newChecked = checked
    
    local container = CreateFrame(window.ScrollFrame, "CheckboxContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local checkboxBg = CreateFrame(container, "CheckboxBg", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Colors.FrameBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = checkboxBg
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = checkboxBg
    
    if checked then
        local checkmark = CreateTextLabel(checkboxBg, "✓", {
            Size = UDim2.new(1, 0, 1, 0),
            TextColor3 = Colors.CheckMark,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    end
    
    local labelText = CreateTextLabel(container, label, {
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -22, 1, 0),
    })
    
    local btn = CreateTextButton(container, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseButton1Click:Connect(function()
        newChecked = not newChecked
    end)
    
    window:AdvanceCursor(20)
    
    return newChecked
end

function Isozine.SliderFloat(label, value, min, max, format)
    local window = State.CurrentWindow
    if not window then return value end
    
    format = format or "%.3f"
    local id = GetID(label)
    local newValue = value
    
    local container = CreateFrame(window.ScrollFrame, "SliderContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local labelText = CreateTextLabel(container, label, {
        Size = UDim2.new(0.4, 0, 1, 0),
    })
    
    local sliderBg = CreateFrame(container, "SliderBg", {
        Position = UDim2.new(0.4, 5, 0, 2),
        Size = UDim2.new(0.6, -5, 0, 16),
        BackgroundColor3 = Colors.FrameBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = sliderBg
    
    local ratio = (value - min) / (max - min)
    local grabPos = ratio * (sliderBg.AbsoluteSize.X - 10)
    
    local grab = CreateFrame(sliderBg, "SliderGrab", {
        Position = UDim2.new(0, grabPos, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = Colors.SliderGrab,
    })
    
    local grabCorner = Instance.new("UICorner")
    grabCorner.CornerRadius = UDim.new(0, GRAB_ROUNDING)
    grabCorner.Parent = grab
    
    local valueLabel = CreateTextLabel(sliderBg, string.format(format, value), {
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 12,
    })
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = sliderBg.AbsolutePosition.X
            local sliderWidth = sliderBg.AbsoluteSize.X
            local relativeX = math.clamp(mouseX - sliderX, 0, sliderWidth)
            local ratio = relativeX / sliderWidth
            newValue = min + (max - min) * ratio
        end
    end)
    
    window:AdvanceCursor(20)
    
    return newValue
end

function Isozine.InputText(label, text, flags)
    local window = State.CurrentWindow
    if not window then return text end
    
    flags = flags or {}
    local id = GetID(label)
    
    local container = CreateFrame(window.ScrollFrame, "InputContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local labelText = CreateTextLabel(container, label, {
        Size = UDim2.new(0.3, 0, 1, 0),
    })
    
    local inputBg = CreateFrame(container, "InputBg", {
        Position = UDim2.new(0.3, 5, 0, 0),
        Size = UDim2.new(0.7, -5, 1, 0),
        BackgroundColor3 = Colors.FrameBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = inputBg
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -8, 1, 0)
    textBox.Position = UDim2.new(0, 4, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 14
    textBox.TextColor3 = Colors.Text
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Text = text
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputBg
    
    if flags.Password then
        textBox.TextTransparency = 0.5
    end
    
    window:AdvanceCursor(20)
    
    return textBox.Text
end

function Isozine.Separator()
    local window = State.CurrentWindow
    if not window then return end
    
    local separator = CreateFrame(window.ScrollFrame, "Separator", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY + 5),
        Size = UDim2.new(1, -window.CursorPos.X * 2, 0, 1),
        BackgroundColor3 = Colors.Separator,
    })
    
    window:AdvanceCursor(11)
end

function Isozine.Spacing()
    local window = State.CurrentWindow
    if not window then return end
    
    window:AdvanceCursor(ITEM_SPACING)
end

function Isozine.SameLine()
    local window = State.CurrentWindow
    if not window then return end
    
    window.CursorPos = Vector2.new(window.CursorPos.X + 150, window.CursorPos.Y - ITEM_SPACING - 20)
end

function Isozine.NewLine()
    local window = State.CurrentWindow
    if not window then return end
    
    window.CursorPos = Vector2.new(WINDOW_PADDING, window.CursorPos.Y)
end

function Isozine.BeginChild(label, size, border)
    local window = State.CurrentWindow
    if not window then return false end
    
    size = size or Vector2.new(0, 100)
    border = border or false
    
    local child = CreateFrame(window.ScrollFrame, "Child_" .. label, {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(size.X == 0 and 1 or 0, size.X == 0 and -(window.CursorPos.X + WINDOW_PADDING) or size.X, 0, size.Y),
        BackgroundColor3 = Colors.ChildBg,
        BackgroundTransparency = border and 0 or 1,
    })
    
    if border then
        local stroke = Instance.new("UIStroke")
        stroke.Color = Colors.Border
        stroke.Thickness = 1
        stroke.Parent = child
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
        corner.Parent = child
    end
    
    -- Store old window state
    window.ChildStack = window.ChildStack or {}
    table.insert(window.ChildStack, {
        CursorPos = window.CursorPos,
        ScrollFrame = window.ScrollFrame,
    })
    
    -- Set new scroll frame to child
    window.ScrollFrame = child
    window.CursorPos = Vector2.new(FRAME_PADDING, FRAME_PADDING)
    
    window:AdvanceCursor(size.Y)
    
    return true
end

function Isozine.EndChild()
    local window = State.CurrentWindow
    if not window or not window.ChildStack or #window.ChildStack == 0 then return end
    
    local oldState = table.remove(window.ChildStack)
    window.ScrollFrame = oldState.ScrollFrame
    window.CursorPos = oldState.CursorPos
end

function Isozine.CollapsingHeader(label, flags)
    local window = State.CurrentWindow
    if not window then return false end
    
    local id = GetID(label)
    window.HeaderStates = window.HeaderStates or {}
    
    if window.HeaderStates[id] == nil then
        window.HeaderStates[id] = true
    end
    
    local container = CreateFrame(window.ScrollFrame, "HeaderContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 22),
        BackgroundColor3 = Colors.Header,
        BackgroundTransparency = 0.6,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = container
    
    local arrow = CreateTextLabel(container, window.HeaderStates[id] and "▼" or "▶", {
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(0, 15, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    
    local headerLabel = CreateTextLabel(container, label, {
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -22, 1, 0),
    })
    
    local btn = CreateTextButton(container, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseEnter:Connect(function()
        container.BackgroundTransparency = 0.4
    end)
    
    btn.MouseLeave:Connect(function()
        container.BackgroundTransparency = 0.6
    end)
    
    btn.MouseButton1Click:Connect(function()
        window.HeaderStates[id] = not window.HeaderStates[id]
    end)
    
    window:AdvanceCursor(22)
    
    return window.HeaderStates[id]
end

function Isozine.TreeNode(label, flags)
    local window = State.CurrentWindow
    if not window then return false end
    
    local id = GetID(label)
    window.TreeStates = window.TreeStates or {}
    
    if window.TreeStates[id] == nil then
        window.TreeStates[id] = false
    end
    
    local container = CreateFrame(window.ScrollFrame, "TreeContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local arrow = CreateTextLabel(container, window.TreeStates[id] and "▼" or "▶", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 15, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 12,
    })
    
    local treeLabel = CreateTextLabel(container, label, {
        Position = UDim2.new(0, 17, 0, 0),
        Size = UDim2.new(1, -17, 1, 0),
    })
    
    local btn = CreateTextButton(container, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseButton1Click:Connect(function()
        window.TreeStates[id] = not window.TreeStates[id]
    end)
    
    window:AdvanceCursor(20)
    
    if window.TreeStates[id] then
        window.CursorPos = Vector2.new(window.CursorPos.X + INDENT_SPACING, window.CursorPos.Y)
    end
    
    return window.TreeStates[id]
end

function Isozine.TreePop()
    local window = State.CurrentWindow
    if not window then return end
    
    window.CursorPos = Vector2.new(math.max(WINDOW_PADDING, window.CursorPos.X - INDENT_SPACING), window.CursorPos.Y)
end

function Isozine.Selectable(label, selected, flags, size)
    local window = State.CurrentWindow
    if not window then return selected, false end
    
    size = size or Vector2.new(0, 20)
    local clicked = false
    local newSelected = selected
    
    local container = CreateFrame(window.ScrollFrame, "SelectableContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(size.X == 0 and 1 or 0, size.X == 0 and -(window.CursorPos.X + WINDOW_PADDING) or size.X, 0, size.Y),
        BackgroundColor3 = selected and Colors.Header or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = selected and 0.4 or 1,
    })
    
    local selectLabel = CreateTextLabel(container, label, {
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -5, 1, 0),
    })
    
    local btn = CreateTextButton(container, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseEnter:Connect(function()
        if not selected then
            container.BackgroundTransparency = 0.8
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not selected then
            container.BackgroundTransparency = 1
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        newSelected = not newSelected
        clicked = true
    end)
    
    window:AdvanceCursor(size.Y)
    
    return newSelected, clicked
end

function Isozine.BeginCombo(label, previewValue, flags)
    local window = State.CurrentWindow
    if not window then return false end
    
    local id = GetID(label)
    window.ComboStates = window.ComboStates or {}
    
    if window.ComboStates[id] == nil then
        window.ComboStates[id] = false
    end
    
    local container = CreateFrame(window.ScrollFrame, "ComboContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local comboLabel = CreateTextLabel(container, label, {
        Size = UDim2.new(0.3, 0, 1, 0),
    })
    
    local comboBg = CreateFrame(container, "ComboBg", {
        Position = UDim2.new(0.3, 5, 0, 0),
        Size = UDim2.new(0.7, -5, 1, 0),
        BackgroundColor3 = Colors.FrameBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = comboBg
    
    local previewLabel = CreateTextLabel(comboBg, previewValue or "", {
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
    })
    
    local arrowLabel = CreateTextLabel(comboBg, "▼", {
        Position = UDim2.new(1, -15, 0, 0),
        Size = UDim2.new(0, 15, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 10,
    })
    
    local btn = CreateTextButton(comboBg, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseButton1Click:Connect(function()
        window.ComboStates[id] = not window.ComboStates[id]
    end)
    
    window:AdvanceCursor(20)
    
    if window.ComboStates[id] then
        local popup = CreateFrame(window.ScrollFrame, "ComboPopup", {
            Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
            Size = UDim2.new(0.7, -5, 0, 100),
            BackgroundColor3 = Colors.PopupBg,
            ZIndex = 100,
        })
        
        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
        popupCorner.Parent = popup
        
        local popupStroke = Instance.new("UIStroke")
        popupStroke.Color = Colors.Border
        popupStroke.Thickness = 1
        popupStroke.Parent = popup
        
        window.ComboPopup = popup
        window.ComboPopupCursor = Vector2.new(FRAME_PADDING, FRAME_PADDING)
        
        window:AdvanceCursor(100)
    end
    
    return window.ComboStates[id]
end

function Isozine.EndCombo()
    local window = State.CurrentWindow
    if not window or not window.ComboPopup then return end
    
    window.ComboPopup = nil
    window.ComboPopupCursor = nil
end

function Isozine.ComboItem(label, selected)
    local window = State.CurrentWindow
    if not window or not window.ComboPopup then return false end
    
    local clicked = false
    
    local item = CreateFrame(window.ComboPopup, "ComboItem", {
        Position = UDim2.new(0, 0, 0, window.ComboPopupCursor.Y),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = selected and Colors.Header or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = selected and 0.4 or 1,
    })
    
    local itemLabel = CreateTextLabel(item, label, {
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -5, 1, 0),
    })
    
    local btn = CreateTextButton(item, "", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    btn.MouseEnter:Connect(function()
        item.BackgroundColor3 = Colors.HeaderHovered
        item.BackgroundTransparency = 0.4
    end)
    
    btn.MouseLeave:Connect(function()
        if selected then
            item.BackgroundColor3 = Colors.Header
        else
            item.BackgroundTransparency = 1
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        clicked = true
    end)
    
    window.ComboPopupCursor = Vector2.new(0, window.ComboPopupCursor.Y + 20)
    
    return clicked
end

function Isozine.BeginTabBar(label, flags)
    local window = State.CurrentWindow
    if not window then return false end
    
    local id = GetID(label)
    window.TabBarStates = window.TabBarStates or {}
    window.TabBarStates[id] = window.TabBarStates[id] or {
        SelectedTab = nil,
        Tabs = {}
    }
    
    local tabBar = CreateFrame(window.ScrollFrame, "TabBar_" .. label, {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 25),
        BackgroundColor3 = Colors.MenuBarBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = tabBar
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 2)
    layout.Parent = tabBar
    
    window.CurrentTabBar = {
        ID = id,
        Frame = tabBar,
        State = window.TabBarStates[id]
    }
    
    window:AdvanceCursor(25)
    
    return true
end

function Isozine.EndTabBar()
    local window = State.CurrentWindow
    if not window or not window.CurrentTabBar then return end
    
    window.CurrentTabBar = nil
end

function Isozine.BeginTabItem(label, open, flags)
    local window = State.CurrentWindow
    if not window or not window.CurrentTabBar then return false end
    
    local tabBar = window.CurrentTabBar
    local state = tabBar.State
    
    if not state.SelectedTab then
        state.SelectedTab = label
    end
    
    local isSelected = state.SelectedTab == label
    
    local tab = CreateTextButton(tabBar.Frame, label, {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = isSelected and Colors.TabActive or Colors.Tab,
        TextColor3 = Colors.Text,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = tab
    
    tab.MouseEnter:Connect(function()
        if not isSelected then
            tab.BackgroundColor3 = Colors.TabHovered
        end
    end)
    
    tab.MouseLeave:Connect(function()
        if not isSelected then
            tab.BackgroundColor3 = Colors.Tab
        end
    end)
    
    tab.MouseButton1Click:Connect(function()
        state.SelectedTab = label
    end)
    
    return isSelected
end

function Isozine.EndTabItem()
    -- Nothing needed here
end

function Isozine.ColorEdit3(label, color)
    local window = State.CurrentWindow
    if not window then return color end
    
    local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
    
    local container = CreateFrame(window.ScrollFrame, "ColorEditContainer", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(1, -window.CursorPos.X - WINDOW_PADDING, 0, 20),
        BackgroundTransparency = 1,
    })
    
    local colorLabel = CreateTextLabel(container, label, {
        Size = UDim2.new(0.3, 0, 1, 0),
    })
    
    local colorPreview = CreateFrame(container, "ColorPreview", {
        Position = UDim2.new(0.3, 5, 0, 2),
        Size = UDim2.new(0, 40, 0, 16),
        BackgroundColor3 = color,
    })
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    previewCorner.Parent = colorPreview
    
    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Colors.Border
    previewStroke.Thickness = 1
    previewStroke.Parent = colorPreview
    
    local valueLabel = CreateTextLabel(container, string.format("#%02X%02X%02X", r, g, b), {
        Position = UDim2.new(0.3, 50, 0, 0),
        Size = UDim2.new(0.7, -50, 1, 0),
        TextSize = 12,
    })
    
    window:AdvanceCursor(20)
    
    return color
end

function Isozine.ProgressBar(fraction, size, overlay)
    local window = State.CurrentWindow
    if not window then return end
    
    size = size or Vector2.new(0, 20)
    fraction = math.clamp(fraction, 0, 1)
    
    local container = CreateFrame(window.ScrollFrame, "ProgressBar", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(size.X == 0 and 1 or 0, size.X == 0 and -(window.CursorPos.X + WINDOW_PADDING) or size.X, 0, size.Y),
        BackgroundColor3 = Colors.FrameBg,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = container
    
    local fill = CreateFrame(container, "ProgressFill", {
        Size = UDim2.new(fraction, 0, 1, 0),
        BackgroundColor3 = Colors.Button,
    })
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    fillCorner.Parent = fill
    
    if overlay then
        local overlayLabel = CreateTextLabel(container, overlay, {
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 2,
        })
    end
    
    window:AdvanceCursor(size.Y)
end

function Isozine.Bullet()
    local window = State.CurrentWindow
    if not window then return end
    
    local bullet = CreateTextLabel(window.ScrollFrame, "•", {
        Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY),
        Size = UDim2.new(0, 15, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    
    window.CursorPos = Vector2.new(window.CursorPos.X + 15, window.CursorPos.Y)
end

function Isozine.BulletText(text)
    Isozine.Bullet()
    Isozine.Text(text)
end

function Isozine.Image(imageId, size)
    local window = State.CurrentWindow
    if not window then return end
    
    size = size or Vector2.new(100, 100)
    
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Position = UDim2.new(0, window.CursorPos.X, 0, window.CursorPos.Y - window.ScrollY)
    image.Size = UDim2.new(0, size.X, 0, size.Y)
    image.BackgroundTransparency = 1
    image.Image = imageId
    image.Parent = window.ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = image
    
    window:AdvanceCursor(size.Y)
end

function Isozine.BeginTooltip()
    local window = State.CurrentWindow
    if not window then return false end
    
    local tooltip = Instance.new("ScreenGui")
    tooltip.Name = "Tooltip"
    tooltip.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    tooltip.Parent = CoreGui
    
    local tooltipFrame = CreateFrame(tooltip, "TooltipFrame", {
        Position = UDim2.new(0, State.MousePos.X + 10, 0, State.MousePos.Y + 10),
        Size = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = Colors.PopupBg,
        ZIndex = 1000,
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, FRAME_ROUNDING)
    corner.Parent = tooltipFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = tooltipFrame
    
    window.CurrentTooltip = {
        ScreenGui = tooltip,
        Frame = tooltipFrame,
        CursorY = FRAME_PADDING
    }
    
    return true
end

function Isozine.EndTooltip()
    local window = State.CurrentWindow
    if not window or not window.CurrentTooltip then return end
    
    window.CurrentTooltip = nil
end

function Isozine.SetTooltip(text)
    if Isozine.BeginTooltip() then
        Isozine.Text(text)
        Isozine.EndTooltip()
    end
end

function Isozine.IsItemHovered()
    -- Simplified version - would need proper rect tracking
    return false
end

function Isozine.GetMousePos()
    return State.MousePos
end

function Isozine.IsMouseDown(button)
    return State.MouseDown[button] or false
end

function Isozine.GetFrameCount()
    return State.FrameCount
end

function Isozine.GetTime()
    return tick()
end

function Isozine.SetNextWindowPos(pos, cond)
    State.NextWindowPos = pos
    State.NextWindowPosCond = cond
end

function Isozine.SetNextWindowSize(size, cond)
    State.NextWindowSize = size
    State.NextWindowSizeCond = cond
end

function Isozine.PushStyleColor(idx, color)
    State.StyleColorStack = State.StyleColorStack or {}
    table.insert(State.StyleColorStack, {idx = idx, color = Colors[idx]})
    Colors[idx] = color
end

function Isozine.PopStyleColor(count)
    count = count or 1
    State.StyleColorStack = State.StyleColorStack or {}
    
    for i = 1, count do
        if #State.StyleColorStack > 0 then
            local item = table.remove(State.StyleColorStack)
            Colors[item.idx] = item.color
        end
    end
end

-- Initialize input tracking
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local oldPos = State.MousePos
        State.MousePos = Vector2.new(input.Position.X, input.Position.Y)
        State.MouseDelta = State.MousePos - oldPos
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.MouseDown[0] = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.MouseDown[1] = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        State.MouseDown[2] = true
    end
    
    if input.KeyCode then
        State.KeysDown[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.MouseDown[0] = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.MouseDown[1] = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        State.MouseDown[2] = false
    end
    
    if input.KeyCode then
        State.KeysDown[input.KeyCode] = false
    end
end)

-- Frame update
RunService.RenderStepped:Connect(function(dt)
    State.DeltaTime = dt
    State.FrameCount = State.FrameCount + 1
end)

-- Return the library
return Isozine
