local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- === Tạo cửa sổ và đổi chữ nút Show ===
local Window = Rayfield:CreateWindow({
    Name = "M4pr Hub",
    LoadingTitle = "Thanks for using! :3",
    LoadingSubtitle = "by Useless Maper",
    ShowText = "M4pr" -- <=== ĐỔI CHỮ "Show Rayfield" THÀNH "Show M4pr" Ở ĐÂY
})

-- === Phần chức năng giữ nguyên 100% ===
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

        local killersFolder =
            workspace:WaitForChild("Players"):WaitForChild("Killers")

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

        local killerRoot =
            killer:FindFirstChild("HumanoidRootPart")
            or killer.PrimaryPart

        if not killerRoot then
            return
        end

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

            local frontPosition =
                killerRoot.Position +
                killerRoot.CFrame.LookVector * PredictionStuds

            frontPosition = Vector3.new(
                frontPosition.X,
                root.Position.Y,
                frontPosition.Z
            )

            root.CFrame = CFrame.lookAt(
                root.Position,
                frontPosition
            )
        end)
    end)
end

local function SearchForShoot()
    local button = playerGui:FindFirstChild("Shoot", true)

    if button and button:IsA("ImageButton") then
        ConnectShootButton(button)
    end
end

SearchForShoot()

playerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") and obj.Name == "Shoot" then
        ConnectShootButton(obj)
    end
end)

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
ChanceV2:CreateLabel("REMEMBER: WHEN AIMING, STAND STILL")


local TwoTimeTab = Window:CreateTab("Two Time", "swords")

local LocalPlayer = Players.LocalPlayer

local BackstabEnabled = false
local BackstabStuds = 2
local BackstabDuration = 1

local DaggerConnection
local RunService = game:GetService("RunService")

local function ConnectDaggerButton(button)
    if DaggerConnection then
        DaggerConnection:Disconnect()
        DaggerConnection = nil
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
            if tick() - startTime >= BackstabDuration then
                connection:Disconnect()
                return
            end

            if not hrp.Parent or not killerRoot.Parent then
                connection:Disconnect()
                return
            end

            local behindPos =
                killerRoot.Position -
                killerRoot.CFrame.LookVector * BackstabStuds

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

TwoTimeTab:CreateToggle({
    Name = "Backstab",
    CurrentValue = false,
    Flag = "BackstabToggle",

    Callback = function(Value)
        BackstabEnabled = Value
    end,
})

TwoTimeTab:CreateInput({
    Name = "Distance Behind Killer",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)

        if num then
            BackstabStuds = num
        end
    end,
})
TwoTimeTab:CreateInput({
    Name = "Backstab Duration (s)",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,

    Callback = function(Text)
        local num = tonumber(Text)

        if num then
            BackstabDuration = num
        end
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

    local killersFolder =
        workspace:WaitForChild("Players"):WaitForChild("Killers")

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

    local survivorsFolder =
        workspace:WaitForChild("Players"):WaitForChild("Survivors")

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


local GeneratorESPEnabled = false
local GeneratorHighlights = {}
local GeneratorChildConnection
local GeneratorScanThread

local function ClearGeneratorESP()
    for _, highlight in pairs(GeneratorHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end

    table.clear(GeneratorHighlights)
end

local function HighlightGenerator(generator)
    if not GeneratorESPEnabled then
        return
    end

    if not generator:IsA("Model") or generator.Name ~= "Generator" then
        return
    end

    if generator:FindFirstChild("GeneratorESP") then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "GeneratorESP"
    highlight.FillColor = Color3.fromRGB(0, 170, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = generator
    highlight.Parent = generator

    table.insert(GeneratorHighlights, highlight)
end

local function ScanGenerators()
    if not GeneratorESPEnabled then
        return
    end

    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then
        return
    end

    local ingame = mapFolder:FindFirstChild("Ingame")
    if not ingame then
        return
    end

    local gameMap = ingame:FindFirstChild("Map")
    if not gameMap then
        return
    end

    for _, child in ipairs(gameMap:GetChildren()) do
        HighlightGenerator(child)
    end
end

local function StartGeneratorESP()
    if GeneratorChildConnection then
        GeneratorChildConnection:Disconnect()
        GeneratorChildConnection = nil
    end

    GeneratorESPEnabled = true
    ClearGeneratorESP()

    local mapFolder = workspace:FindFirstChild("Map")
    local ingame = mapFolder and mapFolder:FindFirstChild("Ingame")
    local gameMap = ingame and ingame:FindFirstChild("Map")

    if gameMap then
        GeneratorChildConnection =
            gameMap.ChildAdded:Connect(function(child)
                HighlightGenerator(child)
            end)
    end

    GeneratorScanThread = task.spawn(function()
        while GeneratorESPEnabled do
            ScanGenerators()
            task.wait(0.5)
        end
    end)
end

local function StopGeneratorESP()
    GeneratorESPEnabled = false

    if GeneratorChildConnection then
        GeneratorChildConnection:Disconnect()
        GeneratorChildConnection = nil
    end

    ClearGeneratorESP()
end

ESPTab:CreateToggle({
    Name = "Generator",
    CurrentValue = false,
    Flag = "GeneratorESP",

    Callback = function(Value)
        if Value then
            StartGeneratorESP()
        else
            StopGeneratorESP()
        end
    end,
})
