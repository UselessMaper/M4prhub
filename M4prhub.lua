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
local TwoTimeTab = Window:CreateTab("Two Time", "Sword")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BackstabEnabled = false
local BackstabStuds = 2

local DashstabEnabled = false
local DashstabStuds = 2
local DashstabDelay = 0
local DashstabDuration = 1
local DashstabLerpSpeed = 0.25

local DaggerConnection
local DashstabConnection

local RunService = game:GetService("RunService")

local BackstabToggle
local DashstabToggle

local function ConnectDaggerButton(button)
    if DaggerConnection then
        DaggerConnection:Disconnect()
        DaggerConnection = nil
    end

    DaggerConnection = button.MouseButton1Click:Connect(function()

        -- =========================
        -- DASHSTAB
        -- =========================
        if DashstabEnabled then

            local character = LocalPlayer.Character
            if not character then
                return
            end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return
            end

            local killersFolder =
                workspace:WaitForChild("Players"):WaitForChild("Killers")

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

            local killerRoot =
                killer:FindFirstChild("HumanoidRootPart")
                or killer.PrimaryPart

            if not killerRoot then
                return
            end

            -- Wait 0.7 seconds after clicking Dagger
            task.wait(DashstabDelay)

            if not DashstabEnabled then
                return
            end

            if not hrp.Parent or not killerRoot.Parent then
                return
            end

            -- Follow behind the killer for 0.7 seconds
            local startTime = tick()

            if DashstabConnection then
                DashstabConnection:Disconnect()
                DashstabConnection = nil
            end

            DashstabConnection = RunService.RenderStepped:Connect(function()

    if not DashstabEnabled
        or tick() - startTime >= DashstabDuration
        or not hrp.Parent
        or not killerRoot.Parent then

        DashstabConnection:Disconnect()
        DashstabConnection = nil
        return
    end

    -- 3 studs behind the killer
    local behindPos =
        killerRoot.Position
        - killerRoot.CFrame.LookVector * DashstabStuds

    -- Target position and rotation
    local targetCFrame = CFrame.lookAt(
        behindPos,
        killerRoot.Position
    )

    -- Smoothly move toward the target
    hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, DashstabLerpSpeed)
end)

return
end

        -- =========================
        -- NORMAL BACKSTAB
        -- =========================
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

        local killersFolder =
            workspace:WaitForChild("Players"):WaitForChild("Killers")

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

        local killerRoot =
            killer:FindFirstChild("HumanoidRootPart")
            or killer.PrimaryPart

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

            local behindPos =
                killerRoot.Position
                - killerRoot.CFrame.LookVector * BackstabStuds

            hrp.CFrame = CFrame.lookAt(
                behindPos,
                killerRoot.Position
            )
        end)
    end)
end

local function SearchForDagger()
    local button =
        LocalPlayer.PlayerGui:FindFirstChild("Dagger", true)

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

-- =========================
-- BACKSTAB TOGGLE
-- =========================

BackstabToggle = TwoTimeTab:CreateToggle({
    Name = "Backstab",
    CurrentValue = false,
    Flag = "BackstabToggle",

    Callback = function(Value)
        BackstabEnabled = Value

        if Value then
            DashstabEnabled = false
            DashstabToggle:Set(false)
        end
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

TwoTimeTab:CreateLabel("You should use 2-3 studs")

-- =========================
-- DASHSTAB TOGGLE
-- =========================

DashstabToggle = TwoTimeTab:CreateToggle({
    Name = "Dashstab",
    CurrentValue = false,
    Flag = "DashstabToggle",

    Callback = function(Value)
        DashstabEnabled = Value

        if Value then
            BackstabEnabled = false
            BackstabToggle:Set(false)
        end
    end,
})
TwoTimeTab:CreateSlider({
    Name = "Dashstab Speed",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.25,
    Flag = "DashstabLerpSpeed",

    Callback = function(Value)
        DashstabLerpSpeed = Value
    end,
})
TwoTimeTab:CreateSlider({
    Name = "Duration",
    Range = {0, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "DashstabDuration",

    Callback = function(Value)
        DashstabDuration = Value
    end,
})
TwoTimeTab:CreateSlider({
    Name = "Distance",
    Range = {0, 5},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 2,
    Flag = "DashstabStuds",

    Callback = function(Value)
        DashstabStuds = Value
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

    task.spawn(function()
    while KillerESPEnabled do
        ApplyHighlight()
        task.wait(0.2)
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
local SurvivorESPEnabled = false
local SurvivorHighlights = {}

local function ClearSurvivorESP()
    for _, highlight in pairs(SurvivorHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    table.clear(SurvivorHighlights)
end

local function UpdateSurvivorESP()
    ClearSurvivorESP()

    if not SurvivorESPEnabled then
        return
    end

    local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")

    local function ApplyHighlights()
        ClearSurvivorESP()

        for _, survivor in ipairs(survivorsFolder:GetChildren()) do
            if survivor:IsA("Model") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SurvivorESP"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = survivor
                highlight.Parent = survivor

                table.insert(SurvivorHighlights, highlight)
            end
        end
    end

    task.spawn(function()
    while SurvivorESPEnabled do
        ApplyHighlights()
        task.wait(0.2)
    end
end)
end

ESPTab:CreateToggle({
    Name = "Survivor",
    CurrentValue = false,
    Flag = "SurvivorESP",
    Callback = function(Value)
        SurvivorESPEnabled = Value
        UpdateSurvivorESP()
    end,
})
