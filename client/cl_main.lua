local registered = {}

AddEventHandler("onClientResourceStart", function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
	local table = lib.callback.await("boatRentals:getRegisteredVehicles")
	if not next(table) then
		return
	end
	for k, v in pairs(table) do
		registered[k] = {
			source = GetPlayerServerId(PlayerId()),
		}
	end
end)

RegisterNetEvent("boat:return", function(data)
    local playerPed = PlayerPedId()
    local vehicle = data.entity or GetVehiclePedIsIn(playerPed)
    if vehicle == 0 then
        return
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    if not registered[plate] then
        return ESX.ShowNotification(labelText("someone_veh"), "error")
    end
    local returnData = {
        plate = plate
    }
    local result = lib.callback.await("boatRentals:vehicleReturn", false, returnData)
    if not result then
        return ESX.ShowNotification(labelText("err"), "error")
    end
    DeleteEntity(vehicle)
    local coords = data.coords
    if type(coords) == "vector3" then
        return
    end
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    SetEntityHeading(playerPed, coords.w)
end)

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(100)
    end

    local function openMenu(spawnIndex)
        local boatList = {}
        for i = 1, #Config.boat do
            if Config.boat[i].job then
                if isAuthorized(Config.boat[i].job) then
                    for n = 1, #Config.boat[i].model do
                        boatList[#boatList+1] = {
                            spawnIndex = spawnIndex,
                            model = Config.boat[i].model[n],
                            modelIndex = n,
                            boatIndex = i
                        }
                    end
                end
            else
                for n = 1, #Config.boat[i].model do
                    boatList[#boatList+1] = {
                        spawnIndex = spawnIndex,
                        model = Config.boat[i].model[n],
                        modelIndex = n,
                        boatIndex = i
                    }
                end
            end
        end
        
        local options = {}
        for i = 1, #boatList do
            local model = joaat(boatList[i].model)                         
            local carname = GetDisplayNameFromVehicleModel(model)
            local vehicleName = GetLabelText(carname)   
            options[#options+1] = {
                title = vehicleName,
                description = labelText("caution", comma_value(Config.caution)),
                onSelect = function()
                    local money = lib.callback.await("boatRentals:checkMoney")
                    if type(money) == "string" then
                        return ESX.ShowNotification(money, "error")
                    end
                    if not money then
                        return ESX.ShowNotification(labelText("not_enough_money"), "error")
                    end
                    local data = {
                        spawnIndex = boatList[i].spawnIndex,
                        modelIndex = boatList[i].modelIndex,
                        boatIndex = boatList[i].boatIndex
                    }
                    local result, plate = lib.callback.await("boatRentals:spawnRequest", false, data)
                    if type(result) == "string" then
                        return ESX.ShowNotification(result, "error")
                    end
                    local entity = promise:new()
                    local coords = Config.spawn[data.spawnIndex]
                    ESX.Game.SpawnVehicle(model, coords, coords.w, function(veh)
                        entity:resolve(veh)
                    end, true)
                    local vehicle = Citizen.Await(entity)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    SetVehicleNumberPlateText(vehicle, plate)
                    SetVehicleFuelLevel(vehicle, 100.0)
                    registered[plate] = true
                end
            }
        end

        lib.registerContext({
            id = "boat_rental",
            title = labelText("rent"),
            options = options
        })

        if lib.showContext == nil then
            lib.showContext = function(...)
                return exports["ox_lib"]:showContext(...)
            end
        end
        
        lib.showContext("boat_rental")
    end


    if Config.blip?.enable then
        for i = 1, #Config.menu do
            local v = Config.menu[i]
            local prop = Config.blip
            local coords = vec3(v.x, v.y, v.z)
            local blip = AddBlipForCoord(coords)
            SetBlipScale(blip, prop.scale)
            SetBlipDisplay(blip, 4)
            SetBlipSprite(blip, prop.sprite)
            SetBlipColour(blip, prop.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(labelText("blip_label"))
            EndTextCommandSetBlipName(blip)
        end
    end

    if Config.ped?.enable then
        local model = type(Config.ped?.model) == "number" and Config.ped?.model or joaat(Config.ped?.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait()
        end
        
        for i = 1, #Config.menu do
            local coords = Config.menu[i]
            local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            CreateThread(function()
                local textUI
                while true do
                    local wait = 1000
                    local playerPed = PlayerPedId()
                    local inArea = #(GetEntityCoords(playerPed) - vector3(coords.x, coords.y, coords.z)) <= 2.0
                    if inArea and not IsPedInAnyVehicle(PlayerPedId()) then
                        if not textUI then
                            textUI = true
                            lib.showTextUI(labelText("rent"), {icon = "eye"})
                        end
                    else
                        if textUI then
                            textUI = false
                            lib.hideTextUI()
                        end
                    end
                    Wait(wait)
                end
            end)
        end

        local options = {
            {
                name = "boat_rent_",
                icon = "fa-solid fa-tags",
                label = labelText("rent"),
                distance = 2.0,
                onSelect = function()
                    local spawnIndex = 0
                    for i = 1, #Config.menu do
                        local coords = Config.menu[i]
                        if #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z)) <= 2.0 then
                            spawnIndex = i
                            break
                        end
                    end
                    openMenu(spawnIndex)
                end,
                canInteract = function(entity, distance, coords, name, bone)
                    local status = false
                    for i = 1, #Config.menu do
                        local coords = Config.menu[i]
                        if #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z)) <= 2.0 then
                            status = true
                            break
                        end
                    end
                    return status
                end,
            },
        }
        exports["ox_target"]:addModel(model, options)

        local allboat = {}
        for i = 1, #Config.boat do
            for n = 1, #Config.boat[i].model do
                allboat[#allboat+1] = Config.boat[i].model[n]
            end
        end
        local vehicle_options = {
            {
                name = "boat_return",
                event = "boat:return",
                icon = "fa-solid fa-sailboat",
                label = labelText("return_vehicle"),
                distance = 2.0,
                canInteract = function(entity, distance, coords, name, bone)
                    local plate = GetVehicleNumberPlateText(entity)
                    local status = false
                    for i = 1, #Config.menu do
                        local coords = Config.menu[i]
                        if #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z)) <= 15.0 then
                            status = true
                            break
                        end
                    end
                    return registered[plate] ~= nil and status
                end,
            },
        }
        
        exports["ox_target"]:addModel(allboat, vehicle_options)
    end
end)