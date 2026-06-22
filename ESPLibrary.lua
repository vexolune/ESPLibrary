local ESPLibrary = (function()
--!nocheck
--!nolint UnknownGlobal
--[[

		▄▄▄▄███▄▄▄▄      ▄████████         ▄████████    ▄████████    ▄███████▄
		▄██▀▀▀███▀▀▀██▄   ███    ███        ███    ███   ███    ███   ███    ███
		███   ███   ███   ███    █▀         ███    █▀    ███    █▀    ███    ███
		███   ███   ███   ███              ▄███▄▄▄       ███          ███    ███
		███   ███   ███ ▀███████████      ▀▀███▀▀▀     ▀███████████ ▀█████████▀
		███   ███   ███          ███        ███    █▄           ███   ███
		███   ███   ███    ▄█    ███        ███    ███    ▄█    ███   ███
		▀█   ███   █▀   ▄████████▀         ██████████  ▄████████▀   ▄████▀
								   v2.1.0

						Created by mstudio45 (Discord)
				Contributors: Dottik, Master Oogway, deividcomsono
						https://docs.mstudio45.com/
--]]

local getgenv = getgenv or function() return shared end

local VERSION = "2.1.0";
local DEBUG_ENABLED = getgenv().mstudio45_ESP_DEBUG == true;

local debug_print = if DEBUG_ENABLED then (function(...) print("[mstudio45's ESP]", ...) end) else (function() end);
local debug_warn  = if DEBUG_ENABLED then (function(...) warn("[mstudio45's ESP]", ...) end) else (function() end);
-- local debug_error = if DEBUG_ENABLED then (function(...) error("[mstudio45's ESP] " .. table.concat({ ... }, " ")) end) else (function() end);

if getgenv().mstudio45_ESP then
	pcall(function() getgenv().mstudio45_ESP:Destroy() end)
	getgenv().mstudio45_ESP = nil
end

-- // Type Definitions // --
export type TracerESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	From: ("Top" | "Bottom" | "Center" | "Mouse")?,
}

export type ArrowESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	CenterOffset: number?,
}

export type Box2DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	Filled: boolean?,
}

export type Box3DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type SkeletonESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type ESPSettings = {
	Name: string,
	Model: Object,
	TextModel: Object?,

	-- // General Settings // --
	Visible: boolean?,
	Color: Color3?,
	MaxDistance: number?,

	StudsOffset: Vector3?,
	TextSize: number?,

	-- // ESP Type Settings // --
	ESPType: ("Text" | "SphereAdornment" | "CylinderAdornment" | "Adornment" | "SelectionBox" | "Highlight"),
	Thickness: number?,
	Transparency: number?,

	-- // SelectionBox Settings // --
	SurfaceColor: Color3?,

	-- // Highlight Settings // --
	FillColor: Color3?,
	OutlineColor: Color3?,

	FillTransparency: number?,
	OutlineTransparency: number?,

	-- // Components // --
	Tracer: TracerESPSettings?,
	Arrow: ArrowESPSettings?,
	Box2D: Box2DESPSettings?,
	Box3D: Box3DESPSettings?,
	Skeleton: SkeletonESPSettings?,

	-- // Callbacks // --
	OnDestroy: BindableEvent?,
	OnDestroyFunc: (() -> nil)?,

	BeforeUpdate: ((self: ESPSettings) -> nil)?,
	AfterUpdate: ((self: ESPSettings) -> nil)?
}

export type ESPInstance = {
	Index: string,
	Hidden: boolean,
	Deleted: boolean,

	OriginalSettings: ESPSettings,
	CurrentSettings: ESPSettings,

	Connections: { RBXScriptConnection },
	Components: {},

	Show: (self, Force: boolean?) -> nil,
	Hide: (self, Force: boolean?) -> nil,
	ToggleVisibility: (self, Force: boolean?) -> nil,
	SetEveryColor: (self, Color: Color3, IncludeComponents: boolean) -> nil,
	Destroy: (self) -> nil
}

local DefaultSettings: ESPSettings = {
	Name = "New ESP",
	Model = nil,
	TextModel = nil,

	-- // General Settings // --
	Visible = true,
	Color = Color3.new(1, 1, 1),
	MaxDistance = 5000,
	
	StudsOffset = Vector3.new(),
	TextSize = 16,
	
	-- // ESP Type Settings // --
	ESPType = "Highlight",
	Thickness = 0.1,
	Transparency = 0.65,
	
	-- // SelectionBox Settings // --
	SurfaceColor = Color3.new(1, 1, 1),

	-- // Highlight Settings // --
	FillColor = Color3.new(1, 1, 1),
	OutlineColor = Color3.new(1, 1, 1),

	FillTransparency = 0.65,
	OutlineTransparency = 0,

	-- // Components // --
	Tracer = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 2,
		Transparency = 0,
		From = "Bottom"
	},
	Arrow = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		CenterOffset = 300,
	},

	Box2D = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
		Filled = false,
	},
	Box3D = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
	},
	Skeleton = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
	},
	HeadDot = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
	},
	ProfilePicture = {
		Enabled = false,
	},

	-- // Callbacks // --
	OnDestroy = nil,
	OnDestroyFunc = nil,

	BeforeUpdate = nil,
	AfterUpdate = nil,
}

-- // Executor Variables // --
local cloneref = getgenv().cloneref or function(inst) return inst; end

-- // GUI Variables // --
local GuiParent, StorageParent;
local CoreGuiAllowed = false;

-- // Services // --
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Toggles = getgenv().Library.Toggles
local Options = getgenv().Library.Options

-- // Core Functions // --
local table_freeze = function<T>(provided_table: T): T
	local data = table.clone(provided_table)

	return setmetatable({}, {
		__index = function(table, key) return rawget(data, key) end,
		__newindex = function(table, key, value) end,
		__iter = function(_) return next, data end,
		__metatable = "The metatable is locked"
	}) :: typeof(provided_table)
end

-- // Functions // --
local function GetPivot(Instance: Bone | Attachment | CFrame | PVInstance)
	if Instance.ClassName == "Bone" then
		return Instance.TransformedWorldCFrame

	elseif Instance.ClassName == "Attachment" then
		return Instance.WorldCFrame

	elseif Instance.ClassName == "Camera" then
		return Instance.CFrame

	else
		return Instance:GetPivot()
	end
end

local function RandomString(name: string?)
	if DEBUG_ENABLED and name then
		return name
	end

	local length = math.random(10, 20)
	local array = {}

	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

local function SafeCallback(Func: (...any) -> ...any, ...: any)
	if not (Func and typeof(Func) == "function") then
		return
	end

	local Result = table.pack(xpcall(Func, function(Error)
		task.defer(error, debug.traceback(Error, 2))
		return Error
	end, ...))

	if not Result[1] then
		return nil
	end

	return table.unpack(Result, 2, Result.n)
end

local Validate; Validate = function(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
	if typeof(Table) ~= "table" then
		return Template
	end

	for k, v in Template do
		if typeof(k) == "number" then
			continue
		end

		if typeof(v) == "table" then
			Table[k] = Validate(Table[k], v)
		elseif Table[k] == nil then
			Table[k] = v
		end
	end

	return Table
end

-- // Instances // --
local InstancesLib = {
	Create = function(instanceType, properties)
		assert(typeof(instanceType) == "string", "Argument #1 must be a string.")
		assert(typeof(properties) == "table", "Argument #2 must be a table.")

		local instance = Instance.new(instanceType)
		for name, val in properties do
			if name == "Parent" then
				continue -- // Parenting is expensive, do last.
			end

			if instanceType == "Path2D" and name == "Transparency" and not CoreGuiAllowed then
				continue -- // Locked behind RobloxSecurity (why roblox?)
			end

			instance[name] = val
		end

		if properties["Parent"] ~= nil then
			instance.Parent = properties["Parent"]
		end

		return instance
	end,

	TryGetProperty = function(instance, propertyName)
		assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.")
		assert(typeof(propertyName) == "string", "Argument #2 must be a string.")

		local success, property = pcall(function()
			return instance[propertyName]
		end)

		return if success then property else nil;
	end,

	FindPrimaryPart = function(instance)
		if typeof(instance) ~= "Instance" then
			return nil
		end

		return (instance:IsA("Model") and instance.PrimaryPart or nil)
			or instance:FindFirstChildWhichIsA("BasePart")
			or instance:FindFirstChildWhichIsA("UnionOperation")
			or instance;
	end,

	DistanceFrom = function(inst, from)
		if not (inst and from) then
			return 9e9;
		end

		local position     = if typeof(inst) == "Instance" then GetPivot(inst).Position else inst;
		local fromPosition = if typeof(from) == "Instance" then GetPivot(from).Position else from;
		return (fromPosition - position).Magnitude;
	end
}

-- // Thread Identity Test // --
do
	local testGui = Instance.new("ScreenGui")
	local successful = pcall(function()
		if not CoreGui then error("CoreGui is nil") end

		testGui.Parent = CoreGui;
	end)

	CoreGuiAllowed = successful;
	if not successful then
		debug_warn("CoreGUI is not accessible!")

		GuiParent = Players.LocalPlayer.PlayerGui;
		StorageParent = ReplicatedStorage;
	else
		GuiParent = CoreGui;
		StorageParent = ReplicatedStorage;
	end

	testGui:Destroy()
end

-- // Storage // --
local StorageFolder = InstancesLib.Create("Folder", {
	Parent = StorageParent,
	Name = RandomString("StorageFolder")
})

local ActiveFolder = InstancesLib.Create("Folder", {
	Parent = if CoreGuiAllowed then GuiParent else InstancesLib.Create("ScreenGui", {
		Parent = GuiParent,
		Name = RandomString("ActiveContainer"),
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ClipToDeviceSafeArea = false,
		DisplayOrder = 999999
	}),
	Name = RandomString("ActiveFolder")
})

local MainGUI = InstancesLib.Create("ScreenGui", {
	Parent = GuiParent,
	Name = RandomString("MainGUI"),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

local CanvasFrame = InstancesLib.Create("Frame", {
	Parent = MainGUI,
	Name = RandomString("CanvasFrame"),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
})

local BillboardGUI = InstancesLib.Create("ScreenGui", {
	Parent = GuiParent,
	Name = RandomString("BillboardGUI"),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

-- // Library // --
local Library = {
	Destroyed = false,

	-- // Storages // --
	ActiveFolder = ActiveFolder,
	MainGUI = MainGUI,
	BillboardGUI = BillboardGUI,
	StorageFolder = StorageFolder,
	CanvasFrame = CanvasFrame,
	GuiParent = GuiParent,
	InstancesLib = InstancesLib,
	RandomString = RandomString,

	-- // Connections // --
	Connections = {},

	-- // ESP // --
	ESP = {},

	-- // Global Config // --
	GlobalConfig = {
		IgnoreCharacter = false,
		Rainbow = false,

		Billboards = true,
		Distance = true,

		Highlighters = true,
		Tracers = true,
		Arrows = true,
		Boxes2D = true,
		Boxes3D = true,
		Skeleton = true,

		Font = Enum.Font.RobotoCondensed
	},

	-- // Rainbow Variables // --
	RainbowHueSetup = 0,
	RainbowHue = 0,
	RainbowStep = 0,
	RainbowColor = Color3.new()
}

function Library:Clear()
	if Library.Destroyed == true then
		return
	end

	for _, ESP in Library.ESP do
		if not ESP then continue end
		ESP:Destroy()
	end

	debug_print("Cleared ESPs.")
end

function Library:Destroy()
	if Library.Destroyed == true then
		return
	end

	-- // Destroy Library // --
	Library:Clear();
	Library.Destroyed = true;

	-- // Destroy Folders // --
	ActiveFolder:Destroy();
	StorageFolder:Destroy();
	MainGUI:Destroy();
	BillboardGUI:Destroy();

	Library.ActiveFolder = nil;
	Library.MainGUI = nil;
	Library.BillboardGUI = nil;
	Library.StorageFolder = nil;
	Library.CanvasFrame = nil;

	-- // Clear connections // --
	for _, connection in Library.Connections do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(Library.Connections)

	-- // Clear getgenv // --
	getgenv().mstudio45_ESP = nil;
	debug_print("Unloaded!");
end

-- // Player Variables // --
local Character: Model?;
local RootPart: Part?;
local Camera: Camera = workspace.CurrentCamera;

local function WorldToViewport(...)
	Camera = (Camera or workspace.CurrentCamera);
	if Camera == nil then
		return Vector2.new(0, 0), false;
	end

	return Camera:WorldToViewportPoint(...);
end

local function UpdatePlayerVariables(newCharacter: Instance?, force: boolean?)
	-- // Update Root Part // --
	if force ~= true and Library.GlobalConfig.IgnoreCharacter == true then
		debug_warn("UpdatePlayerVariables: IgnoreCharacter enabled.");
		return;
	end;

	debug_print("Updating Player Variables...");
	Character = newCharacter or Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait();
	RootPart = Character:WaitForChild("HumanoidRootPart", 2.5) or Character:WaitForChild("UpperTorso", 2.5) or Character:WaitForChild("Torso", 2.5) or Character.PrimaryPart or Character:WaitForChild("Head", 2.5);
end
task.spawn(UpdatePlayerVariables, nil, true);

local VisibilityCache = setmetatable({}, { __mode = "k" })
local function IsPlayerVisible(char)
	if not char then return false end
	local now = os.clock()
	local cache = VisibilityCache[char]
	if cache and now - cache.Time < 0.05 then
		return cache.Visible
	end
	
	local isVis = false
	local rp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
	if rp then
		local cam = workspace.CurrentCamera
		if cam then
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {Players.LocalPlayer.Character, char}
			raycastParams.IgnoreWater = true
			
			local origin = cam.CFrame.Position
			local direction = rp.Position - origin
			local result = workspace:Raycast(origin, direction, raycastParams)
			isVis = (result == nil)
		end
	end
	
	VisibilityCache[char] = { Time = now, Visible = isVis }
	return isVis
end

local function GetComponentColor(ESP, componentName, defaultColorOption)
	if Toggles.TeamBasedColor and Toggles.TeamBasedColor.Value and ESP.Player and ESP.Player.Team then
		return ESP.Player.TeamColor.Color
	elseif Toggles.VisibleCheck and Toggles.VisibleCheck.Value then
		local isVisible = IsPlayerVisible(ESP.CurrentSettings.Model)
		if isVisible then
			return Options.VisibleCheckColor1 and Options.VisibleCheckColor1.Value or Color3.fromRGB(0, 255, 0)
		else
			return Options.VisibleCheckColor2 and Options.VisibleCheckColor2.Value or Color3.fromRGB(255, 0, 0)
		end
	else
		return defaultColorOption and defaultColorOption.Value or Color3.fromRGB(255, 255, 255)
	end
end


-- // Type Checks // --
local AllowedTracerFrom = {
	top = true,
	bottom = true,
	center = true,
	mouse = true,
}

local AllowedESPType = {
	text = true,
	sphereadornment = true,
	cylinderadornment = true,
	adornment = true,
	selectionbox = true,
	highlight = true,
}

-- // Helper Functions // --
local function GetModelCorners(Model: Instance?)
	if not Model then
		return false, {}, {}, 0, 0, 0, 0;
	end

	-- // Calculate Bounding Box // --
	local ModelCFrame, ModelSize = nil, nil

	if Model:IsA("Model") then
		ModelCFrame, ModelSize = Model:GetBoundingBox()
	else
		if not InstancesLib.TryGetProperty(Model, "Size") then
			local PrimaryPart = InstancesLib.FindPrimaryPart(Model)

			if InstancesLib.TryGetProperty(PrimaryPart, "Size") then
				ModelCFrame = PrimaryPart.CFrame
				ModelSize = PrimaryPart.Size
			end
		else
			ModelCFrame = Model.CFrame
			ModelSize = Model.Size
		end
	end

	if not (ModelCFrame and ModelSize) then
		return false, {}, {}, 0, 0, 0, 0
	end

	-- // Corners // --
	local sx, sy, sz = ModelSize.X / 2, ModelSize.Y / 2, ModelSize.Z / 2
	local corners = {
		ModelCFrame * Vector3.new(sx, sy, sz),      -- Top Right Back
		ModelCFrame * Vector3.new(sx, sy, -sz),     -- Top Right Front
		ModelCFrame * Vector3.new(sx, -sy, sz),     -- Bottom Right Back
		ModelCFrame * Vector3.new(sx, -sy, -sz),    -- Bottom Right Front

		ModelCFrame * Vector3.new(-sx, sy, sz),     -- Top Left Back
		ModelCFrame * Vector3.new(-sx, sy, -sz),    -- Top Left Front
		ModelCFrame * Vector3.new(-sx, -sy, sz),    -- Bottom Left Back
		ModelCFrame * Vector3.new(-sx, -sy, -sz),   -- Bottom Left Front
	}

	-- // Screen Position for Corners // --
	local screenCorners = {}
	local cornersInFront = 0;

	local minX, maxX = math.huge, -math.huge;
	local minY, maxY = math.huge, -math.huge;
	
	for idx, corner in corners do
		local cornerPos, cornerOnScreen = WorldToViewport(corner)
		screenCorners[idx] = cornerPos;

		if cornerPos.Z <= 0 then continue end
		cornersInFront = cornersInFront + 1;

		minX = math.min(minX, cornerPos.X);
		minY = math.min(minY, cornerPos.Y);
		maxX = math.max(maxX, cornerPos.X);
		maxY = math.max(maxY, cornerPos.Y);
	end

	return cornersInFront > 0, corners, screenCorners, minX, minY, maxX, maxY;
end

-- // ESP Instances // --
local Components = {}; do
	-- // Billboards // --
	Components.Billboard = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		-- // Create Billboard // --
		debug_print("Creating Billboard...")

		local Billboard = InstancesLib.Create("BillboardGui", {
			Parent = BillboardGUI,
			Name = ESP.Index,

			Enabled = true,
			ResetOnSpawn = false,
			AlwaysOnTop = true,
			Size = UDim2.new(0, 200, 0, 50),

			-- // Settings // --
			Adornee = ESP.CurrentSettings.TextModel or ESP.CurrentSettings.Model,
			StudsOffset = ESP.CurrentSettings.StudsOffset,
		})

		local BillboardText = InstancesLib.Create("TextLabel", {
			Parent = Billboard,

			Size = UDim2.new(0, 200, 0, 50),
			Font = Library.GlobalConfig.Font,
			TextWrap = true,
			TextWrapped = true,
			RichText = true,
			TextStrokeTransparency = 0,
			BackgroundTransparency = 1,

			-- // Settings // --
			Text = ESP.CurrentSettings.Name,
			TextColor3 = ESP.CurrentSettings.Color,
			TextSize = ESP.CurrentSettings.TextSize,
		})

		local BillboardUIStroke = InstancesLib.Create("UIStroke", {
			Parent = BillboardText
		})

		local ProfileImage = InstancesLib.Create("ImageLabel", {
			Parent = Billboard,
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(0.5, -95, 0.5, -12), -- Positioned to the left of the Text
			BackgroundTransparency = 1,
			Visible = false,
		})
		
		local ProfileCorner = InstancesLib.Create("UICorner", {
			Parent = ProfileImage,
			CornerRadius = UDim.new(1, 0),
		})
		
		local ProfileUIStroke = InstancesLib.Create("UIStroke", {
			Parent = ProfileImage,
			Thickness = 1.5,
			Color = Color3.fromRGB(255, 255, 255),
		})

		-- // Billboard Data // --
		local BillboardData = {}
		BillboardData.Destroy = function(self)
			if not Billboard then return end
			
			Billboard:Destroy();
			Billboard = nil;
		end;

		BillboardData.Update = function(self)
			if not Billboard then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings
			local _screenPos, isOnScreen = unpack(ESP._LastScreenPos)
			local DistanceFromPlayer = ESP._LastDistance or 0
			
			local NameEnabled = Toggles.NameEnabled and Toggles.NameEnabled.Value == true
			local BillboardEnabled = isOnScreen == true and NameEnabled;
			
			Billboard.Enabled = BillboardEnabled;
			if not BillboardEnabled then return end

			-- // Update Visuals // --
			local nameText = ESPSettings.Name
			if ESP.Player then
				local nameType = Options.NameType and Options.NameType.Value or "Name"
				if nameType == "DisplayName" then
					nameText = ESP.Player.DisplayName
				elseif nameType == "Both" then
					nameText = ESP.Player.DisplayName .. " (@" .. ESP.Player.Name .. ")"
				else
					nameText = ESP.Player.Name
				end
			end

			local nameColor = GetComponentColor(ESP, "Name", Options.NameColorPicker)
			local nameHex = nameColor:ToHex()

			local textParts = { string.format('<font color="#%s">%s</font>', nameHex, nameText) }

			if Toggles.DistanceEnabled and Toggles.DistanceEnabled.Value then
				local distColor = GetComponentColor(ESP, "Distance", Options.DistanceColorPicker)
				local distHex = distColor:ToHex()
				table.insert(textParts, string.format('<font color="#%s">[%dm]</font>', distHex, math.floor(DistanceFromPlayer)))
			end

			if Toggles.EquippedItemEnabled and Toggles.EquippedItemEnabled.Value then
				local tool = ESPSettings.Model:FindFirstChildOfClass("Tool")
				local toolName = tool and tool.Name or "Bare Fists"
				local toolColor = GetComponentColor(ESP, "EquippedItem", Options.EquippedItemColorPicker)
				local toolHex = toolColor:ToHex()
				table.insert(textParts, string.format('<font color="#%s">%s</font>', toolHex, toolName))
			end

			BillboardText.Text = table.concat(textParts, "\n")
			BillboardText.Font = Library.GlobalConfig.Font;
			BillboardText.TextSize = ESPSettings.TextSize;

			-- UIGradient Logic
			local uiGradient = BillboardText:FindFirstChildOfClass("UIGradient")
			if Toggles.TextGradientEnabled and Toggles.TextGradientEnabled.Value then
				if not uiGradient then
					InstancesLib.Create("UIGradient", {
						Parent = BillboardText,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
						})
					})
				end
			else
				if uiGradient then uiGradient:Destroy() end
			end

			-- Text Background Logic
			if Toggles.TextBackgroundEnabled and Toggles.TextBackgroundEnabled.Value then
				BillboardText.BackgroundTransparency = 0.6
				BillboardText.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			else
				BillboardText.BackgroundTransparency = 1
			end

			-- Outline Logic
			BillboardUIStroke.Enabled = Toggles.OutlineEnabled and Toggles.OutlineEnabled.Value == true

			-- Profile Picture Logic
			if Toggles.ProfilePictureEnabled and Toggles.ProfilePictureEnabled.Value and ESP.Player then
				ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. ESP.Player.UserId .. "&w=48&h=48"
				ProfileImage.Visible = true
				ProfileUIStroke.Color = nameColor
			else
				ProfileImage.Visible = false
			end
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Billboard then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Billboard.Enabled = value;
				else
					rawset(BillboardData, key, value);
				end
			end,

			__index = function(table, key)
				if not Billboard then return nil end

				if key == "Visible" then
					return Billboard.Enabled;
				else
					return rawget(BillboardData, key);
				end
			end,

			__iter = function(_) return next, BillboardData end,
			__metatable = "The metatable is locked"
		}) :: typeof(BillboardData)
	end
	
	-- // Highlighter // --
	Components.Highlighter = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		-- // Create Highlighter // --
		local Highlighter = nil

		local ESPType = string.lower(ESP.CurrentSettings.ESPType)
		local IsAdornment = string.match(ESPType, "adornment")

		debug_print("Creating Highlighter...", ESPType, IsAdornment)
		if IsAdornment then
			local _, ModelSize = nil, nil

			if ESP.CurrentSettings.Model:IsA("Model") then
				_, ModelSize = ESP.CurrentSettings.Model:GetBoundingBox()
			else
				if not InstancesLib.TryGetProperty(ESP.CurrentSettings.Model, "Size") then
					local PrimaryPart = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model)

					if not InstancesLib.TryGetProperty(PrimaryPart, "Size") then
						debug_print("Couldn't get model size, switching to Highlight.", ESP.Index, "-", ESP.CurrentSettings.Name)

						ESP.CurrentSettings.ESPType = "Highlight"
						return Library:Add(ESP.CurrentSettings)
					end

					ModelSize = PrimaryPart.Size
				else
					ModelSize = ESP.CurrentSettings.Model.Size
				end
			end

			if ESPType == "sphereadornment" then
				Highlighter = InstancesLib.Create("SphereHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Radius = ModelSize.X * 1.085,
					CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})

			elseif ESPType == "cylinderadornment" then
				Highlighter = InstancesLib.Create("CylinderHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Height = ModelSize.Y * 2,
					Radius = ModelSize.X * 1.085,
					CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})
			else
				Highlighter = InstancesLib.Create("BoxHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Size = ModelSize,

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})
			end

		elseif ESPType == "selectionbox" then
			Highlighter = InstancesLib.Create("SelectionBox", {
				Parent = ActiveFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				Color3 = ESP.CurrentSettings.BorderColor,
				LineThickness = ESP.CurrentSettings.Thickness,

				SurfaceColor3 = ESP.CurrentSettings.SurfaceColor,
				SurfaceTransparency = ESP.CurrentSettings.Transparency
			})

		elseif ESPType == "highlight" then
			Highlighter = InstancesLib.Create("Highlight", {
				Parent = ActiveFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				-- // Settings // --
				FillColor = ESP.CurrentSettings.FillColor,
				OutlineColor = ESP.CurrentSettings.OutlineColor,

				FillTransparency = ESP.CurrentSettings.FillTransparency,
				OutlineTransparency = ESP.CurrentSettings.OutlineTransparency
			})
		end

		-- // Highlighter Data // --
		local function SetVisible(visible: boolean)
			if not Highlighter then return end

			local Parent = if visible then ActiveFolder else StorageFolder;
			if Highlighter.Parent == Parent then return end

			Highlighter.Parent  = Parent;
			Highlighter.Adornee = if visible then ESP.CurrentSettings.Model else nil;
		end

		local HighlighterData = {}
		HighlighterData.Destroy = function(self)
			if not Highlighter then return end

			Highlighter:Destroy();
			Highlighter = nil;
		end

		HighlighterData.Update = function(self)
			if not Highlighter then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings
			local _screenPos, isOnScreen = unpack(ESP._LastScreenPos)
			
			local ChamsEnabled = isOnScreen == true and Toggles.ChamsEnabled and Toggles.ChamsEnabled.Value == true

			SetVisible(ChamsEnabled);
			if not ChamsEnabled then return end

			-- // Update Visuals // --
			if IsAdornment then
				Highlighter.Color3 = GetComponentColor(ESP, "Chams", Options.ChamsColorPicker1)
				Highlighter.Transparency = ESPSettings.Transparency

			elseif ESPType == "selectionbox" then
				Highlighter.Color3 = GetComponentColor(ESP, "Chams", Options.ChamsColorPicker2)
				Highlighter.LineThickness = ESPSettings.Thickness;

				Highlighter.SurfaceColor3 = GetComponentColor(ESP, "Chams", Options.ChamsColorPicker1)
				Highlighter.SurfaceTransparency = ESPSettings.Transparency;

			else
				local fillColor = GetComponentColor(ESP, "ChamsFill", Options.ChamsColorPicker1)
				local outlineColor = GetComponentColor(ESP, "ChamsOutline", Options.ChamsColorPicker2)
				
				Highlighter.FillColor = fillColor
				Highlighter.OutlineColor = outlineColor

				local filled = Toggles.ChamsFilled and Toggles.ChamsFilled.Value == true
				local fillTransparency = filled and (Options.ChamsFillTransparency and Options.ChamsFillTransparency.Value or 0.5) or 1
				local outlineTransparency = Options.ChamsOutlineTransparency and Options.ChamsOutlineTransparency.Value or 0

				local mode = Options.ChamsMode and Options.ChamsMode.Value or "Default"
				if mode == "Visible Only" then
					local isVis = IsPlayerVisible(ESPSettings.Model)
					if isVis then
						Highlighter.FillTransparency = fillTransparency
						Highlighter.OutlineTransparency = outlineTransparency
					else
						Highlighter.FillTransparency = 1
						Highlighter.OutlineTransparency = 1
					end
				elseif mode == "Hidden Only" then
					local isVis = IsPlayerVisible(ESPSettings.Model)
					if not isVis then
						Highlighter.FillTransparency = fillTransparency
						Highlighter.OutlineTransparency = outlineTransparency
					else
						Highlighter.FillTransparency = 1
						Highlighter.OutlineTransparency = 1
					end
				else
					Highlighter.FillTransparency = fillTransparency
					Highlighter.OutlineTransparency = outlineTransparency
				end
			end
		end

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Highlighter then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					)

					SetVisible(value);
				else
					rawset(HighlighterData, key, value);
				end
			end,

			__index = function(table, key)
				if not Highlighter then return nil end

				if key == "Visible" then
					return Highlighter.Adornee ~= nil;
				else
					return rawget(HighlighterData, key);
				end
			end,

			__iter = function(_) return next, HighlighterData end,
			__metatable = "The metatable is locked"
		}) :: typeof(HighlighterData)
	end

	-- // Tracer // --
	Components.Tracer = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end

		if not ESP then
			return
		end

		if not ESP.CurrentSettings.Tracer.Enabled then
			return
		end

		-- // Fix Settings // --
		local ESPSettings = ESP.CurrentSettings

		ESPSettings.Tracer.From = string.lower(tostring(ESPSettings.Tracer.From))
		if AllowedTracerFrom[ESPSettings.Tracer.From] == nil then
			debug_warn(string.format("Invalid Tracer.From (%s), defaulting to 'Bottom'.", ESPSettings.Tracer.From))
			ESPSettings.Tracer.From = "bottom"
		end

		-- // Create Path2D // --
		debug_print("Creating Tracer...")

		local TracerPath = InstancesLib.Create("Path2D", {
			Parent = Library.CanvasFrame,
			Name = (if DEBUG_ENABLED then "Tracer_" else "") .. ESP.Index,
			Closed = false,

			-- // Settings // --
			Color3 = ESPSettings.Tracer.Color,
			Thickness = ESPSettings.Tracer.Thickness,
			Transparency = ESPSettings.Tracer.Transparency
		})

		-- // Tracer Data // --
		local FromRaw, ToRaw = ESPSettings.Tracer.From, ESPSettings.Tracer.To
		local DefaultPoint = UDim2.fromOffset(0, 0)
		local TracerData = {}
		
		-- // Functions // --
		local function SetVisible(Visible: boolean)
			if not TracerPath then return end
			if TracerPath.Visible == Visible then return end

			TracerPath.Parent = if Visible then Library.CanvasFrame else StorageFolder;
			TracerPath.Visible = Visible;
		end

		local function UpdateTracer(FromPoint: UDim2, ToPoint: UDim2)
			TracerPath:SetControlPoints({
				Path2DControlPoint.new(FromPoint),
				Path2DControlPoint.new(ToPoint)
			})
		end

		TracerData.Destroy = function(self)
			if not TracerPath then return end
			
			TracerPath:SetControlPoints({});
			TracerPath:Destroy();
			TracerPath = nil;
		end;

		TracerData.Update = function(self)
			if not TracerPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local screenPos, isOnScreen = unpack(ESP._LastScreenPos);
			
			local TracerEnabled = isOnScreen == true and Toggles.TracerEnabled and Toggles.TracerEnabled.Value == true;

			SetVisible(TracerEnabled);
			if not TracerEnabled then return end

			-- // Update Visuals // --
			local ToPoint = UDim2.fromOffset(screenPos.X, screenPos.Y);
			local FromSetting = Options.TracerOriginDropdown and Options.TracerOriginDropdown.Value or "Bottom";
			FromSetting = string.lower(tostring(FromSetting))

			if FromSetting == "mouse" then
				local MousePos = UserInputService:GetMouseLocation()
				UpdateTracer(
					UDim2.fromOffset(MousePos.X, MousePos.Y),
					ToPoint
				)
			elseif FromSetting == "top" then
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, 0),
					ToPoint
				)
			elseif FromSetting == "middle" or FromSetting == "center" then
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2),
					ToPoint
				)
			else
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
					ToPoint
				)
			end

			-- // Visuals // --
			TracerPath.Thickness = Options.TracerThicknessSlider and Options.TracerThicknessSlider.Value or 2;
			TracerPath.Color3 = GetComponentColor(ESP, "Tracer", Options.TracerColorPicker);
			
			if CoreGuiAllowed then
				TracerPath.Transparency = Options.TracerTransparencySlider and Options.TracerTransparencySlider.Value or 0;
			end;
		end;

		UpdateTracer(
			if typeof(FromRaw) ~= "Vector2" then DefaultPoint else UDim2.fromOffset(FromRaw.X, FromRaw.Y),
			if typeof(ToRaw) ~= "Vector2"   then DefaultPoint else UDim2.fromOffset(ToRaw.X,    ToRaw.Y)
		);

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not TracerPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SetVisible(value);
				else
					rawset(TracerData, key, value);
				end
			end,

			__index = function(table, key)
				if not TracerPath then return nil end

				if key == "Visible" then
					return TracerPath.Visible;
				else
					return rawget(TracerData, key);
				end
			end,

			__iter = function(_) return next, TracerData end,
			__metatable = "The metatable is locked"
		}) :: typeof(TracerData)
	end

	-- // Arrow // --
	Components.Arrow = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Arrow.Enabled then
			return
		end

		-- // Create Arrow // --
		debug_print("Creating Arrow...")

		local Arrow = InstancesLib.Create("ImageLabel", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Arrow_" else "") .. ESP.Index,

			Size = UDim2.new(0, 48, 0, 48),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,

			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Image = "http://www.roblox.com/asset/?id=16368985219",
			ImageColor3 = ESP.CurrentSettings.Color or Color3.new(),
		});

		-- // Arrow Data // --
		local ArrowData = { }
		ArrowData.Destroy = function(self)
			if not Arrow then return end
			
			Arrow:Destroy();
			Arrow = nil;
		end;

		ArrowData.Update = function(self)
			if not Arrow then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local screenPos, isOnScreen = unpack(ESP._LastScreenPos);
			
			local ArrowEnabled = isOnScreen == false and Toggles.ArrowEnabled and Toggles.ArrowEnabled.Value == true;
			
			Arrow.Visible = ArrowEnabled;
			if not ArrowEnabled then return end

			-- // Update Visuals // --
			local screenSize = Camera.ViewportSize
			local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

			local partPos = Vector2.new(screenPos.X, screenPos.Y);

			local IsInverted = screenPos.Z <= 0;
			local invert = (IsInverted and -1 or 1);

			local direction = (partPos - centerPos);
			local arctan = math.atan2(direction.Y, direction.X);
			local angle = math.deg(arctan) + 90;
			
			local offsetVal = Options.ArrowCenterOffsetSlider and Options.ArrowCenterOffsetSlider.Value or 200
			local distance = (offsetVal * 0.001) * screenSize.Y;

			-- // Update Position // --
			Arrow.Rotation = angle + 180 * (IsInverted and 0 or 1);
			Arrow.Position = UDim2.fromOffset(
				centerPos.X + (distance * math.cos(arctan) * invert),
				centerPos.Y + (distance * math.sin(arctan) * invert)
			);

			-- // Update Visuals // --
			Arrow.ImageColor3 = GetComponentColor(ESP, "Arrow", Options.ArrowColorPicker);
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Arrow then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Arrow.Visible = value;
				else
					rawset(ArrowData, key, value);
				end
			end,

			__index = function(table, key)
				if not Arrow then return nil end
				
				if key == "Visible" then
					return Arrow.Visible;
				else
					return rawget(ArrowData, key);
				end
			end,

			__iter = function(_) return next, ArrowData end,
			__metatable = "The metatable is locked"
		}) :: typeof(ArrowData)
	end

	-- // Box2D // --
	Components.Box2D = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Box2D.Enabled then
			return
		end

		debug_print("Creating Box2D...")

		-- // Create Frame // --
		local Frame = InstancesLib.Create("Frame", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Box2D_" else "") .. ESP.Index,

			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 2,
		})
	
		local UIStroke = InstancesLib.Create("UIStroke", {
			Parent = Frame,
		})

		local HealthBarFrame = InstancesLib.Create("Frame", {
			Parent = Frame,
			Name = "HealthBar",
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.new(0, -6, 0, 0),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			BorderSizePixel = 0,
			Visible = false,
		})

		local HealthBarFill = InstancesLib.Create("Frame", {
			Parent = HealthBarFrame,
			Name = "Fill",
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(0, 255, 0),
			BorderSizePixel = 0,
		})

		-- // Box2D Data // --
		local Box2DData = {}
		Box2DData.Destroy = function(self)
			if not Frame then return end
			
			Frame:Destroy();
			Frame = nil;
		end;

		Box2DData.Update = function(self)
			if not Frame then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			
			local boxEnabled = Toggles.BoxEnabled and Toggles.BoxEnabled.Value == true
			local boxType = Options.BoxType and Options.BoxType.Value or "2D"
			local Box2DEnabled = isOnScreen == true and boxEnabled and boxType == "2D";
			
			local healthBarEnabled = isOnScreen == true and Toggles.HealthBarEnabled and Toggles.HealthBarEnabled.Value == true;

			local ComponentActive = Box2DEnabled or healthBarEnabled
			Frame.Visible = ComponentActive
			if not ComponentActive then return end

			-- // Corners // --
			local isCornerOnScreen, _corners, _screenCorners, minX, minY, maxX, maxY = GetModelCorners(ESPSettings.Model);
			if not isCornerOnScreen then
				Frame.Visible = false
				return
			end

			-- // Update Position // --
			Frame.Position = UDim2.fromOffset(minX, minY)
			Frame.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
			
			-- // Update Box Visuals // --
			if Box2DEnabled then
				local boxOutlineColor = GetComponentColor(ESP, "BoxOutline", Options.BoxColorPicker1)
				local boxFillColor = GetComponentColor(ESP, "BoxFill", Options.BoxColorPicker2)
				
				Frame.BackgroundColor3 = boxFillColor
				UIStroke.Enabled = true
				UIStroke.Color = boxOutlineColor
				UIStroke.Thickness = Options.BoxThicknessSlider and Options.BoxThicknessSlider.Value or 1
				UIStroke.Transparency = Options.BoxTransparencySlider and Options.BoxTransparencySlider.Value or 0
				Frame.BackgroundTransparency = if Toggles.FillBox and Toggles.FillBox.Value then 0.5 else 1;
			else
				UIStroke.Enabled = false
				Frame.BackgroundTransparency = 1
			end

			-- // Update Health Bar // --
			if healthBarEnabled then
				local humanoid = ESPSettings.Model:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					
					-- Health Bar Position
					HealthBarFrame.Size = UDim2.new(0, 4, 1, 0)
					HealthBarFrame.Position = UDim2.new(0, -6, 0, 0)
					HealthBarFrame.Visible = true
					
					-- Fill size
					HealthBarFill.Size = UDim2.new(1, 0, healthPercent, 0)
					HealthBarFill.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
					
					-- Color
					local barColor
					if Toggles.HealthBased and Toggles.HealthBased.Value then
						barColor = Color3.fromHSV(healthPercent * 0.3, 1, 1)
					else
						barColor = Options.HealthBarColorPicker and Options.HealthBarColorPicker.Value or Color3.fromRGB(0, 255, 0)
					end
					HealthBarFill.BackgroundColor3 = barColor
					
					-- Health Text
					if Toggles.HealthTextEnabled and Toggles.HealthTextEnabled.Value then
						local textLabel = HealthBarFrame:FindFirstChild("HealthText")
						if not textLabel then
							textLabel = InstancesLib.Create("TextLabel", {
								Parent = HealthBarFrame,
								Name = "HealthText",
								Size = UDim2.new(0, 30, 0, 12),
								BackgroundTransparency = 1,
								Font = Library.GlobalConfig.Font,
								TextSize = 10,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextStrokeTransparency = 0,
								RichText = true,
							})
							InstancesLib.Create("UIStroke", { Parent = textLabel })
						end
						
						textLabel.Text = tostring(math.floor(humanoid.Health))
						textLabel.Position = UDim2.new(0, -32, 1 - healthPercent, -6)
						textLabel.Visible = true
					else
						local textLabel = HealthBarFrame:FindFirstChild("HealthText")
						if textLabel then textLabel.Visible = false end
					end
				else
					HealthBarFrame.Visible = false
				end
			else
				HealthBarFrame.Visible = false
			end
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Frame then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Frame.Visible = value;
				else
					rawset(Box2DData, key, value);
				end
			end,

			__index = function(table, key)
				if not Frame then return nil end
				
				if key == "Visible" then
					return Frame.Visible;
				else
					return rawget(Box2DData, key);
				end
			end,

			__iter = function(_) return next, Box2DData end,
			__metatable = "The metatable is locked"
		}) :: typeof(Box2DData)
	end

	-- // Box3D // --
	Components.Box3D = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		if not ESP.CurrentSettings.Box3D.Enabled then
			return
		end

		debug_print("Creating Box3D...")

		-- // Create Path2D // --
		local BoxPath = InstancesLib.Create("Path2D", {
			Parent = Library.CanvasFrame,
			Name = (if DEBUG_ENABLED then "Box3D_" else "") .. ESP.Index,
			Visible = false,
			
			-- // Settings // --
			Color3 = ESP.CurrentSettings.Box3D.Color,
			Thickness = ESP.CurrentSettings.Box3D.Thickness,
			Transparency = ESP.CurrentSettings.Box3D.Transparency
		})
		
		-- // Functions // --
		local Box3DData = {}

		local function SetVisible(Visible: boolean)
			if not BoxPath then return end
			if BoxPath.Visible == Visible then return end

			BoxPath.Parent = if Visible then Library.CanvasFrame else StorageFolder;
			BoxPath.Visible = Visible;
		end

		Box3DData.Destroy = function(self)
			if not BoxPath then return end
			
			BoxPath:SetControlPoints({});
			BoxPath:Destroy();
			BoxPath = nil;
		end;

		Box3DData.Update = function(self)
			if not BoxPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end
			
			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			
			local boxEnabled = Toggles.BoxEnabled and Toggles.BoxEnabled.Value == true
			local boxType = Options.BoxType and Options.BoxType.Value or "2D"
			local Box3DEnabled = isOnScreen == true and boxEnabled and boxType == "3D";
			
			if not Box3DEnabled then
				SetVisible(false);
				return
			end

			-- // Path // --
			local _isCornerOnScreen, _corners, screenCorners, _minX, _minY, _maxX, _maxY = GetModelCorners(ESPSettings.Model);
			if not (screenCorners and screenCorners[1]) then
				SetVisible(false);
				return
			end
			
			-- // Update Visuals // --
			SetVisible(true);
			local boxOutlineColor = GetComponentColor(ESP, "BoxOutline", Options.BoxColorPicker1)
			BoxPath.Color3 = boxOutlineColor;
			BoxPath.Thickness = Options.BoxThicknessSlider and Options.BoxThicknessSlider.Value or 1;
			
			if CoreGuiAllowed then
				BoxPath.Transparency = Options.BoxTransparencySlider and Options.BoxTransparencySlider.Value or 0;
			end;

			-- 1-2-4-3-1 (Right Face) | 5-6-8-7-5 (Left Face)
			-- Connect: 1-5, 2-6, 4-8, 3-7
			-- Path: 1-2-4-3-1-5-6-8-7-5-6-2-4-8-7-3
			local PointIndices = {1, 2, 4, 3, 1, 5, 6, 8, 7, 5, 6, 2, 4, 8, 7, 3}
			local ControlPoints = table.create(16)
			
			for idx, Index in PointIndices do
				local Point = screenCorners[Index]
				ControlPoints[idx] = Path2DControlPoint.new(
					UDim2.fromOffset(Point.X, Point.Y)
				)
			end
			
			-- // Update Points // --
			BoxPath:SetControlPoints(ControlPoints);
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not BoxPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SetVisible(value);
				else
					rawset(Box3DData, key, value);
				end
			end,

			__index = function(table, key)
				if not BoxPath then return nil end
				
				if key == "Visible" then
					return BoxPath.Visible;
				else
					return rawget(Box3DData, key);
				end
			end,

			__iter = function(_) return next, Box3DData end,
			__metatable = "The metatable is locked"
		}) :: typeof(Box3DData)
	end

	-- // Skeleton // --
	local R15Sequence = {
		-- Root
		"LowerTorso",

		-- Left Leg
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"LeftLowerLeg",
		"LeftUpperLeg",
		"LowerTorso",

		-- Right Leg
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"RightLowerLeg",
		"RightUpperLeg",
		"LowerTorso",

		-- Up torso
		"UpperTorso",

		-- Left Arm
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"LeftLowerArm",
		"LeftUpperArm",
		"UpperTorso",

		-- Right Arm
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"RightLowerArm",
		"RightUpperArm",
		"UpperTorso",

		-- Finish
		"Head"
	}

	local R6Sequence = {
		"Torso",

		-- Left Arm
		"Left Arm",
		"Torso",

		-- Right Arm
		"Right Arm",
		"Torso",

		-- Left Leg
		"Left Leg",
		"Torso",

		-- Right Leg
		"Right Leg",
		"Torso",

		-- Head
		"Head"
	}

	Components.Skeleton = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Skeleton.Enabled then
			return
		end

		debug_print("Creating Skeleton...")

		-- // Create Path2D // --
		local SkeletonPath = InstancesLib.Create("Path2D", {
			Parent = Library.CanvasFrame,
			Name = (if DEBUG_ENABLED then "Skeleton_" else "") .. ESP.Index,
			Visible = false,
			
			-- // Settings // --
			Color3 = ESP.CurrentSettings.Skeleton.Color,
			Thickness = ESP.CurrentSettings.Skeleton.Thickness,
			Transparency = ESP.CurrentSettings.Skeleton.Transparency
		})

		-- // Skeleton Data // --
		local SkeletonData = {}
		local CachedParts = {}

		local function SetVisible(visible: boolean)
			if not SkeletonPath then return end
			if SkeletonPath.Visible == visible then return end

			SkeletonPath.Parent = if visible then Library.CanvasFrame else Library.StorageFolder
			SkeletonPath.Visible = visible
		end

		SkeletonData.Destroy = function(self)
			if not SkeletonPath then return end
			
			SkeletonPath:SetControlPoints({});
			SkeletonPath:Destroy();

			SkeletonPath = nil;
		end;

		SkeletonData.Update = function(self)
			if not SkeletonPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end
			
			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			
			local SkeletonEnabled = isOnScreen == true and Toggles.SkeletonEnabled and Toggles.SkeletonEnabled.Value == true;
			
			if not SkeletonEnabled then
				SetVisible(false);
				return
			end

			-- // Detect Rig Type dynamically // --
			local Model = ESPSettings.Model
			local RigType = "Unknown"
			local humanoid = Model:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if humanoid.RigType == Enum.HumanoidRigType.R15 then
					RigType = "R15"
				else
					RigType = "R6"
				end
			else
				if Model:FindFirstChild("LowerTorso") then
					RigType = "R15"
				elseif Model:FindFirstChild("Torso") then
					RigType = "R6"
				end
			end

			if RigType == "Unknown" then
				SetVisible(false);
				return
			end

			local Sequence = if RigType == "R15" then R15Sequence else R6Sequence

			-- // Build Path from Joints // --
			local ControlPoints = {}
			local pointsMade = 0

			for idx, partName in Sequence do
				local part = CachedParts[partName]
				if not part then
					part = Model:FindFirstChild(partName)
					CachedParts[partName] = part
				end

				if not part then 
					continue
				end

				local pos, visible = WorldToViewport(part.Position)
				if pos.Z <= 0 then
					continue
				end

				table.insert(ControlPoints, Path2DControlPoint.new(UDim2.fromOffset(pos.X, pos.Y)))
				pointsMade = pointsMade + 1 
			end

			if pointsMade == 0 then
				SetVisible(false);
				return
			end

			-- // Update Visuals // --
			SetVisible(true);
			SkeletonPath.Color3 = GetComponentColor(ESP, "Skeleton", Options.SkeletonColorPicker);
			SkeletonPath.Thickness = 1;
			
			if CoreGuiAllowed then
				SkeletonPath.Transparency = 0;
			end;

			-- // Update Points // --
			SkeletonPath:SetControlPoints(ControlPoints);
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not SkeletonPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SkeletonPath.Visible = value;
				else
					rawset(SkeletonData, key, value);
				end
			end,

			__index = function(table, key)
				if not SkeletonPath then return nil end
				
				if key == "Visible" then
					return SkeletonPath.Visible;
				else
					return rawget(SkeletonData, key);
				end
			end,

			__iter = function(_) return next, SkeletonData end,
			__metatable = "The metatable is locked"
		}) :: typeof(SkeletonData)
	end

	-- // Head Dot // --
	Components.HeadDot = function(ESP)
		if Library.Destroyed == true then return end
		if not ESP then return end
		
		-- // Create BillboardGui for Head Dot // --
		local HeadDotBillboard = InstancesLib.Create("BillboardGui", {
			Parent = BillboardGUI,
			Name = "HeadDot_" .. ESP.Index,
			Enabled = false,
			ResetOnSpawn = false,
			AlwaysOnTop = true,
			Size = UDim2.fromOffset(8, 8),
		})
		
		local DotFrame = InstancesLib.Create("Frame", {
			Parent = HeadDotBillboard,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		})
		
		local Corner = InstancesLib.Create("UICorner", {
			Parent = DotFrame,
			CornerRadius = UDim.new(1, 0), -- Round circle
		})
		
		local GlowStroke = InstancesLib.Create("UIStroke", {
			Parent = DotFrame,
			Enabled = false,
			Thickness = 2,
			Transparency = 0.5,
		})

		local HeadDotData = {}
		HeadDotData.Destroy = function(self)
			if not HeadDotBillboard then return end
			HeadDotBillboard:Destroy()
			HeadDotBillboard = nil
		end
		
		HeadDotData.Update = function(self)
			if not HeadDotBillboard then return end
			if not ESP._LastScreenPos then return end
			
			local ESPSettings = ESP.CurrentSettings
			local _, isOnScreen = unpack(ESP._LastScreenPos)
			
			local head = ESPSettings.Model:FindFirstChild("Head")
			local enabled = isOnScreen == true and head ~= nil and Toggles.HeadDotEnabled and Toggles.HeadDotEnabled.Value == true
			
			HeadDotBillboard.Enabled = enabled
			if not enabled then return end
			
			HeadDotBillboard.Adornee = head
			
			local dotColor = GetComponentColor(ESP, "HeadDot", Options.HeadDotColorPicker)
			DotFrame.BackgroundColor3 = dotColor
			
			if Toggles.HeadDotGlowEnabled and Toggles.HeadDotGlowEnabled.Value then
				GlowStroke.Enabled = true
				GlowStroke.Color = dotColor
			else
				GlowStroke.Enabled = false
			end
		end

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not HeadDotBillboard then return end
				if key == "Visible" then
					HeadDotBillboard.Enabled = value
				else
					rawset(HeadDotData, key, value)
				end
			end,
			__index = function(table, key)
				if not HeadDotBillboard then return nil end
				if key == "Visible" then
					return HeadDotBillboard.Enabled
				else
					return rawget(HeadDotData, key)
				end
			end,
			__iter = function(_) return next, HeadDotData end,
			__metatable = "The metatable is locked"
		}) :: typeof(HeadDotData)
	end
end

function Library:Add(espSettings: ESPSettings)
	if Library.Destroyed == true then
		debug_warn("Library is destroyed, please reload it.")
		return
	end

	assert(
		typeof(espSettings) == "table", 
		string.format("espSettings; expected table, got %s", typeof(espSettings))
	)
	assert(
		typeof(espSettings.Model) == "Instance",
		string.format("espSettings.Model; expected Instance, got %s", typeof(espSettings.Model))
	)

	-- // Fix ESPType // --
	if not espSettings.ESPType then espSettings.ESPType = "Highlight" end
	assert(
		typeof(espSettings.ESPType) == "string",
		string.format("espSettings.ESPType; expected string, got %s", typeof(espSettings.ESPType))
	)

	espSettings.ESPType = string.lower(espSettings.ESPType)
	assert(
		AllowedESPType[espSettings.ESPType] == true, 
		string.format("espSettings.ESPType; invalid ESPType, got %s", espSettings.ESPType)
	)

	-- // Fix Settings // --
	espSettings.Name = if typeof(espSettings.Name) == "string" then espSettings.Name else espSettings.Model.Name;
	espSettings.TextModel = if typeof(espSettings.TextModel) == "Instance" then espSettings.TextModel else espSettings.Model;
	
	espSettings = Validate(espSettings, DefaultSettings)

	-- // ESP Data // --
	local ESP = {
		Index = RandomString(),
		OriginalSettings = table_freeze(espSettings) :: ESPSettings,
		CurrentSettings = setmetatable({}, {
			__tostring = function(_) return tostring(espSettings) end,

			__index = function(_, key) return rawget(espSettings, key); end,
			__newindex = function(_, key, value)
				if key == "Model" or key == "TextModel" or key == "ESPType" then
					error(string.format("%s cannot be changed, it is read-only.", key))
				end

				rawset(espSettings, key, value);
			end,

			__eq = function(_, other) return other == espSettings end,
			__iter = function(_) return next, espSettings end,
			__metatable = "The metatable is locked"
		}) :: ESPSettings,

		Hidden = false,
		Deleted = false,

		Connections = {} :: { RBXScriptConnection },
		Components = {}
	} :: ESPInstance;

	debug_print("Creating ESP...", ESP.Index, "-", ESP.CurrentSettings.Name)

	-- // Create Components // --
	ESP.Components["Billboard"] = Components.Billboard(ESP)
	ESP.Components["Highlighter"] = Components.Highlighter(ESP)

	for Name, CreateFunc in Components do
		local Data = espSettings[Name]
		if not Data then continue end

		local Component = CreateFunc(ESP)
		if not Component then continue end

		ESP.Components[Name] = Component
	end

	-- // Setup Destroy Handler // --
	function ESP:Destroy()
		debug_print("Deleting ESP...", tostring(ESP.Index) .. " - " .. tostring(ESP.CurrentSettings.Name))
		
		if ESP.Deleted == true then
			debug_warn("ESP Instance is already deleted.")
			return;
		end

		-- // Change State // --
		ESP.Deleted = true

		-- // Remove from Library // --
		local TableIndex = table.find(Library.ESP, ESP.Index)
		if TableIndex then table.remove(Library.ESP, TableIndex) end
		Library.ESP[ESP.Index] = nil

		-- // Destroy Components // --
		for _, Component in ESP.Components do
			if not Component.Destroy then continue end

			Component:Destroy()
		end
		table.clear(ESP.Components)

		-- // Clear connections // --
		for _, connection in ESP.Connections do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(ESP.Connections)

		-- // Callbacks // --
		if ESP.OriginalSettings.OnDestroy then
			SafeCallback(ESP.OriginalSettings.OnDestroy.Fire, ESP.OriginalSettings.OnDestroy)
		end

		if ESP.OriginalSettings.OnDestroyFunc then
			SafeCallback(ESP.OriginalSettings.OnDestroyFunc)
		end

		-- // Replace Render // --
		ESP.Render = function(...) end

		debug_print("ESP deleted.", ESP.Index, "-", ESP.CurrentSettings.Name)
	end

	-- // Setup Show/Hide Handler // --
	local function Show(forceShow: boolean?)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceShow ~= true and not ESP.Hidden then
			return
		end

		ESP.Hidden = false;
		for Name, Component in ESP.Components do
			Component.Visible = true
		end
	end

	local function Hide(forceHide: boolean?)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceHide ~= true and ESP.Hidden then
			return
		end

		ESP.Hidden = true;
		for Name, Component in ESP.Components do
			Component.Visible = false
		end
	end

	function ESP:Show(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = true;
		Show(force);
	end

	function ESP:Hide(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = false;
		Hide(force);
	end

	function ESP:ToggleVisibility(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = not ESP.CurrentSettings.Visible;
		if ESP.CurrentSettings.Visible then
			Show(force);
		else
			Hide(force);
		end
	end

	-- // Setup Setting Helpers // --
	function ESP:SetEveryColor(Color: Color3, IncludeComponents: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end
		local ESPSettings = ESP.CurrentSettings

		ESPSettings.Color = Color;

		-- // SelectionBox // --
		ESPSettings.SurfaceColor = Color;

		-- // Highlights // --
		ESPSettings.FillColor = Color;
		ESPSettings.OutlineColor = Color;

		-- // Components // --
		if IncludeComponents == true then
			for Name, Component in ESP.Components do
				local ComponentTable = ESPSettings[Name]
				if typeof(ComponentTable) ~= "table" then continue end

				ComponentTable.Color = Color;
			end
		end
	end

	-- // Setup Render Handler // --
	function ESP:Render()
		if not ESP then return end

		local ESPSettings = ESP.CurrentSettings
		if ESP.Deleted == true or not ESPSettings then return end
		
		local masterEnabled = Toggles.ESPEnabled and Toggles.ESPEnabled.Value == true
		local maxDist = Options.MaxDistanceSlider and Options.MaxDistanceSlider.Value or 3000
		local isTeammate = false
		if Toggles.TeamCheck and Toggles.TeamCheck.Value and ESP.Player and ESP.Player ~= Players.LocalPlayer then
			isTeammate = ESP.Player.Team == Players.LocalPlayer.Team
		end

		-- // Early exit conditions // --
		if not masterEnabled or isTeammate or ESPSettings.Visible == false or not (
			Camera and (
				if Library.GlobalConfig.IgnoreCharacter == true then true else RootPart
			)
		) then
			Hide()
			return
		end

		-- // Check Distance // --
		if not ESPSettings.ModelRoot then
			ESPSettings.ModelRoot = InstancesLib.FindPrimaryPart(ESPSettings.Model)
		end

		local ModelRoot = ESPSettings.ModelRoot or ESPSettings.Model
		local DistanceFromPlayer = InstancesLib.DistanceFrom(ModelRoot, RootPart or Camera)
		ESP._LastDistance = DistanceFromPlayer

		if DistanceFromPlayer > maxDist then
			Hide()
			return
		end

		-- // Get Screen Information // --
		local screenPos, isOnScreen = WorldToViewport(GetPivot(ModelRoot).Position)
		ESP._LastScreenPos = { screenPos, isOnScreen }

		-- // Before Update Callback // --
		if ESPSettings.BeforeUpdate then
			SafeCallback(ESPSettings.BeforeUpdate, ESP)
		end

		-- // Update Components // --
		for Name, Component in ESP.Components do
			if not Component.Update then continue end

			local success, err = xpcall(Component.Update, debug.traceback, Component)
			if success then continue end

			debug_warn("Error updating component (" .. Name .. "):\n", err)
		end

		-- // After Update Callback // --
		if ESPSettings.AfterUpdate then
			SafeCallback(ESPSettings.AfterUpdate, ESP)
		end
	end

	if ESP.OriginalSettings.Visible == false then
		Hide()
	else
		Show()
	end

	Library.ESP[ESP.Index] = ESP
	debug_print("ESP created.", ESP.Index, "-", ESP.CurrentSettings.Name)
	return ESP
end

-- // Update Player Variables // --
table.insert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = workspace.CurrentCamera; end))
table.insert(Library.Connections, Players.LocalPlayer.CharacterAdded:Connect(UpdatePlayerVariables))

-- // Rainbow Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function(Delta)
	-- // Only update rainbow if it's enabled // --
	if not Library.GlobalConfig.Rainbow then return end
	
	Library.RainbowStep = Library.RainbowStep + Delta
	if Library.RainbowStep >= (1 / 60) then
		Library.RainbowStep = 0

		Library.RainbowHueSetup = Library.RainbowHueSetup + (1 / 400)
		if Library.RainbowHueSetup > 1 then
			Library.RainbowHueSetup = 0
		end

		Library.RainbowHue = Library.RainbowHueSetup
		Library.RainbowColor = Color3.fromHSV(Library.RainbowHue, 0.8, 1)
	end
end))

-- // Main Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
	local toDestroy = {}
	for Index, ESP in pairs(Library.ESP) do
		if not ESP then 
			toDestroy[Index] = true
			continue 
		end

		if 
			ESP.Deleted == true or 
			not (ESP.CurrentSettings and (ESP.CurrentSettings.Model and ESP.CurrentSettings.Model.Parent)) 
		then
			toDestroy[Index] = ESP
		else
			-- // Render ESP // --
			ESP.Render(ESP)
		end
	end

	for Index, ESP in pairs(toDestroy) do
		if ESP == true then
			Library.ESP[Index] = nil
		else
			pcall(function() ESP:Destroy() end)
		end
	end
end))

debug_print("Loaded! (" .. tostring(VERSION) ..")")
getgenv().mstudio45_ESP = Library
return Library
end)()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Toggles = getgenv().Library.Toggles
local Options = getgenv().Library.Options

local InstancesLib = ESPLibrary.InstancesLib
local GuiParent = ESPLibrary.GuiParent
local RandomString = ESPLibrary.RandomString

print("[Vesper Debug] 9. Exited ESPLibrary closure successfully")

-- Initialize ESPLibrary Global Config from UI Defaults
ESPLibrary.GlobalConfig.Billboards = true
ESPLibrary.GlobalConfig.Highlighters = true
ESPLibrary.GlobalConfig.Boxes2D = false
ESPLibrary.GlobalConfig.Boxes3D = false
ESPLibrary.GlobalConfig.Tracers = false
ESPLibrary.GlobalConfig.Skeleton = false
ESPLibrary.GlobalConfig.Arrows = false

local PlayerESPInstances = {}
local PlayerConnections = {}

local ESPEnabled = false

local function createESP(player, char)
	if not char then return end
	print("[Vesper ESP] createESP called for player:", player.Name, "char:", char.Name)
	
	if PlayerESPInstances[player] then
		pcall(function() PlayerESPInstances[player]:Destroy() end)
		PlayerESPInstances[player] = nil
	end
	
	local espColor = Options.ESPColorPicker and Options.ESPColorPicker.Value or Color3.fromRGB(255, 255, 255)
	local maxDist = Options.MaxDistanceSlider and Options.MaxDistanceSlider.Value or 3000
	local textSize = Options.TextSizeSlider and Options.TextSizeSlider.Value or 16
	
	local tracerThickness = Options.TracerThicknessSlider and Options.TracerThicknessSlider.Value or 2
	local tracerTransparency = Options.TracerTransparencySlider and Options.TracerTransparencySlider.Value or 0
	local tracerFrom = Options.TracerOriginDropdown and Options.TracerOriginDropdown.Value or "Bottom"
	
	local boxThickness = Options.BoxThicknessSlider and Options.BoxThicknessSlider.Value or 1
	local boxTransparency = Options.BoxTransparencySlider and Options.BoxTransparencySlider.Value or 0
	
	local espInstance = ESPLibrary:Add({
		Model = char,
		Name = player.Name,
		Color = espColor,
		Visible = true,
		MaxDistance = maxDist,
		TextSize = textSize,
		
		Tracer = {
			Enabled = true,
			Color = espColor,
			Thickness = tracerThickness,
			Transparency = tracerTransparency,
			From = tracerFrom,
		},
		Arrow = {
			Enabled = true,
			Color = espColor,
			CenterOffset = 300,
		},
		Box2D = {
			Enabled = true,
			Color = espColor,
			Thickness = boxThickness,
			Transparency = boxTransparency,
			Filled = false,
		},
		Box3D = {
			Enabled = true,
			Color = espColor,
			Thickness = boxThickness,
			Transparency = boxTransparency,
		},
		Skeleton = {
			Enabled = true,
			Color = espColor,
			Thickness = 1,
			Transparency = 0,
		},
		HeadDot = {
			Enabled = true,
			Color = espColor,
		},
		ProfilePicture = {
			Enabled = true,
		},
		ESPType = "Highlight",
		FillColor = espColor,
		OutlineColor = espColor,
		FillTransparency = 0.5,
		OutlineTransparency = 0,
	})
	
	espInstance.Player = player
	PlayerESPInstances[player] = espInstance
end

local function ApplyESP(player)
	print("[Vesper ESP] ApplyESP called for player:", player.Name)
	if not (Toggles.ESPEnabled and Toggles.ESPEnabled.Value == true) then
		print("[Vesper ESP] ApplyESP early return (ESP disabled)")
		return
	end
	if player == LocalPlayer and not (Toggles.SelfESP and Toggles.SelfESP.Value) then
		print("[Vesper ESP] ApplyESP early return for LocalPlayer (Self ESP disabled)")
		return
	end
	if PlayerConnections[player] then 
		print("[Vesper ESP] ApplyESP connection already exists for:", player.Name)
		return 
	end
	
	PlayerConnections[player] = player.CharacterAdded:Connect(function(char)
		createESP(player, char)
	end)
	
	if player.Character then
		createESP(player, player.Character)
	end
end

local function RemoveESP(player)
	print("[Vesper ESP] RemoveESP called for player:", player.Name)
	if PlayerESPInstances[player] then
		pcall(function() PlayerESPInstances[player]:Destroy() end)
		PlayerESPInstances[player] = nil
	end
	if PlayerConnections[player] then
		pcall(function() PlayerConnections[player]:Disconnect() end)
		PlayerConnections[player] = nil
	end
end

-- // 2D Radar Widget // --
local function MakeDraggable(Frame)
	local UserInputService = game:GetService("UserInputService")
	local Dragging, DragInput, DragStart, StartPosition
	
	local function Update(Input)
		local Delta = Input.Position - DragStart
		Frame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
	end
	
	Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPosition = Frame.Position
			
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	
	Frame.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

local RadarGui = InstancesLib.Create("ScreenGui", {
	Parent = GuiParent,
	Name = "VesperRadarGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local RadarFrame = InstancesLib.Create("Frame", {
	Parent = RadarGui,
	Name = "RadarFrame",
	Size = UDim2.fromOffset(150, 150),
	Position = UDim2.new(0, 30, 0, 300),
	BackgroundColor3 = Color3.fromRGB(15, 15, 15),
	BackgroundTransparency = 0.4,
	Visible = false,
})

InstancesLib.Create("UICorner", {
	Parent = RadarFrame,
	CornerRadius = UDim.new(1, 0),
})

local RadarOutline = InstancesLib.Create("UIStroke", {
	Parent = RadarFrame,
	Thickness = 1.5,
	Color = Color3.fromRGB(45, 45, 45),
})

-- Center Dot (LocalPlayer)
local CenterDot = InstancesLib.Create("Frame", {
	Parent = RadarFrame,
	Size = UDim2.fromOffset(6, 6),
	Position = UDim2.new(0.5, -3, 0.5, -3),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 0,
})
InstancesLib.Create("UICorner", {
	Parent = CenterDot,
	CornerRadius = UDim.new(1, 0),
})

MakeDraggable(RadarFrame)

local RadarDots = {}
local function UpdateRadar()
	if not (Toggles.RadarEnabled and Toggles.RadarEnabled.Value == true) then
		RadarFrame.Visible = false
		for _, dot in pairs(RadarDots) do
			dot.Visible = false
		end
		return
	end
	
	local size = Options.RadarSizeSlider and Options.RadarSizeSlider.Value or 150
	RadarFrame.Size = UDim2.fromOffset(size, size)
	local center = size / 2
	CenterDot.Position = UDim2.fromOffset(center - 3, center - 3)
	
	RadarFrame.Visible = true
	
	local localChar = LocalPlayer.Character
	local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
	if not localHrp then
		for _, dot in pairs(RadarDots) do
			dot.Visible = false
		end
		return
	end
	
	local localPos = localHrp.Position
	local localLook = localHrp.CFrame.LookVector
	local localRight = localHrp.CFrame.RightVector
	
	local scale = Options.RadarScaleSlider and Options.RadarScaleSlider.Value or 2
	local maxDist = center - 8
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		
		-- Check team check
		local isTeammate = player.Team == LocalPlayer.Team
		local teamCheck = Toggles.TeamCheck and Toggles.TeamCheck.Value
		
		if hrp and (not teamCheck or not isTeammate) then
			local dot = RadarDots[player]
			if not dot then
				dot = InstancesLib.Create("Frame", {
					Parent = RadarFrame,
					Size = UDim2.fromOffset(5, 5),
					BorderSizePixel = 0,
				})
				InstancesLib.Create("UICorner", {
					Parent = dot,
					CornerRadius = UDim.new(1, 0),
				})
				RadarDots[player] = dot
			end
			
			local relPos = hrp.Position - localPos
			local x = relPos:Dot(localRight)
			local z = relPos:Dot(localLook)
			
			local radarX = x / scale
			local radarY = -z / scale
			
			local dist = math.sqrt(radarX^2 + radarY^2)
			if dist > maxDist then
				local angle = math.atan2(radarY, radarX)
				radarX = math.cos(angle) * maxDist
				radarY = math.sin(angle) * maxDist
			end
			
			dot.Position = UDim2.fromOffset(center + radarX - 2.5, center + radarY - 2.5)
			
			local dotColor = Color3.fromRGB(255, 0, 0)
			if Toggles.TeamBasedColor and Toggles.TeamBasedColor.Value and player.Team then
				dotColor = player.TeamColor.Color
			end
			dot.BackgroundColor3 = dotColor
			dot.Visible = true
		else
			local dot = RadarDots[player]
			if dot then
				dot.Visible = false
			end
		end
	end
	
	-- Clean up left players safely
	local toRemove = {}
	for player, dot in pairs(RadarDots) do
		if not Players:FindFirstChild(player.Name) then
			table.insert(toRemove, player)
		end
	end
	for _, player in ipairs(toRemove) do
		local dot = RadarDots[player]
		if dot then
			pcall(function() dot:Destroy() end)
		end
		RadarDots[player] = nil
	end
end

table.insert(ESPLibrary.Connections, RunService.RenderStepped:Connect(UpdateRadar))



return {
	ESPLibrary = ESPLibrary,
	ApplyESP = ApplyESP,
	RemoveESP = RemoveESP,
	PlayerESPInstances = PlayerESPInstances,
	PlayerConnections = PlayerConnections,
	RadarGui = RadarGui,
	RadarFrame = RadarFrame,
	UpdateRadar = UpdateRadar
}
