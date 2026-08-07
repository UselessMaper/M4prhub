local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "M4pr Hub",
    LoadingTitle = "Thanks for using! :3",
    LoadingSubtitle = "by Useless Maper"
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
local TwoTimeTab = Window:CreateTab("two time", "Sword")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BackstabEnabled = false
local BackstabStuds = 2
local DaggerConnection

local RunService = game:GetService("RunService")

local function ConnectDaggerButton(button)
    if DaggerConnection then
        DaggerConnection:Disconnect()
    end

    DaggerConnection = button.MouseButton1Click:Connect(function()
        if not BackstabEnabled then
            return
        end

        local character = LocalPlayer.Character
        if not character then
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end

        local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

        -- Find the first killer model
        local killer
        for _, model in ipairs(killersFolder:GetChildren()) do
            if model:IsA("Model") then
                killer = model
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

        local startTime = tick()

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if tick() - startTime >= 0.8 then
                connection:Disconnect()
                return
            end

            if not hrp.Parent or not killerRoot.Parent then
                connection:Disconnect()
                return
            end

            -- Stay 2 studs behind the killer
            local behindPos = killerRoot.Position - killerRoot.CFrame.LookVector * BackstabStuds

            hrp.CFrame = CFrame.lookAt(behindPos, killerRoot.Position)
        end)
    end)
end

local function SearchForDagger()
    local button = LocalPlayer.PlayerGui:FindFirstChild("Dagger", true)
    if button and button:IsA("ImageButton") then
        ConnectDaggerButton(button)
    end
end

SearchForDagger()

LocalPlayer.PlayerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") and obj.Name == "Dagger" then
        ConnectDaggerButton(obj)
    end
end)

TwoTimeTab:CreateToggle({
    Name = "Backstab",
    CurrentValue = false,
    Flag = "BackstabToggle",
    Callback = function(Value)
        BackstabEnabled = Value
    end,
})
TwoTimeTab:CreateSlider({
    Name = "Studs",
    Range = {0, 5},
    Increment = 1,
    Suffix = "",
    CurrentValue = 2,
    Flag = "BackstabStuds",
    Callback = function(Value)
        BackstabStuds = Value
    end,
})
local ESPTab = Window:CreateTab("ESP", "eye")
local KillerESPEnabled = false
local KillerHighlight

local function UpdateKillerESP()
    if KillerHighlight then
        KillerHighlight:Destroy()
        KillerHighlight = nil
    end

    if not KillerESPEnabled then
        return
    end

    local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

    local function ApplyHighlight()
        if KillerHighlight then
            KillerHighlight:Destroy()
            KillerHighlight = nil
        end

        for _, killer in ipairs(killersFolder:GetChildren()) do
            if killer:IsA("Model") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "KillerESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = killer
                highlight.Parent = killer

                KillerHighlight = highlight
                break
            end
        end
    end

    ApplyHighlight()

    killersFolder.ChildAdded:Connect(function()
        if KillerESPEnabled then
            task.wait()
            ApplyHighlight()
        end
    end)
end

ESPTab:CreateToggle({
    Name = "Killer",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value)
        KillerESPEnabled = Value
        UpdateKillerESP()
    end,
})
