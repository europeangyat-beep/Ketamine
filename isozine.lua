local Isozine = {Windows = {}, ActiveWindow = nil, DragData = {}, InputFocus = nil}
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    obj.Parent = props.Parent
    return obj
end

local function Tween(obj, props, time)
    TS:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad), props):Play()
end

function Isozine:CreateWindow(title, size)
    local gui = Create("ScreenGui", {
        Name = "IsozineGui",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local window = Create("Frame", {
        Name = "Window",
        Parent = gui,
        Size = UDim2.new(0, size.X or 500, 0, size.Y or 400),
        Position = UDim2.new(0.5, -(size.X or 500)/2, 0.5, -(size.Y or 400)/2),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = window, CornerRadius = UDim.new(0, 6)})
    
    local header = Create("Frame", {
        Name = "Header",
        Parent = window,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = header, CornerRadius = UDim.new(0, 6)})
    
    local titleLabel = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local content = Create("ScrollingFrame", {
        Name = "Content",
        Parent = window,
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    })
    
    Create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local windowObj = {
        Gui = gui,
        Window = window,
        Content = content,
        Elements = {}
    }
    
    table.insert(self.Windows, windowObj)
    return windowObj
end

function Isozine:Button(window, text, callback)
    local btn = Create("TextButton", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
    
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}) end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 120, 220)}, 0.1)
        wait(0.1)
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1)
        if callback then callback() end
    end)
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return btn
end

function Isozine:Toggle(window, text, default, callback)
    local container = Create("Frame", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 4)})
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggle = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundColor3 = default and Color3.fromRGB(60, 120, 220) or Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = toggle, CornerRadius = UDim.new(1, 0)})
    
    local knob = Create("Frame", {
        Parent = toggle,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})
    
    local state = default or false
    local btn = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(toggle, {BackgroundColor3 = state and Color3.fromRGB(60, 120, 220) or Color3.fromRGB(60, 60, 60)})
        Tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
        if callback then callback(state) end
    end)
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return {State = state, Element = container}
end

function Isozine:Slider(window, text, min, max, default, callback)
    local container = Create("Frame", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 4)})
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text .. ": " .. tostring(default),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local sliderBg = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 1, -15),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = sliderBg, CornerRadius = UDim.new(1, 0)})
    
    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(60, 120, 220),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(1, 0)})
    
    local value = default
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RS.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation().X
            local relativePos = math.clamp((mousePos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * relativePos)
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return {Value = value, Element = container}
end

function Isozine:TextBox(window, text, placeholder, callback)
    local container = Create("Frame", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 4)})
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local box = Create("TextBox", {
        Parent = container,
        Size = UDim2.new(1, -100, 0, 24),
        Position = UDim2.new(0, 90, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = "",
        PlaceholderText = placeholder or "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = box, CornerRadius = UDim.new(0, 4)})
    
    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return {Element = container, TextBox = box}
end

function Isozine:Label(window, text)
    local label = Create("TextLabel", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 25),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return label
end

function Isozine:Separator(window)
    local sep = Create("Frame", {
        Parent = window.Content,
        Size = UDim2.new(1, -10, 0, 1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0
    })
    
    window.Content.CanvasSize = UDim2.new(0, 0, 0, window.Content.UIListLayout.AbsoluteContentSize.Y)
    return sep
end

return Isozine
