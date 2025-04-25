-- Spiral Admin + CmdBar
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
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
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 3
		})
	end)
end

-- Fly Function
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

local Skreppa = Instance.new("ScreenGui", CoreGui)
Skreppa.ZIndexBehavior = Enum.ZIndexBehavior.Global

local CommandBar = Instance.new("TextBox", Skreppa)
CommandBar.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
CommandBar.BorderColor3 = Color3.fromRGB(224, 224, 224)
CommandBar.Font = Enum.Font.Code
CommandBar.Position = UDim2.new(0, 0, 0.5, 0)
CommandBar.Size = UDim2.new(0, 0, 0, 25)
CommandBar.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandBar.TextSize = 18
CommandBar.TextTruncate = Enum.TextTruncate.AtEnd
CommandBar.Visible = false
CommandBar.ZIndex = 1

UserInputService.InputBegan:Connect(function(Key, Processed)
	if not Processed and Key.KeyCode == Enum.KeyCode.Semicolon then
		CommandBar.Visible = true
		CommandBar.Text = ""
		task.wait()
		CommandBar:CaptureFocus()
		CommandBar:TweenSize(UDim2.new(0, 250, 0, 25), "Out", "Quad", 0.35, true)
	end
end)

CommandBar.FocusLost:Connect(function(Focused)
	if Focused then
		CommandBar:TweenSize(UDim2.new(0, 0, 0, 25), "Out", "Quad", 0.2, true)
		task.wait()
		CommandBar.Visible = false

		local msg = CommandBar.Text:lower()
		CommandBar.Text = ""

		if msg == prefix.."fly" then
			if not flying then flying = true Fly() notify("Fly", "Enabled") end
		elseif msg == prefix.."unfly" then
			flying = false
			if T then for _, v in pairs(T:GetChildren()) do if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end end end
			notify("Fly", "Disabled")
		elseif msg == prefix.."noclip" then noclip = true notify("Noclip", "Enabled")
		elseif msg == prefix.."clip" then noclip = false notify("Noclip", "Disabled")
		elseif msg == prefix.."reset" then player.Character:BreakJoints()
		elseif string.sub(msg, 1, 6) == prefix.."blink" then
			tpwalking = true blinkSpeed = tonumber(string.sub(msg, 7)) or 1 notify("Blink", "Speed: "..blinkSpeed)
			spawn(function() while tpwalking and player.Character and player.Character:FindFirstChild("Humanoid") do local delta = hb:Wait()
			if player.Character.Humanoid.MoveDirection.Magnitude > 0 then player.Character:TranslateBy(player.Character.Humanoid.MoveDirection * blinkSpeed * delta * 10) end end end)
		elseif msg == prefix.."unblink" then tpwalking = false notify("Blink", "Stopped")
		elseif string.sub(msg, 1, 12) == prefix.."blinkspeed" then local speed = tonumber(string.sub(msg, 13)) if speed then blinkSpeed = speed notify("Blink Speed", "Set to "..speed) else notify("Error", "Invalid speed.") end
		elseif msg == prefix.."camlock" then camlockEnabled = not camlockEnabled notify("Camlock", camlockEnabled and "Enabled" or "Disabled")
		elseif msg == prefix.."aimbot" then aimbotEnabled = not aimbotEnabled notify("Aimbot", aimbotEnabled and "Enabled" or "Disabled")
		elseif msg == prefix.."credits" then notify("Credits", "SKIES ADMIN (KOS) BY BYTECOLLECTOR | DISCORD: prodsaturn")
		elseif msg == prefix.."revive" then local char = player.Character if char and char:FindFirstChild("HumanoidRootPart") then revivePosition = char.HumanoidRootPart.CFrame reviveActive = true notify("Revive", "Enabled") end
		elseif msg == prefix.."norevive" then reviveActive = false notify("Revive", "Disabled")
		elseif msg == prefix.."revivepos" then local char = player.Character if char and char:FindFirstChild("HumanoidRootPart") and reviveActive then revivePosition = char.HumanoidRootPart.CFrame notify("Revive", "Position Updated") end
		elseif string.sub(msg, 1, 4 + #prefix) == prefix.."kos" then
			local targetName = msg:sub(6)
			for _, v in pairs(Players:GetPlayers()) do
				if v.Name:lower():sub(1, #targetName) == targetName or v.DisplayName:lower():sub(1, #targetName) == targetName then
					local head = v.Character and v.Character:FindFirstChild("Head")
					if head and not head:FindFirstChild("KOS_TAG") then
						local tag = Instance.new("BillboardGui")
						tag.Name = "KOS_TAG"
						tag.Size = UDim2.new(0, 100, 0, 40)
						tag.StudsOffset = Vector3.new(0, 2, 0)
						tag.AlwaysOnTop = true
						tag.Adornee = head
						tag.Parent = head
						local text = Instance.new("TextLabel")
						text.Size = UDim2.new(1, 0, 1, 0)
						text.BackgroundTransparency = 1
						text.Text = "KOS"
						text.TextColor3 = Color3.fromRGB(255, 0, 0)
						text.TextStrokeTransparency = 0
						text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						text.Font = Enum.Font.GothamBlack
						text.TextScaled = true
						text.Parent = tag
						notify("KOS", "Marked "..v.DisplayName.." / "..v.Name)
					end
				end
			end
		elseif string.sub(msg, 1, 6 + #prefix) == prefix.."unkos" then
			local targetName = msg:sub(8)
			for _, v in pairs(Players:GetPlayers()) do
				if v.Name:lower():sub(1, #targetName) == targetName or v.DisplayName:lower():sub(1, #targetName) == targetName then
					local head = v.Character and v.Character:FindFirstChild("Head")
					if head and head:FindFirstChild("KOS_TAG") then
						head.KOS_TAG:Destroy()
						notify("KOS", "Removed from "..v.DisplayName.." / "..v.Name)
					end
				end
			end
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	if reviveActive and revivePosition then
		char:WaitForChild("HumanoidRootPart").CFrame = revivePosition
	end
end)

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

task.spawn(function()
	while true do
		task.wait(0.8)
		if spamming and spamtext ~= "" then
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamtext, "All")
		end
	end
end)
