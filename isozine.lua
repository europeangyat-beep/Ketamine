local Lib = {}
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

local C = {
    WindowBg = Color3.fromRGB(15, 15, 15),
    TitleBg = Color3.fromRGB(10, 10, 10),
    TitleBgActive = Color3.fromRGB(16, 29, 46),
    Border = Color3.fromRGB(43, 43, 43),
    FrameBg = Color3.fromRGB(41, 74, 122),
    FrameBgHovered = Color3.fromRGB(66, 150, 250),
    FrameBgActive = Color3.fromRGB(66, 150, 250),
    Button = Color3.fromRGB(66, 150, 250),
    ButtonHovered = Color3.fromRGB(66, 150, 250),
    ButtonActive = Color3.fromRGB(6, 53, 98),
    CheckMark = Color3.fromRGB(66, 150, 250),
    SliderGrab = Color3.fromRGB(66, 150, 250),
    SliderGrabActive = Color3.fromRGB(66, 150, 250),
    Text = Color3.fromRGB(255, 255, 255),
    TextDisabled = Color3.fromRGB(128, 128, 128),
    Header = Color3.fromRGB(66, 150, 250),
    HeaderHovered = Color3.fromRGB(66, 150, 250),
    HeaderActive = Color3.fromRGB(66, 150, 250),
    Separator = Color3.fromRGB(110, 110, 128),
    ScrollbarBg = Color3.fromRGB(5, 5, 5),
    ScrollbarGrab = Color3.fromRGB(79, 79, 79),
}

local function C3(r, g, b) return Color3.fromRGB(r, g, b) end

local function Inst(c, p)
    local o = Instance.new(c)
    for k, v in pairs(p) do if k ~= "Parent" then o[k] = v end end
    o.Parent = p.Parent
    return o
end

function Lib:Begin(t, s)
    local sg = Inst("ScreenGui", {Name = "ImGui", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})
    
    local w = Inst("Frame", {
        Name = "Window",
        Parent = sg,
        Size = UDim2.new(0, s.X or 400, 0, s.Y or 300),
        Position = UDim2.new(0.5, -(s.X or 400)/2, 0.5, -(s.Y or 300)/2),
        BackgroundColor3 = C.WindowBg,
        BorderColor3 = C.Border,
        BorderSizePixel = 1
    })
    
    local tb = Inst("Frame", {
        Name = "TitleBar",
        Parent = w,
        Size = UDim2.new(1, 0, 0, 19),
        BackgroundColor3 = C.TitleBg,
        BorderSizePixel = 0
    })
    
    Inst("TextLabel", {
        Parent = tb,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = t,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local close = Inst("TextButton", {
        Parent = tb,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -18, 0, 2),
        BackgroundColor3 = C3(140, 20, 20),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = C.Text,
        TextSize = 12,
        Font = Enum.Font.SourceSansBold
    })
    
    close.MouseButton1Click:Connect(function() sg:Destroy() end)
    
    local cont = Inst("ScrollingFrame", {
        Name = "Content",
        Parent = w,
        Size = UDim2.new(1, -16, 1, -27),
        Position = UDim2.new(0, 8, 0, 23),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 12,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = C.ScrollbarGrab
    })
    
    Inst("UIListLayout", {Parent = cont, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
    
    local drag, dstart, spos
    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dstart = i.Position
            spos = w.Position
            tb.BackgroundColor3 = C.TitleBgActive
        end
    end)
    
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dstart
            w.Position = UDim2.new(spos.X.Scale, spos.X.Offset + d.X, spos.Y.Scale, spos.Y.Offset + d.Y)
        end
    end)
    
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
            tb.BackgroundColor3 = C.TitleBg
        end
    end)
    
    return {G = sg, W = w, C = cont}
end

function Lib:Button(w, txt, cb)
    local b = Inst("TextButton", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 19),
        BackgroundColor3 = C.Button,
        BorderSizePixel = 0,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        AutoButtonColor = false
    })
    
    b.MouseEnter:Connect(function() b.BackgroundColor3 = C.ButtonHovered end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = C.Button end)
    b.MouseButton1Down:Connect(function() b.BackgroundColor3 = C.ButtonActive end)
    b.MouseButton1Up:Connect(function() b.BackgroundColor3 = C.ButtonHovered end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return b
end

function Lib:Checkbox(w, txt, def, cb)
    local f = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 19),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    local box = Inst("Frame", {
        Parent = f,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = C.FrameBg,
        BorderColor3 = C.Border,
        BorderSizePixel = 1
    })
    
    local check = Inst("TextLabel", {
        Parent = box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.CheckMark,
        TextSize = 18,
        Font = Enum.Font.SourceSansBold
    })
    
    Inst("TextLabel", {
        Parent = f,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local state = def or false
    check.Text = state and "✓" or ""
    
    local btn = Inst("TextButton", {
        Parent = f,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    btn.MouseEnter:Connect(function() box.BackgroundColor3 = C.FrameBgHovered end)
    btn.MouseLeave:Connect(function() box.BackgroundColor3 = C.FrameBg end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        check.Text = state and "✓" or ""
        if cb then cb(state) end
    end)
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return {S = state, E = f}
end

function Lib:SliderInt(w, txt, min, max, def, cb)
    local f = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    local lbl = Inst("TextLabel", {
        Parent = f,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local frame = Inst("Frame", {
        Parent = f,
        Size = UDim2.new(1, 0, 0, 19),
        Position = UDim2.new(0, 0, 0, 19),
        BackgroundColor3 = C.FrameBg,
        BorderSizePixel = 0
    })
    
    local fill = Inst("Frame", {
        Parent = frame,
        Size = UDim2.new((def - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = C.SliderGrab,
        BorderSizePixel = 0
    })
    
    local val = Inst("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(def),
        TextColor3 = C.Text,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local v = def
    local drag = false
    
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            frame.BackgroundColor3 = C.FrameBgActive
        end
    end)
    
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
            frame.BackgroundColor3 = C.FrameBg
        end
    end)
    
    RS.RenderStepped:Connect(function()
        if drag then
            local mp = UIS:GetMouseLocation().X
            local rp = math.clamp((mp - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
            v = math.floor(min + (max - min) * rp)
            fill.Size = UDim2.new(rp, 0, 1, 0)
            val.Text = tostring(v)
            if cb then cb(v) end
        end
    end)
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return {V = v, E = f}
end

function Lib:InputText(w, txt, placeholder, cb)
    local f = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 19),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    Inst("TextLabel", {
        Parent = f,
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local tb = Inst("TextBox", {
        Parent = f,
        Size = UDim2.new(1, -105, 0, 19),
        Position = UDim2.new(0, 105, 0, 0),
        BackgroundColor3 = C.FrameBg,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder or "",
        TextColor3 = C.Text,
        PlaceholderColor3 = C.TextDisabled,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })
    
    Inst("UIPadding", {Parent = tb, PaddingLeft = UDim.new(0, 4)})
    
    tb.FocusLost:Connect(function(e)
        if e and cb then cb(tb.Text) end
    end)
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return {E = f, T = tb}
end

function Lib:Text(w, txt)
    local l = Inst("TextLabel", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 14),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return l
end

function Lib:Separator(w)
    local s = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 1),
        BackgroundColor3 = C.Separator,
        BorderSizePixel = 0
    })
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return s
end

function Lib:SameLine() end

function Lib:Spacing(w)
    local s = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return s
end

function Lib:CollapsingHeader(w, txt, def)
    local f = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 22),
        BackgroundColor3 = C.Header,
        BorderSizePixel = 0
    })
    
    local arrow = Inst("TextLabel", {
        Parent = f,
        Size = UDim2.new(0, 16, 1, 0),
        BackgroundTransparency = 1,
        Text = def and "▼" or "▶",
        TextColor3 = C.Text,
        TextSize = 11,
        Font = Enum.Font.SourceSansBold
    })
    
    Inst("TextLabel", {
        Parent = f,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local cont = Inst("Frame", {
        Parent = w.C,
        Size = UDim2.new(1, -8, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = def or false
    })
    
    Inst("UIListLayout", {Parent = cont, Padding = UDim.new(0, 4)})
    
    local open = def or false
    
    local btn = Inst("TextButton", {
        Parent = f,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    btn.MouseEnter:Connect(function() f.BackgroundColor3 = C.HeaderHovered end)
    btn.MouseLeave:Connect(function() f.BackgroundColor3 = C.Header end)
    btn.MouseButton1Click:Connect(function()
        open = not open
        arrow.Text = open and "▼" or "▶"
        cont.Visible = open
        w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    end)
    
    w.C.CanvasSize = UDim2.new(0, 0, 0, w.C.UIListLayout.AbsoluteContentSize.Y)
    return {E = f, C = cont, O = open}
end

return Lib
