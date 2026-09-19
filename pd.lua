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

local MAIN_FONT = Enum.Font.GothamMedium

-- Theme Customization State & Color Registry
local ThemeColors = {
    MainBackground = Color3.fromRGB(22, 22, 22),
    TopBar = Color3.fromRGB(32, 32, 32),
    ButtonBackground = Color3.fromRGB(45, 45, 45),
    ButtonHover = Color3.fromRGB(60, 60, 60),
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(160, 160, 160),
    EnabledColor = Color3.fromRGB(35, 110, 50),
    DisabledColor = Color3.fromRGB(110, 35, 35),
    SliderBackground = Color3.fromRGB(50, 50, 50),
}

local themeElementsTracker = {
    MainBackgrounds = {},
    TopBars = {},
    Buttons = {},
    Texts = {},
    Toggles = {},
    Sliders = {},
}

local function applyCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "furhub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 430)
mainFrame.Position = UDim2.new(0, 50, 0, 150)
mainFrame.BackgroundColor3 = ThemeColors.MainBackground
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
applyCorner(mainFrame, 8)
table.insert(themeElementsTracker.MainBackgrounds, mainFrame)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = ThemeColors.TopBar
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
applyCorner(topBar, 8)
table.insert(themeElementsTracker.TopBars, topBar)

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 10)
topBarCover.Position = UDim2.new(0, 0, 1, -10)
topBarCover.BackgroundColor3 = ThemeColors.TopBar
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar
table.insert(themeElementsTracker.TopBars, topBarCover)

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
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = ThemeColors.TextPrimary
titleLabel.TextSize = 14
titleLabel.Font = MAIN_FONT
titleLabel.Text = "fur hub"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar
table.insert(themeElementsTracker.Texts, titleLabel)

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
    btn.Size = UDim2.new(0, 52, 0, 24)
    btn.BackgroundColor3 = ThemeColors.ButtonBackground
    btn.TextColor3 = ThemeColors.TextSecondary
    btn.TextSize = 10
    btn.Font = MAIN_FONT
    btn.Text = string.lower(name)
    btn.Parent = tabContainer
    applyCorner(btn, 4)
    table.insert(themeElementsTracker.Buttons, btn)
    table.insert(themeElementsTracker.Texts, btn)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -12, 1, -48)
    container.Position = UDim2.new(0, 6, 0, 42)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.ScrollBarThickness = 3
    container.Visible = false
    container.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = container

    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        for _, b in ipairs(tabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = ThemeColors.ButtonBackground
                b.TextColor3 = ThemeColors.TextSecondary
            end
        end
        btn.BackgroundColor3 = ThemeColors.ButtonHover
        btn.TextColor3 = ThemeColors.TextPrimary
        container.Visible = true
    end)

    return container
end

local visualsContainer = createTabButton("Visuals")
visualsContainer.Visible = true
local inventoryTabContainer = createTabButton("InvView")
local aimbotContainer = createTabButton("Aimbot")
local silentContainer = createTabButton("Silent")
local modsContainer = createTabButton("Mods")
local configContainer = createTabButton("Config")
local themesContainer = createTabButton("Themes")

for _, b in ipairs(tabContainer:GetChildren()) do
    if b:IsA("TextButton") and b.Text == "visuals" then
        b.BackgroundColor3 = ThemeColors.ButtonHover
        b.TextColor3 = ThemeColors.TextPrimary
    end
end

local function createToggleUI(parent, name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = defaultState and ThemeColors.EnabledColor or ThemeColors.DisabledColor
    btn.TextColor3 = ThemeColors.TextPrimary
    btn.TextSize = 12
    btn.Font = MAIN_FONT
    btn.Text = string.lower(name) .. ": " .. (defaultState and "on" or "off")
    btn.Parent = parent
    applyCorner(btn, 4)
    table.insert(themeElementsTracker.Texts, btn)

    local state = defaultState
    local updateState = function(newState, fireCallback)
        state = newState
        btn.Text = string.lower(name) .. ": " .. (state and "on" or "off")
        btn.BackgroundColor3 = state and ThemeColors.EnabledColor or ThemeColors.DisabledColor
        if fireCallback then
            callback(state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        updateState(not state, true)
    end)

    table.insert(themeElementsTracker.Toggles, {Button = btn, GetState = function() return state end})
    return btn, updateState
end

local function createButtonUI(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = ThemeColors.ButtonBackground
    btn.TextColor3 = ThemeColors.TextPrimary
    btn.TextSize = 12
    btn.Font = MAIN_FONT
    btn.Text = string.lower(name)
    btn.Parent = parent
    applyCorner(btn, 4)
    table.insert(themeElementsTracker.Buttons, btn)
    table.insert(themeElementsTracker.Texts, btn)

    btn.MouseButton1Click:Connect(function()
        callback()
    end)

    return btn
end

local function createDropdownUI(parent, name, options, initialVal, callback)
    local isOpen = false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 28)
    mainBtn.BackgroundColor3 = ThemeColors.ButtonBackground
    mainBtn.TextColor3 = ThemeColors.TextPrimary
    mainBtn.TextSize = 12
    mainBtn.Font = MAIN_FONT
    mainBtn.Text = string.lower(name) .. ": " .. string.lower(tostring(initialVal))
    mainBtn.Parent = container
    applyCorner(mainBtn, 4)
    table.insert(themeElementsTracker.Buttons, mainBtn)
    table.insert(themeElementsTracker.Texts, mainBtn)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 30)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 5
    listFrame.Parent = container
    applyCorner(listFrame, 4)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local selectOpt = function(opt, fireCallback)
        mainBtn.Text = string.lower(name) .. ": " .. string.lower(opt)
        isOpen = false
        listFrame.Visible = false
        container.Size = UDim2.new(1, -8, 0, 28)
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

        for _, itemData in ipairs(newOptions) do
            local optName = type(itemData) == "table" and itemData.Name or tostring(itemData)
            local isHighlighted = type(itemData) == "table" and itemData.Highlight or false

            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 25)
            optBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            optBtn.TextColor3 = isHighlighted and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
            optBtn.TextSize = 11
            optBtn.Font = MAIN_FONT
            optBtn.Text = string.lower(optName)
            optBtn.ZIndex = 6
            optBtn.Parent = listFrame

            optBtn.MouseButton1Click:Connect(function()
                selectOpt(optName, true)
            end)
        end

        listFrame.Size = UDim2.new(1, 0, 0, #newOptions * 26)
    end

    populateOptions(options)

    mainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        if isOpen then
            container.Size = UDim2.new(1, -8, 0, 28 + listFrame.AbsoluteSize.Y)
        else
            container.Size = UDim2.new(1, -8, 0, 28)
        end
    end)

    return container, selectOpt, populateOptions
end

local function createSliderUI(parent, name, min, max, step, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 42)
    container.BackgroundColor3 = ThemeColors.TopBar
    container.BorderSizePixel = 0
    container.Parent = parent
    applyCorner(container, 4)
    table.insert(themeElementsTracker.TopBars, container)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = ThemeColors.TextPrimary
    label.TextSize = 11
    label.Font = MAIN_FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.lower(name) .. ": " .. tostring(defaultVal)
    label.Parent = container
    table.insert(themeElementsTracker.Texts, label)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -12, 0, 8)
    sliderBar.Position = UDim2.new(0, 6, 0, 25)
    sliderBar.BackgroundColor3 = ThemeColors.SliderBackground
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container
    applyCorner(sliderBar, 3)
    table.insert(themeElementsTracker.Sliders, sliderBar)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ThemeColors.EnabledColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar
    applyCorner(fill, 3)

    local currentValue = defaultVal
    local draggingSlider = false

    local updateValuePos = function(val, fireCallback)
        currentValue = math.clamp(val, min, max)
        currentValue = math.floor(currentValue / step + 0.5) * step
        fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        label.Text = string.lower(name) .. ": " .. string.format(step < 1 and "%.2f" or "%.0f", currentValue)
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
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = ThemeColors.ButtonBackground
    btn.TextColor3 = ThemeColors.TextPrimary
    btn.TextSize = 12
    btn.Font = MAIN_FONT
    btn.Text = string.lower(name) .. ": [" .. string.lower(defaultKey.Name) .. "]"
    btn.Parent = parent
    applyCorner(btn, 4)
    table.insert(themeElementsTracker.Buttons, btn)
    table.insert(themeElementsTracker.Texts, btn)

    local currentKey = defaultKey
    local binding = false

    local updateKey = function(newKey, fireCallback)
        currentKey = newKey
        btn.Text = string.lower(name) .. ": [" .. string.lower(currentKey.Name) .. "]"
        if fireCallback then
            callback(currentKey)
        end
    end

    btn.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        btn.Text = string.lower(name) .. ": [press key...]"
        
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

local function refreshTheme()
    for _, f in ipairs(themeElementsTracker.MainBackgrounds) do
        if f and f.Parent then f.BackgroundColor3 = ThemeColors.MainBackground end
    end
    for _, f in ipairs(themeElementsTracker.TopBars) do
        if f and f.Parent then f.BackgroundColor3 = ThemeColors.TopBar end
    end
    for _, b in ipairs(themeElementsTracker.Buttons) do
        if b and b.Parent then b.BackgroundColor3 = ThemeColors.ButtonBackground end
    end
    for _, t in ipairs(themeElementsTracker.Texts) do
        if t and t.Parent then t.TextColor3 = ThemeColors.TextPrimary end
    end
    for _, s in ipairs(themeElementsTracker.Sliders) do
        if s and s.Parent then s.BackgroundColor3 = ThemeColors.SliderBackground end
    end
    for _, toggleInfo in ipairs(themeElementsTracker.Toggles) do
        if toggleInfo.Button and toggleInfo.Button.Parent then
            local state = toggleInfo.GetState()
            toggleInfo.Button.BackgroundColor3 = state and ThemeColors.EnabledColor or ThemeColors.DisabledColor
        end
    end
end

do
    local function createColorPickerRow(parent, labelName, currentColor, onColorChanged)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -8, 0, 32)
        container.BackgroundColor3 = ThemeColors.TopBar
        container.BorderSizePixel = 0
        container.Parent = parent
        applyCorner(container, 4)
        table.insert(themeElementsTracker.TopBars, container)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 140, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = ThemeColors.TextPrimary
        lbl.TextSize = 12
        lbl.Font = MAIN_FONT
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = string.lower(labelName)
        lbl.Parent = container
        table.insert(themeElementsTracker.Texts, lbl)

        local function createColorInput(defaultVal, posX, nameLabel, callback)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 42, 0, 20)
            box.Position = UDim2.new(0, posX, 0, 6)
            box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            box.TextColor3 = ThemeColors.TextPrimary
            box.TextSize = 11
            box.Font = MAIN_FONT
            box.Text = tostring(math.floor(defaultVal * 255))
            box.Parent = container
            applyCorner(box, 3)
            table.insert(themeElementsTracker.Texts, box)

            box.FocusLost:Connect(function()
                local num = tonumber(box.Text)
                if num then
                    num = math.clamp(num, 0, 255)
                    box.Text = tostring(num)
                    callback(num / 255)
                else
                    box.Text = tostring(math.floor(defaultVal * 255))
                end
            end)
        end

        local rVal, gVal, bVal = currentColor.R, currentColor.G, currentColor.B

        createColorInput(rVal, 160, "R", function(newR)
            rVal = newR
            local updated = Color3.new(rVal, gVal, bVal)
            onColorChanged(updated)
            refreshTheme()
        end)

        createColorInput(gVal, 210, "G", function(newG)
            gVal = newG
            local updated = Color3.new(rVal, gVal, bVal)
            onColorChanged(updated)
            refreshTheme()
        end)

        createColorInput(bVal, 260, "B", function(newB)
            bVal = newB
            local updated = Color3.new(rVal, gVal, bVal)
            onColorChanged(updated)
            refreshTheme()
        end)

        return container
    end

    createColorPickerRow(themesContainer, "Main Background", ThemeColors.MainBackground, function(c) ThemeColors.MainBackground = c end)
    createColorPickerRow(themesContainer, "Top Bar", ThemeColors.TopBar, function(c) ThemeColors.TopBar = c end)
    createColorPickerRow(themesContainer, "Button Background", ThemeColors.ButtonBackground, function(c) ThemeColors.ButtonBackground = c end)
    createColorPickerRow(themesContainer, "Button Hover / Active", ThemeColors.ButtonHover, function(c) ThemeColors.ButtonHover = c end)
    createColorPickerRow(themesContainer, "Primary Text", ThemeColors.TextPrimary, function(c) ThemeColors.TextPrimary = c end)
    createColorPickerRow(themesContainer, "Secondary Text", ThemeColors.TextSecondary, function(c) ThemeColors.TextSecondary = c end)
    createColorPickerRow(themesContainer, "Enabled Toggle", ThemeColors.EnabledColor, function(c) ThemeColors.EnabledColor = c end)
    createColorPickerRow(themesContainer, "Disabled Toggle", ThemeColors.DisabledColor, function(c) ThemeColors.DisabledColor = c end)

    createButtonUI(themesContainer, "Reset Theme Defaults", function()
        ThemeColors.MainBackground = Color3.fromRGB(22, 22, 22)
        ThemeColors.TopBar = Color3.fromRGB(32, 32, 32)
        ThemeColors.ButtonBackground = Color3.fromRGB(45, 45, 45)
        ThemeColors.ButtonHover = Color3.fromRGB(60, 60, 60)
        ThemeColors.TextPrimary = Color3.fromRGB(240, 240, 240)
        ThemeColors.TextSecondary = Color3.fromRGB(160, 160, 160)
        ThemeColors.EnabledColor = Color3.fromRGB(35, 110, 50)
        ThemeColors.DisabledColor = Color3.fromRGB(110, 35, 35)
        ThemeColors.SliderBackground = Color3.fromRGB(50, 50, 50)
        refreshTheme()
    end)
end

local invWindow = Instance.new("Frame")
invWindow.Size = UDim2.new(0, 680, 0, 480)
invWindow.Position = UDim2.new(0.5, -340, 0.5, -240)
invWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
invWindow.BorderSizePixel = 0
invWindow.Visible = false
invWindow.Parent = screenGui
applyCorner(invWindow, 6)

local invTopBar = Instance.new("Frame")
invTopBar.Size = UDim2.new(1, 0, 0, 32)
invTopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
invTopBar.BorderSizePixel = 0
invTopBar.Parent = invWindow
applyCorner(invTopBar, 6)

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, -12, 1, 0)
invTitle.Position = UDim2.new(0, 10, 0, 0)
invTitle.BackgroundTransparency = 1
invTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
invTitle.TextSize = 13
invTitle.Font = MAIN_FONT
invTitle.Text = "inventory viewer"
invTitle.TextXAlignment = Enum.TextXAlignment.Left
invTitle.Parent = invTopBar

local invDragging, invDragInput, invDragStart, invStartPos
invTopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        invDragging = true
        invDragStart = input.Position
        invStartPos = invWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                invDragging = false
            end
        end)
    end
end)

invTopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        invDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == invDragInput and invDragging then
        local delta = input.Position - invDragStart
        invWindow.Position = UDim2.new(invStartPos.X.Scale, invStartPos.X.Offset + delta.X, invStartPos.Y.Scale, invStartPos.Y.Offset + delta.Y)
    end
end)

local invMainBody = Instance.new("Frame")
invMainBody.Size = UDim2.new(1, -12, 1, -40)
invMainBody.Position = UDim2.new(0, 6, 0, 34)
invMainBody.BackgroundTransparency = 1
invMainBody.Parent = invWindow

local invLeftFrame = Instance.new("Frame")
invLeftFrame.Size = UDim2.new(0, 460, 1, 0)
invLeftFrame.Position = UDim2.new(0, 0, 0, 0)
invLeftFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
invLeftFrame.BorderSizePixel = 0
invLeftFrame.Parent = invMainBody
applyCorner(invLeftFrame, 6)

local invLeftTitle = Instance.new("TextLabel")
invLeftTitle.Size = UDim2.new(1, 0, 0, 26)
invLeftTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
invLeftTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
invLeftTitle.TextSize = 13
invLeftTitle.Font = MAIN_FONT
invLeftTitle.Text = "inventory"
invLeftTitle.Parent = invLeftFrame
applyCorner(invLeftTitle, 6)

local invLeftScroll = Instance.new("ScrollingFrame")
invLeftScroll.Size = UDim2.new(1, -12, 1, -34)
invLeftScroll.Position = UDim2.new(0, 6, 0, 30)
invLeftScroll.BackgroundTransparency = 1
invLeftScroll.ScrollBarThickness = 4
invLeftScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
invLeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
invLeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
invLeftScroll.Parent = invLeftFrame

local invLeftLayout = Instance.new("UIListLayout")
invLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
invLeftLayout.Padding = UDim.new(0, 8)
invLeftLayout.Parent = invLeftScroll

local invRightFrame = Instance.new("Frame")
invRightFrame.Size = UDim2.new(0, 202, 1, 0)
invRightFrame.Position = UDim2.new(0, 466, 0, 0)
invRightFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
invRightFrame.BorderSizePixel = 0
invRightFrame.Parent = invMainBody
applyCorner(invRightFrame, 6)

local invRightTitle = Instance.new("TextLabel")
invRightTitle.Size = UDim2.new(1, 0, 0, 26)
invRightTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
invRightTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
invRightTitle.TextSize = 13
invRightTitle.Font = MAIN_FONT
invRightTitle.Text = "gear / appearance"
invRightTitle.Parent = invRightFrame
applyCorner(invRightTitle, 6)

local gearGridFrame = Instance.new("Frame")
gearGridFrame.Size = UDim2.new(1, -10, 1, -34)
gearGridFrame.Position = UDim2.new(0, 5, 0, 30)
gearGridFrame.BackgroundTransparency = 1
gearGridFrame.Parent = invRightFrame

local gearSlots = {}
local gearSlotDefinitions = {
    {Name = "Headware", Label = "HEADWARE", SlotAttr = "ClothingHeadware", Pos = UDim2.new(0, 4, 0, 6)},
    {Name = "Backpack", Label = "BACKPACK", SlotAttr = "ClothingBackpack", Pos = UDim2.new(0, 98, 0, 6)},
    {Name = "ChestRig", Label = "CHEST RIG", SlotAttr = "ClothingChestRig", Pos = UDim2.new(0, 4, 0, 72)},
    {Name = "ItemBack1", Label = "ITEM BACK 1", SlotAttr = "ItemBack1", Pos = UDim2.new(0, 98, 0, 72)},
    {Name = "ItemBack2", Label = "ITEM BACK 2", SlotAttr = "ItemBack2", Pos = UDim2.new(0, 4, 0, 138)},
    {Name = "ItemHip", Label = "ITEM HIP", SlotAttr = "ItemHip", Pos = UDim2.new(0, 98, 0, 138)},
}

for _, def in ipairs(gearSlotDefinitions) do
    local slotFrame = Instance.new("Frame")
    slotFrame.Size = UDim2.new(0, 90, 0, 60)
    slotFrame.Position = def.Pos
    slotFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    slotFrame.BorderSizePixel = 0
    slotFrame.Parent = gearGridFrame
    applyCorner(slotFrame, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.TextSize = 10
    lbl.Font = MAIN_FONT
    lbl.Text = string.lower(def.Label)
    lbl.Parent = slotFrame

    local itemLbl = Instance.new("TextLabel")
    itemLbl.Size = UDim2.new(1, -6, 1, -18)
    itemLbl.Position = UDim2.new(0, 3, 0, 16)
    itemLbl.BackgroundTransparency = 1
    itemLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    itemLbl.TextSize = 11
    itemLbl.Font = MAIN_FONT
    itemLbl.TextWrapped = true
    itemLbl.Text = "empty"
    itemLbl.Parent = slotFrame

    gearSlots[def.SlotAttr] = {Label = itemLbl, Frame = slotFrame}
end

local selectedTargetPlayer = LocalPlayer.Name
local inventoryViewerEnabled = false
local inventoryLoopToken = 0

local invViewerIndicator = Drawing.new("Square")
invViewerIndicator.Visible = false
invViewerIndicator.Color = Color3.fromRGB(255, 0, 0)
invViewerIndicator.Thickness = 2
invViewerIndicator.Filled = false
invViewerIndicator.Size = Vector2.new(20, 20)

local invViewerIndicatorText = Drawing.new("Text")
invViewerIndicatorText.Visible = false
invViewerIndicatorText.Color = Color3.fromRGB(255, 0, 0)
invViewerIndicatorText.Size = 14
invViewerIndicatorText.Center = true
invViewerIndicatorText.Outline = true
invViewerIndicatorText.Font = 2
invViewerIndicatorText.Text = "[viewed target]"

RunService.RenderStepped:Connect(function()
    if not inventoryViewerEnabled then
        invViewerIndicator.Visible = false
        invViewerIndicatorText.Visible = false
        return
    end

    local targetPlayer = Players:FindFirstChild(selectedTargetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        invViewerIndicator.Visible = false
        invViewerIndicatorText.Visible = false
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local hrp = targetPlayer.Character.HumanoidRootPart
    local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
    local distance = (hrp.Position - character.HumanoidRootPart.Position).Magnitude

    if onScreen then
        invViewerIndicator.Size = Vector2.new(30, 40)
        invViewerIndicator.Position = Vector2.new(screenPos.X - 15, screenPos.Y - 20)
        invViewerIndicator.Visible = true

        invViewerIndicatorText.Position = Vector2.new(screenPos.X, screenPos.Y - 38)
        invViewerIndicatorText.Text = string.lower(string.format("[viewed: %s | %.0fm]", selectedTargetPlayer, distance))
        invViewerIndicatorText.Visible = true
    else
        invViewerIndicator.Visible = false
        invViewerIndicatorText.Visible = false
    end
end)

local function getItemAttachmentsInfo(itemObj)
    if not itemObj then return nil, nil end
    local attFolder = itemObj:FindFirstChild("Attachments")
    local sightName = nil
    local magName = nil
    
    if attFolder then
        for _, child in ipairs(attFolder:GetChildren()) do
            if child:GetAttribute("Slot") == "Sight" then
                sightName = child.Name
            elseif child:GetAttribute("Magazine") == true or child:GetAttribute("Magazine") ~= nil then
                magName = child.Name
            end
        end
    end
    return sightName, magName
end

local function shouldWarnItem(itemName, sightName)
    if itemName == "FlareGun" then return true end
    if itemName == "HSPV" then return true end
    if itemName == "R700" then return true end
    if itemName == "TFZ98S" then return true end
    if sightName == "Reapir" then return true end
    return false
end

local function checkPlayerHasWarnedItem(playerName)
    local repPlayers = ReplicatedStorage:FindFirstChild("Players")
    if not repPlayers then return false end
    local pFolder = repPlayers:FindFirstChild(playerName)
    if not pFolder then return false end
    local invFolder = pFolder:FindFirstChild("Inventory")
    if not invFolder then return false end

    local function scanItem(itemObj)
        local itemName = itemObj.Name
        local sightName, _ = getItemAttachmentsInfo(itemObj)
        if shouldWarnItem(itemName, sightName) then return true end

        local nestedInv = itemObj:FindFirstChild("Inventory")
        if nestedInv then
            for _, subItem in ipairs(nestedInv:GetChildren()) do
                if scanItem(subItem) then return true end
            end
        end
        return false
    end

    for _, item in ipairs(invFolder:GetChildren()) do
        if scanItem(item) then return true end
    end
    return false
end

local function createGridCategory(title, maxSlots, itemsMap)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundTransparency = 1
    header.TextColor3 = Color3.fromRGB(200, 200, 200)
    header.TextSize = 12
    header.Font = MAIN_FONT
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = string.lower(title)
    header.Parent = invLeftScroll

    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(1, 0, 0, math.ceil(maxSlots / 6) * 56)
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = invLeftScroll

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 52, 0, 52)
    gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = gridFrame

    for i = 1, maxSlots do
        local slot = Instance.new("Frame")
        slot.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        slot.BorderSizePixel = 0
        slot.LayoutOrder = i
        slot.Parent = gridFrame
        applyCorner(slot, 4)

        local itemData = itemsMap[i]
        if itemData then
            local sightName, magName = getItemAttachmentsInfo(itemData.Obj)
            local displayText = string.lower(itemData.Name)
            local isWarned = shouldWarnItem(itemData.Name, sightName)
            
            if sightName then
                local sightColorHex = (sightName == "Reapir") and "rgb(255,50,50)" or "rgb(100,220,255)"
                displayText = displayText .. "\n" .. "<font size=\"8\" color=\"" .. sightColorHex .. "\">" .. string.lower(sightName) .. "</font>"
            end
            if magName then
                displayText = displayText .. "\n" .. "<font size=\"8\" color=\"rgb(255,150,100)\">" .. string.lower(magName) .. "</font>"
            end

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -4, 1, -4)
            nameLbl.Position = UDim2.new(0, 2, 0, 2)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = isWarned and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(240, 240, 240)
            nameLbl.TextSize = 10
            nameLbl.Font = MAIN_FONT
            nameLbl.TextWrapped = true
            nameLbl.RichText = true
            nameLbl.Text = displayText
            nameLbl.Parent = slot

            if itemData.Amount and itemData.Amount > 1 then
                local amtLbl = Instance.new("TextLabel")
                amtLbl.Size = UDim2.new(0, 24, 0, 12)
                amtLbl.Position = UDim2.new(0, 3, 0, 3)
                amtLbl.BackgroundTransparency = 1
                amtLbl.TextColor3 = Color3.fromRGB(255, 190, 0)
                amtLbl.TextSize = 10
                amtLbl.Font = MAIN_FONT
                amtLbl.Text = tostring(itemData.Amount)
                amtLbl.TextXAlignment = Enum.TextXAlignment.Left
                amtLbl.Parent = slot
            end
        end
    end
end

local function refreshInventoryDisplay()
    for _, slotData in pairs(gearSlots) do
        slotData.Label.Text = "empty"
        slotData.Label.TextColor3 = Color3.fromRGB(120, 120, 120)
        slotData.Label.RichText = false
    end

    for _, child in ipairs(invLeftScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local repPlayers = ReplicatedStorage:FindFirstChild("Players")
    if not repPlayers then return end
    local pFolder = repPlayers:FindFirstChild(selectedTargetPlayer)
    if not pFolder then return end
    local invFolder = pFolder:FindFirstChild("Inventory")
    if not invFolder then return end

    invTitle.Text = string.lower("inventory viewer - " .. selectedTargetPlayer)

    local categorizedItems = {
        ChestRig = {},
        Shirt = {},
        Pants = {},
        Backpack = {}
    }

    local function parseItem(itemObj)
        local slotAttr = itemObj:GetAttribute("Slot") or ""
        local amount = itemObj:GetAttribute("Amount") or 1

        if gearSlots[slotAttr] then
            local itemName = itemObj.Name
            local sightName, magName = getItemAttachmentsInfo(itemObj)
            local displayText = string.lower(itemName)
            local isWarned = shouldWarnItem(itemName, sightName)
            
            if sightName then
                local sightColorHex = (sightName == "Reapir") and "rgb(255,50,50)" or "rgb(100,220,255)"
                displayText = displayText .. "\n" .. "<font size=\"8\" color=\"" .. sightColorHex .. "\">" .. string.lower(sightName) .. "</font>"
            end
            if magName then
                displayText = displayText .. "\n" .. "<font size=\"8\" color=\"rgb(255,150,100)\">" .. string.lower(magName) .. "</font>"
            end

            gearSlots[slotAttr].Label.RichText = true
            gearSlots[slotAttr].Label.Text = displayText
            gearSlots[slotAttr].Label.TextColor3 = isWarned and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
        end

        local cat, indexStr = slotAttr:match("^([%a]+)(%d+)$")
        if cat and indexStr then
            local idx = tonumber(indexStr)
            if categorizedItems[cat] then
                categorizedItems[cat][idx] = {Name = itemObj.Name, Amount = amount, Obj = itemObj}
            end
        end

        local nestedInv = itemObj:FindFirstChild("Inventory")
        if nestedInv then
            for _, subItem in ipairs(nestedInv:GetChildren()) do
                parseItem(subItem)
            end
        end
    end

    for _, item in ipairs(invFolder:GetChildren()) do
        parseItem(item)
    end

    createGridCategory("Chest Rig", 12, categorizedItems.ChestRig)
    createGridCategory("Shirt", 6, categorizedItems.Shirt)
    createGridCategory("Pants", 6, categorizedItems.Pants)
    createGridCategory("Backpack", 30, categorizedItems.Backpack)
end

local function getPlayerNamesList()
    local list = {}
    local repPlayers = ReplicatedStorage:FindFirstChild("Players")
    for _, p in ipairs(Players:GetPlayers()) do
        local hasWarned = checkPlayerHasWarnedItem(p.Name)
        table.insert(list, {Name = p.Name, Highlight = hasWarned})
    end
    return list
end

local _, _, updateInvPlayerDropdown = createDropdownUI(inventoryTabContainer, "Select Player", getPlayerNamesList(), selectedTargetPlayer, function(val)
    selectedTargetPlayer = val
    if inventoryViewerEnabled then
        refreshInventoryDisplay()
    end
end)

createButtonUI(inventoryTabContainer, "Refresh Player List", function()
    updateInvPlayerDropdown(getPlayerNamesList())
end)

local _, setInvViewerUI = createToggleUI(inventoryTabContainer, "Inventory Viewer", false, function(val)
    inventoryViewerEnabled = val
    invWindow.Visible = val
    inventoryLoopToken = inventoryLoopToken + 1
    local currentToken = inventoryLoopToken

    if val then
        refreshInventoryDisplay()
        task.spawn(function()
            while inventoryViewerEnabled and currentToken == inventoryLoopToken do
                task.wait(5)
                if inventoryViewerEnabled and currentToken == inventoryLoopToken then
                    refreshInventoryDisplay()
                end
            end
        end)
    end
end)

local aimbotInvViewerEnabled = false
local aimbotInvKey = Enum.KeyCode.H

local _, setAimbotInvViewerUI = createToggleUI(inventoryTabContainer, "Aimbot Inv Viewer", false, function(val)
    aimbotInvViewerEnabled = val
end)

createKeybindUI(inventoryTabContainer, "Aimbot Inv Key", aimbotInvKey, function(key)
    aimbotInvKey = key
end)

local playerESPEnabled = true
local gearESPEnabled = false
local npcESPEnabled = true
local noGrassEnabled = false
local fullbrightEnabled = false
local brightLoop = nil

local playerESPMasterEnabled = true
local playerESPKey = Enum.KeyCode.Y
local setPlayerESPMasterUI = nil
local setPlayerESPUI = nil
local setNpcESPUI = nil

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
                table.insert(items, string.lower(objVal.Value.Name))
            elseif objVal and objVal:IsA("StringValue") and objVal.Value ~= "" then
                table.insert(items, string.lower(objVal.Value))
            end
        end
    end

    for _, child in ipairs(char:GetChildren()) do
        if armorList[child.Name] then
            table.insert(items, string.lower(child.Name))
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

local function isPointVisible(destination, modelOrChar)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    
    local origin = cam.CFrame.Position
    
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
        if not success or not result then return true end
        
        local hitPart = result.Instance
        if hitPart then
            local isTransparent = hitPart.Transparency >= 1
            local notCollide = not hitPart.CanCollide
            local isSelfPart = modelOrChar and hitPart:IsDescendantOf(modelOrChar)
            
            if isTransparent or notCollide or isSelfPart then
                table.insert(filterList, hitPart)
                raycastParams.FilterDescendantsInstances = filterList
                currentOrigin = result.Position + ((destination - currentOrigin).Unit * 0.1)
                if (currentOrigin - destination).Magnitude < 0.1 then return true end
            else
                return false
            end
        else
            return true
        end
    end
    
    return false
end

local function isVisible(targetPart, modelOrChar)
    if not targetPart then return false end
    
    local cam = Workspace.CurrentCamera
    if not cam then return false end

    local cf = targetPart.CFrame
    local size = targetPart.Size
    
    local camRight = cam.CFrame.RightVector
    local leftPoint = cf.Position - (camRight * (size.X / 2))
    local rightPoint = cf.Position + (camRight * (size.X / 2))
    local topPoint = cf.Position + (cf.UpVector * (size.Y / 2))
    
    if isPointVisible(topPoint, modelOrChar) then return true end
    if isPointVisible(leftPoint, modelOrChar) then return true end
    if isPointVisible(rightPoint, modelOrChar) then return true end
    
    return false
end

local AimbotMasterEnabled = true
local AimbotEnabled = false
local aimNpcEnabled = true
local teamCheckEnabled = true
local smoothing = 0.2
local predictionFactor = 0.12
local AimPart = "Head"
local toggleKey = Enum.KeyCode.X
local guiToggleKey = Enum.KeyCode.RightShift
local noRecoilEnabled = false
local rapidFireEnabled = false
local noBulletDropEnabled = false

local currentTarget = nil
local TargetLoop = nil
local originalFireModes = {}
local originalRecoilValues = {}

local setAimbotMasterUI = nil
local setSilentAimUI = nil

local function getPlayerNameFromTarget(target)
    if not target then return nil end
    if target:IsA("Player") then return target.Name
    elseif target:IsA("Model") then return target.Name end
    return nil
end

local function isTeammate(target)
    if not teamCheckEnabled then return false end
    local targetName = getPlayerNameFromTarget(target)
    if not targetName then return false end

    local clansFolder = ReplicatedStorage:FindFirstChild("Clans")
    if not clansFolder then return false end

    local localPlayerName = LocalPlayer.Name
    local localTeamFolder = nil
    local targetTeamFolder = nil

    for _, clanFolder in ipairs(clansFolder:GetChildren()) do
        local ownerName = clanFolder.Name:gsub("'s team$", "")
        if ownerName == localPlayerName then localTeamFolder = clanFolder end
        if ownerName == targetName then targetTeamFolder = clanFolder end

        for _, member in ipairs(clanFolder:GetChildren()) do
            if member.Name == localPlayerName then localTeamFolder = clanFolder end
            if member.Name == targetName then targetTeamFolder = clanFolder end
        end
    end

    if localTeamFolder and targetTeamFolder and localTeamFolder == targetTeamFolder then return true end
    return false
end

local function isTargetValid(target)
    if not target then return false end
    if isTeammate(target) then return false end

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

            if not isTeammate(player) then
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
    end

    if aimNpcEnabled then
        local aiZonesFolder = Workspace:FindFirstChild("AiZones")
        if aiZonesFolder then
            for _, zoneFolder in ipairs(aiZonesFolder:GetChildren()) do
                for _, npc in ipairs(zoneFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild(AimPart) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        if not isTeammate(npc) then
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
local silentTeamCheckEnabled = true

local SilentFOVRadius = 150
local OuterFOVRadius = 300
local SilentHitChance = 100

local TargetHead_S = true
local TargetUpperTorso_S = false
local TargetLowerTorso_S = false
local TargetLeftArm_S = false
local TargetRightArm_S = false
local TargetLeftLeg_S = false
local TargetRightLeg_S = false

local setTargetHeadUI = nil
local setTargetUpperTorsoUI = nil
local setTargetLowerTorsoUI = nil
local setTargetLeftArmUI = nil
local setTargetRightArmUI = nil
local setTargetLeftLegUI = nil
local setTargetRightLegUI = nil
local setHitChanceUI = nil

local blatantModeEnabled = false
local blatantKey = Enum.KeyCode.B
local blatantSavedSettings = nil
local setBlatantKeyUI = nil

local function checkAndClearBlatant()
    if blatantModeEnabled then
        blatantModeEnabled = false
        blatantSavedSettings = nil
    end
end

local SilentCircle = Drawing.new("Circle")
SilentCircle.Radius = SilentFOVRadius
SilentCircle.Color = Color3.fromRGB(255, 255, 255)
SilentCircle.Thickness = 1.5
SilentCircle.Filled = false
SilentCircle.Transparency = 1
SilentCircle.Visible = false

local activeSilentTargetPos = nil
local isSilentTargetActive = false
local isTriggerbotHolding = false
local triggerbotShotCount = 0
local lastTriggerbotTime = 0

local function isSilentTeammate(target)
    if not silentTeamCheckEnabled then return false end
    local targetName = getPlayerNameFromTarget(target)
    if not targetName then return false end

    local clansFolder = ReplicatedStorage:FindFirstChild("Clans")
    if not clansFolder then return false end

    local localPlayerName = LocalPlayer.Name
    local localTeamFolder = nil
    local targetTeamFolder = nil

    for _, clanFolder in ipairs(clansFolder:GetChildren()) do
        local ownerName = clanFolder.Name:gsub("'s team$", "")
        if ownerName == localPlayerName then localTeamFolder = clanFolder end
        if ownerName == targetName then targetTeamFolder = clanFolder end

        for _, member in ipairs(clanFolder:GetChildren()) do
            if member.Name == localPlayerName then localTeamFolder = clanFolder end
            if member.Name == targetName then targetTeamFolder = clanFolder end
        end
    end

    if localTeamFolder and targetTeamFolder and localTeamFolder == targetTeamFolder then return true end
    return false
end

local function getValidHitParts(char)
    local parts = {}
    if TargetHead_S and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) then table.insert(parts, char:FindFirstChild("Head") or char.HumanoidRootPart) end
    if TargetUpperTorso_S and char:FindFirstChild("UpperTorso") then table.insert(parts, char.UpperTorso) end
    if TargetLowerTorso_S and char:FindFirstChild("LowerTorso") then table.insert(parts, char.LowerTorso) end
    if TargetLeftArm_S then
        if char:FindFirstChild("LeftUpperArm") then table.insert(parts, char.LeftUpperArm) end
        if char:FindFirstChild("LeftLowerArm") then table.insert(parts, char.LeftLowerArm) end
        if char:FindFirstChild("LeftHand") then table.insert(parts, char.LeftHand) end
        if char:FindFirstChild("Left Arm") then table.insert(parts, char["Left Arm"]) end
    end
    if TargetRightArm_S then
        if char:FindFirstChild("RightUpperArm") then table.insert(parts, char.RightUpperArm) end
        if char:FindFirstChild("RightLowerArm") then table.insert(parts, char.RightLowerArm) end
        if char:FindFirstChild("RightHand") then table.insert(parts, char.RightHand) end
        if char:FindFirstChild("Right Arm") then table.insert(parts, char["Right Arm"]) end
    end
    if TargetLeftLeg_S then
        if char:FindFirstChild("LeftUpperLeg") then table.insert(parts, char.LeftUpperLeg) end
        if char:FindFirstChild("LeftLowerLeg") then table.insert(parts, char.LeftLowerLeg) end
        if char:FindFirstChild("LeftFoot") then table.insert(parts, char.LeftFoot) end
        if char:FindFirstChild("Left Leg") then table.insert(parts, char["Left Leg"]) end
    end
    if TargetRightLeg_S then
        if char:FindFirstChild("RightUpperLeg") then table.insert(parts, char.RightUpperLeg) end
        if char:FindFirstChild("RightLowerLeg") then table.insert(parts, char.RightLowerLeg) end
        if char:FindFirstChild("RightFoot") then table.insert(parts, char.RightFoot) end
        if char:FindFirstChild("Right Leg") then table.insert(parts, char["Right Leg"]) end
    end
    return parts
end

local function findSilentTargetAndPoint()
    local innerCandidates = {}
    local mousePos = UserInputService:GetMouseLocation()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil, false end

    local function evaluateCharacter(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local parts = getValidHitParts(char)
        if hum and hum.Health > 0 and #parts > 0 then
            local head = char:FindFirstChild("Head") or parts[1]
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist <= OuterFOVRadius then
                    local foundVisiblePart = nil
                    for _, part in ipairs(parts) do
                        if isVisible(part, char) then
                            foundVisiblePart = part
                            break
                        end
                    end

                    if foundVisiblePart and dist <= SilentFOVRadius then
                        table.insert(innerCandidates, {char = char, dist = dist, part = foundVisiblePart})
                    end
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not isSilentTeammate(player) then
                evaluateCharacter(player.Character)
            end
        end
    end

    if TargetNpcs_S then
        local aiZonesFolder = Workspace:FindFirstChild("AiZones")
        if aiZonesFolder then
            for _, zoneFolder in ipairs(aiZonesFolder:GetChildren()) do
                for _, npc in ipairs(zoneFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        if not isSilentTeammate(npc) then
                            evaluateCharacter(npc)
                        end
                    end
                end
            end
        end
    end

    table.sort(innerCandidates, function(a, b) return a.dist < b.dist end)

    if #innerCandidates > 0 then
        return innerCandidates[1].char, innerCandidates[1].part.Position, true
    end

    return nil, nil, false
end

RunService.RenderStepped:Connect(function()
    if not SilentAimEnabled then
        SilentCircle.Visible = false
        isSilentTargetActive = false
        activeSilentTargetPos = nil
        SilentCircle.Color = Color3.fromRGB(255, 255, 255)
        if isTriggerbotHolding then
            pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
            isTriggerbotHolding = false
        end
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    SilentCircle.Position = mousePos
    SilentCircle.Radius = SilentFOVRadius
    SilentCircle.Visible = CircleVisible

    local targetChar, targetPos, isVisibleInInnerRing = findSilentTargetAndPoint()
    
    if targetChar and targetPos and isVisibleInInnerRing then
        if math.random(1, 100) <= SilentHitChance then
            activeSilentTargetPos = targetPos
            isSilentTargetActive = true
            SilentCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            activeSilentTargetPos = nil
            isSilentTargetActive = false
            SilentCircle.Color = Color3.fromRGB(255, 255, 255)
        end

        if TriggerbotEnabled then
            local currentTime = os.clock()
            local canShoot = true
            if not rapidFireEnabled then
                if currentTime - lastTriggerbotTime < 0.25 then canShoot = false end
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
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0)) end)
                        isTriggerbotHolding = true
                        lastTriggerbotTime = currentTime
                    end
                end
            end
        end
    else
        activeSilentTargetPos = nil
        isSilentTargetActive = false
        SilentCircle.Color = Color3.fromRGB(255, 255, 255)
        if isTriggerbotHolding then
            pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
            isTriggerbotHolding = false
        end
        triggerbotShotCount = 0
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if SilentAimEnabled and isSilentTargetActive and activeSilentTargetPos then
        local args = {...}
        
        if method == "Raycast" and self == Workspace then
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                args[2] = (activeSilentTargetPos - origin).Unit * direction.Magnitude
                return oldNamecall(self, unpack(args))
            end
        elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
            local ray = args[1]
            if typeof(ray) == "Ray" then
                args[1] = Ray.new(ray.Origin, (activeSilentTargetPos - ray.Origin).Unit * ray.Direction.Magnitude)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

local oldRaycast
if Workspace.Raycast then
    oldRaycast = hookfunction(Workspace.Raycast, function(self, origin, direction, ...)
        if SilentAimEnabled and isSilentTargetActive and activeSilentTargetPos and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
            direction = (activeSilentTargetPos - origin).Unit * direction.Magnitude
        end
        return oldRaycast(self, origin, direction, ...)
    end)
end

RunService.RenderStepped:Connect(function()
    if not playerESPMasterEnabled then
        for _, drawings in pairs(playerObjects) do
            drawings.Text.Visible = false
            for _, b in ipairs(drawings.Bones) do b.line.Visible = false end
        end
        for _, drawings in pairs(npcObjects) do
            drawings.Text.Visible = false
            for _, b in ipairs(drawings.Bones) do b.line.Visible = false end
        end
        return
    end

    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local localHRP = character.HumanoidRootPart
    local cam = Workspace.CurrentCamera
    if not cam then return end

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
                    local visible = isVisible(head, char)
                    local espColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)

                    drawings.Text.Color = espColor
                    for _, bone in ipairs(drawings.Bones) do bone.line.Color = espColor end

                    local gearInfo = getPlayerGearInfo(char)
                    drawings.Text.Text = string.lower(string.format("%s [%.0fm]%s", player.Name, distance, gearInfo))
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
                    local visible = isVisible(head, model)
                    local espColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0)

                    drawings.Text.Color = espColor
                    for _, bone in ipairs(drawings.Bones) do bone.line.Color = espColor end

                    drawings.Text.Text = string.lower(string.format("%s [%.0fm]", model.Name, distance))
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

local Setters = {}

do
    _, setPlayerESPMasterUI = createToggleUI(visualsContainer, "esp master", playerESPMasterEnabled, function(val)
        playerESPMasterEnabled = val
        if not val then
            for _, d in pairs(playerObjects) do
                d.Text.Visible = false
                for _, b in ipairs(d.Bones) do b.line.Visible = false end
            end
            for _, d in pairs(npcObjects) do
                d.Text.Visible = false
                for _, b in ipairs(d.Bones) do b.line.Visible = false end
            end
        end
    end)

    _, setPlayerESPUI = createToggleUI(visualsContainer, "player esp", playerESPEnabled, function(val)
        playerESPEnabled = val
        if not val then
            for _, d in pairs(playerObjects) do
                d.Text.Visible = false
                for _, b in ipairs(d.Bones) do b.line.Visible = false end
            end
        end
    end)

    _, Setters.setGearESP = createToggleUI(visualsContainer, "gear esp", gearESPEnabled, function(val)
        gearESPEnabled = val
    end)

    _, setNpcESPUI = createToggleUI(visualsContainer, "npc esp", npcESPEnabled, function(val)
        npcESPEnabled = val
        if not val then
            for _, d in pairs(npcObjects) do
                d.Text.Visible = false
                for _, b in ipairs(d.Bones) do b.line.Visible = false end
            end
        end
    end)

    local _, setPlayerESPKey = createKeybindUI(visualsContainer, "esp key", playerESPKey, function(key)
        playerESPKey = key
    end)

    createButtonUI(visualsContainer, "remove visor folder", function()
        local success = pcall(function()
            local visor = Players.LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Visor
            if visor then
                local maska = visor:FindFirstChild("MaskaVisor")
                local altyn = visor:FindFirstChild("AltynVisor")
                if maska then maska:Destroy() end
                if altyn then altyn:Destroy() end
            end
        end)
        if not success then
            local noInset = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("NoInsetGui")
            if noInset then
                local mainF = noInset:FindFirstChild("MainFrame")
                if mainF then
                    local effects = mainF:FindFirstChild("ScreenEffects")
                    if effects then
                        local vFolder = effects:FindFirstChild("Visor")
                        if vFolder then
                            local maska = vFolder:FindFirstChild("MaskaVisor")
                            local altyn = vFolder:FindFirstChild("AltynVisor")
                            if maska then maska:Destroy() end
                            if altyn then altyn:Destroy() end
                        end
                    end
                end
            end
        end
    end)

    createButtonUI(visualsContainer, "enable third person", function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 9999
        LocalPlayer.CameraMinZoomDistance = 0.5
    end)

    _, Setters.setNoGrass = createToggleUI(visualsContainer, "no grass", noGrassEnabled, function(val)
        noGrassEnabled = val
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Terrain") then
                sethiddenproperty(item, "Decoration", not val)
            end
        end
    end)

    _, Setters.setFullbright = createToggleUI(visualsContainer, "fullbright", fullbrightEnabled, function(val)
        fullbrightEnabled = val
        if val then
            if brightLoop then brightLoop:Disconnect() end
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

    createButtonUI(visualsContainer, "bring agents to vault", function()
        local paths = {
            Workspace:WaitForChild("Anna", 5),
            Workspace:WaitForChild("Nurse", 5),
            Workspace:WaitForChild("Mihkel", 5),
            Workspace:WaitForChild("Blaze", 5),
            Workspace:WaitForChild("Tarmo", 5),
            Workspace:WaitForChild("Boss", 5)
        }

        local spacing = 5
        local targetX = -155
        local targetZ = -427

        for i, model in ipairs(paths) do
            if model and model:IsA("Model") then
                local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local currentCF = primaryPart.CFrame
                    local originalY = currentCF.Position.Y
                    local newZ = targetZ + ((i - 1) * spacing)
                    
                    local targetCF = CFrame.new(targetX, originalY, newZ) * CFrame.Angles(0, math.rad(270), 0)
                    model:PivotTo(targetCF)
                end
            end
        end
    end)
end

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

    if gameProcessedEvent then return end
    
    if input.KeyCode == toggleKey then
        if not AimbotMasterEnabled or SilentAimEnabled then return end
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            ResetTarget()
            AimbotLoop()
        else
            ResetTarget()
        end
        return
    end

    if input.KeyCode == aimbotInvKey then
        if aimbotInvViewerEnabled and currentTarget and currentTarget:IsA("Player") then
            selectedTargetPlayer = currentTarget.Name
            setInvViewerUI(not inventoryViewerEnabled, true)
        end
        return
    end

    if input.KeyCode == playerESPKey then
        if playerESPMasterEnabled then
            playerESPEnabled = not playerESPEnabled
            npcESPEnabled = playerESPEnabled
            if setPlayerESPUI then setPlayerESPUI(playerESPEnabled, true) end
            if setNpcESPUI then setNpcESPUI(npcESPEnabled, true) end
        end
        return
    end

    if input.KeyCode == blatantKey then
        if not blatantModeEnabled then
            blatantSavedSettings = {
                hitChance = SilentHitChance,
                head = TargetHead_S,
                upperTorso = TargetUpperTorso_S,
                lowerTorso = TargetLowerTorso_S,
                leftArm = TargetLeftArm_S,
                rightArm = TargetRightArm_S,
                leftLeg = TargetLeftLeg_S,
                rightLeg = TargetRightLeg_S,
            }
            blatantModeEnabled = true
            
            SilentHitChance = 100
            if setHitChanceUI then setHitChanceUI(100) end

            TargetHead_S = true
            TargetUpperTorso_S = false
            TargetLowerTorso_S = false
            TargetLeftArm_S = false
            TargetRightArm_S = false
            TargetLeftLeg_S = false
            TargetRightLeg_S = false

            if setTargetHeadUI then setTargetHeadUI(true, false) end
            if setTargetUpperTorsoUI then setTargetUpperTorsoUI(false, false) end
            if setTargetLowerTorsoUI then setTargetLowerTorsoUI(false, false) end
            if setTargetLeftArmUI then setTargetLeftArmUI(false, false) end
            if setTargetRightArmUI then setTargetRightArmUI(false, false) end
            if setTargetLeftLegUI then setTargetLeftLegUI(false, false) end
            if setTargetRightLegUI then setTargetRightLegUI(false, false) end
        else
            blatantModeEnabled = false
            if blatantSavedSettings then
                SilentHitChance = blatantSavedSettings.hitChance
                if setHitChanceUI then setHitChanceUI(SilentHitChance) end

                TargetHead_S = blatantSavedSettings.head
                TargetUpperTorso_S = blatantSavedSettings.upperTorso
                TargetLowerTorso_S = blatantSavedSettings.lowerTorso
                TargetLeftArm_S = blatantSavedSettings.leftArm
                TargetRightArm_S = blatantSavedSettings.rightArm
                TargetLeftLeg_S = blatantSavedSettings.leftLeg
                TargetRightLeg_S = blatantSavedSettings.rightLeg

                if setTargetHeadUI then setTargetHeadUI(TargetHead_S, false) end
                if setTargetUpperTorsoUI then setTargetUpperTorsoUI(TargetUpperTorso_S, false) end
                if setTargetLowerTorsoUI then setTargetLowerTorsoUI(TargetLowerTorso_S, false) end
                if setTargetLeftArmUI then setTargetLeftArmUI(TargetLeftArm_S, false) end
                if setTargetRightArmUI then setTargetRightArmUI(TargetRightArm_S, false) end
                if setTargetLeftLegUI then setTargetLeftLegUI(TargetLeftLeg_S, false) end
                if setTargetRightLegUI then setTargetRightLegUI(TargetRightLeg_S, false) end

                blatantSavedSettings = nil
            end
        end
        return
    end
end)

do
    _, setAimbotMasterUI = createToggleUI(aimbotContainer, "aimbot", AimbotMasterEnabled, function(val)
        AimbotMasterEnabled = val
        if AimbotMasterEnabled then
            if SilentAimEnabled then
                SilentAimEnabled = false
                if setSilentAimUI then setSilentAimUI(false, false) end
            end
        else
            AimbotEnabled = false
            ResetTarget()
        end
    end)

    _, Setters.setAimNpc = createToggleUI(aimbotContainer, "aim npcs", aimNpcEnabled, function(val)
        aimNpcEnabled = val
        if not val and currentTarget and currentTarget:IsA("Model") then ResetTarget() end
    end)

    _, Setters.setTeamCheck = createToggleUI(aimbotContainer, "team check", teamCheckEnabled, function(val)
        teamCheckEnabled = val
        if val and currentTarget and isTeammate(currentTarget) then ResetTarget() end
    end)

    _, Setters.setToggleKey = createKeybindUI(aimbotContainer, "aimbot key", toggleKey, function(key)
        toggleKey = key
    end)

    _, Setters.setAimPart = createDropdownUI(aimbotContainer, "aim part", {"Head", "UpperTorso", "LowerTorso"}, "Head", function(val)
        AimPart = val
    end)

    _, Setters.setSmoothing = createSliderUI(aimbotContainer, "smoothing", 0.01, 1, 0.01, smoothing, function(val)
        smoothing = val
    end)

    _, Setters.setPrediction = createSliderUI(aimbotContainer, "prediction", 0, 0.5, 0.01, predictionFactor, function(val)
        predictionFactor = val
    end)
end

do
    _, setSilentAimUI = createToggleUI(silentContainer, "silent aim", SilentAimEnabled, function(val)
        SilentAimEnabled = val
        if SilentAimEnabled then
            AimbotEnabled = false
            ResetTarget()
            if setAimbotMasterUI then setAimbotMasterUI(false, false) end
        else
            if isTriggerbotHolding then
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
                isTriggerbotHolding = false
            end
        end
    end)

    createToggleUI(silentContainer, "team check", silentTeamCheckEnabled, function(val) silentTeamCheckEnabled = val end)
    createToggleUI(silentContainer, "fov circle", CircleVisible, function(val) CircleVisible = val end)
    createToggleUI(silentContainer, "triggerbot", TriggerbotEnabled, function(val)
        TriggerbotEnabled = val
        if not val and isTriggerbotHolding then
            pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
            isTriggerbotHolding = false
        end
    end)
    createSliderUI(silentContainer, "burst limit", 0, 15, 1, TriggerbotBurstLimit, function(val) TriggerbotBurstLimit = val end)
    createToggleUI(silentContainer, "target npcs", TargetNpcs_S, function(val) TargetNpcs_S = val end)

    _, setTargetHeadUI = createToggleUI(silentContainer, "target head", TargetHead_S, function(val)
        TargetHead_S = val
        checkAndClearBlatant()
    end)
    _, setTargetUpperTorsoUI = createToggleUI(silentContainer, "target uppertorso", TargetUpperTorso_S, function(val)
        TargetUpperTorso_S = val
        checkAndClearBlatant()
    end)
    _, setTargetLowerTorsoUI = createToggleUI(silentContainer, "target lowertorso", TargetLowerTorso_S, function(val)
        TargetLowerTorso_S = val
        checkAndClearBlatant()
    end)
    _, setTargetLeftArmUI = createToggleUI(silentContainer, "target left arm", TargetLeftArm_S, function(val)
        TargetLeftArm_S = val
        checkAndClearBlatant()
    end)
    _, setTargetRightArmUI = createToggleUI(silentContainer, "target right arm", TargetRightArm_S, function(val)
        TargetRightArm_S = val
        checkAndClearBlatant()
    end)
    _, setTargetLeftLegUI = createToggleUI(silentContainer, "target left leg", TargetLeftLeg_S, function(val)
        TargetLeftLeg_S = val
        checkAndClearBlatant()
    end)
    _, setTargetRightLegUI = createToggleUI(silentContainer, "target right leg", TargetRightLeg_S, function(val)
        TargetRightLeg_S = val
        checkAndClearBlatant()
    end)

    createSliderUI(silentContainer, "fov radius", 20, 400, 5, SilentFOVRadius, function(val)
        SilentFOVRadius = val
        checkAndClearBlatant()
    end)

    createSliderUI(silentContainer, "outer fov radius", 50, 600, 10, OuterFOVRadius, function(val)
        OuterFOVRadius = val
        checkAndClearBlatant()
    end)

    _, setHitChanceUI = createSliderUI(silentContainer, "hit chance", 10, 100, 5, SilentHitChance, function(val)
        SilentHitChance = val
        checkAndClearBlatant()
    end)

    setBlatantKeyUI = createKeybindUI(silentContainer, "blatant mode key", blatantKey, function(key)
        blatantKey = key
    end)
end

do
    _, Setters.setNoRecoil = createToggleUI(modsContainer, "no recoil", noRecoilEnabled, function(val)
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
                if desc and desc.Parent then desc.Value = origVal end
            end
            originalRecoilValues = {}
        end
    end)

    _, Setters.setRapidFire = createToggleUI(modsContainer, "rapid fire", rapidFireEnabled, function(val)
        rapidFireEnabled = val
        if not val then
            for tbl, original in pairs(originalFireModes) do
                if type(tbl) == "table" then
                    if original.FireMode ~= nil then tbl.FireMode = original.FireMode end
                    if original.FireModes ~= nil then
                        tbl.FireModes = {}
                        for idx, mode in ipairs(original.FireModes) do tbl.FireModes[idx] = mode end
                    end
                    if original.Rate ~= nil then tbl.FireRate = original.FireRate end
                    if original.CycleTiming ~= nil then tbl.CycleTiming = original.CycleTiming end
                end
            end
            originalFireModes = {}
        end
    end)

    local originalAmmoDropValues = {}
    _, Setters.setNoBulletDrop = createToggleUI(modsContainer, "no bullet drop", noBulletDropEnabled, function(val)
        noBulletDropEnabled = val
        local ammoTypes = ReplicatedStorage:FindFirstChild("AmmoTypes")
        if not ammoTypes then return end

        if val then
            originalAmmoDropValues = {}
            for _, ammo in ipairs(ammoTypes:GetChildren()) do
                if ammo:IsA("Instance") then
                    originalAmmoDropValues[ammo] = ammo:GetAttribute("ProjectileDrop")
                    if ammo:GetAttribute("ProjectileDrop") ~= nil then ammo:SetAttribute("ProjectileDrop", 0) end
                end
            end
        else
            for ammo, origDrop in pairs(originalAmmoDropValues) do
                if ammo and ammo.Parent and origDrop ~= nil then ammo:SetAttribute("ProjectileDrop", origDrop) end
            end
            originalAmmoDropValues = {}
        end
    end)
end

createKeybindUI(configContainer, "gui toggle key", guiToggleKey, function(key)
    guiToggleKey = key
end)

local HttpService = game:GetService("HttpService")
local folderName = "FurHubConfigs"

if not isfolder(folderName) then makefolder(folderName) end

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1, -8, 0, 28)
configNameBox.BackgroundColor3 = ThemeColors.ButtonBackground
configNameBox.TextColor3 = ThemeColors.TextPrimary
configNameBox.TextSize = 12
configNameBox.Font = MAIN_FONT
configNameBox.PlaceholderText = "enter config name..."
configNameBox.Text = ""
configNameBox.Parent = configContainer
applyCorner(configNameBox, 4)
table.insert(themeElementsTracker.Buttons, configNameBox)
table.insert(themeElementsTracker.Texts, configNameBox)

local function getConfigsList()
    local files = listfiles(folderName)
    local list = {}
    for _, file in ipairs(files) do
        local name = file:match("[/\\]([^/\\]+)$") or file
        name = name:gsub("%.json$", "")
        if name ~= "" and name ~= "default" then table.insert(list, name) end
    end
    return list
end

local initialList = getConfigsList()
local initialSelection = #initialList > 0 and initialList[1] or ""

local loadDropdownContainer, selectLoadOpt, updateLoadDropdown = createDropdownUI(configContainer, "load config", initialList, initialSelection, function(val)
    configNameBox.Text = val
end)

if initialSelection ~= "" then configNameBox.Text = initialSelection end

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
        teamCheck = teamCheckEnabled,
        smoothing = smoothing,
        predictionFactor = predictionFactor,
        aimPart = AimPart,
        toggleKey = toggleKey.Name,
        guiToggleKey = guiToggleKey.Name,
        noRecoil = noRecoilEnabled,
        rapidFire = rapidFireEnabled,
        noBulletDrop = noBulletDropEnabled,
        silentAim = SilentAimEnabled,
        circleVisible = CircleVisible,
        triggerbot = TriggerbotEnabled,
        burstLimit = TriggerbotBurstLimit,
        silentFOV = SilentFOVRadius,
        outerFOV = OuterFOVRadius,
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

    local success, result = pcall(function() return readfile(path) end)

    if success and result then
        local successDec, data = pcall(function() return HttpService:JSONDecode(result) end)

        if successDec and data then
            if data.playerESP ~= nil then 
                playerESPEnabled = data.playerESP
                if setPlayerESPUI then setPlayerESPUI(data.playerESP, true) end
            end
            if data.gearESP ~= nil then Setters.setGearESP(data.gearESP, true) end
            if data.npcESP ~= nil then 
                npcESPEnabled = data.npcESP
                if setNpcESPUI then setNpcESPUI(data.npcESP, true) end
            end
            if data.noGrass ~= nil then Setters.setNoGrass(data.noGrass, true) end
            if data.fullbright ~= nil then Setters.setFullbright(data.fullbright, true) end
            if data.aimbotMaster ~= nil then setAimbotMasterUI(data.aimbotMaster, true) end
            if data.aimNpc ~= nil then Setters.setAimNpc(data.aimNpc, true) end
            if data.teamCheck ~= nil then Setters.setTeamCheck(data.teamCheck, true) end
            if data.smoothing ~= nil then Setters.setSmoothing(data.smoothing, true) end
            if data.predictionFactor ~= nil then Setters.setPrediction(data.predictionFactor, true) end
            if data.aimPart ~= nil then Setters.setAimPart(data.aimPart, true) end
            if data.toggleKey ~= nil and Enum.KeyCode[data.toggleKey] then Setters.setToggleKey(Enum.KeyCode[data.toggleKey], true) end
            if data.guiToggleKey ~= nil and Enum.KeyCode[data.guiToggleKey] then guiToggleKey = Enum.KeyCode[data.guiToggleKey] end
            if data.noRecoil ~= nil then Setters.setNoRecoil(data.noRecoil, true) end
            if data.rapidFire ~= nil then Setters.setRapidFire(data.rapidFire, true) end
            if data.noBulletDrop ~= nil then Setters.setNoBulletDrop(data.noBulletDrop, true) end
        end
    end
end

local function resetToDefault()
    playerESPEnabled = true
    npcESPEnabled = true
    if setPlayerESPUI then setPlayerESPUI(true, true) end
    if setNpcESPUI then setNpcESPUI(true, true) end
    Setters.setGearESP(false, true)
    Setters.setNoGrass(false, true)
    Setters.setFullbright(false, true)
    if setAimbotMasterUI then setAimbotMasterUI(true, true) end
    Setters.setAimNpc(true, true)
    Setters.setTeamCheck(true, true)
    Setters.setSmoothing(0.2, true)
    Setters.setPrediction(0.12, true)
    Setters.setAimPart("Head", true)
    Setters.setToggleKey(Enum.KeyCode.X, true)
    guiToggleKey = Enum.KeyCode.RightShift
    Setters.setNoRecoil(false, true)
    Setters.setRapidFire(false, true)
    Setters.setNoBulletDrop(false, true)
end

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -8, 0, 28)
saveBtn.BackgroundColor3 = Color3.fromRGB(35, 110, 50)
saveBtn.TextColor3 = ThemeColors.TextPrimary
saveBtn.TextSize = 12
saveBtn.Font = MAIN_FONT
saveBtn.Text = "save config"
saveBtn.Parent = configContainer
applyCorner(saveBtn, 4)
table.insert(themeElementsTracker.Texts, saveBtn)

saveBtn.MouseButton1Click:Connect(function() saveCurrentConfig() end)

loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(1, -8, 0, 28)
loadBtn.BackgroundColor3 = Color3.fromRGB(110, 35, 35)
loadBtn.TextColor3 = ThemeColors.TextPrimary
loadBtn.TextSize = 12
loadBtn.Font = MAIN_FONT
loadBtn.Text = "load selected config"
loadBtn.Parent = configContainer
applyCorner(loadBtn, 4)
table.insert(themeElementsTracker.Texts, loadBtn)

loadBtn.MouseButton1Click:Connect(function() loadConfigByName(configNameBox.Text) end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -8, 0, 28)
resetBtn.BackgroundColor3 = Color3.fromRGB(110, 75, 35)
resetBtn.TextColor3 = ThemeColors.TextPrimary
resetBtn.TextSize = 12
resetBtn.Font = MAIN_FONT
resetBtn.Text = "reset to default"
resetBtn.Parent = configContainer
applyCorner(resetBtn, 4)
table.insert(themeElementsTracker.Texts, resetBtn)

resetBtn.MouseButton1Click:Connect(function() resetToDefault() end)

local removeAllBtn = Instance.new("TextButton")
removeAllBtn.Size = UDim2.new(1, -8, 0, 28)
removeAllBtn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
removeAllBtn.TextColor3 = ThemeColors.TextPrimary
removeAllBtn.TextSize = 12
removeAllBtn.Font = MAIN_FONT
removeAllBtn.Text = "remove all configs"
removeAllBtn.Parent = configContainer
applyCorner(removeAllBtn, 4)
table.insert(themeElementsTracker.Texts, removeAllBtn)

removeAllBtn.MouseButton1Click:Connect(function()
    local files = listfiles(folderName)
    for _, file in ipairs(files) do delfile(file) end
    refreshDropdown()
    configNameBox.Text = ""
end)
