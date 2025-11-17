--[[
	StarField Interface Suite
	Based on Rayfield Interface Suite by Sirius
	Enhanced and modified for improved performance and features
]]

if debugX then
	warn('Initialising StarField')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Improved loadWithTimeout with better error handling and caching
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	
	-- Cache to avoid repeated requests
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
	end
	
	return if success then result else nil
end

local requestsDisabled = true
local InterfaceBuild = 'SF1'
local Release = "StarField Build 2.0"
local StarFieldFolder = "StarField"
local ConfigurationFolder = StarFieldFolder.."/Configurations"
local ConfigurationExtension = ".sfld"

-- Enhanced settings system with validation
local settingsTable = {
	General = {
		starfieldOpen = {Type = 'bind', Value = 'K', Name = 'StarField Keybind'},
		uiScale = {Type = 'slider', Value = 100, Range = {80, 120}, Name = 'UI Scale'},
		animationSpeed = {Type = 'slider', Value = 1, Range = {0.5, 2}, Name = 'Animation Speed'},
	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
		autoSave = {Type = 'toggle', Value = true, Name = 'Auto Save Config'},
	}
}

local overriddenSettings = {}

-- Improved settings management
local SettingsManager = {}
SettingsManager.__index = SettingsManager

function SettingsManager.new()
	local self = setmetatable({}, SettingsManager)
	self.settings = {}
	self.overrides = {}
	self.listeners = {}
	return self
end

function SettingsManager:get(category, name)
	if self.overrides[`{category}.{name}`] ~= nil then
		return self.overrides[`{category}.{name}`]
	elseif self.settings[category] and self.settings[category][name] then
		return self.settings[category][name].Value
	end
	return nil
end

function SettingsManager:set(category, name, value)
	if not self.settings[category] then
		self.settings[category] = {}
	end
	self.settings[category][name] = self.settings[category][name] or {}
	self.settings[category][name].Value = value
	
	-- Notify listeners
	if self.listeners[`{category}.{name}`] then
		for _, callback in ipairs(self.listeners[`{category}.{name}`]) do
			task.spawn(callback, value)
		end
	end
end

function SettingsManager:override(category, name, value)
	self.overrides[`{category}.{name}`] = value
end

function SettingsManager:onChange(category, name, callback)
	local key = `{category}.{name}`
	self.listeners[key] = self.listeners[key] or {}
	table.insert(self.listeners[key], callback)
end

local settingsManager = SettingsManager.new()

-- Enhanced theme system with gradient support
local StarFieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),
			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),
			-- ... rest of default theme
		},
		
		Cosmic = {
			TextColor = Color3.fromRGB(255, 255, 255),
			Background = Color3.fromRGB(10, 15, 30),
			Topbar = Color3.fromRGB(20, 25, 45),
			Shadow = Color3.fromRGB(5, 10, 25),
			ElementBackground = Color3.fromRGB(30, 35, 60),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 75),
			-- Cosmic theme colors
		},
		
		Nebula = {
			TextColor = Color3.fromRGB(255, 255, 255),
			Background = Color3.fromRGB(40, 10, 50),
			Topbar = Color3.fromRGB(60, 20, 70),
			Shadow = Color3.fromRGB(30, 5, 40),
			ElementBackground = Color3.fromRGB(80, 30, 90),
			ElementBackgroundHover = Color3.fromRGB(100, 40, 110),
			-- Nebula theme colors
		}
	},
	
	-- New features
	Modules = {},
	Plugins = {},
	Security = {
		AntiTamper = true,
		EncryptConfigs = false
	}
}

-- Services
local HttpService = getService('HttpService')
local RunService = getService('RunService')
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Performance optimization
local function throttle(callback, delay)
	local lastCall = 0
	return function(...)
		local now = tick()
		if now - lastCall >= delay then
			lastCall = now
			return callback(...)
		end
	end
end

-- Enhanced notification system
local NotificationQueue = {}
local MaxNotifications = 5

local function processNotificationQueue()
	while #NotificationQueue > 0 and #NotificationQueue <= MaxNotifications do
		local notification = table.remove(NotificationQueue, 1)
		StarFieldLibrary:Notify(notification)
		task.wait(0.5) -- Space between notifications
	end
end

-- Improved utility functions
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local function validateColor(color)
	if typeof(color) == "Color3" then
		return color
	elseif typeof(color) == "table" and color.R and color.G and color.B then
		return Color3.fromRGB(color.R, color.G, color.B)
	end
	return Color3.new(1, 1, 1) -- Default to white
end

-- Enhanced theme system with gradient support
function StarFieldLibrary:ChangeTheme(theme, customColors)
	if typeof(theme) == 'string' then
		if self.Theme[theme] then
			self.CurrentTheme = deepCopy(self.Theme[theme])
		else
			warn(`Theme {theme} not found, using default`)
			self.CurrentTheme = deepCopy(self.Theme.Default)
		end
	elseif typeof(theme) == 'table' then
		self.CurrentTheme = theme
	else
		self.CurrentTheme = deepCopy(self.Theme.Default)
	end
	
	-- Apply custom colors if provided
	if customColors then
		for key, value in pairs(customColors) do
			if self.CurrentTheme[key] ~= nil then
				self.CurrentTheme[key] = validateColor(value)
			end
		end
	end
	
	-- Apply theme to UI
	self:ApplyTheme()
end

function StarFieldLibrary:ApplyTheme()
	if not self.Main then return end
	
	-- Apply theme colors to all UI elements
	-- This would be implemented based on your specific UI structure
end

-- Enhanced notification system with queue management
function StarFieldLibrary:Notify(data)
	-- Validate notification data
	if not data or not data.Title then
		warn("Invalid notification data")
		return
	end
	
	-- Add to queue if too many notifications are active
	if #NotificationQueue >= MaxNotifications then
		table.insert(NotificationQueue, data)
		return
	end
	
	-- Create notification UI
	-- Implementation would go here based on your UI structure
	
	-- Process queue after delay
	task.delay(data.Duration or 5, processNotificationQueue)
end

-- Plugin system for extensibility
function StarFieldLibrary:RegisterPlugin(name, pluginModule)
	if type(pluginModule) ~= "table" or type(pluginModule.init) ~= "function" then
		error("Plugin must be a table with an init function")
	end
	
	self.Plugins[name] = pluginModule
	pluginModule:init(self)
end

function StarFieldLibrary:LoadPlugin(name, url)
	local success, plugin = pcall(loadWithTimeout, url, 10)
	if success and plugin then
		self:RegisterPlugin(name, plugin)
		return true
	else
		warn(`Failed to load plugin {name}: {plugin}`)
		return false
	end
end

-- Module system for organized code
function StarFieldLibrary:CreateModule(name)
	local module = {
		Name = name,
		Elements = {},
		Callbacks = {}
	}
	
	self.Modules[name] = module
	return setmetatable(module, {
		__index = function(self, key)
			return StarFieldLibrary[key] or module[key]
		end
	})
end

-- Enhanced security features
function StarFieldLibrary:EnableSecurity()
	self.Security.AntiTamper = true
	self.Security.EncryptConfigs = true
	
	-- Add anti-tamper measures
	-- This would include checksum verification, environment checks, etc.
end

function StarFieldLibrary:EncryptData(data)
	if not self.Security.EncryptConfigs then
		return data
	end
	
	-- Simple XOR encryption for demonstration
	-- In production, use proper encryption
	local key = "StarFieldSecure"
	local encrypted = ""
	
	for i = 1, #data do
		local char = string.sub(data, i, i)
		local keyChar = string.sub(key, (i - 1) % #key + 1, (i - 1) % #key + 1)
		encrypted = encrypted .. string.char(bit32.bxor(string.byte(char), string.byte(keyChar)))
	end
	
	return encrypted
end

function StarFieldLibrary:DecryptData(data)
	if not self.Security.EncryptConfigs then
		return data
	end
	
	return self:EncryptData(data) -- XOR is symmetric
end

-- Improved configuration management
function StarFieldLibrary:SaveConfiguration()
	if not self.ConfigurationEnabled then return end
	
	local configData = {}
	
	-- Collect all flag values
	for flagName, flagData in pairs(self.Flags) do
		if flagData.Type == "ColorPicker" then
			configData[flagName] = self:PackColor(flagData.Color)
		else
			configData[flagName] = flagData.CurrentValue or flagData.CurrentKeybind or flagData.CurrentOption
		end
	end
	
	-- Add metadata
	configData._metadata = {
		Version = Release,
		SaveDate = os.time(),
		Theme = self.CurrentThemeName
	}
	
	local jsonData = HttpService:JSONEncode(configData)
	
	if self.Security.EncryptConfigs then
		jsonData = self:EncryptData(jsonData)
	end
	
	-- Save to file
	if writefile then
		writefile(self.ConfigurationPath, jsonData)
	end
end

function StarFieldLibrary:LoadConfiguration()
	if not self.ConfigurationEnabled then return false end
	
	if not isfile or not isfile(self.ConfigurationPath) then
		return false
	end
	
	local fileData = readfile(self.ConfigurationPath)
	
	if self.Security.EncryptConfigs then
		fileData = self:DecryptData(fileData)
	end
	
	local success, config = pcall(HttpService.JSONDecode, HttpService, fileData)
	if not success then return false end
	
	-- Load theme first
	if config._metadata and config._metadata.Theme then
		self:ChangeTheme(config._metadata.Theme)
	end
	
	-- Load flag values
	for flagName, value in pairs(config) do
		if flagName ~= "_metadata" and self.Flags[flagName] then
			local flag = self.Flags[flagName]
			if flag.Type == "ColorPicker" then
				flag:Set(self:UnpackColor(value))
			else
				flag:Set(value)
			end
		end
	end
	
	return true
end

-- Utility functions
function StarFieldLibrary:PackColor(color)
	return {R = math.floor(color.R * 255), G = math.floor(color.G * 255), B = math.floor(color.B * 255)}
end

function StarFieldLibrary:UnpackColor(colorTable)
	return Color3.fromRGB(colorTable.R, colorTable.G, colorTable.B)
end

-- Enhanced window creation with better error handling
function StarFieldLibrary:CreateWindow(settings)
	-- Validate settings
	assert(settings and type(settings) == "table", "Settings must be a table")
	assert(settings.Name, "Window must have a name")
	
	-- Set default values
	settings.ConfigurationSaving = settings.ConfigurationSaving or {}
	settings.ConfigurationSaving.Enabled = settings.ConfigurationSaving.Enabled or false
	settings.ConfigurationSaving.FileName = settings.ConfigurationSaving.FileName or tostring(game.PlaceId)
	
	-- Initialize window
	-- This would contain the UI creation code from the original Rayfield implementation
	-- but enhanced with the new features
	
	local window = {
		Name = settings.Name,
		Tabs = {},
		Theme = settings.Theme or "Default"
	}
	
	-- Apply theme
	self:ChangeTheme(window.Theme)
	
	-- Set up configuration saving
	if settings.ConfigurationSaving.Enabled then
		self.ConfigurationEnabled = true
		self.ConfigurationPath = ConfigurationFolder .. "/" .. settings.ConfigurationSaving.FileName .. ConfigurationExtension
		
		-- Create folders if they don't exist
		if makefolder and not isfolder(StarFieldFolder) then
			makefolder(StarFieldFolder)
			makefolder(ConfigurationFolder)
		end
	end
	
	-- Enhanced tab creation
	function window:CreateTab(name, icon, isSettings)
		local tab = {
			Name = name,
			Icon = icon,
			Elements = {},
			Sections = {}
		}
		
		-- Tab creation implementation would go here
		
		-- Enhanced element creation methods would be added here
		function tab:CreateButton(buttonSettings)
			-- Enhanced button implementation
		end
		
		function tab:CreateToggle(toggleSettings)
			-- Enhanced toggle implementation
		end
		
		-- ... other element creation methods
		
		table.insert(self.Tabs, tab)
		return tab
	end
	
	-- Window management methods
	function window:SetVisibility(visible)
		StarFieldLibrary:SetVisibility(visible)
	end
	
	function window:Minimize()
		-- Minimize implementation
	end
	
	function window:Destroy()
		-- Cleanup implementation
	end
	
	return window
end

-- Performance monitoring
local PerformanceMonitor = {
	frameTimes = {},
	lastCheck = tick()
}

function PerformanceMonitor:logFrameTime()
	table.insert(self.frameTimes, tick())
	
	-- Keep only last 60 frames (approx 1 second)
	if #self.frameTimes > 60 then
		table.remove(self.frameTimes, 1)
	end
end

function PerformanceMonitor:getFPS()
	if #self.frameTimes < 2 then return 60 end
	
	local timeSpan = self.frameTimes[#self.frameTimes] - self.frameTimes[1]
	return math.min(60, math.floor(#self.frameTimes / timeSpan))
end

-- Connect to render stepped for FPS monitoring
RunService.RenderStepped:Connect(function()
	PerformanceMonitor:logFrameTime()
end)

-- Enhanced destruction with cleanup
function StarFieldLibrary:Destroy()
	-- Clean up all connections
	for _, connection in pairs(self.Connections or {}) do
		if connection and typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end
	
	-- Save configuration
	self:SaveConfiguration()
	
	-- Destroy UI
	if self.Main then
		self.Main:Destroy()
	end
	
	-- Clear references
	table.clear(self.Flags)
	table.clear(self.Modules)
	table.clear(self.Plugins)
end

-- Initialize library
function StarFieldLibrary:Init()
	-- Load plugins
	for pluginName, pluginUrl in pairs(self.AutoLoadPlugins or {}) do
		self:LoadPlugin(pluginName, pluginUrl)
	end
	
	-- Initialize performance monitoring
	self.PerformanceMonitor = PerformanceMonitor
	
	-- Set up auto-save
	if settingsManager:get("System", "autoSave") then
		task.spawn(function()
			while true do
				task.wait(30) -- Auto-save every 30 seconds
				if self.ConfigurationEnabled then
					self:SaveConfiguration()
				end
			end
		end)
	end
end

-- Return the enhanced library
return StarFieldLibrary
