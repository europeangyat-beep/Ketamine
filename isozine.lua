local RoIso = {}
RoIso.__index = RoIso

local Config = {
	WindowBgColor = Color3.fromRGB(20, 20, 25),
	WindowBgTransparency = 0.05,
	TitleBarColor = Color3.fromRGB(40, 40, 50),
	TabColor = Color3.fromRGB(35, 35, 45),
	TabActiveColor = Color3.fromRGB(60, 120, 200),
	ButtonColor = Color3.fromRGB(60, 60, 70),
	ButtonHoverColor = Color3.fromRGB(80, 80, 90),
	ButtonActiveColor = Color3.fromRGB(100, 100, 110),
	TextColor = Color3.fromRGB(255, 255, 255),
	Padding = 8,
	ItemSpacing = 4,
	TitleBarHeight = 30,
	TabHeight = 35,
}

function RoIso.new(title, size, position)
	local self = setmetatable({}, RoIso)
	
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "RoIso_" .. title
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.IgnoreGuiInset = true
	
	local success = pcall(function()
		self.ScreenGui.Parent = game:GetService("CoreGui")
	end)
	if not success then
		self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end
	
	self.Tabs = {}
	self.ActiveTab = nil
	self.UnhookPosition = nil
	
	size = size or Vector2.new(500, 400)
	position = position or Vector2.new(100, 100)
	
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, size.X, 0, size.Y)
	self.MainFrame.Position = UDim2.new(0, position.X, 0, position.Y)
	self.MainFrame.BackgroundColor3 = Config.WindowBgColor
	self.MainFrame.BackgroundTransparency = Config.WindowBgTransparency
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Active = true
	self.MainFrame.Draggable = true
	self.MainFrame.Parent = self.ScreenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.MainFrame
	
	self.TitleBar = Instance.new("Frame")
	self.TitleBar.Name = "TitleBar"
	self.TitleBar.Size = UDim2.new(1, 0, 0, Config.TitleBarHeight)
	self.TitleBar.BackgroundColor3 = Config.TitleBarColor
	self.TitleBar.BorderSizePixel = 0
	self.TitleBar.Parent = self.MainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = self.TitleBar
	
	local titleHider = Instance.new("Frame")
	titleHider.Size = UDim2.new(1, 0, 0, 8)
	titleHider.Position = UDim2.new(0, 0, 1, -8)
	titleHider.BackgroundColor3 = Config.TitleBarColor
	titleHider.BorderSizePixel = 0
	titleHider.Parent = self.TitleBar
	
	self.TitleLabel = Instance.new("TextLabel")
	self.TitleLabel.Name = "Title"
	self.TitleLabel.Size = UDim2.new(1, -16, 1, 0)
	self.TitleLabel.Position = UDim2.new(0, 12, 0, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Text = title
	self.TitleLabel.TextColor3 = Config.TextColor
	self.TitleLabel.TextSize = 16
	self.TitleLabel.Font = Enum.Font.GothamBold
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Parent = self.TitleBar
	
	self.TabContainer = Instance.new("Frame")
	self.TabContainer.Name = "TabContainer"
	self.TabContainer.Size = UDim2.new(1, 0, 0, Config.TabHeight)
	self.TabContainer.Position = UDim2.new(0, 0, 0, Config.TitleBarHeight)
	self.TabContainer.BackgroundColor3 = Config.TabColor
	self.TabContainer.BorderSizePixel = 0
	self.TabContainer.Parent = self.MainFrame
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 2)
	tabLayout.Parent = self.TabContainer
	
	self.ContentFrame = Instance.new("ScrollingFrame")
	self.ContentFrame.Name = "ContentFrame"
	self.ContentFrame.Size = UDim2.new(1, 0, 1, -(Config.TitleBarHeight + Config.TabHeight))
	self.ContentFrame.Position = UDim2.new(0, 0, 0, Config.TitleBarHeight + Config.TabHeight)
	self.ContentFrame.BackgroundTransparency = 1
	self.ContentFrame.BorderSizePixel = 0
	self.ContentFrame.ScrollBarThickness = 6
	self.ContentFrame.ScrollBarImageColor3 = Config.ButtonColor
	self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.ContentFrame.Parent = self.MainFrame
	
	return self
end

function RoIso:AddTab(name)
	if self.Tabs[name] then return end
	
	local tab = {}
	tab.Name = name
	tab.Buttons = {}
	tab.CursorY = Config.Padding
	
	tab.Frame = Instance.new("Frame")
	tab.Frame.Name = name
	tab.Frame.Size = UDim2.new(1, -Config.Padding * 2, 1, 0)
	tab.Frame.Position = UDim2.new(0, Config.Padding, 0, 0)
	tab.Frame.BackgroundTransparency = 1
	tab.Frame.Visible = false
	tab.Frame.Parent = self.ContentFrame
	
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, Config.ItemSpacing)
	layout.Parent = tab.Frame
	
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name
	tabButton.Size = UDim2.new(0, 100, 1, 0)
	tabButton.BackgroundColor3 = Config.TabColor
	tabButton.BorderSizePixel = 0
	tabButton.Text = name
	tabButton.TextColor3 = Config.TextColor
	tabButton.TextSize = 14
	tabButton.Font = Enum.Font.GothamMedium
	tabButton.Parent = self.TabContainer
	
	tabButton.MouseButton1Click:Connect(function()
		self:SwitchTab(name)
	end)
	
	tab.Button = tabButton
	self.Tabs[name] = tab
	
	if not self.ActiveTab then
		self:SwitchTab(name)
	end
end

function RoIso:SwitchTab(name)
	if not self.Tabs[name] then return end
	
	for tabName, tab in pairs(self.Tabs) do
		tab.Frame.Visible = false
		tab.Button.BackgroundColor3 = Config.TabColor
	end
	
	self.Tabs[name].Frame.Visible = true
	self.Tabs[name].Button.BackgroundColor3 = Config.TabActiveColor
	self.ActiveTab = name
end

function RoIso:AddButton(tabName, buttonText, callback)
	local tab = self.Tabs[tabName]
	if not tab then
		warn("Tab '" .. tabName .. "' does not exist. Create it first with AddTab()")
		return
	end
	
	local btn = Instance.new("TextButton")
	btn.Name = buttonText
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = Config.ButtonColor
	btn.BorderSizePixel = 0
	btn.Text = buttonText
	btn.TextColor3 = Config.TextColor
	btn.TextSize = 14
	btn.Font = Enum.Font.Gotham
	btn.AutoButtonColor = false
	btn.Parent = tab.Frame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
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
		if callback then
			callback()
		end
	end)
	
	table.insert(tab.Buttons, btn)
	
	local contentSize = #tab.Buttons * (35 + Config.ItemSpacing) + Config.Padding
	self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize)
end

function RoIso:Unhook(position)
	self.UnhookPosition = position or Vector2.new(10, 10)
	
	local unhookBtn = Instance.new("TextButton")
	unhookBtn.Name = "UnhookButton"
	unhookBtn.Size = UDim2.new(0, 100, 0, 30)
	unhookBtn.Position = UDim2.new(0, self.UnhookPosition.X, 0, self.UnhookPosition.Y)
	unhookBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	unhookBtn.BorderSizePixel = 0
	unhookBtn.Text = "Unload"
	unhookBtn.TextColor3 = Config.TextColor
	unhookBtn.TextSize = 14
	unhookBtn.Font = Enum.Font.GothamBold
	unhookBtn.ZIndex = 10
	unhookBtn.Parent = self.MainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = unhookBtn
	
	unhookBtn.MouseEnter:Connect(function()
		unhookBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
	end)
	
	unhookBtn.MouseLeave:Connect(function()
		unhookBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	end)
	
	unhookBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
end

function RoIso:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
	setmetatable(self, nil)
end

return RoIso
