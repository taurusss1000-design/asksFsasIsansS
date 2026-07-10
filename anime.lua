local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Auto Fish Anime - Blatant",
    Icon = "rbxassetid://139467646163013",
    Folder = "AnimeFish",
    Size = UDim2.new(0, 530, 0, 300),
    NewElements = true,
})

Window:Tag({ Title = "SKIP MINIGAME", Color = Color3.fromHex("#EF4F1D") })

local FishingTab = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local FishingServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("FishingService"):WaitForChild("RE")

local AutoFish = {
    Active = false,
    WaitTime = 3,
}

local castLoop
local fishCaughtConnection
local guiConnection

function AutoFish.Start()
    if AutoFish.Active then return end
    AutoFish.Active = true
    
    -- 1. SEMBUNYIKAN GUI MINIGAME (Biar nggak nutupin layar/nyangkut)
    guiConnection = LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
        if not AutoFish.Active then return end
        if descendant:IsA("ScreenGui") or descendant:IsA("Frame") or descendant:IsA("ImageLabel") then
            local name = descendant.Name:lower()
            if name:find("minigame") or name:find("fishing") or name:find("bar") or name:find("fish") then
                task.spawn(function()
                    task.wait(0.1)
                    if descendant.Parent then
                        pcall(function() descendant.Visible = false end)
                    end
                end)
            end
        end
    end)
    
    -- 2. BLATANT SKIP MINIGAME
    fishCaughtConnection = FishingServiceRE:WaitForChild("FishCaught").OnClientEvent:Connect(function(fishData)
        if not AutoFish.Active then return end
        
        task.spawn(function()
            -- Kasih delay dikit biar server gak detect kita nyelesain minigame 0 detik
            task.wait(AutoFish.WaitTime)
            
            pcall(function()
                FishingServiceRE:WaitForChild("SetRodLock"):FireServer(true)
                
                -- Kirim sukses minigame instan (Bypass 2 stage minigame)
                local successData = {
                    yanksCompleted = math.random(2, 4),
                    minigameDurationMs = math.random(1500, 4000),
                    redBarDangerTicks = math.random(10, 40),
                    snagAttempts = 0,
                    snagSuccesses = 0,
                    maxRedBarProximity = math.random(),
                    totalSpamPoints = math.random(20, 50)
                }
                FishingServiceRE:WaitForChild("FishingSuccess"):FireServer(true, successData)
                
                if type(fishData) == "table" then
                    FishingServiceRE:WaitForChild("ThrowFish"):FireServer(fishData)
                    FishingServiceRE:WaitForChild("CreateHandFish"):FireServer(fishData)
                end
                
                task.wait(1)
                
                -- Bersih-bersih
                FishingServiceRE:WaitForChild("DestroyHandFish"):FireServer()
                FishingServiceRE:WaitForChild("Cleanup"):FireServer(true)
                FishingServiceRE:WaitForChild("SetRodLock"):FireServer(false)
            end)
            
            -- Lempar ulang otomatis
            task.wait(1.5)
            if AutoFish.Active then
                pcall(function()
                    FishingServiceRE:WaitForChild("FishingStarted"):FireServer(1.5 + math.random())
                end)
            end
        end)
    end)
    
    -- Mulai lempar pancingan
    castLoop = task.spawn(function()
        pcall(function()
            FishingServiceRE:WaitForChild("FishingStarted"):FireServer(1.5 + math.random())
        end)
        
        -- Fallback loop misal server ngelag atau pancingan lepas
        while AutoFish.Active do
            task.wait(15)
            pcall(function()
                FishingServiceRE:WaitForChild("FishingStarted"):FireServer(1.5 + math.random())
            end)
        end
    end)
end

function AutoFish.Stop()
    AutoFish.Active = false
    if fishCaughtConnection then fishCaughtConnection:Disconnect() fishCaughtConnection = nil end
    if guiConnection then guiConnection:Disconnect() guiConnection = nil end
    if castLoop then task.cancel(castLoop) castLoop = nil end
end

local Section = FishingTab:Section({ Title = "Blatant Fishing (Skip Minigame)" })

Section:Toggle({
    Title = "Auto Fish (Skip Minigame)",
    Callback = function(state)
        if state then
            AutoFish.Start()
        else
            AutoFish.Stop()
        end
    end
})

Section:Input({
    Title = "Bypass Delay (Detik)",
    Value = tostring(AutoFish.WaitTime),
    Type = "Input",
    Placeholder = "3",
    Callback = function(input)
        local num = tonumber(input)
        if num then
            AutoFish.WaitTime = num
        end
    end
})
