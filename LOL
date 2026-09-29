--// ANTI AFK & AUTO LOAD CHECK
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local VirtualUser = game:GetService("VirtualUser")

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// SERVICES & REFERENCES (PINAGSAMA SA PINAKA-TAAS)
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local MaterialService = cloneref(game:GetService("MaterialService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local TweenService = cloneref(game:GetService("TweenService"))

--// PLAYER REFERENCES
local Player = Players.LocalPlayer
local LocalPlayer = Player
local SavedData = LocalPlayer:WaitForChild("SavedData")
local Cash = SavedData:WaitForChild("Cash")
local Rebirths = SavedData:WaitForChild("Rebirths")
local OwnedPetsIndex = SavedData:WaitForChild("OwnedPets")
local IndexRewardStage = SavedData:WaitForChild("IndexRewardStage")

--// GAME MODULES & REMOTES (PINAGSAMA SA TAAS)
local GameServices = ReplicatedStorage:WaitForChild("GameServices")
local GameData = ReplicatedStorage:WaitForChild("GameData")

local General_m = require(GameServices:WaitForChild("General"))
local General_m_Hatch = General_m
local PetAging_m = require(GameServices:WaitForChild("PetAging"))
local DayNight_mData = require(GameServices:WaitForChild("DayNight"))

local Pets_m = require(GameData:WaitForChild("Pets"))
local Mutations_m = require(GameData:WaitForChild("Mutations"))
local Eggs_mData = require(GameData:WaitForChild("Eggs"))
local General_mData = require(GameData:WaitForChild("General"))
local Rebirths_m = require(GameData:WaitForChild("Rebirths"))
local IndexRewards = require(GameData:WaitForChild("IndexRewards"))

local PetRenderer_m = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))

local GameRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local BuyWithCash = GameRemotes:WaitForChild("BuyWithCash")
local ShopStockRemote = GameRemotes:WaitForChild("ShopStock")
local RestockRemote = GameRemotes:WaitForChild("Restock")
local PlacePetRemote = GameRemotes:WaitForChild("PlacePet")
local PickupPetRemote = GameRemotes:WaitForChild("PickupPet")
local ClaimIndexReward = GameRemotes:WaitForChild("ClaimIndexReward")
local FavoritePetRemote = GameRemotes:WaitForChild("FavoritePet")

-- PINALITAN ANG BASKET DROP REMOTE PATUNGO SA VOLCANO DIP REMOTE
local VolcanoDipRemote = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/VolcanoDip")



--// SELL SHOP REMOTES & REFERENCES
local DialogueRemotes = ReplicatedStorage:WaitForChild("Dialogue"):WaitForChild("Remotes")
local DialogueSelect = DialogueRemotes:WaitForChild("DialogueSelect")
local DialogueTypingDone = DialogueRemotes:WaitForChild("DialogueTypingDone")
local DialogueSend = DialogueRemotes:WaitForChild("DialogueSend")
local ConfirmRequest = GameRemotes:WaitForChild("ConfirmRequest")

local RichieNPC = workspace:WaitForChild("Stalls"):WaitForChild("Sell"):WaitForChild("Richie")
local latestRequestId = nil

-- Dynamic Request ID Sniffer
for _, remote in ipairs(GameRemotes:GetChildren()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            for i = 1, #args do
                if type(args[i]) == "string" and #args[i] >= 30 then
                    latestRequestId = args[i]
                end
            end
        end)
    end
end

-- Bypass dialogue typing animation
DialogueSend.OnClientEvent:Connect(function(data)
    if data and data.Model == RichieNPC and data.AwaitComplete then
        DialogueTypingDone:FireServer(data.Model, data.CompleteToken)
    end
end)


--// WINDUI INITIALIZATION
local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if RunService:IsStudio() or not writefile then
			WindUI = require(
				ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")
			)
		else
			WindUI =
				loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
					)
				)()
		end
	end
end

--// SETTINGS & CONFIG MANAGER
local ConfigFile = "LunaHub_Config.json"
local isResetting = false

local ConfigData = {
	SelectedEggs = {},
	SelectedRarities = {},
	SelectedPlaceEgg = {},
	SelectedPlaceRarities = {},
	AutoPickup = false,
	AutoVolcanoDip = false,
	AutoPlaceEgg = false,
	AutoHatchEgg = false,
	AutoUpgradeHatchLuck = false,
	AutoUpgradeHatchLuckMax = false,
	AutoRebirth = false,
	AutoClaimIndex = false,
	AutoClaimOffline = false,
	SelectedGear = {},
	Autobuygear = false,
	SelectedFood = {},
    AutoSellAllPets = false,    
    SelectedPetToSell = {},
    SelectedSellRarities = {},
	Autobuyfood = false,
	SelectedESPEggs = {},
	SelectedESPRarities = {},
	FPSBoost = false,
    AutoSellPet = false,
	AutoEquipBestPet = false,
	ESPEnabled = false,
	SelectedFavPet = {},
    HideEggs = false,
	AutoFavoritePet = false
}

local function LoadConfig()
	if isfile and readfile and isfile(ConfigFile) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)
		if success and type(result) == "table" then
			for k, v in pairs(result) do
				ConfigData[k] = v
			end
		end
	end
end

local function SaveConfig()
	if isResetting then return end
	if writefile then
		pcall(function()
			writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
		end)
	end
end

LoadConfig()

local ThemeName = "Dark"

-- MULTI-SELECT TABLES
local SelectedEggs = ConfigData.SelectedEggs or {}
local SelectedRarities = ConfigData.SelectedRarities or {}
local SelectedPlaceEgg = ConfigData.SelectedPlaceEgg or {}
local SelectedPlaceRarities = ConfigData.SelectedPlaceRarities or {}
local SelectedESPEggs = ConfigData.SelectedESPEggs or {}
local SelectedESPRarities = ConfigData.SelectedESPRarities or {}
local SelectedGear = ConfigData.SelectedGear or {}
local SelectedFood = ConfigData.SelectedFood or {}
local SelectedPetToSell = ConfigData.SelectedPetToSell or {}
local SelectedSellRarities = ConfigData.SelectedSellRarities or {}
local SelectedFavPet = ConfigData.SelectedFavPet or {}

-- TOGGLES
local AutoPickup = ConfigData.AutoPickup or false
local AutoVolcanoDip = ConfigData.AutoVolcanoDip or false
local HideEggs = ConfigData.HideEggs or false
local AutoPlaceEgg = ConfigData.AutoPlaceEgg or false
local AutoHatchEgg = ConfigData.AutoHatchEgg or false
local AutoClaimIndex = ConfigData.AutoClaimIndex or false
local AutoClaimOffline = ConfigData.AutoClaimOffline or false
local AutoUpgradeHatchLuck = ConfigData.AutoUpgradeHatchLuck or false
local AutoUpgradeHatchLuckMax = ConfigData.AutoUpgradeHatchLuckMax or false
local AutoRebirth = ConfigData.AutoRebirth or false
local ESPEnabled = ConfigData.ESPEnabled or false
local Autobuygear = ConfigData.Autobuygear or false
local Autobuyfood = ConfigData.Autobuyfood or false
local FPSBoost = ConfigData.FPSBoost or false
local AutoEquipBestPet = ConfigData.AutoEquipBestPet or false
local AutoSellPet = ConfigData.AutoSellPet or false
local AutoSellAllPets = ConfigData.AutoSellAllPets or false
local AutoFavoritePet = ConfigData.AutoFavoritePet or false


-- UI ELEMENT REFERENCES FOR RESET
local UIElements = {}

local function SetUIValue(element, newValue)
	if not element then return end
	pcall(function()
		if element.Set then
			element:Set(newValue)
		elseif element.SetValue then
			element:SetValue(newValue)
		elseif element.Value ~= nil then
			element.Value = newValue
		end
	end)
end


--NO PROMPT
for i,v in pairs(game:GetService("Workspace"):GetDescendants()) do
	if v:IsA("ProximityPrompt") then
		v["HoldDuration"] = 0
	end
end


game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(v)
    v["HoldDuration"] = 0
end)


--==================================================
-- HELPER FUNCTIONS (DEFINED EARLY FOR BUTTONS/LOOPS)
--==================================================

local function GetCharacter()
	local Character = Player.Character
	if not Character then return nil end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not HRP then return nil end
	return Character
end

local function TeleportToMyPlot()
	local Character = GetCharacter()
	if not Character then return false end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return false end

	local Plots = workspace:FindFirstChild("Plots")
	if not Plots then return false end

	local MyPlot = nil
	for _, Plot in ipairs(Plots:GetChildren()) do
		local NestsOwnerLoaded = Plot:GetAttribute("NestsOwnerLoaded")
		if NestsOwnerLoaded == Player.UserId then
			MyPlot = Plot
			break
		end

		local Owner = Plot:GetAttribute("Owner")
		local OwnerUserId = Plot:GetAttribute("OwnerUserId")
		local UserId = Plot:GetAttribute("UserId")

		if Owner == Player.Name or Owner == Player.UserId or OwnerUserId == Player.UserId or UserId == Player.UserId then
			MyPlot = Plot
			break
		end
	end

	if not MyPlot then return false end

	local Baseplate = MyPlot:FindFirstChild("Baseplate")
	if Baseplate and Baseplate:IsA("BasePart") then
		HRP.CFrame = Baseplate.CFrame * CFrame.new(0, 3, 0)
		return true
	end

	local PlotPart = MyPlot:FindFirstChildWhichIsA("BasePart", true)
	if PlotPart then
		HRP.CFrame = PlotPart.CFrame * CFrame.new(0, 3, 0)
		return true
	end

	return false
end

--==================================================
-- FPS BOOST & RESTORE SYSTEM
--==================================================

local SavedGraphicsState = {
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	ShadowSoftness = Lighting.ShadowSoftness,
	QualityLevel = settings().Rendering.QualityLevel,
	MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel,
	Materials = {},
	WaterWaveSize = nil,
	WaterWaveSpeed = nil,
	WaterReflectance = nil,
	WaterTransparency = nil,
	OriginalProps = {}
}

local function SaveOriginalGraphics()
	SavedGraphicsState.GlobalShadows = Lighting.GlobalShadows
	SavedGraphicsState.FogEnd = Lighting.FogEnd
	SavedGraphicsState.ShadowSoftness = Lighting.ShadowSoftness
	SavedGraphicsState.QualityLevel = settings().Rendering.QualityLevel
	SavedGraphicsState.MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		SavedGraphicsState.WaterWaveSize = terrain.WaterWaveSize
		SavedGraphicsState.WaterWaveSpeed = terrain.WaterWaveSpeed
		SavedGraphicsState.WaterReflectance = terrain.WaterReflectance
		SavedGraphicsState.WaterTransparency = terrain.WaterTransparency
	end
end

SaveOriginalGraphics()

local FPSConn = nil

local function ApplyFPSBoost(state)
	if state then
		SaveOriginalGraphics()

		pcall(function() Lighting.GlobalShadows = false end)
		pcall(function() Lighting.FogEnd = 9e9 end)
		pcall(function() Lighting.ShadowSoftness = 0 end)

		if sethiddenproperty then
			pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
		end

		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
		end)

		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function()
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 0
				if sethiddenproperty then
					sethiddenproperty(terrain, "Decoration", false)
				end
			end)
		end

		if setfpscap then
			pcall(function() setfpscap(1e6) end)
		end

		local function CleanInstance(Inst)
			if not Inst or not Inst.Parent then return end
			pcall(function()
				if Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Material = Inst.Material,
							Reflectance = Inst.Reflectance
						}
					end
					Inst.Material = Enum.Material.Plastic
					Inst.Reflectance = 0
				elseif Inst:IsA("MeshPart") then
					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Material = Inst.Material,
							Reflectance = Inst.Reflectance,
							RenderFidelity = Inst.RenderFidelity
						}
					end
					Inst.RenderFidelity = Enum.RenderFidelity.Performance
					Inst.Reflectance = 0
					Inst.Material = Enum.Material.Plastic
				elseif Inst:IsA("PostEffect")
					or Inst:IsA("ParticleEmitter")
					or Inst:IsA("Trail")
					or Inst:IsA("Smoke")
					or Inst:IsA("Fire")
					or Inst:IsA("Sparkles") then

					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Enabled = Inst.Enabled
						}
					end

					Inst.Enabled = false
				end
			end)
		end

		for _, v in ipairs(game:GetDescendants()) do
			CleanInstance(v)
		end

		if FPSConn then
			FPSConn:Disconnect()
		end

		FPSConn = game.DescendantAdded:Connect(function(v)
			if FPSBoost then
				CleanInstance(v)
			end
		end)

	else
		if FPSConn then
			FPSConn:Disconnect()
			FPSConn = nil
		end

		pcall(function() Lighting.GlobalShadows = SavedGraphicsState.GlobalShadows end)
		pcall(function() Lighting.FogEnd = SavedGraphicsState.FogEnd end)
		pcall(function() Lighting.ShadowSoftness = SavedGraphicsState.ShadowSoftness end)

		pcall(function()
			settings().Rendering.QualityLevel = SavedGraphicsState.QualityLevel
			settings().Rendering.MeshPartDetailLevel = SavedGraphicsState.MeshPartDetailLevel
		end)

		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function()
				if SavedGraphicsState.WaterWaveSize then
					terrain.WaterWaveSize = SavedGraphicsState.WaterWaveSize
				end

				if SavedGraphicsState.WaterWaveSpeed then
					terrain.WaterWaveSpeed = SavedGraphicsState.WaterWaveSpeed
				end

				if SavedGraphicsState.WaterReflectance then
					terrain.WaterReflectance = SavedGraphicsState.WaterReflectance
				end

				if SavedGraphicsState.WaterTransparency then
					terrain.WaterTransparency = SavedGraphicsState.WaterTransparency
				end
			end)
		end

		if setfpscap then
			pcall(function() setfpscap(60) end)
		end

		for Inst, Props in pairs(SavedGraphicsState.OriginalProps) do
			if Inst and Inst.Parent then
				pcall(function()
					for prop, val in pairs(Props) do
						Inst[prop] = val
					end
				end)
			end
		end

		SavedGraphicsState.OriginalProps = {}
	end
end

-- Init Boost if loaded from config
if FPSBoost then
	task.spawn(function()
		task.wait(1)
		ApplyFPSBoost(true)
	end)
end


--==================================================
-- HIDE ALL EGGS FUNCTION (Collision Fixed)
--==================================================

local function ToggleHideEggs(state)
	local Plots = workspace:FindFirstChild("Plots")
	if not Plots then return end

	for _, plot in ipairs(Plots:GetChildren()) do
		local eggsFolder = plot:FindFirstChild("Eggs")
		if eggsFolder then
			for _, egg in ipairs(eggsFolder:GetChildren()) do
				if egg:IsA("Model") or egg:IsA("BasePart") then
					
					for _, child in ipairs(egg:GetDescendants()) do
						if child:IsA("BasePart") then
							if state then
								-- I-save ang original transparency at cancollide bago itago
								if not child:GetAttribute("OriginalTransparency") then
									child:SetAttribute("OriginalTransparency", child.Transparency)
								end
								if child:GetAttribute("OriginalCanCollide") == nil then
									child:SetAttribute("OriginalCanCollide", child.CanCollide)
								end
								
								child.Transparency = 1
								child.CanCollide = false
							else
								-- Ibalik sa dati nilang original values
								local origTrans = child:GetAttribute("OriginalTransparency") or 0
								local origCollide = child:GetAttribute("OriginalCanCollide")
								
								child.Transparency = origTrans
								if origCollide ~= nil then
									child.CanCollide = origCollide
								end
							end
						elseif child:IsA("Decal") or child:IsA("Texture") then
							child.Transparency = state and 1 or 0
						elseif child:IsA("BillboardGui") or child:IsA("SurfaceGui") or 
							   child:IsA("ParticleEmitter") or child:IsA("Beam") or 
							   child:IsA("Trail") or child:IsA("Fire") or 
							   child:IsA("Smoke") or child:IsA("Sparkles") or 
							   child:IsA("Light") or child:IsA("Highlight") or 
							   child:IsA("SelectionBox") then
							child.Enabled = not state
						end
					end

				end
			end
		end
	end
end

-- AUTO-HIDE UPON STARTUP (Para sa Saved Config)
task.spawn(function()
	task.wait(1.5)
	if (typeof(ConfigData) == "table" and ConfigData.HideEggs) or (HideEggs ~= nil and HideEggs) then
		ToggleHideEggs(true)
	end
end)

-- AUTO-HIDE KAPAG MAY BAGONG PLANTED / SPAWNED EGG
task.spawn(function()
	local PlotsFolder = workspace:WaitForChild("Plots", 10)
	if PlotsFolder then
		local function AttachEggListener(plot)
			local eggsFolder = plot:WaitForChild("Eggs", 5)
			if eggsFolder then
				eggsFolder.ChildAdded:Connect(function()
					if HideEggs then
						task.wait(0.2)
						ToggleHideEggs(true)
					end
				end)
			end
		end

		for _, plot in ipairs(PlotsFolder:GetChildren()) do
			AttachEggListener(plot)
		end

		PlotsFolder.ChildAdded:Connect(function(plot)
			AttachEggListener(plot)
		end)
	end
end)

--// EGG CONTAINER
local RenderedEggs = workspace:WaitForChild("RenderedEggs")

--// EGG LIST
local EggNames = {
	"Volcanic Egg",
	"Cherub Egg",
    "Solaris Egg",
	"Blackhole Egg",
    "Bloom Egg",
	"Galaxy Egg",	
	"Aurora Egg",
    "Tidal Egg",
	"Soul Egg",
	"Sinister Egg",
	"Flaming Egg",
	"Dominus Egg",
	"Asteroid Egg",
    "Skull Egg",
    "Crystal Egg",
	"Diamond Egg",
	"Golden Egg",
	"Glass Egg",
	"Ice Egg",
	"Slime Egg",
    "Flower Egg",
    "Mushroom Egg",
	"Leaf Egg",
	"Stone Egg",
    "Easter Egg",
	"Cracked Egg",
	"Brown Egg",
	"White Egg"
}

local RarityNames = {
	"Ethereal",
	"Divine",
	"Mythic",
	"Legendary",
	"Epic",
	"Rare",
	"Common"
}

--==================================================
-- SHOP STOCK SYSTEM
--==================================================

local ShopStockData = {}
local ShopStockReady = false

RestockRemote.OnClientEvent:Connect(function(stockData)
	if type(stockData) ~= "table" then return end
	ShopStockData = stockData
	ShopStockReady = true
end)

task.spawn(function()
	for i = 1, 10 do
		if ShopStockReady then break end
		pcall(function() ShopStockRemote:FireServer() end)
		task.wait(2)
	end
end)

local function GetShopStock(Category, ItemName)
	local CategoryData = ShopStockData[Category]
	if type(CategoryData) ~= "table" then return 0 end
	local ItemData = CategoryData[ItemName]
	if type(ItemData) ~= "table" then return 0 end
	return tonumber(ItemData.Amount) or 0
end

local function ReduceShopStock(Category, ItemName)
	local CategoryData = ShopStockData[Category]
	if type(CategoryData) ~= "table" then return end
	local ItemData = CategoryData[ItemName]
	if type(ItemData) ~= "table" then return end
	local Amount = tonumber(ItemData.Amount) or 0
	ItemData.Amount = math.max(0, Amount - 1)
end

local GearShop = {
	"Advanced Radar",
	"Jewel Radar",
	"Royal Radar",
	"Magic Radar",
	"Angelic Radar",
	"Eternal Radar"
}

local FoodShop = {
	"Grass",
	"Bone",
	"Meat",
	"Magic Apple",
	"Dragon Fruit"
}

local PET_LIST = {
    "Snail", "Turtle", "Sloth", "Axolotl", "Koala",
    "Capybara", "Chicken", "Pig", "Elephant", "Panda",
    "Kangaroo", "Deer", "Spider", "Crocodile", "Gorilla",
    "Snake", "Horse", "Wolf", "Shark", "Platypus",
    "Lion", "Ostrich", "Fox", "Boar", "Giraffe",
    "Cheetah", "Monkey", "Unicorn", "Flamingo", "TRex",
    "Phoenix", "Peacock", "Cerberus", "Komodo", "Kitsune",
    "Dragon", "Griffin"
}


local EggPriority = {}
for Index, Name in ipairs(EggNames) do
	EggPriority[Name] = Index
end

local RarityPriority = {}
for Index, Name in ipairs(RarityNames) do
	RarityPriority[Name] = Index
end

--==================================================
-- WINDOW
--==================================================

local Window = WindUI:CreateWindow({
	Title = "LUNA HUB",
	Author = "RIDE A PET",
	Theme = ThemeName,

	ToggleKey = Enum.KeyCode.F,
	OpenButton = {
		Enabled = true,
		OnlyMobile = false
	},
})

Window:Tag({
	Title = "v.1.0.0.8",
	Color = "ElementBackground",
})

--==================================================
-- TABS
--==================================================

local Tab1 = Window:Tab({ Title = "HOME", Icon = "warehouse" })
local Tab2 = Window:Tab({ Title = "FARM", Icon = "egg" })
local Tab3 = Window:Tab({ Title = "SHOP", Icon = "shopping-cart" })
local Tab4 = Window:Tab({ Title = "VISUAL", Icon = "eye" })
local Tab5 = Window:Tab({ Title = "Tracker", Icon = "radar" })
local Tab6 = Window:Tab({ Title = "CONFIG", Icon = "file-cog" })
local Tab7 = Window:Tab({ Title = "SETTINGS", Icon = "settings" })

--==================================================
-- TAB 1 (HOME)
--==================================================

    Tab1:Paragraph({
	Title = "Discord",
	Desc = "Join our Discord Community",

	Buttons = {
		{
			Title = "Discord",
			Callback = function()
				local DiscordLink = "discord.gg/vENCWk39f7"

				if setclipboard then
					setclipboard(DiscordLink)
				end

				WindUI:Notify({
					Title = "Discord Link",
					Content = "Discord link copied to clipboard!",
					Icon = "solar:copy-bold",
					Duration = 4,
					CanClose = true,
				})
			end,
		},
	},
})

    local HomeSection1 = Tab1:Section({
	Title = "Teleport",
	Icon = "compass",
	Box = true,
	BoxBorder = true,
})

HomeSection1:Button({
	Title = "TP TO MARKET",
	Justify = "Center",
	Icon = "",
	Callback = function()
		local char = LocalPlayer.Character
		if char then
			local marketCFrame = CFrame.new(148.190125, 40316.3672, 916.778992, 0.728601754, 4.76895323e-08, -0.684937537, -8.04378715e-08, 1, -1.59396176e-08, 0.684937537, 6.67085516e-08, 0.728601754)
			char:PivotTo(marketCFrame)
		end
	end,
})


HomeSection1:Button({
	Title = "TP TO VOLCANO ENTRANCE",
	Justify = "Center",
	Icon = "",
	Callback = function()
		local char = LocalPlayer.Character
		if char then
			local volcanoEntranceCFrame = CFrame.new(-4948.55371, 41320.418, -3669.84229, -0.576323509, 1.14716983e-07, 0.817221642, 4.89400023e-08, 1, -1.05860764e-07, -0.817221642, -2.1015218e-08, -0.576323509)
			char:PivotTo(volcanoEntranceCFrame)
		end
	end,
})

HomeSection1:Button({
	Title = "TP TO MY PLOT",
	Justify = "Center",
	Icon = "",
	Callback = function()
		TeleportToMyPlot()
	end,
})

--==================================================
-- TAB 2 (FARM)
--==================================================

local EggSection = Tab2:Section({
	Title = "Auto Farm",
	Icon = "egg",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedRarities = EggSection:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to auto farm",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedRarities = value
		ConfigData.SelectedRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedEggs = EggSection:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to auto farm",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedEggs = value
		ConfigData.SelectedEggs = value
		SaveConfig()
	end,
})

UIElements.AutoVolcanoDip = EggSection:Toggle({
	Title = "Auto Volcano Dip",
	Desc = "Dips picked up egg into Volcano Lava before bringing to plot",
	Value = ConfigData.AutoVolcanoDip,

	Callback = function(value)
		AutoVolcanoDip = value
		ConfigData.AutoVolcanoDip = value
		SaveConfig()
	end,
})

UIElements.AutoPickup = EggSection:Toggle({
	Title = "Auto Farm",
	Desc = "Automatically get the egg and proceed to your plot",
	Value = ConfigData.AutoPickup,

	Callback = function(value)
		AutoPickup = value
		ConfigData.AutoPickup = value
		SaveConfig()
	end,
})



local EggSection1 = Tab2:Section({
	Title = "Auto Place & Hatch",
	Icon = "sparkles",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedPlaceRarities = EggSection1:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to place in your plot",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedPlaceRarities,
	AllowNone = true,
	Callback = function(value)
		SelectedPlaceRarities = value
		ConfigData.SelectedPlaceRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedPlaceEgg = EggSection1:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to place in your plot",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedPlaceEgg,
    AllowNone = true,
	Callback = function(value)
		SelectedPlaceEgg = value
		ConfigData.SelectedPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.AutoPlaceEgg = EggSection1:Toggle({
	Title = "Auto Place Eggs",
	Desc = "Automatically place the selected eggs in your plot",
	Value = ConfigData.AutoPlaceEgg,

	Callback = function(value)
		AutoPlaceEgg = value
		ConfigData.AutoPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.AutoHatchEgg = EggSection1:Toggle({
	Title = "Auto Hatch Egg",
	Desc = "Automatically hatch ready eggs in your plot",
	Value = ConfigData.AutoHatchEgg,

	Callback = function(value)
		AutoHatchEgg = value
		ConfigData.AutoHatchEgg = value
		SaveConfig()
	end,
})

UIElements.AutoEquipBestPet = EggSection1:Toggle({
	Title = "Auto Equip Best Pet",
    Desc = "Automatically equip the best pet (go to your plot)",
	Value = ConfigData.AutoEquipBestPet,

	Callback = function(value)
		AutoEquipBestPet = value
		ConfigData.AutoEquipBestPet = value
		SaveConfig()
	end,
})


local EggSection2 = Tab2:Section({
	Title = "Upgrades",
	Icon = "trending-up",
	Box = true,
	BoxBorder = true,
})

UIElements.AutoUpgradeHatchLuck = EggSection2:Toggle({
	Title = "Auto Upgrade Hatch Luck",
	Desc = "Automatically upgrade hatch luck by 1x",
	Value = ConfigData.AutoUpgradeHatchLuck,

	Callback = function(value)
		AutoUpgradeHatchLuck = value
		ConfigData.AutoUpgradeHatchLuck = value
		SaveConfig()
	end,
})

UIElements.AutoUpgradeHatchLuckMax = EggSection2:Toggle({
	Title = "Auto Upgrade Hatch Luck (Max)",
	Desc = "Automatically upgrade hatch luck by max",
	Value = ConfigData.AutoUpgradeHatchLuckMax,

	Callback = function(value)
		AutoUpgradeHatchLuckMax = value
		ConfigData.AutoUpgradeHatchLuckMax = value
		SaveConfig()
	end,
})

UIElements.AutoRebirth = EggSection2:Toggle({
	Title = "Auto Rebirth",
	Value = ConfigData.AutoRebirth,

	Callback = function(value)
		AutoRebirth = value
		ConfigData.AutoRebirth = value
		SaveConfig()
	end,
})

UIElements.AutoClaimIndex = EggSection2:Toggle({
	Title = "Auto Claim Index Reward",
	Value = ConfigData.AutoClaimIndex,

	Callback = function(value)
		AutoClaimIndex = value
		ConfigData.AutoClaimIndex = value
		SaveConfig()
	end,
})

UIElements.AutoClaimOffline = EggSection2:Toggle({
	Title = "Auto Claim Offline Rewards",
	Value = ConfigData.AutoClaimOffline,

	Callback = function(value)
		AutoClaimOffline = value
		ConfigData.AutoClaimOffline = value
		SaveConfig()

		-- One-time execution pag na-toggle sa ON
		if value then
			task.spawn(function()
				pcall(function()
					local OfflineEarnings = ReplicatedStorage:FindFirstChild("Remotes") 
						and ReplicatedStorage.Remotes:FindFirstChild("Game") 
						and ReplicatedStorage.Remotes.Game:FindFirstChild("OfflineEarnings")

					if OfflineEarnings then
						-- 1. I-fire ang server para ma-claim ang reward
						OfflineEarnings:FireServer()
						task.wait(0.3)
						
						-- 2. Isara/Itago ang Pop-up UI sa screen
						local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
						if PlayerGui then
							for _, gui in ipairs(PlayerGui:GetChildren()) do
								if gui:IsA("ScreenGui") then
									local guiName = string.lower(gui.Name)
									if string.find(guiName, "offline") or string.find(guiName, "away") or string.find(guiName, "reward") then
										gui.Enabled = false
									end
									
									for _, desc in ipairs(gui:GetDescendants()) do
										if desc:IsA("TextLabel") or desc:IsA("TextButton") then
											local text = string.lower(desc.Text)
											if string.find(text, "while you're away") or string.find(text, "your pets made you") then
												local targetFrame = desc:FindFirstAncestorOfClass("Frame") or desc:FindFirstAncestorOfClass("ScreenGui")
												if targetFrame then
													if targetFrame:IsA("ScreenGui") then
														targetFrame.Enabled = false
													else
														targetFrame.Visible = false
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end)
		end
	end,
})

--==================================================
-- TAB 3 (SHOP)
--==================================================

local ShopSection = Tab3:Section({
	Title = "Gear Shop",
	Icon = "wrench",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedGear = ShopSection:Dropdown({
	Title = "Select Radars",
	Values = GearShop,
	Multi = true,
	Value = ConfigData.SelectedGear,
    AllowNone = true,

	Callback = function(value)
		SelectedGear = value
		ConfigData.SelectedGear = value
		SaveConfig()
	end,
})

UIElements.Autobuygear = ShopSection:Toggle({
	Title = "Auto Buy Gears",
	Desc = "Automatically buy selected gear",
	Value = ConfigData.Autobuygear,

	Callback = function(value)
		Autobuygear = value
		ConfigData.Autobuygear = value
		SaveConfig()
	end,
})

local ShopSection1 = Tab3:Section({
	Title = "Food Shop",
	Icon = "apple",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedFood = ShopSection1:Dropdown({
	Title = "Select Food",
	Values = FoodShop,
	Multi = true,
	Value = ConfigData.SelectedFood,
	AllowNone = true,

	Callback = function(value)
		SelectedFood = value
		ConfigData.SelectedFood = value
		SaveConfig()
	end,
})

UIElements.Autobuyfood = ShopSection1:Toggle({
	Title = "Auto Buy Foods",
	Desc = "Automatically buy selected food",
	Value = ConfigData.Autobuyfood,

	Callback = function(value)
		Autobuyfood = value
		ConfigData.Autobuyfood = value
		SaveConfig()
	end,
})

local ShopSection2 = Tab3:Section({
	Title = "Sell Shop",
	Icon = "dollar-sign",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedSellRarities = ShopSection2:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to auto sell",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedSellRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedSellRarities = value
		ConfigData.SelectedSellRarities = SelectedSellRarities
		SaveConfig()
	end,
})

UIElements.SelectedPetToSell = ShopSection2:Dropdown({
	Title = "Category Filter",
    Desc = "Choose category to auto sell",
	Values = PET_LIST,
	Multi = true,
	Value = ConfigData.SelectedPetToSell,
	AllowNone = true,

	Callback = function(value)
		SelectedPetToSell = value
		ConfigData.SelectedPetToSell = SelectedPetToSell
		SaveConfig()
	end,
})

UIElements.AutoSellPet = ShopSection2:Toggle({
	Title = "Auto Sell Pets",
	Desc = "Automatically sell selected pets",
	Value = ConfigData.AutoSellPet,

	Callback = function(value)
		AutoSellPet = value
		ConfigData.AutoSellPet = value
		SaveConfig()
	end,
})

UIElements.AutoSellAllPets = ShopSection2:Toggle({
	Title = "Auto Sell All Pets",
	Desc = "Automatically sell all pets in inventory",
	Value = ConfigData.AutoSellAllPets,

	Callback = function(value)
		AutoSellAllPets = value
		ConfigData.AutoSellAllPets = value
		SaveConfig()
	end,
})

local FavSection = Tab3:Section({
	Title = "Favorite Pet",
	Icon = "heart",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedFavPet = FavSection:Dropdown({
	Title = "Select Pet to Favorite",
	Desc = "Choose which pets to auto favorite",
	Values = PET_LIST,
	Multi = true,
	Value = ConfigData.SelectedFavPet,
	AllowNone = true,

	Callback = function(value)
		SelectedFavPet = value
		ConfigData.SelectedFavPet = value
		SaveConfig()
	end,
})

UIElements.AutoFavoritePet = FavSection:Toggle({
	Title = "Auto Favorite Pet",
	Desc = "Automatically favorites selected pets then stops when finished",
	Value = ConfigData.AutoFavoritePet,

	Callback = function(value)
		AutoFavoritePet = value
		ConfigData.AutoFavoritePet = value
		SaveConfig()
		if value then
			task.spawn(ProcessAutoFavorite)
		end
	end,
})

--==================================================
-- TAB 4 (VISUAL)
--==================================================

local VisualSection = Tab4:Section({
	Title = "ESP Settings",
	Icon = "eye",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedESPRarities = VisualSection:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to display ESP",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedESPRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedESPRarities = value
		ConfigData.SelectedESPRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedESPEggs = VisualSection:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to display ESP",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedESPEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedESPEggs = value
		ConfigData.SelectedESPEggs = value
		SaveConfig()
	end,
})

UIElements.ESPEnabled = VisualSection:Toggle({
	Title = "Egg ESP",
	Desc = "Enable esp and distance for selected eggs",
	Value = ConfigData.ESPEnabled,

	Callback = function(value)
		ESPEnabled = value
		ConfigData.ESPEnabled = value
		SaveConfig()
	end,
})

--==================================================
-- TAB 5 (TRACKER)
--==================================================

local EggsSection = Tab5:Section({
	Title = "Egg Tracker",
	Icon = "radar",
	Box = true,
	BoxBorder = true,
})

local LiveEggParagraph = EggsSection:Paragraph({
	Title = "Tracked Eggs (0)",
	Desc = "Scanning workspace for rendered eggs...",
})

local function UpdateRenderedEggList()
	local CountMap = {}
	local TotalCount = 0

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		CountMap[Name] = (CountMap[Name] or 0) + 1
		TotalCount = TotalCount + 1
	end

	if TotalCount == 0 then
		LiveEggParagraph:SetTitle("Tracked Eggs (0)")
		LiveEggParagraph:SetDesc("No eggs currently rendered on map.")
	else
		local SpawnedEggNames = {}
		for Name, _ in pairs(CountMap) do
			table.insert(SpawnedEggNames, Name)
		end

		table.sort(SpawnedEggNames, function(a, b)
			local priorityA = EggPriority[a] or 999
			local priorityB = EggPriority[b] or 999
			return priorityA < priorityB
		end)

		local DescriptionText = ""
		for _, Name in ipairs(SpawnedEggNames) do
			local Count = CountMap[Name]
			DescriptionText = DescriptionText .. string.format("• %s (x%d)\n", Name, Count)
		end

		LiveEggParagraph:SetTitle(string.format("Tracked Eggs (%d)", TotalCount))
		LiveEggParagraph:SetDesc(DescriptionText)
	end
end

RenderedEggs.ChildAdded:Connect(function() task.defer(UpdateRenderedEggList) end)
RenderedEggs.ChildRemoved:Connect(function() task.defer(UpdateRenderedEggList) end)

task.spawn(function()
	task.wait(1)
	UpdateRenderedEggList()
end)

--==================================================
-- TAB 6 (CONFIG)
--==================================================

local ConfigSection = Tab6:Section({
	Title = "Config",
	Icon = "file-cog",
	Box = true,
	BoxBorder = true,
})

ConfigSection:Button({
	Title = "Reset Config",
	Desc = "Reset all your saved configurations",

	Callback = function()
		isResetting = true

		if delfile and isfile and isfile(ConfigFile) then
			pcall(function() delfile(ConfigFile) end)
		end

		if FPSBoost then
			FPSBoost = false
			ApplyFPSBoost(false)
		end

		SelectedEggs = {}
		SelectedRarities = {}
		SelectedPlaceEgg = {}
		SelectedPlaceRarities = {}
        SelectedPetToSell = {}
        SelectedSellRarities = {}
		SelectedFavPet = {}
		AutoPickup = false
		AutoVolcanoDip = false
		AutoPlaceEgg = false
		AutoHatchEgg = false
		AutoUpgradeHatchLuck = false
		AutoUpgradeHatchLuckMax = false
		AutoRebirth = false
		AutoClaimIndex = false
		AutoClaimOffline = false
		SelectedGear = {}
		Autobuygear = false
		SelectedFood = {}
		Autobuyfood = false
		SelectedESPEggs = {}
		SelectedESPRarities = {}
		ESPEnabled = false
		FPSBoost = false
        AutoSellPet = false
        AutoSellAllPets = false
        AutoEquipBestPet = false
        HideEggs = false
		AutoFavoritePet = false

		ConfigData = {
			SelectedEggs = {},
			SelectedRarities = {},
			SelectedPlaceEgg = {},
			SelectedPlaceRarities = {},
			AutoPickup = false,
			AutoVolcanoDip = false,
			AutoPlaceEgg = false,
			AutoHatchEgg = false,
			AutoUpgradeHatchLuck = false,
			AutoUpgradeHatchLuckMax = false,
			AutoRebirth = false,
			AutoClaimIndex = false,
			AutoClaimOffline = false,
			SelectedGear = {},
			Autobuygear = false,
			SelectedFood = {},
            SelectedPetToSell = {},
            SelectedSellRarities = {},
			Autobuyfood = false,
			SelectedESPEggs = {},
			SelectedESPRarities = {},
			ESPEnabled = false,
            AutoEquipBestPet = false,
            AutoSellPet = false,
            AutoSellAllPets = false,
			FPSBoost = false,
			SelectedFavPet = {},
            HideEggs = false,
			AutoFavoritePet = false
		}

		SetUIValue(UIElements.SelectedRarities, {})
		SetUIValue(UIElements.SelectedEggs, {})
		SetUIValue(UIElements.AutoPickup, false)
		SetUIValue(UIElements.AutoVolcanoDip, false)
		SetUIValue(UIElements.SelectedPlaceEgg, {})
		SetUIValue(UIElements.SelectedPlaceRarities, {})
		SetUIValue(UIElements.AutoPlaceEgg, false)
		SetUIValue(UIElements.AutoHatchEgg, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuck, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuckMax, false)
		SetUIValue(UIElements.AutoRebirth, false)
		SetUIValue(UIElements.AutoClaimIndex, false)
		SetUIValue(UIElements.AutoClaimOffline, false)
		SetUIValue(UIElements.SelectedGear, {})
		SetUIValue(UIElements.Autobuygear, false)
		SetUIValue(UIElements.SelectedFood, {})
		SetUIValue(UIElements.SelectedPetToSell, {})
		SetUIValue(UIElements.SelectedSellRarities, {})
		SetUIValue(UIElements.Autobuyfood, false)
		SetUIValue(UIElements.SelectedESPEggs, {})
		SetUIValue(UIElements.SelectedESPRarities, {})
		SetUIValue(UIElements.ESPEnabled, false)
		SetUIValue(UIElements.FPSBoost, false)
        SetUIValue(UIElements.AutoSellPet, false)
        SetUIValue(UIElements.AutoSellAllPets, false)
        SetUIValue(UIElements.AutoEquipBestPet, false)
		SetUIValue(UIElements.SelectedFavPet, {})
		SetUIValue(UIElements.AutoFavoritePet, false)
        SetUIValue(UIElements.HideEggs, false)
        

		WindUI:Notify({
			Title = "Config Reset",
			Content = "All configurations have been reset to default!",
			Icon = "solar:bell-bold",
			Duration = 5,
			CanClose = true,
		})

		task.wait(0.1)
		isResetting = false
	end,
})

--==================================================
-- SERVER FUNCTIONS
--==================================================

local function RejoinServer()
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end)
end

local function ServerHop()
	task.spawn(function()
		local success, result = pcall(function()
			local CurrentJobId = game.JobId
			local Cursor = ""
			local Candidates = {}

			for _ = 1, 5 do
				local Url = string.format(
					"https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s",
					tostring(game.PlaceId),
					Cursor ~= "" and "&cursor=" .. HttpService:UrlEncode(Cursor) or ""
				)

				local Body = game:HttpGet(Url)
				local Data = HttpService:JSONDecode(Body)

				if Data and Data.data then
					for _, Server in ipairs(Data.data) do
						if Server.id and Server.id ~= CurrentJobId and Server.playing and Server.maxPlayers and Server.playing < Server.maxPlayers then
							table.insert(Candidates, Server)
						end
					end
				end

				Cursor = (Data and Data.nextPageCursor) or ""
				if Cursor == "" then break end
			end

			table.sort(Candidates, function(a, b) return a.playing < b.playing end)
			return Candidates[1]
		end)

		if success and result and result.id then
			WindUI:Notify({
				Title = "Server Hop",
				Content = string.format("Hopping to a server with %d player(s)...", result.playing),
				Icon = "solar:server-bold",
				Duration = 3,
				CanClose = true,
			})
			task.wait(0.5)
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, result.id, Player)
			end)
		else
			WindUI:Notify({
				Title = "Server Hop",
				Content = "Server hop failed try again.",
				Icon = "solar:bell-bold",
				Duration = 4,
				CanClose = true,
			})
		end
	end)
end

--==================================================
-- TAB 7 (SETTINGS)
--==================================================

local SettingsSection = Tab7:Section({
	Title = "Performance",
	Icon = "zap",
	Box = true,
	BoxBorder = true,
})

UIElements.FPSBoost = SettingsSection:Toggle({
	Title = "FPS Boost",
	Desc = "Lower graphics quality to increase FPS performance",
	Value = ConfigData.FPSBoost,

	Callback = function(value)
		FPSBoost = value
		ConfigData.FPSBoost = value
		SaveConfig()
		ApplyFPSBoost(value)
	end,
})

UIElements.HideEggs = SettingsSection:Toggle({
	Title = "Hide All Eggs",
	Desc = "Hide all eggs in your plot and other players' plots",
	Value = ConfigData.HideEggs,

	Callback = function(value)
		HideEggs = value
		ConfigData.HideEggs = value
		SaveConfig()
		ToggleHideEggs(value)
	end,
})


local SettingsSection1 = Tab7:Section({
	Title = "Servers",
	Icon = "globe",
	Box = true,
	BoxBorder = true,
})
SettingsSection1:Button({
	Title = "Rejoin",
	Justify = "Center",
	Icon = "",
	Callback = function() RejoinServer() end,
})

SettingsSection1:Button({
	Title = "Server Hop",
	Justify = "Center",
	Icon = "",
	Callback = function() ServerHop() end,
})

--==================================================
-- ADDITIONAL HELPER FUNCTIONS
--==================================================

local function GetEggPart(Egg)
	if not Egg then return nil end
	if Egg:IsA("BasePart") then return Egg end

	if Egg:IsA("Model") then
		if Egg.PrimaryPart then return Egg.PrimaryPart end

		local Pickup = Egg:FindFirstChild("Pickup", true)
		if Pickup and Pickup:IsA("ProximityPrompt") and Pickup.Parent:IsA("BasePart") then
			return Pickup.Parent
		end

		return Egg:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function FindSelectedEgg()
	local BestEgg = nil
	local HighestRarityPriority = math.huge
	local HighestEggPriority = math.huge

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		local eggData = Eggs_mData[Name]
		local Rarity = eggData and eggData.Rarity or "Common"

		local IsNameSelected = false
		local IsRaritySelected = false

		-- Check if Name selected
		if type(SelectedEggs) == "table" then
			for _, SelectedName in ipairs(SelectedEggs) do
				if SelectedName == Name then
					IsNameSelected = true
					break
				end
			end
		elseif SelectedEggs == Name then
			IsNameSelected = true
		end

		-- Check if Rarity selected
		if type(SelectedRarities) == "table" then
			for _, SelectedRarity in ipairs(SelectedRarities) do
				if SelectedRarity == Rarity then
					IsRaritySelected = true
					break
				end
			end
		elseif SelectedRarities == Rarity then
			IsRaritySelected = true
		end

		-- Priority Calculations:
		-- Priority 1: Selected Rarity
		-- Priority 2: Selected Egg Name
		if IsRaritySelected or IsNameSelected then
			local currentRarityPrio = IsRaritySelected and (RarityPriority[Rarity] or 99) or 999
			local currentEggPrio = IsNameSelected and (EggPriority[Name] or 999) or 9999

			if currentRarityPrio < HighestRarityPriority then
				HighestRarityPriority = currentRarityPrio
				HighestEggPriority = currentEggPrio
				BestEgg = Egg
			elseif currentRarityPrio == HighestRarityPriority then
				if currentEggPrio < HighestEggPriority then
					HighestEggPriority = currentEggPrio
					BestEgg = Egg
				end
			end
		end
	end

	return BestEgg
end

local function PickupEgg(Egg)
	if not Egg then return false end

	pcall(function()
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local GameRemotes = Remotes and Remotes:FindFirstChild("Game")

		if GameRemotes then
			local PickupRemote = GameRemotes:FindFirstChild("PickupEgg")
				or GameRemotes:FindFirstChild("ClaimEgg")
				or GameRemotes:FindFirstChild("CollectEgg")

			if PickupRemote then
				PickupRemote:FireServer(Egg)
			end
		end
	end)

	for _, Descendant in ipairs(Egg:GetDescendants()) do
		if Descendant:IsA("ProximityPrompt") then
			if typeof(fireproximityprompt) == "function" then
				pcall(function() fireproximityprompt(Descendant) end)
			end

			pcall(function()
				Descendant:InputHoldBegin()
				task.wait(0.05)
				Descendant:InputHoldEnd()
			end)
		end
	end

	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
	local EggPart = GetEggPart(Egg)

	if HRP and EggPart then
		pcall(function()
			firetouchinterest(HRP, EggPart, 0)
			task.wait(0.05)
			firetouchinterest(HRP, EggPart, 1)
		end)
	end

	return true
end

local function TeleportToEgg(Egg)
	local Character = GetCharacter()
	if not Character then return false end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local EggPart = GetEggPart(Egg)

	if not HRP or not EggPart then return false end

	HRP.CFrame = EggPart.CFrame * CFrame.new(0, 1.5, 0)
	return true
end

local function WaitForEggPickup(Egg, Timeout)
	Timeout = Timeout or 5
	local StartTime = os.clock()

	while Egg and Egg.Parent == RenderedEggs do
		if (os.clock() - StartTime) >= Timeout then break end
		task.wait(0.1)
	end
end

-- Helper Tween Function
local function TweenToCFrame(targetCFrame, speedOrTime)
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local distance = (hrp.Position - targetCFrame.Position).Magnitude
	local duration = typeof(speedOrTime) == "number" and speedOrTime or (distance / 60)
	if duration <= 0 then duration = 0.1 end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
	tween.Completed:Wait()
end

--==================================================
-- ESP SYSTEM WITH RARITY COLORS
--==================================================

local ActiveESP = {}

-- Function para makuha ang color batay sa rarity
local function GetEggColor(eggName)
	local eggData = Eggs_mData[eggName]
	local rarity = eggData and eggData.Rarity or "Common"

	if rarity == "Common" then
		return Color3.fromRGB(255, 255, 255) -- White
	elseif rarity == "Rare" then
		return Color3.fromRGB(85, 170, 255) -- Blue
	elseif rarity == "Epic" then
		return Color3.fromRGB(170, 85, 255) -- Purple
	elseif rarity == "Legendary" then
		return Color3.fromRGB(255, 215, 0) -- Gold / Yellow
	elseif rarity == "Mythic" then
		return Color3.fromRGB(255, 50, 50) -- Red
	elseif rarity == "Divine" then
		return Color3.fromRGB(255, 255, 153) -- Light Yellow
	elseif rarity == "Ethereal" or rarity == "Eternal" then
		return Color3.fromRGB(255, 0, 127) -- Neon Pink/Eternal
	end

	return Color3.fromRGB(255, 255, 255) -- Default White
end

local function RemoveESP(Egg)
	if ActiveESP[Egg] then
		if ActiveESP[Egg].Billboard then
			ActiveESP[Egg].Billboard:Destroy()
		end
		ActiveESP[Egg] = nil
	end
end

local function ClearAllESP()
	for Egg, _ in pairs(ActiveESP) do
		RemoveESP(Egg)
	end
end

local function CreateESP(Egg)
	if ActiveESP[Egg] then return end

	local EggPart = GetEggPart(Egg)
	if not EggPart then return end

	local textColor = GetEggColor(Egg.Name)

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "LunaEggESP"
	Billboard.Adornee = EggPart
	Billboard.Size = UDim2.new(0, 200, 0, 50)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Parent = EggPart

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextColor3 = textColor
	TextLabel.TextStrokeTransparency = 0
	TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.TextSize = 16
	TextLabel.Text = Egg.Name .. "\n[0m]"
	TextLabel.Parent = Billboard

	ActiveESP[Egg] = {
		Billboard = Billboard,
		TextLabel = TextLabel,
		Part = EggPart
	}
end

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		ClearAllESP()
		return
	end

	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	for Egg, _ in pairs(ActiveESP) do
		if not Egg or not Egg.Parent or Egg.Parent ~= RenderedEggs then
			RemoveESP(Egg)
		end
	end

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		local eggData = Eggs_mData[Name]
		local Rarity = eggData and eggData.Rarity or "Common"

		local IsNameSelected = false
		local IsRaritySelected = false

		if type(SelectedESPEggs) == "table" then
			for _, SelectedName in ipairs(SelectedESPEggs) do
				if SelectedName == Name then
					IsNameSelected = true
					break
				end
			end
		elseif SelectedESPEggs == Name then
			IsNameSelected = true
		end

		if type(SelectedESPRarities) == "table" then
			for _, SelectedRarity in ipairs(SelectedESPRarities) do
				if SelectedRarity == Rarity then
					IsRaritySelected = true
					break
				end
			end
		elseif SelectedESPRarities == Rarity then
			IsRaritySelected = true
		end

		if IsNameSelected or IsRaritySelected then
			if not ActiveESP[Egg] then
				CreateESP(Egg)
			end

			if ActiveESP[Egg] and HRP and ActiveESP[Egg].Part then
				local Dist = math.floor((HRP.Position - ActiveESP[Egg].Part.Position).Magnitude)
				ActiveESP[Egg].TextLabel.Text = string.format("%s\n[%dm]", Name, Dist)
			end
		else
			RemoveESP(Egg)
		end
	end
end)

-- Auto-hide kapag may bagong itinanim na egg sa kahit anong plot
local PlotsFolder = workspace:WaitForChild("Plots", 5)
if PlotsFolder then
	for _, plot in ipairs(PlotsFolder:GetChildren()) do
		local eggsFolder = plot:FindFirstChild("Eggs")
		if eggsFolder then
			eggsFolder.ChildAdded:Connect(function(child)
				if HideEggs then
					task.wait(0.1) -- Maghintay nang kaunti para ma-render ang buong model
					ToggleHideEggs(true)
				end
			end)
		end
	end
end

--==================================================
-- AUTOMATION LOOPS
--==================================================

--AUTO FAVORITE PET 
function ProcessAutoFavorite()
	-- Gagawin ang loop habang NAKA-ON ang toggle
	while AutoFavoritePet do
		local favList = type(SelectedFavPet) == "table" and SelectedFavPet or (SelectedFavPet ~= "" and {SelectedFavPet} or {})
		
		if #favList > 0 then
			local favMap = {}
			for _, name in ipairs(favList) do
				favMap[string.lower(name)] = true
			end

			local function IsPetFavorited(inst)
				if inst:GetAttribute("IsFavorite") == true or inst:GetAttribute("Favorite") == true or inst:GetAttribute("Favorited") == true then
					return true
				end
				local favVal = inst:FindFirstChild("Favorite") or inst:FindFirstChild("IsFavorite")
				if favVal and (favVal:IsA("BoolValue") and favVal.Value == true) then
					return true
				end
				return false
			end

			local function GetTargetPets()
				local targets = {}

				local petsFolder = SavedData:FindFirstChild("Pets") or SavedData:FindFirstChild("OwnedPets")
				if petsFolder then
					for _, petObj in ipairs(petsFolder:GetChildren()) do
						local rawName = petObj:GetAttribute("PetName") or petObj.Name
						local petName = string.match(rawName, "^(.-) %[") or rawName

						if favMap[string.lower(petName)] and not IsPetFavorited(petObj) then
							table.insert(targets, { Instance = petObj, Key = petObj:GetAttribute("PetKey") or petObj.Name })
						end
					end
				end

				local containers = {LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character}
				for _, container in ipairs(containers) do
					if container then
						for _, child in ipairs(container:GetChildren()) do
							if child:IsA("Tool") then
								local rawName = child:GetAttribute("PetName") or child.Name
								local petName = string.match(rawName, "^(.-) %[") or rawName

								if favMap[string.lower(petName)] and not IsPetFavorited(child) then
									local key = child:GetAttribute("PetKey") or child.Name
									table.insert(targets, { Instance = child, Key = key })
								end
							end
						end
					end
				end

				return targets
			end

			local targets = GetTargetPets()

			if #targets > 0 then
				for _, item in ipairs(targets) do
					if not AutoFavoritePet then break end

					pcall(function()
						if FavoritePetRemote then
							if item.Key then
								FavoritePetRemote:FireServer(item.Key)
							else
								FavoritePetRemote:FireServer(item.Instance)
							end
						end
					end)

					task.wait(0.3) 
				end
			end
		end

		task.wait(10)
	end
end





-- AUTO BUY GEAR LOOP
task.spawn(function()
	while true do
		if Autobuygear and ShopStockReady then
			pcall(function()
				if type(SelectedGear) == "table" then
					for _, GearItem in ipairs(SelectedGear) do
						if not Autobuygear then break end
						local Stock = GetShopStock("Gears", GearItem)
						if Stock > 0 then
							BuyWithCash:FireServer("Gears", GearItem)
							ReduceShopStock("Gears", GearItem)
							task.wait(0.2)
						end
					end
				elseif type(SelectedGear) == "string" and SelectedGear ~= "" then
					local Stock = GetShopStock("Gears", SelectedGear)
					if Stock > 0 then
						BuyWithCash:FireServer("Gears", SelectedGear)
						ReduceShopStock("Gears", SelectedGear)
					end
				end
			end)
		end
		task.wait(0.5)
	end
end)






-- AUTO BUY FOOD LOOP
task.spawn(function()
	while true do
		if Autobuyfood and ShopStockReady then
			pcall(function()
				if type(SelectedFood) == "table" then
					for _, FoodItem in ipairs(SelectedFood) do
						if not Autobuyfood then break end
						local Stock = GetShopStock("Food", FoodItem)
						if Stock > 0 then
							BuyWithCash:FireServer("Food", FoodItem)
							ReduceShopStock("Food", FoodItem)
							task.wait(0.2)
						end
					end
				elseif type(SelectedFood) == "string" and SelectedFood ~= "" then
					local Stock = GetShopStock("Food", SelectedFood)
					if Stock > 0 then
						BuyWithCash:FireServer("Food", SelectedFood)
						ReduceShopStock("Food", SelectedFood)
					end
				end
			end)
		end
		task.wait(0.5)
	end
end)





--==================================================
-- AUTO SELL PET LOOP (FIXED TELEPORT)
--==================================================

-- Helper function para i-equip ang pet nang maayos
local function EquipTargetPetForSell(petTool)
    if not petTool or not petTool:IsA("Tool") then return false end

    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not humanoid or not backpack then return false end

    -- Kung hawak na, okay na
    if petTool.Parent == character then
        return true
    end

    -- Kung nasa backpack, i-equip
    if petTool.Parent == backpack then
        humanoid:EquipTool(petTool)
        
        -- Maghintay sandali hanggang ma-equip (timeout pagkatapos ng 1 segundo)
        local startTime = os.clock()
        while petTool.Parent ~= character and (os.clock() - startTime) < 1 do
            task.wait(0.05)
        end
        
        return petTool.Parent == character
    end

    return false
end

-- Function para kunin ang mga pets na ibebenta (Pets lang, no Eggs)
local function GetTargetPetsToSell()
    local targetTools = {}
    local containers = {LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character}

    -- Siguraduhing tables ang mga napili
    local targetPets = type(SelectedPetToSell) == "table" and SelectedPetToSell or {}
    local targetRarities = type(SelectedSellRarities) == "table" and SelectedSellRarities or {}

    -- Gumawa ng set para sa mas mabilis na pag-check
    local petSet = {}
    for _, name in ipairs(targetPets) do petSet[string.lower(name)] = true end
    
    local raritySet = {}
    for _, rarity in ipairs(targetRarities) do raritySet[string.lower(rarity)] = true end

    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") then
                    -- Kunin ang malinis na pangalan (walang [Level])
                    local rawName = child:GetAttribute("PetName") or child.Name
                    local petName = string.match(rawName, "^(.-) %[") or rawName
                    
                    ---------------------------------------------------------
                    -- FILTER: Check kung valid na Pet ito (gamit ang Pets_m)
                    ---------------------------------------------------------
                    local petConfig = Pets_m[petName]
                    
                    if not petConfig then
                        continue -- Kung wala sa Pets_m, HINDI ito pet (malamang egg), kaya skip.
                    end
                    ---------------------------------------------------------

                    -- Safety: Huwag ibenta kung favorite
                    if child:GetAttribute("IsFavorite") == true then continue end

                    local petRarity = petConfig.Rarity or child:GetAttribute("Rarity") or "Common"

                    -- Check Category Filter
                    local isPetSelected = petSet[string.lower(petName)] or false

                    -- Check Rarity Filter
                    local isRaritySelected = raritySet[string.lower(petRarity)] or false

                    -- Isasama lang kung valid pet AT (tumugma sa category OR rarity filter)
                    if isPetSelected or isRaritySelected then
                        table.insert(targetTools, child)
                    end
                end
            end
        end
    end

    return targetTools
end

-- Main function para sa pag-teleport at pagbenta
local function ForceTeleportAndSellPets()
    -- 1. Kunin muna ang listahan ng ibebenta
    local targetTools = GetTargetPetsToSell()
    if #targetTools == 0 then return end

    -- 2. Safety check para sa NPC at Character
    if not RichieNPC or not RichieNPC.Parent then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 3. Loop sa bawat pet na ibebenta
    for _, petTool in ipairs(targetTools) do
        -- Check kung naka-on pa ang toggle
        if not AutoSellPet then break end
        
        -- Double check kung valid pet pa rin (baka nawala habang nasa loop)
        if not petTool or not petTool.Parent then continue end
        local rawName = petTool:GetAttribute("PetName") or petTool.Name
        local petName = string.match(rawName, "^(.-) %[") or rawName
        if not Pets_m[petName] then continue end

        -- 4. I-equip ang pet
        local equipped = EquipTargetPetForSell(petTool)
        
        -- 5. Kung na-equip, mag-teleport at ibenta
        if equipped then
            -- Refresh HRP reference
            hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- TELEPORT LOGIC (Pinatibay)
            pcall(function()
                local targetCFrame = RichieNPC:IsA("Model") and RichieNPC:GetPivot() or RichieNPC.CFrame
                -- Mag-tp sa harap ni Richie
                hrp.CFrame = targetCFrame * CFrame.new(0, 0, -4) 
            end)
            
            -- Maghintay ng kaunti para makarating ang server
            task.wait(0.3)

            -- INTERACT LOGIC
            local prompt = RichieNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and typeof(fireproximityprompt) == "function" then
                fireproximityprompt(prompt)
                task.wait(0.4) -- Hintayin bumukas ang dialogue
            end

            -- SELL LOGIC
            if DialogueSelect then
                DialogueSelect:FireServer(RichieNPC, "I would like to sell this")
                task.wait(0.3) -- Hintayin ang request ID
            end

            -- CONFIRM LOGIC
            if latestRequestId and ConfirmRequest then
                ConfirmRequest:FireServer(latestRequestId, true, "Yes")
                -- Linisin ang request ID para sa susunod
                latestRequestId = nil 
            end
            
            -- Delay bawat benta para sa stability
            task.wait(0.4) 
        end
    end
end

-- Main Loop Thread
task.spawn(function()
    while true do
        if AutoSellPet then
            -- Gumamit ng pcall para hindi mag-crash ang buong script kung may error sa isang cycle
            pcall(function()
                ForceTeleportAndSellPets()
            end)
            -- Maghintay bago ang susunod na scan cycle
            task.wait(2) 
        else
            task.wait(0.5)
        end
    end
end)





-- Safe Auto Sell All Pets Function
local function ForceTeleportAndSellAllPets()
    -- Safety Check kung existing ang NPC at Character
    if not RichieNPC or not RichieNPC.Parent then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 1. Teleport sa harap ni Richie
    local success, err = pcall(function()
        local targetCFrame = RichieNPC:IsA("Model") and RichieNPC:GetPivot() or RichieNPC.CFrame
        hrp.CFrame = targetCFrame * CFrame.new(0, 0, -3.5)
    end)
    if not success then return end

    task.wait(0.5)

    -- 2. Open Dialogue
    local prompt = RichieNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    end

    task.wait(0.6)

    -- 3. Select Option: "I would like to sell my pets"
    if DialogueSelect then
        DialogueSelect:FireServer(RichieNPC, "I would like to sell my pets")
        
        task.wait(0.6)

        -- 4. Select "Yes" sa confirmation
        DialogueSelect:FireServer(RichieNPC, "Yes")
    end

    task.wait(0.5)

    -- 5. Confirm Request Remote (kung may Request ID)
    if latestRequestId and ConfirmRequest then
        ConfirmRequest:FireServer(latestRequestId, true, "Yes")
        latestRequestId = nil
    end
end

-- Main Auto-Sell All Loop Thread
task.spawn(function()
    while true do
        if AutoSellAllPets then
            pcall(function()
                ForceTeleportAndSellAllPets()
            end)
            task.wait(5) 
        else
            task.wait(0.5)
        end
    end
end)





--==================================================
-- AUTO PLACE EGG LOOP (FIXED)
--==================================================
local MAX_PLANTED_EGGS = 10

local function GetRandomPlotPosition(Baseplate)
    if not Baseplate or not Baseplate:IsA("BasePart") then return nil end

    local Size = Baseplate.Size
    local Position = Baseplate.Position

    local MarginX = math.min(3, Size.X / 4)
    local MarginZ = math.min(3, Size.Z / 4)

    local MinX = Position.X - (Size.X / 2) + MarginX
    local MaxX = Position.X + (Size.X / 2) - MarginX

    local MinZ = Position.Z - (Size.Z / 2) + MarginZ
    local MaxZ = Position.Z + (Size.Z / 2) - MarginZ

    local RandomX = MinX + math.random() * (MaxX - MinX)
    local RandomZ = MinZ + math.random() * (MaxZ - MinZ)

    local Y = Position.Y + (Size.Y / 2) + 1.5

    return Vector3.new(RandomX, Y, RandomZ)
end

local function GetTargetEggsToPlace()
    local targetEggTools = {}
    local containers = {Player:FindFirstChild("Backpack"), LocalPlayer.Character}

    local targetEggNames = type(SelectedPlaceEgg) == "table" and SelectedPlaceEgg or (SelectedPlaceEgg ~= "" and {SelectedPlaceEgg} or {})
    local targetRarities = type(SelectedPlaceRarities) == "table" and SelectedPlaceRarities or (SelectedPlaceRarities ~= "" and {SelectedPlaceRarities} or {})

    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") then
                    local eggName = child.Name
                    local eggData = Eggs_mData[eggName]
                    
                    ---------------------------------------------------------
                    -- FIX: Check kung valid na Egg ito bago magpatuloy
                    ---------------------------------------------------------
                    if not eggData then 
                        continue -- Kung wala sa Eggs_mData, hindi ito egg (malamang pet), kaya skip.
                    end
                    ---------------------------------------------------------

                    local eggRarity = eggData and eggData.Rarity or "Common"

                    local isNameSelected = false
                    for _, name in ipairs(targetEggNames) do
                        if name == eggName then
                            isNameSelected = true
                            break
                        end
                    end

                    local isRaritySelected = false
                    for _, rarity in ipairs(targetRarities) do
                        if rarity == eggRarity then
                            isRaritySelected = true
                            break
                        end
                    end

                    -- Isasama lang kung valid egg AT tumugma sa filter
                    if isNameSelected or isRaritySelected then
                        table.insert(targetEggTools, child)
                    end
                end
            end
        end
    end

    return targetEggTools
end

task.spawn(function()
    while true do
        if AutoPlaceEgg then
            pcall(function()
                local TargetTools = GetTargetEggsToPlace()
                if #TargetTools == 0 then return end

                local Character = GetCharacter()
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

                if not Character or not Humanoid then return end

                local Plots = workspace:FindFirstChild("Plots")
                local MyPlot = nil

                if Plots then
                    for _, Plot in ipairs(Plots:GetChildren()) do
                        local NestsOwnerLoaded = Plot:GetAttribute("NestsOwnerLoaded")
                        if NestsOwnerLoaded == Player.UserId then
                            MyPlot = Plot
                            break
                        end

                        local Owner = Plot:GetAttribute("Owner")
                        local OwnerUserId = Plot:GetAttribute("OwnerUserId")
                        local UserId = Plot:GetAttribute("UserId")

                        if Owner == Player.Name or Owner == Player.UserId or OwnerUserId == Player.UserId or UserId == Player.UserId then
                            MyPlot = Plot
                            break
                        end
                    end
                end

                if not MyPlot then return end

                local EggsFolder = MyPlot:FindFirstChild("Eggs")
                local EggCount = EggsFolder and #EggsFolder:GetChildren() or 0

                if EggCount >= MAX_PLANTED_EGGS then return end

                local Baseplate = MyPlot:FindFirstChild("Baseplate")
                if not Baseplate or not Baseplate:IsA("BasePart") then return end

                local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
                local EggPlacedRemote = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")

                if not EggPlacedRemote then return end

                for _, EggTool in ipairs(TargetTools) do
                    -- Double check bago mag-equip para sa performance
                    if not AutoPlaceEgg then break end
                    
                    EggsFolder = MyPlot:FindFirstChild("Eggs")
                    EggCount = EggsFolder and #EggsFolder:GetChildren() or 0

                    if EggCount >= MAX_PLANTED_EGGS then break end

                    -- Siguraduhing egg pa rin ang hawak (baka na-sell o nawala habang naghihintay)
                    if not EggTool or not EggTool.Parent or not Eggs_mData[EggTool.Name] then continue end

                    if EggTool.Parent ~= Character then
                        Humanoid:EquipTool(EggTool)
                        task.wait(0.15) -- Bahagyang taas ng wait para sa stability
                    end

                    if EggTool.Parent == Character then
                        local PlantPosition = GetRandomPlotPosition(Baseplate)
                        if PlantPosition then
                            EggPlacedRemote:FireServer({ PlantPosition = PlantPosition })
                            task.wait(0.35)
                        end
                    end
                end
            end)
            task.wait(0.3)
        else
            task.wait(0.5)
        end
    end
end)




-- AUTO HATCH EGG LOOP
local function IsEggReadyToHatch(eggModel)
    local eggConfig = Eggs_mData[eggModel.Name]
    local eggData = eggModel:FindFirstChild("EggData")
    local placeTimeObj = eggData and eggData:FindFirstChild("PlaceTime")

    if not eggConfig or not placeTimeObj or placeTimeObj.Value <= 0 then
        return false
    end

    local weightObj = eggData:FindFirstChild("Weight")
    local weightVal = weightObj and tonumber(weightObj.Value) or 1
    local totalGrowthTime = General_mData.GrowthTimeFor(eggConfig.GrowthTime, weightVal)
    
    local elapsedTime = eggModel:GetAttribute("FlatGrow") == true 
        and (workspace:GetServerTimeNow() - placeTimeObj.Value) 
        or DayNight_mData.GrowthElapsed(placeTimeObj.Value)

    local timeLeft = totalGrowthTime - elapsedTime
    return timeLeft <= 0
end

task.spawn(function()
    while true do
        if AutoHatchEgg then
            pcall(function()
                local HatchRemote = ReplicatedStorage:FindFirstChild("Remotes")
                    and ReplicatedStorage.Remotes:FindFirstChild("Game")
                    and ReplicatedStorage.Remotes.Game:FindFirstChild("Hatch")

                if HatchRemote then
                    local myPlot = General_m_Hatch:GetPlot(Player)
                    local eggsFolder = myPlot and myPlot:FindFirstChild("Eggs")

                    if eggsFolder then
                        for _, eggModel in ipairs(eggsFolder:GetChildren()) do
                            local eggKey = eggModel:GetAttribute("EggKey") 
                                or (eggModel:FindFirstChild("EggKey") and eggModel.EggKey.Value)

                            if eggKey and IsEggReadyToHatch(eggModel) then
                                HatchRemote:FireServer({ EggKey = tostring(eggKey) })
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)






-- AUTO PLACE BEST PETS
local function GetMaxPetCapacity()
	local currentRebirths = Rebirths and Rebirths.Value or 0
	local attrMax = LocalPlayer:GetAttribute("MaxPets")
	local calculatedCapacity = 5 + math.floor(currentRebirths)

	if attrMax and attrMax > 0 then
		return math.max(attrMax, calculatedCapacity)
	end

	return calculatedCapacity
end

local function CalculatePetIncome(petTool)
	local petName = string.match(petTool.Name, "^(.-) %[") or petTool:GetAttribute("PetName") or petTool.Name
	local petConfig = Pets_m[petName]
	local baseIncome = petConfig and tonumber(petConfig.Income) or 0

	if baseIncome <= 0 then return 0 end

	local weight = tonumber(petTool:GetAttribute("Weight")) or 1
	local mutation = petTool:GetAttribute("Mutation")
	local spawnMutation = petTool:GetAttribute("SpawnMutation")

	local combinedFactor = Mutations_m.CombinedFactor and Mutations_m.CombinedFactor(mutation, spawnMutation) or 1
	local weightStandard = PetAging_m.WeightStandardKG or 1

	return math.floor(math.floor(baseIncome * (weight / weightStandard)) * combinedFactor)
end

local function GetAllPetsSorted()
	local petsList = {}

	for _, petData in pairs(PetRenderer_m.GetAll()) do
		if petData.OwnerUserId == LocalPlayer.UserId and petData.Model and petData.Model.Parent then
			table.insert(petsList, {
				Key = petData.PetKey,
				Income = tonumber(petData.DisplayIncome) or tonumber(petData.Income) or 0,
				Placed = true,
				Position = petData.Model:GetPivot().Position
			})
		end
	end

	local containers = {LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}
	for _, container in ipairs(containers) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("PetKey") then
					table.insert(petsList, {
						Key = child:GetAttribute("PetKey"),
						Income = CalculatePetIncome(child),
						Placed = false,
						Tool = child
					})
				end
			end
		end
	end

	table.sort(petsList, function(a, b)
		return a.Income > b.Income
	end)

	return petsList
end

local function GetPlotPlacementPos(rootPart, index)
	local targetPos = (rootPart.CFrame * CFrame.new(((index - 1) % 3 - 1) * 4, 0, -(math.floor((index - 1) / 3) * 4 + 8))).Position
	local myPlot = General_m:GetPlot(LocalPlayer)
	local baseplate = myPlot and myPlot:FindFirstChild("Baseplate")

	if not baseplate then return targetPos end

	local objSpace = baseplate.CFrame:PointToObjectSpace(targetPos)
	local sizeX = baseplate.Size.X / 2 - 2
	local sizeZ = baseplate.Size.Z / 2 - 2
	local clampedX = math.clamp(objSpace.X, -sizeX, sizeX)
	local clampedZ = math.clamp(objSpace.Z, -sizeZ, sizeZ)

	return baseplate.CFrame:PointToWorldSpace(Vector3.new(clampedX, objSpace.Y, clampedZ))
end

local function PlaceBestPets()
	if AutoSellPet or AutoSellAllPets then return end

	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local allPets = GetAllPetsSorted()
	if #allPets == 0 then return end

	local maxCapacity = GetMaxPetCapacity()
	local targetPetsCount = math.min(maxCapacity, #allPets)

	local bestPetsToPlace = {}
	local bestKeysMap = {}

	for i = 1, targetPetsCount do
		bestPetsToPlace[i] = allPets[i]
		bestKeysMap[allPets[i].Key] = true
	end

	local freedPositions = {}

	for _, pet in ipairs(allPets) do
		if pet.Placed and not bestKeysMap[pet.Key] then
			table.insert(freedPositions, pet.Position)
			PetRenderer_m.Remove(LocalPlayer.UserId, pet.Key)
			PickupPetRemote:FireServer(pet.Key)
			task.wait(0.2)
		end
	end

	for slotIndex, pet in ipairs(bestPetsToPlace) do
		if AutoSellPet or AutoSellAllPets then break end

		if not pet.Placed then
			local petTool = pet.Tool
			if not petTool or not petTool.Parent then
				local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
				if backpack then
					for _, item in ipairs(backpack:GetChildren()) do
						if item:GetAttribute("PetKey") == pet.Key then
							petTool = item
							break
						end
					end
				end
			end

			if petTool then
				humanoid:EquipTool(petTool)
				local timeout = os.clock() + 2
				repeat task.wait() until petTool.Parent == char or os.clock() > timeout

				if petTool.Parent == char then
					local placePos = table.remove(freedPositions, 1) or GetPlotPlacementPos(rootPart, slotIndex)
					PlacePetRemote:FireServer(pet.Key, placePos)
					task.wait(0.2)
				end
			end
		end
	end

	if LocalPlayer:GetAttribute("IsRiding") ~= true and not AutoSellPet and not AutoSellAllPets then
		humanoid:UnequipTools()
	end
end

task.spawn(function()
	while true do
		if AutoEquipBestPet and not AutoSellPet and not AutoSellAllPets then
			pcall(function() PlaceBestPets() end)
			task.wait(10)
		else
			task.wait(0.5)
		end
	end
end)






-- AUTO UPGRADE HATCH LUCK
task.spawn(function()
	while true do
		if AutoUpgradeHatchLuck then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")

				if UpgradesRemote then
					UpgradesRemote:FireServer("Hatch Luck", 1)
				end
			end)
			task.wait(0.5)
		else
			task.wait(0.5)
		end
	end
end)






-- AUTO UPGRADE HATCH LUCK MAX
task.spawn(function()
	while true do
		if AutoUpgradeHatchLuckMax then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")

				if UpgradesRemote then
					UpgradesRemote:FireServer("Max")
				end
			end)
			task.wait(5)
		else
			task.wait(0.5)
		end
	end
end)






-- AUTO REBIRTH LOOP
local function CanRebirth()
	-- 1. Cap Check
	local maxCap = tonumber(Rebirths_m.Cap)
	if maxCap and Rebirths.Value >= maxCap then 
		return false 
	end

	-- 2. Cost Check
	local currentCost = Rebirths_m.GetCost(Rebirths.Value)
	if Cash.Value < currentCost then 
		return false 
	end

	-- 3. Pet Requirement Check
	local nextIndex = Rebirths.Value + 1
	local reqList = General_m.RebirthRequirements
	
	if not reqList then
		return true
	end

	local requiredPet = reqList[math.clamp(nextIndex, 1, math.max(#reqList, 1))]

	-- Kung walang pet requirement sa level na 'to
	if not requiredPet then 
		return true 
	end

	-- Check Pet via PetRenderer
	if PetRenderer_m and PetRenderer_m.GetAll then
		for _, val in pairs(PetRenderer_m.GetAll()) do
			if val.OwnerUserId == LocalPlayer.UserId and (val.Model and val.Model.Parent and val.Model.Name == requiredPet) then
				return true
			end
		end
	end

	-- Check Container (Backpack & Character)
	local function ScanContainer(container)
		if not container then return false end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, requiredPet) then
				return true
			end
		end
		return false
	end

	if ScanContainer(LocalPlayer:FindFirstChildOfClass("Backpack")) or ScanContainer(LocalPlayer.Character) then
		return true
	end

	-- Check Mount / Mounted Part
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local mountJoint = hrp and hrp:FindFirstChild("PetMountJoint")
	local mountedPart = mountJoint and (mountJoint.Part1 and mountJoint.Parent)

	if mountedPart then
		local petAttr = mountedPart:GetAttribute("PetName") or mountedPart.Name
		if string.find(petAttr, requiredPet) then
			return true
		end
	end

	return false
end

-- MAIN LOOP
task.spawn(function()
	while true do
		if AutoRebirth then
			pcall(function()
				if CanRebirth() then
					local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
					local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
					local RebirthRemote = GameRemotes and GameRemotes:FindFirstChild("Rebirth")

					if RebirthRemote then
						RebirthRemote:FireServer()
					end
				end
			end)

			task.wait(2)
		else
			task.wait(0.5)
		end
	end
end)






-- AUTO CLAIM INDEX REWARD
local function CanClaimIndexReward()
	local success, result = pcall(function()
		local discovered = IndexRewards.DiscoveredCount(OwnedPetsIndex.Value)
		local stage = IndexRewards.StageAt(IndexRewardStage.Value)
		if not stage then return false end
		return discovered >= stage.Goal
	end)
	return success and result == true
end

task.spawn(function()
	while true do
		if AutoClaimIndex then
			if CanClaimIndexReward() then
				pcall(function() ClaimIndexReward:FireServer() end)
				task.wait(1)
			end
		end
		task.wait(0.5)
	end
end)






-- AUTO FARM LOOP
task.spawn(function()
	while true do
		if AutoPickup then
			local Egg = FindSelectedEgg()
			if Egg then
				local char = GetCharacter()
				local hrp = char and char:FindFirstChild("HumanoidRootPart")

				if hrp then
					if Egg.Name == "Volcanic Egg" then
						
						local volcano1CFrame = CFrame.new(
							-4895.28516, 41278.4492, -3723.92383,
							-0.651083589, -0.103715874, 0.751886427,
							1.3961988e-08, 0.990619779, 0.136646986,
							-0.759006023, 0.0889686197, -0.644976318
						)
						hrp.CFrame = volcano1CFrame
						task.wait(0.1)

						local volcano2CFrame = CFrame.new(
						 -4974.02295, 41275.0195, -3647.97583,
                        -0.736429989, 5.97274452e-09, 0.676513731,
                        3.34177592e-08, 1, 2.75487313e-08,
                       -0.676513731, 4.28952873e-08, -0.736429989
						)
						TweenToCFrame(volcano2CFrame)
						task.wait(0.1)

						local eggPart = GetEggPart(Egg)
						if eggPart then
							hrp.CFrame = eggPart.CFrame * CFrame.new(0, 1.5, 0)
							task.wait(0.1)

							for i = 1, 2 do
								PickupEgg(Egg)
								task.wait(0.05)
							end
							task.wait(0.5)
						end

						hrp.CFrame = volcano2CFrame
						task.wait(0.1)

						TweenToCFrame(volcano1CFrame)
						task.wait(0.1)

						TeleportToMyPlot()
						task.wait(0.5)

					else
						if TeleportToEgg(Egg) then
							task.wait(0.05)

							for i = 1, 2 do
								PickupEgg(Egg)
								task.wait(0.05)
							end

							task.wait(0.5)

							if AutoVolcanoDip then
								task.wait(0.50)
								local lavaCFrame = CFrame.new(-5111.86475, 41405.6055, -3470.93066, 0.99564749, -5.98519776e-08, 0.0931990221, 6.81852583e-08, 1, -8.62295266e-08, -0.0931990221, 9.22090138e-08, 0.99564749)
								hrp.CFrame = lavaCFrame
								task.wait(0.5)

								pcall(function()
									if VolcanoDipRemote then
										VolcanoDipRemote:FireServer()
									end
								end)

								task.wait(10)

								TeleportToMyPlot()
								task.wait(0.5)
							else
								TeleportToMyPlot()
								task.wait(0.5)
							end
						else
							task.wait(0.1)
						end
					end
				else
					task.wait(0.1)
				end
			else
				task.wait(0.2)
			end
		else
			task.wait(0.2)
		end
		task.wait(0.03)
	end
end)
