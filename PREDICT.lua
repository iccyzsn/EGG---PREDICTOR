-- // EGG SCANNER & MINI-DEX (Global Search & Deep Scan Edition) \\ --
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
title.Text = "🥚 EGG ANALYZER v2.0"
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

-- Function to safely read properties and deep scan children
local function scanObject(obj)
    clearExplorer()
    
    if not obj then
        addExplorerLine("ERROR", "Egg not found!", Color3.fromRGB(255, 50, 50))
        return
    end

    addExplorerLine("ClassName", obj.ClassName, Color3.fromRGB(255, 200, 0))
    addExplorerLine("Name", obj.Name, Color3.fromRGB(255, 255, 255))
    
    -- Get Position safely
    local eggPart = obj
    if obj:IsA("Model") then
        eggPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    if eggPart then
        pcall(function() addExplorerLine("Position", tostring(eggPart.Position), Color3.fromRGB(100, 255, 255)) end)
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
    
    -- Deep scan children (This will find your EggData folder!)
    addExplorerLine("--- CHILDREN ---", "", Color3.fromRGB(255, 100, 0))
    for _, child in pairs(obj:GetChildren()) do
        addExplorerLine("  [" .. child.ClassName .. "]", child.Name, Color3.fromRGB(200, 200, 255))
        
        -- If the child is a folder (like EggData), dig one level deeper!
        if child:IsA("Folder") or child:IsA("Configuration") then
            for _, subChild in pairs(child:GetChildren()) do
                addExplorerLine("    [" .. subChild.ClassName .. "]", subChild.Name, Color3.fromRGB(180, 180, 220))
                -- If it's a value object (StringValue, IntValue etc), show its value!
                if subChild:IsA("ValueBase") then
                    addExplorerLine("      Value", tostring(subChild.Value), Color3.fromRGB(255, 255, 100))
                end
            end
        end
    end
end

-- GLOBAL SEARCH: Finds any object with "Egg" in its name near the player
local function findClosestEgg()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local rootPos = character.HumanoidRootPart.Position
    local closestEgg = nil
    local shortestDistance = 50 -- 50 stud range
    
    -- Search the ENTIRE workspace, not just Plots
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Must be a Model or Part, and have "egg" in the name
        if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), "egg") then
            
            -- Ignore things inside ReplicatedStorage/ServerStorage if they somehow got into workspace
            -- (We only want the actual eggs sitting on the ground)
            local eggPart = obj
            if obj:IsA("Model") then
                eggPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            end
                
            if eggPart then
                local dist = (eggPart.Position - rootPos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestEgg = obj
                end
            end
        end
    end
    
    return closestEgg
end

-- Function to run the actual prediction
local function runPrediction()
    predictionText.Text = "Scanning nearby environment..."
    predictionText.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    task.wait(1)

    local egg = findClosestEgg()

    if not egg then
        predictionText.Text = "No egg found nearby. Walk closer to an egg!"
        predictionText.TextColor3 = Color3.fromRGB(255, 100, 100)
        clearExplorer()
        addExplorerLine("STATUS", "Out of Range", Color3.fromRGB(255, 50, 50))
        return
    end

    -- 1. Deep Study the object
    scanObject(egg)

    -- 2. Make a prediction based on what we found
    local predictionMsg = "Unable to determine contents."
    local predColor = Color3.fromRGB(255, 255, 255)

    -- Check Attributes first
    if egg:GetAttribute("HiddenPet") ~= nil then
        local pet = egg:GetAttribute("HiddenPet")
        local rarity = egg:GetAttribute("Rarity") or "Unknown"
        predictionMsg = "PREDICTION: " .. pet .. "\nRARITY: " .. rarity
        predColor = Color3.fromRGB(0, 255, 150)
    else
        -- Check inside the EggData folder for a Value object (like a StringValue named "Pet")
        local eggData = egg:FindFirstChild("EggData")
        if eggData then
            local petValue = eggData:FindFirstChild("Pet") or eggData:FindFirstChild("HiddenPet") or eggData:FindFirstChild("PetName")
            if petValue and petValue:IsA("StringValue") then
                predictionMsg = "PREDICTION: " .. petValue.Value
                predColor = Color3.fromRGB(0, 255, 150)
            end
        else
            predictionMsg = "No EggData or Attributes detected. Random contents."
            predColor = Color3.fromRGB(255, 100, 100)
        end
    end

    predictionText.Text = predictionMsg
    predictionText.TextColor3 = predColor
end

-- Connect the button click
scanBtn.MouseButton1Click:Connect(runPrediction)
