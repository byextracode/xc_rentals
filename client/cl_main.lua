registered = {}

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
    local playerPed = cache.ped
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
    lib.hideTextUI()
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
                return registered[plate] ~= nil
            end,
        },
    }

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
            local rental = lib.points.new({
                coords = coords,
                distance = 50.0
            })
            local options = {
                {
                    name = "boat_rent_",
                    icon = "fa-solid fa-tags",
                    label = labelText("rent"),
                    distance = 1.5,
                    onSelect = function()
                        openMenu(i)
                    end
                },
            }

            function rental:onEnter()
                if not DoesEntityExist(ped) then
                    ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                end
                exports["ox_target"]:addModel(model, options)
                exports["ox_target"]:addModel(allboat, vehicle_options)
            end

            function rental:onExit()
                if textUI then
                    textUI = false
                    lib.hideTextUI()
                end
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
                exports["ox_target"]:removeModel(model, options.name)
                exports["ox_target"]:removeModel(allboat, vehicle_options.name)
            end
            
            function rental:nearby()
                local wait = 1000
                local inArea = self.currentDistance < 5.0
                local inVeh = GetVehiclePedIsIn(cache.ped) ~= 0
                local text = inVeh and labelText("return_vehicle") or labelText("rent")
                local style = inVeh and {icon = "e"} or {icon = "eye"}
                if inArea then
                    wait = 0
                    if not textUI then
                        textUI = true
                        lib.showTextUI(text, style)
                    end
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("boat:return", { coords = coords })
                    end
                else
                    if textUI then
                        textUI = false
                        lib.hideTextUI()
                    end
                end
                Wait(wait)
            end
        end
    end
end)