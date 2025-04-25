-- SPIRAL ADMIN (KOS)
-- GAME: The Streets By SnakeWorl 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local hb = RunService.Heartbeat
local tpwalking = false
local blinkSpeed = 1
local spamtext = ""
local spamming = false
local noclip = false
local prefix = ";"
local camlockEnabled = false
local aimbotEnabled = false
local orbitRadius = 5
local orbitSpeed = 2
local followTarget = nil
local orbiting = false
local flying = false
local SPEED = 2
local CONTROL = {F = 0, B = 0, L = 0, R = 0}
local T
local reviveActive = false
local revivePosition

-- Notification Function
local function notify(title, text)
	game.StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = 3
	})
end

-- Player Finder
local function GetPlayer(name)
	local matched = {}
	for _, v in pairs(Players:GetPlayers()) do
		if v.Name:lower():sub(1, #name) == name:lower() or v.DisplayName:lower():sub(1, #name) == name:lower() then
			table.insert(matched, v)
		end
	end
	return matched
end

-- FLY FUNCTION
local function Fly()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	T = char.HumanoidRootPart
	local BG = Instance.new("BodyGyro", T)
	local BV = Instance.new("BodyVelocity", T)
	BG.P = 9e4
	BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	BG.cframe = T.CFrame
	BV.velocity = Vector3.new(0, 0.1, 0)
	BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

	RunService.RenderStepped:Connect(function()
		if flying and T then
			BG.cframe = camera.CFrame
			local new = (camera.CFrame.lookVector * (CONTROL.F - CONTROL.B) + camera.CFrame.RightVector * (CONTROL.R - CONTROL.L)).Unit
			BV.velocity = new * SPEED
		end
	end)
end

-- Input Controls for Fly
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then CONTROL.F = 1 end
	if key == Enum.KeyCode.S then CONTROL.B = 1 end
	if key == Enum.KeyCode.A then CONTROL.L = 1 end
	if key == Enum.KeyCode.D then CONTROL.R = 1 end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then CONTROL.F = 0 end
	if key == Enum.KeyCode.S then CONTROL.B = 0 end
	if key == Enum.KeyCode.A then CONTROL.L = 0 end
	if key == Enum.KeyCode.D then CONTROL.R = 0 end
end)

-- CMD BAR LOGIC
inputBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local msg = inputBox.Text:lower()
	inputBox.Text = ""

	if msg == prefix.."fly" then
		if not flying then
			flying = true
			Fly()
			notify("Fly", "Enabled")
		end
	elseif msg == prefix.."unfly" then
		flying = false
		if T then
			for _, v in pairs(T:GetChildren()) do
				if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
					v:Destroy()
				end
			end
		end
		notify("Fly", "Disabled")
	elseif msg == prefix.."noclip" then
		noclip = true
		notify("Noclip enabled", "Type ;clip to disable")
	elseif msg == prefix.."clip" then
		noclip = false
		notify("Noclip disabled", "Type ;noclip to enable")
	elseif msg == prefix.."reset" then
		player.Character:BreakJoints()
	elseif string.sub(msg, 1, 6) == prefix.."blink" then
		tpwalking = true
		blinkSpeed = tonumber(string.sub(msg, 7)) or 1
		notify("Blink started", "Speed: "..blinkSpeed)
		spawn(function()
			while tpwalking and player.Character and player.Character:FindFirstChild("Humanoid") do
				local delta = hb:Wait()
				if player.Character.Humanoid.MoveDirection.Magnitude > 0 then
					player.Character:TranslateBy(player.Character.Humanoid.MoveDirection * blinkSpeed * delta * 10)
				end
			end
		end)
	elseif msg == prefix.."unblink" then
		tpwalking = false
		notify("Blink stopped", "")
	elseif string.sub(msg, 1, 12) == prefix.."blinkspeed" then
		local speed = tonumber(string.sub(msg, 13))
		if speed then
			blinkSpeed = speed
			notify("Blink Speed", "Set to "..speed)
		else
			notify("Error", "Invalid speed.")
		end
	elseif msg == prefix.."camlock" then
		camlockEnabled = not camlockEnabled
		notify("Camlock", camlockEnabled and "Enabled" or "Disabled")
	elseif msg == prefix.."aimbot" then
		aimbotEnabled = not aimbotEnabled
		notify("Aimbot", aimbotEnabled and "Enabled" or "Disabled")
	elseif msg == prefix.."credits" then
		notify("CREDITS", "SKIES ADMIN (KOS) BY BYTECOLLECTOR | DISCORD: prodsaturn")
	elseif msg == prefix.."revive" then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			revivePosition = char.HumanoidRootPart.CFrame
			reviveActive = true
			notify("Revive", "Enabled and position saved.")
		else
			notify("Revive", "Failed to get position.")
		end
	elseif msg == prefix.."norevive" then
		reviveActive = false
		notify("Revive", "Disabled.")
	elseif msg == prefix.."revivepos" then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") and reviveActive then
			revivePosition = char.HumanoidRootPart.CFrame
			notify("Revive", "Position updated.")
		else
			notify("Revive", "You must have ;revive active first.")
		end
	end
end)

-- Spam Loop
task.spawn(function()
	while true do
		task.wait(0.8)
		if spamming and spamtext ~= "" then
			game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamtext, "All")
		end
	end
end)

-- GunAnims
local guns = {"GlockSimple", "ShottySimple", "Sawed Off", "Uzi", "AR15"}
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://15309223710"
local playing = {}

player.Backpack.ChildAdded:Connect(function(tool)
	if table.find(guns, tool.Name) then
		tool.Equipped:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				local track = char.Humanoid:LoadAnimation(anim)
				track:Play()
				playing[tool] = track
			end
		end)
		tool.Unequipped:Connect(function()
			if playing[tool] then
				playing[tool]:Stop()
				playing[tool] = nil
			end
		end)
	end
end)

-- Revive Listener
player.CharacterAdded:Connect(function(char)
	if reviveActive and revivePosition then
		char:WaitForChild("HumanoidRootPart").CFrame = revivePosition
	end
end)

-- Autofocus input box
task.wait(0.1)
inputBox:CaptureFocus()
