--[[

Credits to the rightful owner of this script, Gerard.

]]--


local library = loadstring(game:HttpGet('https://pastebin.com/raw/T3tvmaz4'))()

local EggsWindow = library:CreateWindow("Eggs")


local CurrencyOrder = {"Rainbow Coins", "Tech Coins", "Fantasy Coins", "Coins", "Diamonds",}


workspace.__THINGS.__REMOTES.MAIN:FireServer("b", "buy egg")


local MyEggData = {}
local littleuselesstable = {}
local GameLibrary = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("Library"))
for i,v in pairs(GameLibrary.Directory.Eggs) do
    local temptable = {}
    temptable['Name'] = i
    temptable['Currency'] = v.currency
    temptable['Price'] = v.cost
    table.insert(MyEggData, temptable)
end

table.sort(MyEggData, function(a, b)
    return a.Price < b.Price
end)

local EggData = {}
for i,v in pairs(CurrencyOrder) do
    table.insert(EggData, " ")
    table.insert(EggData, "-- "..v.." --")
    for a,b in pairs(MyEggData) do
        if b.Currency == v then
            table.insert(EggData, b.Name)
        end
    end
end

EggsWindow:Toggle("Open Eggs", {flag = 'OpenEggs'}, function(new)
    while wait() and EggsWindow.flags.OpenEggs do
        local ohTable1 = {
            [1] = EggsWindow.flags.SelectedEgg,
            [2] = EggsWindow.flags.TripleEggs
        }
        workspace.__THINGS.__REMOTES["buy egg"]:InvokeServer(ohTable1)
    end
end)
EggsWindow:Dropdown('Egg', {flag = 'SelectedEgg', list = EggData})
EggsWindow:Toggle("Triple Eggs", {flag = 'TripleEggs'})
EggsWindow:Section(" ")
EggsWindow:Button("Remove Egg animation", function()
    for i,v in pairs(getgc(true)) do
        if (typeof(v) == 'table' and rawget(v, 'OpenEgg')) then
            v.OpenEgg = function()
                return
            end
        end
    end
end)

while true do
local notif = game:GetService("Players").LocalPlayer.PlayerGui
if notif.Main.Bottom.Inventory.Notification.Count.text > "245" then do
    notif.Inventory.Enabled = true
    task.wait(1)
    notif.Inventory.Enabled = false
end
end
task.wait(120)
end

local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do game:GetService("RunService").Heartbeat:Wait() end
local mt = getrawmetatable(game)
local oldnamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...) local pain = {...} if string.match(string.lower(tostring(self)), "invite to bank") then Lib.Message.New("[WARNING]\nSomebody was just invited to your bank\n\nIf this was not you, cancel outgoing invites immediately") return {} end return oldnamecall(self, ...) end)
Lib.Message.New("Bank logger security initiated.")
setreadonly(mt, true)
