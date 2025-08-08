for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v:IsA("TextLabel") and v.Text == "by ywxo" then
        local screenGui = v:FindFirstAncestorOfClass("ScreenGui")
        if screenGui then
            screenGui:Destroy()
        end
    end
end
for _,v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v.Name == "ywxoscriptToggle" then
        v:Destroy()
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Pet Leveling " .. Fluent.Version,
    SubTitle = "by ywxo",
    TabWidth = 160,
    Size = UDim2.fromOffset(680, 600),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Mobile = Window:AddTab({ Title = "Mobile", Icon = "smartphone" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local LevelingEnabled = false
local SelectedPetToLevel
local SelectedLevelingPet
local SupportPets = {}
local UnequipList = {}
local Backpack = game.Players.LocalPlayer:WaitForChild("Backpack")
local PetsService = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetsService")

local Wildcards = {"Mimic", "Nihonzaru", "Sloth", "Ascended"}

local function MatchesWildcard(name)
    for _, pattern in ipairs(Wildcards) do
        if string.find(name:lower(), pattern:lower()) then
            return true
        end
    end
    return false
end

local function GetAllPetNames()
    local names = {}
    for _, item in ipairs(Backpack:GetChildren()) do
        if item:GetAttribute("ItemType") == "Pet" then
            table.insert(names, item.Name)
        end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local function GetFilteredPetNames()
    local names = {}
    for _, item in ipairs(Backpack:GetChildren()) do
        if item:GetAttribute("ItemType") == "Pet" and MatchesWildcard(item.Name) then
            table.insert(names, item.Name)
        end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local petNamesAll = GetAllPetNames()
local petNamesFiltered = GetFilteredPetNames()

Tabs.Main:AddDropdown("PetToLevel", {
    Title = "Pet to Level",
    Description = "Select the pet you want to level up",
    Values = petNamesAll,
    Multi = false,
    Default = nil,
    Callback = function(Value)
        if type(Value) == "string" then
            local pet = Backpack:FindFirstChild(Value)
            if pet then
                SelectedPetToLevel = pet:GetAttribute("PET_UUID")
            end
        end
    end
})

Tabs.Main:AddDropdown("LevelingPet", {
    Title = "Leveling Pet",
    Description = "Select the pet with leveling abilities",
    Values = petNamesFiltered,
    Multi = false,
    Default = nil,
    Callback = function(Value)
        if type(Value) == "string" then
            local pet = Backpack:FindFirstChild(Value)
            if pet then
                SelectedLevelingPet = pet:GetAttribute("PET_UUID")
            end
        end
    end
})

for i = 1, 6 do
    Tabs.Main:AddDropdown("SupportPet"..i, {
        Title = "Support Pet "..i,
        Description = "Select support pet #"..i,
        Values = petNamesFiltered,
        Multi = false,
        Default = nil,
        Callback = function(Value)
            if type(Value) == "string" then
                local pet = Backpack:FindFirstChild(Value)
                if pet then
                    SupportPets[i] = pet:GetAttribute("PET_UUID")
                else
                    SupportPets[i] = nil
                end
            end
        end
    })
end

local function CheckCooldown(petUUID)
    local success, cooldowns = pcall(function()
        return game:GetService("ReplicatedStorage").GameEvents:WaitForChild("GetPetCooldown"):InvokeServer(petUUID)
    end)
    if success and type(cooldowns) == "table" then
        for _, cd in pairs(cooldowns) do
            if cd.Time <= 0 then
                return true
            end
        end
    end
    return false
end

Tabs.Main:AddToggle("LevelToggle", {
    Title = "Tactical Leveling",
    Description = "Automatically manage pets for optimal leveling",
    Default = false,
    Callback = function(Value)
        LevelingEnabled = Value
        if Value then
            task.spawn(function()
                if SelectedLevelingPet then
                    pcall(function()
                        PetsService:FireServer("EquipPet", SelectedLevelingPet, CFrame.new(43.28, 0, -87.71))
                    end)
                end
                for _, uuid in pairs(SupportPets) do
                    if uuid then
                        pcall(function()
                            PetsService:FireServer("EquipPet", uuid, CFrame.new(43.28, 0, -87.71))
                        end)
                    end
                end
                for _, uuid in ipairs(UnequipList) do
                    pcall(function()
                        PetsService:FireServer("UnequipPet", uuid)
                    end)
                end
                local SupportActive = true
                while LevelingEnabled and task.wait(0.5) do
                    pcall(function()
                        if SelectedLevelingPet then
                            local IsReady = CheckCooldown(SelectedLevelingPet)
                            if IsReady and SupportActive then
                                task.wait(0.2)
                                for _, uuid in pairs(SupportPets) do
                                    if uuid then
                                        PetsService:FireServer("UnequipPet", uuid)
                                    end
                                end
                                if SelectedPetToLevel then
                                    PetsService:FireServer("EquipPet", SelectedPetToLevel, CFrame.new(43.28, 0, -87.71))
                                end
                                SupportActive = false
                            elseif not IsReady and not SupportActive then
                                task.wait(5)
                                for _, uuid in pairs(SupportPets) do
                                    if uuid then
                                        task.wait(0.5)
                                        PetsService:FireServer("EquipPet", uuid, CFrame.new(43.28, 0, -87.71))
                                    end
                                end
                                if SelectedPetToLevel then
                                    PetsService:FireServer("UnequipPet", SelectedPetToLevel)
                                end
                                SupportActive = true
                            end
                        end
                    end)
                end
            end)
        end
    end
})

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

Tabs.Mobile:AddButton({
    Title = "Create Mobile Toggle",
    Description = "Creates a movable toggle button for mobile users",
    Callback = function()
        for _, v in pairs(CoreGui:GetDescendants()) do
            if v.Name == "ywxoscriptToggle" then
                v:Destroy()
            end
        end
        local MobileToggle = Instance.new("ScreenGui")
        local ToggleButton = Instance.new("ImageButton")
        local UICorner = Instance.new("UICorner")
        MobileToggle.Name = "ywxoscriptToggle"
        MobileToggle.Parent = CoreGui
        MobileToggle.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        MobileToggle.ResetOnSpawn = false
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = MobileToggle
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.Position = UDim2.new(0.8, 0, 0.5, 0)
        ToggleButton.Size = UDim2.new(0, 100, 0, 100)
        ToggleButton.Image = "rbxassetid://71867797281940"
        UICorner.CornerRadius = UDim.new(0, 20)
        UICorner.Parent = ToggleButton
        local dragging = false
        local dragInput, dragStart, startPos
        local function Update(input)
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        ToggleButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                Update(input)
            end
        end)
        ToggleButton.InputEnded:Connect(function(input)
            if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                for _, v in pairs(CoreGui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text == "by ywxo" then
                        local screenGui = v:FindFirstAncestorOfClass("ScreenGui")
                        if screenGui then
                            screenGui.Enabled = not screenGui.Enabled
                        end
                    end
                end
            end
        end)
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ywxoscripts")
SaveManager:SetFolder("ywxoscripts/petleveling")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
