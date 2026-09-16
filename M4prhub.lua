local lier = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

local Window = lier:CreateWindow({
    Title = "M4pr Hub",
    Footer = "",
    Center = true,
    AutoShow = true,
})

local Options = lier.Options
local Toggles = lier.Toggles

local ChanceTab = Window:AddTab("Chance")

local AimGroup = ChanceTab:AddLeftGroupbox("")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AimV2Enabled = false
local AutoCoinFlip = false
local ShootConnection
local PredictionStuds = 4

local function ConnectShootButton(button)
    if ShootConnection then
        ShootConnection:Disconnect()
        ShootConnection = nil
    end

    ShootConnection = button.Activated:Connect(function()
        if not AimV2Enabled then
            return
        end

        local character = player.Character
        if not character then
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

if not root or not humanoid then
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

        local oldAutoRotate = humanoid.AutoRotate
humanoid.AutoRotate = false
        local startTime = tick()
        local connection

        connection = RunService.RenderStepped:Connect(function()
            if tick() - startTime >= 2 then
    humanoid.AutoRotate = oldAutoRotate
    connection:Disconnect()
    return
end

            if not root.Parent or not killerRoot.Parent then
    humanoid.AutoRotate = oldAutoRotate
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

AimGroup:AddToggle("AimV2", {
    Text = "Auto Aim",
    Default = false,

    Callback = function(Value)
        AimV2Enabled = Value
    end,
})

AimGroup:AddInput("Prediction", {
    Text = "Prediction",
    Default = "4",
    Placeholder = "4",
    Numeric = true,

    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            PredictionStuds = num
        end
    end,
})

AimGroup:AddToggle("AutoCoinFlip", {
    Text = "Auto CoinFlip",
    Default = false,

    Callback = function(Value)
        AutoCoinFlip = Value

        if Value then
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")

                local LocalPlayer = Players.LocalPlayer
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

                local Killers = workspace
                    :WaitForChild("Players")
                    :WaitForChild("Killers")

                local RemoteEvent = ReplicatedStorage
                    :WaitForChild("Modules")
                    :WaitForChild("Network")
                    :WaitForChild("Network")
                    :WaitForChild("RemoteEvent")

                local DISTANCE = 50

                local function IsKillerNearby(PlayerRoot)
                    for _, Killer in ipairs(Killers:GetChildren()) do
                        if Killer:IsA("Model") then
                            local KillerRoot = Killer:FindFirstChild("HumanoidRootPart")

                            if KillerRoot then
                                if (PlayerRoot.Position - KillerRoot.Position).Magnitude <= DISTANCE then
                                    return true
                                end
                            end
                        end
                    end

                    return false
                end

                while AutoCoinFlip do
                    task.wait(0.1)

                    local Character = LocalPlayer.Character
                    local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")

                    if not PlayerRoot then
                        continue
                    end

                    local MainUI = PlayerGui:FindFirstChild("MainUI")
                    if not MainUI then
                        continue
                    end

                    local AbilityContainer = MainUI:FindFirstChild("AbilityContainer")
                    if not AbilityContainer then
                        continue
                    end

                    local Reroll = AbilityContainer:FindFirstChild("Reroll")
                    local Charges = Reroll and Reroll:FindFirstChild("Charges")

                    if Charges
                        and Charges:IsA("TextLabel")
                        and Charges.Text ~= "3"
                        and not IsKillerNearby(PlayerRoot) then

                        RemoteEvent:FireServer("UseActorAbility", {"CoinFlip"})
                    end
                end
            end)
        end
    end,
})

local TwoTimeTab = Window:AddTab("Two Time")

local BackstabGroup = TwoTimeTab:AddLeftGroupbox("")

local BackstabEnabled = false
local BackstabDistance = 2
local BackstabDuration = 0.5

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
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

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

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

    local backstabPart = Instance.new("Part")

    backstabPart.Name = "BackstabPrimaryPart"
    backstabPart.Size = Vector3.new(1, 1, 1)
    backstabPart.Transparency = 1
    backstabPart.Anchored = true
    backstabPart.CanCollide = false
    backstabPart.CanTouch = false
    backstabPart.CanQuery = false

    backstabPart.CFrame =
        killerRoot.CFrame
        - killerRoot.CFrame.LookVector * BackstabDistance

    backstabPart.Parent = character
    character.PrimaryPart = backstabPart

    local startTime = tick()

    BackstabConnection = RunService.RenderStepped:Connect(function()
        local finished =
            not BackstabEnabled
            or not character.Parent
            or not backstabPart.Parent
            or not killer.Parent
            or not killerRoot.Parent
            or tick() - startTime >= BackstabDuration

        if finished then
            if BackstabConnection then
                BackstabConnection:Disconnect()
                BackstabConnection = nil
            end

            if backstabPart and backstabPart.Parent then
                backstabPart:Destroy()
            end

            if character.Parent
                and originalPrimaryPart
                and originalPrimaryPart.Parent then
                character.PrimaryPart = originalPrimaryPart
            end

            return
        end

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

    DaggerConnection = button.Activated:Connect(function()
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

BackstabGroup:AddToggle("Backstab", {
    Text = "Auto Backstab",
    Default = false,

    Callback = function(Value)
        BackstabEnabled = Value

        if not Value then
            StopBackstab()
        end
    end,
})

BackstabGroup:AddInput("BackstabDistance", {
    Text = "Distance Behind Killer",
    Default = "2",
    Placeholder = "2",
    Numeric = true,

    Callback = function(Text)
        local num = tonumber(Text)

        if num then
            BackstabDistance = num
        end
    end,
})

BackstabGroup:AddInput("BackstabDuration", {
    Text = "Backstab Duration (s)",
    Default = "0.5",
    Placeholder = "0.5",
    Numeric = true,

    Callback = function(Text)
        local num = tonumber(Text)

        if num and num > 0 then
            BackstabDuration = num
        end
    end,
})

local VeronicaTab = Window:AddTab("Veronica")

local AutoTrick = VeronicaTab:AddLeftGroupbox("")

AutoTrick:AddToggle("AutoTrick", {
    Text = "Auto Trick",
    Default = false,

    Callback = function(Value)
        if Value then
            -- ENABLE AUTO TRICK

            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local UserInputService = game:GetService("UserInputService")

            local device

            if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
                device = "PC"
            else
                device = "Mobile"
            end

            local behaviorFolder = ReplicatedStorage
                :WaitForChild("Assets")
                :WaitForChild("Survivors")
                :WaitForChild("Veeronica")
                :WaitForChild("Behavior")

            local function getSprintingButton()
                return player.PlayerGui
                    :WaitForChild("MainUI")
                    :WaitForChild("SprintingButton")
            end

            local activeMonitors = {}
            local descendantAddedConn

            local function monitorHighlight(h)
                if not h or activeMonitors[h] then
                    return
                end

                local connections = {}
                local prevState = false

                local function cleanup()
                    for _, conn in ipairs(connections) do
                        if conn and conn.Connected then
                            conn:Disconnect()
                        end
                    end

                    activeMonitors[h] = nil
                end

                local function isPlayerCharacter()
                    local adornee = h.Adornee
                    local char = player.Character

                    if not adornee or not char then
                        return false
                    end

                    return adornee == char or adornee:IsDescendantOf(char)
                end

                local function onChanged()
                    if not h.Parent then
                        cleanup()
                        return
                    end

                    local state = isPlayerCharacter()

                    if state and not prevState then
                        if device == "Mobile" then
                            local ok, btn = pcall(getSprintingButton)

                            if ok and btn then
                                for _, v in pairs(getconnections(btn.MouseButton1Down)) do
                                    pcall(function()
                                        v:Fire()
                                    end)

                                    pcall(function()
                                        if v.Function then
                                            v:Function()
                                        end
                                    end)
                                end
                            end

                        elseif device == "PC" then
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(
                                    true,
                                    Enum.KeyCode.Space,
                                    false,
                                    game
                                )

                                task.wait()

                                VirtualInputManager:SendKeyEvent(
                                    false,
                                    Enum.KeyCode.Space,
                                    false,
                                    game
                                )
                            end)
                        end
                    end

                    prevState = state
                end
                                table.insert(
                    connections,
                    h:GetPropertyChangedSignal("Adornee"):Connect(onChanged)
                )

                table.insert(
                    connections,
                    h.AncestryChanged:Connect(function(_, parent)
                        if not parent then
                            cleanup()
                        else
                            onChanged()
                        end
                    end)
                )

                table.insert(
                    connections,
                    player.CharacterAdded:Connect(onChanged)
                )

                activeMonitors[h] = cleanup

                task.spawn(onChanged)
            end

            for _, obj in ipairs(behaviorFolder:GetDescendants()) do
                if obj:IsA("Highlight") then
                    monitorHighlight(obj)
                end
            end

            descendantAddedConn = behaviorFolder.DescendantAdded:Connect(function(obj)
                if obj:IsA("Highlight") then
                    monitorHighlight(obj)
                end
            end)

            getgenv().AutoTrickCleanup = function()
                if descendantAddedConn then
                    descendantAddedConn:Disconnect()
                    descendantAddedConn = nil
                end

                for _, cleanup in pairs(activeMonitors) do
                    cleanup()
                end

                table.clear(activeMonitors)
            end

        else
            -- DISABLE AUTO TRICK
            if getgenv().AutoTrickCleanup then
                getgenv().AutoTrickCleanup()
                getgenv().AutoTrickCleanup = nil
            end
        end
    end,
})

local Sk8Enabled = false

local controlChargeActive = false
local overrideConnection = nil
local connection = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local shiftlockEnabled = false

local function setShiftlock(state)
    shiftlockEnabled = state

    if connection then
        connection:Disconnect()
        connection = nil
    end

    if shiftlockEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

        connection = RunService.RenderStepped:Connect(function()
            local character = lp.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then
                local camCF = workspace.CurrentCamera.CFrame

                root.CFrame = CFrame.new(
                    root.Position,
                    Vector3.new(
                        camCF.LookVector.X + root.Position.X,
                        root.Position.Y,
                        camCF.LookVector.Z + root.Position.Z
                    )
                )
            end
        end)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

local chargeAnimIds = {
    "117058860640843"
}

local ORIGINAL_DASH_SPEED = 60

local detectorChargeIds =
    (type(chargeAnimIds) == "table" and chargeAnimIds) or {}

local savedHumanoidState = {}

local function getHumanoid()
    if not lp or not lp.Character then
        return nil
    end

    return lp.Character:FindFirstChildOfClass("Humanoid")
end

local function saveHumState(hum)
    if not hum then
        return
    end

    if savedHumanoidState[hum] then
        return
    end

    local s = {}

    pcall(function()
        s.WalkSpeed = hum.WalkSpeed

        local ok = pcall(function()
            s.JumpPower = hum.JumpPower
        end)

        if not ok then
            pcall(function()
                s.JumpPower = hum.JumpHeight
            end)
        end

        local ok2, ar = pcall(function()
            return hum.AutoRotate
        end)

        if ok2 then
            s.AutoRotate = ar
        end

        s.PlatformStand = hum.PlatformStand
    end)

    savedHumanoidState[hum] = s
end
local function restoreHumState(hum)
    if not hum then
        return
    end

    local s = savedHumanoidState[hum]
    if not s then
        return
    end

    pcall(function()
        if s.WalkSpeed ~= nil then
            hum.WalkSpeed = s.WalkSpeed
        end

        if s.JumpPower ~= nil then
            local ok = pcall(function()
                hum.JumpPower = s.JumpPower
            end)

            if not ok then
                pcall(function()
                    hum.JumpHeight = s.JumpPower
                end)
            end
        end

        if s.AutoRotate ~= nil then
            pcall(function()
                hum.AutoRotate = s.AutoRotate
            end)
        end

        if s.PlatformStand ~= nil then
            hum.PlatformStand = s.PlatformStand
        end
    end)

    savedHumanoidState[hum] = nil
end

local function startOverride()
    if controlChargeActive then
        return
    end

    local hum = getHumanoid()
    if not hum then
        return
    end

    controlChargeActive = true
    saveHumState(hum)

    pcall(function()
        hum.WalkSpeed = ORIGINAL_DASH_SPEED
        hum.AutoRotate = false
    end)

    setShiftlock(true)

    overrideConnection = RunService.RenderStepped:Connect(function()
        local humanoid = getHumanoid()
        local rootPart =
            humanoid
            and humanoid.Parent
            and humanoid.Parent:FindFirstChild("HumanoidRootPart")

        if not humanoid or not rootPart then
            return
        end

        pcall(function()
            humanoid.WalkSpeed = ORIGINAL_DASH_SPEED
            humanoid.AutoRotate = false
        end)

        local direction = rootPart.CFrame.LookVector
        local horizontal = Vector3.new(direction.X, 0, direction.Z)

        if horizontal.Magnitude > 0 then
            humanoid:Move(horizontal.Unit)
        else
            humanoid:Move(Vector3.new(0, 0, 0))
        end
    end)
end

local function stopOverride()
    if not controlChargeActive then
        return
    end

    controlChargeActive = false

    if overrideConnection then
        pcall(function()
            overrideConnection:Disconnect()
        end)

        overrideConnection = nil
    end

    setShiftlock(false)

    local hum = getHumanoid()

    if hum then
        pcall(function()
            restoreHumState(hum)
            hum:Move(Vector3.new(0, 0, 0))
        end)
    end
end
local function detectChargeAnimation()
    local hum = getHumanoid()
    if not hum then
        return false
    end

    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local ok, animId = pcall(function()
            return tostring(
                track.Animation and track.Animation.AnimationId or ""
            ):match("%d+")
        end)

        if ok and animId and animId ~= "" then
            if detectorChargeIds and table.find(detectorChargeIds, animId) then
                return true
            end
        end
    end

    return false
end

lp.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 2)

        if hum then
            -- Optional initialization
        end
    end)
end)

local detectorLoop

detectorLoop = RunService.RenderStepped:Connect(function()
    if not Sk8Enabled then
        if controlChargeActive then
            stopOverride()
        end

        return
    end

    local hum = getHumanoid()

    if not hum then
        if controlChargeActive then
            stopOverride()
        end

        return
    end

    if detectChargeAnimation() then
        if not controlChargeActive then
            startOverride()
        end
    else
        if controlChargeActive then
            stopOverride()
        end
    end
end)

AutoTrick:AddToggle("Sk8Control", {
    Text = "Sk8 Control",
    Default = false,

    Callback = function(Value)
        Sk8Enabled = Value

        if Value then
            print("Sk8 Control ON")
        else
            print("Sk8 Control OFF")

            if controlChargeActive then
                stopOverride()
            end

            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end,
})

local Tab007n7 = Window:AddTab("007n7")

local RealClone = Tab007n7:AddLeftGroupbox("")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local AnimationTrack
local CloneConnection
local CurrentClone

local function StopAnimation()
    if AnimationTrack then
        AnimationTrack:Stop()
        AnimationTrack:Destroy()
        AnimationTrack = nil
    end
end

local function ConnectClone(Clone, StatusContainer)
    if CloneConnection then
        CloneConnection:Disconnect()
        CloneConnection = nil
    end

    CurrentClone = Clone

    CloneConnection = Clone.Activated:Connect(function()
        if not Enabled then
            return
        end

        if StatusContainer:FindFirstChild("Invisibility") then
            return
        end

        local Invisibility

        for i = 1, 10 do
            if not Enabled then
                return
            end

            Invisibility = StatusContainer:FindFirstChild("Invisibility")

            if Invisibility and Invisibility:IsA("ImageLabel") then
                break
            end

            task.wait(0.1)
        end

        if not Invisibility or not Invisibility:IsA("ImageLabel") then
            return
        end

        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            return
        end

        StopAnimation()

        local Animator = Humanoid:FindFirstChildOfClass("Animator")

        if not Animator then
            Animator = Instance.new("Animator")
            Animator.Parent = Humanoid
        end

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://115509603980568"

        AnimationTrack = Animator:LoadAnimation(Animation)
        AnimationTrack.Looped = true
        AnimationTrack:Play()
        AnimationTrack:AdjustSpeed(0)

        Invisibility.Destroying:Once(function()
            StopAnimation()
        end)
    end)
end

RealClone:AddToggle("RealClone", {
    Text = "True Clone",
    Default = false,

    Callback = function(Value)
        Enabled = Value

        if CloneConnection then
            CloneConnection:Disconnect()
            CloneConnection = nil
        end

        CurrentClone = nil
        StopAnimation()

        if not Enabled then
            return
        end

        task.spawn(function()
            while Enabled do
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local MainUI = PlayerGui and PlayerGui:FindFirstChild("MainUI")

                if MainUI then
                    local AbilityContainer = MainUI:FindFirstChild("AbilityContainer")
                    local StatusContainer = MainUI:FindFirstChild("StatusContainer")

                    if AbilityContainer and StatusContainer then
                        local Clone = AbilityContainer:FindFirstChild("Clone")

                        if Clone
                            and Clone:IsA("ImageButton")
                            and Clone ~= CurrentClone then
                            ConnectClone(Clone, StatusContainer)
                        end

                        if AnimationTrack
                            and not StatusContainer:FindFirstChild("Invisibility") then
                            StopAnimation()
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local AnimationIds = {
    ["rbxassetid://105458270463374"] = true,
    ["rbxassetid://106427068964975"] = true,
    ["rbxassetid://106538427162796"] = true,
    ["rbxassetid://106860049270347"] = true,
    ["rbxassetid://108196996477620"] = true,
    ["rbxassetid://109667959938617"] = true,
    ["rbxassetid://114126519127454"] = true,
    ["rbxassetid://114266653674439"] = true,
    ["rbxassetid://114506382930939"] = true,
    ["rbxassetid://116107946837042"] = true,
    ["rbxassetid://116618003477002"] = true,
    ["rbxassetid://118298475669935"] = true,
    ["rbxassetid://120112897026015"] = true,
    ["rbxassetid://121080480916189"] = true,
    ["rbxassetid://121293883585738"] = true,
    ["rbxassetid://121858217776572"] = true,
    ["rbxassetid://12222208"] = true,
    ["rbxassetid://122709416391891"] = true,
    ["rbxassetid://123172382755876"] = true,
    ["rbxassetid://123556520269026"] = true,
    ["rbxassetid://124269076578545"] = true,
    ["rbxassetid://124705663396411"] = true,
    ["rbxassetid://125403313786645"] = true,
    ["rbxassetid://126171487400618"] = true,
    ["rbxassetid://126830014841198"] = true,
    ["rbxassetid://127154365553241"] = true,
    ["rbxassetid://127245564598429"] = true,
    ["rbxassetid://129260077168659"] = true,
    ["rbxassetid://129405885079224"] = true,
    ["rbxassetid://129921445546291"] = true,
    ["rbxassetid://130321333480982"] = true,
    ["rbxassetid://130958529065375"] = true,
    ["rbxassetid://135853087227453"] = true,
    ["rbxassetid://138938529389204"] = true,
    ["rbxassetid://18885909645"] = true,
    ["rbxassetid://70371667919898"] = true,
    ["rbxassetid://70785407091644"] = true,
    ["rbxassetid://70948173568515"] = true,
    ["rbxassetid://74707328554358"] = true,
    ["rbxassetid://77375846492436"] = true,
    ["rbxassetid://80277760801310"] = true,
    ["rbxassetid://81299297965542"] = true,
    ["rbxassetid://81362825527808"] = true,
    ["rbxassetid://82843272472677"] = true,
    ["rbxassetid://83829782357897"] = true,
    ["rbxassetid://84069821282466"] = true,
    ["rbxassetid://87294535821555"] = true,
    ["rbxassetid://88451353906104"] = true,
    ["rbxassetid://88970503168421"] = true,
    ["rbxassetid://90620531468240"] = true,
    ["rbxassetid://91509234639766"] = true,
    ["rbxassetid://92567970681901"] = true,
    ["rbxassetid://93069721274110"] = true,
    ["rbxassetid://93366464803829"] = true,
    ["rbxassetid://94958041603347"] = true,
    ["rbxassetid://96587400766332"] = true,
    ["rbxassetid://99824350842479"] = true,
    ["rbxassetid://99829427721752"] = true,
}

local AutoClone = false
local Range = 15
local FacingCheck = false
local FacingDot = 0.5

local MonitoredModels = {}
local ModelConnections = {}

-- RemoteEvent
local RemoteEvent

do
    local Success, Result = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Modules", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("RemoteEvent", 10)
    end)

    if Success then
        RemoteEvent = Result
    else
        warn("[Auto Clone] Không tìm thấy RemoteEvent:", Result)
    end
end


-- =========================
-- UTILITY
-- =========================

local function GetRoot(Model)
    if not Model then
        return nil
    end

    return Model:FindFirstChild("HumanoidRootPart")
end


local function FireClone()
    if not RemoteEvent then
        return
    end

    local Success, Error = pcall(function()
        RemoteEvent:FireServer(
            "UseActorAbility",
            { "Clone" }
        )
    end)

    if not Success then
        warn("[Auto Clone] FireServer error:", Error)
    end
end


local function CheckFacing(KillerRoot, PlayerRoot)
    if not KillerRoot or not PlayerRoot then
        return false
    end

    local Offset = PlayerRoot.Position - KillerRoot.Position

    if Offset.Magnitude <= 0.001 then
        return true
    end

    local Direction = Offset.Unit
    local Dot = KillerRoot.CFrame.LookVector:Dot(Direction)

    return Dot >= FacingDot
end


-- =========================
-- REMOVE MODEL
-- =========================

local function RemoveModel(Model)
    local Connection = ModelConnections[Model]

    if Connection then
        Connection:Disconnect()
        ModelConnections[Model] = nil
    end

    MonitoredModels[Model] = nil
end


-- =========================
-- ANIMATION MONITOR
-- =========================

local function SetupAnimator(Model, Animator)
    if not AutoClone then
        return
    end

    if not Model or not Model.Parent then
        return
    end

    if not Animator or not Animator.Parent then
        return
    end

    -- Đã connect rồi thì không connect lần nữa
    if ModelConnections[Model] then
        return
    end

    ModelConnections[Model] = Animator.AnimationPlayed:Connect(function(Track)
        if not AutoClone then
            return
        end

        if not Model or not Model.Parent then
            RemoveModel(Model)
            return
        end

        if not Track then
            return
        end

        local Animation = Track.Animation

        if not Animation then
            return
        end

        local AnimationId = Animation.AnimationId

        if not AnimationId then
            return
        end

        -- Một số AnimationId có thể không đúng format
        if not AnimationIds[AnimationId] then
            return
        end

        -- Lấy character hiện tại
        local Character = LocalPlayer.Character

        if not Character or not Character.Parent then
            return
        end

        local PlayerRoot = GetRoot(Character)
        local KillerRoot = GetRoot(Model)

        if not PlayerRoot or not KillerRoot then
            return
        end

        -- Range check ngay lúc animation bắt đầu
        local Distance = (
            PlayerRoot.Position - KillerRoot.Position
        ).Magnitude

        if Distance > Range then
            return
        end

        -- Facing check
        if FacingCheck then
            if not CheckFacing(KillerRoot, PlayerRoot) then
                return
            end
        end

        FireClone()
    end)
end


-- =========================
-- MONITOR MODEL
-- =========================

local function MonitorModel(Model)
    if not AutoClone then
        return
    end

    if not Model or not Model:IsA("Model") then
        return
    end

    if not Model.Parent then
        return
    end

    if MonitoredModels[Model] then
        return
    end

    MonitoredModels[Model] = true

    task.spawn(function()
        while AutoClone and Model.Parent do
            local Humanoid = Model:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                local Animator = Humanoid:FindFirstChildOfClass("Animator")

                if Animator then
                    SetupAnimator(Model, Animator)
                    return
                end
            end

            task.wait(0.05)
        end

        -- Model bị remove hoặc AutoClone bị tắt
        if not AutoClone or not Model.Parent then
            RemoveModel(Model)
        end
    end)
end


-- =========================
-- CLEAR DEAD MODELS
-- =========================

local function ClearDeadModels()
    for Model in pairs(MonitoredModels) do
        if not Model or not Model.Parent then
            RemoveModel(Model)
        end
    end
end


-- =========================
-- STOP ALL
-- =========================

local function StopMonitoring()
    for Model, Connection in pairs(ModelConnections) do
        if Connection then
            Connection:Disconnect()
        end

        ModelConnections[Model] = nil
    end

    table.clear(MonitoredModels)
end


-- =========================
-- AUTO CLONE LOOP
-- =========================

local MonitorRunning = false

local function StartMonitoring()
    if MonitorRunning then
        return
    end

    MonitorRunning = true

    task.spawn(function()
        while AutoClone do
            local PlayersFolder = workspace:FindFirstChild("Players")
            local Killers = PlayersFolder
                and PlayersFolder:FindFirstChild("Killers")

            if Killers then
                for _, Model in ipairs(Killers:GetChildren()) do
                    if Model:IsA("Model") then
                        MonitorModel(Model)
                    end
                end
            end

            ClearDeadModels()

            task.wait(0.05)
        end

        StopMonitoring()
        MonitorRunning = false
    end)
end

-- =========================
-- AUTO CLONE TOGGLE
-- =========================

RealClone:AddToggle("AutoClone", {
    Text = "Auto Clone",
    Default = false,
    Callback = function(Value)
        AutoClone = Value

        if not AutoClone then
            StopMonitoring()
            return
        end

        StartMonitoring()
    end,
})


-- =========================
-- RANGE
-- =========================

RealClone:AddInput("CloneRange", {
    Text = "Range",
    Default = "15",
    Placeholder = "15",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)

        if Number then
            Range = math.max(0, Number)
        end
    end,
})

-- =========================
-- FACING CHECK
-- =========================

RealClone:AddToggle("FacingCheck", {
    Text = "Facing Check",
    Default = false,

    Callback = function(Value)
        FacingCheck = Value
    end,
})

-- =========================
-- DOT
-- =========================

RealClone:AddInput("FacingDot", {
    Text = "Dot",
    Default = "0.5",
    Placeholder = "0.5",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)

        if Number then
            FacingDot = math.clamp(Number, -1, 1)
        end
    end,
})

local Guest1337Tab = Window:AddTab("Guest1337")

local Guest1 = Guest1337Tab:AddLeftGroupbox("")

local ValidSounds = {
["rbxassetid://101199185291628"] = true,
["rbxassetid://101553872555606"] = true,
["rbxassetid://101698569375359"] = true,
["rbxassetid://104910828105172"] = true,
["rbxassetid://105204810054381"] = true,
["rbxassetid://105516183226360"] = true,
["rbxassetid://105840448036441"] = true,
["rbxassetid://106836941416453"] = true,
["rbxassetid://107444859834748"] = true,
["rbxassetid://108610718831698"] = true,
["rbxassetid://108651070773439"] = true,
["rbxassetid://108907358619313"] = true,
["rbxassetid://109348678063422"] = true,
["rbxassetid://109570290393196"] = true,
["rbxassetid://112809109188560"] = true,
["rbxassetid://113413858159336"] = true,
["rbxassetid://114742322778642"] = true,
["rbxassetid://115026634746636"] = true,
["rbxassetid://115678417928765"] = true,
["rbxassetid://116468089135195"] = true,
["rbxassetid://116581754553533"] = true,
["rbxassetid://117173212095661"] = true,
["rbxassetid://117231507259853"] = true,
["rbxassetid://118562842802948"] = true,
["rbxassetid://119583605486352"] = true,
["rbxassetid://119664480754070"] = true,
["rbxassetid://119942598489800"] = true,
["rbxassetid://120749612844426"] = true,
["rbxassetid://121954639447247"] = true,
["rbxassetid://12222216"] = true,
["rbxassetid://123497933758952"] = true,
["rbxassetid://123835423223220"] = true,
["rbxassetid://123923371062204"] = true,
["rbxassetid://124234993291213"] = true,
["rbxassetid://124903763333174"] = true,
["rbxassetid://125213046326879"] = true,
["rbxassetid://127557531826290"] = true,
["rbxassetid://128195973631079"] = true,
["rbxassetid://128367348686124"] = true,
["rbxassetid://128856426573270"] = true,
["rbxassetid://131123355704017"] = true,
["rbxassetid://131406927389838"] = true,
["rbxassetid://132581672170205"] = true,
["rbxassetid://133709029886490"] = true,
["rbxassetid://135319730390518"] = true,
["rbxassetid://136323728355613"] = true,
["rbxassetid://137809737339569"] = true,
["rbxassetid://139996647355899"] = true,
["rbxassetid://140242176732868"] = true,
["rbxassetid://18511965048"] = true,
["rbxassetid://70739368096233"] = true,
["rbxassetid://71805956520207"] = true,
["rbxassetid://73662192846371"] = true,
["rbxassetid://74809026448465"] = true,
["rbxassetid://74842815979546"] = true,
["rbxassetid://75330693422988"] = true,
["rbxassetid://76565307485888"] = true,
["rbxassetid://79391273191671"] = true,
["rbxassetid://79980897195554"] = true,
["rbxassetid://80516583309685"] = true,
["rbxassetid://82221759983649"] = true,
["rbxassetid://84307400688050"] = true,
["rbxassetid://85853080745515"] = true,
["rbxassetid://86174610237192"] = true,
["rbxassetid://88589682639517"] = true,
["rbxassetid://89004992452376"] = true,
["rbxassetid://94317217837143"] = true,
["rbxassetid://95079963655241"] = true,
["rbxassetid://96117920303138"] = true,
["rbxassetid://96594507550917"] = true,
["rbxassetid://98111231282218"] = true,
["rbxassetid://98675142200448"] = true,
["rbxassetid://98733709078792"] = true,
["rbxassetid://98742773509325"] = true,
["rbxassetid://99856718263455"] = true,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local KillersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent = ReplicatedStorage
:WaitForChild("Modules")
:WaitForChild("Network")
:WaitForChild("Network")
:WaitForChild("RemoteEvent")

local Guesting = false
local GuestRange = 15
local GuestFace = false
local GuestDot = 0.5
local PlayedOutside = {}
local Blocked = {}

Guest1:AddToggle("AB", {
Text = "Auto Block",
Default = false,
Callback = function(Value)
Guesting = Value

if Guesting then
task.spawn(function()
while Guesting do
local Character = LocalPlayer.Character
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

if HumanoidRootPart then  
            for _, Model in ipairs(KillersFolder:GetChildren()) do  
if Model:IsA("Model") then  
    local HRP = Model:FindFirstChild("HumanoidRootPart")  

        for _, Obj in ipairs(Model:GetDescendants()) do  
            if Obj:IsA("Sound") and ValidSounds[Obj.SoundId] then
            
            local InRange = HRP and (HumanoidRootPart.Position - HRP.Position).Magnitude <= GuestRange

if Obj.IsPlaying then
    local CanBlock = InRange

    if GuestFace and CanBlock then
        local Direction = (HumanoidRootPart.Position - HRP.Position).Unit
        local Dot = HRP.CFrame.LookVector:Dot(Direction)
        CanBlock = Dot > GuestDot
    end

    if PlayedOutside[Obj] == nil then
        PlayedOutside[Obj] = not CanBlock
    end

    if CanBlock and not PlayedOutside[Obj] and not Blocked[Obj] then
    Blocked[Obj] = true
    RemoteEvent:FireServer("UseActorAbility", {"Block"})
end
else
    PlayedOutside[Obj] = nil
    Blocked[Obj] = nil
end
break
end
end
end
end
end

task.wait(0.1)  
    end  
end)

end
end
})

Guest1:AddInput("ABRange", {
Text = "Range",
Default = "15",
Placeholder = "15",
Numeric = true,
Finished = true,

Callback = function(Value)  
    local Num = tonumber(Value)  
    if Num and Num > 0 then  
        GuestRange = Num  
    end  
end

})

Guest1:AddToggle("AbFace", {
Text = "Facing Check",
Default = false,

Callback = function(Value)  
    GuestFace = Value  
end

})

Guest1:AddInput("ABDot", {
Text = "Dot",
Default = "0.5",
Placeholder = "0.5",
Numeric = true,
Finished = true,

Callback = function(Value)  
    local Num = tonumber(Value)  
    if Num and Num >= -1 and Num <= 1 then  
        GuestDot = Num  
    end  
end

})

local ParrySounds = {
["rbxassetid://102808968188291"] = true,
["rbxassetid://114975236395509"] = true,
["rbxassetid://116616310968045"] = true,
["rbxassetid://117828699507982"] = true,
["rbxassetid://120902177402976"] = true,
["rbxassetid://123825742002486"] = true,
["rbxassetid://125854302746190"] = true,
["rbxassetid://132298811847315"] = true,
["rbxassetid://135209101640984"] = true,
["rbxassetid://18568553101"] = true,
["rbxassetid://423041300"] = true,
["rbxassetid://423041325"] = true,
["rbxassetid://423041356"] = true,
["rbxassetid://81114852524420"] = true,
["rbxassetid://82772022662025"] = true,
["rbxassetid://86208973578215"] = true,
["rbxassetid://91165993312513"] = true,
["rbxassetid://95135835034592"] = true,
}

local AutoParry = false
local ParryDelay = 0.5

Guest1:AddToggle("AP", {
    Text = "Auto Parry",
    Default = false,

    Callback = function(Value)
        AutoParry = Value

        if AutoParry then
            task.spawn(function()
                while AutoParry do
                    local Character = LocalPlayer.Character

                    if Character then
                        for _, Sound in ipairs(Character:GetDescendants()) do
                            if Sound:IsA("Sound")
                                and Sound.IsPlaying
                                and ParrySounds[Sound.SoundId] then

                                task.wait(ParryDelay)

                                if AutoParry and Sound.IsPlaying then
                                    RemoteEvent:FireServer("UseActorAbility", {"Punch"})
                                end

                                task.wait(0.3)
                                break
                            end
                        end
                    end

                    task.wait(0.05)
                end
            end)
        end
    end
})

Guest1:AddInput("APDelay", {
    Text = "Delay",
    Default = "0.5",
    Placeholder = "0.5",
    Numeric = true,
    Finished = true,

    Callback = function(Value)
        local Num = tonumber(Value)
        if Num and Num >= 0 then
            ParryDelay = Num
        end
    end
})

local AnimLook = false
local Looking = false
local PunchAimDistance = 4

local ValidAnimations = {
["rbxassetid://100129666722695"] = true,
["rbxassetid://108807732150251"] = true,
["rbxassetid://108911997126897"] = true,
["rbxassetid://111270184603402"] = true,
["rbxassetid://113936304594883"] = true,
["rbxassetid://114294293966030"] = true,
["rbxassetid://115877419084531"] = true,
["rbxassetid://119850211147676"] = true,
["rbxassetid://121347891120512"] = true,
["rbxassetid://122560631718612"] = true,
["rbxassetid://123142632470371"] = true,
["rbxassetid://127777649118195"] = true,
["rbxassetid://129843313690921"] = true,
["rbxassetid://132010205222516"] = true,
["rbxassetid://133398613783505"] = true,
["rbxassetid://135562195148584"] = true,
["rbxassetid://136007065400978"] = true,
["rbxassetid://138040001965654"] = true,
["rbxassetid://138936949998619"] = true,
["rbxassetid://140703210927645"] = true,
["rbxassetid://255661850"] = true,
["rbxassetid://71190646367497"] = true,
["rbxassetid://7130144078"] = true,
["rbxassetid://72007882634344"] = true,
["rbxassetid://72685103823181"] = true,
["rbxassetid://73737871217870"] = true,
["rbxassetid://73908019523515"] = true,
["rbxassetid://78440860685556"] = true,
["rbxassetid://81905101227053"] = true,
["rbxassetid://82137285150006"] = true,
["rbxassetid://83161312898155"] = true,
["rbxassetid://86096387000557"] = true,
["rbxassetid://86709774283672"] = true,
["rbxassetid://87259391926321"] = true,
["rbxassetid://90604236361267"] = true,
["rbxassetid://9113764330"] = true,
["rbxassetid://91730605416216"] = true,
["rbxassetid://91794561199608"] = true,
["rbxassetid://91810464218576"] = true,
["rbxassetid://94245829151472"] = true,
["rbxassetid://96190919614312"] = true,
["rbxassetid://99422325754526"] = true,
}

Guest1:AddToggle("AnimLook", {
    Text = "Punch Aim",
    Default = false,

    Callback = function(Value)
        AnimLook = Value

        if AnimLook then
            task.spawn(function()
                while AnimLook do
                    local Character = LocalPlayer.Character
                    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

                    if Humanoid and Root and not Looking then
                        for _, Track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
                            local Anim = Track.Animation

                            if Anim and ValidAnimations[Anim.AnimationId] then
                                local ClosestHRP
                                local ClosestDistance = math.huge

                                for _, Killer in ipairs(KillersFolder:GetChildren()) do
                                    local HRP = Killer:FindFirstChild("HumanoidRootPart")
                                    if HRP then
                                        local Distance = (Root.Position - HRP.Position).Magnitude
                                        if Distance < ClosestDistance then
                                            ClosestDistance = Distance
                                            ClosestHRP = HRP
                                        end
                                    end
                                end

                                if ClosestHRP then
                                    Looking = true

local OldAutoRotate = Humanoid.AutoRotate
Humanoid.AutoRotate = false

local EndTime = tick() + 0.5

while tick() < EndTime and AnimLook do
    local KillerModel = ClosestHRP.Parent
    local KillerHumanoid = KillerModel and KillerModel:FindFirstChildOfClass("Humanoid")

    if KillerHumanoid then
        local TargetPos = ClosestHRP.Position + KillerHumanoid.MoveDirection * PunchAimDistance

        Root.CFrame = CFrame.lookAt(
            Root.Position,
            Vector3.new(
                TargetPos.X,
                Root.Position.Y,
                TargetPos.Z
            )
        )
    end

    task.wait()
end

Humanoid.AutoRotate = OldAutoRotate
Looking = false
                                end

                                break
                            end
                        end
                    end

                    task.wait(0.03)
                end
            end)
        end
    end
})

Guest1:AddInput("PunchAimDistance", {
    Text = "Prediction",
    Default = "4",
    Placeholder = "4",
    Numeric = true,
    Finished = true,

    Callback = function(Value)
        local Num = tonumber(Value)
        if Num and Num >= 0 then
            PunchAimDistance = Num
        end
    end
})

local KillerTab = Window:AddTab("Killer")

local M1AimGroup = KillerTab:AddLeftGroupbox("")

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

        -- Keep player's position unchanged
        lookPosition = Vector3.new(
            lookPosition.X,
            root.Position.Y,
            lookPosition.Z
        )

        -- Rotate character only
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
        button.Activated:Connect(function()
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

M1AimGroup:AddToggle("M1Aim", {
    Text = "M1 Aim",
    Default = false,

    Callback = function(Value)
        M1AimEnabled = Value
    end,
})

local lolz = {}

if getgenv().emergency_stop == nil or not getgenv().emergency_stop then
    getgenv().emergency_stop = false
end

function StudsIntoPower(studs)
    return studs * 6
end

function lolz:ExtendHitbox(studs, time)
    local distance = StudsIntoPower(studs)
    local start = tick()

    if getgenv().emergency_stop == true then
        getgenv().emergency_stop = false
    end

    repeat
        game:GetService("RunService").Heartbeat:Wait()

        local velocity = nil

        while not (
            game:GetService("Players").LocalPlayer.Character
            and game:GetService("Players").LocalPlayer.Character.Parent
            and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
            and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent
        ) do
            game:GetService("RunService").Heartbeat:Wait()
        end

        local root = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
velocity = root.Velocity

root.Velocity = Vector3.new(
    velocity.X,
    velocity.Y,
    velocity.Z
) + (root.CFrame.LookVector * distance)

        game:GetService("RunService").RenderStepped:Wait()

        if (
            game:GetService("Players").LocalPlayer.Character
            and game:GetService("Players").LocalPlayer.Character.Parent
            and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
            and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent
        ) then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
        end

    until tick() - start > tonumber(time)
        or getgenv().emergency_stop == true

    if getgenv().emergency_stop == true then
        getgenv().emergency_stop = false
    end
end

function lolz:StopExtendingHitbox()
    getgenv().emergency_stop = true
end


--------------------------------------------------
-- HITBOX EXPANDER TOGGLE
--------------------------------------------------

local HitboxEnabled = false
local ButtonConnections = {}

local STUDS = 4
local TIME = 1

local allowedButtons = {
    ["Slash"] = true,
    ["Stab"] = true,
    ["Carving Slash"] = true,
    ["Punch"] = true
}

local function hookImageButton(button)
    if not button:IsA("ImageButton") then
        return
    end

    if not allowedButtons[button.Name] then
        return
    end

    button.Activated:Connect(function()
        if not HitboxEnabled then
            return
        end

        lolz:ExtendHitbox(STUDS, TIME)
    end)
end


-- Hook existing ImageButtons
for _, object in ipairs(game:GetDescendants()) do
    hookImageButton(object)
end


-- Hook ImageButtons created later
game.DescendantAdded:Connect(function(object)
    hookImageButton(object)
end)


M1AimGroup:AddToggle("HitboxExpander", {
    Text = "M1 Hitbox Expander",
    Default = false,

    Callback = function(Value)
        HitboxEnabled = Value

        if not Value then
            lolz:StopExtendingHitbox()
        end
    end,
})

M1AimGroup:AddInput("HitboxRange", {
    Text = "Range",
    Default = tostring(STUDS),
    Placeholder = "4",
    Numeric = true,

    Callback = function(Text)
        local number = tonumber(Text)

        if number then
            STUDS = number
        end
    end,
})

M1AimGroup:AddInput("HitboxDuration", {
    Text = "Duration",
    Default = tostring(TIME),
    Placeholder = "1",
    Numeric = true,

    Callback = function(Text)
        local number = tonumber(Text)

        if number then
            TIME = number
        end
    end,
})

M1AimGroup:AddDivider()
M1AimGroup:AddLabel("Helper Guy:")
M1AimGroup:AddLabel(":DO NOT SPAM ABILITY!!!")
M1AimGroup:AddDivider()

local PlayerTab = Window:AddTab("Player")

local InfiniteGroup = PlayerTab:AddLeftGroupbox("")

local Sprinting = game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting
local stamina = require(Sprinting)

local StaminaLossDisabled = false
local InfiniteStaminaToggle

-- Stored input values
local MaxStaminaValue = 100
local MinStaminaValue = 0
local StaminaGainValue = 20
local StaminaLossValue = 10
local SprintSpeedValue = 26

local InfStam = InfiniteGroup:AddToggle("InfiniteStamina", {
    Text = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        StaminaLossDisabled = Value

        if Value then
            stamina.MinStamina = -math.huge
        else
            stamina.MinStamina = 0
        end
    end,
})

InfiniteGroup:AddInput("MaxStamina", {
    Text = "Max Stamina",
    Default = "100",
    Placeholder = "100",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)
        if Number then
            MaxStaminaValue = Number
        end
    end,
})

InfiniteGroup:AddButton({
    Text = "Apply Max",

    Func = function()
        stamina.MaxStamina = MaxStaminaValue
    end,
})

InfiniteGroup:AddInput("MinStamina", {
    Text = "Min Stamina",
    Default = "0",
    Placeholder = "0",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)
        if Number then
            MinStaminaValue = Number
        end
    end,
})

InfiniteGroup:AddButton({
    Text = "Apply Min",

    Func = function()
    InfStam:SetValue(false)
        stamina.MinStamina = MinStaminaValue
    end,
})

InfiniteGroup:AddInput("StaminaGain", {
    Text = "Stamina Gain",
    Default = "20",
    Placeholder = "20",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)
        if Number then
            StaminaGainValue = Number
        end
    end,
})

InfiniteGroup:AddButton({
    Text = "Apply Gain",

    Func = function()
        stamina.StaminaGain = StaminaGainValue
    end,
})

InfiniteGroup:AddInput("StaminaLoss", {
    Text = "Stamina Loss",
    Default = "10",
    Placeholder = "10",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)
        if Number then
            StaminaLossValue = Number
        end
    end,
})

InfiniteGroup:AddButton({
    Text = "Apply Loss",

    Func = function()
        stamina.StaminaLoss = StaminaLossValue
    end,
})

InfiniteGroup:AddInput("SprintSpeed", {
    Text = "Sprint Speed",
    Default = "26",
    Placeholder = "26",
    Numeric = true,

    Callback = function(Text)
        local Number = tonumber(Text)
        if Number then
            SprintSpeedValue = Number
        end
    end,
})

InfiniteGroup:AddButton({
    Text = "Apply Speed",

    Func = function()
        stamina.SprintSpeed = SprintSpeedValue
    end,
})

local ESPTab = Window:AddTab("ESP")

local KillerGroup = ESPTab:AddLeftGroupbox("")

--------------------------------------------------
-- KILLER ESP
--------------------------------------------------

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

KillerGroup:AddToggle("KillerESP", {
    Text = "Killer",
    Default = false,

    Callback = function(Value)
        KillerESPEnabled = Value
        UpdateKillerESP()
    end,
})

--------------------------------------------------
-- SURVIVOR ESP
--------------------------------------------------

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

KillerGroup:AddToggle("SurvivorESP", {
    Text = "Survivor",
    Default = false,

    Callback = function(Value)
        SurvivorESPEnabled = Value
        UpdateSurvivorESP()
    end,
})

--------------------------------------------------
-- GENERATOR ESP
--------------------------------------------------

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

KillerGroup:AddToggle("GeneratorESP", {
    Text = "Generator",
    Default = false,

    Callback = function(Value)
        if Value then
            StartGeneratorESP()
        else
            StopGeneratorESP()
        end
    end,
})

local GeneratorTab = Window:AddTab("Generator")

local GeneratorGroup = GeneratorTab:AddLeftGroupbox("")

local AutoGen = false
local AutoGenDelay = 4

GeneratorGroup:AddToggle("AutoGen", {
    Text = "Auto Gen",
    Default = false,

    Callback = function(Value)
        AutoGen = Value

        if Value then
            task.spawn(function()
                while AutoGen do
                    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

                    local puzzleUI = playerGui:FindFirstChild("PuzzleUI")

                    if not puzzleUI then
                        puzzleUI = playerGui.ChildAdded:Wait()

                        if not AutoGen then
                            break
                        end

                        if puzzleUI.Name ~= "PuzzleUI" then
                            continue
                        end
                    end

                    task.wait(AutoGenDelay)

                    if not AutoGen then
                        break
                    end

                    if not puzzleUI.Parent then
                        continue
                    end

                    for _, generator in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
                        if not AutoGen then
                            break
                        end

                        if generator.Name == "Generator" then
                            local remotes = generator:FindFirstChild("Remotes")
                            local remote = remotes and remotes:FindFirstChild("RE")

                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer()
                            end
                        end
                    end
                end
            end)
        end
    end,
})

GeneratorGroup:AddInput("AutoGenDelay", {
    Text = "Delay",
    Default = "4",
    Placeholder = "4",
    Numeric = true,

    Callback = function(Value)
        local number = tonumber(Value)

        if number and number >= 0 then
            AutoGenDelay = number
        end
    end,
})

--------------------------------------------------
-- FUNNY
--------------------------------------------------

local FunnyTab = Window:AddTab("Funny")

local FunnyGroup = FunnyTab:AddLeftGroupbox("")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Connection

FunnyGroup:AddToggle("DieRunning", {
    Text = "Die Running",
    Default = false,

    Callback = function(Value)
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end

        if Value then
            Connection = RunService.Heartbeat:Connect(function()
                local Character = LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

                if Humanoid and RootPart then
                    local Velocity = RootPart.AssemblyLinearVelocity
                    local HorizontalSpeed =
                        Vector3.new(Velocity.X, 0, Velocity.Z).Magnitude

                    if HorizontalSpeed > 20 then
                        Humanoid.Health = 0
                    end
                end
            end)
        end
    end,
})

--------------------------------------------------
-- CREDITS
--------------------------------------------------

local CreditsTab = Window:AddTab("Credits")

local CreditsGroup = CreditsTab:AddLeftGroupbox("")

CreditsGroup:AddLabel("Owner:")
CreditsGroup:AddLabel("Useless Maper")
CreditsGroup:AddDivider()

CreditsGroup:AddLabel("Made By:")
CreditsGroup:AddLabel("Useless Maper and AI")
CreditsGroup:AddDivider()

CreditsGroup:AddLabel("Script Helper:")
CreditsGroup:AddLabel("RFS Discord")
CreditsGroup:AddDivider()

CreditsGroup:AddLabel("Idea Used:")
CreditsGroup:AddLabel("RFS Discord, Schmackrr")
CreditsGroup:AddDivider()

CreditsGroup:AddLabel("Thanks To:")
CreditsGroup:AddLabel("Thanks RFS for helping me!")

--------------------------------------------------
-- DISCORD
--------------------------------------------------

local DiscordTab = Window:AddTab("Discord")

local DiscordGroup = DiscordTab:AddLeftGroupbox("")

DiscordGroup:AddButton({
    Text = "RFS Discord",

    Func = function()
        setclipboard("https://discord.gg/WcSKXjGtc")
    end,
})

DiscordGroup:AddButton({
    Text = "Schmackrr Discord",

    Func = function()
        setclipboard("https://discord.gg/9GMmxPAAP")
    end,
})

local SettingsTab = Window:AddTab("Settings")

local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = lier.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(Value)
        lier.KeybindFrame.Visible = Value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = lier.ShowCustomCursor,
    Callback = function(Value)
        lier.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        lier:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        lier:SetDPIScale(tonumber(Value:gsub("%%", "")))
    end,
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = lier.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        Window:SetCornerRadius(Value)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu Bind")
    :AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu Keybind",
    })

MenuGroup:AddButton("Unload", function()
    lier:Unload()
end)

lier.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(lier)
SaveManager:SetLibrary(lier)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("M4prHub")
SaveManager:SetFolder("M4prHub")

ThemeManager:ApplyToTab(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()
ThemeManager:LoadDefault()
