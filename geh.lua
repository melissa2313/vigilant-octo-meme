local scriptVer = "ok"
local saveFileVer = "2.0"
gameLoadTime = tick()

if not game:IsLoaded() then
    game.Loaded:Wait()
end
local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do
	game:GetService("RunService").Heartbeat:Wait()
end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Notify = getsenv(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Admin Commands"):WaitForChild("Admin Cmds Client")).AddNotification


allConnected = {}


diffTimeGame = (tick() - gameLoadTime)
Notify("Welcome")


startTime = tick()


--Settings
getgenv().settings = {
    saveVersion = saveFileVer,
    autoFarming = {
        orbs = true,
        sendAll = true,
        areas = {},
        blacklist = {},
        farmMode = "Highest Max Health",
        antiCheatMode = "Wait",
        petSpeed = 10
    },
    game = {
        autoRankChest = true,
        autoVipChest = false,
        autoUseCoinsBoost = false,
        autoUseDamageBoost = false,
        autoUseLuck = false,
        autoUseSuperLuck = false,
        autoCollectBags = true,
        autoBuyMysterious3 = false,
        autoBuyMysterious2 = false,
        autoBuyMysterious1 = false,
        autoBuyNormal3 = false,
        autoBuyNormal2 = false,
        autoBuyNormal1 = false,
        unlockGamepasses = true,
        antiAfk = true,
        statTrackers = true,
        autoInterest = false,
        autoDepo = false
    },
    autoEggs = {
        selectedEggs = {},
        trippleHatch = true,
        skipAnimation = true
    },
    machines = {
        goldAmount = 6,
        goldString = "6 Pets, 100%",
        goldMythicals = false,
        rainbowAmount = 6,
        rainbowString = "6 Pets, 100%",
        rainbowMythicals = false,
        dmAmount = 6,
        dmString = "6 Pets, 100%",
        dmAutoClaim = true,
        dmEnabled = false,
        dmMythicals = false,
        selectedEnchants = {}
    },
    colection = {
        trippleHatch = true,
        ignoreDarkMatter = false,
        ignoreRainbow = false,
        ignoreGold = false,
        ignoreNormal = false,
        ignoreMythicals = false
    },
    guis = {
        keycodes = {}
    }
}
local tempSettings
local function resetTempSettings()
    tempSettings = {
        autoFarming = {
            enabled = false
        },
        autoEggs = {
            enabled = true
        },
        machines = {
            goldEnabled = true,
            rainbowEnabled = true,
            enchantingEquipped = false,
            enchantingNamed = false,
            autoFuse = false,
            eggChecker = false
        },
        colection = {
            deleteEnabled = false,
            openEnabled = false
        }
    }
end
resetTempSettings()

--saving


function recurseTable(tbl, i1, i2)
	for index, value in pairs(tbl) do
		if type(value) == 'table' then
            if i2 then
                getgenv().settings[i1][i2][index] = value
            elseif i1 then
                recurseTable(value, i1, index)
            elseif value then
                recurseTable(value, index)
            end
		else
			if i2 then
                getgenv().settings[i1][i2][index] = value
            elseif i1 then
                getgenv().settings[i1][index] = value
            end
		end
	end
end

local function loadSettings()
    if(isfile and readfile) then
        if(isfile("hhc.json")) then
            data = HttpService:JSONDecode(readfile("hhc.json"))
            recurseTable(data)
            Lib.Signal.Fire("Notification", "Loaded Data From Save File", {
                color = Color3.fromRGB(104, 244, 104)
            })
            if not (data["saveVersion"] == getgenv().settings["saveVersion"]) then
                writefile("hhc.json", (HttpService:JSONEncode(getgenv().settings)))
                Lib.Signal.Fire("Notification", "Migrated Save File To Newer Version", {
                    color = Color3.fromRGB(104, 244, 104)
                })
            end
        end
    end
end
succ, err = pcall(loadSettings)
if err then
    Notify("Could Not Load Save File")
    print(err)
    print(succ)
end

local function saveSettings()
    if(writefile and isfile) then
        writefile("hhc.json", (HttpService:JSONEncode(getgenv().settings)))
        Lib.Signal.Fire("Notification", "Successfully Saved Data", {
            color = Color3.fromRGB(104, 244, 104)
        })
    end
end

local function deleteSettings()
    if(isfile and delfile) then
        if(isfile("hhc.json")) then
            delfile("hhc.json")
            Lib.Signal.Fire("Notification", "Successfully Deleted Save File", {
                color = Color3.fromRGB(104, 244, 104)
            })
        else
            Lib.Signal.Fire("Notification", "Save File Doesn't Exist", {
                color = Color3.fromRGB(237, 22, 22)
            })
        end
    end
end

--Global Functions

local function deleteArrayValue(whichArray, itemName)
	for i,v in pairs(whichArray) do
		if (v == itemName) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end

local function deleteArrayValueThatIsTable(whichArray, itemName, path)
	for i,v in pairs(whichArray) do
		if (v == itemName[path]) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end
local function FindArrayValueThatIsTable(whichArray, itemName, path)
	for i,v in pairs(whichArray) do
		if (v == itemName[path]) then
            return true
		end
	end
    return false
end

local function enchantArrayFind(whichArray, itemName)
	for i,v in ipairs(whichArray) do
		if (v["Enchant"] == itemName["Enchant"] and v["Enchant Number"] == itemName["Enchant Number"]) then
            return true
		end
	end
    return false
end

local function enchantArrayRemove(whichArray, itemName)
	for i,v in ipairs(whichArray) do
		if (v["Enchant"] == itemName["Enchant"] and v["Enchant Number"] == itemName["Enchant Number"]) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end

local function getLengthOfTable(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter = counter + 1
	end
	return counter
end



--Return Coins Array
function getCoinArray()
    local coinData = {}
    local CD = Lib.Network.Invoke("Get Coins")
    for i, data in pairs(CD) do
        --check coins data matching
        matched = false
        for ie, ve in ipairs(getgenv().settings.autoFarming.areas) do
            if (ve == data.a) then
                  matched = true
                break
            end
        end
        for ie, ve in ipairs(getgenv().settings.autoFarming.blacklist) do
            if (ve == data.n) then
                matched = false
                break
            end
        end
        if matched then
            table.insert(coinData, i)
        end
    end

    if (getgenv().settings.autoFarming.farmMode == "Highest Health") then
        --Max
        table.sort(coinData, function(a, b)
            return ((CD[a]["h"]) > (CD[b]["h"]))
        end)
        
    elseif (getgenv().settings.autoFarming.farmMode == "Highest Max Health") then
        --Min
        table.sort(coinData, function(a, b)
            
            return (CD[a]["mh"] > CD[b]["mh"])
        end)
    elseif (getgenv().settings.autoFarming.farmMode == "Diamonds First") then
        --Diamonds First
        table.sort(coinData, function(a, b)
            aNum = 0
            bNum = 0

            if string.match(CD[a]["n"], "Diamond") then
                aNum = 3
            end
            if string.match(CD[b]["n"], "Diamond") then
                bNum = 3
            end

            return (aNum > bNum)
        end)
    end

    return coinData
end

local allAreas = {}
--Update Areas Array
function getAreas()
    allAreas = {}
    worlds = game:GetService("ReplicatedStorage").Framework.Modules["1 | Directory"].Areas:GetChildren()
    for i,v in ipairs(worlds) do
        for ie,ve in pairs(require(v)) do
            table.insert(allAreas, {
                ["area"] = ie,
                ["world"] = v.Name
            })
        end
    end
end
getAreas()

--Update Equipped Pets Array
local equippedPets = {}
function getPets()
    equippedPets = {}
    local Pets = Lib.Save.Get().Pets
    for i, v in pairs(Pets) do
        if v.e then
            table.insert(equippedPets, v.uid)
        end
    end
end
getPets()

--Auto Orbs
spawn(function()
    local orbsBuffer = {}
    spawn(function()
        table.insert(allConnected, Lib.Network.Fired("Orb Added"):Connect(function(orbID)
            if getgenv().settings.autoFarming.orbs then
                table.insert(orbsBuffer, orbID)
            end
        end))
    end)
    while wait(math.random(3,5)) do
        if ((#orbsBuffer > 0) and getgenv().settings.autoFarming.orbs) then
            Lib.Network.Fire("claim orbs", orbsBuffer)
            orbsBuffer = {}
        end
    end
end)

--Send Pet Function
function sendPet(coinID, petID)
    Lib.Network.Fire("change pet target", petID, "Coin", coinID)
    Lib.Network.Fire("farm coin", coinID, petID)
end

local petsFarming = {}


--Auto Farm
function startAutoFarm()
    spawn(function()
        while (tempSettings.autoFarming.enabled) do
            getPets()
            coinTargetNum = 1
            coinTable = getCoinArray()
            if getgenv().settings.autoFarming.sendAll then
                if coinTable[coinTargetNum] then
                    if not petsFarming[equippedPets[1]] or not table.find(coinTable, petsFarming[equippedPets[1]]) then
                        Lib.Network.Invoke("join coin", coinTable[coinTargetNum], equippedPets)
                        for i,v in ipairs(equippedPets) do
                            sendPet(coinTable[coinTargetNum], v)
                            petsFarming[v] = coinTable[coinTargetNum]
                        end
                    end
                end
            else
                if coinTable[coinTargetNum] then
                    for i,v in ipairs(equippedPets) do
                        if not petsFarming[v] or not table.find(coinTable, petsFarming[v]) then
                            if (tempSettings.autoFarming.enabled) and coinTable[coinTargetNum] then
                                Lib.Network.Invoke("join coin", coinTable[coinTargetNum], {v})
                                sendPet(coinTable[coinTargetNum], v)
                                petsFarming[v] = coinTable[coinTargetNum]
                                coinTargetNum = coinTargetNum + 1
                                if not (getgenv().settings.autoFarming.antiCheatMode == "None") then
                                    wait()
                                end
                            end
                        else

                        end
                    end
                end
            end
        end
    end)
end


--UI Lib
function createUILibrary()
    --Start Functions
    local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/UILib.lua"))()
    local UILib = UILib.CreateWindow("ok", (scriptVer))

    --Tabs
    local TabEst = UILib:Tab("Main ")
    local TabFarming = UILib:Tab("Farming ")
    local TabEgg = UILib:Tab("Eggs ")
    local TabMachine = UILib:Tab("Machines ")
    local TabGUIs = UILib:Tab("GUIs ")
    local TabOther = UILib:Tab("Other")
    local TabFree = UILib:Tab("Tools")
    local TabPets = TabFree:Section("Pets")
    --Other
    local ScriptSection = TabOther:Section("Script")
    local UISection = TabOther:Section("UI")

    ScriptSection:Button("Save Settings", function()
        saveSettings()
    end)
    ScriptSection:Button("Delete Settings Save File", function()
        deleteSettings()
    end)
    UISection:Button("Reload UI", function()
        for i,v in ipairs(allConnected) do
            v:Disconnect()
        end
        resetTempSettings()
        UISection:DestroyUI()
        createUILibrary()
    end)
    UISection:Button("Destroy UI", function()
        for i,v in ipairs(allConnected) do
            v:Disconnect()
        end
        resetTempSettings()
        UISection:DestroyUI()
    end)

    --Essentials
    local creditsSection = TabEst:Section("Credits")
    local gameSection = TabEst:Section("Game")
    local redeemSection = TabEst:Section("Auto Use/Redeem")
    local merchantSection = TabEst:Section("Merchant")
    local PlayerSection = TabEst:Section("Player")
    local SpoofingSection = TabEst:Section("Spoofing")
    local UIEnhancementsSection = TabEst:Section("UI Enhancements")

    creditsSection:Label("Credits")
    creditsSection:Button("Copy Invite Link", function()
        setclipboard("discord.gg/hugegames")
    end)
    creditsSection:Label("HUGE GAMES")
    creditsSection:Label("Twekky, 4lve, Natt")
    local SectionPetTeams = TabFree:Section("Pet Teams")
    local SectionMerchantHop = TabFree:Section("Merchant Hop")
    SectionMerchantHop:DropDown("Merchant Hopper Mode", {"Rainbow Hellish Axolotl", "Buy Tier 3"}, function(option)
            if option == "Rainbow Hellish Axolotl" then
                getgenv().mode = 2
            else
                getgenv().mode = 1
            end
        end)
        SectionMerchantHop:Button("Start Merchant Hop", function()
            if not getgenv().mode then
                getgenv().mode = 1
            end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/MerchantHop.lua"))()
        end)

        SectionPetTeams:TextBox("Team Name", "Team Name")
        SectionPetTeams:Button("Save Team")
        SectionPetTeams:Button("Load Team")

        TabPets:Button("Re-Equip Pets", function()
            getPets()
            Lib.Network.Invoke("unequip all pets")
            for i,v in ipairs(equippedPets) do
                Lib.Network.Invoke("equip pet", v)
            end
        end)
        Lib.Save.Get().Upgrades["Pet Walkspeed"] = getgenv().settings.autoFarming.petSpeed
        TabPets:Slider("Pet To Coin Speed", 1, 500, function(currentValue)
            Lib.Save.Get().Upgrades["Pet Walkspeed"] = currentValue
            getgenv().settings.autoFarming.petSpeed = currentValue
        end)

        local plrList = {}
        local selctedPlayer = Lib.LocalPlayer.Name
        local spoofPlayer = Lib.LocalPlayer.Name
        for i,v in pairs(game:GetService("Players"):GetChildren()) do
            table.insert(plrList, v.Name)
        end
        SpoofingSection:DropDown("Select Player", plrList, function(plr)
            selctedPlayer = plr
        end)
        SpoofingSection:Button("Spoof Selected Player", function()
            spoofPlayer = selctedPlayer
            if not Lib.Save["OldGet"] then
                Lib.Save["OldGet"] = Lib.Save.Get
                Lib.Save.Get = function(getOtherPlr)
                    if(getOtherPlr and not (getOtherPlr.Name == game:GetService("Players").LocalPlayer.Name)) then
                        return Lib.Save["OldGet"](getOtherPlr)
                    end
                    plr = game:GetService("Players"):FindFirstChild(spoofPlayer)
                    if not plr then
                        return Lib.Save["OldGet"]()
                    end
                    if(plr.Name == game:GetService("Players").LocalPlayer.Name) then
                        return Lib.Save["OldGet"]()
                    else
                        return Lib.Save["OldGet"](plr)
                    end
                end
            end
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
        end)
        SpoofingSection:Button("Un-Spoof Player", function()
            pcall(function()
                if Lib.Save["OldGet"] then
                    Lib.Save.Get = Lib.Save["OldGet"]
                    Lib.Save["OldGet"] = nil
                end
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
            end)
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
        end)
        SpoofingSection:Button("Show Twitter Name", function()
            if(Lib.Save.Get().TwitterUsername) then
                Lib.Message.New("Your Twitter Name Is @"..Lib.Save.Get().TwitterUsername)
            else
                Lib.Message.New("You Or The User You Spoofed Isn't Verified Through Twitter")
            end
        end)



    --Walk Speed & Jump Power    
    
    PlayerSection:Slider("WalkSpeed", 16, 500, function(currentValue)
        game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = currentValue
    end)
    PlayerSection:Slider("Jump Power", 50, 1000, function(currentValue)
        game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = currentValue
    end)

    
--Auto Redeem Gift
  	local gifttimer = game:GetService("Players").LocalPlayer.PlayerGui.FreeGiftsTop.Button.Timer
  	redeemSection:Toggle("[NEW!] Auto Redeem Free Gift", getgenv().settings.game.autofreegift, function(bool)
      getgenv().settings.game.autofreegift = bool
      if bool then
          spawn(function()
              while getgenv().settings.game.autofreegift do
                if gifttimer.text == "Ready!" then
                    Lib.Network.Invoke("redeem free gift", 1)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 2)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 3)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 4)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 5)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 6)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 7)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 8)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 9)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 10)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 11)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 12)
                  end
                  wait(5)
                end
              end)
          end
      end)

--Auto Loot Bags

    redeemSection:Label("Misc")

    redeemSection:Toggle("Auto Claim Loot Bags", getgenv().settings.game.autoCollectBags, function(bool)
        getgenv().settings.game.autoCollectBags = bool
        if bool then
            spawn(function()
                while ((getgenv().settings.game.autoCollectBags) and wait(1)) do
                    script = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Lootbags)

                    for i,v in pairs(game:GetService("Workspace")["__THINGS"].Lootbags:GetChildren()) do
                        if(v:GetAttribute("ReadyForCollection")) then
                            if not v:GetAttribute("Collected") then
                                script.Collect(v)
                            end
                        end
                    end
                    wait()
                end
            end)
        end
    end)

    --Auto Redeem Chest
    redeemSection:Label("Chests")
    redeemSection:Toggle("Auto Redeem Rank Chest", getgenv().settings.game.autoRankChest, function(bool)
        getgenv().settings.game.autoRankChest = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoRankChest do
                    Save = Lib.Save.Get()
                    rankCooldown = Lib.Directory.Ranks[Save.Rank].rewardCooldown
                    if ((Save["RankTimer"] + rankCooldown) < os.time()) then
                        Lib.Network.Invoke("redeem rank rewards")
                    end
                    wait(1)
                end
            end)
        end
    end)
    --Auto Reddem VIP Chest
    redeemSection:Toggle("Auto Redeem VIP Chest", getgenv().settings.game.autoVipChest, function(bool)
        getgenv().settings.game.autoVipChest = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoVipChest do
                    Save = Lib.Save.Get()
                    cooldown = 14400
                    if ((Save["VIPCooldown"] + cooldown) < os.time()) then
                        Lib.Network.Invoke("redeem vip rewards")
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    --Auto Use Booost
    redeemSection:Label("Boosts")
    redeemSection:Toggle("Auto Use 3x Coins Boost", getgenv().settings.game.autoUseCoinsBoost, function(bool)
        getgenv().settings.game.autoUseCoinsBoost = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseCoinsBoost do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Triple Coins"] then
                        if Save["Boosts"]["Triple Coins"] < 60 then
                            Lib.Network.Fire("activate boost", "Triple Coins")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Triple Coins")
                        wait(5)
                    end
                    wait(1)
                end
            end)
        end
    end)
    redeemSection:Toggle("Auto Use 3x Damage Boost", getgenv().settings.game.autoUseDamageBoost, function(bool)
        getgenv().settings.game.autoUseDamageBoost = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseDamageBoost do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Triple Damage"] then
                        if Save["Boosts"]["Triple Damage"] < 61 then
                            Lib.Network.Fire("activate boost", "Triple Damage")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Triple Damage")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Toggle("Auto Use Super Lucky", getgenv().settings.game.autoUseLuck, function(bool)
        getgenv().settings.game.autoUseLuck = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseLuck do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Super Lucky"] then
                        if Save["Boosts"]["Super Lucky"] < 61 then
                            Lib.Network.Fire("activate boost", "Super Lucky")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Super Lucky")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Toggle("Auto Use Ultra Lucky", getgenv().settings.game.autoUseSuperLuck, function(bool)
        getgenv().settings.game.autoUseSuperLuck = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseSuperLuck do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Ultra Lucky"] then
                        if Save["Boosts"]["Ultra Lucky"] < 61 then
                            Lib.Network.Fire("activate boost", "Ultra Lucky")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Ultra Lucky")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Label("This Will Automatically Use Boost")
    redeemSection:Label("When There Is Less Than 1 Minute Left")
    --Merchant
    merchantSection:Label("Enable Before Merchant Arrival")
    merchantSection:Label("Mysterious Merchant")
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 1", getgenv().settings.game.autoBuyMysterious1, function(bool)
        getgenv().settings.game.autoBuyMysterious1 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious1) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 1)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 2", getgenv().settings.game.autoBuyMysterious2, function(bool)
        getgenv().settings.game.autoBuyMysterious2 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious2) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 2)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 3", getgenv().settings.game.autoBuyMysterious3, function(bool)
        getgenv().settings.game.autoBuyMysterious3 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious3) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 3)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Label("Normal Merchant")
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 1", getgenv().settings.game.autoBuyNormal1, function(bool)
        getgenv().settings.game.autoBuyNormal1 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal1) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 1)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 2", getgenv().settings.game.autoBuyNormal2, function(bool)
        getgenv().settings.game.autoBuyNormal2 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal2) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 2)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 3", getgenv().settings.game.autoBuyNormal3, function(bool)
        getgenv().settings.game.autoBuyNormal3 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal3) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 3)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)

    merchantSection:Button("Buy All Tier 3 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 3)
        end
    end)
    merchantSection:Button("Buy All Tier 2 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 2)
        end
    end)
    merchantSection:Button("Buy All Tier 1 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 1)
        end
    end)

    
    --Bypass Hacker Portal Quests
    gameSection:Button("Bypass Hacker Portal Quests",function()
         print("Hacker Portal Opened")
    end)

   
    --Unlock Gamepasses
    gameSection:Toggle("Unlock Teleport And Super Magnet", getgenv().settings.game.unlockGamepasses, function(isToggled)
        getgenv().settings.game.unlockGamepasses = isToggled
        if isToggled then
            Lib.Gamepasses.Owns = function() return true end
            teleportScript = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)
            teleportScript.UpdateList()
            teleportScript.UpdateBottom()
        else
            Lib.Gamepasses.Owns = function(p1, p2)
                if not p2 then
                    p2 = game:GetService("Players").LocalPlayer;
                end;
                v2 = Lib.Save.Get();
                if not v2 then
                    return;
                end;
                l__Gamepasses__3 = v2.Gamepasses;
                for v4, v5 in pairs(v2.Gamepasses) do
                    if tostring(v5) == tostring(p1) then
                        return true;
                    end;
                end;
                return false;
            end;
            teleportScript = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)
            teleportScript.UpdateList()
            teleportScript.UpdateBottom()
            hover = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Hoverboard)
            hover.UpdateButton()
        end
    end)

    --AntiAfk
    gameSection:Toggle("Anti Afk", getgenv().settings.game.antiAfk, function(isToggled)
        getgenv().settings.game.antiAfk = isToggled
        if isToggled then
            spawn(function()
                Notify("Enabled Anti AFK")
                VirtualUser = game:GetService("VirtualUser")
                table.insert(allConnected, game:GetService("Players").LocalPlayer.Idled:connect(function()
                    if(getgenv().settings.game.antiAfk) then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    else
                        return false
                    end
                end))
            end)
        else
            Notify("Disabled Anti AFK")
        end
    end)
    --Stat Trackers
    enabledBefore = false
    for i,v in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right"):GetChildren()) do
        if v.Name:split('')[#v.Name] == '2' then
            enabledBefore = true
        end
    end
    gameSection:Toggle("Stat Trackers", getgenv().settings.game.statTrackers, function(isToggled)
        getgenv().settings.game.statTrackers = isToggled
        if isToggled then
            if not enabledBefore then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/stattracker.lua"))()
                enabledBefore = true
            else
                menus = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right")
                for i,v in pairs(menus:GetChildren()) do
                    if v.Name:split('')[#v.Name] == '2' then
                        v.Visible = true
                    end
                end
            end
        else
            menus = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right")
            for i,v in pairs(menus:GetChildren()) do
                if v.Name:split('')[#v.Name] == '2' then
                    v.Visible = false
                end
            end
        end
    end)
    gameSection:Slider("Inventory Size",1,200, function(value)
        game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.UIGridLayout.CellSize = UDim2.new(0, value, 0, value)
        game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.UIGridLayout.CellPadding = UDim2.new(0, (value/3), 0, (value/3))
    end)
    --Fps cap
    gameSection:Button("Cap fps to 10",function()
        if(setfpscap) then
            setfpscap(10)
        end
    end)
    gameSection:Button("Cap fps to 60",function()
        if(setfpscap) then
            setfpscap(60)
        end
    end)


    --UI Enhancements
        UIEnhancementsSection:Label("Allows For better searching within inventory")
        UIEnhancementsSection:Label("Example: TC will show all pets with Tech Coins")
        UIEnhancementsSection:Label("]- Credits To Gerard, Stole This Idea From Him -[")
        UIEnhancementsSection:Button("Advanced Search",function()
        print("Advanced Search Active")
        end)

    --Farming
    local mainFarmingSection = TabFarming:Section("Options")
    --Enabled
    mainFarmingSection:Toggle("Autofarm", false, function(isToggled)
        tempSettings.autoFarming.enabled = isToggled
        if(isToggled) then
            spawn(function()
                startAutoFarm()
            end)
        else
            petsFarming = {}
        end
    end)
    --Auto Orbs
    --Enable Script
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = false
    mainFarmingSection:Toggle("Auto Orbs", getgenv().settings.autoFarming.orbs, function(isToggled)
        getgenv().settings.autoFarming.orbs = isToggled
        if getgenv().settings.autoFarming.orbs then
            --Disable Script
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = true
            wait(2)
            --Claim All Existing Orbs
            Lib.Network.Fire("claim orbs", (game:GetService("Workspace")["__THINGS"].Orbs:GetChildren()))
            for i,v in pairs(game:GetService("Workspace")["__THINGS"].Orbs:GetChildren()) do
                v:Destroy()
            end
            for i,v in pairs(game:GetService("Workspace")["__DEBRIS"]:GetChildren()) do
                if(v.name == "RewardBillboard") then
                    v:Destroy()
                end
            end
        else
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = false
        end
    end)
    --Send All Pets
    mainFarmingSection:Toggle("Send All Pets", getgenv().settings.autoFarming.sendAll, function(isToggled)
        if isToggled then
            getgenv().settings.autoFarming.sendAll = true
        else
            getgenv().settings.autoFarming.sendAll = false
        end
    end)
    mainFarmingSection:Label("Farming Mode")
    mainFarmingSection:DropDown(getgenv().settings.autoFarming.farmMode, {"Normal", "Highest Health", "Highest Max Health", "Diamonds First", "Candy Canes First"}, function(option) -- food is chosen item
        getgenv().settings.autoFarming.farmMode = option
    end)
    mainFarmingSection:Label("Anti-Cheat Prevention Mode")
    mainFarmingSection:DropDown(getgenv().settings.autoFarming.antiCheatMode, {"Wait", "None"}, function(option) -- food is chosen item
        getgenv().settings.autoFarming.antiCheatMode = option
    end)

    TabFarming:Label("Autofarm Area(s)")

    --AutoFarm Areas

    table.sort(allAreas, function(a, b)
        return a.area < b.area
    end)

    tempAreaArray = {}
    for i,v in ipairs(allAreas) do
        if not (tempAreaArray[v.world]) then
            tempAreaArray[v.world] = TabFarming:Section(v.world.." Areas")
            tempAreaArray[v.world]:Label("Select What Area(s) To Autofarm")
            tempAreaArray[v.world]:Toggle(v.area, FindArrayValueThatIsTable((getgenv().settings.autoFarming.areas), v, "area"), function(isToggled)
                if isToggled then
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                    table.insert(getgenv().settings.autoFarming.areas, v.area)
                else
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                end
            end)
        else
            tempAreaArray[v.world]:Toggle(v.area, FindArrayValueThatIsTable((getgenv().settings.autoFarming.areas), v, "area"), function(isToggled)
                if isToggled then
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                    table.insert(getgenv().settings.autoFarming.areas, v.area)
                else
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                end
            end)
        end
    end

    TabFarming:Label("Autofarm Blacklist")

    --Blacklist

    coinTypes = {}
    for i,v in pairs(Lib.Directory.Worlds) do
        for ie,ve in pairs(v["spawns"]) do
            for iee,vee in ipairs(ve["coins"]) do
                match = false
                for i,v in pairs(coinTypes) do
                    if (v["type"] == vee[1]) then
                        match = true
                        break
                    end
                end
                if not match then
                    table.insert(coinTypes, {
                        ["type"] = vee[1],
                        ["world"] = i
                    })
                end
            end
        end
    end
    --Toggles
    table.sort(coinTypes, function(a, b)
        return a.type < b.type
    end)
    tempCoinArray = {}
    for i,v in ipairs(coinTypes) do
        if not (tempCoinArray[v["world"]]) then
            tempCoinArray[v["world"]] = TabFarming:Section(v["world"].." Coin Blacklist")
            tempCoinArray[v["world"]]:Label("Select What Coin(s) To Ignore")
            tempCoinArray[v["world"]]:Toggle(v["type"], ((getgenv().settings.autoFarming.blacklist.type) == v["type"]), function(isToggled)
                if isToggled then
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                    table.insert(getgenv().settings.autoFarming.blacklist, v["type"])
                else
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                end
            end)
        else
            tempCoinArray[v["world"]]:Toggle(v["type"], ((getgenv().settings.autoFarming.blacklist.type) == v["type"]), function(isToggled)
                if isToggled then
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                    table.insert(getgenv().settings.autoFarming.blacklist, v["type"])
                else
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                end
            end)
        end
    end

    --Auto Eggs

    mainEggSection = TabEgg:Section("Main")
    local Library = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
    mainEggSection:Label("Inventory will open/close every 100 seconds.")
    
mainEggSection:Toggle("Auto Eggs", false, function(isToggled)
        tempSettings.autoEggs.enabled = isToggled
        if(isToggled) then
            spawn(function()
                --999+ fix
                spawn(function()
                    if((getLengthOfTable(getgenv().settings.autoEggs.selectedEggs)) > 0) then
                        while(tempSettings.autoEggs.enabled) do
                            wait(100)
                            if(tempSettings.autoEggs.enabled) then
                                game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Enabled = true
                                wait(1)
                                game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Enabled = false
                            end
                        end
                    end
                end)
                while(tempSettings.autoEggs.enabled) do
                    if((getLengthOfTable(getgenv().settings.autoEggs.selectedEggs)) > 0) then
                        --Start AutoEggs
                        save = Lib.Save.Get


                        for i,v in pairs(getgenv().settings.autoEggs.selectedEggs) do
                            affordsEgg = false
                            if getgenv().settings.autoEggs.trippleHatch then
                                affordsEgg = (save()[v.currency] >= (v.cost * 3))
                            else
                                affordsEgg = (save()[v.currency] >= v.cost)
                            end
                            if(affordsEgg and tempSettings.autoEggs.enabled) then
                                Lib.Network.Invoke("buy egg", (i), (getgenv().settings.autoEggs.trippleHatch))
                                Notify("Opening "..i)
                                wait(0.5)
                            end
                        end
                    else
                        spawn(function()
                            Lib.Message.New("Select atleast one egg before starting auto hatch")
                        end)
                        tempSettings.autoEggs.enabled = false
                    end
                    wait()
                end
            end)
        end
    end)
    --Tripple Hatch
    mainEggSection:Toggle("Triple Hatch", getgenv().settings.autoEggs.trippleHatch, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.trippleHatch = true
        else
            getgenv().settings.autoEggs.trippleHatch = false
        end
    end)
    --Set to false
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
    --Egg Skip Animation
    mainEggSection:Toggle("Skip Egg Animation", getgenv().settings.autoEggs.skipAnimation, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.skipAnimation = true
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
        else
            getgenv().settings.autoEggs.skipAnimation = false
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
        end
    end)
    mainEggSection:Label("Egg Counter")
    mainEggSection:TextBox("Type egg name, click ENTER after!", "Type Here", function(getText)
        _G.egg = getText
    end)
    mainEggSection:Label("Follow the format: 'Hacker Egg', 'Golden Hacker Egg'")
    mainEggSection:Label("Make sure to click ENTER after typing for it to work")
    mainEggSection:Button("Click Here To Count Eggs Opened!", function()
        local Library = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
        if Library.Save.Get().EggsOpened[_G.egg] then
            Library.Message.New(_G.egg.. "(s) opened: " ..Library.Save.Get().EggsOpened[_G.egg])
        else
            Library.Message.New(_G.egg.. "(s) opened: 0")
            end
    end)



    --Generate Egg Data
    tempVariableArray = {}
    eggsData = {}
    --Get egg data and world
    for i, v in ipairs(game:GetService("ReplicatedStorage").Game.Eggs:GetChildren()) do
        for ie, ve in ipairs(v:GetChildren()) do
            local mod = ve:FindFirstChildOfClass("ModuleScript");
            if mod then
                eggsData[{["name"] = ve.Name, ["world"] = v.Name}] = require(mod);
            end;
        end;
    end;

    --Loop through data
    for i,v in pairs(eggsData) do
        if(v.hatchable) then
            if(tempVariableArray[i.world]) then
                tempVariableArray[i.world]:Toggle(i.name, getgenv().settings.autoEggs.selectedEggs[i.name], function(isToggled)
                    if isToggled then
                        getgenv().settings.autoEggs.selectedEggs[i.name] = {
                            ["cost"] = v.cost,
                            ["currency"] = v.currency
                        }
                    else
                        getgenv().settings.autoEggs.selectedEggs[i.name] = nil
                    end
                end)
            else
                tempVariableArray[i.world] = TabEgg:Section(i.world)
                tempVariableArray[i.world]:Toggle(i.name, getgenv().settings.autoEggs.selectedEggs[i.name], function(isToggled)
                    if isToggled then
                        getgenv().settings.autoEggs.selectedEggs[i.name] = {
                            ["cost"] = v.cost,
                            ["currency"] = v.currency
                        }
                    else
                        getgenv().settings.autoEggs.selectedEggs[i.name] = nil
                    end
                end)
            end
        end
    end

    -- Machines
    local EnchantSection = TabMachine:Section("Auto Enchant")
    local GoldSection = TabMachine:Section("Auto Gold")
    local RainbowSection = TabMachine:Section("Auto Rainbow")
    local ColletionSection = TabMachine:Section("Pet Index / Pet Collection")
    local DarkMatterSection = TabMachine:Section("Dark Matter")
    local BankSection = TabMachine:Section("Bank")
    local FuseSection = TabMachine:Section("Auto Fuse")

    --Bank

    local bankAction = {}

    bankAction.deposit = function(BUID, Pets, Gems)
        return pcall(function()
            Lib.Network.Invoke("bank deposit", BUID, Pets, Gems)
        end)
    end
    bankAction.withdraw = function(BUID, Pets, Gems)
        return pcall(function()
            Lib.Network.Invoke("bank withdraw", BUID, Pets, Gems)
        end)
    end
    bankAction.get = function(BUID)
        return Lib.Network.Invoke("get bank", BUID)
    end

    local allBank = {}
    local bankNames = {}
    local selectedBankUID = nil

    for i,v in pairs((Lib.Network.Invoke("get my banks"))) do
        pcall(function ()
            name = Players:GetNameFromUserIdAsync(v.Owner)
        end)
        if name then
            allBank[name] = v.BUID
            table.insert(bankNames, name)
        end
    end

    BankSection:DropDown("Select bank", bankNames, function(selected)
        BUID = allBank[selected]
        if not BUID then
            spawn(function()
                Lib.Message.New("Bank Wasn't Found")
            end)
            return false
        end
        selectedBankUID = BUID
    end)

    BankSection:Button("Deposit 100 Pets", function()
        Pets = Lib.Save.Get().Pets
        PetsUID = {}

        for i,v in pairs(Pets) do
            if i < 100 then
                table.insert(PetsUID, v.uid)
            else
                break
            end
        end

        table.remove(PetsUID, #PetsUID)

        bankAction.deposit(selectedBankUID, PetsUID, 0)
    end)
    BankSection:Button("Withdraw 100 Pets", function()
        Pets = bankAction.get(selectedBankUID)["Storage"]["Pets"]
        PetsUID = {}

        for i,v in pairs(Pets) do
            if i < 100 then
                table.insert(PetsUID, v.uid)
            else
                break
            end
        end
        bankAction.withdraw(selectedBankUID, PetsUID, 0)

    end)

    BankSection:Button("Deposit All Gems", function()
        
        bankAction.deposit(selectedBankUID, {}, math.floor(Lib.Save.Get().Diamonds - 10))

    end)

    BankSection:Button("Withdraw All Gems", function()
        
        myDiamonds = math.floor(Lib.Save.Get().Diamonds)
        bankDiamonds = math.floor(bankAction.get(selectedBankUID)["Storage"]["Currency"].Diamonds - 10)

        if ((myDiamonds + bankDiamonds) > 25000000000) then
            bankAction.withdraw(selectedBankUID, {}, (bankDiamonds - myDiamonds - 10))
        else
            bankAction.withdraw(selectedBankUID, {}, bankDiamonds)
        end
        

    end)


    BankSection:Toggle("Auto Collect Bank Interest", getgenv().settings.game.autoInterest, function(bool)
        getgenv().settings.game.autoInterest = bool
        if bool then
            spawn(function()
                while (getgenv().settings.game.autoInterest) do
                    myBanks = (Lib.Network.Invoke("get my banks"))
                    for i,v in pairs(myBanks) do
                        if(v.Owner == Lib.LocalPlayer.UserId) then
                            bankIntrest = Lib.Network.Invoke("collect bank interest", v.BUID)
                            bankDetail = Lib.Network.Invoke("get bank", v.BUID)
                            wait((os.time() + 86400) - bankDetail.LastInterest)
                        end
                    end
                end
            end)
        end
    end)
    BankSection:Toggle("Auto Deposit Gems To My Bank", getgenv().settings.game.autoDepo, function(bool)
        getgenv().settings.game.autoDepo = bool
        if bool then
            spawn(function()
                while (getgenv().settings.game.autoDepo) do
                    myBanks = (Lib.Network.Invoke("get my banks"))
                    for i,v in pairs(myBanks) do
                        if(v.Owner == Lib.LocalPlayer.UserId) then
                            bankAction.deposit(v.BUID, {}, math.floor(Lib.Save.Get().Diamonds - 10))
                        end
                    end
                    wait(30)
                end
            end)
        end
    end)


    --Auto Enchant

    EnchantSection:Toggle("Enchant Equipped Pets", false, function(isToggled)
        tempSettings.machines.enchantingEquipped = isToggled
        if not (tempSettings.machines.enchantingEquipped) then return end
        spawn(function()
            if (#getgenv().settings.machines.selectedEnchants > 0) then
                while (tempSettings.machines.enchantingEquipped) do
                    save = Lib.Save.Get().Pets
                    for i,v in pairs(save) do
                        if (v.e) then
                            if (v["powers"]) and (#v["powers"] > 0) then
                                matchedEnchant = false
                                for ie,ve in pairs(v["powers"]) do
                                    for iee,vee in pairs(getgenv().settings.machines.selectedEnchants) do
                                        if (tonumber(vee["Enchant Number"]) <= tonumber(ve[2])) and (vee["Enchant"] == ve[1]) then
                                            matchedEnchant = true
                                        end
                                    end
                                    if not (matchedEnchant) then
                                        Lib.Network.Invoke("enchant pet", v.uid)
                                    end
                                end
                            else
                                Lib.Network.Invoke("enchant pet", v.uid)
                            end
                        end
                    end
                    wait()
                end
                return
            else
                spawn(function() Lib.Message.New("No Enchants Selected") end)
                tempSettings.machines.enchantingEquipped = false
                return
            end
        end)
    end)

    EnchantSection:Toggle("Enchant Pets Named Enchant", false, function(isToggled)
        tempSettings.machines.enchantingNamed = isToggled
        if not (tempSettings.machines.enchantingNamed) then return end
        spawn(function()
            if (#getgenv().settings.machines.selectedEnchants > 0) then
                while (tempSettings.machines.enchantingNamed) do
                    save = Lib.Save.Get().Pets
                    for i,v in pairs(save) do
                        if (v.nk:lower() == "enchant") then
                            if (v["powers"]) and (#v["powers"] > 0) then
                                matchedEnchant = false
                                for ie,ve in pairs(v["powers"]) do
                                    for iee,vee in pairs(getgenv().settings.machines.selectedEnchants) do
                                        if (tonumber(vee["Enchant Number"]) <= tonumber(ve[2])) and (vee["Enchant"] == ve[1]) then
                                            matchedEnchant = true
                                        end
                                    end
                                    if not (matchedEnchant) then
                                        Lib.Network.Invoke("enchant pet", v.uid)
                                    end
                                end
                            else
                                Lib.Network.Invoke("enchant pet", v.uid)
                            end
                        end
                    end
                    wait()
                end
                return
            else
                spawn(function() Lib.Message.New("No Enchannts Selected") end)
                tempSettings.machines.enchantingNamed = false
                return
            end
        end)
    end)

    EnchantSection:Label("Select Enchant(s) To Stop At")

    enchantsTable = {}
    for i,v in pairs(Lib.Directory.Powers) do
        if (v["canDrop"]) then
            for ie,ve in ipairs(v["tiers"]) do
                table.insert(enchantsTable, (i.." - "..ie.." | "..ve["title"]))
            end
        end
    end

    for i,v in ipairs(enchantsTable) do
        EnchantSection:Toggle(v, enchantArrayFind(getgenv().settings.machines.selectedEnchants, {
            ["Enchant"] = string.split((string.split(v, " | ")[1]), " - ")[1],
            ["Enchant Number"] = string.split((string.split(v, " | ")[1]), " - ")[2]
        }), function(bool)
            splitEnch = string.split((string.split(v, " | ")[1]), " - ")
            tempTable = {
                ["Enchant"] = splitEnch[1],
                ["Enchant Number"] = splitEnch[2]
            }
            if bool then
                if not enchantArrayFind(getgenv().settings.machines.selectedEnchants, tempTable) then
                    table.insert(getgenv().settings.machines.selectedEnchants, tempTable)
                end
            else
                enchantArrayRemove(getgenv().settings.machines.selectedEnchants, tempTable)
            end
        end)
    end



    --Gold
    GoldSection:Label("Name Pets Ignore To Ignore Them")
    GoldSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.goldMythicals, function(isToggled)
        getgenv().settings.machines.goldMythicals = isToggled
    end)
    GoldSection:Toggle("Auto Make Pets Gold", false, function(isToggled)
        tempSettings.machines.goldEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.machines.goldEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.goldMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if not (petRarity.g or petRarity.r or petRarity.dm) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.goldAmount) then
                            petsToGold = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToGold == (getgenv().settings.machines.goldAmount)) then
                                    table.insert(petsToGold, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("use golden machine", petsToGold)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)
    GoldSection:DropDown(getgenv().settings.machines.goldString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.goldAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.goldString = option
    end)


    --Auto Rainbow
    RainbowSection:Label("Name Pets Ignore To Ignore Them")
    RainbowSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.rainbowMythicals, function(isToggled)
        getgenv().settings.machines.rainbowMythicals = isToggled
    end)

    RainbowSection:Toggle("Auto Make Pets Rainbow", false, function(isToggled)
        tempSettings.machines.rainbowEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.machines.rainbowEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.rainbowMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if (petRarity.g) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.rainbowAmount) then
                            petsToRainbow = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToRainbow == (getgenv().settings.machines.rainbowAmount)) then
                                    table.insert(petsToRainbow, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("use rainbow machine", petsToRainbow)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)

    RainbowSection:DropDown(getgenv().settings.machines.rainbowString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.rainbowAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.rainbowString = option
    end)

    --Collection
    ColletionSection:Label("Settings")

    ColletionSection:Toggle("Triple Hatch", getgenv().settings.colection.trippleHatch, function(isToggled)
        getgenv().settings.colection.trippleHatch = isToggled
    end)

    ColletionSection:Toggle("Skip Egg Animation", getgenv().settings.autoEggs.skipAnimation, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.skipAnimation = true
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
        else
            getgenv().settings.autoEggs.skipAnimation = false
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
        end
    end)

    ColletionSection:Toggle("Ignore Darkmatter Pet Index", getgenv().settings.colection.ignoreDarkMatter, function(isToggled)
        getgenv().settings.colection.ignoreDarkMatter = isToggled
    end)

    ColletionSection:Toggle("Ignore Rainbow Pet Index", getgenv().settings.colection.ignoreRainbow, function(isToggled)
        getgenv().settings.colection.ignoreRainbow = isToggled
    end)

    ColletionSection:Toggle("Ignore Gold Pet Index", getgenv().settings.colection.ignoreGold, function(isToggled)
        getgenv().settings.colection.ignoreGold = isToggled
    end)

    ColletionSection:Toggle("Ignore Normal Pet Index", getgenv().settings.colection.ignoreNormal, function(isToggled)
        getgenv().settings.colection.ignoreNormal = isToggled
    end)

    ColletionSection:Toggle("Ignore Mythical Pet Index", getgenv().settings.colection.ignoreMythicals, function(isToggled)
        getgenv().settings.colection.ignoreMythicals = isToggled
    end)

    ColletionSection:Label("Main")

    ColletionSection:Toggle("Delete Opened Pets That Are In Index", false, function(isToggled)
        tempSettings.colection.deleteEnabled = isToggled
        if isToggled then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Open Egg"):Connect(function(egg, openTable)
                    if tempSettings.colection.deleteEnabled then
                        save = Lib.Save.Get()

                        local deleteTable = {}
                        for i,v in ipairs(openTable) do
                            if (Lib.Directory.Pets[v.id]["rarity"] == "Mythical") then
                                continue
                            end
                            matched = false
                            if not (getgenv().settings.colection.ignoreDarkMatter) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 4) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreRainbow) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 3) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreGold) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 2) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreNormal) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 1) then
                                    matched = true
                                end
                            end

                            if (matched == true) then
                                table.insert(deleteTable, v.uid)
                            end
                        end
                        Lib.Network.Invoke("delete several pets", deleteTable)
                    else
                        return
                    end
                end))
            end)
        end
    end)

    ColletionSection:Toggle("Open Eggs That Isn't In Index", false, function(isToggled)
        tempSettings.colection.openEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.colection.openEnabled do
                    print("Start")
                    collectablePets = Lib.Shared.GetAllCollectablePets()

                    for i,v in pairs(collectablePets) do
                        if not Lib.Shared.GetPetEgg(v.petId) then
                            collectablePets[i] = nil
                        end
                    end

                    for i,v in pairs(collectablePets) do
                        if tempSettings.colection.openEnabled then
                            local isRainbow = v["isRainbow"]
                            local isDarkMatter = v["isDarkMatter"]
                            if v["isGolden"] then
                                attribute = 2
                            elseif isRainbow then
                                attribute = 3
                            elseif isDarkMatter then
                                attribute = 4
                            else
                                attribute = 1
                            end;

                            if (getgenv().settings.colection.ignoreDarkMatter) then
                                if attribute == 4 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreRainbow) then
                                if attribute == 3 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreGold) then
                                if attribute == 2 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreNormal) then
                                if attribute == 1 then
                                    continue
                                end
                            end

                            if getgenv().settings.colection.ignoreMythicals then
                                if (Lib.Directory.Pets[v.petId]["rarity"] == "Mythical") then
                                    continue
                                end
                            end
                            
                           
                            ownPet = Lib.Functions.SearchArray((Lib.Save.Get().Collection), v.petId .. "-" .. attribute)
                            inEgg = Lib.Shared.GetPetEgg(v.petId)
                            if inEgg then
                                if not ownPet then
                                    goldData = (Lib.Directory.Eggs[("Golden "..inEgg)])
                                    eggData = Lib.Directory.Eggs[inEgg]
                                    if goldData and  not (attribute == 1) then
                                        print(goldData, eggData, inEgg)
                                        if eggData.hatchable and (Lib.Save.Get()[(eggData.currency)] >= goldData.cost) then
                                            Lib.Network.Invoke("buy egg", ("Golden "..inEgg), getgenv().settings.colection.trippleHatch)
                                            Notify("Opening "..("Golden "..inEgg))
                                            wait(0.8)
                                        end
                                    else
                                        if eggData.hatchable and (Lib.Save.Get()[eggData.currency] >= eggData.cost) then
                                            Lib.Network.Invoke("buy egg", inEgg, getgenv().settings.colection.trippleHatch)
                                            Notify("Opening "..inEgg)
                                            wait(0.5)
                                        end
                                    end
                                end
                            end

                        end
                    end
                    print("Reached End")
                    wait()
                end
                return
            end)
        end
    end)




    --Dark Matter

    DarkMatterSection:Label("Name Pets Ignore To Ignore Them")
    DarkMatterSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.dmMythicals, function(isToggled)
        getgenv().settings.machines.dmMythicals = isToggled
    end)
    DarkMatterSection:Toggle("Auto Make Pets Dark Matter", getgenv().settings.machines.dmEnabled, function(isToggled)
        getgenv().settings.machines.dmEnabled = isToggled
        if isToggled then
            spawn(function()
                while getgenv().settings.machines.dmEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.dmMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if (petRarity.r) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.dmAmount) then
                            petsToDM = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToDM == (getgenv().settings.machines.dmAmount)) then
                                    table.insert(petsToDM, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("convert to dark matter", petsToDM)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)
    DarkMatterSection:Toggle("Auto Claim Dark Matter", getgenv().settings.machines.dmAutoClaim, function(bool)
        getgenv().settings.machines.dmAutoClaim = bool
        if bool then
            spawn(function()
                while getgenv().settings.machines.dmAutoClaim do
                    save = Lib.Save.Get()
                    for i,v in pairs(save["DarkMatterQueue"]) do
                        if (v["readyTime"] < os.time()) then
                            Lib.Network.Invoke("redeem dark matter pet", i)
                        end
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    DarkMatterSection:DropDown(getgenv().settings.machines.dmString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.dmAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.dmString = option
    end)

    --Fusing

    local petToFuse = ''
    local amountPetsFuse = 3
    local petRarity = "Normal"

    FuseSection:TextBox("Pet Name", "Pet Name", function(getText)
        petToFuse = getText
    end)

    FuseSection:DropDown("Pet Rarity",{"Normal", "Gold", "Rainbow", "Dark Matter"}, function(option)
        petRarity = option
    end)

    FuseSection:DropDown('Amount Of Pets To Fuse', {
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12'
    }, function(option)
        amountPetsFuse = tonumber(option)
    end)

    --Im lazy, adding code from 2.0

    FuseSection:Toggle("Auto Fuse", false, function(bool)
        tempSettings.machines.autoFuse = bool
        if bool then
            spawn(function()
                while tempSettings.machines.autoFuse do
                    petId = -1
                    for i,v in pairs(Lib.Directory.Pets) do
                        if (string.lower(v["name"]) == string.lower(petToFuse)) then
                            petId = i
                            break
                        end
                    end
                    if (petId == -1) then
                        spawn(function()
                            Lib.Message.New("Invalid Pet Name Did u Click Enter After Typing???")
                            return
                        end)
                        tempSettings.machines.autoFuse = false
                        return
                    end
                    local Pets = Lib.Save.Get().Pets
                    local selectedPets = {}
                    for i,v in ipairs(Pets) do
                        local petRarityTable = Lib.PetCmds.Get(v.uid)
                        if not (#selectedPets == amountPetsFuse) then
                            if (v.id == (tostring(petId))) then
                                if (petRarity == "Normal") and not (petRarityTable.r) and not (petRarityTable.g) and not (petRarityTable.dm) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Gold") and (petRarityTable.g) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Rainbow") and (petRarityTable.r) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Dark Matter") and (petRarityTable.dm) then
                                    table.insert(selectedPets, v.uid)
                                end
                            end
                        else
                            break
                        end
                    end
                    if (#selectedPets == amountPetsFuse) then
                        Lib.Network.Invoke("fuse pets", selectedPets)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)



    --Gold
    coroutine.wrap(function()
        currString1 = "Gold Machine"
        currInstance1 = game:GetService("Players").LocalPlayer.PlayerGui.Golden
        currSection1 = TabGUIs:Section(currString1)

        currSection1:Button(currString1, function()
            currInstance1.Enabled = true
        end)
        keycode = Enum.KeyCode.G
        if getgenv().settings.guis.keycodes[currString1] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString1]]
        end
        currSection1:KeyBind(currString1.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString1] = keycode
            currInstance1.Enabled = (not currInstance1.Enabled)
        end)
    end)()


    --Rainbow
    coroutine.wrap(function()
        currString2 = "Rainbow Machine"
        currInstance2 = game:GetService("Players").LocalPlayer.PlayerGui.Rainbow
        currSection2 = TabGUIs:Section(currString2)

        currSection2:Button(currString2, function()
            currInstance2.Enabled = true
        end)
        keycode = Enum.KeyCode.R
        if getgenv().settings.guis.keycodes[currString2] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString2]]
        end
        currSection2:KeyBind(currString2.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString2] = keycode
            currInstance2.Enabled = (not currInstance2.Enabled)
        end)
    end)()


    --Dark Matter
    coroutine.wrap(function()
        currStrin3 = "Dark Matter Machine"
        currInstance3 = game:GetService("Players").LocalPlayer.PlayerGui.DarkMatter
        currSection3 = TabGUIs:Section(currStrin3)

        currSection3:Button(currStrin3, function()
            currInstance3.Enabled = true
        end)
        keycode = Enum.KeyCode.T
        if getgenv().settings.guis.keycodes[currStrin3] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin3]]
        end
        currSection3:KeyBind(currStrin3.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin3] = keycode
            currInstance3.Enabled = (not currInstance3.Enabled)
        end)
    end)()

    --Fuse
    coroutine.wrap(function()
        currStrin4 = "Fuse Machine"
        currInstance4 = game:GetService("Players").LocalPlayer.PlayerGui.FusePets
        currSectio4 = TabGUIs:Section(currStrin4)

        currSectio4:Button(currStrin4, function()
            currInstance4.Enabled = true
        end)
        keycode = Enum.KeyCode.F
        if getgenv().settings.guis.keycodes[currStrin4] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin4]]
        end
        currSectio4:KeyBind(currStrin4.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin4] = keycode
            currInstance4.Enabled = (not currInstance4.Enabled)
        end)
    end)()

    --Fuse
    coroutine.wrap(function()
        currString5 = "Pet Collection"
        currInstance5 = game:GetService("Players").LocalPlayer.PlayerGui.Collection
        currSection5 = TabGUIs:Section(currString5)

        currSection5:Button(currString5, function()
            currInstance5.Enabled = true
        end)
        keycode = Enum.KeyCode.P
        if getgenv().settings.guis.keycodes[currString5] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString5]]
        end
        currSection5:KeyBind(currString5.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString5] = keycode
            currInstance5.Enabled = (not currInstance5.Enabled)
        end)
    end)()

    --Merchant
    coroutine.wrap(function()
        currStrin6 = "Merchant"
        currInstance6 = game:GetService("Players").LocalPlayer.PlayerGui.Merchant
        currSectio6 = TabGUIs:Section(currStrin6)

        currSectio6:Button(currStrin6, function()
            currInstance6.Enabled = true
        end)
        keycode = Enum.KeyCode.M
        if getgenv().settings.guis.keycodes[currStrin6] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin6]]
        end
        currSectio6:KeyBind(currStrin6.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin6] = keycode
            currInstance6.Enabled = (not currInstance6.Enabled)
        end)
    end)()


    --Bank
    coroutine.wrap(function()
        currString7 = "Bank"
        currInstance7 = game:GetService("Players").LocalPlayer.PlayerGui.Bank
        currSection7 = TabGUIs:Section(currString7)

        currSection7:Button(currString7, function()
            currInstance7.Enabled = true
        end)
        keycode = Enum.KeyCode.B
        if getgenv().settings.guis.keycodes[currString7] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString7]]
        end
        currSection7:KeyBind(currString7.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString7] = keycode
            currInstance7.Enabled = (not currInstance7.Enabled)
        end)
    end)()

    --Enchant
    coroutine.wrap(function()
        currString8 = "Enchant"
        currInstance8 = game:GetService("Players").LocalPlayer.PlayerGui.EnchantPets
        currSection8 = TabGUIs:Section(currString8)

        currSection8:Button(currString8, function()
            currInstance8.Enabled = true
        end)
        keycode = Enum.KeyCode.E
        if getgenv().settings.guis.keycodes[currString8] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString8]]
        end
        currSection8:KeyBind(currString8.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString8] = keycode
            currInstance8.Enabled = (not currInstance8.Enabled)
        end)
    end)()
    diffTime = (tick() - startTime)
    wait()
    Lib.Signal.Fire("Notification", "Script Took "..(string.format("%0.2f", diffTime)).."s To Fully Load", {
        color = Color3.fromRGB(255, 46, 154)
    })
end
local scriptVer = "ok"
local saveFileVer = "2.0"
gameLoadTime = tick()

if not game:IsLoaded() then
    game.Loaded:Wait()
end
local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do
	game:GetService("RunService").Heartbeat:Wait()
end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Notify = getsenv(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Admin Commands"):WaitForChild("Admin Cmds Client")).AddNotification


allConnected = {}


diffTimeGame = (tick() - gameLoadTime)
Notify("Welcome")


startTime = tick()


--Settings
getgenv().settings = {
    saveVersion = saveFileVer,
    autoFarming = {
        orbs = true,
        sendAll = true,
        areas = {},
        blacklist = {},
        farmMode = "Highest Max Health",
        antiCheatMode = "Wait",
        petSpeed = 10
    },
    game = {
        autoRankChest = true,
        autoVipChest = false,
        autoUseCoinsBoost = false,
        autoUseDamageBoost = false,
        autoUseLuck = false,
        autoUseSuperLuck = false,
        autoCollectBags = true,
        autoBuyMysterious3 = false,
        autoBuyMysterious2 = false,
        autoBuyMysterious1 = false,
        autoBuyNormal3 = false,
        autoBuyNormal2 = false,
        autoBuyNormal1 = false,
        unlockGamepasses = true,
        antiAfk = true,
        statTrackers = true,
        autoInterest = false,
        autoDepo = false
    },
    autoEggs = {
        selectedEggs = {},
        trippleHatch = true,
        skipAnimation = true
    },
    machines = {
        goldAmount = 6,
        goldString = "6 Pets, 100%",
        goldMythicals = false,
        rainbowAmount = 6,
        rainbowString = "6 Pets, 100%",
        rainbowMythicals = false,
        dmAmount = 6,
        dmString = "6 Pets, 100%",
        dmAutoClaim = true,
        dmEnabled = false,
        dmMythicals = false,
        selectedEnchants = {}
    },
    colection = {
        trippleHatch = true,
        ignoreDarkMatter = false,
        ignoreRainbow = false,
        ignoreGold = false,
        ignoreNormal = false,
        ignoreMythicals = false
    },
    guis = {
        keycodes = {}
    }
}
local tempSettings
local function resetTempSettings()
    tempSettings = {
        autoFarming = {
            enabled = false
        },
        autoEggs = {
            enabled = true
        },
        machines = {
            goldEnabled = true,
            rainbowEnabled = true,
            enchantingEquipped = false,
            enchantingNamed = false,
            autoFuse = false,
            eggChecker = false
        },
        colection = {
            deleteEnabled = false,
            openEnabled = false
        }
    }
end
resetTempSettings()

--saving


function recurseTable(tbl, i1, i2)
	for index, value in pairs(tbl) do
		if type(value) == 'table' then
            if i2 then
                getgenv().settings[i1][i2][index] = value
            elseif i1 then
                recurseTable(value, i1, index)
            elseif value then
                recurseTable(value, index)
            end
		else
			if i2 then
                getgenv().settings[i1][i2][index] = value
            elseif i1 then
                getgenv().settings[i1][index] = value
            end
		end
	end
end

local function loadSettings()
    if(isfile and readfile) then
        if(isfile("hhc.json")) then
            data = HttpService:JSONDecode(readfile("hhc.json"))
            recurseTable(data)
            Lib.Signal.Fire("Notification", "Loaded Data From Save File", {
                color = Color3.fromRGB(104, 244, 104)
            })
            if not (data["saveVersion"] == getgenv().settings["saveVersion"]) then
                writefile("hhc.json", (HttpService:JSONEncode(getgenv().settings)))
                Lib.Signal.Fire("Notification", "Migrated Save File To Newer Version", {
                    color = Color3.fromRGB(104, 244, 104)
                })
            end
        end
    end
end
succ, err = pcall(loadSettings)
if err then
    Notify("Could Not Load Save File")
    print(err)
    print(succ)
end

local function saveSettings()
    if(writefile and isfile) then
        writefile("hhc.json", (HttpService:JSONEncode(getgenv().settings)))
        Lib.Signal.Fire("Notification", "Successfully Saved Data", {
            color = Color3.fromRGB(104, 244, 104)
        })
    end
end

local function deleteSettings()
    if(isfile and delfile) then
        if(isfile("hhc.json")) then
            delfile("hhc.json")
            Lib.Signal.Fire("Notification", "Successfully Deleted Save File", {
                color = Color3.fromRGB(104, 244, 104)
            })
        else
            Lib.Signal.Fire("Notification", "Save File Doesn't Exist", {
                color = Color3.fromRGB(237, 22, 22)
            })
        end
    end
end

--Global Functions

local function deleteArrayValue(whichArray, itemName)
	for i,v in pairs(whichArray) do
		if (v == itemName) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end

local function deleteArrayValueThatIsTable(whichArray, itemName, path)
	for i,v in pairs(whichArray) do
		if (v == itemName[path]) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end
local function FindArrayValueThatIsTable(whichArray, itemName, path)
	for i,v in pairs(whichArray) do
		if (v == itemName[path]) then
            return true
		end
	end
    return false
end

local function enchantArrayFind(whichArray, itemName)
	for i,v in ipairs(whichArray) do
		if (v["Enchant"] == itemName["Enchant"] and v["Enchant Number"] == itemName["Enchant Number"]) then
            return true
		end
	end
    return false
end

local function enchantArrayRemove(whichArray, itemName)
	for i,v in ipairs(whichArray) do
		if (v["Enchant"] == itemName["Enchant"] and v["Enchant Number"] == itemName["Enchant Number"]) then
            table.remove(whichArray, i)
            return true
		end
	end
    return false
end

local function getLengthOfTable(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter = counter + 1
	end
	return counter
end



--Return Coins Array
function getCoinArray()
    local coinData = {}
    local CD = Lib.Network.Invoke("Get Coins")
    for i, data in pairs(CD) do
        --check coins data matching
        matched = false
        for ie, ve in ipairs(getgenv().settings.autoFarming.areas) do
            if (ve == data.a) then
                  matched = true
                break
            end
        end
        for ie, ve in ipairs(getgenv().settings.autoFarming.blacklist) do
            if (ve == data.n) then
                matched = false
                break
            end
        end
        if matched then
            table.insert(coinData, i)
        end
    end

    if (getgenv().settings.autoFarming.farmMode == "Highest Health") then
        --Max
        table.sort(coinData, function(a, b)
            return ((CD[a]["h"]) > (CD[b]["h"]))
        end)
        
    elseif (getgenv().settings.autoFarming.farmMode == "Highest Max Health") then
        --Min
        table.sort(coinData, function(a, b)
            
            return (CD[a]["mh"] > CD[b]["mh"])
        end)
    elseif (getgenv().settings.autoFarming.farmMode == "Diamonds First") then
        --Diamonds First
        table.sort(coinData, function(a, b)
            aNum = 0
            bNum = 0

            if string.match(CD[a]["n"], "Diamond") then
                aNum = 3
            end
            if string.match(CD[b]["n"], "Diamond") then
                bNum = 3
            end

            return (aNum > bNum)
        end)
    end

    return coinData
end

local allAreas = {}
--Update Areas Array
function getAreas()
    allAreas = {}
    worlds = game:GetService("ReplicatedStorage").Framework.Modules["1 | Directory"].Areas:GetChildren()
    for i,v in ipairs(worlds) do
        for ie,ve in pairs(require(v)) do
            table.insert(allAreas, {
                ["area"] = ie,
                ["world"] = v.Name
            })
        end
    end
end
getAreas()

--Update Equipped Pets Array
local equippedPets = {}
function getPets()
    equippedPets = {}
    local Pets = Lib.Save.Get().Pets
    for i, v in pairs(Pets) do
        if v.e then
            table.insert(equippedPets, v.uid)
        end
    end
end
getPets()

--Auto Orbs
spawn(function()
    local orbsBuffer = {}
    spawn(function()
        table.insert(allConnected, Lib.Network.Fired("Orb Added"):Connect(function(orbID)
            if getgenv().settings.autoFarming.orbs then
                table.insert(orbsBuffer, orbID)
            end
        end))
    end)
    while wait(math.random(3,5)) do
        if ((#orbsBuffer > 0) and getgenv().settings.autoFarming.orbs) then
            Lib.Network.Fire("claim orbs", orbsBuffer)
            orbsBuffer = {}
        end
    end
end)

--Send Pet Function
function sendPet(coinID, petID)
    Lib.Network.Fire("change pet target", petID, "Coin", coinID)
    Lib.Network.Fire("farm coin", coinID, petID)
end

local petsFarming = {}


--Auto Farm
function startAutoFarm()
    spawn(function()
        while (tempSettings.autoFarming.enabled) do
            getPets()
            coinTargetNum = 1
            coinTable = getCoinArray()
            if getgenv().settings.autoFarming.sendAll then
                if coinTable[coinTargetNum] then
                    if not petsFarming[equippedPets[1]] or not table.find(coinTable, petsFarming[equippedPets[1]]) then
                        Lib.Network.Invoke("join coin", coinTable[coinTargetNum], equippedPets)
                        for i,v in ipairs(equippedPets) do
                            sendPet(coinTable[coinTargetNum], v)
                            petsFarming[v] = coinTable[coinTargetNum]
                        end
                    end
                end
            else
                if coinTable[coinTargetNum] then
                    for i,v in ipairs(equippedPets) do
                        if not petsFarming[v] or not table.find(coinTable, petsFarming[v]) then
                            if (tempSettings.autoFarming.enabled) and coinTable[coinTargetNum] then
                                Lib.Network.Invoke("join coin", coinTable[coinTargetNum], {v})
                                sendPet(coinTable[coinTargetNum], v)
                                petsFarming[v] = coinTable[coinTargetNum]
                                coinTargetNum = coinTargetNum + 1
                                if not (getgenv().settings.autoFarming.antiCheatMode == "None") then
                                    wait()
                                end
                            end
                        else

                        end
                    end
                end
            end
        end
    end)
end


--UI Lib
function createUILibrary()
    --Start Functions
    local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/UILib.lua"))()
    local UILib = UILib.CreateWindow("ok", (scriptVer))

    --Tabs
    local TabEst = UILib:Tab("Main ")
    local TabFarming = UILib:Tab("Farming ")
    local TabEgg = UILib:Tab("Eggs ")
    local TabMachine = UILib:Tab("Machines ")
    local TabGUIs = UILib:Tab("GUIs ")
    local TabOther = UILib:Tab("Other")
    local TabFree = UILib:Tab("Tools")
    local TabPets = TabFree:Section("Pets")
    --Other
    local ScriptSection = TabOther:Section("Script")
    local UISection = TabOther:Section("UI")

    ScriptSection:Button("Save Settings", function()
        saveSettings()
    end)
    ScriptSection:Button("Delete Settings Save File", function()
        deleteSettings()
    end)
    UISection:Button("Reload UI", function()
        for i,v in ipairs(allConnected) do
            v:Disconnect()
        end
        resetTempSettings()
        UISection:DestroyUI()
        createUILibrary()
    end)
    UISection:Button("Destroy UI", function()
        for i,v in ipairs(allConnected) do
            v:Disconnect()
        end
        resetTempSettings()
        UISection:DestroyUI()
    end)

    --Essentials
    local creditsSection = TabEst:Section("Credits")
    local gameSection = TabEst:Section("Game")
    local redeemSection = TabEst:Section("Auto Use/Redeem")
    local merchantSection = TabEst:Section("Merchant")
    local PlayerSection = TabEst:Section("Player")
    local SpoofingSection = TabEst:Section("Spoofing")
    local UIEnhancementsSection = TabEst:Section("UI Enhancements")

    creditsSection:Label("Credits")
    creditsSection:Button("Copy Invite Link", function()
        setclipboard("discord.gg/hugegames")
    end)
    creditsSection:Label("HUGE GAMES")
    creditsSection:Label("Twekky, 4lve, Natt")
    local SectionPetTeams = TabFree:Section("Pet Teams")
    local SectionMerchantHop = TabFree:Section("Merchant Hop")
    SectionMerchantHop:DropDown("Merchant Hopper Mode", {"Rainbow Hellish Axolotl", "Buy Tier 3"}, function(option)
            if option == "Rainbow Hellish Axolotl" then
                getgenv().mode = 2
            else
                getgenv().mode = 1
            end
        end)
        SectionMerchantHop:Button("Start Merchant Hop", function()
            if not getgenv().mode then
                getgenv().mode = 1
            end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/MerchantHop.lua"))()
        end)

        SectionPetTeams:TextBox("Team Name", "Team Name")
        SectionPetTeams:Button("Save Team")
        SectionPetTeams:Button("Load Team")

        TabPets:Button("Re-Equip Pets", function()
            getPets()
            Lib.Network.Invoke("unequip all pets")
            for i,v in ipairs(equippedPets) do
                Lib.Network.Invoke("equip pet", v)
            end
        end)
        Lib.Save.Get().Upgrades["Pet Walkspeed"] = getgenv().settings.autoFarming.petSpeed
        TabPets:Slider("Pet To Coin Speed", 1, 500, function(currentValue)
            Lib.Save.Get().Upgrades["Pet Walkspeed"] = currentValue
            getgenv().settings.autoFarming.petSpeed = currentValue
        end)

        local plrList = {}
        local selctedPlayer = Lib.LocalPlayer.Name
        local spoofPlayer = Lib.LocalPlayer.Name
        for i,v in pairs(game:GetService("Players"):GetChildren()) do
            table.insert(plrList, v.Name)
        end
        SpoofingSection:DropDown("Select Player", plrList, function(plr)
            selctedPlayer = plr
        end)
        SpoofingSection:Button("Spoof Selected Player", function()
            spoofPlayer = selctedPlayer
            if not Lib.Save["OldGet"] then
                Lib.Save["OldGet"] = Lib.Save.Get
                Lib.Save.Get = function(getOtherPlr)
                    if(getOtherPlr and not (getOtherPlr.Name == game:GetService("Players").LocalPlayer.Name)) then
                        return Lib.Save["OldGet"](getOtherPlr)
                    end
                    plr = game:GetService("Players"):FindFirstChild(spoofPlayer)
                    if not plr then
                        return Lib.Save["OldGet"]()
                    end
                    if(plr.Name == game:GetService("Players").LocalPlayer.Name) then
                        return Lib.Save["OldGet"]()
                    else
                        return Lib.Save["OldGet"](plr)
                    end
                end
            end
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
        end)
        SpoofingSection:Button("Un-Spoof Player", function()
            pcall(function()
                if Lib.Save["OldGet"] then
                    Lib.Save.Get = Lib.Save["OldGet"]
                    Lib.Save["OldGet"] = nil
                end
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
            end)
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Inventory).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Currency).Update()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Active Boosts"]).Render()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Achievements).UpdateAll()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Ranks).Update()
        end)
        SpoofingSection:Button("Show Twitter Name", function()
            if(Lib.Save.Get().TwitterUsername) then
                Lib.Message.New("Your Twitter Name Is @"..Lib.Save.Get().TwitterUsername)
            else
                Lib.Message.New("You Or The User You Spoofed Isn't Verified Through Twitter")
            end
        end)



    --Walk Speed & Jump Power    
    
    PlayerSection:Slider("WalkSpeed", 16, 500, function(currentValue)
        game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = currentValue
    end)
    PlayerSection:Slider("Jump Power", 50, 1000, function(currentValue)
        game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = currentValue
    end)

    
--Auto Redeem Gift
  	local gifttimer = game:GetService("Players").LocalPlayer.PlayerGui.FreeGiftsTop.Button.Timer
  	redeemSection:Toggle("[NEW!] Auto Redeem Free Gift", getgenv().settings.game.autofreegift, function(bool)
      getgenv().settings.game.autofreegift = bool
      if bool then
          spawn(function()
              while getgenv().settings.game.autofreegift do
                if gifttimer.text == "Ready!" then
                    Lib.Network.Invoke("redeem free gift", 1)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 2)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 3)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 4)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 5)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 6)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 7)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 8)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 9)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 10)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 11)
                    wait(5)
                    Lib.Network.Invoke("redeem free gift", 12)
                  end
                  wait(5)
                end
              end)
          end
      end)

--Auto Loot Bags

    redeemSection:Label("Misc")

    redeemSection:Toggle("Auto Claim Loot Bags", getgenv().settings.game.autoCollectBags, function(bool)
        getgenv().settings.game.autoCollectBags = bool
        if bool then
            spawn(function()
                while ((getgenv().settings.game.autoCollectBags) and wait(1)) do
                    script = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Lootbags)

                    for i,v in pairs(game:GetService("Workspace")["__THINGS"].Lootbags:GetChildren()) do
                        if(v:GetAttribute("ReadyForCollection")) then
                            if not v:GetAttribute("Collected") then
                                script.Collect(v)
                            end
                        end
                    end
                    wait()
                end
            end)
        end
    end)

    --Auto Redeem Chest
    redeemSection:Label("Chests")
    redeemSection:Toggle("Auto Redeem Rank Chest", getgenv().settings.game.autoRankChest, function(bool)
        getgenv().settings.game.autoRankChest = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoRankChest do
                    Save = Lib.Save.Get()
                    rankCooldown = Lib.Directory.Ranks[Save.Rank].rewardCooldown
                    if ((Save["RankTimer"] + rankCooldown) < os.time()) then
                        Lib.Network.Invoke("redeem rank rewards")
                    end
                    wait(1)
                end
            end)
        end
    end)
    --Auto Reddem VIP Chest
    redeemSection:Toggle("Auto Redeem VIP Chest", getgenv().settings.game.autoVipChest, function(bool)
        getgenv().settings.game.autoVipChest = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoVipChest do
                    Save = Lib.Save.Get()
                    cooldown = 14400
                    if ((Save["VIPCooldown"] + cooldown) < os.time()) then
                        Lib.Network.Invoke("redeem vip rewards")
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    --Auto Use Booost
    redeemSection:Label("Boosts")
    redeemSection:Toggle("Auto Use 3x Coins Boost", getgenv().settings.game.autoUseCoinsBoost, function(bool)
        getgenv().settings.game.autoUseCoinsBoost = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseCoinsBoost do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Triple Coins"] then
                        if Save["Boosts"]["Triple Coins"] < 60 then
                            Lib.Network.Fire("activate boost", "Triple Coins")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Triple Coins")
                        wait(5)
                    end
                    wait(1)
                end
            end)
        end
    end)
    redeemSection:Toggle("Auto Use 3x Damage Boost", getgenv().settings.game.autoUseDamageBoost, function(bool)
        getgenv().settings.game.autoUseDamageBoost = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseDamageBoost do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Triple Damage"] then
                        if Save["Boosts"]["Triple Damage"] < 61 then
                            Lib.Network.Fire("activate boost", "Triple Damage")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Triple Damage")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Toggle("Auto Use Super Lucky", getgenv().settings.game.autoUseLuck, function(bool)
        getgenv().settings.game.autoUseLuck = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseLuck do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Super Lucky"] then
                        if Save["Boosts"]["Super Lucky"] < 61 then
                            Lib.Network.Fire("activate boost", "Super Lucky")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Super Lucky")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Toggle("Auto Use Ultra Lucky", getgenv().settings.game.autoUseSuperLuck, function(bool)
        getgenv().settings.game.autoUseSuperLuck = bool
        if bool then
            spawn(function()
                while getgenv().settings.game.autoUseSuperLuck do
                    Save = Lib.Save.Get()
                    if Save["Boosts"]["Ultra Lucky"] then
                        if Save["Boosts"]["Ultra Lucky"] < 61 then
                            Lib.Network.Fire("activate boost", "Ultra Lucky")
                            wait(5)
                        end
                    else
                        Lib.Network.Fire("activate boost", "Ultra Lucky")
                        wait(5)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    redeemSection:Label("This Will Automatically Use Boost")
    redeemSection:Label("When There Is Less Than 1 Minute Left")
    --Merchant
    merchantSection:Label("Enable Before Merchant Arrival")
    merchantSection:Label("Mysterious Merchant")
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 1", getgenv().settings.game.autoBuyMysterious1, function(bool)
        getgenv().settings.game.autoBuyMysterious1 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious1) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 1)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 2", getgenv().settings.game.autoBuyMysterious2, function(bool)
        getgenv().settings.game.autoBuyMysterious2 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious2) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 2)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Mysterious Merchant Tier 3", getgenv().settings.game.autoBuyMysterious3, function(bool)
        getgenv().settings.game.autoBuyMysterious3 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyMysterious3) then
                        if (isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 3)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Label("Normal Merchant")
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 1", getgenv().settings.game.autoBuyNormal1, function(bool)
        getgenv().settings.game.autoBuyNormal1 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal1) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 1)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 2", getgenv().settings.game.autoBuyNormal2, function(bool)
        getgenv().settings.game.autoBuyNormal2 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal2) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 2)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)
    merchantSection:Toggle("Auto Buy Normal Merchant Tier 3", getgenv().settings.game.autoBuyNormal3, function(bool)
        getgenv().settings.game.autoBuyNormal3 = bool
        if bool then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Merchant Arrival"):Connect(function(isMysterious)
                    if (getgenv().settings.game.autoBuyNormal3) then
                        if (not isMysterious) then
                            for i = 1, 10 do
                                Lib.Network.Invoke("buy merchant item", 3)
                            end
                        end
                    else
                        return
                    end
                end))
            end)
        end
    end)

    merchantSection:Button("Buy All Tier 3 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 3)
        end
    end)
    merchantSection:Button("Buy All Tier 2 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 2)
        end
    end)
    merchantSection:Button("Buy All Tier 1 Pets", function()
        for i = 1, 10 do
            Lib.Network.Invoke("buy merchant item", 1)
        end
    end)

    
    --Bypass Hacker Portal Quests
    gameSection:Button("Bypass Hacker Portal Quests",function()
         print("Hacker Portal Opened")
    end)

   
    --Unlock Gamepasses
    gameSection:Toggle("Unlock Teleport And Super Magnet", getgenv().settings.game.unlockGamepasses, function(isToggled)
        getgenv().settings.game.unlockGamepasses = isToggled
        if isToggled then
            Lib.Gamepasses.Owns = function() return true end
            teleportScript = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)
            teleportScript.UpdateList()
            teleportScript.UpdateBottom()
        else
            Lib.Gamepasses.Owns = function(p1, p2)
                if not p2 then
                    p2 = game:GetService("Players").LocalPlayer;
                end;
                v2 = Lib.Save.Get();
                if not v2 then
                    return;
                end;
                l__Gamepasses__3 = v2.Gamepasses;
                for v4, v5 in pairs(v2.Gamepasses) do
                    if tostring(v5) == tostring(p1) then
                        return true;
                    end;
                end;
                return false;
            end;
            teleportScript = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport)
            teleportScript.UpdateList()
            teleportScript.UpdateBottom()
            hover = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Hoverboard)
            hover.UpdateButton()
        end
    end)

    --AntiAfk
    gameSection:Toggle("Anti Afk", getgenv().settings.game.antiAfk, function(isToggled)
        getgenv().settings.game.antiAfk = isToggled
        if isToggled then
            spawn(function()
                Notify("Enabled Anti AFK")
                VirtualUser = game:GetService("VirtualUser")
                table.insert(allConnected, game:GetService("Players").LocalPlayer.Idled:connect(function()
                    if(getgenv().settings.game.antiAfk) then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    else
                        return false
                    end
                end))
            end)
        else
            Notify("Disabled Anti AFK")
        end
    end)
    --Stat Trackers
    enabledBefore = false
    for i,v in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right"):GetChildren()) do
        if v.Name:split('')[#v.Name] == '2' then
            enabledBefore = true
        end
    end
    gameSection:Toggle("Stat Trackers", getgenv().settings.game.statTrackers, function(isToggled)
        getgenv().settings.game.statTrackers = isToggled
        if isToggled then
            if not enabledBefore then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/vigilkat/vigilkat/main/stattracker.lua"))()
                enabledBefore = true
            else
                menus = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right")
                for i,v in pairs(menus:GetChildren()) do
                    if v.Name:split('')[#v.Name] == '2' then
                        v.Visible = true
                    end
                end
            end
        else
            menus = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Right")
            for i,v in pairs(menus:GetChildren()) do
                if v.Name:split('')[#v.Name] == '2' then
                    v.Visible = false
                end
            end
        end
    end)
    gameSection:Slider("Inventory Size",1,200, function(value)
        game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.UIGridLayout.CellSize = UDim2.new(0, value, 0, value)
        game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.UIGridLayout.CellPadding = UDim2.new(0, (value/3), 0, (value/3))
    end)
    --Fps cap
    gameSection:Button("Cap fps to 10",function()
        if(setfpscap) then
            setfpscap(10)
        end
    end)
    gameSection:Button("Cap fps to 60",function()
        if(setfpscap) then
            setfpscap(60)
        end
    end)


    --UI Enhancements
        UIEnhancementsSection:Label("Allows For better searching within inventory")
        UIEnhancementsSection:Label("Example: TC will show all pets with Tech Coins")
        UIEnhancementsSection:Label("]- Credits To Gerard, Stole This Idea From Him -[")
        UIEnhancementsSection:Button("Advanced Search",function()
        print("Advanced Search Active")
        end)

    --Farming
    local mainFarmingSection = TabFarming:Section("Options")
    --Enabled
    mainFarmingSection:Toggle("Autofarm", false, function(isToggled)
        tempSettings.autoFarming.enabled = isToggled
        if(isToggled) then
            spawn(function()
                startAutoFarm()
            end)
        else
            petsFarming = {}
        end
    end)
    --Auto Orbs
    --Enable Script
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = false
    mainFarmingSection:Toggle("Auto Orbs", getgenv().settings.autoFarming.orbs, function(isToggled)
        getgenv().settings.autoFarming.orbs = isToggled
        if getgenv().settings.autoFarming.orbs then
            --Disable Script
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = true
            wait(2)
            --Claim All Existing Orbs
            Lib.Network.Fire("claim orbs", (game:GetService("Workspace")["__THINGS"].Orbs:GetChildren()))
            for i,v in pairs(game:GetService("Workspace")["__THINGS"].Orbs:GetChildren()) do
                v:Destroy()
            end
            for i,v in pairs(game:GetService("Workspace")["__DEBRIS"]:GetChildren()) do
                if(v.name == "RewardBillboard") then
                    v:Destroy()
                end
            end
        else
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Orbs.Disabled = false
        end
    end)
    --Send All Pets
    mainFarmingSection:Toggle("Send All Pets", getgenv().settings.autoFarming.sendAll, function(isToggled)
        if isToggled then
            getgenv().settings.autoFarming.sendAll = true
        else
            getgenv().settings.autoFarming.sendAll = false
        end
    end)
    mainFarmingSection:Label("Farming Mode")
    mainFarmingSection:DropDown(getgenv().settings.autoFarming.farmMode, {"Normal", "Highest Health", "Highest Max Health", "Diamonds First", "Candy Canes First"}, function(option) -- food is chosen item
        getgenv().settings.autoFarming.farmMode = option
    end)
    mainFarmingSection:Label("Anti-Cheat Prevention Mode")
    mainFarmingSection:DropDown(getgenv().settings.autoFarming.antiCheatMode, {"Wait", "None"}, function(option) -- food is chosen item
        getgenv().settings.autoFarming.antiCheatMode = option
    end)

    TabFarming:Label("Autofarm Area(s)")

    --AutoFarm Areas

    table.sort(allAreas, function(a, b)
        return a.area < b.area
    end)

    tempAreaArray = {}
    for i,v in ipairs(allAreas) do
        if not (tempAreaArray[v.world]) then
            tempAreaArray[v.world] = TabFarming:Section(v.world.." Areas")
            tempAreaArray[v.world]:Label("Select What Area(s) To Autofarm")
            tempAreaArray[v.world]:Toggle(v.area, FindArrayValueThatIsTable((getgenv().settings.autoFarming.areas), v, "area"), function(isToggled)
                if isToggled then
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                    table.insert(getgenv().settings.autoFarming.areas, v.area)
                else
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                end
            end)
        else
            tempAreaArray[v.world]:Toggle(v.area, FindArrayValueThatIsTable((getgenv().settings.autoFarming.areas), v, "area"), function(isToggled)
                if isToggled then
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                    table.insert(getgenv().settings.autoFarming.areas, v.area)
                else
                    deleteArrayValueThatIsTable(getgenv().settings.autoFarming.areas, v, "area")
                end
            end)
        end
    end

    TabFarming:Label("Autofarm Blacklist")

    --Blacklist

    coinTypes = {}
    for i,v in pairs(Lib.Directory.Worlds) do
        for ie,ve in pairs(v["spawns"]) do
            for iee,vee in ipairs(ve["coins"]) do
                match = false
                for i,v in pairs(coinTypes) do
                    if (v["type"] == vee[1]) then
                        match = true
                        break
                    end
                end
                if not match then
                    table.insert(coinTypes, {
                        ["type"] = vee[1],
                        ["world"] = i
                    })
                end
            end
        end
    end
    --Toggles
    table.sort(coinTypes, function(a, b)
        return a.type < b.type
    end)
    tempCoinArray = {}
    for i,v in ipairs(coinTypes) do
        if not (tempCoinArray[v["world"]]) then
            tempCoinArray[v["world"]] = TabFarming:Section(v["world"].." Coin Blacklist")
            tempCoinArray[v["world"]]:Label("Select What Coin(s) To Ignore")
            tempCoinArray[v["world"]]:Toggle(v["type"], ((getgenv().settings.autoFarming.blacklist.type) == v["type"]), function(isToggled)
                if isToggled then
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                    table.insert(getgenv().settings.autoFarming.blacklist, v["type"])
                else
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                end
            end)
        else
            tempCoinArray[v["world"]]:Toggle(v["type"], ((getgenv().settings.autoFarming.blacklist.type) == v["type"]), function(isToggled)
                if isToggled then
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                    table.insert(getgenv().settings.autoFarming.blacklist, v["type"])
                else
                    deleteArrayValue(getgenv().settings.autoFarming.blacklist, v["type"])
                end
            end)
        end
    end

    --Auto Eggs

    mainEggSection = TabEgg:Section("Main")
    local Library = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
    mainEggSection:Label("Inventory will open/close every 100 seconds.")
    
mainEggSection:Toggle("Auto Eggs", false, function(isToggled)
        tempSettings.autoEggs.enabled = isToggled
        if(isToggled) then
            spawn(function()
                --999+ fix
                spawn(function()
                    if((getLengthOfTable(getgenv().settings.autoEggs.selectedEggs)) > 0) then
                        while(tempSettings.autoEggs.enabled) do
                            wait(100)
                            if(tempSettings.autoEggs.enabled) then
                                game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Enabled = true
                                wait(1)
                                game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Enabled = false
                            end
                        end
                    end
                end)
                while(tempSettings.autoEggs.enabled) do
                    if((getLengthOfTable(getgenv().settings.autoEggs.selectedEggs)) > 0) then
                        --Start AutoEggs
                        save = Lib.Save.Get


                        for i,v in pairs(getgenv().settings.autoEggs.selectedEggs) do
                            affordsEgg = false
                            if getgenv().settings.autoEggs.trippleHatch then
                                affordsEgg = (save()[v.currency] >= (v.cost * 3))
                            else
                                affordsEgg = (save()[v.currency] >= v.cost)
                            end
                            if(affordsEgg and tempSettings.autoEggs.enabled) then
                                Lib.Network.Invoke("buy egg", (i), (getgenv().settings.autoEggs.trippleHatch))
                                Notify("Opening "..i)
                                wait(0.5)
                            end
                        end
                    else
                        spawn(function()
                            Lib.Message.New("Select atleast one egg before starting auto hatch")
                        end)
                        tempSettings.autoEggs.enabled = false
                    end
                    wait()
                end
            end)
        end
    end)
    --Tripple Hatch
    mainEggSection:Toggle("Triple Hatch", getgenv().settings.autoEggs.trippleHatch, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.trippleHatch = true
        else
            getgenv().settings.autoEggs.trippleHatch = false
        end
    end)
    --Set to false
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
    --Egg Skip Animation
    mainEggSection:Toggle("Skip Egg Animation", getgenv().settings.autoEggs.skipAnimation, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.skipAnimation = true
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
        else
            getgenv().settings.autoEggs.skipAnimation = false
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
        end
    end)
    mainEggSection:Label("Egg Counter")
    mainEggSection:TextBox("Type egg name, click ENTER after!", "Type Here", function(getText)
        _G.egg = getText
    end)
    mainEggSection:Label("Follow the format: 'Hacker Egg', 'Golden Hacker Egg'")
    mainEggSection:Label("Make sure to click ENTER after typing for it to work")
    mainEggSection:Button("Click Here To Count Eggs Opened!", function()
        local Library = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
        if Library.Save.Get().EggsOpened[_G.egg] then
            Library.Message.New(_G.egg.. "(s) opened: " ..Library.Save.Get().EggsOpened[_G.egg])
        else
            Library.Message.New(_G.egg.. "(s) opened: 0")
            end
    end)



    --Generate Egg Data
    tempVariableArray = {}
    eggsData = {}
    --Get egg data and world
    for i, v in ipairs(game:GetService("ReplicatedStorage").Game.Eggs:GetChildren()) do
        for ie, ve in ipairs(v:GetChildren()) do
            local mod = ve:FindFirstChildOfClass("ModuleScript");
            if mod then
                eggsData[{["name"] = ve.Name, ["world"] = v.Name}] = require(mod);
            end;
        end;
    end;

    --Loop through data
    for i,v in pairs(eggsData) do
        if(v.hatchable) then
            if(tempVariableArray[i.world]) then
                tempVariableArray[i.world]:Toggle(i.name, getgenv().settings.autoEggs.selectedEggs[i.name], function(isToggled)
                    if isToggled then
                        getgenv().settings.autoEggs.selectedEggs[i.name] = {
                            ["cost"] = v.cost,
                            ["currency"] = v.currency
                        }
                    else
                        getgenv().settings.autoEggs.selectedEggs[i.name] = nil
                    end
                end)
            else
                tempVariableArray[i.world] = TabEgg:Section(i.world)
                tempVariableArray[i.world]:Toggle(i.name, getgenv().settings.autoEggs.selectedEggs[i.name], function(isToggled)
                    if isToggled then
                        getgenv().settings.autoEggs.selectedEggs[i.name] = {
                            ["cost"] = v.cost,
                            ["currency"] = v.currency
                        }
                    else
                        getgenv().settings.autoEggs.selectedEggs[i.name] = nil
                    end
                end)
            end
        end
    end

    -- Machines
    local EnchantSection = TabMachine:Section("Auto Enchant")
    local GoldSection = TabMachine:Section("Auto Gold")
    local RainbowSection = TabMachine:Section("Auto Rainbow")
    local ColletionSection = TabMachine:Section("Pet Index / Pet Collection")
    local DarkMatterSection = TabMachine:Section("Dark Matter")
    local BankSection = TabMachine:Section("Bank")
    local FuseSection = TabMachine:Section("Auto Fuse")

    --Bank

    local bankAction = {}

    bankAction.deposit = function(BUID, Pets, Gems)
        return pcall(function()
            Lib.Network.Invoke("bank deposit", BUID, Pets, Gems)
        end)
    end
    bankAction.withdraw = function(BUID, Pets, Gems)
        return pcall(function()
            Lib.Network.Invoke("bank withdraw", BUID, Pets, Gems)
        end)
    end
    bankAction.get = function(BUID)
        return Lib.Network.Invoke("get bank", BUID)
    end

    local allBank = {}
    local bankNames = {}
    local selectedBankUID = nil

    for i,v in pairs((Lib.Network.Invoke("get my banks"))) do
        pcall(function ()
            name = Players:GetNameFromUserIdAsync(v.Owner)
        end)
        if name then
            allBank[name] = v.BUID
            table.insert(bankNames, name)
        end
    end

    BankSection:DropDown("Select bank", bankNames, function(selected)
        BUID = allBank[selected]
        if not BUID then
            spawn(function()
                Lib.Message.New("Bank Wasn't Found")
            end)
            return false
        end
        selectedBankUID = BUID
    end)

    BankSection:Button("Deposit 100 Pets", function()
        Pets = Lib.Save.Get().Pets
        PetsUID = {}

        for i,v in pairs(Pets) do
            if i < 100 then
                table.insert(PetsUID, v.uid)
            else
                break
            end
        end

        table.remove(PetsUID, #PetsUID)

        bankAction.deposit(selectedBankUID, PetsUID, 0)
    end)
    BankSection:Button("Withdraw 100 Pets", function()
        Pets = bankAction.get(selectedBankUID)["Storage"]["Pets"]
        PetsUID = {}

        for i,v in pairs(Pets) do
            if i < 100 then
                table.insert(PetsUID, v.uid)
            else
                break
            end
        end
        bankAction.withdraw(selectedBankUID, PetsUID, 0)

    end)

    BankSection:Button("Deposit All Gems", function()
        
        bankAction.deposit(selectedBankUID, {}, math.floor(Lib.Save.Get().Diamonds - 10))

    end)

    BankSection:Button("Withdraw All Gems", function()
        
        myDiamonds = math.floor(Lib.Save.Get().Diamonds)
        bankDiamonds = math.floor(bankAction.get(selectedBankUID)["Storage"]["Currency"].Diamonds - 10)

        if ((myDiamonds + bankDiamonds) > 25000000000) then
            bankAction.withdraw(selectedBankUID, {}, (bankDiamonds - myDiamonds - 10))
        else
            bankAction.withdraw(selectedBankUID, {}, bankDiamonds)
        end
        

    end)


    BankSection:Toggle("Auto Collect Bank Interest", getgenv().settings.game.autoInterest, function(bool)
        getgenv().settings.game.autoInterest = bool
        if bool then
            spawn(function()
                while (getgenv().settings.game.autoInterest) do
                    myBanks = (Lib.Network.Invoke("get my banks"))
                    for i,v in pairs(myBanks) do
                        if(v.Owner == Lib.LocalPlayer.UserId) then
                            bankIntrest = Lib.Network.Invoke("collect bank interest", v.BUID)
                            bankDetail = Lib.Network.Invoke("get bank", v.BUID)
                            wait((os.time() + 86400) - bankDetail.LastInterest)
                        end
                    end
                end
            end)
        end
    end)
    BankSection:Toggle("Auto Deposit Gems To My Bank", getgenv().settings.game.autoDepo, function(bool)
        getgenv().settings.game.autoDepo = bool
        if bool then
            spawn(function()
                while (getgenv().settings.game.autoDepo) do
                    myBanks = (Lib.Network.Invoke("get my banks"))
                    for i,v in pairs(myBanks) do
                        if(v.Owner == Lib.LocalPlayer.UserId) then
                            bankAction.deposit(v.BUID, {}, math.floor(Lib.Save.Get().Diamonds - 10))
                        end
                    end
                    wait(30)
                end
            end)
        end
    end)


    --Auto Enchant

    EnchantSection:Toggle("Enchant Equipped Pets", false, function(isToggled)
        tempSettings.machines.enchantingEquipped = isToggled
        if not (tempSettings.machines.enchantingEquipped) then return end
        spawn(function()
            if (#getgenv().settings.machines.selectedEnchants > 0) then
                while (tempSettings.machines.enchantingEquipped) do
                    save = Lib.Save.Get().Pets
                    for i,v in pairs(save) do
                        if (v.e) then
                            if (v["powers"]) and (#v["powers"] > 0) then
                                matchedEnchant = false
                                for ie,ve in pairs(v["powers"]) do
                                    for iee,vee in pairs(getgenv().settings.machines.selectedEnchants) do
                                        if (tonumber(vee["Enchant Number"]) <= tonumber(ve[2])) and (vee["Enchant"] == ve[1]) then
                                            matchedEnchant = true
                                        end
                                    end
                                    if not (matchedEnchant) then
                                        Lib.Network.Invoke("enchant pet", v.uid)
                                    end
                                end
                            else
                                Lib.Network.Invoke("enchant pet", v.uid)
                            end
                        end
                    end
                    wait()
                end
                return
            else
                spawn(function() Lib.Message.New("No Enchants Selected") end)
                tempSettings.machines.enchantingEquipped = false
                return
            end
        end)
    end)

    EnchantSection:Toggle("Enchant Pets Named Enchant", false, function(isToggled)
        tempSettings.machines.enchantingNamed = isToggled
        if not (tempSettings.machines.enchantingNamed) then return end
        spawn(function()
            if (#getgenv().settings.machines.selectedEnchants > 0) then
                while (tempSettings.machines.enchantingNamed) do
                    save = Lib.Save.Get().Pets
                    for i,v in pairs(save) do
                        if (v.nk:lower() == "enchant") then
                            if (v["powers"]) and (#v["powers"] > 0) then
                                matchedEnchant = false
                                for ie,ve in pairs(v["powers"]) do
                                    for iee,vee in pairs(getgenv().settings.machines.selectedEnchants) do
                                        if (tonumber(vee["Enchant Number"]) <= tonumber(ve[2])) and (vee["Enchant"] == ve[1]) then
                                            matchedEnchant = true
                                        end
                                    end
                                    if not (matchedEnchant) then
                                        Lib.Network.Invoke("enchant pet", v.uid)
                                    end
                                end
                            else
                                Lib.Network.Invoke("enchant pet", v.uid)
                            end
                        end
                    end
                    wait()
                end
                return
            else
                spawn(function() Lib.Message.New("No Enchannts Selected") end)
                tempSettings.machines.enchantingNamed = false
                return
            end
        end)
    end)

    EnchantSection:Label("Select Enchant(s) To Stop At")

    enchantsTable = {}
    for i,v in pairs(Lib.Directory.Powers) do
        if (v["canDrop"]) then
            for ie,ve in ipairs(v["tiers"]) do
                table.insert(enchantsTable, (i.." - "..ie.." | "..ve["title"]))
            end
        end
    end

    for i,v in ipairs(enchantsTable) do
        EnchantSection:Toggle(v, enchantArrayFind(getgenv().settings.machines.selectedEnchants, {
            ["Enchant"] = string.split((string.split(v, " | ")[1]), " - ")[1],
            ["Enchant Number"] = string.split((string.split(v, " | ")[1]), " - ")[2]
        }), function(bool)
            splitEnch = string.split((string.split(v, " | ")[1]), " - ")
            tempTable = {
                ["Enchant"] = splitEnch[1],
                ["Enchant Number"] = splitEnch[2]
            }
            if bool then
                if not enchantArrayFind(getgenv().settings.machines.selectedEnchants, tempTable) then
                    table.insert(getgenv().settings.machines.selectedEnchants, tempTable)
                end
            else
                enchantArrayRemove(getgenv().settings.machines.selectedEnchants, tempTable)
            end
        end)
    end



    --Gold
    GoldSection:Label("Name Pets Ignore To Ignore Them")
    GoldSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.goldMythicals, function(isToggled)
        getgenv().settings.machines.goldMythicals = isToggled
    end)
    GoldSection:Toggle("Auto Make Pets Gold", false, function(isToggled)
        tempSettings.machines.goldEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.machines.goldEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.goldMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if not (petRarity.g or petRarity.r or petRarity.dm) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.goldAmount) then
                            petsToGold = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToGold == (getgenv().settings.machines.goldAmount)) then
                                    table.insert(petsToGold, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("use golden machine", petsToGold)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)
    GoldSection:DropDown(getgenv().settings.machines.goldString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.goldAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.goldString = option
    end)


    --Auto Rainbow
    RainbowSection:Label("Name Pets Ignore To Ignore Them")
    RainbowSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.rainbowMythicals, function(isToggled)
        getgenv().settings.machines.rainbowMythicals = isToggled
    end)

    RainbowSection:Toggle("Auto Make Pets Rainbow", false, function(isToggled)
        tempSettings.machines.rainbowEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.machines.rainbowEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.rainbowMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if (petRarity.g) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.rainbowAmount) then
                            petsToRainbow = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToRainbow == (getgenv().settings.machines.rainbowAmount)) then
                                    table.insert(petsToRainbow, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("use rainbow machine", petsToRainbow)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)

    RainbowSection:DropDown(getgenv().settings.machines.rainbowString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.rainbowAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.rainbowString = option
    end)

    --Collection
    ColletionSection:Label("Settings")

    ColletionSection:Toggle("Triple Hatch", getgenv().settings.colection.trippleHatch, function(isToggled)
        getgenv().settings.colection.trippleHatch = isToggled
    end)

    ColletionSection:Toggle("Skip Egg Animation", getgenv().settings.autoEggs.skipAnimation, function(isToggled)
        if isToggled then
            getgenv().settings.autoEggs.skipAnimation = true
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = true
        else
            getgenv().settings.autoEggs.skipAnimation = false
            game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"].Disabled = false
        end
    end)

    ColletionSection:Toggle("Ignore Darkmatter Pet Index", getgenv().settings.colection.ignoreDarkMatter, function(isToggled)
        getgenv().settings.colection.ignoreDarkMatter = isToggled
    end)

    ColletionSection:Toggle("Ignore Rainbow Pet Index", getgenv().settings.colection.ignoreRainbow, function(isToggled)
        getgenv().settings.colection.ignoreRainbow = isToggled
    end)

    ColletionSection:Toggle("Ignore Gold Pet Index", getgenv().settings.colection.ignoreGold, function(isToggled)
        getgenv().settings.colection.ignoreGold = isToggled
    end)

    ColletionSection:Toggle("Ignore Normal Pet Index", getgenv().settings.colection.ignoreNormal, function(isToggled)
        getgenv().settings.colection.ignoreNormal = isToggled
    end)

    ColletionSection:Toggle("Ignore Mythical Pet Index", getgenv().settings.colection.ignoreMythicals, function(isToggled)
        getgenv().settings.colection.ignoreMythicals = isToggled
    end)

    ColletionSection:Label("Main")

    ColletionSection:Toggle("Delete Opened Pets That Are In Index", false, function(isToggled)
        tempSettings.colection.deleteEnabled = isToggled
        if isToggled then
            spawn(function()
                table.insert(allConnected, Lib.Network.Fired("Open Egg"):Connect(function(egg, openTable)
                    if tempSettings.colection.deleteEnabled then
                        save = Lib.Save.Get()

                        local deleteTable = {}
                        for i,v in ipairs(openTable) do
                            if (Lib.Directory.Pets[v.id]["rarity"] == "Mythical") then
                                continue
                            end
                            matched = false
                            if not (getgenv().settings.colection.ignoreDarkMatter) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 4) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreRainbow) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 3) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreGold) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 2) then
                                    matched = true
                                end
                            end

                            if not (getgenv().settings.colection.ignoreNormal) then
                                if Lib.Functions.SearchArray(save.Collection, v.id .. "-" .. 1) then
                                    matched = true
                                end
                            end

                            if (matched == true) then
                                table.insert(deleteTable, v.uid)
                            end
                        end
                        Lib.Network.Invoke("delete several pets", deleteTable)
                    else
                        return
                    end
                end))
            end)
        end
    end)

    ColletionSection:Toggle("Open Eggs That Isn't In Index", false, function(isToggled)
        tempSettings.colection.openEnabled = isToggled
        if isToggled then
            spawn(function()
                while tempSettings.colection.openEnabled do
                    print("Start")
                    collectablePets = Lib.Shared.GetAllCollectablePets()

                    for i,v in pairs(collectablePets) do
                        if not Lib.Shared.GetPetEgg(v.petId) then
                            collectablePets[i] = nil
                        end
                    end

                    for i,v in pairs(collectablePets) do
                        if tempSettings.colection.openEnabled then
                            local isRainbow = v["isRainbow"]
                            local isDarkMatter = v["isDarkMatter"]
                            if v["isGolden"] then
                                attribute = 2
                            elseif isRainbow then
                                attribute = 3
                            elseif isDarkMatter then
                                attribute = 4
                            else
                                attribute = 1
                            end;

                            if (getgenv().settings.colection.ignoreDarkMatter) then
                                if attribute == 4 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreRainbow) then
                                if attribute == 3 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreGold) then
                                if attribute == 2 then
                                    continue
                                end
                            end

                            if (getgenv().settings.colection.ignoreNormal) then
                                if attribute == 1 then
                                    continue
                                end
                            end

                            if getgenv().settings.colection.ignoreMythicals then
                                if (Lib.Directory.Pets[v.petId]["rarity"] == "Mythical") then
                                    continue
                                end
                            end
                            
                           
                            ownPet = Lib.Functions.SearchArray((Lib.Save.Get().Collection), v.petId .. "-" .. attribute)
                            inEgg = Lib.Shared.GetPetEgg(v.petId)
                            if inEgg then
                                if not ownPet then
                                    goldData = (Lib.Directory.Eggs[("Golden "..inEgg)])
                                    eggData = Lib.Directory.Eggs[inEgg]
                                    if goldData and  not (attribute == 1) then
                                        print(goldData, eggData, inEgg)
                                        if eggData.hatchable and (Lib.Save.Get()[(eggData.currency)] >= goldData.cost) then
                                            Lib.Network.Invoke("buy egg", ("Golden "..inEgg), getgenv().settings.colection.trippleHatch)
                                            Notify("Opening "..("Golden "..inEgg))
                                            wait(0.8)
                                        end
                                    else
                                        if eggData.hatchable and (Lib.Save.Get()[eggData.currency] >= eggData.cost) then
                                            Lib.Network.Invoke("buy egg", inEgg, getgenv().settings.colection.trippleHatch)
                                            Notify("Opening "..inEgg)
                                            wait(0.5)
                                        end
                                    end
                                end
                            end

                        end
                    end
                    print("Reached End")
                    wait()
                end
                return
            end)
        end
    end)




    --Dark Matter

    DarkMatterSection:Label("Name Pets Ignore To Ignore Them")
    DarkMatterSection:Toggle("Ignore Mytchical Pets", getgenv().settings.machines.dmMythicals, function(isToggled)
        getgenv().settings.machines.dmMythicals = isToggled
    end)
    DarkMatterSection:Toggle("Auto Make Pets Dark Matter", getgenv().settings.machines.dmEnabled, function(isToggled)
        getgenv().settings.machines.dmEnabled = isToggled
        if isToggled then
            spawn(function()
                while getgenv().settings.machines.dmEnabled do
                    save = Lib.Save.Get
                    getPetRarity = Lib.PetCmds.Get
                    petTable = {}
                    for i,v in pairs(save().Pets) do
                        if not ((v.nk:lower()) == "ignore") and not (v.e) and not (Lib.Directory.Pets[v.id].rarity == "Exclusive") then
                            if not ((getgenv().settings.machines.dmMythicals) and (Lib.Directory.Pets[v.id].rarity == "Mythical")) then
                                local petRarity = getPetRarity(v.uid)

                                if (petRarity.r) then
                                    if not petTable[v.id] then
                                        petTable[v.id] = {}
                                    end
                                    table.insert(petTable[v.id], v.uid)
                                end
                            end
                        end
                    end

                    for i,v in pairs(petTable) do
                        if(#v >= getgenv().settings.machines.dmAmount) then
                            petsToDM = {}
                            for ie,ve in ipairs(v) do
                                if not (#petsToDM == (getgenv().settings.machines.dmAmount)) then
                                    table.insert(petsToDM, ve)
                                else
                                    break
                                end
                            end
                            Lib.Network.Invoke("convert to dark matter", petsToDM)
                            wait(1.5)
                            break
                        end
                    end
                    wait()
                end
            end)
        end
    end)
    DarkMatterSection:Toggle("Auto Claim Dark Matter", getgenv().settings.machines.dmAutoClaim, function(bool)
        getgenv().settings.machines.dmAutoClaim = bool
        if bool then
            spawn(function()
                while getgenv().settings.machines.dmAutoClaim do
                    save = Lib.Save.Get()
                    for i,v in pairs(save["DarkMatterQueue"]) do
                        if (v["readyTime"] < os.time()) then
                            Lib.Network.Invoke("redeem dark matter pet", i)
                        end
                    end
                    wait(1)
                end
                return
            end)
        end
    end)
    DarkMatterSection:DropDown(getgenv().settings.machines.dmString, {"1 Pet, 13%", "2 Pets, 29%", "3 Pets, 47%", "4 Pets, 63%", "5 Pets, 88%", "6 Pets, 100%"}, function(option)
        getgenv().settings.machines.dmAmount = (tonumber(option:split(" ")[1]))
        getgenv().settings.machines.dmString = option
    end)

    --Fusing

    local petToFuse = ''
    local amountPetsFuse = 3
    local petRarity = "Normal"

    FuseSection:TextBox("Pet Name", "Pet Name", function(getText)
        petToFuse = getText
    end)

    FuseSection:DropDown("Pet Rarity",{"Normal", "Gold", "Rainbow", "Dark Matter"}, function(option)
        petRarity = option
    end)

    FuseSection:DropDown('Amount Of Pets To Fuse', {
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12'
    }, function(option)
        amountPetsFuse = tonumber(option)
    end)

    --Im lazy, adding code from 2.0

    FuseSection:Toggle("Auto Fuse", false, function(bool)
        tempSettings.machines.autoFuse = bool
        if bool then
            spawn(function()
                while tempSettings.machines.autoFuse do
                    petId = -1
                    for i,v in pairs(Lib.Directory.Pets) do
                        if (string.lower(v["name"]) == string.lower(petToFuse)) then
                            petId = i
                            break
                        end
                    end
                    if (petId == -1) then
                        spawn(function()
                            Lib.Message.New("Invalid Pet Name Did u Click Enter After Typing???")
                            return
                        end)
                        tempSettings.machines.autoFuse = false
                        return
                    end
                    local Pets = Lib.Save.Get().Pets
                    local selectedPets = {}
                    for i,v in ipairs(Pets) do
                        local petRarityTable = Lib.PetCmds.Get(v.uid)
                        if not (#selectedPets == amountPetsFuse) then
                            if (v.id == (tostring(petId))) then
                                if (petRarity == "Normal") and not (petRarityTable.r) and not (petRarityTable.g) and not (petRarityTable.dm) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Gold") and (petRarityTable.g) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Rainbow") and (petRarityTable.r) then
                                    table.insert(selectedPets, v.uid)
                                end
                                if (petRarity == "Dark Matter") and (petRarityTable.dm) then
                                    table.insert(selectedPets, v.uid)
                                end
                            end
                        else
                            break
                        end
                    end
                    if (#selectedPets == amountPetsFuse) then
                        Lib.Network.Invoke("fuse pets", selectedPets)
                    end
                    wait(1)
                end
                return
            end)
        end
    end)



    --Gold
    coroutine.wrap(function()
        currString1 = "Gold Machine"
        currInstance1 = game:GetService("Players").LocalPlayer.PlayerGui.Golden
        currSection1 = TabGUIs:Section(currString1)

        currSection1:Button(currString1, function()
            currInstance1.Enabled = true
        end)
        keycode = Enum.KeyCode.G
        if getgenv().settings.guis.keycodes[currString1] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString1]]
        end
        currSection1:KeyBind(currString1.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString1] = keycode
            currInstance1.Enabled = (not currInstance1.Enabled)
        end)
    end)()


    --Rainbow
    coroutine.wrap(function()
        currString2 = "Rainbow Machine"
        currInstance2 = game:GetService("Players").LocalPlayer.PlayerGui.Rainbow
        currSection2 = TabGUIs:Section(currString2)

        currSection2:Button(currString2, function()
            currInstance2.Enabled = true
        end)
        keycode = Enum.KeyCode.R
        if getgenv().settings.guis.keycodes[currString2] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString2]]
        end
        currSection2:KeyBind(currString2.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString2] = keycode
            currInstance2.Enabled = (not currInstance2.Enabled)
        end)
    end)()


    --Dark Matter
    coroutine.wrap(function()
        currStrin3 = "Dark Matter Machine"
        currInstance3 = game:GetService("Players").LocalPlayer.PlayerGui.DarkMatter
        currSection3 = TabGUIs:Section(currStrin3)

        currSection3:Button(currStrin3, function()
            currInstance3.Enabled = true
        end)
        keycode = Enum.KeyCode.T
        if getgenv().settings.guis.keycodes[currStrin3] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin3]]
        end
        currSection3:KeyBind(currStrin3.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin3] = keycode
            currInstance3.Enabled = (not currInstance3.Enabled)
        end)
    end)()

    --Fuse
    coroutine.wrap(function()
        currStrin4 = "Fuse Machine"
        currInstance4 = game:GetService("Players").LocalPlayer.PlayerGui.FusePets
        currSectio4 = TabGUIs:Section(currStrin4)

        currSectio4:Button(currStrin4, function()
            currInstance4.Enabled = true
        end)
        keycode = Enum.KeyCode.F
        if getgenv().settings.guis.keycodes[currStrin4] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin4]]
        end
        currSectio4:KeyBind(currStrin4.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin4] = keycode
            currInstance4.Enabled = (not currInstance4.Enabled)
        end)
    end)()

    --Fuse
    coroutine.wrap(function()
        currString5 = "Pet Collection"
        currInstance5 = game:GetService("Players").LocalPlayer.PlayerGui.Collection
        currSection5 = TabGUIs:Section(currString5)

        currSection5:Button(currString5, function()
            currInstance5.Enabled = true
        end)
        keycode = Enum.KeyCode.P
        if getgenv().settings.guis.keycodes[currString5] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString5]]
        end
        currSection5:KeyBind(currString5.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString5] = keycode
            currInstance5.Enabled = (not currInstance5.Enabled)
        end)
    end)()

    --Merchant
    coroutine.wrap(function()
        currStrin6 = "Merchant"
        currInstance6 = game:GetService("Players").LocalPlayer.PlayerGui.Merchant
        currSectio6 = TabGUIs:Section(currStrin6)

        currSectio6:Button(currStrin6, function()
            currInstance6.Enabled = true
        end)
        keycode = Enum.KeyCode.M
        if getgenv().settings.guis.keycodes[currStrin6] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currStrin6]]
        end
        currSectio6:KeyBind(currStrin6.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currStrin6] = keycode
            currInstance6.Enabled = (not currInstance6.Enabled)
        end)
    end)()


    --Bank
    coroutine.wrap(function()
        currString7 = "Bank"
        currInstance7 = game:GetService("Players").LocalPlayer.PlayerGui.Bank
        currSection7 = TabGUIs:Section(currString7)

        currSection7:Button(currString7, function()
            currInstance7.Enabled = true
        end)
        keycode = Enum.KeyCode.B
        if getgenv().settings.guis.keycodes[currString7] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString7]]
        end
        currSection7:KeyBind(currString7.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString7] = keycode
            currInstance7.Enabled = (not currInstance7.Enabled)
        end)
    end)()

    --Enchant
    coroutine.wrap(function()
        currString8 = "Enchant"
        currInstance8 = game:GetService("Players").LocalPlayer.PlayerGui.EnchantPets
        currSection8 = TabGUIs:Section(currString8)

        currSection8:Button(currString8, function()
            currInstance8.Enabled = true
        end)
        keycode = Enum.KeyCode.E
        if getgenv().settings.guis.keycodes[currString8] then
            keycode = Enum.KeyCode[getgenv().settings.guis.keycodes[currString8]]
        end
        currSection8:KeyBind(currString8.." Key Bind", keycode, function(keycode)
            getgenv().settings.guis.keycodes[currString8] = keycode
            currInstance8.Enabled = (not currInstance8.Enabled)
        end)
    end)()
    diffTime = (tick() - startTime)
    wait()
    Lib.Signal.Fire("Notification", "Script Took "..(string.format("%0.2f", diffTime)).."s To Fully Load", {
        color = Color3.fromRGB(255, 46, 154)
    })
end
loadstring(game:HttpGet("https://pastebin.com/raw/7pxae3p4"))()
createUILibrary()
