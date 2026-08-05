-- [[ Mobile GUI by Melon ]] --
-- [[ Edited by Melon ]] -- 
-- [[ Created by ??? ]] --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Definitive System Defaults
local DEFAULT_SPEED = 30
local DEFAULT_SIZE = 5
local DEFAULT_DENSITY = 0.7
local DEFAULT_JUMP = 60

-- Customizable Configuration Vars (modified via UI)
local SPEED_MULTIPLIER = DEFAULT_SPEED
local BALL_SIZE = DEFAULT_SIZE
local BALL_DENSITY = DEFAULT_DENSITY
local JUMP_POWER = DEFAULT_JUMP
local IS_BALL_ENABLED = true 

local JUMP_GAP = 0.3
local delta = 1

-- Global tracking variables
local character
local ball
local humanoid
local params = RaycastParams.new()
local tcConnection = nil
local jumpConnection = nil

-- Create ScreenGui Wrapper
local BallGUI = Instance.new("ScreenGui")
BallGUI.Name = "Cool Ball GUI"
BallGUI.ResetOnSpawn = false 
BallGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW WINDOW CONTAINER
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = BallGUI
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.0837606788, 0, 0.317955106, 0)
MainFrame.Size = UDim2.new(0, 254, 0, 500) -- Expanded further to accommodate the Reset button row perfectly
MainFrame.Active = true

-- WINDOWS STYLE TITLE BAR (The Drag Handle & Separator)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(57, 65, 138)
TitleBar.BorderSizePixel = 0

-- Make the entire menu draggable by holding the title bar
MainFrame.Draggable = true

local TitleBarGrad = Instance.new("UIGradient")
TitleBarGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(103, 50, 149))}
TitleBarGrad.Parent = TitleBar

-- Window Title Text Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Cool Ball GUI"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Windows-style Minimize Button (-)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -56, 0, 3)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 18

-- Windows-style X Close Button (X)
local XButton = Instance.new("TextButton")
XButton.Name = "XButton"
XButton.Parent = TitleBar
XButton.Size = UDim2.new(0, 24, 0, 24)
XButton.Position = UDim2.new(1, -28, 0, 3)
XButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
XButton.BorderSizePixel = 0
XButton.Text = "×"
XButton.TextColor3 = Color3.fromRGB(255, 255, 255)
XButton.Font = Enum.Font.SourceSansBold
XButton.TextSize = 18

-- CONTENT BODY FRAME
local ContentFrame = Instance.new("ImageLabel")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30) 
ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ContentFrame.BorderSizePixel = 0
ContentFrame.Image = "http://roblox.com"

local ContentGrad = Instance.new("UIGradient")
ContentGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 45, 90)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 70, 170))}
ContentGrad.Parent = ContentFrame
-- Instantiate control components inside the Content Body
local WButton = Instance.new("TextButton")
local WGRad = Instance.new("UIGradient")
local SButton = Instance.new("TextButton")
local SGrad = Instance.new("UIGradient")
local DButton = Instance.new("TextButton")
local DGrad = Instance.new("UIGradient")
local AButton = Instance.new("TextButton")
local AGrad = Instance.new("UIGradient")

local SpeedInput = Instance.new("TextBox")
local SizeInput = Instance.new("TextBox")
local WeightInput = Instance.new("TextBox") 
local JumpInput = Instance.new("TextBox") 
local ScriptStateButton = Instance.new("TextButton")
local ResetDefaultsButton = Instance.new("TextButton") -- NEW: Reset to Default Button Asset

local SpeedLabel = Instance.new("TextLabel")
local SizeLabel = Instance.new("TextLabel")
local WeightLabel = Instance.new("TextLabel")
local JumpLabel = Instance.new("TextLabel") 

WButton.Name = "WButton"
WButton.Parent = ContentFrame
WButton.BackgroundColor3 = Color3.fromRGB(103, 50, 149)
WButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
WButton.BorderSizePixel = 2
WButton.Position = UDim2.new(0.335968375, 0, 0.02, 0)
WButton.Size = UDim2.new(0, 83, 0, 45)
WButton.Font = Enum.Font.SourceSans
WButton.Text = "W"
WButton.TextColor3 = Color3.fromRGB(0, 0, 0)
WButton.TextScaled = true

WGRad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 103, 248))}
WGRad.Parent = WButton

SButton.Name = "SButton"
SButton.Parent = ContentFrame
SButton.BackgroundColor3 = Color3.fromRGB(103, 50, 149)
SButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
SButton.BorderSizePixel = 2
SButton.Position = UDim2.new(0.335968375, 0, 0.23, 0)
SButton.Size = UDim2.new(0, 83, 0, 45)
SButton.Font = Enum.Font.SourceSans
SButton.Text = "S"
SButton.TextColor3 = Color3.fromRGB(0, 0, 0)
SButton.TextScaled = true

SGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 103, 248))}
SGrad.Parent = SButton

DButton.Name = "DButton"
DButton.Parent = ContentFrame
DButton.BackgroundColor3 = Color3.fromRGB(103, 50, 149)
DButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
DButton.BorderSizePixel = 2
DButton.Position = UDim2.new(0.695652187, 0, 0.125, 0)
DButton.Size = UDim2.new(0, 70, 0, 45)
DButton.Font = Enum.Font.SourceSans
DButton.Text = "D"
DButton.TextColor3 = Color3.fromRGB(0, 0, 0)
DButton.TextScaled = true

DGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 103, 248))}
DGrad.Parent = DButton

AButton.Name = "AButton"
AButton.Parent = ContentFrame
AButton.BackgroundColor3 = Color3.fromRGB(103, 50, 149)
AButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
AButton.BorderSizePixel = 2
AButton.Position = UDim2.new(0.0276679844, 0, 0.125, 0)
AButton.Size = UDim2.new(0, 69, 0, 45)
AButton.Font = Enum.Font.SourceSans
AButton.Text = "A"
AButton.TextColor3 = Color3.fromRGB(0, 0, 0)
AButton.TextScaled = true

AGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 103, 248))}
AGrad.Parent = AButton

-- Speed UI Section
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = ContentFrame
SpeedLabel.Size = UDim2.new(0, 110, 0, 18)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.36, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Movement Speed"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 13

SpeedInput.Name = "SpeedInput"
SpeedInput.Parent = ContentFrame
SpeedInput.Size = UDim2.new(0, 110, 0, 28)
SpeedInput.Position = UDim2.new(0.05, 0, 0.41, 0)
SpeedInput.Text = tostring(SPEED_MULTIPLIER)
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Size UI Section
SizeLabel.Name = "SizeLabel"
SizeLabel.Parent = ContentFrame
SizeLabel.Size = UDim2.new(0, 110, 0, 18)
SizeLabel.Position = UDim2.new(0.52, 0, 0.36, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Ball Size"
SizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeLabel.Font = Enum.Font.SourceSansBold
SizeLabel.TextSize = 13

SizeInput.Name = "SizeInput"
SizeInput.Parent = ContentFrame
SizeInput.Size = UDim2.new(0, 110, 0, 28)
SizeInput.Position = UDim2.new(0.52, 0, 0.41, 0)
SizeInput.Text = tostring(BALL_SIZE)
SizeInput.TextSize = 14
SizeInput.Font = Enum.Font.SourceSans
SizeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Weight UI Section
WeightLabel.Name = "WeightLabel"
WeightLabel.Parent = ContentFrame
WeightLabel.Size = UDim2.new(0, 110, 0, 18)
WeightLabel.Position = UDim2.new(0.05, 0, 0.49, 0)
WeightLabel.BackgroundTransparency = 1
WeightLabel.Text = "Ball Weight"
WeightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WeightLabel.Font = Enum.Font.SourceSansBold
WeightLabel.TextSize = 13

WeightInput.Name = "WeightInput"
WeightInput.Parent = ContentFrame
WeightInput.Size = UDim2.new(0, 110, 0, 28)
WeightInput.Position = UDim2.new(0.05, 0, 0.54, 0)
WeightInput.Text = tostring(BALL_DENSITY)
WeightInput.TextSize = 14
WeightInput.Font = Enum.Font.SourceSans
WeightInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Jump Power UI Section
JumpLabel.Name = "JumpLabel"
JumpLabel.Parent = ContentFrame
JumpLabel.Size = UDim2.new(0, 110, 0, 18)
JumpLabel.Position = UDim2.new(0.52, 0, 0.49, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.TextSize = 13

JumpInput.Name = "JumpInput"
JumpInput.Parent = ContentFrame
JumpInput.Size = UDim2.new(0, 110, 0, 28)
JumpInput.Position = UDim2.new(0.52, 0, 0.54, 0)
JumpInput.Text = tostring(JUMP_POWER)
JumpInput.TextSize = 14
JumpInput.Font = Enum.Font.SourceSans
JumpInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Mode Toggle Setup
ScriptStateButton.Name = "ScriptStateButton"
ScriptStateButton.Parent = ContentFrame
ScriptStateButton.Size = UDim2.new(0, 228, 0, 36)
ScriptStateButton.Position = UDim2.new(0.05, 0, 0.67, 0)
ScriptStateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ScriptStateButton.Text = "Ball Mode: ON"
ScriptStateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptStateButton.Font = Enum.Font.SourceSansBold
ScriptStateButton.TextSize = 14

-- NEW: Reset Defaults Button UI Setup Configurations
ResetDefaultsButton.Name = "ResetDefaultsButton"
ResetDefaultsButton.Parent = ContentFrame
ResetDefaultsButton.Size = UDim2.new(0, 228, 0, 36)
ResetDefaultsButton.Position = UDim2.new(0.05, 0, 0.78, 0)
ResetDefaultsButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ResetDefaultsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ResetDefaultsButton.BorderSizePixel = 1
ResetDefaultsButton.Text = "Reset to Defaults"
ResetDefaultsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetDefaultsButton.Font = Enum.Font.SourceSansBold
ResetDefaultsButton.TextSize = 14

XButton.MouseButton1Down:Connect(function()
	BallGUI:Destroy()
end)

MinimizeButton.MouseButton1Down:Connect(function()
	ContentFrame.Visible = not ContentFrame.Visible
	if ContentFrame.Visible then
		MainFrame.Size = UDim2.new(0, 254, 0, 500) 
		MinimizeButton.Text = "-"
	else
		MainFrame.Size = UDim2.new(0, 254, 0, 30)  
		MinimizeButton.Text = "+"
	end
end)
-- Text Entry Box Listeners
SpeedInput.FocusLost:Connect(function()
	local num = tonumber(SpeedInput.Text)
	if num then SPEED_MULTIPLIER = num end
end)

SizeInput.FocusLost:Connect(function()
	local num = tonumber(SizeInput.Text)
	if num and ball and IS_BALL_ENABLED then 
		BALL_SIZE = num 
		ball.Size = Vector3.new(num, num, num)
	end
end)

WeightInput.FocusLost:Connect(function()
	local num = tonumber(WeightInput.Text)
	if num and ball and IS_BALL_ENABLED then
		BALL_DENSITY = num 
		WeightInput.Text = tostring(BALL_DENSITY)
		local physicalClamp = math.clamp(num, 0.001, 100)
		ball.CustomPhysicalProperties = PhysicalProperties.new(physicalClamp, 0.7, 0.5, 1, 1)
	end
end)

JumpInput.FocusLost:Connect(function()
	local num = tonumber(JumpInput.Text)
	if num then JUMP_POWER = num end
end)

-- NEW: Reset to Defaults Listener Module Engine Action
ResetDefaultsButton.MouseButton1Down:Connect(function()
	-- Restore logic back to baseline system settings variables
	SPEED_MULTIPLIER = DEFAULT_SPEED
	BALL_SIZE = DEFAULT_SIZE
	BALL_DENSITY = DEFAULT_DENSITY
	JUMP_POWER = DEFAULT_JUMP
	
	-- Instantly push values visually directly inside text layout inputs
	SpeedInput.Text = tostring(DEFAULT_SPEED)
	SizeInput.Text = tostring(DEFAULT_SIZE)
	WeightInput.Text = tostring(DEFAULT_DENSITY)
	JumpInput.Text = tostring(DEFAULT_JUMP)
	
	-- Live update physics parts properties immediately if active
	if ball and IS_BALL_ENABLED then
		ball.Size = Vector3.new(DEFAULT_SIZE, DEFAULT_SIZE, DEFAULT_SIZE)
		local physicalClamp = math.clamp(DEFAULT_DENSITY, 0.001, 100)
		ball.CustomPhysicalProperties = PhysicalProperties.new(physicalClamp, 0.7, 0.5, 1, 1)
	end
end)

local InitializeBallPhysics

local function RevertBallPhysics()
	if tcConnection then tcConnection:Disconnect() tcConnection = nil end
	if character then
		character:BreakJoints()
	end
end

ScriptStateButton.MouseButton1Down:Connect(function()
	IS_BALL_ENABLED = not IS_BALL_ENABLED
	if IS_BALL_ENABLED then
		ScriptStateButton.Text = "Ball Mode: ON"
		ScriptStateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		if character then InitializeBallPhysics(character) end
	else
		ScriptStateButton.Text = "Ball Mode: OFF"
		ScriptStateButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		RevertBallPhysics()
	end
end)

InitializeBallPhysics = function(char)
	character = char
	ball = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	
	if not IS_BALL_ENABLED then return end

	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			if v.Name ~= "HumanoidRootPart" then
				v.Massless = true 
			else
				v.Massless = false
			end
		end
	end

	ball.Shape = Enum.PartType.Ball
	ball.Material = Enum.Material.SmoothPlastic
	ball.Size = Vector3.new(BALL_SIZE, BALL_SIZE, BALL_SIZE)
	ball.Transparency = 0.75 

	local physicalClamp = math.clamp(BALL_DENSITY, 0.001, 100)
	ball.CustomPhysicalProperties = PhysicalProperties.new(physicalClamp, 0.7, 0.5, 1, 1)

	local forceName = "BallGravityForce"
	local ballForce = ball:FindFirstChild(forceName) or Instance.new("BodyForce")
	ballForce.Name = forceName
	ballForce.Parent = ball

	params.FilterDescendantsInstances = {character}
	Camera.CameraSubject = ball

	if tcConnection then tcConnection:Disconnect() end
	tcConnection = RunService.RenderStepped:Connect(function(dt)
		if not IS_BALL_ENABLED then return end
		ball.CanCollide = true
		humanoid.PlatformStand = true
		
		if BALL_DENSITY < 0.5 then
			local totalMass = ball:GetMass()
			ballForce.Force = Vector3.new(0, totalMass * workspace.Gravity * (1 - (BALL_DENSITY / 0.7)), 0)
		elseif BALL_DENSITY > 2 then
			local totalMass = ball:GetMass()
			ballForce.Force = Vector3.new(0, -totalMass * workspace.Gravity * (BALL_DENSITY / 5), 0)
		else
			ballForce.Force = Vector3.new(0, 0, 0)
		end
		
		if UserInputService:GetFocusedTextBox() then return end
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			ball.RotVelocity -= Camera.CFrame.RightVector * dt * SPEED_MULTIPLIER
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			ball.RotVelocity -= Camera.CFrame.LookVector * dt * SPEED_MULTIPLIER
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			ball.RotVelocity += Camera.CFrame.RightVector * dt * SPEED_MULTIPLIER
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			ball.RotVelocity += Camera.CFrame.LookVector * dt * SPEED_MULTIPLIER
		end
	end)
end

local function ApplyMobileMovement(vectorDirection)
	if IS_BALL_ENABLED and ball then
		ball.RotVelocity += vectorDirection * delta * SPEED_MULTIPLIER
	end
end

WButton.MouseButton1Down:Connect(function() ApplyMobileMovement(-Camera.CFrame.RightVector) end)
AButton.MouseButton1Down:Connect(function() ApplyMobileMovement(-Camera.CFrame.LookVector) end)
SButton.MouseButton1Down:Connect(function() ApplyMobileMovement(Camera.CFrame.RightVector) end)
DButton.MouseButton1Down:Connect(function() ApplyMobileMovement(Camera.CFrame.LookVector) end)

if jumpConnection then jumpConnection:Disconnect() end
jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not ball or not IS_BALL_ENABLED then return end
	
	if input.KeyCode == Enum.KeyCode.Space then
		ball.Velocity = Vector3.new(ball.Velocity.X, JUMP_POWER, ball.Velocity.Z)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.2) 
	InitializeBallPhysics(char)
end)

if LocalPlayer.Character then
	InitializeBallPhysics(LocalPlayer.Character)
end
 
