--- Script made by HiHowdy
--- Script converted from ESX to vRP by ReanCoding
--https://github.com/ReanCoding--

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","onyxLocksystem")

RegisterServerEvent('onyx:updateSearchedVehTable')
AddEventHandler('onyx:updateSearchedVehTable', function(plate)
    local _source = source
    local vehPlate = plate
    TriggerClientEvent('onyx:returnSearchedVehTable', -1, vehPlate)
end)

RegisterServerEvent('onyx:reqHotwiring')
AddEventHandler('onyx:reqHotwiring', function(plate)
    local source = source
    local user_id = vRP.getUserId({source})
        if vRP.tryGetInventoryItem({user_id,"lockpick",1,false}) then --here check if you have item  
        TriggerClientEvent('onyx:beginHotwire', source, plate)
        local rnd = math.random(1, 25)
        if rnd == 20 then
            if vRP.tryGetInventoryItem({user_id,"lockpick",1,true}) then --here check if you have item  
            TriggerEvent("pNotify:SendNotification",{text = "Your lockpick has broken",type = "error",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    else
        TriggerEvent("pNotify:SendNotification",{text = "You have no lockpicks",type = "error",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
    end
end
end)