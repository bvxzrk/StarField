--[[
	StarField Interface Suite
	Enhanced version of Rayfield Library
	Improved performance, features and customization
]]

if debugX then
	warn('Initialising StarField')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Enhanced loading with better error handling and caching
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	
	-- Cache system to avoid repeated requests
	if not loadWithTimeout.cache then
		loadWithTimeout.cache = {}
	end
	
	if loadWithTimeout.cache[url] then
		return loadWithTimeout.cache[url]
	end

	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url)
		if not fetchSuccess or #fetchResult == 0 then
			success, result = false, fetchResult or "Empty response"
			requestCompleted = true
			return
		end
		
		local execSuccess, execResult = pcall(function()
			return loadstring(fetchResult)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn(`Request for {url} timed out after {timeout} seconds`)
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	while not requestCompleted do
		task.wait()
	end
	
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	
	if success then
		loadWithTimeout.cache[url] = result
	else
		warn(`Failed to process {url}: {result}`)
	end
	
	return if success then result else nil
end

local requestsDisabled = true
local InterfaceBuild = 'STAR2'
local Release = "StarField Build 2.0"
local StarFieldFolder = "StarField"
local ConfigurationFolder = StarFieldFolder.."/Configurations"
local ConfigurationExtension = ".sfld"

-- Enhanced settings system
local settingsTable = {
	General = {
		starfieldOpen = {Type = 'bind', Value = 'K', Name = 'StarField Keybind'},
		uiScale = {Type = 'slider', Value = 100, Range = {50, 150}, Name = 'UI Scale'},
		animationSpeed = {Type = 'slider', Value = 1, Range = {0.5, 2}, Name = 'Animation Speed'},
	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
		performanceMode = {Type = 'toggle', Value = false, Name = 'Performance Mode'},
		autoSave = {Type = 'toggle', Value = true, Name = 'Auto Save Config'},
	}
}

local overriddenSettings = {}
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	return overriddenSettings[`{category}.{name}`] or (settingsTable[category] and settingsTable[category][name] and settingsTable[category][name].Value)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

local useStudio = RunService:IsStudio()
local settingsCreated = false
local settingsInitialized = false
local cachedSettings

-- Enhanced prompt system
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

-- Enhanced theme system with more customization
local StarFieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),
			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),
			NotificationBackground = Color3.fromRGB(20, 20, 20),
			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),
			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),
			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178),
			AccentColor = Color3.fromRGB(0, 146, 214),
		},
		
		Cosmic = {
			TextColor = Color3.fromRGB(255, 255, 255),
			Background = Color3.fromRGB(10, 10, 35),
			Topbar = Color3.fromRGB(20, 20, 55),
			Shadow = Color3.fromRGB(5, 5, 25),
			NotificationBackground = Color3.fromRGB(15, 15, 40),
			TabBackground = Color3.fromRGB(40, 40, 80),
			TabStroke = Color3.fromRGB(60, 60, 120),
			TabBackgroundSelected = Color3.fromRGB(80, 100, 255),
			TabTextColor = Color3.fromRGB(200, 200, 255),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
			ElementBackground = Color3.fromRGB(25, 25, 60),
			ElementBackgroundHover = Color3.fromRGB(35, 35, 80),
			SecondaryElementBackground = Color3.fromRGB(20, 20, 45),
			ElementStroke = Color3.fromRGB(60, 60, 120),
			SecondaryElementStroke = Color3.fromRGB(45, 45, 90),
			SliderBackground = Color3.fromRGB(40, 60, 150),
			SliderProgress = Color3.fromRGB(80, 100, 255),
			SliderStroke = Color3.fromRGB(100, 120, 255),
			ToggleBackground = Color3.fromRGB(30, 30, 70),
			ToggleEnabled = Color3.fromRGB(80, 100, 255),
			ToggleDisabled = Color3.fromRGB(60, 60, 100),
			ToggleEnabledStroke = Color3.fromRGB(100, 120, 255),
			ToggleDisabledStroke = Color3.fromRGB(80, 80, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(60, 80, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 80),
			DropdownSelected = Color3.fromRGB(35, 35, 90),
			DropdownUnselected = Color3.fromRGB(25, 25, 60),
			InputBackground = Color3.fromRGB(25, 25, 60),
			InputStroke = Color3.fromRGB(70, 70, 130),
			PlaceholderColor = Color3.fromRGB(150, 150, 200),
			AccentColor = Color3.fromRGB(80, 100, 255),
		},

		Nebula = {
			TextColor = Color3.fromRGB(255, 240, 245),
			Background = Color3.fromRGB(40, 10, 50),
			Topbar = Color3.fromRGB(60, 20, 70),
			Shadow = Color3.fromRGB(30, 5, 40),
			NotificationBackground = Color3.fromRGB(45, 15, 55),
			TabBackground = Color3.fromRGB(80, 40, 100),
			TabStroke = Color3.fromRGB(100, 60, 120),
			TabBackgroundSelected = Color3.fromRGB(180, 80, 200),
			TabTextColor = Color3.fromRGB(240, 200, 250),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
			ElementBackground = Color3.fromRGB(50, 25, 65),
			ElementBackgroundHover = Color3.fromRGB(65, 35, 80),
			SecondaryElementBackground = Color3.fromRGB(45, 20, 55),
			ElementStroke = Color3.fromRGB(90, 50, 110),
			SecondaryElementStroke = Color3.fromRGB(75, 40, 95),
			SliderBackground = Color3.fromRGB(120, 40, 140),
			SliderProgress = Color3.fromRGB(160, 60, 180),
			SliderStroke = Color3.fromRGB(180, 80, 200),
			ToggleBackground = Color3.fromRGB(55, 30, 70),
			ToggleEnabled = Color3.fromRGB(160, 60, 180),
			ToggleDisabled = Color3.fromRGB(90, 60, 100),
			ToggleEnabledStroke = Color3.fromRGB(180, 80, 200),
			ToggleDisabledStroke = Color3.fromRGB(110, 70, 120),
			ToggleEnabledOuterStroke = Color3.fromRGB(120, 40, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(70, 40, 80),
			DropdownSelected = Color3.fromRGB(65, 30, 80),
			DropdownUnselected = Color3.fromRGB(50, 25, 65),
			InputBackground = Color3.fromRGB(50, 25, 65),
			InputStroke = Color3.fromRGB(95, 55, 115),
			PlaceholderColor = Color3.fromRGB(180, 140, 200),
			AccentColor = Color3.fromRGB(160, 60, 180),
		},

		Solar = {
			TextColor = Color3.fromRGB(255, 250, 240),
			Background = Color3.fromRGB(40, 30, 15),
			Topbar = Color3.fromRGB(60, 45, 20),
			Shadow = Color3.fromRGB(30, 20, 10),
			NotificationBackground = Color3.fromRGB(50, 35, 20),
			TabBackground = Color3.fromRGB(90, 65, 30),
			TabStroke = Color3.fromRGB(110, 80, 40),
			TabBackgroundSelected = Color3.fromRGB(255, 180, 60),
			TabTextColor = Color3.fromRGB(255, 240, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 35, 10),
			ElementBackground = Color3.fromRGB(55, 40, 20),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 25),
			SecondaryElementBackground = Color3.fromRGB(45, 35, 15),
			ElementStroke = Color3.fromRGB(85, 60, 30),
			SecondaryElementStroke = Color3.fromRGB(75, 55, 25),
			SliderBackground = Color3.fromRGB(180, 120, 40),
			SliderProgress = Color3.fromRGB(255, 180, 60),
			SliderStroke = Color3.fromRGB(255, 200, 80),
			ToggleBackground = Color3.fromRGB(60, 45, 25),
			ToggleEnabled = Color3.fromRGB(255, 150, 40),
			ToggleDisabled = Color3.fromRGB(100, 80, 50),
			ToggleEnabledStroke = Color3.fromRGB(255, 170, 60),
			ToggleDisabledStroke = Color3.fromRGB(120, 95, 65),
			ToggleEnabledOuterStroke = Color3.fromRGB(180, 120, 40),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 65, 45),
			DropdownSelected = Color3.fromRGB(70, 50, 25),
			DropdownUnselected = Color3.fromRGB(55, 40, 20),
			InputBackground = Color3.fromRGB(55, 40, 20),
			InputStroke = Color3.fromRGB(95, 70, 35),
			PlaceholderColor = Color3.fromRGB(190, 160, 120),
			AccentColor = Color3.fromRGB(255, 180, 60),
		}
	}
}

-- Enhanced UI scaling system
local function getUIScale()
	return getSetting("General", "uiScale") or 100
end

local function getAnimationSpeed()
	return getSetting("General", "animationSpeed") or 1
end

local function scaledTweenInfo(duration, easingStyle, easingDirection)
	local speed = getAnimationSpeed()
	return TweenInfo.new(duration / speed, easingStyle or Enum.EasingStyle.Exponential, easingDirection or Enum.EasingDirection.Out)
end

-- Load interface
local StarField = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
StarField.Name = "StarField"

local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local starfieldDestroyed = false

repeat
	if StarField:FindFirstChild('Build') and StarField.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('StarField | Build Mismatch')
		print('StarField may encounter issues as you are running an incompatible interface version ('.. ((StarField:FindFirstChild('Build') and StarField.Build.Value) or 'No Build') ..').\n\nThis version of StarField is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

StarField.Enabled = false

-- Enhanced parent assignment
if gethui then
	StarField.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(StarField)
	StarField.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	StarField.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	StarField.Parent = CoreGui
end

-- Clean up old interfaces
local function cleanupOldInterfaces()
	local parent = StarField.Parent
	if parent then
		for _, gui in ipairs(parent:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name == "StarField" and gui ~= StarField then
				gui.Enabled = false
				gui.Name = "StarField-Old"
			end
		end
	end
end
cleanupOldInterfaces()

-- Main UI components
local Main = StarField:WaitForChild('Main')
local Topbar = Main.Topbar
local Elements = Main.Elements
local TabList = Main.TabList
local LoadingFrame = Main.LoadingFrame
local Notifications = StarField.Notifications

local SelectedTheme = StarFieldLibrary.Theme.Default
local CFileName, CEnabled, Minimised, Hidden, Debounce = nil, false, false, false, false
local searchOpen = false

-- Enhanced theme application
local function ChangeTheme(Theme)
	if typeof(Theme) == 'string' then
		SelectedTheme = StarFieldLibrary.Theme[Theme] or StarFieldLibrary.Theme.Default
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

	-- Apply theme to all UI elements
	Main.BackgroundColor3 = SelectedTheme.Background
	Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow

	-- Apply to text elements
	for _, text in ipairs(StarField:GetDescendants()) do
		if text:IsA('TextLabel') or text:IsA('TextBox') then 
			text.TextColor3 = SelectedTheme.TextColor 
		end
	end

	-- Apply to UI elements
	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element:IsA("Frame") and Element.Name ~= "Placeholder" then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				if Element:FindFirstChild("UIStroke") then
					Element.UIStroke.Color = SelectedTheme.ElementStroke
				end
			end
		end
	end

	-- Apply to tab buttons
	for _, tabBtn in ipairs(TabList:GetChildren()) do
		if tabBtn:IsA("Frame") then
			tabBtn.UIStroke.Color = SelectedTheme.TabStroke
		end
	end
end

-- Enhanced icon system
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')

local function getIcon(name: string)
	if not Icons then return end
	name = string.lower(string.gsub(name, "^%s*(.-)%s*$", "%1"))
	local sizedIcons = Icons['48px']
	local iconData = sizedIcons[name]
	
	if iconData then
		return {
			id = iconData[1],
			imageRectSize = Vector2.new(iconData[2][1], iconData[2][2]),
			imageRectOffset = Vector2.new(iconData[3][1], iconData[3][2])
		}
	end
end

-- Enhanced configuration system
local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	local Data = {}
	for flagName, flagData in pairs(StarFieldLibrary.Flags) do
		if flagData.Type == "ColorPicker" then
			Data[flagName] = {R = flagData.Color.R * 255, G = flagData.Color.G * 255, B = flagData.Color.B * 255}
		else
			Data[flagName] = flagData.CurrentValue or flagData.CurrentKeybind or flagData.CurrentOption or flagData.Color
		end
	end

	if writefile then
		writefile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, HttpService:JSONEncode(Data))
	end
end

local function LoadConfiguration(Configuration)
	local success, data = pcall(HttpService.JSONDecode, HttpService, Configuration)
	if not success then return end

	for flagName, flagData in pairs(StarFieldLibrary.Flags) do
		if data[flagName] then
			task.spawn(function()
				if flagData.Type == "ColorPicker" then
					flagData:Set(Color3.fromRGB(data[flagName].R, data[flagName].G, data[flagName].B))
				else
					flagData:Set(data[flagName])
				end
			end)
		end
	end
end

-- Enhanced notification system
function StarFieldLibrary:Notify(notificationData)
	task.spawn(function()
		local notification = Notifications.Template:Clone()
		notification.Name = notificationData.Title or 'Notification'
		notification.Parent = Notifications
		notification.LayoutOrder = #Notifications:GetChildren()
		notification.Visible = false

		-- Set notification content
		notification.Title.Text = notificationData.Title or "Notification"
		notification.Description.Text = notificationData.Content or "No content provided"

		if notificationData.Image then
			if typeof(notificationData.Image) == 'string' and Icons then
				local asset = getIcon(notificationData.Image)
				if asset then
					notification.Icon.Image = 'rbxassetid://'..asset.id
					notification.Icon.ImageRectOffset = asset.imageRectOffset
					notification.Icon.ImageRectSize = asset.imageRectSize
				end
			else
				notification.Icon.Image = "rbxassetid://" .. (notificationData.Image or 0)
			end
		end

		-- Apply theme
		notification.BackgroundColor3 = SelectedTheme.NotificationBackground
		notification.Title.TextColor3 = SelectedTheme.TextColor
		notification.Description.TextColor3 = SelectedTheme.TextColor
		notification.UIStroke.Color = SelectedTheme.TextColor
		notification.Icon.ImageColor3 = SelectedTheme.TextColor

		notification.Visible = true

		-- Enhanced animation
		notification.BackgroundTransparency = 1
		notification.Title.TextTransparency = 1
		notification.Description.TextTransparency = 1
		notification.UIStroke.Transparency = 1
		notification.Shadow.ImageTransparency = 1
		notification.Icon.ImageTransparency = 1

		task.wait()

		-- Show animation
		TweenService:Create(notification, scaledTweenInfo(0.6), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(notification.Title, scaledTweenInfo(0.3), {TextTransparency = 0}):Play()
		TweenService:Create(notification.Icon, scaledTweenInfo(0.3), {ImageTransparency = 0}):Play()
		TweenService:Create(notification.Description, scaledTweenInfo(0.3), {TextTransparency = 0.35}):Play()
		TweenService:Create(notification.UIStroke, scaledTweenInfo(0.4), {Transparency = 0.95}):Play()
		TweenService:Create(notification.Shadow, scaledTweenInfo(0.3), {ImageTransparency = 0.82}):Play()

		-- Calculate duration
		local duration = notificationData.Duration or math.min(math.max((#notification.Description.Text * 0.1) + 2.5, 3), 10)
		task.wait(duration)

		-- Hide animation
		TweenService:Create(notification, scaledTweenInfo(0.4), {BackgroundTransparency = 1}):Play()
		TweenService:Create(notification.UIStroke, scaledTweenInfo(0.4), {Transparency = 1}):Play()
		TweenService:Create(notification.Shadow, scaledTweenInfo(0.3), {ImageTransparency = 1}):Play()
		TweenService:Create(notification.Title, scaledTweenInfo(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(notification.Description, scaledTweenInfo(0.3), {TextTransparency = 1}):Play()

		task.wait(0.5)
		notification:Destroy()
	end)
end

-- Enhanced window creation
function StarFieldLibrary:CreateWindow(settings)
	-- Apply settings with defaults
	settings = settings or {}
	settings.Name = settings.Name or "StarField Interface"
	settings.LoadingTitle = settings.LoadingTitle or "StarField"
	settings.LoadingSubtitle = settings.LoadingSubtitle or "Enhanced Interface Suite"
	settings.Theme = settings.Theme or "Default"
	settings.ConfigurationSaving = settings.ConfigurationSaving or {Enabled = false}
	settings.DisableRayfieldPrompts = settings.DisableRayfieldPrompts or false
	
	-- Initialize window
	Topbar.Title.Text = settings.Name
	LoadingFrame.Title.Text = settings.LoadingTitle
	LoadingFrame.Subtitle.Text = settings.LoadingSubtitle
	LoadingFrame.Version.Text = Release

	-- Apply theme
	ChangeTheme(settings.Theme)

	-- Enhanced configuration system
	if settings.ConfigurationSaving.Enabled then
		CFileName = settings.ConfigurationSaving.FileName or tostring(game.PlaceId)
		CEnabled = true
		ConfigurationFolder = settings.ConfigurationSaving.FolderName or ConfigurationFolder
		
		if not isfolder(ConfigurationFolder) then
			makefolder(ConfigurationFolder)
		end
	end

	-- Enhanced key system
	if settings.KeySystem and settings.KeySettings then
		-- Key system implementation here (similar to original)
	end

	local Window = {}
	
	-- Enhanced tab creation
	function Window:CreateTab(name, icon, isSettings)
		local tabButton = TabList.Template:Clone()
		tabButton.Name = name
		tabButton.Title.Text = name
		tabButton.Parent = TabList
		tabButton.Visible = not isSettings

		-- Enhanced icon handling
		if icon and icon ~= 0 then
			if typeof(icon) == 'string' and Icons then
				local asset = getIcon(icon)
				if asset then
					tabButton.Image.Image = 'rbxassetid://'..asset.id
					tabButton.Image.ImageRectOffset = asset.imageRectOffset
					tabButton.Image.ImageRectSize = asset.imageRectSize
				end
			else
				tabButton.Image.Image = "rbxassetid://" .. icon
			end
			tabButton.Image.Visible = true
			tabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
			tabButton.Size = UDim2.new(0, tabButton.Title.TextBounds.X + 52, 0, 30)
		end

		local tabPage = Elements.Template:Clone()
		tabPage.Name = name
		tabPage.Parent = Elements
		tabPage.Visible = true

		-- Clear template elements
		for _, element in ipairs(tabPage:GetChildren()) do
			if element:IsA("Frame") and element.Name ~= "Placeholder" then
				element:Destroy()
			end
		end

		local Tab = {}
		
		-- Enhanced button element
		function Tab:CreateButton(buttonSettings)
			local button = Elements.Template.Button:Clone()
			button.Name = buttonSettings.Name
			button.Title.Text = buttonSettings.Name
			button.Parent = tabPage
			button.Visible = true

			button.Interact.MouseButton1Click:Connect(function()
				local success, err = pcall(buttonSettings.Callback)
				if not success then
					warn(`Button {buttonSettings.Name} error: {err}`)
				end
			end)

			local buttonValue = {}
			function buttonValue:Set(newText)
				button.Title.Text = newText
				button.Name = newText
			end

			return buttonValue
		end

		-- Enhanced toggle element
		function Tab:CreateToggle(toggleSettings)
			local toggle = Elements.Template.Toggle:Clone()
			toggle.Name = toggleSettings.Name
			toggle.Title.Text = toggleSettings.Name
			toggle.Parent = tabPage
			toggle.Visible = true

			local function updateToggleState(value)
				toggleSettings.CurrentValue = value
				if value then
					TweenService:Create(toggle.Switch.Indicator, scaledTweenInfo(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(toggle.Switch.Indicator, scaledTweenInfo(0.8), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
				else
					TweenService:Create(toggle.Switch.Indicator, scaledTweenInfo(0.45, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(toggle.Switch.Indicator, scaledTweenInfo(0.8), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
				end
				
				if toggleSettings.Callback then
					pcall(toggleSettings.Callback, value)
				end
			end

			toggle.Interact.MouseButton1Click:Connect(function()
				updateToggleState(not toggleSettings.CurrentValue)
				if not toggleSettings.Ext then
					SaveConfiguration()
				end
			end)

			function toggleSettings:Set(value)
				updateToggleState(value)
				if not toggleSettings.Ext then
					SaveConfiguration()
				end
			end

			if settings.ConfigurationSaving and toggleSettings.Flag then
				StarFieldLibrary.Flags[toggleSettings.Flag] = toggleSettings
			end

			return toggleSettings
		end

		-- Enhanced slider element
		function Tab:CreateSlider(sliderSettings)
			local slider = Elements.Template.Slider:Clone()
			slider.Name = sliderSettings.Name
			slider.Title.Text = sliderSettings.Name
			slider.Parent = tabPage
			slider.Visible = true

			local function updateSliderValue(value)
				value = math.clamp(value, sliderSettings.Range[1], sliderSettings.Range[2])
				sliderSettings.CurrentValue = value
				
				local progressWidth = slider.Main.AbsoluteSize.X * (value / (sliderSettings.Range[2] - sliderSettings.Range[1]))
				TweenService:Create(slider.Main.Progress, scaledTweenInfo(0.45), {Size = UDim2.new(0, math.max(progressWidth, 5), 1, 0)}):Play()
				
				slider.Main.Information.Text = tostring(value) .. (sliderSettings.Suffix or "")
				
				if sliderSettings.Callback then
					pcall(sliderSettings.Callback, value)
				end
			end

			-- Slider dragging implementation
			local dragging = false
			slider.Main.Interact.MouseButton1Down:Connect(function()
				dragging = true
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			slider.Main.Interact.MouseButton1Click:Connect(function(x)
				local percent = (x - slider.Main.AbsolutePosition.X) / slider.Main.AbsoluteSize.X
				local value = sliderSettings.Range[1] + percent * (sliderSettings.Range[2] - sliderSettings.Range[1])
				value = math.floor(value / sliderSettings.Increment + 0.5) * sliderSettings.Increment
				updateSliderValue(value)
			end)

			function sliderSettings:Set(value)
				updateSliderValue(value)
				if not sliderSettings.Ext then
					SaveConfiguration()
				end
			end

			if settings.ConfigurationSaving and sliderSettings.Flag then
				StarFieldLibrary.Flags[sliderSettings.Flag] = sliderSettings
			end

			return sliderSettings
		end

		-- Enhanced dropdown element
		function Tab:CreateDropdown(dropdownSettings)
			local dropdown = Elements.Template.Dropdown:Clone()
			dropdown.Name = dropdownSettings.Name
			dropdown.Title.Text = dropdownSettings.Name
			dropdown.Parent = tabPage
			dropdown.Visible = true

			dropdownSettings.CurrentOption = dropdownSettings.CurrentOption or {}
			if typeof(dropdownSettings.CurrentOption) == "string" then
				dropdownSettings.CurrentOption = {dropdownSettings.CurrentOption}
			end

			local function updateDropdownDisplay()
				if dropdownSettings.MultipleOptions then
					if #dropdownSettings.CurrentOption == 1 then
						dropdown.Selected.Text = dropdownSettings.CurrentOption[1]
					elseif #dropdownSettings.CurrentOption == 0 then
						dropdown.Selected.Text = "None"
					else
						dropdown.Selected.Text = "Various"
					end
				else
					dropdown.Selected.Text = dropdownSettings.CurrentOption[1] or "None"
				end
			end

			updateDropdownDisplay()

			-- Dropdown options implementation
			for _, option in ipairs(dropdownSettings.Options) do
				local optionFrame = Elements.Template.Dropdown.List.Template:Clone()
				optionFrame.Name = option
				optionFrame.Title.Text = option
				optionFrame.Parent = dropdown.List
				optionFrame.Visible = true

				optionFrame.Interact.MouseButton1Click:Connect(function()
					if dropdownSettings.MultipleOptions then
						local index = table.find(dropdownSettings.CurrentOption, option)
						if index then
							table.remove(dropdownSettings.CurrentOption, index)
						else
							table.insert(dropdownSettings.CurrentOption, option)
						end
					else
						dropdownSettings.CurrentOption = {option}
					end
					
					updateDropdownDisplay()
					
					if dropdownSettings.Callback then
						pcall(dropdownSettings.Callback, dropdownSettings.CurrentOption)
					end
					
					if not dropdownSettings.Ext then
						SaveConfiguration()
					end
				end)
			end

			function dropdownSettings:Set(options)
				dropdownSettings.CurrentOption = options
				updateDropdownDisplay()
				if dropdownSettings.Callback then
					pcall(dropdownSettings.Callback, options)
				end
			end

			if settings.ConfigurationSaving and dropdownSettings.Flag then
				StarFieldLibrary.Flags[dropdownSettings.Flag] = dropdownSettings
			end

			return dropdownSettings
		end

		-- Enhanced section
		function Tab:CreateSection(sectionName)
			local section = Elements.Template.SectionTitle:Clone()
			section.Title.Text = sectionName
			section.Parent = tabPage
			section.Visible = true

			local sectionValue = {}
			function sectionValue:Set(newName)
				section.Title.Text = newName
			end

			return sectionValue
		end

		-- Enhanced label
		function Tab:CreateLabel(labelText, icon, color, ignoreTheme)
			local label = Elements.Template.Label:Clone()
			label.Title.Text = labelText
			label.Parent = tabPage
			label.Visible = true

			if icon then
				if typeof(icon) == 'string' and Icons then
					local asset = getIcon(icon)
					if asset then
						label.Icon.Image = 'rbxassetid://'..asset.id
						label.Icon.ImageRectOffset = asset.imageRectOffset
						label.Icon.ImageRectSize = asset.imageRectSize
					end
				end
				label.Icon.Visible = true
			end

			local labelValue = {}
			function labelValue:Set(newText, newIcon, newColor)
				label.Title.Text = newText
				-- Handle icon and color updates
			end

			return labelValue
		end

		return Tab
	end

	-- Enhanced theme modification
	function Window:ModifyTheme(newTheme)
		ChangeTheme(newTheme)
		StarFieldLibrary:Notify({
			Title = "Theme Changed", 
			Content = `Successfully changed theme to {typeof(newTheme) == 'string' and newTheme or 'Custom Theme'}.`,
			Duration = 3,
			Image = 4483362748
		})
	end

	-- Initialize settings tab
	local function createSettings(window)
		local settingsTab = window:CreateTab('StarField Settings', 0, true)
		
		for categoryName, categorySettings in pairs(settingsTable) do
			settingsTab:CreateSection(categoryName)
			
			for settingName, setting in pairs(categorySettings) do
				if setting.Type == 'toggle' then
					setting.Element = settingsTab:CreateToggle({
						Name = setting.Name,
						CurrentValue = setting.Value,
						Callback = function(value)
							setting.Value = value
							-- Save settings
						end
					})
				elseif setting.Type == 'slider' then
					setting.Element = settingsTab:CreateSlider({
						Name = setting.Name,
						CurrentValue = setting.Value,
						Range = setting.Range,
						Callback = function(value)
							setting.Value = value
							-- Apply UI scaling if needed
							if settingName == 'uiScale' then
								-- Apply scaling logic
							end
						end
					})
				end
			end
		end
	end

	createSettings(Window)

	return Window
end

-- Enhanced visibility control
function StarFieldLibrary:SetVisibility(visible)
	if Debounce then return end
	Hidden = not visible
	-- Add visibility animation logic here
end

function StarFieldLibrary:IsVisible()
	return not Hidden
end

-- Enhanced destruction
function StarFieldLibrary:Destroy()
	starfieldDestroyed = true
	if StarField then
		StarField:Destroy()
	end
end

-- Enhanced configuration loading
function StarFieldLibrary:LoadConfiguration()
	if not CEnabled then return end

	local success, result = pcall(function()
		if isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
			LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
			StarFieldLibrary:Notify({
				Title = "Configuration Loaded",
				Content = "Your settings have been restored from previous session.",
				Duration = 4,
				Image = 4384403532
			})
		end
	end)

	if not success then
		warn("Configuration loading error:", result)
	end
end

-- Initialize library
task.delay(2, function()
	StarFieldLibrary:LoadConfiguration()
end)

return StarFieldLibrary
