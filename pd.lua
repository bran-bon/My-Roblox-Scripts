local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
end)

UserInputService.MouseBehavior = Enum.MouseBehavior.Default
GuiService.AutoSelectGuiEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "furhub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 420)
mainFrame.Position = UDim2.new(0, 50, 0, 150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 80, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Fur Hub"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -90, 1, 0)
tabContainer.Position = UDim2.new(0, 85, 0, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = topBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 2)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabContainer

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 10
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.Parent = tabContainer

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -10, 1, -45)
    container.Position = UDim2.new(0, 5, 0, 40)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.ScrollBarThickness = 4
    container.Visible = false
    container.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = container

    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        for _, b in ipairs(tabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                b.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        container.Visible = true
    end)

    return container
end

local visualsContainer = createTabButton("Visuals")
visualsContainer.Visible = true
local aimbotContainer = createTabButton("Aimbot")
local silentContainer = createTabButton("Silent")
local modsContainer = createTabButton("Mods")
local configContainer = createTabButton("Config")

for _, b in ipairs(tabContainer:GetChildren()) do
    if b:IsA("TextButton") and b.Text == "Visuals" then
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function createToggleUI(parent, name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    btn.Parent = parent

    local state = defaultState
    local updateState = function(newState, fireCallback)
        state = newState
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
        if fireCallback then
            callback(state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        updateState(not state, true)
    end)

    return btn, updateState
end

local function createButtonUI(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.Parent = parent

    btn.MouseButton1Click:Connect(function()
        callback()
    end)

    return btn
end

local function createDropdownUI(parent, name, options, initialVal, callback)
    local isOpen = false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 28)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.TextSize = 12
    mainBtn.Font = Enum.Font.SourceSansBold
    mainBtn.Text = name .. ": " .. tostring(initialVal)
    mainBtn.Parent = container

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 30)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 5
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local selectOpt = function(opt, fireCallback)
        mainBtn.Text = name .. ": " .. opt
        isOpen = false
        listFrame.Visible = false
        container.Size = UDim2.new(1, -10, 0, 28)
        if fireCallback then
            callback(opt)
        end
    end

    local function populateOptions(newOptions)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, opt in ipairs(newOptions) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 25)
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.SourceSansBold
            optBtn.Text = opt
            optBtn.ZIndex = 6
            optBtn.Parent = listFrame

            optBtn.MouseButton1Click:Connect(function()
                selectOpt(opt, true)
            end)
        end

        listFrame.Size = UDim2.new(1, 0, 0, #newOptions * 26)
    end

    populateOptions(options)

    mainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        if isOpen then
            container.Size = UDim2.new(1, -10, 0, 28 + listFrame.AbsoluteSize.Y)
        else
            container.Size = UDim2.new(1, -10, 0, 28)
        end
    end)

    return container, selectOpt, populateOptions
end

local function createSliderUI(parent, name, min, max, step, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 42)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 11
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name .. ": " .. tostring(defaultVal)
    label.Parent = container

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -10, 0, 10)
    sliderBar.Position = UDim2.new(0, 5, 0, 24)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local currentValue = defaultVal
    local draggingSlider = false

    local updateValuePos = function(val, fireCallback)
        currentValue = math.clamp(val, min, max)
        currentValue = math.floor(currentValue / step + 0.5) * step
        fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        label.Text = name .. ": " .. string.format(step < 1 and "%.2f" or "%.0f", currentValue)
        if fireCallback then
            callback(currentValue)
        end
    end

    local function updateValue(inputPos)
        local pos = math.clamp((inputPos - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local val = min + ((max - min) * pos)
        updateValuePos(val, true)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateValue(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    return container, updateValuePos
end

local function createKeybindUI(parent, name, defaultKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": [" .. defaultKey.Name .. "]"
    btn.Parent = parent

    local currentKey = defaultKey
    local binding = false

    local updateKey = function(newKey, fireCallback)
        currentKey = newKey
        btn.Text = name .. ": [" .. currentKey.Name .. "]"
        if fireCallback then
            callback(currentKey)
        end
    end

    btn.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        btn.Text = name .. ": [Press Key...]"
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                updateKey(input.KeyCode, true)
                binding = false
                connection:Disconnect()
            end
        end)
    end)

    return btn, updateKey
end

local playerESPEnabled = true
local gearESPEnabled = false
local npcESPEnabled = true
local noGrassEnabled = false
local fullbrightEnabled = false
local brightLoop = nil

local playerObjects = {}
local npcObjects = {}

local armorList = {
    ["6B2"] = true, ["6B23"] = true, ["6B27"] = true, ["6B43"] = true, ["6B47"] = true, ["6B5"] = true,
    ["AA2"] = true, ["Altyn"] = true, ["AltynVisor"] = true, ["Attak5"] = true,
    ["Bandoiler"] = true, ["ConcealedVest"] = true, ["DozerArmor"] = true, ["FastMT"] = true, ["FastVisor"] = true,
    ["GP5"] = true, ["GP5Filter"] = true, ["HSPV"] = true,
    ["IOTV4"] = true, ["JPC"] = true, ["LegArmor"] = true, ["LowCutVisor"] = true,
    ["Lvl4Plate"] = true, ["MaskaVisor"] = true, ["MotorcycleHelmet"] = true, ["MotorcycleHelmetVisor"] = true,
    ["ONV9"] = true, ["Pathfinder"] = true, ["QuadNVG"] = true, ["SPSh44"] = true, ["SSH68"] = true,
    ["ScavKingHelmet"] = true, ["ScavKingVest"] = true, ["Smersh"] = true,
    ["SpecopsBackpack"] = true, ["TankCap"] = true, ["UNOHelmet"] = true,
    ["UNOVest"] = true, ["WastelandBackpack"] = true,
    ["ZSh"] = true, ["ZShVisor"] = true
}

local function getPlayerGearInfo(char)
    if not gearESPEnabled then return "" end
    local items = {}

    local holstered = char:FindFirstChild("Holstered")
    if holstered then
        for _, valName in ipairs({"ItemBack1", "ItemBack2", "ItemHip1"}) do
            local objVal = holstered:FindFirstChild(valName)
            if objVal and objVal:IsA("ObjectValue") and objVal.Value then
                table.insert(items, objVal.Value.Name)
            elseif objVal and objVal:IsA("StringValue") and objVal.Value ~= "" then
                table.insert(items, objVal.Value)
            end
        end
    end

    for _, child in ipairs(char:GetChildren()) do
        if armorList[child.Name] then
            table.insert(items, child.Name)
        end
    end

    if #items > 0 then
        return "\n" .. table.concat(items, ", ")
    end
    return ""
end

local function createESPStruct(color)
    local espText = Drawing.new("Text")
    espText.Visible = false
    espText.Center = true
    espText.Outline = true
    espText.Font = 2
    espText.Size = 12
    espText.Color = color

    local boneLines = {}
    local boneList = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }
    for _, bone in ipairs(boneList) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        line.Color = color
        table.insert(boneLines, {line = line, p1 = bone[1], p2 = bone[2]})
    end

    return {Text = espText, Bones = boneLines}
end

local function removeESPStruct(struct)
    if struct then
        if struct.AncestryCon then struct.AncestryCon:Disconnect() end
        if struct.Text and struct.Text.Remove then struct.Text:Remove() end
        for _, b in ipairs(struct.Bones) do
            if b.line and b.line.Remove then b.line:Remove() end
        end
    end
end

local function removePlayerESP(player)
    if playerObjects[player] then
        removeESPStruct(playerObjects[player])
        playerObjects[player] = nil
    end
end

local function createPlayerESP(player)
    if player == LocalPlayer or playerObjects[player] then return end

    local struct = createESPStruct(Color3.new(1, 1, 1))
    playerObjects[player] = struct

    local ancestryCon
    ancestryCon = player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            ancestryCon:Disconnect()
            removePlayerESP(player)
        end
    end)
    struct.AncestryCon = ancestryCon
end

local function removeNPCESP(model)
    if npcObjects[model] then
        removeESPStruct(npcObjects[model])
        npcObjects[model] = nil
    end
end

local function createNPCESP(model)
    if npcObjects[model] or model == character then return end
    if not model:FindFirstChild("Humanoid") or not model:FindFirstChild("Head") then return end

    local struct = createESPStruct(Color3.new(1, 0.5, 0))
    npcObjects[model] = struct

    local ancestryCon
    ancestryCon = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            ancestryCon:Disconnect()
            removeNPCESP(model)
        end
    end)
    struct.AncestryCon = ancestryCon
end

local aiZones = Workspace:FindFirstChild("AiZones")
if aiZones then
    local function scanZone(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
                createNPCESP(obj)
            end
            scanZone(obj)
        end
    end

    scanZone(aiZones)

    aiZones.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            createNPCESP(obj)
        end
    end)

    aiZones.DescendantRemoving:Connect(function(obj)
        if npcObjects[obj] then
            removeNPCESP(obj)
        end
    end)
end

local function isVisible(targetPart, modelOrChar)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    
    local origin = cam.CFrame.Position
    local destination = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local filterList = {character}
    if modelOrChar then
        table.insert(filterList, modelOrChar)
    end
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.IgnoreWater = true

    local currentOrigin = origin
    
    while true do
        local success, result = pcall(function()
            return Workspace:Raycast(currentOrigin, (destination - currentOrigin).Unit * (destination - currentOrigin).Magnitude, raycastParams)
        end)
        if not success or not result then
            return true
        end
        
        local hitPart = result.Instance
        if hitPart then
            local isTransparent = hitPart.Transparency >= 1
            local notCollide = not hitPart.CanCollide
            local isSelfPart = modelOrChar and hitPart:IsDescendantOf(modelOrChar)
            
            if isTransparent or notCollide or isSelfPart then
                table.insert(filterList, hitPart)
                raycastParams.FilterDescendantsInstances = filterList
                currentOrigin = result.Position + ((destination - currentOrigin).Unit * 0.1)
                if (currentOrigin - destination).Magnitude < 0.1 then
                    return true
                end
            else
                return false
            end
        else
            return true
        end
    end
    
    return false
end

local AimbotMasterEnabled = true
local AimbotEnabled = false
local aimNpcEnabled = true
local smoothing = 0.2
local predictionFactor = 0.12
local AimPart = "Head"
local toggleKey = Enum.KeyCode.X
local guiToggleKey = Enum.KeyCode.RightShift
local noRecoilEnabled = false
local rapidFireEnabled = false

local currentTarget = nil
local TargetLoop = nil
local originalFireModes = {}
local originalRecoilValues = {}

local setAimbotMasterUI = nil
local setSilentAimUI = nil

local function isTargetValid(target)
    if target:IsA("Player") then
        local char = target.Character
        if char and char:FindFirstChild(AimPart) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            return true
        end
    elseif target:IsA("Model") then
        if aimNpcEnabled and target:FindFirstChild(AimPart) and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
            return true
        end
    end
    return false
end

local function getClosestTarget(cam)
    if not cam then return nil end
    local target = nil
    local closestMag = math.huge
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
           and player.Character 
           and player.Character:FindFirstChild(AimPart) 
           and player.Character:FindFirstChild("Humanoid") 
           and player.Character.Humanoid.Health > 0 then

            local char = player.Character
            local screenPoint, onScreen = cam:WorldToViewportPoint(char[AimPart].Position)
            local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude

            if onScreen then
                if distanceFromCenter < closestMag then
                    closestMag = distanceFromCenter
                    target = player
                end
            end
        end
    end

    if aimNpcEnabled then
        local aiZonesFolder = Workspace:FindFirstChild("AiZones")
        if aiZonesFolder then
            for _, zoneFolder in ipairs(aiZonesFolder:GetChildren()) do
                for _, npc in ipairs(zoneFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild(AimPart) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        local screenPoint, onScreen = cam:WorldToViewportPoint(npc[AimPart].Position)
                        local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        if onScreen then
                            if distanceFromCenter < closestMag then
                                closestMag = distanceFromCenter
                                target = npc
                            end
                        end
                    end
                end
            end
        end
    end

    return target
end

local function ResetTarget()
    if TargetLoop then
        TargetLoop:Disconnect()
        TargetLoop = nil
    end
    currentTarget = nil
end

local function AimbotLoop()
    TargetLoop = RunService.RenderStepped:Connect(function()
        if AimbotEnabled then
            local cam = Workspace.CurrentCamera
            if not cam then return end
            
            if not currentTarget or not isTargetValid(currentTarget) then
                currentTarget = getClosestTarget(cam)
            end

            if currentTarget then
                local part = nil
                if currentTarget:IsA("Player") then
                    part = currentTarget.Character and currentTarget.Character[AimPart]
                elseif currentTarget:IsA("Model") then
                    part = currentTarget[AimPart]
                end

                if part then
                    local predictedPosition = part.Position
                    if part.AssemblyLinearVelocity then
                        predictedPosition = predictedPosition + (part.AssemblyLinearVelocity * predictionFactor)
                    end
                    local newCFrame = CFrame.new(cam.CFrame.Position, predictedPosition)
                    cam.CFrame = cam.CFrame:Lerp(newCFrame, smoothing)
                end
            end
        end
    end)
end

local SilentAimEnabled = false
local TargetNpcs_S = true
local CircleVisible = true
local TriggerbotEnabled = false
local TriggerbotBurstLimit = 0

local SilentFOVRadius = 150
local SilentHitChance = 100

local TargetHead_S = true
local TargetUpperTorso_S = false
local TargetLowerTorso_S = false
local TargetLeftArm_S = false
local TargetRightArm_S = false
local TargetLeftLeg_S = false
local TargetRightLeg_S = false

local SilentCircle = Drawing.new("Circle")
SilentCircle.Radius = SilentFOVRadius
SilentCircle.Color = Color3.fromRGB(255, 255, 255)
SilentCircle.Thickness = 1.5
SilentCircle.Filled = false
SilentCircle.Transparency = 1
SilentCircle.Visible = false

local activeSilentTargetHead = nil
local isSilentTargetActive = false
local isTriggerbotHolding = false
local triggerbotShotCount = 0
local lastTriggerbotTime = 0

local function getValidHitParts(char)
    local parts = {}
    if TargetHead_S and char:FindFirstChild("Head") then table.insert(parts, char.Head) end
    if TargetUpperTorso_S and char:FindFirstChild("UpperTorso") then table.insert(parts, char.UpperTorso) end
    if TargetLowerTorso_S and char:FindFirstChild("LowerTorso") then table.insert(parts, char.LowerTorso) end
    if TargetLeftArm_S and char:FindFirstChild("LeftUpperArm") then table.insert(parts, char.LeftUpperArm) end
    if TargetRightArm_S and char:FindFirstChild("RightUpperArm") then table.insert(parts, char.RightUpperArm) end
    if TargetLeftLeg_S and char:FindFirstChild("LeftUpperLeg") then table.insert(parts, char.LeftUpperLeg) end
    if TargetRightLeg_S and char:FindFirstChild("RightUpperLeg") then table.insert(parts, char.RightUpperLeg) end
    return parts
end

local function getClosestSilentCharacter()
    local candidates = {}
    local mousePos = UserInputService:GetMouseLocation()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local parts = getValidHitParts(char)
            if hum and hum.Health > 0 and #parts > 0 then
                local head = char:FindFirstChild("Head") or parts[1]
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= SilentFOVRadius then
                        table.insert(candidates, {char = char, dist = dist, parts = parts})
                    end
                end
            end
        end
    end

    if TargetNpcs_S then
        local aiZonesFolder = Workspace:FindFirstChild("AiZones")
        if aiZonesFolder then
            for _, zoneFolder in ipairs(aiZonesFolder:GetChildren()) do
                for _, npc in ipairs(zoneFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        local parts = getValidHitParts(npc)
                        if #parts > 0 then
                            local head = npc:FindFirstChild("Head") or parts[1]
                            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist <= SilentFOVRadius then
                                    table.insert(candidates, {char = npc, dist = dist, parts = parts})
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.dist < b.dist
    end)

    for _, candidate in ipairs(candidates) do
        for _, part in ipairs(candidate.parts) do
            if isVisible(part, candidate.char) then
                return candidate.char, part
            end
        end
    end

    if #candidates > 0 then
        local candidate = candidates[1]
        local parts = candidate.parts
        local hitPart = parts[math.random(1, #parts)]
        return candidate.char, hitPart
    end

    return nil, nil
end

RunService.RenderStepped:Connect(function()
    if not SilentAimEnabled then
        SilentCircle.Visible = false
        isSilentTargetActive = false
        activeSilentTargetHead = nil
        if isTriggerbotHolding then
            pcall(function()
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
            isTriggerbotHolding = false
        end
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    SilentCircle.Position = mousePos
    SilentCircle.Radius = SilentFOVRadius
    SilentCircle.Visible = CircleVisible

    local targetChar, hitPart = getClosestSilentCharacter()
    if targetChar and hitPart then
        if math.random(1, 100) <= SilentHitChance then
            activeSilentTargetHead = hitPart
            isSilentTargetActive = true
        else
            activeSilentTargetHead = nil
            isSilentTargetActive = false
        end

        if TriggerbotEnabled then
            local visible = isVisible(hitPart, targetChar)
            if visible and SilentAimEnabled and isSilentTargetActive and activeSilentTargetHead then
                local currentTime = os.clock()
                local canShoot = true
                if not rapidFireEnabled then
                    if currentTime - lastTriggerbotTime < 0.25 then
                        canShoot = false
                    end
                end

                if canShoot then
                    if TriggerbotBurstLimit > 0 and rapidFireEnabled then
                        triggerbotShotCount = triggerbotShotCount + 1
                        if triggerbotShotCount > TriggerbotBurstLimit then
                            if isTriggerbotHolding then
                                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
                                isTriggerbotHolding = false
                            end
                            canShoot = false
                        end
                    end

                    if canShoot then
                        if not isTriggerbotHolding then
                            pcall(function()
                                VirtualUser:Button1Down(Vector2.new(0,0))
                            end)
                            isTriggerbotHolding = true
                            lastTriggerbotTime = currentTime
                        end
                    end
                end
            else
                if isTriggerbotHolding then
                    pcall(function()
                        VirtualUser:Button1Up(Vector2.new(0,0))
                    end)
                    isTriggerbotHolding = false
                end
                triggerbotShotCount = 0
            end
        end
    else
        activeSilentTargetHead = nil
        isSilentTargetActive = false
        if isTriggerbotHolding then
            pcall(function()
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
            isTriggerbotHolding = false
        end
        triggerbotShotCount = 0
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if SilentAimEnabled and isSilentTargetActive then
        local args = {...}
        
        if method == "Raycast" and self == Workspace then
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and activeSilentTargetHead then
                local targetPos = activeSilentTargetHead.Position
                args[2] = (targetPos - origin).Unit * direction.Magnitude
                return oldNamecall(self, unpack(args))
            end
        elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
            local ray = args[1]
            if typeof(ray) == "Ray" and activeSilentTargetHead then
                local targetPos = activeSilentTargetHead.Position
                args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * ray.Direction.Magnitude)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

local oldRaycast
if Workspace.Raycast then
    oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, ...)
        if SilentAimEnabled and isSilentTargetActive and activeSilentTargetHead and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
            local targetPos = activeSilentTargetHead.Position
            direction = (targetPos - origin).Unit * direction.Magnitude
        end
        return oldRaycast(self, origin, direction, ...)
    end)
end

RunService.RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local localHRP = character.HumanoidRootPart
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local mousePos = UserInputService:GetMouseLocation()

    local fovGreenTriggered = false

    for player, drawings in pairs(playerObjects) do
        if not player.Parent then
            removePlayerESP(player)
        else
            local char = player.Character
            if char and char:FindFirstChild("Head") and playerESPEnabled then
                local head = char.Head
                local distance = (head.Position - localHRP.Position).Magnitude
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)

                if onScreen then
                    local isAimbotTarget = (AimbotEnabled and currentTarget and currentTarget == player)
                    local isInsideSilentFOV = false
                    if SilentAimEnabled then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distToMouse <= SilentFOVRadius then
                            isInsideSilentFOV = true
                        end
                    end

                    local visible = false
                    if isAimbotTarget then
                        visible = isVisible(head, char)
                    elseif isInsideSilentFOV and SilentAimEnabled then
                        visible = isVisible(head, char)
                        if visible then
                            fovGreenTriggered = true
                        end
                    end

                    local espColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)

                    drawings.Text.Color = espColor
                    for _, bone in ipairs(drawings.Bones) do
                        bone.line.Color = espColor
                    end

                    local gearInfo = getPlayerGearInfo(char)
                    drawings.Text.Text = string.format("%s [%.0fm]%s", player.Name, distance, gearInfo)
                    drawings.Text.Center = true
                    drawings.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    drawings.Text.Visible = true

                    for _, bone in ipairs(drawings.Bones) do
                        local part1 = char:FindFirstChild(bone.p1)
                        local part2 = char:FindFirstChild(bone.p2)
                        if part1 and part2 then
                            local p1Screen, p1On = cam:WorldToViewportPoint(part1.Position)
                            local p2Screen, p2On = cam:WorldToViewportPoint(part2.Position)
                            if p1On and p2On then
                                bone.line.From = Vector2.new(p1Screen.X, p1Screen.Y)
                                bone.line.To = Vector2.new(p2Screen.X, p2Screen.Y)
                                bone.line.Visible = true
                            else
                                bone.line.Visible = false
                            end
                        else
                            bone.line.Visible = false
                        end
                    end
                else
                    drawings.Text.Visible = false
                    for _, bone in ipairs(drawings.Bones) do bone.line.Visible = false end
                end
            else
                drawings.Text.Visible = false
                for _, bone in ipairs(drawings.Bones) do bone.line.Visible = false end
            end
        end
    end

    for model, drawings in pairs(npcObjects) do
        if not model.Parent then
            removeNPCESP(model)
        else
            if model:FindFirstChild("Head") and npcESPEnabled then
                local head = model.Head
                local distance = (head.Position - localHRP.Position).Magnitude
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)

                if onScreen then
                    local isAimbotTarget = (AimbotEnabled and currentTarget and currentTarget == model)
                    local isInsideSilentFOV = false
                    if SilentAimEnabled then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distToMouse <= SilentFOVRadius then
                            isInsideSilentFOV = true
                        end
                    end

                    local visible = false
                    if isAimbotTarget then
                        visible = isVisible(head, model)
                    elseif isInsideSilentFOV and SilentAimEnabled then
                        visible = isVisible(head, model)
                        if visible then
                            fovGreenTriggered = true
                        end
                    end

                    local espColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0)

                    drawings.Text.Color = espColor
                    for _, bone in ipairs(drawings.Bones) do
                        bone.line.Color = espColor
                    end

                    drawings.Text.Text = string.format("%s [%.0fm]", model.Name, distance)
                    drawings.Text.Center = true
                    drawings.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    drawings.Text.Visible = true

                    for _, bone in ipairs(drawings.Bones) do
                        local part1 = model:FindFirstChild(bone.p1)
                        local part2 = model:FindFirstChild(bone.p2)
                        if part1 and part2 then
                            local p1Screen, p1On = cam:WorldToViewportPoint(part1.Position)
                            local p2Screen, p2On = cam:WorldToViewportPoint(part2.Position)
                            if p1On and p2On then
                                bone.line.From = Vector2.new(p1Screen.X, p1Screen.Y)
                                bone.line.To = Vector2.new(p2Screen.X, p2Screen.Y)
                                bone.line.Visible = true
                            else
                                bone.line.Visible = false
                            end
                        else
                            bone.line.Visible = false
                        end
                    end
                else
                    drawings.Text.Visible = false
                    for _, bone in ipairs(drawings.Bones) do bone.line.Visible = false end
                end
            else
                drawings.Text.Visible = false
                for _, bone in ipairs(drawings.Bones) do bone.line.Visible = false end
            end
        end
    end

    if SilentAimEnabled then
        if fovGreenTriggered or (AimbotEnabled and currentTarget and isVisible(currentTarget:IsA("Player") and currentTarget.Character.Head or currentTarget.Head, currentTarget:IsA("Player") and currentTarget.Character or currentTarget)) then
            SilentCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            SilentCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then createPlayerESP(player) end
        player.CharacterAdded:Connect(function() createPlayerESP(player) end)
    end
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createPlayerESP(player) end)
end)
Players.PlayerRemoving:Connect(function(player) removePlayerESP(player) end)

local _, setPlayerESP = createToggleUI(visualsContainer, "Player ESP", playerESPEnabled, function(val)
    playerESPEnabled = val
    if not val then
        for _, d in pairs(playerObjects) do
            d.Text.Visible = false
            for _, b in ipairs(d.Bones) do b.line.Visible = false end
        end
    end
end)

local _, setGearESP = createToggleUI(visualsContainer, "Gear ESP", gearESPEnabled, function(val)
    gearESPEnabled = val
end)

local _, setNpcESP = createToggleUI(visualsContainer, "NPC ESP", npcESPEnabled, function(val)
    npcESPEnabled = val
    if not val then
        for _, d in pairs(npcObjects) do
            d.Text.Visible = false
            for _, b in ipairs(d.Bones) do b.line.Visible = false end
        end
    end
end)

createButtonUI(visualsContainer, "Remove Visors & Flashbang", function()
    local noInset = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("NoInsetGui")
    if noInset then
        local mainF = noInset:FindFirstChild("MainFrame")
        if mainF then
            local effects = mainF:FindFirstChild("ScreenEffects")
            if effects then
                local vFolder = effects:FindFirstChild("Visor")
                if vFolder then vFolder:Destroy() end
                local mFolder = effects:FindFirstChild("Mask")
                if mFolder then mFolder:Destroy() end
                local fFolder = effects:FindFirstChild("Flashbang")
                if fFolder then fFolder:Destroy() end
            end
        end
    end
end)

createButtonUI(visualsContainer, "Enable Third Person", function()
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    LocalPlayer.CameraMaxZoomDistance = 400
    LocalPlayer.CameraMinZoomDistance = 0.5
end)

local _, setNoGrass = createToggleUI(visualsContainer, "No Grass", noGrassEnabled, function(val)
    noGrassEnabled = val
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Terrain") then
            sethiddenproperty(item, "Decoration", not val)
        end
    end
end)

local _, setFullbright = createToggleUI(visualsContainer, "Fullbright", fullbrightEnabled, function(val)
    fullbrightEnabled = val
    if val then
        if brightLoop then
            brightLoop:Disconnect()
        end
        local function brightFunc()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
        brightLoop = RunService.RenderStepped:Connect(brightFunc)
    else
        if brightLoop then
            brightLoop:Disconnect()
            brightLoop = nil
        end
    end
end)

oldWait = hookfunction(task.wait, function(n)
    if rapidFireEnabled then
        local source = debug.info(2, "s") or ""
        if string.find(source, "FPS") or string.find(source, "Bullet") then
            return oldWait(0)
        end
    end
    return oldWait(n)
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if rapidFireEnabled then
            local itemsList = ReplicatedStorage:FindFirstChild("ItemsList")
            if itemsList then
                for _, v in ipairs(itemsList:GetChildren()) do
                    local settingsMod = v:FindFirstChild("SettingsModule")
                    if settingsMod then
                        local success, settings = pcall(require, settingsMod)
                        if success and type(settings) == "table" then
                            if not originalFireModes[settings] then
                                local clonedModes = nil
                                if type(settings.FireModes) == "table" then
                                    clonedModes = {}
                                    for idx, mode in ipairs(settings.FireModes) do
                                        clonedModes[idx] = mode
                                    end
                                end
                                originalFireModes[settings] = {
                                    FireMode = settings.FireMode,
                                    FireModes = clonedModes,
                                    FireRate = settings.FireRate,
                                    CycleTiming = settings.CycleTiming
                                }
                            end

                            if settings.FireMode == "Semi" or settings.FireMode == "Bolt Action" then
                                settings.FireMode = "Auto"
                            end
                            if type(settings.FireModes) == "table" then
                                for idx, mode in ipairs(settings.FireModes) do
                                    if mode == "Semi" or mode == "Bolt Action" then
                                        settings.FireModes[idx] = "Auto"
                                    end
                                end
                            end
                            settings.FireRate = 0
                            settings.CycleTiming = {0, 0}
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == guiToggleKey then
        mainFrame.Visible = not mainFrame.Visible
        return
    end

    if gameProcessedEvent or not AimbotMasterEnabled then return end
    if input.KeyCode == toggleKey then
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            if SilentAimEnabled then
                SilentAimEnabled = false
                if setSilentAimUI then
                    setSilentAimUI(false, false)
                end
            end
            ResetTarget()
            AimbotLoop()
        else
            ResetTarget()
        end
    end
end)

_, setAimbotMasterUI = createToggleUI(aimbotContainer, "Aimbot", AimbotMasterEnabled, function(val)
    AimbotMasterEnabled = val
    if AimbotMasterEnabled then
        if SilentAimEnabled then
            SilentAimEnabled = false
            if setSilentAimUI then
                setSilentAimUI(false, false)
            end
        end
    else
        AimbotEnabled = false
        ResetTarget()
    end
end)

local _, setAimNpc = createToggleUI(aimbotContainer, "Aim NPCs", aimNpcEnabled, function(val)
    aimNpcEnabled = val
    if not val and currentTarget and currentTarget:IsA("Model") then
        ResetTarget()
    end
end)

local _, setToggleKey = createKeybindUI(aimbotContainer, "Aimbot Key", toggleKey, function(key)
    toggleKey = key
end)

local _, setAimPart = createDropdownUI(aimbotContainer, "Aim Part", {"Head", "UpperTorso", "LowerTorso"}, "Head", function(val)
    AimPart = val
end)

local _, setSmoothing = createSliderUI(aimbotContainer, "Smoothing", 0.01, 1, 0.01, smoothing, function(val)
    smoothing = val
end)

local _, setPrediction = createSliderUI(aimbotContainer, "Prediction", 0, 0.5, 0.01, predictionFactor, function(val)
    predictionFactor = val
end)

_, setSilentAimUI = createToggleUI(silentContainer, "Silent Aim", SilentAimEnabled, function(val)
    SilentAimEnabled = val
    if SilentAimEnabled then
        AimbotEnabled = false
        ResetTarget()
        if setAimbotMasterUI then
            setAimbotMasterUI(false, false)
        end
    else
        if isTriggerbotHolding then
            pcall(function()
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
            isTriggerbotHolding = false
        end
    end
end)

createToggleUI(silentContainer, "FOV Circle", CircleVisible, function(val)
    CircleVisible = val
end)

createToggleUI(silentContainer, "Triggerbot", TriggerbotEnabled, function(val)
    TriggerbotEnabled = val
    if not val and isTriggerbotHolding then
        pcall(function()
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
        isTriggerbotHolding = false
    end
end)

createSliderUI(silentContainer, "Burst Limit", 0, 15, 1, TriggerbotBurstLimit, function(val)
    TriggerbotBurstLimit = val
end)

createToggleUI(silentContainer, "Target NPCs", TargetNpcs_S, function(val)
    TargetNpcs_S = val
end)

createToggleUI(silentContainer, "Target Head", TargetHead_S, function(val)
    TargetHead_S = val
end)

createToggleUI(silentContainer, "Target UpperTorso", TargetUpperTorso_S, function(val)
    TargetUpperTorso_S = val
end)

createToggleUI(silentContainer, "Target LowerTorso", TargetLowerTorso_S, function(val)
    TargetLowerTorso_S = val
end)

createSliderUI(silentContainer, "FOV Radius", 20, 400, 5, SilentFOVRadius, function(val)
    SilentFOVRadius = val
end)

createSliderUI(silentContainer, "Hit Chance", 10, 100, 5, SilentHitChance, function(val)
    SilentHitChance = val
end)

local _, setNoRecoil = createToggleUI(modsContainer, "No Recoil", noRecoilEnabled, function(val)
    noRecoilEnabled = val
    local rangedWeapons = ReplicatedStorage:FindFirstChild("RangedWeapons")
    if not rangedWeapons then return end

    if val then
        originalRecoilValues = {}
        for _, desc in ipairs(rangedWeapons:GetDescendants()) do
            if desc:IsA("NumberValue") and (desc.Name == "x" or desc.Name == "y") then
                originalRecoilValues[desc] = desc.Value
                desc.Value = 0
            end
        end
    else
        for desc, origVal in pairs(originalRecoilValues) do
            if desc and desc.Parent then
                desc.Value = origVal
            end
        end
        originalRecoilValues = {}
    end
end)

local _, setRapidFire = createToggleUI(modsContainer, "Rapid Fire", rapidFireEnabled, function(val)
    rapidFireEnabled = val
    if not val then
        for tbl, original in pairs(originalFireModes) do
            if type(tbl) == "table" then
                if original.FireMode ~= nil then tbl.FireMode = original.FireMode end
                if original.FireModes ~= nil then
                    tbl.FireModes = {}
                    for idx, mode in ipairs(original.FireModes) do
                        tbl.FireModes[idx] = mode
                    end
                end
                if original.Rate ~= nil then tbl.FireRate = original.FireRate end
                if original.CycleTiming ~= nil then tbl.CycleTiming = original.CycleTiming end
            end
        end
        originalFireModes = {}
    end
end)

createKeybindUI(configContainer, "GUI Toggle Key", guiToggleKey, function(key)
    guiToggleKey = key
end)

local HttpService = game:GetService("HttpService")
local folderName = "FurHubConfigs"

if not isfolder(folderName) then
    makefolder(folderName)
end

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1, -10, 0, 28)
configNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
configNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameBox.TextSize = 12
configNameBox.Font = Enum.Font.SourceSansBold
configNameBox.PlaceholderText = "Enter Config Name..."
configNameBox.Text = ""
configNameBox.Parent = configContainer

local function getConfigsList()
    local files = listfiles(folderName)
    local list = {}
    for _, file in ipairs(files) do
        local name = file:match("[/\\]([^/\\]+)$") or file
        name = name:gsub("%.json$", "")
        if name ~= "" and name ~= "default" then
            table.insert(list, name)
        end
    end
    return list
end

local initialList = getConfigsList()
local initialSelection = #initialList > 0 and initialList[1] or ""

local loadDropdownContainer, selectLoadOpt, updateLoadDropdown = createDropdownUI(configContainer, "Load Config", initialList, initialSelection, function(val)
    configNameBox.Text = val
end)

if initialSelection ~= "" then
    configNameBox.Text = initialSelection
end

local function refreshDropdown()
    local list = getConfigsList()
    updateLoadDropdown(list)
    if #list > 0 and (configNameBox.Text == "" or not table.find(list, configNameBox.Text)) then
        configNameBox.Text = list[1]
    elseif #list == 0 then
        configNameBox.Text = ""
    end
end

local function saveCurrentConfig()
    local cfgName = configNameBox.Text
    if cfgName == "" or cfgName == "default" then return end

    local data = {
        playerESP = playerESPEnabled,
        gearESP = gearESPEnabled,
        npcESP = npcESPEnabled,
        noGrass = noGrassEnabled,
        fullbright = fullbrightEnabled,
        aimbotMaster = AimbotMasterEnabled,
        aimNpc = aimNpcEnabled,
        smoothing = smoothing,
        predictionFactor = predictionFactor,
        aimPart = AimPart,
        toggleKey = toggleKey.Name,
        guiToggleKey = guiToggleKey.Name,
        noRecoil = noRecoilEnabled,
        rapidFire = rapidFireEnabled,
        silentAim = SilentAimEnabled,
        circleVisible = CircleVisible,
        triggerbot = TriggerbotEnabled,
        burstLimit = TriggerbotBurstLimit,
        silentFOV = SilentFOVRadius,
        silentHitChance = SilentHitChance
    }

    local encoded = HttpService:JSONEncode(data)
    writefile(folderName .. "/" .. cfgName .. ".json", encoded)
    refreshDropdown()
end

local function loadConfigByName(cfgName)
    if cfgName == "" or cfgName == "default" then return end
    local path = folderName .. "/" .. cfgName .. ".json"
    if not isfile(path) then return end

    local success, result = pcall(function()
        return readfile(path)
    end)

    if success and result then
        local successDec, data = pcall(function()
            return HttpService:JSONDecode(result)
        end)

        if successDec and data then
            if data.playerESP ~= nil then setPlayerESP(data.playerESP, true) end
            if data.gearESP ~= nil then setGearESP(data.gearESP, true) end
            if data.npcESP ~= nil then setNpcESP(data.npcESP, true) end
            if data.noGrass ~= nil then setNoGrass(data.noGrass, true) end
            if data.fullbright ~= nil then setFullbright(data.fullbright, true) end
            if data.aimbotMaster ~= nil then setAimbotMasterUI(data.aimbotMaster, true) end
            if data.aimNpc ~= nil then setAimNpc(data.aimNpc, true) end
            if data.smoothing ~= nil then setSmoothing(data.smoothing, true) end
            if data.predictionFactor ~= nil then setPrediction(data.predictionFactor, true) end
            if data.aimPart ~= nil then setAimPart(data.aimPart, true) end
            if data.toggleKey ~= nil and Enum.KeyCode[data.toggleKey] then setToggleKey(Enum.KeyCode[data.toggleKey], true) end
            if data.guiToggleKey ~= nil and Enum.KeyCode[data.guiToggleKey] then guiToggleKey = Enum.KeyCode[data.guiToggleKey] end
            if data.noRecoil ~= nil then setNoRecoil(data.noRecoil, true) end
            if data.rapidFire ~= nil then setRapidFire(data.rapidFire, true) end
        end
    end
end

local function resetToDefault()
    setPlayerESP(true, true)
    setGearESP(false, true)
    setNpcESP(true, true)
    setNoGrass(false, true)
    setFullbright(false, true)
    setAimbotMasterUI(true, true)
    setAimNpc(true, true)
    setSmoothing(0.2, true)
    setPrediction(0.12, true)
    setAimPart("Head", true)
    setToggleKey(Enum.KeyCode.X, true)
    guiToggleKey = Enum.KeyCode.RightShift
    setNoRecoil(false, true)
    setRapidFire(false, true)
end

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -10, 0, 28)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextSize = 12
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.Text = "Save Config"
saveBtn.Parent = configContainer

saveBtn.MouseButton1Click:Connect(function()
    saveCurrentConfig()
end)

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(1, -10, 0, 28)
loadBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.TextSize = 12
loadBtn.Font = Enum.Font.SourceSansBold
loadBtn.Text = "Load Selected Config"
loadBtn.Parent = configContainer

loadBtn.MouseButton1Click:Connect(function()
    loadConfigByName(configNameBox.Text)
end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -10, 0, 28)
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 0)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.Text = "Reset to Default"
resetBtn.Parent = configContainer

resetBtn.MouseButton1Click:Connect(function()
    resetToDefault()
end)

local removeAllBtn = Instance.new("TextButton")
removeAllBtn.Size = UDim2.new(1, -10, 0, 28)
removeAllBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
removeAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeAllBtn.TextSize = 12
removeAllBtn.Font = Enum.Font.SourceSansBold
removeAllBtn.Text = "Remove All Configs"
removeAllBtn.Parent = configContainer

removeAllBtn.MouseButton1Click:Connect(function()
    local files = listfiles(folderName)
    for _, file in ipairs(files) do
        delfile(file)
    end
    refreshDropdown()
    configNameBox.Text = ""
end)
