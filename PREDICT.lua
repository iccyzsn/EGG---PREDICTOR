-- // EGG SCANNER & MINI-DEX (Smart Search Edition) \\ --
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 1. Create the Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggScannerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 2. Create the Main Window
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(1, -370, 0.5, -225) 
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- 3. Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.TextScaled = true
title.Text = "🥚 EGG ANALYZER v1.0"
title.Font = Enum.Font.Code
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- 4. Prediction Box (Top)
local predictionBox = Instance.new("Frame")
predictionBox.Size = UDim2.new(1, -20, 0, 60)
predictionBox.Position = UDim2.new(0, 10, 0, 50)
predictionBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
predictionBox.Parent = mainFrame

local predCorner = Instance.new("UICorner")
predCorner.Parent = predictionBox

local predictionText = Instance.new("TextLabel")
predictionText.Size = UDim2.new(1, -10, 1, -10)
predictionText.Position = UDim2.new(0, 5, 0, 5)
predictionText.BackgroundTransparency = 1
predictionText.TextColor3 = Color3.fromRGB(255, 255, 255)
predictionText.TextWrapped = true
predictionText.TextScaled = true
predictionText.Text = "Walk near an egg and Scan."
predictionText.Font = Enum.Font.Gotham
predictionText.Parent = predictionBox

-- 5. Explorer/DEX List (Scrolling Frame)
local explorerFrame = Instance.new("ScrollingFrame")
explorerFrame.Size = UDim2.new(1, -20, 1, -170)
explorerFrame.Position = UDim2.new(0, 10, 0, 120)
explorerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
explorerFrame.ScrollBarThickness = 4
explorerFrame.Parent = mainFrame

local explorerCorner = Instance.new("UICorner")
explorerCorner.Parent = explorerFrame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Padding = UDim.new(0, 2)
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Parent = explorerFrame

-- 6. Scan Button (Bottom)
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -20, 0, 40)
scanBtn.Position = UDim2.new(0, 10, 1, -50)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextScaled = true
scanBtn.Text = "🔍 SCAN NEAREST EGG"
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.Parent = scanBtn

-- // THE LOGIC // --

local function clearExplorer()
    for _, child in pairs(explorerFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function addExplorerLine(propertyName, value, color)
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -10, 0, 20)
    line.BackgroundTransparency = 1
    line.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextScaled = true
    line.Font = Enum.Font.Code
    line.Text = "  " .. propertyName .. ": " .. tostring(value)
    line.LayoutOrder = #explorerFrame:GetChildren()
    line.Parent = explorerFrame
end

-- Function to safely read properties (Now handles Models properly!)
local function scanObject(obj, plotName)
    clearExplorer()
    
    if not obj then
        addExplorerLine("ERROR", "Egg not found!", Color3.fromRGB(255, 50, 50))
        return
    end

    addExplorerLine("Plot Origin", plotName, Color3.fromRGB(255, 100, 255))
    addExplorerLine("ClassName", obj.ClassName, Color3.fromRGB(255, 200, 0))
    addExplorerLine("Name", obj.Name, Color3.fromRGB(255, 255, 255))
    
    -- If it's a model, get the position of its primary part
    if obj:IsA("Model") then
        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if primary then
            pcall(function() addExplorerLine("Position", tostring(primary.Position), Color3.fromRGB(100, 255, 255)) end)
        end
    else
        -- If it's a regular part
        pcall(function() addExplorerLine("Position", tostring(obj.Position), Color3.fromRGB(100, 255, 255)) end)
        pcall(function() addExplorerLine("Material", tostring(obj.Material), Color3.fromRGB(150, 255, 150)) end)
        pcall(function() addExplorerLine("Color", tostring(obj.Color), Color3.fromRGB(255, 150, 150)) end)
        pcall(function() addExplorerLine("Size", tostring(obj.Size), Color3.fromRGB(255, 255, 150)) end)
        pcall(function() addExplorerLine("Transparency", tostring(obj.Transparency), Color3.fromRGB(200, 200, 200)) end)
    end
    
    addExplorerLine("--- ATTRIBUTES ---", "", Color3.fromRGB(255, 100, 0))
    local attributes = obj:GetAttributes()
    if next(attributes) == nil then
        addExplorerLine("Attributes", "None", Color3.fromRGB(150, 150, 150))
    else
        for attrName, attrValue in pairs(attributes) do
            addExplorerLine("  " .. attrName, tostring(attrValue), Color3.fromRGB(0, 255, 150))
        end
    end
    
    addExplorerLine("--- CHILDREN ---", "", Color3.fromRGB(255, 100, 0))
    for _, child in pairs(obj:GetChildren()) do
        addExplorerLine("  [" .. child.ClassName .. "]", child.Name, Color3.fromRGB(200, 200, 255))
    end
end

-- SMART SEARCH: Finds any object with "Egg" in its name near the player
local function findClosestEgg()
    local plotsFolder = workspace:WaitForChild("Plots")
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil, nil end
    
    local rootPos = character.HumanoidRootPart.Position
    local closestEgg = nil
    local closestPlotName = nil
    local shortestDistance = 50 -- Increased range to 50 studs
    
    -- Loop through all plots
    for _, plotFolder in pairs(plotsFolder:GetChildren()) do
        -- Look through EVERYTHING inside the plot (models, parts, etc.)
        for _, obj in pairs(plotFolder:GetDescendants()) do
            -- If the object is a Part or Model, and has "egg" in its name (ignores uppercase/lowercase)
            if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), "egg") then
                
                -- Get the actual 3D position of this egg
                local eggPart = obj
                if obj:IsA("Model") then
                    eggPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end
                
                if eggPart then
                    local dist = (eggPart.Position - rootPos).Magnitude
                    -- If it's closer than the last egg we found, save this one
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestEgg = obj
                        closestPlotName = plotFolder.Name
                    end
                end
            end
        end
    end
    
    return closestEgg, closestPlotName
end

-- Function to run the actual prediction
local function runPrediction()
    predictionText.Text = "Scanning nearby plots..."
    predictionText.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    task.wait(1)

    -- Find the closest egg using the Smart Search
    local egg, plotName = findClosestEgg()

    if not egg then
        predictionText.Text = "No egg found nearby. Make sure you are near an egg!"
        predictionText.TextColor3 = Color3.fromRGB(255, 100, 100)
        clearExplorer()
        addExplorerLine("STATUS", "Out of Range", Color3.fromRGB(255, 50, 50))
        return
    end

    -- 1. Study the object like a DEX
    scanObject(egg, plotName)

    -- 2. Make a prediction based on what we found
    local predictionMsg = "Unable to determine contents."
    local predColor = Color3.fromRGB(255, 255, 255)

    -- Check if the egg has a custom Attribute named "HiddenPet"
    if egg:GetAttribute("HiddenPet") ~= nil then
        local pet = egg:GetAttribute("HiddenPet")
        local rarity = egg:GetAttribute("Rarity") or "Unknown"
        
        predictionMsg = "PREDICTION: " .. pet .. "\nRARITY: " .. rarity
        predColor = Color3.fromRGB(0, 255, 150)
    else
        -- If no attribute is found, it's a mystery!
        predictionMsg = "No hidden data detected. Contents are purely random."
        predColor = Color3.fromRGB(255, 100, 100)
    end

    predictionText.Text = predictionMsg
    predictionText.TextColor3 = predColor
end

-- Connect the button click
scanBtn.MouseButton1Click:Connect(runPrediction)
