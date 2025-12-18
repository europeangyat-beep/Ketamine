local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlutoniumUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 775, 0, 500)
mainFrame.Position = UDim2.new(0.5, -387.5, 0.5, -250)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(91, 124, 255)
toggleButton.BackgroundTransparency = 0.15
toggleButton.BorderSizePixel = 0
toggleButton.Text = "≡"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 28
toggleButton.Font = Enum.Font.GothamBold
toggleButton.ZIndex = 1000

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(91, 124, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleButton

local menuVisible = true
toggleButton.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	mainFrame.Visible = menuVisible
	TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundTransparency = menuVisible and 0.15 or 0.5}):Play()
end)

toggleButton.MouseEnter:Connect(function()
	TweenService:Create(toggleButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
end)

toggleButton.MouseLeave:Connect(function()
	TweenService:Create(toggleButton, TweenInfo.new(0.15), {BackgroundTransparency = menuVisible and 0.15 or 0.5}):Play()
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local frameStart = nil

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		frameStart = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
sidebar.BackgroundTransparency = 0.05
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Left-side rounded corners only
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

-- Clip sidebar to hide right corners
sidebar.ClipsDescendants = true

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1
header.Parent = sidebar

local headerBorder = Instance.new("Frame")
headerBorder.Size = UDim2.new(1, -32, 0, 1)
headerBorder.Position = UDim2.new(0, 16, 1, 0)
headerBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
headerBorder.BackgroundTransparency = 0.95
headerBorder.BorderSizePixel = 0
headerBorder.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -32, 0, 20)
headerTitle.Position = UDim2.new(0, 16, 0, 12)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Plutonium"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.TextSize = 16
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local headerSubtitle = Instance.new("TextLabel")
headerSubtitle.Size = UDim2.new(1, -32, 0, 15)
headerSubtitle.Position = UDim2.new(0, 16, 0, 32)
headerSubtitle.BackgroundTransparency = 1
headerSubtitle.Text = "beta | version 3.0"
headerSubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerSubtitle.TextTransparency = 0.65
headerSubtitle.TextSize = 11
headerSubtitle.Font = Enum.Font.Gotham
headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
headerSubtitle.Parent = header

-- Nav Items Container
local navItems = Instance.new("ScrollingFrame")
navItems.Size = UDim2.new(1, -16, 1, -140)
navItems.Position = UDim2.new(0, 8, 0, 72)
navItems.BackgroundTransparency = 1
navItems.BorderSizePixel = 0
navItems.ScrollBarThickness = 0
navItems.CanvasSize = UDim2.new(0, 0, 0, 0)
navItems.AutomaticCanvasSize = Enum.AutomaticSize.Y
navItems.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navItems

-- Footer
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 64)
footer.Position = UDim2.new(0, 0, 1, -64)
footer.BackgroundTransparency = 1
footer.Parent = sidebar

local footerBorder = Instance.new("Frame")
footerBorder.Size = UDim2.new(1, -32, 0, 1)
footerBorder.Position = UDim2.new(0, 16, 0, 0)
footerBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
footerBorder.BackgroundTransparency = 0.95
footerBorder.BorderSizePixel = 0
footerBorder.Parent = footer

local footerAvatar = Instance.new("ImageLabel")
footerAvatar.Size = UDim2.new(0, 32, 0, 32)
footerAvatar.Position = UDim2.new(0, 16, 0, 16)
footerAvatar.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
footerAvatar.BorderSizePixel = 0
footerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=48&height=48&format=png"
footerAvatar.Parent = footer

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 6)
avatarCorner.Parent = footerAvatar

local footerName = Instance.new("TextLabel")
footerName.Size = UDim2.new(1, -58, 0, 16)
footerName.Position = UDim2.new(0, 58, 0, 18)
footerName.BackgroundTransparency = 1
footerName.Text = player.Name
footerName.TextColor3 = Color3.fromRGB(255, 255, 255)
footerName.TextSize = 12
footerName.Font = Enum.Font.GothamBold
footerName.TextXAlignment = Enum.TextXAlignment.Left
footerName.TextTruncate = Enum.TextTruncate.AtEnd
footerName.Parent = footer

local footerStatus = Instance.new("TextLabel")
footerStatus.Size = UDim2.new(1, -58, 0, 12)
footerStatus.Position = UDim2.new(0, 58, 0, 34)
footerStatus.BackgroundTransparency = 1
footerStatus.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
footerStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
footerStatus.TextTransparency = 0.65
footerStatus.TextSize = 10
footerStatus.Font = Enum.Font.Gotham
footerStatus.TextXAlignment = Enum.TextXAlignment.Left
footerStatus.TextTruncate = Enum.TextTruncate.AtEnd
footerStatus.Parent = footer

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -235, 1, 0)
contentArea.Position = UDim2.new(0, 230, 0, 0)
contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
contentArea.BackgroundTransparency = 0.05
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentArea

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 6
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
contentScroll.ScrollBarImageTransparency = 0.9
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroll.Parent = contentArea

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 24)
contentPadding.PaddingBottom = UDim.new(0, 24)
contentPadding.PaddingLeft = UDim.new(0, 24)
contentPadding.PaddingRight = UDim.new(0, 24)
contentPadding.Parent = contentScroll

-- UI Library
local Library = {}
Library.Tabs = {}
Library.CurrentTab = nil
Library.HeaderSubtitle = headerSubtitle

function Library:CreateTab(title, icon)
	local tabData = {
		Title = title,
		Icon = icon,
		Elements = {},
		Container = nil,
		Button = nil
	}

	table.insert(self.Tabs, tabData)

	-- Create nav button
	local navButton = Instance.new("TextButton")
	navButton.Size = UDim2.new(1, -8, 0, 42)
	navButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	navButton.BackgroundTransparency = 1
	navButton.BorderSizePixel = 0
	navButton.Text = ""
	navButton.AutoButtonColor = false
	navButton.Parent = navItems

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = navButton

	local buttonIcon = Instance.new("ImageLabel")
	buttonIcon.Size = UDim2.new(0, 18, 0, 18)
	buttonIcon.Position = UDim2.new(0, 12, 0.5, -9)
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Image = icon or ""
	buttonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	buttonIcon.ImageTransparency = 0.3
	buttonIcon.Parent = navButton

	local buttonLabel = Instance.new("TextLabel")
	buttonLabel.Size = UDim2.new(1, -42, 1, 0)
	buttonLabel.Position = UDim2.new(0, 42, 0, 0)
	buttonLabel.BackgroundTransparency = 1
	buttonLabel.Text = title
	buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	buttonLabel.TextTransparency = 0.5
	buttonLabel.TextSize = 13
	buttonLabel.Font = Enum.Font.GothamMedium
	buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
	buttonLabel.Parent = navButton

	-- Create content container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = contentScroll

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Padding = UDim.new(0, 0)
	containerLayout.Parent = container

	containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.Size = UDim2.new(1, 0, 0, containerLayout.AbsoluteContentSize.Y)
	end)

	tabData.Container = container
	tabData.Button = navButton

	-- Set first tab as active
	if #self.Tabs == 1 then
		self:SelectTab(tabData)
	end

	-- Button click
	navButton.MouseButton1Click:Connect(function()
		self:SelectTab(tabData)
	end)

	-- Hover effects
	navButton.MouseEnter:Connect(function()
		if self.CurrentTab ~= tabData then
			TweenService:Create(navButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.96}):Play()
			TweenService:Create(buttonLabel, TweenInfo.new(0.15), {TextTransparency = 0.2}):Play()
			TweenService:Create(buttonIcon, TweenInfo.new(0.15), {ImageTransparency = 0.2}):Play()
		end
	end)

	navButton.MouseLeave:Connect(function()
		if self.CurrentTab ~= tabData then
			TweenService:Create(navButton, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			TweenService:Create(buttonLabel, TweenInfo.new(0.15), {TextTransparency = 0.5}):Play()
			TweenService:Create(buttonIcon, TweenInfo.new(0.15), {ImageTransparency = 0.3}):Play()
		end
	end)

	local TabAPI = {}
	tabData.CurrentSection = nil

	function TabAPI:AddSection(title)
		local section = Instance.new("Frame")
		section.Size = UDim2.new(1, 0, 0, 0)
		section.BackgroundTransparency = 1
		section.Parent = container

		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sectionLayout.Padding = UDim.new(0, 0)
		sectionLayout.Parent = section

		sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			section.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 28)
		end)

		local sectionTitle = Instance.new("TextLabel")
		sectionTitle.Size = UDim2.new(1, 0, 0, 16)
		sectionTitle.BackgroundTransparency = 1
		sectionTitle.Text = string.upper(title)
		sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		sectionTitle.TextTransparency = 0.5
		sectionTitle.TextSize = 13
		sectionTitle.Font = Enum.Font.GothamBold
		sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
		sectionTitle.LayoutOrder = 0
		sectionTitle.Parent = section

		local spacer = Instance.new("Frame")
		spacer.Size = UDim2.new(1, 0, 0, 16)
		spacer.BackgroundTransparency = 1
		spacer.LayoutOrder = 1
		spacer.Parent = section

		tabData.CurrentSection = section
		return section
	end

	function TabAPI:AddToggle(label, callback)
		local section = tabData.CurrentSection or container

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 45)
		row.BackgroundTransparency = 1
		row.LayoutOrder = #section:GetChildren()
		row.Parent = section

		local border = Instance.new("Frame")
		border.Size = UDim2.new(1, 0, 0, 1)
		border.Position = UDim2.new(0, 0, 1, 0)
		border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		border.BackgroundTransparency = 0.96
		border.BorderSizePixel = 0
		border.Parent = row

		local labelText = Instance.new("TextLabel")
		labelText.Size = UDim2.new(1, -110, 1, 0)
		labelText.Position = UDim2.new(0, 0, 0, 0)
		labelText.BackgroundTransparency = 1
		labelText.Text = label
		labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
		labelText.TextTransparency = 0.15
		labelText.TextSize = 13
		labelText.Font = Enum.Font.Gotham
		labelText.TextXAlignment = Enum.TextXAlignment.Left
		labelText.Parent = row

		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 36, 0, 20)
		toggleButton.Position = UDim2.new(1, -100, 0.5, -10)
		toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.AutoButtonColor = false
		toggleButton.Parent = row

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0.5, 0)
		toggleCorner.Parent = toggleButton

		local toggleShadow = Instance.new("UIStroke")
		toggleShadow.Color = Color3.fromRGB(0, 0, 0)
		toggleShadow.Transparency = 0.6
		toggleShadow.Thickness = 1
		toggleShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		toggleShadow.Parent = toggleButton

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = UDim2.new(0, 3, 0.5, -7)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = toggleButton

		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		local knobShadow = Instance.new("UIStroke")
		knobShadow.Color = Color3.fromRGB(0, 0, 0)
		knobShadow.Transparency = 0.7
		knobShadow.Thickness = 1
		knobShadow.Parent = knob

		local toggled = false

		toggleButton.MouseButton1Click:Connect(function()
			toggled = not toggled

			if toggled then
				TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundColor3 = Color3.fromRGB(91, 124, 255)
				}):Play()
				TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Position = UDim2.new(1, -17, 0.5, -7)
				}):Play()
			else
				TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundColor3 = Color3.fromRGB(60, 60, 70)
				}):Play()
				TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Position = UDim2.new(0, 3, 0.5, -7)
				}):Play()
			end

			if callback then
				callback(toggled)
			end
		end)
	end

	function TabAPI:AddSlider(label, min, max, default, callback)
		local section = tabData.CurrentSection or container

		local sliderContainer = Instance.new("Frame")
		sliderContainer.Size = UDim2.new(1, 0, 0, 50)
		sliderContainer.BackgroundTransparency = 1
		sliderContainer.LayoutOrder = #section:GetChildren()
		sliderContainer.Parent = section

		local sliderHeader = Instance.new("Frame")
		sliderHeader.Size = UDim2.new(1, 0, 0, 20)
		sliderHeader.BackgroundTransparency = 1
		sliderHeader.Parent = sliderContainer

		local sliderLabel = Instance.new("TextLabel")
		sliderLabel.Size = UDim2.new(1, -80, 1, 0)
		sliderLabel.BackgroundTransparency = 1
		sliderLabel.Text = label
		sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		sliderLabel.TextTransparency = 0.15
		sliderLabel.TextSize = 13
		sliderLabel.Font = Enum.Font.Gotham
		sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
		sliderLabel.Parent = sliderHeader

		local sliderValue = Instance.new("TextLabel")
		sliderValue.Size = UDim2.new(0, 30, 1, 0)
		sliderValue.Position = UDim2.new(1, -30, 0, 0)
		sliderValue.BackgroundTransparency = 1
		sliderValue.Text = tostring(default)
		sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
		sliderValue.TextTransparency = 0.5
		sliderValue.TextSize = 12
		sliderValue.Font = Enum.Font.Gotham
		sliderValue.TextXAlignment = Enum.TextXAlignment.Right
		sliderValue.Parent = sliderHeader

		local trackFrame = Instance.new("Frame")
		trackFrame.Size = UDim2.new(1, -20, 0, 20)
		trackFrame.Position = UDim2.new(0, 10, 0, 30)
		trackFrame.BackgroundTransparency = 1
		trackFrame.Parent = sliderContainer

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, 0, 0, 4)
		track.Position = UDim2.new(0, 0, 0.5, -2)
		track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		track.BorderSizePixel = 0
		track.Parent = trackFrame

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 2)
		trackCorner.Parent = track

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(91, 124, 255)
		fill.BorderSizePixel = 0
		fill.Parent = track

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 2)
		fillCorner.Parent = fill

		local thumb = Instance.new("Frame")
		thumb.Size = UDim2.new(0, 14, 0, 14)
		thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
		thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		thumb.BorderSizePixel = 0
		thumb.Parent = trackFrame

		local thumbCorner = Instance.new("UICorner")
		thumbCorner.CornerRadius = UDim.new(1, 0)
		thumbCorner.Parent = thumb

		local thumbShadow = Instance.new("UIStroke")
		thumbShadow.Color = Color3.fromRGB(0, 0, 0)
		thumbShadow.Transparency = 0.7
		thumbShadow.Thickness = 2
		thumbShadow.Parent = thumb

		local dragging = false

		local function updateSlider(input)
			local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local value = math.floor(min + (max - min) * pos)

			fill.Size = UDim2.new(pos, 0, 1, 0)
			thumb.Position = UDim2.new(pos, -7, 0.5, -7)
			sliderValue.Text = tostring(value)

			if callback then
				callback(value)
			end
		end

		thumb.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)

		thumb.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateSlider(input)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	function TabAPI:AddDropdown(label, options, callback)
		local section = tabData.CurrentSection or container

		local dropdownContainer = Instance.new("Frame")
		dropdownContainer.Size = UDim2.new(1, 0, 0, 55)
		dropdownContainer.BackgroundTransparency = 1
		dropdownContainer.LayoutOrder = #section:GetChildren()
		dropdownContainer.Parent = section

		local dropdownButton = Instance.new("TextButton")
		dropdownButton.Size = UDim2.new(1, 0, 0, 47)
		dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownButton.BackgroundTransparency = 0.97
		dropdownButton.BorderSizePixel = 0
		dropdownButton.Text = ""
		dropdownButton.AutoButtonColor = false
		dropdownButton.Parent = dropdownContainer

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = dropdownButton

		local dropLabel = Instance.new("TextLabel")
		dropLabel.Size = UDim2.new(1, -60, 0, 18)
		dropLabel.Position = UDim2.new(0, 16, 0, 8)
		dropLabel.BackgroundTransparency = 1
		dropLabel.Text = label
		dropLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		dropLabel.TextTransparency = 0.15
		dropLabel.TextSize = 13
		dropLabel.Font = Enum.Font.Gotham
		dropLabel.TextXAlignment = Enum.TextXAlignment.Left
		dropLabel.Parent = dropdownButton

		local dropValue = Instance.new("TextLabel")
		dropValue.Size = UDim2.new(1, -60, 0, 15)
		dropValue.Position = UDim2.new(0, 16, 0, 26)
		dropValue.BackgroundTransparency = 1
		dropValue.Text = options[1] or ""
		dropValue.TextColor3 = Color3.fromRGB(255, 255, 255)
		dropValue.TextTransparency = 0.5
		dropValue.TextSize = 12
		dropValue.Font = Enum.Font.Gotham
		dropValue.TextXAlignment = Enum.TextXAlignment.Left
		dropValue.Parent = dropdownButton

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 20, 0, 20)
		arrow.Position = UDim2.new(1, -30, 0.5, -10)
		arrow.BackgroundTransparency = 1
		arrow.Text = "▼"
		arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		arrow.TextTransparency = 0.6
		arrow.TextSize = 12
		arrow.Font = Enum.Font.Gotham
		arrow.Parent = dropdownButton

		local menu = Instance.new("Frame")
		menu.Size = UDim2.new(1, 0, 0, 0)
		menu.Position = UDim2.new(0, 0, 0, 47)
		menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		menu.BackgroundTransparency = 0.96
		menu.BorderSizePixel = 0
		menu.Visible = false
		menu.ClipsDescendants = true
		menu.Parent = dropdownContainer

		local menuCorner = Instance.new("UICorner")
		menuCorner.CornerRadius = UDim.new(0, 8)
		menuCorner.Parent = menu
		local menuBorder = Instance.new("Frame")
		menuBorder.Size = UDim2.new(1, 0, 0, 1)
		menuBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		menuBorder.BackgroundTransparency = 0.95
		menuBorder.BorderSizePixel = 0
		menuBorder.Parent = menu

		local menuScroll = Instance.new("ScrollingFrame")
		menuScroll.Size = UDim2.new(1, 0, 1, 0)
		menuScroll.BackgroundTransparency = 1
		menuScroll.BorderSizePixel = 0
		menuScroll.ScrollBarThickness = 4
		menuScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		menuScroll.ScrollBarImageTransparency = 0.9
		menuScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 34)
		menuScroll.Parent = menu

		local menuLayout = Instance.new("UIListLayout")
		menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
		menuLayout.Padding = UDim.new(0, 0)
		menuLayout.Parent = menuScroll

		local isOpen = false

		for i, option in ipairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, 0, 0, 34)
			optionButton.BackgroundTransparency = 1
			optionButton.BorderSizePixel = 0
			optionButton.Text = ""
			optionButton.AutoButtonColor = false
			optionButton.Parent = menuScroll

			local optionLabel = Instance.new("TextLabel")
			optionLabel.Size = UDim2.new(1, -32, 1, 0)
			optionLabel.Position = UDim2.new(0, 16, 0, 0)
			optionLabel.BackgroundTransparency = 1
			optionLabel.Text = option
			optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			optionLabel.TextTransparency = 0.3
			optionLabel.TextSize = 12
			optionLabel.Font = Enum.Font.Gotham
			optionLabel.TextXAlignment = Enum.TextXAlignment.Left
			optionLabel.Parent = optionButton

			if i == 1 then
				optionButton.BackgroundColor3 = Color3.fromRGB(92, 124, 255)
				optionButton.BackgroundTransparency = 0.85
				optionLabel.TextColor3 = Color3.fromRGB(124, 92, 255)
				optionLabel.TextTransparency = 0
			end

			optionButton.MouseEnter:Connect(function()
				TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.94}):Play()
				TweenService:Create(optionLabel, TweenInfo.new(0.1), {TextTransparency = 0.05}):Play()
			end)

			optionButton.MouseLeave:Connect(function()
				if dropValue.Text ~= option then
					TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
					TweenService:Create(optionLabel, TweenInfo.new(0.1), {TextTransparency = 0.3}):Play()
				end
			end)

			optionButton.MouseButton1Click:Connect(function()
				for _, btn in ipairs(menuScroll:GetChildren()) do
					if btn:IsA("TextButton") then
						btn.BackgroundTransparency = 1
						btn:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(255, 255, 255)
						btn:FindFirstChildOfClass("TextLabel").TextTransparency = 0.3
					end
				end

				optionButton.BackgroundColor3 = Color3.fromRGB(92, 124, 255)
				optionButton.BackgroundTransparency = 0.85
				optionLabel.TextColor3 = Color3.fromRGB(124, 92, 255)
				optionLabel.TextTransparency = 0
				dropValue.Text = option

				isOpen = false
				TweenService:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
				task.wait(0.2)
				menu.Visible = false
				dropdownContainer.Size = UDim2.new(1, 0, 0, 55)

				if callback then
					callback(option)
				end
			end)
		end

		dropdownButton.MouseButton1Click:Connect(function()
			isOpen = not isOpen

			if isOpen then
				menu.Visible = true
				local menuHeight = math.min(#options * 34, 200)
				TweenService:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, menuHeight)}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
				TweenService:Create(buttonCorner, TweenInfo.new(0.2), {CornerRadius = UDim.new(0, 8)}):Play()
				dropdownContainer.Size = UDim2.new(1, 0, 0, 55 + menuHeight)
			else
				TweenService:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
				task.wait(0.2)
				menu.Visible = false
				dropdownContainer.Size = UDim2.new(1, 0, 0, 55)
			end
		end)

		dropdownButton.MouseEnter:Connect(function()
			TweenService:Create(dropdownButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.95}):Play()
		end)

		dropdownButton.MouseLeave:Connect(function()
			if not isOpen then
				TweenService:Create(dropdownButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.97}):Play()
			end
		end)
	end

	function TabAPI:AddButton(label, callback)
		local section = tabData.CurrentSection or container

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 47)
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundTransparency = 0.97
		button.BorderSizePixel = 0
		button.Text = ""
		button.AutoButtonColor = false
		button.LayoutOrder = #section:GetChildren()
		button.Parent = section

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button

		local buttonLabel = Instance.new("TextLabel")
		buttonLabel.Size = UDim2.new(1, -50, 1, 0)
		buttonLabel.Position = UDim2.new(0, 16, 0, 0)
		buttonLabel.BackgroundTransparency = 1
		buttonLabel.Text = label
		buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		buttonLabel.TextTransparency = 0.15
		buttonLabel.TextSize = 13
		buttonLabel.Font = Enum.Font.Gotham
		buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
		buttonLabel.Parent = button

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(1, -30, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "›"
		arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		arrow.TextTransparency = 0.7
		arrow.TextSize = 14
		arrow.Font = Enum.Font.Gotham
		arrow.Parent = button

		local spacer = Instance.new("Frame")
		spacer.Size = UDim2.new(1, 0, 0, 8)
		spacer.BackgroundTransparency = 1
		spacer.LayoutOrder = #section:GetChildren() + 1
		spacer.Parent = section

		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 0.95}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 0.97}):Play()
		end)

		button.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)
	end

	return TabAPI
end
function Library:SelectTab(tabData)
	for _, tab in ipairs(self.Tabs) do
		tab.Container.Visible = false
		TweenService:Create(tab.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
		TweenService:Create(tab.Button:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.15), {TextTransparency = 0.5}):Play()
		TweenService:Create(tab.Button:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.15), {ImageTransparency = 0.3}):Play()
	end
	tabData.Container.Visible = true
	TweenService:Create(tabData.Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.92}):Play()
	TweenService:Create(tabData.Button:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.15), {TextTransparency = 0}):Play()
	TweenService:Create(tabData.Button:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.15), {ImageTransparency = 0}):Play()

	self.CurrentTab = tabData
end

return Library
