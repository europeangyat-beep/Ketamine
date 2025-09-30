local Isozine = {Version = "2.1", Windows = {}, State = {}}
local S = Isozine.State

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local C = {
    Text = Color3.fromRGB(255,255,255),
    WindowBg = Color3.fromRGB(15,15,15),
    Border = Color3.fromRGB(110,110,128),
    TitleBg = Color3.fromRGB(10,10,10),
    TitleBgActive = Color3.fromRGB(41,74,122),
    FrameBg = Color3.fromRGB(41,74,122),
    FrameBgHovered = Color3.fromRGB(66,150,250),
    FrameBgActive = Color3.fromRGB(15,135,250),
    Button = Color3.fromRGB(66,150,250),
    ButtonHovered = Color3.fromRGB(66,150,250),
    ButtonActive = Color3.fromRGB(15,135,250),
    Header = Color3.fromRGB(66,150,250),
    CheckMark = Color3.fromRGB(66,150,250),
    Tab = Color3.fromRGB(46,89,148),
    TabActive = Color3.fromRGB(51,105,173),
    TabHovered = Color3.fromRGB(66,150,250)
}

local function New(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

local Window = {}
Window.__index = Window

function Window.new(title)
    if Isozine.Windows[title] then
        S.CW = Isozine.Windows[title]
        return S.CW
    end
    
    local w = setmetatable({
        Title = title,
        Open = true,
        Y = 8,
        States = {},
        DragConnection = nil,
        InputConnection = nil
    }, Window)
    
    w.Gui = New("ScreenGui", {
        Name = "Isozine_"..title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CG
    })
    
    w.Main = New("Frame", {
        Parent = w.Gui,
        Position = UDim2.new(0, 100, 0, 100),
        Size = UDim2.new(0, 400, 0, 300),
        BackgroundColor3 = C.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    New("UICorner", {CornerRadius = UDim.new(0,4), Parent = w.Main})
    New("UIStroke", {Color = C.Border, Thickness = 1, Parent = w.Main})
    
    w.TitleBar = New("Frame", {
        Parent = w.Main,
        Size = UDim2.new(1,0,0,24),
        BackgroundColor3 = C.TitleBg,
        BorderSizePixel = 0
    })
    
    w.TitleText = New("TextLabel", {
        Parent = w.TitleBar,
        Size = UDim2.new(1,-25,1,0),
        Position = UDim2.new(0,6,0,0),
        Text = title,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    
    local close = New("TextButton", {
        Parent = w.TitleBar,
        Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(1,-22,0,2),
        Text = "×",
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextColor3 = C.Text,
        BackgroundColor3 = C.TitleBg,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    close.MouseButton1Click:Connect(function()
        w:Destroy()
    end)
    
    w.Content = New("ScrollingFrame", {
        Parent = w.Main,
        Position = UDim2.new(0,0,0,24),
        Size = UDim2.new(1,-8,1,-24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Color3.fromRGB(79,79,79),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        w.Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    w.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = w.Main.Position
            
            if w.DragConnection then
                w.DragConnection:Disconnect()
            end
            
            w.DragConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if w.DragConnection then
                        w.DragConnection:Disconnect()
                        w.DragConnection = nil
                    end
                end
            end)
        end
    end)
    
    if w.InputConnection then
        w.InputConnection:Disconnect()
    end
    
    w.InputConnection = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    Isozine.Windows[title] = w
    S.CW = w
    return w
end

function Window:Destroy()
    self.Open = false
    if self.DragConnection then
        self.DragConnection:Disconnect()
    end
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    if self.Gui then
        self.Gui:Destroy()
    end
    Isozine.Windows[self.Title] = nil
    S.CW = nil
end

function Window:Begin()
    if not self.Open or not self.Gui or not self.Gui.Parent then
        return false
    end
    S.CW = self
    self.Y = 8
    
    for _,v in ipairs(self.Content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
    return true
end

function Window:End()
    self.Content.CanvasSize = UDim2.new(0,0,0,self.Y+8)
    S.CW = nil
end

function Window:Add(height)
    self.Y = self.Y + height + 4
    return self.Y - height - 4
end

function Isozine.Begin(title)
    local w = Window.new(title)
    return w and w:Begin() or false
end

function Isozine.End()
    if S.CW then
        S.CW:End()
    end
end

function Isozine.Text(txt)
    if not S.CW then return end
    local y = S.CW:Add(20)
    New("TextLabel", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,20),
        Text = txt,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
end

function Isozine.Button(label, size)
    if not S.CW then return false end
    size = size or Vector2.new(120, 26)
    local clicked = false
    local y = S.CW:Add(size.Y)
    
    local btn = New("TextButton", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(0,size.X,0,size.Y),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundColor3 = C.Button,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = btn})
    
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = C.ButtonHovered end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.Button end)
    btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = C.ButtonActive end)
    btn.MouseButton1Up:Connect(function() btn.BackgroundColor3 = C.ButtonHovered end)
    btn.MouseButton1Click:Connect(function() clicked = true end)
    
    return clicked
end

function Isozine.Checkbox(label, checked)
    if not S.CW then return checked end
    local newVal = checked
    local y = S.CW:Add(20)
    
    local container = New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    local box = New("Frame", {
        Parent = container,
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(0,0,0,2),
        BackgroundColor3 = C.FrameBg,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = box})
    New("UIStroke", {Color = C.Border, Thickness = 1, Parent = box})
    
    if checked then
        New("TextLabel", {
            Parent = box,
            Size = UDim2.new(1,0,1,0),
            Text = "✓",
            Font = Enum.Font.SourceSansBold,
            TextSize = 14,
            TextColor3 = C.CheckMark,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
            BorderSizePixel = 0
        })
    end
    
    New("TextLabel", {
        Parent = container,
        Position = UDim2.new(0,22,0,0),
        Size = UDim2.new(1,-22,1,0),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    
    local btn = New("TextButton", {
        Parent = container,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    btn.MouseButton1Click:Connect(function()
        newVal = not newVal
    end)
    
    return newVal
end

function Isozine.SliderFloat(label, val, min, max, fmt)
    if not S.CW then return val end
    fmt = fmt or "%.2f"
    local newVal = val
    local y = S.CW:Add(20)
    
    local container = New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    New("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.35,0,1,0),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    
    local slider = New("Frame", {
        Parent = container,
        Position = UDim2.new(0.35,4,0,2),
        Size = UDim2.new(0.65,-4,0,16),
        BackgroundColor3 = C.FrameBg,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = slider})
    
    local fill = New("Frame", {
        Parent = slider,
        Size = UDim2.new((val-min)/(max-min),0,1,0),
        BackgroundColor3 = C.Button,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = fill})
    
    local valLabel = New("TextLabel", {
        Parent = slider,
        Size = UDim2.new(1,0,1,0),
        Text = string.format(fmt, val),
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0
    })
    
    local dragging = false
    local dragConn = nil
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            if dragConn then
                dragConn:Disconnect()
            end
            
            dragConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if dragConn then
                        dragConn:Disconnect()
                        dragConn = nil
                    end
                end
            end)
        end
    end)
    
    local moveConn = UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            newVal = min + (max - min) * rel
        end
    end)
    
    return newVal
end

function Isozine.InputText(label, txt)
    if not S.CW then return txt end
    local newTxt = txt
    local y = S.CW:Add(20)
    
    local container = New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    New("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.3,0,1,0),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    
    local bg = New("Frame", {
        Parent = container,
        Position = UDim2.new(0.3,4,0,0),
        Size = UDim2.new(0.7,-4,1,0),
        BackgroundColor3 = C.FrameBg,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = bg})
    
    local box = New("TextBox", {
        Parent = bg,
        Size = UDim2.new(1,-8,1,0),
        Position = UDim2.new(0,4,0,0),
        Text = txt,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0
    })
    box:GetPropertyChangedSignal("Text"):Connect(function()
        newTxt = box.Text
    end)
    
    return newTxt
end

function Isozine.Separator()
    if not S.CW then return end
    local y = S.CW:Add(10)
    New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y+5),
        Size = UDim2.new(1,-16,0,1),
        BackgroundColor3 = C.Border,
        BorderSizePixel = 0
    })
end

function Isozine.Spacing()
    if S.CW then
        S.CW.Y = S.CW.Y + 4
    end
end

function Isozine.CollapsingHeader(label)
    if not S.CW then return false end
    local id = S.CW.Title..label
    S.CW.States[id] = S.CW.States[id] == nil and true or S.CW.States[id]
    
    local y = S.CW:Add(22)
    
    local header = New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,22),
        BackgroundColor3 = C.Header,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = header})
    
    New("TextLabel", {
        Parent = header,
        Position = UDim2.new(0,20,0,0),
        Size = UDim2.new(1,-20,1,0),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    
    New("TextLabel", {
        Parent = header,
        Size = UDim2.new(0,15,1,0),
        Position = UDim2.new(0,2,0,0),
        Text = S.CW.States[id] and "▼" or "▶",
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0
    })
    
    local btn = New("TextButton", {
        Parent = header,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    btn.MouseEnter:Connect(function() header.BackgroundTransparency = 0.4 end)
    btn.MouseLeave:Connect(function() header.BackgroundTransparency = 0.6 end)
    btn.MouseButton1Click:Connect(function()
        S.CW.States[id] = not S.CW.States[id]
    end)
    
    return S.CW.States[id]
end

function Isozine.BeginTabBar(label)
    if not S.CW then return false end
    S.TabBarID = S.CW.Title..label
    S.CW.States[S.TabBarID] = S.CW.States[S.TabBarID] or {sel=nil}
    
    local y = S.CW:Add(26)
    S.TabBar = New("Frame", {
        Parent = S.CW.Content,
        Position = UDim2.new(0,8,0,y),
        Size = UDim2.new(1,-16,0,26),
        BackgroundColor3 = C.TitleBg,
        BorderSizePixel = 0
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = S.TabBar})
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0,2),
        Parent = S.TabBar
    })
    return true
end

function Isozine.EndTabBar()
    S.TabBar = nil
    S.TabBarID = nil
end

function Isozine.BeginTabItem(label)
    if not S.TabBar then return false end
    local state = S.CW.States[S.TabBarID]
    state.sel = state.sel or label
    local active = state.sel == label
    
    local tab = New("TextButton", {
        Parent = S.TabBar,
        Size = UDim2.new(0,100,1,0),
        Text = label,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = C.Text,
        BackgroundColor3 = active and C.TabActive or C.Tab,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    New("UICorner", {CornerRadius = UDim.new(0,2), Parent = tab})
    
    tab.MouseEnter:Connect(function()
        if not active then
            tab.BackgroundColor3 = C.TabHovered
        end
    end)
    tab.MouseLeave:Connect(function()
        if not active then
            tab.BackgroundColor3 = C.Tab
        end
    end)
    tab.MouseButton1Click:Connect(function()
        state.sel = label
    end)
    
    return active
end

function Isozine.EndTabItem()
end

return Isozine
