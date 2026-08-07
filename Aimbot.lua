--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)

]]

--// Cache
local game, workspace = game, workspace
local pcall, next, tick, loadstring, tonumber = pcall, next, tick, loadstring, tonumber
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

-- Safe rendering property fallbacks
local getrenderproperty = getrenderproperty or function(obj, key)
	local s, r = pcall(function() return obj[key] end)
	return s and r or nil
end

local setrenderproperty = setrenderproperty or function(obj, key, val)
	pcall(function() obj[key] = val end)
end

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--// Service Methods
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables
local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}, nil, 0

-- Safe Environment Fallback to prevent Read-Only table crashes
local Environment = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1
	},
	Settings = {
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		OffsetToMoveDirection = false,
		OffsetIncrement = 15,
		Sensitivity = 0,
		Sensitivity2 = 3.5,
		LockMode = 1,
		LockPart = "Head",
		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},
	FOVSettings = {
		Enabled = true,
		Visible = true,
		Radius = 90,
		NumSides = 60,
		Thickness = 1,
		Transparency = 1,
		Filled = false,
		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},
	Blacklisted = {},
	FOVCircleOutline = Drawingnew("Circle"),
	FOVCircle = Drawingnew("Circle")
}

-- Attempt global exposure safely without forcing it
pcall(function()
	if getgenv then
		getgenv().ExunysDeveloperAimbot = Environment
	end
end)

setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)
--// Core Functions
local FixUsername = function(String)
	local Result
	for _, Value in next, Players:GetPlayers() do
		if stringsub(stringlower(Value.Name), 1, #String) == stringlower(String) then
			Result = Value.Name
		end
	end
	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed
	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil
	setrenderproperty(Environment.FOVCircle, "Color", Environment.FOVSettings.Color)
	pcall(function() UserInputService.MouseDeltaSensitivity = OriginalSensitivity end)
	if Animation then Animation:Cancel() end
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

		for _, Value in next, Players:GetPlayers() do
			local Character = Value.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

local Part = LockPart == "Torso"
    and (Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso"))
    or Character:FindFirstChild(LockPart)

if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, Value.Name) and Character and Part and Humanoid then
    local PartPosition = Part.Position
				local TeamCheckOption = Environment.DeveloperSettings.TeamCheckOption

				if Settings.TeamCheck and Value[TeamCheckOption] == LocalPlayer[TeamCheckOption] then continue end
				if Settings.AliveCheck and Humanoid.Health <= 0 then continue end

				if Settings.WallCheck then
					local Origin = Camera.CFrame.Position
					local Direction = PartPosition - Origin
					local Params = RaycastParams.new()
					
					local IgnoreList = {}
					if LocalPlayer.Character then
						for _, Val in next, LocalPlayer.Character:GetDescendants() do
							IgnoreList[#IgnoreList + 1] = Val
						end
					end
					Params.FilterDescendantsInstances = IgnoreList
					Params.FilterType = Enum.RaycastFilterType.Exclude

					local RaycastResult = workspace:Raycast(Origin, Direction, Params)
					if RaycastResult and not RaycastResult.Instance:IsDescendantOf(Character) then
						continue
					end
				end

				local Vector, OnScreen, Distance = Camera:WorldToViewportPoint(PartPosition)
				Vector = ConvertVector(Vector)
				Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(
    (LockPart == "Torso"
        and (Environment.Locked.Character:FindFirstChild("UpperTorso") or Environment.Locked.Character:FindFirstChild("Torso"))
        or Environment.Locked.Character:FindFirstChild(LockPart)
    ).Position
))).Magnitude > RequiredDistance then
    CancelLock()
end
end

local Load = function()
	pcall(function() OriginalSensitivity = UserInputService.MouseDeltaSensitivity end)
	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	ServiceConnections.RenderSteppedConnection = RunService[Environment.DeveloperSettings.UpdateMode]:Connect(function()
		local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

		if FOVSettings.Enabled and Settings.Enabled then
			setrenderproperty(FOVCircle, "Visible", FOVSettings.Visible)
			setrenderproperty(FOVCircleOutline, "Visible", FOVSettings.Visible)
			setrenderproperty(FOVCircle, "Radius", FOVSettings.Radius)
			setrenderproperty(FOVCircleOutline, "Radius", FOVSettings.Radius)
			setrenderproperty(FOVCircle, "NumSides", FOVSettings.NumSides)
			setrenderproperty(FOVCircleOutline, "NumSides", FOVSettings.NumSides)
			setrenderproperty(FOVCircle, "Thickness", FOVSettings.Thickness)
			setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			setrenderproperty(FOVCircle, "Transparency", FOVSettings.Transparency)
			setrenderproperty(FOVCircleOutline, "Transparency", FOVSettings.Transparency)
			setrenderproperty(FOVCircle, "Filled", FOVSettings.Filled)
			setrenderproperty(FOVCircleOutline, "Filled", FOVSettings.Filled)

			setrenderproperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)
			setrenderproperty(FOVCircle, "Position", UserInputService:GetMouseLocation())
			setrenderproperty(FOVCircleOutline, "Position", UserInputService:GetMouseLocation())
		else
			setrenderproperty(FOVCircle, "Visible", false)
			setrenderproperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()

			if Environment.Locked and Environment.Locked.Character then
				local Hum = Environment.Locked.Character:FindFirstChildOfClass("Humanoid")
				Offset = OffsetToMoveDirection and Hum and Hum.MoveDirection * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero

local Part = LockPart == "Torso"
    and (Environment.Locked.Character:FindFirstChild("UpperTorso") or Environment.Locked.Character:FindFirstChild("Torso"))
    or Environment.Locked.Character:FindFirstChild(LockPart)

if Part then
    local LockedPosition_Vector3 = Part.Position
    local LockedPosition = Camera:WorldToViewportPoint(LockedPosition_Vector3 + Offset)

					if Environment.Settings.LockMode == 2 and mousemoverel then
						mousemoverel((LockedPosition.X - UserInputService:GetMouseLocation().X) / Settings.Sensitivity2, (LockedPosition.Y - UserInputService:GetMouseLocation().Y) / Settings.Sensitivity2)
					else
						if Settings.Sensitivity > 0 then
							Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
							Animation:Play()
						else
							pcall(function() Camera.CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset) end)
						end
						pcall(function() UserInputService.MouseDeltaSensitivity = 0 end)
					end
					setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
				end
			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
		if GameProcessed or Typing then return end
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running
				if not Running then CancelLock() end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input, GameProcessed)
		if GameProcessed or Settings.Toggle or Typing then return end
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Settings.TriggerKey or Input.UserInputType == Settings.TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function() Typing = true end)
ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function() Typing = false end)

function Environment.Exit(self)
	for Index, _ in next, ServiceConnections do pcall(function() ServiceConnections[Index]:Disconnect() end) end
	if self.FOVCircle and self.FOVCircle.Remove then self.FOVCircle:Remove() end
	if self.FOVCircleOutline and self.FOVCircleOutline.Remove then self.FOVCircleOutline:Remove() end
end

function Environment.Restart()
	for Index, _ in next, ServiceConnections do pcall(function() ServiceConnections[Index]:Disconnect() end) end
	Load()
end

function Environment.Blacklist(self, Username)
	local Fixed = FixUsername(Username) or Username
	if Fixed and not tablefind(self.Blacklisted, Fixed) then 
		table.insert(self.Blacklisted, Fixed) 
	end
end

function Environment.Whitelist(self, Username)
	local Fixed = FixUsername(Username) or Username
	local Index = tablefind(self.Blacklisted, Fixed)
	if Index then tableremove(self.Blacklisted, Index) end
end

Load()
--// Kavo UI Library Generation
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Universal Aimbot V3", "Midnight")

-- Target-Width Expansion Patch (Resizes menu elements from 525 to 650 pixels wide)
pcall(function()
	local uiTarget = game:GetService("CoreGui"):FindFirstChild("Universal Aimbot V3") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Universal Aimbot V3")
	if uiTarget then
		for _, frame in next, uiTarget:GetDescendants() do
			if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
				if frame.Size.X.Offset == 525 then
					frame.Size = UDim2.new(frame.Size.X.Scale, 100, frame.Size.Y.Scale, frame.Size.Y.Offset)
				elseif frame.Size.X.Offset == 450 then
					frame.Size = UDim2.new(frame.Size.X.Scale, 575, frame.Size.Y.Scale, frame.Size.Y.Offset)
				end
			elseif frame:IsA("TextLabel") and frame.Size.X.Offset == 450 then
				frame.Size = UDim2.new(frame.Size.X.Scale, 575, frame.Size.Y.Scale, frame.Size.Y.Offset)
			end
		end
	end
end)

local MainTab = Window:NewTab("Aimbot")
local FovTab = Window:NewTab("FOV Settings")
local ActionsTab = Window:NewTab("Management")

-- Safe element insertion wrapper to prevent readonly error crashes
local SafeSlider = function(section, name, info, max, min, callback)
	local success = pcall(function()
		section:NewSlider(name, info, max, min, callback)
	end)
	if not success then
		section:NewTextBox(name .. " [" .. min .. "-" .. max .. "]", info, function(txt)
			local num = tonumber(txt)
			if num then
				callback(mathclamp(num, min, max))
			end
		end)
	end
end

local MainSection = MainTab:NewSection("Core Configuration")

MainSection:NewToggle("Enable Aimbot", "Turns core tracking function on or off.", function(state)
	Environment.Settings.Enabled = state
	if not state then CancelLock() end
end)

MainSection:NewToggle("Team Check", "Prevents tracking teammates.", function(state)
	Environment.Settings.TeamCheck = state
end)

MainSection:NewToggle("Alive Check", "Prevents tracking dead players.", function(state)
	Environment.Settings.AliveCheck = state
end)

MainSection:NewToggle("Wall Check", "Only scan visible enemies via workspace geometry.", function(state)
	Environment.Settings.WallCheck = state
end)

MainSection:NewDropdown("Lock Part", "Priority targeted body parts.", {"Head", "HumanoidRootPart", "Torso"}, function(selected)
	Environment.Settings.LockPart = selected
end)

MainSection:NewDropdown("Lock Mode", "Tracking mechanics format.", {"CFrame Camera", "Mouse Movements"}, function(selected)
	Environment.Settings.LockMode = (selected == "CFrame Camera") and 1 or 2
end)

local MechanicsSection = MainTab:NewSection("Physics & Modifiers")

MechanicsSection:NewToggle("Offset to Move Direction", "Predictive positional leading logic.", function(state)
	Environment.Settings.OffsetToMoveDirection = state
end)

SafeSlider(MechanicsSection, "Predict Offset Mult", "Velocity adjustment scale.", 30, 1, function(value)
	Environment.Settings.OffsetIncrement = value
end)

SafeSlider(MechanicsSection, "Camera Sensitivity", "Smoothness interpolation value.", 5, 0, function(value)
	Environment.Settings.Sensitivity = value / 10
end)

SafeSlider(MechanicsSection, "Mouse Sensitivity", "Raw delta displacement scale.", 10, 1, function(value)
	Environment.Settings.Sensitivity2 = value
end)

MechanicsSection:NewToggle("Toggle Trigger Action", "Switch key bind mode behavior.", function(state)
	Environment.Settings.Toggle = state
	Running = false
	CancelLock()
end)

MechanicsSection:NewKeybind("Change Action Keybind", "Primary tracking trigger target hotkey.", Enum.KeyCode.E, function() end, function(key)
	Environment.Settings.TriggerKey = key
end)

local FovSection = FovTab:NewSection("Visual Parameters")

FovSection:NewToggle("Enable Circle Elements", "Draw dynamic screen tracking ring.", function(state)
	Environment.FOVSettings.Enabled = state
end)

FovSection:NewToggle("Circle Visibility", "Toggle UI element rendering visibility.", function(state)
	Environment.FOVSettings.Visible = state
end)

SafeSlider(FovSection, "Radius", "Pixel scanning boundaries zone scale.", 500, 10, function(value)
	Environment.FOVSettings.Radius = value
end)

SafeSlider(FovSection, "Segment Quality", "Circle edge resolution detail.", 120, 12, function(value)
	Environment.FOVSettings.NumSides = value
end)

SafeSlider(FovSection, "Border Thickness", "Line width stroke size config.", 10, 1, function(value)
	Environment.FOVSettings.Thickness = value
end)

local FovStyleSection = FovTab:NewSection("Chroma & Colorizations")

FovStyleSection:NewToggle("Rainbow Core Color", "Loops active hue cycle color shifts.", function(state)
	Environment.FOVSettings.RainbowColor = state
end)

FovStyleSection:NewToggle("Rainbow Outline Color", "Loops external boundary border shifts.", function(state)
	Environment.FOVSettings.RainbowOutlineColor = state
end)

FovStyleSection:NewColorPicker("Static Circle Color", "Base element fill profile.", Color3fromRGB(255, 255, 255), function(color)
	Environment.FOVSettings.Color = color
end)

FovStyleSection:NewColorPicker("Target Locked Color", "Color profile upon acquisition lock.", Color3fromRGB(255, 150, 150), function(color)
	Environment.FOVSettings.LockedColor = color
end)

local AdjustSection = ActionsTab:NewSection("Aimbot Process Management")

AdjustSection:NewTextBox("Blacklist Player", "Input target system ignore IDs.", function(txt)
	pcall(function() Environment:Blacklist(txt) end)
end)

AdjustSection:NewTextBox("Whitelist Player", "Reintroduce profiles into regular loop tracking.", function(txt)
	pcall(function() Environment:Whitelist(txt) end)
end)

AdjustSection:NewButton("Restart Service Instance", "Flush active event pipelines cleanly.", function()
	Environment.Restart()
end)

AdjustSection:NewButton("Eradicate Thread Elements", "Perform total loop destruction routines.", function()
	Environment:Exit()
end)

return Environment
