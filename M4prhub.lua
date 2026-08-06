local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "M4pr Hub v1.3",
    LoadingTitle = "Thanks for using! :3",
    LoadingSubtitle = "by Useless Maper"
})
local ChanceTab = Window:CreateTab("Chance", "target") -- Tab name, icon ID
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local AutoAim = false
local AimConnection

local function getCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return Character
end

local function getNearestKiller()
    local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

    local char = getCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local nearest
    local shortest = math.huge

    for _, model in ipairs(killersFolder:GetChildren()) do
        if model:IsA("Model") then
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = model
                end
            end
        end
    end

    return nearest
end

local function aimAtPrediction()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local killer = getNearestKiller()
    if not killer then return end

    local root = killer:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local start = tick()

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if tick() - start >= 1.9 then
            conn:Disconnect()
            return
        end

        local velocity = root.AssemblyLinearVelocity
        local targetPos

        -- Predict 4 studs ahead if moving
        if velocity.Magnitude > 0.1 then
            targetPos = root.Position + velocity.Unit * 4
        else
            -- Otherwise aim directly at the killer
            targetPos = root.Position
        end

        local flatTarget = Vector3.new(
    targetPos.X,
    hrp.Position.Y,
    targetPos.Z
)

hrp.CFrame = CFrame.lookAt(hrp.Position, flatTarget)
    end)
end

local ShootConnection

ChanceTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
    Flag = "AutoAimToggle",
    Callback = function(Value)
        AutoAim = Value

        if ShootConnection then
            ShootConnection:Disconnect()
            ShootConnection = nil
        end

        if AutoAim then
            print("Auto Aim Enabled")

            task.spawn(function()
                while AutoAim do
                    local shootButton

                    for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if v:IsA("ImageButton") and v.Name == "Shoot" then
                            shootButton = v
                            break
                        end
                    end

                    if shootButton then
                        ShootConnection = shootButton.MouseButton1Click:Connect(function()
                            if AutoAim then
                                aimAtPrediction()
                            end
                        end)
                        break
                    end

                    task.wait(0.5)
                end
            end)
        else
            print("Auto Aim Disabled")
        end
    end,
})
local ChanceV2 = Window:CreateTab("Chance v2", "crosshair")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AimV2Enabled = false
local ShootConnection
local PredictionStuds = 4

local function ConnectShootButton(button)
    if ShootConnection then
        ShootConnection:Disconnect()
        ShootConnection = nil
    end

    ShootConnection = button.MouseButton1Click:Connect(function()
        if not AimV2Enabled then
            return
        end

        local character = player.Character
        if not character then
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end

        local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

        -- Find the first killer model
        local killer
        for _, v in ipairs(killersFolder:GetChildren()) do
            if v:IsA("Model") then
                killer = v
                break
            end
        end

        if not killer then
            return
        end

        local killerRoot = killer:FindFirstChild("HumanoidRootPart") or killer.PrimaryPart
        if not killerRoot then
            return
        end

        -- Look at a point 4 studs in front of the killer
        local RunService = game:GetService("RunService")

local startTime = tick()
local connection

connection = RunService.RenderStepped:Connect(function()
    if tick() - startTime >= 2 then
        connection:Disconnect()
        return
    end

    if not root.Parent or not killerRoot.Parent then
        connection:Disconnect()
        return
    end

    -- Point 4 studs in front of the model
    local frontPosition = killerRoot.Position + killerRoot.CFrame.LookVector * PredictionStuds
    frontPosition = Vector3.new(
        frontPosition.X,
        root.Position.Y,
        frontPosition.Z
    )

    -- Face that point
    root.CFrame = CFrame.lookAt(root.Position, frontPosition)
end)
    end)
end

local function SearchForShoot()
    local button = playerGui:FindFirstChild("Shoot", true)
    if button and button:IsA("ImageButton") then
        ConnectShootButton(button)
    end
end

-- Initial search
SearchForShoot()

-- Reconnect if the Shoot button is recreated
playerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") and obj.Name == "Shoot" then
        ConnectShootButton(obj)
    end
end)

-- Search again after respawning
player.CharacterAdded:Connect(function()
    task.wait(1)
    SearchForShoot()
end)

ChanceV2:CreateToggle({
    Name = "Aim v2",
    CurrentValue = false,
    Flag = "AimV2",
    Callback = function(Value)
        AimV2Enabled = Value
    end,
})
ChanceV2:CreateInput({
    Name = "Prediction",
    PlaceholderText = "4",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)

        if num then
            PredictionStuds = num
        end
    end,
})
ChanceV2:CreateLabel("Should be 4 studs")
