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

-- =========================
-- TWO TIME
-- =========================

local TwoTimeTab = Window:CreateTab("Two Time", "swords")

local BackstabEnabled = false
local BackstabDistance = 2
local BackstabDuration = 1

local RunService = game:GetService("RunService")
local DaggerConnection
local BackstabConnection

local function StopBackstab()
    if BackstabConnection then
        BackstabConnection:Disconnect()
        BackstabConnection = nil
    end

    local character = player.Character
    if not character then
        return
    end

    local temporaryPart = character:FindFirstChild("BackstabPrimaryPart")

    if temporaryPart then
        temporaryPart:Destroy()
    end

    -- Restore the real character PrimaryPart
    local humanoidRootPart =
        character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        character.PrimaryPart = humanoidRootPart
    end
end

local function DoBackstab()
    if not BackstabEnabled then
        return
    end

    StopBackstab()

    local character = player.Character
    if not character then
        return
    end

    local originalPrimaryPart = character.PrimaryPart
    if not originalPrimaryPart then
        return
    end

    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then
        return
    end

    local killersFolder = playersFolder:FindFirstChild("Killers")
    if not killersFolder then
        return
    end

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

    -- Create YOUR temporary PrimaryPart
    local backstabPart = Instance.new("Part")
    backstabPart.Name = "BackstabPrimaryPart"
    backstabPart.Size = Vector3.new(1, 1, 1)
    backstabPart.Transparency = 1
    backstabPart.Anchored = true
    backstabPart.CanCollide = false
    backstabPart.CanTouch = false
    backstabPart.CanQuery = false

    -- Start behind the Killer
    backstabPart.CFrame =
        killerRoot.CFrame
        - killerRoot.CFrame.LookVector * BackstabDistance

    backstabPart.Parent = character

    -- Make the NEW PART your PrimaryPart
    character.PrimaryPart = backstabPart

    local startTime = tick()

    BackstabConnection = RunService.RenderStepped:Connect(function()
        if not BackstabEnabled
            or not character.Parent
            or not backstabPart.Parent
            or not killer.Parent
            or not killerRoot.Parent
            or tick() - startTime >= BackstabDuration then

            if BackstabConnection then
                BackstabConnection:Disconnect()
                BackstabConnection = nil
            end

            if backstabPart and backstabPart.Parent then
                backstabPart:Destroy()
            end

            -- Restore original PrimaryPart
            if character.Parent
                and originalPrimaryPart
                and originalPrimaryPart.Parent then

                character.PrimaryPart = originalPrimaryPart
            end

            return
        end

        -- Continuously move ONLY the temporary PrimaryPart
        -- behind the Killer.
        backstabPart.CFrame =
            killerRoot.CFrame
            - killerRoot.CFrame.LookVector * BackstabDistance
    end)
end

local function ConnectDaggerButton(button)
    if DaggerConnection then
        DaggerConnection:Disconnect()
        DaggerConnection = nil
    end

    DaggerConnection = button.MouseButton1Click:Connect(function()
        if BackstabEnabled then
            DoBackstab()
        end
    end)
end

local function SearchForDagger()
    local button = playerGui:FindFirstChild("Dagger", true)

    if button and button:IsA("ImageButton") then
        ConnectDaggerButton(button)
    end
end

SearchForDagger()

playerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") and obj.Name == "Dagger" then
        ConnectDaggerButton(obj)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    SearchForDagger()
end)

TwoTimeTab:CreateToggle({
    Name = "Backstab",
    CurrentValue = false,
    Flag = "BackstabToggle",

    Callback = function(Value)
        BackstabEnabled = Value

        if not Value then
            StopBackstab()
        end
    end,
})

TwoTimeTab:CreateInput({
    Name = "Distance Behind Killer",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,

    Callback = function(Text)
        local num = tonumber(Text)

        if num then
            BackstabDistance = num
        end
    end,
})

TwoTimeTab:CreateInput({
    Name = "Backstab Duration (s)",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,

    Callback = function(Text)
        local num = tonumber(Text)

        if num and num > 0 then
            BackstabDuration = num
        end
    end,
})

local KillerTab = Window:CreateTab("Killer", "skull")

local M1AimEnabled = false

local M1Buttons = {
    ["Slash"] = true,
    ["Stab"] = true,
    ["Carving Slash"] = true,
    ["Punch"] = true,
}

local M1ButtonConnections = {}

local function GetNearestPlayer()
    local character = player.Character
    if not character then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local nearestPlayer = nil
    local nearestDistance = math.huge

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local targetCharacter = targetPlayer.Character

            if targetCharacter then
                local targetRoot =
                    targetCharacter:FindFirstChild("HumanoidRootPart")

                if targetRoot then
                    local distance =
                        (root.Position - targetRoot.Position).Magnitude

                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = targetPlayer
                    end
                end
            end
        end
    end

    return nearestPlayer
end

local function DoM1Aim()
    if not M1AimEnabled then
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

    local targetPlayer = GetNearestPlayer()
    if not targetPlayer then
        return
    end

    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        return
    end

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetRoot then
        return
    end

    local startTime = tick()

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not M1AimEnabled then
            connection:Disconnect()
            return
        end

        if tick() - startTime >= 1 then
            connection:Disconnect()
            return
        end

        if not root.Parent or not targetRoot.Parent then
            connection:Disconnect()
            return
        end

        -- Aim 4 studs in front of the target
        local lookPosition =
            targetRoot.Position +
            targetRoot.CFrame.LookVector * 4

        -- Keep the player's Y position unchanged
        lookPosition = Vector3.new(
            lookPosition.X,
            root.Position.Y,
            lookPosition.Z
        )

        -- Rotate only, don't move
        root.CFrame = CFrame.lookAt(
            root.Position,
            lookPosition
        )
    end)
end

local function ConnectM1Button(button)
    if M1ButtonConnections[button] then
        M1ButtonConnections[button]:Disconnect()
    end

    M1ButtonConnections[button] =
        button.MouseButton1Click:Connect(function()
            DoM1Aim()
        end)
end

local function IsM1Button(obj)
    return (
        (obj:IsA("ImageButton") or obj:IsA("TextButton"))
        and M1Buttons[obj.Name] == true
    )
end

local function ScanM1Buttons()
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if IsM1Button(obj) then
            ConnectM1Button(obj)
        end
    end
end

ScanM1Buttons()

playerGui.DescendantAdded:Connect(function(obj)
    if IsM1Button(obj) then
        ConnectM1Button(obj)
    end
end)

KillerTab:CreateToggle({
    Name = "M1 Aim",
    CurrentValue = false,
    Flag = "M1Aim",

    Callback = function(Value)
        M1AimEnabled = Value
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
-- =========================
-- CREDITS
-- =========================

local CreditsTab = Window:CreateTab("Credits", "user")

CreditsTab:CreateParagraph({
    Title = "Owner",
    Content = "Useless Maper"
})

CreditsTab:CreateParagraph({
    Title = "Script Helper",
    Content = "RFS Discord"
})

CreditsTab:CreateParagraph({
    Title = "Idea Used",
    Content = "RFS Discord, Schmackrr"
})

CreditsTab:CreateParagraph({
    Title = "Thanks To",
    Content = "Thanks RFS for helping me!"
})

local DiscordTab = Window:CreateTab("Discord", "message-circle")

DiscordTab:CreateButton({
    Name = "RFS Discord",
    Callback = function()
        setclipboard("https://discord.gg/WcSKXjGtc")
    end,
})

DiscordTab:CreateButton({
    Name = "Schmackrr Discord",
    Callback = function()
        setclipboard("https://discord.gg/9GMmxPAAP")
    end,
})
