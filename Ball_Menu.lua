local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Customizable Configuration Vars (modified via UI)
local SPEED_MULTIPLIER = 30
local BALL_SIZE = 5
local IS_BALL_ENABLED = true 

local JUMP_POWER = 60
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
BallGUI.Name = "BallGUI"
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
MainFrame.Size = UDim2.new(0, 254, 0, 340) -- Height adjusted for new Title Bar spacing
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

-- CONTENT BODY FRAME (Houses all sliders & buttons underneath the Title Bar)
local ContentFrame = Instance.new("ImageLabel")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30) -- Starts right below title bar
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
local ScriptStateButton = Instance.new("TextButton")

WButton.Name = "WButton"
WButton.Parent = ContentFrame
WButton.BackgroundColor3 = Color3.fromRGB(103, 50, 149)
WButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
WButton.BorderSizePixel = 2
WButton.Position = UDim2.new(0.335968375, 0, 0.04, 0)
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
SButton.Position = UDim2.new(0.335968375, 0, 0.36, 0)
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
DButton.Position = UDim2.new(0.695652187, 0, 0.20, 0)
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
AButton.Position = UDim2.new(0.0276679844, 0, 0.20, 0)
AButton.Size = UDim2.new(0, 69, 0, 45)
AButton.Font = Enum.Font.SourceSans
AButton.Text = "A"
AButton.TextColor3 = Color3.fromRGB(0, 0, 0)
AButton.TextScaled = true

AGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(57, 65, 138)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 103, 248))}
AGrad.Parent = AButton

SpeedInput.Name = "SpeedInput"
SpeedInput.Parent = ContentFrame
SpeedInput.Size = UDim2.new(0, 110, 0, 35)
SpeedInput.Position = UDim2.new(0.05, 0, 0.60, 0)
SpeedInput.Text = tostring(SPEED_MULTIPLIER)
SpeedInput.PlaceholderText = "Speed..."
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

SizeInput.Name = "SizeInput"
SizeInput.Parent = ContentFrame
SizeInput.Size = UDim2.new(0, 110, 0, 35)
SizeInput.Position = UDim2.new(0.52, 0, 0.60, 0)
SizeInput.Text = tostring(BALL_SIZE)
SizeInput.PlaceholderText = "Ball Size..."
SizeInput.TextSize = 14
SizeInput.Font = Enum.Font.SourceSans
SizeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

ScriptStateButton.Name = "ScriptStateButton"
ScriptStateButton.Parent = ContentFrame
ScriptStateButton.Size = UDim2.new(0, 228, 0, 40)
ScriptStateButton.Position = UDim2.new(0.05, 0, 0.78, 0)
ScriptStateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ScriptStateButton.Text = "Ball Mode: ON"
ScriptStateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptStateButton.Font = Enum.Font.SourceSansBold
ScriptStateButton.TextSize = 16

-- Completely destroys the whole GUI object
XButton.MouseButton1Down:Connect(function()
	BallGUI:Destroy()
end)

-- WINDOWS MINIMIZE EVENT FUNCTION: Collapses body but preserves the top title bar visibility perfectly
MinimizeButton.MouseButton1Down:Connect(function()
	ContentFrame.Visible = not ContentFrame.Visible
	if ContentFrame.Visible then
		MainFrame.Size = UDim2.new(0, 254, 0, 340) -- Full size bounds
		MinimizeButton.Text = "-"
	else
		MainFrame.Size = UDim2.new(0, 254, 0, 30)  -- Collapsed Windows-style top-bar height
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

-- Forward function declaration so toggle routine can call it cleanly
local InitializeBallPhysics

-- Instantly kills/resets the character to fix broken Roblox controls cleanly
local function RevertBallPhysics()
	if tcConnection then tcConnection:Disconnect() tcConnection = nil end
	if character then
		character:BreakJoints()
	end
end

-- Toggles State engine action logic
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

-- Core Processing Logic Initialization Engine
InitializeBallPhysics = function(char)
	character = char
	ball = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	
	-- Stop activation sequence mid-way if cheat configuration engine is turned off
	if not IS_BALL_ENABLED then return end

	-- Strip collision properties
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Transparency = 0
		end
	end

	-- Apply physical properties to the ball frame
	ball.Shape = Enum.PartType.Ball
	ball.Material = Enum.Material.SmoothPlastic
	ball.Size = Vector3.new(BALL_SIZE, BALL_SIZE, BALL_SIZE)
	ball.Transparency = 0.75

	params.FilterDescendantsInstances = {character}
	Camera.CameraSubject = ball

	-- Core Render Loop Connection Handling
	if tcConnection then tcConnection:Disconnect() end
	tcConnection = RunService.RenderStepped:Connect(function(dt)
		if not IS_BALL_ENABLED then return end
		ball.CanCollide = true
		humanoid.PlatformStand = true
		
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

-- Mobile button directional handling links mapped dynamically
local function ApplyMobileMovement(vectorDirection)
	if IS_BALL_ENABLED and ball then
		ball.RotVelocity += vectorDirection * delta * SPEED_MULTIPLIER
	end
end

WButton.MouseButton1Down:Connect(function() ApplyMobileMovement(-Camera.CFrame.RightVector) end)
AButton.MouseButton1Down:Connect(function() ApplyMobileMovement(-Camera.CFrame.LookVector) end)
SButton.MouseButton1Down:Connect(function() ApplyMobileMovement(Camera.CFrame.RightVector) end)
DButton.MouseButton1Down:Connect(function() ApplyMobileMovement(Camera.CFrame.LookVector) end)

-- ALWAYS-ACTIVE CUSTOM JUMP MECHANIC (Allows tapping Spacebar to jump at all times in mid-air if Ball Mode is ON)
if jumpConnection then jumpConnection:Disconnect() end
jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not ball or not IS_BALL_ENABLED then return end
	
	-- Checks if spacebar was tapped (does not register holding down continuously)
	if input.KeyCode == Enum.KeyCode.Space then
		-- Directly updates velocity to force a jump regardless of Raycast floor tracking
		ball.Velocity = Vector3.new(ball.Velocity.X, JUMP_POWER, ball.Velocity.Z)
	end
end)

-- Character spawn hooks initialization sequence loops
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.2) 
	InitializeBallPhysics(char)
end)

if LocalPlayer.Character then
	InitializeBallPhysics(LocalPlayer.Character)
end
