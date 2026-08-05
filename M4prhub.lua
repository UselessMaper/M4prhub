local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "M4pr Hub",
    LoadingTitle = "Thanks for using! :3",
    LoadingSubtitle = "by Useless Maper"
})
local ChanceTab = Window:CreateTab("Chance", 4483362458) -- Tab name, icon ID
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
            targetPos = root.Position + velocity.Unit * 3
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

ChanceTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
    Flag = "AutoAimToggle",
    Callback = function(Value)
        AutoAim = Value

        if AimConnection then
            AimConnection:Disconnect()
            AimConnection = nil
        end

        if AutoAim then
            print("Auto Aim Enabled")

            -- Find the Shoot ImageButton anywhere in PlayerGui
            local shootButton
            for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("ImageButton") and v.Name == "Shoot" then
                    shootButton = v
                    break
                end
            end

            if shootButton then
                AimConnection = shootButton.MouseButton1Click:Connect(function()
                    if AutoAim then
                        aimAtPrediction()
                    end
                end)
            else
                warn("Shoot ImageButton not found!")
            end
        else
            print("Auto Aim Disabled")
        end
    end,
})
