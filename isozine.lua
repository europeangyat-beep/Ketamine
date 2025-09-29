local RoIso = {}
RoIso.__index = RoIso

local cfg = {
	bg = Color3.fromRGB(15, 15, 18),
	title = Color3.fromRGB(25, 25, 30),
	tab = Color3.fromRGB(20, 20, 24),
	tabActive = Color3.fromRGB(45, 100, 180),
	btn = Color3.fromRGB(35, 35, 42),
	btnHover = Color3.fromRGB(45, 45, 55),
	btnActive = Color3.fromRGB(55, 55, 65),
	accent = Color3.fromRGB(60, 130, 220),
	text = Color3.fromRGB(240, 240, 245),
	textDim = Color3.fromRGB(160, 160, 170),
}

function RoIso.new(name, sz, pos)
	local self = setmetatable({}, RoIso)
	sz = sz or Vector2.new(480, 380)
	pos = pos or Vector2.new(100, 100)
	
	self.sg = Instance.new("ScreenGui")
	self.sg.Name = "RoIso"
	self.sg.ResetOnSpawn = false
	self.sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() self.sg.Parent = game:GetService("CoreGui") end)
	if not self.sg.Parent then 
		self.sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 
	end
	
	self.tabs = {}
	self.active = nil
	
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, sz.X, 0, sz.Y)
	f.Position = UDim2.new(0, pos.X, 0, pos.Y)
	f.BackgroundColor3 = cfg.bg
	f.BorderSizePixel = 0
	f.Active = true
	f.Draggable = true
	f.Parent = self.sg
	self.main = f
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = f
	
	local t = Instance.new("Frame")
	t.Size = UDim2.new(1, 0, 0, 28)
	t.BackgroundColor3 = cfg.title
	t.BorderSizePixel = 0
	t.Parent = f
	
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 6)
	tc.Parent = t
	
	local th = Instance.new("Frame")
	th.Size = UDim2.new(1, 0, 0, 6)
	th.Position = UDim2.new(0, 0, 1, -6)
	th.BackgroundColor3 = cfg.title
	th.BorderSizePixel = 0
	th.Parent = t
	
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -20, 1, 0)
	tl.Position = UDim2.new(0, 10, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = name
	tl.TextColor3 = cfg.text
	tl.TextSize = 14
	tl.Font = Enum.Font.GothamBold
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = t
	
	local tc = Instance.new("Frame")
	tc.Size = UDim2.new(1, 0, 0, 32)
	tc.Position = UDim2.new(0, 0, 0, 28)
	tc.BackgroundColor3 = cfg.tab
	tc.BorderSizePixel = 0
	tc.Parent = f
	self.tabCont = tc
	
	local tl = Instance.new("UIListLayout")
	tl.FillDirection = Enum.FillDirection.Horizontal
	tl.Padding = UDim.new(0, 1)
	tl.Parent = tc
	
	local s = Instance.new("ScrollingFrame")
	s.Size = UDim2.new(1, -16, 1, -68)
	s.Position = UDim2.new(0, 8, 0, 60)
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.ScrollBarThickness = 4
	s.ScrollBarImageColor3 = cfg.btnHover
	s.CanvasSize = UDim2.new(0, 0, 0, 0)
	s.Parent = f
	self.scroll = s
	
	return self
end

function RoIso:AddTab(n)
	if self.tabs[n] then return end
	
	local tab = {name = n, items = {}, y = 0}
	
	local f = Instance.new("Frame")
	f.Name = n
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.Parent = self.scroll
	tab.frame = f
	
	local b = Instance.new("TextButton")
	b.Name = n
	b.Size = UDim2.new(0, 90, 1, 0)
	b.BackgroundColor3 = cfg.tab
	b.BorderSizePixel = 0
	b.Text = n
	b.TextColor3 = cfg.text
	b.TextSize = 13
	b.Font = Enum.Font.GothamMedium
	b.AutoButtonColor = false
	b.Parent = self.tabCont
	tab.btn = b
	
	b.MouseButton1Click:Connect(function()
		for _, t in pairs(self.tabs) do
			t.frame.Visible = false
			t.btn.BackgroundColor3 = cfg.tab
		end
		f.Visible = true
		b.BackgroundColor3 = cfg.tabActive
		self.active = n
	end)
	
	self.tabs[n] = tab
	if not self.active then
		f.Visible = true
		b.BackgroundColor3 = cfg.tabActive
		self.active = n
	end
end

function RoIso:AddButton(tab, txt, cb)
	local t = self.tabs[tab]
	if not t then warn("Tab '" .. tab .. "' doesnt exist") return end
	
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.Position = UDim2.new(0, 0, 0, t.y)
	b.BackgroundColor3 = cfg.btn
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = cfg.text
	b.TextSize = 13
	b.Font = Enum.Font.Gotham
	b.AutoButtonColor = false
	b.Parent = t.frame
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = b
	
	b.MouseEnter:Connect(function() b.BackgroundColor3 = cfg.btnHover end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = cfg.btn end)
	b.MouseButton1Down:Connect(function() b.BackgroundColor3 = cfg.btnActive end)
	b.MouseButton1Up:Connect(function() b.BackgroundColor3 = cfg.btnHover end)
	b.MouseButton1Click:Connect(function() if cb then cb() end end)
	
	t.y = t.y + 36
	self.scroll.CanvasSize = UDim2.new(0, 0, 0, t.y)
end

function RoIso:AddToggle(tab, txt, def, cb)
	local t = self.tabs[tab]
	if not t then warn("Tab '" .. tab .. "' doesnt exist") return end
	
	local state = def or false
	
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 32)
	f.Position = UDim2.new(0, 0, 0, t.y)
	f.BackgroundColor3 = cfg.btn
	f.BorderSizePixel = 0
	f.Parent = t.frame
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = f
	
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -50, 1, 0)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = cfg.text
	l.TextSize = 13
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	
	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0, 36, 0, 18)
	tb.Position = UDim2.new(1, -42, 0.5, -9)
	tb.BackgroundColor3 = state and cfg.accent or cfg.btnActive
	tb.BorderSizePixel = 0
	tb.Text = ""
	tb.AutoButtonColor = false
	tb.Parent = f
	
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = tb
	
	local k = Instance.new("Frame")
	k.Size = UDim2.new(0, 14, 0, 14)
	k.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	k.BackgroundColor3 = cfg.text
	k.BorderSizePixel = 0
	k.Parent = tb
	
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = k
	
	tb.MouseButton1Click:Connect(function()
		state = not state
		tb.BackgroundColor3 = state and cfg.accent or cfg.btnActive
		game:GetService("TweenService"):Create(k, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		}):Play()
		if cb then cb(state) end
	end)
	
	t.y = t.y + 36
	self.scroll.CanvasSize = UDim2.new(0, 0, 0, t.y)
end

function RoIso:AddSlider(tab, txt, min, max, def, cb)
	local t = self.tabs[tab]
	if not t then warn("Tab '" .. tab .. "' doesnt exist") return end
	
	local val = def or min
	
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 48)
	f.Position = UDim2.new(0, 0, 0, t.y)
	f.BackgroundColor3 = cfg.btn
	f.BorderSizePixel = 0
	f.Parent = t.frame
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = f
	
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -20, 0, 20)
	l.Position = UDim2.new(0, 10, 0, 4)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = cfg.text
	l.TextSize = 13
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	
	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0, 50, 0, 20)
	vl.Position = UDim2.new(1, -60, 0, 4)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(val)
	vl.TextColor3 = cfg.accent
	vl.TextSize = 13
	vl.Font = Enum.Font.GothamBold
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = f
	
	local sb = Instance.new("Frame")
	sb.Size = UDim2.new(1, -20, 0, 6)
	sb.Position = UDim2.new(0, 10, 1, -14)
	sb.BackgroundColor3 = cfg.btnActive
	sb.BorderSizePixel = 0
	sb.Parent = f
	
	local sbc = Instance.new("UICorner")
	sbc.CornerRadius = UDim.new(1, 0)
	sbc.Parent = sb
	
	local sf = Instance.new("Frame")
	sf.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
	sf.BackgroundColor3 = cfg.accent
	sf.BorderSizePixel = 0
	sf.Parent = sb
	
	local sfc = Instance.new("UICorner")
	sfc.CornerRadius = UDim.new(1, 0)
	sfc.Parent = sf
	
	local drag = false
	sb.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end
	end)
	sb.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local x = math.clamp((i.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
			val = math.floor(min + (max - min) * x)
			vl.Text = tostring(val)
			sf.Size = UDim2.new(x, 0, 1, 0)
			if cb then cb(val) end
		end
	end)
	
	t.y = t.y + 52
	self.scroll.CanvasSize = UDim2.new(0, 0, 0, t.y)
end

function RoIso:AddTextbox(tab, txt, def, cb)
	local t = self.tabs[tab]
	if not t then warn("Tab '" .. tab .. "' doesnt exist") return end
	
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 32)
	f.Position = UDim2.new(0, 0, 0, t.y)
	f.BackgroundColor3 = cfg.btn
	f.BorderSizePixel = 0
	f.Parent = t.frame
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = f
	
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 80, 1, 0)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = cfg.text
	l.TextSize = 13
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, -100, 0, 24)
	tb.Position = UDim2.new(0, 94, 0, 4)
	tb.BackgroundColor3 = cfg.btnActive
	tb.BorderSizePixel = 0
	tb.Text = def or ""
	tb.PlaceholderText = "Enter text..."
	tb.TextColor3 = cfg.text
	tb.PlaceholderColor3 = cfg.textDim
	tb.TextSize = 12
	tb.Font = Enum.Font.Gotham
	tb.ClearTextOnFocus = false
	tb.Parent = f
	
	local tbc = Instance.new("UICorner")
	tbc.CornerRadius = UDim.new(0, 3)
	tbc.Parent = tb
	
	tb.FocusLost:Connect(function()
		if cb then cb(tb.Text) end
	end)
	
	t.y = t.y + 36
	self.scroll.CanvasSize = UDim2.new(0, 0, 0, t.y)
end

function RoIso:Unhook(pos)
	pos = pos or Vector2.new(10, 10)
	
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 80, 0, 24)
	b.Position = UDim2.new(0, pos.X, 0, pos.Y)
	b.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	b.BorderSizePixel = 0
	b.Text = "Unload"
	b.TextColor3 = cfg.text
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 10
	b.Parent = self.main
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = b
	
	b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(200, 70, 70) end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end)
	b.MouseButton1Click:Connect(function() self.sg:Destroy() end)
end

return RoIso
