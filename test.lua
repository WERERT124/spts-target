local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local PlayerListButton = Instance.new("TextButton")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextBox = Instance.new("TextBox")
local StartButton = Instance.new("TextButton")
local StopButton = Instance.new("TextButton")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.new(1, 0.388, 0.368)
Frame.BorderColor3 = Color3.new(0.674, 0.211, 0.152)
Frame.Position = UDim2.new(0.3, 0, 0.5, 0)
Frame.Size = UDim2.new(0.2, 0, 0.3, 0)
Frame.Active = true
Frame.Draggable = true

PlayerListButton.Parent = Frame
PlayerListButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
PlayerListButton.Size = UDim2.new(0.8, 0, 0.12, 0)
PlayerListButton.Position = UDim2.new(0.1, 0, 0.05, 0)
PlayerListButton.Font = Enum.Font.SourceSansBold
PlayerListButton.Text = "Show Player List"
PlayerListButton.TextScaled = true

ScrollingFrame.Parent = Frame
ScrollingFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
ScrollingFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.Visible = false
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.new(1, 1, 1)
TextBox.BackgroundTransparency = 0.3
TextBox.Size = UDim2.new(0.8, 0, 0.12, 0)
TextBox.Position = UDim2.new(0.1, 0, 0.65, 0)
TextBox.Font = Enum.Font.SourceSansBold
TextBox.PlaceholderText = "Target1, Target2..."
TextBox.Text = ""
TextBox.TextScaled = true

StartButton.Parent = Frame
StartButton.BackgroundColor3 = Color3.new(0, 1, 0)
StartButton.Size = UDim2.new(0.8, 0, 0.12, 0)
StartButton.Position = UDim2.new(0.1, 0, 0.8, 0)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.Text = "Start"
StartButton.TextScaled = true

StopButton.Parent = Frame
StopButton.BackgroundColor3 = Color3.new(1, 0, 0)
StopButton.Size = UDim2.new(0.8, 0, 0.12, 0)
StopButton.Position = UDim2.new(0.1, 0, 0.95, 0)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.Text = "Stop"
StopButton.TextScaled = true

local run = false
local targetPlayers = {} 
local moveConnection = nil

local function updateTextBox()
	local names = {}
	for _, p in ipairs(targetPlayers) do
		table.insert(names, p.Name)
	end
	TextBox.Text = table.concat(names, ", ")
end

local function clearPlayerButtons()
	for _, child in ipairs(ScrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function updatePlayerList()
	clearPlayerButtons()

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local playerButton = Instance.new("TextButton")
		playerButton.Parent = ScrollingFrame
		playerButton.Size = UDim2.new(1, 0, 0, 30)
		playerButton.Font = Enum.Font.SourceSansBold
		playerButton.Text = player.Name
		playerButton.TextScaled = true

		local isSelected = table.find(targetPlayers, player) ~= nil
		playerButton.BackgroundColor3 = isSelected and Color3.new(0, 0.8, 0) or Color3.new(0.7, 0.7, 0.7)

		playerButton.MouseButton1Click:Connect(function()
			local index = table.find(targetPlayers, player)
			if index then
				table.remove(targetPlayers, index)
				playerButton.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7)
			else
				table.insert(targetPlayers, player)
				playerButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
			end
			updateTextBox()
		end)
	end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
	local index = table.find(targetPlayers, player)
	if index then
		table.remove(targetPlayers, index)
		updateTextBox()
	end
	updatePlayerList()
end)

PlayerListButton.MouseButton1Click:Connect(function()
	ScrollingFrame.Visible = not ScrollingFrame.Visible
	if ScrollingFrame.Visible then
		updatePlayerList()
	end
end)

local function stopFollowing()
	run = false
	StartButton.Text = "Start"

	if moveConnection then
		moveConnection:Disconnect()
		moveConnection = nil
	end
end

local function startFollowing()
	targetPlayers = {}
	local inputNames = string.split(TextBox.Text, ",")
	for _, name in ipairs(inputNames) do
		name = name:match("^%s*(.-)%s*$")
		if name and name ~= "" then
			local p = Players:FindFirstChild(name)
			if p then
				table.insert(targetPlayers, p)
			end
		end
	end

	if #targetPlayers == 0 then
		print("Invalid player name(s)")
		StartButton.Text = "No Targets!"
		task.wait(1)
		StartButton.Text = "Start"
		return
	end

	updateTextBox()
	updatePlayerList()

	stopFollowing()
	run = true
	StartButton.Text = "Running..."

	moveConnection = RunService.Heartbeat:Connect(function()
		if not run or #targetPlayers == 0 then
			return
		end

		local localCharacter = LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

		if not localRoot then return end

		
		for _, targetPlayer in ipairs(targetPlayers) do
			local targetCharacter = targetPlayer.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

			if targetRoot then
				
				targetRoot.CFrame = localRoot.CFrame + localRoot.CFrame.LookVector * 2
				
				
				targetRoot.CanCollide = false
			end
		end
	end)
end

StartButton.MouseButton1Click:Connect(function()
	startFollowing()
end)

StopButton.MouseButton1Click:Connect(function()
	stopFollowing()
end)


updatePlayerList()
