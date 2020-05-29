--- Script made by HiHowdy
--- Script converted from ESX to vRP by ReanCoding
--https://github.com/ReanCoding--

vRPLS = {}
Tunnel.bindInterface("onyxLocksystem",vRPLS)
Proxy.addInterface("onyxLocksystem",vRPLS)
PMserver = Tunnel.getInterface("onyxLocksystem","onyxLocksystem")
vRPserver = Tunnel.getInterface("vRP","onyxLocksystem")
vRP = Proxy.getInterface("vRP")


local vehicles = {}
local searchedVehicles = {}
local pickedVehicled = {}
local hasCheckedOwnedVehs = false
local lockDisable = false

function givePlayerKeys(plate)
    local vehPlate = plate
    table.insert(vehicles, vehPlate)
    print('gave player keys: ' .. plate)
end

function hasToggledLock()
    lockDisable = true
    Wait(100)
    lockDisable = false
end

function playLockAnim(vehicle)
    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)

    local veh = vehicle

    while not HasAnimDictLoaded do
        Citizen.Wait(0)
    end

    if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
        TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
    end
end

function toggleLock(vehicle)
    local veh = vehicle

    local plate = GetVehicleNumberPlateText(veh)
    local lockStatus = GetVehicleDoorLockStatus(veh)
    if hasKeys(plate) and not lockDisable then
        print('lock status: ' .. lockStatus)
        if lockStatus == 1 then
            SetVehicleDoorsLocked(veh, 2)
            SetVehicleDoorsLockedForAllPlayers(veh, true)
            TriggerEvent("pNotify:SendNotification",{text = "Vehicle Locked",type = "info",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
            playLockAnim()
            hasToggledLock()
        elseif lockStatus == 2 then
            SetVehicleDoorsLocked(veh, 1)
            SetVehicleDoorsLockedForAllPlayers(veh, false)
            TriggerEvent("pNotify:SendNotification",{text = "Vehicle Unlocked",type = "info",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
            playLockAnim(veh)
            hasToggledLock()
        else
            SetVehicleDoorsLocked(veh, 2)
            SetVehicleDoorsLockedForAllPlayers(veh, true)
            TriggerEvent("pNotify:SendNotification",{text = "Vehicle Locked",type = "info",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
            playLockAnim()
            hasToggledLock()
        end
        if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
            Wait(500)
            local flickers = 0
            while flickers < 2 do
                SetVehicleLights(veh, 2)
                Wait(170)
                SetVehicleLights(veh, 0)
                flickers = flickers + 1
                Wait(170)
            end
        end
    end
end

RegisterNetEvent('onyx:pickDoor')
AddEventHandler('onyx:pickDoor', function()
    -- TODO: Lockpicking vehicle doors to gain access
end)

-- Locking vehicles
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if IsControlJustReleased(0, 303) then
            if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                toggleLock(veh)
            else
                local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 3.0, 0, 70)
                if DoesEntityExist(veh) then
                    toggleLock(veh)
                end
            end
        end
    end
end)

local isSearching = false
local isHotwiring = false

-- Has entered vehicle without keys
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped)
            local driver = GetPedInVehicleSeat(veh, -1)
            local plate = GetVehicleNumberPlateText(veh)
            if driver == ped then
                if not hasKeys(plate) and not isHotwiring and not isSearching then
                    local pos = GetEntityCoords(ped)
                    if hasBeenSearched(plate) then
                        DrawText3Ds(pos.x, pos.y, pos.z + 0.2, 'Press ~y~[H] ~w~to hotwire')
                    else
                        DrawText3Ds(pos.x, pos.y, pos.z + 0.2, 'Press ~y~[H] ~w~to hotwire or ~g~[G] ~w~to search')
                    end
                    SetVehicleEngineOn(veh, false, true, true)
                    -- Searching
                    if IsControlJustReleased(0, 47) and not isSearching and not hasBeenSearched(plate) then -- G
                        if hasBeenSearched(plate) then
                            isSearching = true
                            Citizen.Wait(5000)
                            isSearching = false
                            TriggerEvent("pNotify:SendNotification",{text = "You search the vehicle and find nothing.",type = "error",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
                        else
                            local rnd = math.random(1, 8)
                            if rnd == 4 then
                                isSearching = true
                                Citizen.Wait(3000)
                                isSearching = false
                               TriggerEvent("pNotify:SendNotification",{text = "You found the keys for plate [" .. plate .. "]",type = "error",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
                                table.insert(vehicles, plate)
                                TriggerServerEvent('onyx:updateSearchedVehTable', plate)
                                table.insert(searchedVehicles, plate)
                            else
                                isSearching = true
                                Citizen.Wait(3000)
                                isSearching = false
                                TriggerEvent("pNotify:SendNotification",{text = "You search the vehicle and find nothing.",type = "error",timeout = (5000),layout = "centerLeft",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})

                                -- Update veh table so other players cant search the same vehicle
                                TriggerServerEvent('onyx:updateSearchedVehTable', plate)
                                table.insert(searchedVehicles, plate)
                            end
                        end
                    end
                    -- Hotwiring
                    if IsControlJustReleased(0, 74) and not isHotwiring then -- E
                        TriggerServerEvent('onyx:reqHotwiring', plate)
                    end
                else
                    SetVehicleEngineOn(veh, true, true, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isHotwiring then
            DisableControlAction(0, 75, true)  -- Disable exit vehicle
            DisableControlAction(0, 74, true)  -- Lights
        end
    end
end)

RegisterNetEvent('onyx:updatePlates')
AddEventHandler('onyx:updatePlates', function(plate)
    table.insert(vehicles, plate)
end)

RegisterNetEvent('onyx:beginHotwire')
AddEventHandler('onyx:beginHotwire', function(plate)
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    RequestAnimDict("veh@std@ds@base")

    while not HasAnimDictLoaded("veh@std@ds@base") do
        Citizen.Wait(100)
	end
    local time = 12500 -- in ms

    local vehPlate = plate
    isHotwiring = true

    SetVehicleEngineOn(veh, false, true, true)

    SetVehicleLights(veh, 0)
    
    local alarmChance = math.random(1, 10)

    if alarmChance == 9 then
        SetVehicleAlarm(veh, true)
        StartVehicleAlarm(veh)
    end

    exports['progressBars']:startUI(time, "Hotwiring [Stage 1]")
    TaskPlayAnim(PlayerPedId(), "veh@std@ds@base", "hotwire", 8.0, 8.0, -1, 1, 0.3, true, true, true)
    Citizen.Wait(time)
    Wait(1000)
    exports['progressBars']:startUI(time, "Hotwiring [Stage 2]")
    TaskPlayAnim(PlayerPedId(), "veh@std@ds@base", "hotwire", 8.0, 8.0, -1, 1, 0.6, true, true, true)
    Citizen.Wait(time)
    Wait(1000)
    exports['progressBars']:startUI(time, "Hotwiring [Stage 3]")
    TaskPlayAnim(PlayerPedId(), "veh@std@ds@base", "hotwire", 8.0, 8.0, -1, 1, 0.4, true, true, true)
    Citizen.Wait(time)
    Wait(1000)
    table.insert(vehicles, vehPlate)
    StopAnimTask(PlayerPedId(), 'veh@std@ds@base', 'hotwire', 1.0)
    isHotwiring = false
    SetVehicleEngineOn(veh, true, true, false)
end)


RegisterNetEvent('onyx:returnSearchedVehTable')
AddEventHandler('onyx:returnSearchedVehTable', function(plate)
    local vehPlate = plate
    table.insert(searchedVehicles, vehPlate)
end)

function hasBeenSearched(plate)
    local vehPlate = plate
    for k, v in ipairs(searchedVehicles) do
        if v == vehPlate then
            return true
        end
    end
    return false
end

function hasKeys(plate)
    local vehPlate = plate
    for k, v in ipairs(vehicles) do
        if v == vehPlate or v == vehPlate .. ' ' then
            return true
        end
    end
    return false
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 370
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
end