-- RoImGui - Immediate Mode GUI Library for Roblox
-- Inspired by Dear ImGui

local RoImGui = {}
RoImGui.__index = RoImGui

-- Configuration
local Config = {
	WindowBgColor = Color3.fromRGB(20, 20, 25),
	WindowBgTransparency = 0.1,
	TitleBarColor = Color3.fromRGB(40, 40, 50),
	ButtonColor = Color3.fromRGB(60, 60, 70),
	ButtonHoverColor = Color3.fromRGB(80, 80, 90),
	ButtonActiveColor = Color3.fromRGB(100, 100, 110),
	TextColor = Color3.fromRGB(255, 255, 255),
	CheckboxColor = Color3.fromRGB(60, 120, 200),
	SliderColor = Color3.fromRGB(60, 120, 200),
	Padding = 8,
	ItemSpacing = 4,
	TitleBarHeight = 30,
	ScrollBarWidth = 14,
}

-- Create new context
function RoImGui.new()
	local self = setmetatable({}, RoImGui)
	
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "RoImGui"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = game:GetService("CoreGui")
	
	self.Windows = {}
	self.CurrentWindow = nil
	self.ActiveId = nil
	self.HotId = nil
	self.MousePos = Vector2.new(0, 0)
	self.MouseDelta = Vector2.new(0, 0)
	self.MouseDown = false
	self.IdCounter = 0
	
	-- Input handling
	local UserInputService = game:GetService("UserInputService")
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local newPos = Vector2.new(input.Position.X, input.Position.Y)
			self.MouseDelta = newPos - self.MousePos
			self.MousePos = newPos
		end
	end)
	
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.MouseDown = true
			self.ActiveId = self.HotId
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.MouseDown = false
			self.ActiveId = nil
		end
	end)
	
	return self
end

-- Generate unique ID
function RoImGui:GenId(label)
	self.IdCounter = self.IdCounter + 1
	return label .. "_" .. self.IdCounter
end

-- Begin new frame
function RoImGui:NewFrame()
	self.IdCounter = 0
	self.HotId = nil
end

-- End frame
function RoImGui:EndFrame()
	-- Cleanup unused windows
	for name, window in pairs(self.Windows) do
		if not window.Active then
			window.Frame:Destroy()
			self.Windows[name] = nil
		else
			window.Active = false
		end
	end
end

-- Begin window
function RoImGui:Begin(name, size, pos)
	local window = self.Windows[name]
	
	if not window then
		window = self:CreateWindow(name, size or Vector2.new(400, 500), pos or Vector2.new(100, 100))
		self.Windows[name] = window
	end
	
	window.Active = true
	window.CursorY = Config.TitleBarHeight + Config.Padding
	self.CurrentWindow = window
	
	return true
end

-- End window
function RoImGui:End()
	self.CurrentWindow = nil
end

-- Create window structure
function RoImGui:CreateWindow(name, size, pos)
	local window = {}
	
	-- Main frame
	window.Frame = Instance.new("Frame")
	window.Frame.Name = name
	window.Frame.Size = UDim2.new(0, size.X, 0, size.Y)
	window.Frame.Position = UDim2.new(0, pos.X, 0, pos.Y)
	window.Frame.BackgroundColor3 = Config.WindowBgColor
	window.Frame.BackgroundTransparency = Config.WindowBgTransparency
	window.Frame.BorderSizePixel = 0
	window.Frame.Active = true
	window.Frame.Parent = self.ScreenGui
	
	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = window.Frame
	
	-- Title bar
	window.TitleBar = Instance.new("Frame")
	window.TitleBar.Name = "TitleBar"
	window.TitleBar.Size = UDim2.new(1, 0, 0, Config.TitleBarHeight)
	window.TitleBar.BackgroundColor3 = Config.TitleBarColor
	window.TitleBar.BorderSizePixel = 0
	window.TitleBar.Parent = window.Frame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 6)
	titleCorner.Parent = window.TitleBar
	
	-- Title text
	window.Title = Instance.new("TextLabel")
	window.Title.Name = "Title"
	window.Title.Size = UDim2.new(1, -16, 1, 0)
	window.Title.Position = UDim2.new(0, 8, 0, 0)
	window.Title.BackgroundTransparency = 1
	window.Title.Text = name
	window.Title.TextColor3 = Config.TextColor
	window.Title.TextSize = 14
	window.Title.Font = Enum.Font.GothamBold
	window.Title.TextXAlignment = Enum.TextXAlignment.Left
	window.Title.Parent = window.TitleBar
	
	-- Content container
	window.Container = Instance.new("Frame")
	window.Container.Name = "Container"
	window.Container.Size = UDim2.new(1, 0, 1, -Config.TitleBarHeight)
	window.Container.Position = UDim2.new(0, 0, 0, Config.TitleBarHeight)
	window.Container.BackgroundTransparency = 1
	window.Container.ClipsDescendants = true
	window.Container.Parent = window.Frame
	
	-- Dragging
	local dragging = false
	local dragStart = Vector2.new(0, 0)
	local startPos = pos
	
	window.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = Vector2.new(window.Frame.AbsolutePosition.X, window.Frame.AbsolutePosition.Y)
		end
	end)
	
	window.TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			window.Frame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
		end
	end)
	
	window.Size = size
	window.CursorY = Config.TitleBarHeight + Config.Padding
	window.Active = true
	
	return window
end

-- Check if point is in rect
function RoImGui:IsPointInRect(point, rectPos, rectSize)
	return point.X >= rectPos.X and point.X <= rectPos.X + rectSize.X and
	       point.Y >= rectPos.Y and point.Y <= rectPos.Y + rectSize.Y
end

-- Button widget
function RoImGui:Button(label, size)
	if not self.CurrentWindow then return false end
	
	local window = self.CurrentWindow
	local id = self:GenId(label)
	size = size or Vector2.new(window.Size.X - Config.Padding * 2, 30)
	
	local btn = Instance.new("TextButton")
	btn.Name = id
	btn.Size = UDim2.new(0, size.X, 0, size.Y)
	btn.Position = UDim2.new(0, Config.Padding, 0, window.CursorY)
	btn.BackgroundColor3 = Config.ButtonColor
	btn.BorderSizePixel = 0
	btn.Text = label
	btn.TextColor3 = Config.TextColor
	btn.TextSize = 14
	btn.Font = Enum.Font.Gotham
	btn.Parent = window.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	
	local clicked = false
	
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Config.ButtonHoverColor
	end)
	
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Config.ButtonColor
	end)
	
	btn.MouseButton1Down:Connect(function()
		btn.BackgroundColor3 = Config.ButtonActiveColor
	end)
	
	btn.MouseButton1Up:Connect(function()
		btn.BackgroundColor3 = Config.ButtonHoverColor
	end)
	
	btn.MouseButton1Click:Connect(function()
		clicked = true
	end)
	
	window.CursorY = window.CursorY + size.Y + Config.ItemSpacing
	
	return clicked
end

-- Text widget
function RoImGui:Text(text)
	if not self.CurrentWindow then return end
	
	local window = self.CurrentWindow
	local id = self:GenId(text)
	
	local lbl = Instance.new("TextLabel")
	lbl.Name = id
	lbl.Size = UDim2.new(1, -Config.Padding * 2, 0, 20)
	lbl.Position = UDim2.new(0, Config.Padding, 0, window.CursorY)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Config.TextColor
	lbl.TextSize = 14
	lbl.Font = Enum.Font.Gotham
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.TextWrapped = true
	lbl.Parent = window.Container
	
	window.CursorY = window.CursorY + 20 + Config.ItemSpacing
end

-- Separator
function RoImGui:Separator()
	if not self.CurrentWindow then return end
	
	local window = self.CurrentWindow
	
	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, -Config.Padding * 2, 0, 1)
	sep.Position = UDim2.new(0, Config.Padding, 0, window.CursorY + 4)
	sep.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	sep.BorderSizePixel = 0
	sep.Parent = window.Container
	
	window.CursorY = window.CursorY + 9
end

return RoImGui
