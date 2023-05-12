registered = {}

AddEventHandler("onClientResourceStart", function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
	local table = lib.callback.await("vehicleRentals:getRegisteredVehicles")
	if not next(table) then
		return
	end
	for k, v in pairs(table) do
		registered[k] = {
			source = GetPlayerServerId(PlayerId()),
		}
	end
end)

RegisterNetEvent("vehicle:return", function(data)
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
    local result = lib.callback.await("vehicleRentals:vehicleReturn", false, returnData)
    if not result then
        return ESX.ShowNotification(labelText("err"), "error")
    end

    local coords = data.coords
    if type(coords) == "vector4" then
        if IsThisModelABoat(GetEntityModel(vehicle)) then
            SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
            SetEntityHeading(playerPed, coords.w)
        else
            TaskLeaveVehicle(cache.ped, vehicle, 0)
            Wait(1400)
        end
    end
    DeleteEntity(vehicle)
end)

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(100)
    end

    local allvehicle = {}
    local inserted = {}

    for i = 1, #Config.location do
        local coords = Config.location[i].menu
        local point = lib.points.new({
            coords = coords,
            distance = Config.location[i].distance
        })
        local ped
        local options = {
            {
                name = "vehicle_rent_"..i,
                icon = "fa-solid fa-rectangle-list",
                label = labelText("rent"),
                distance = 1.5,
                onSelect = function()
                    openMenu(i)
                end,
                canInteract = function(entity, distance, targetcoords, name, bone)
                    return #(targetcoords - vector3(coords.x, coords.y, coords.z)) <= 2.0
                end,
            },
        }

        for n = 1, #Config.location[i].vehicle do
            if not inserted[Config.location[i].vehicle[n].model] then
                allvehicle[#allvehicle+1] = Config.location[i].vehicle[n].model
                inserted[Config.location[i].vehicle[n].model] = true
            end
        end

        if Config.location[i].blip then
            local prop = Config.location[i].blip
            local blip = AddBlipForCoord(coords)
            SetBlipScale(blip, prop.scale)
            SetBlipDisplay(blip, 4)
            SetBlipSprite(blip, prop.sprite)
            SetBlipColour(blip, prop.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(prop.label)
            EndTextCommandSetBlipName(blip)
        end

        
        if Config.target and Config.location[i].ped then
            local model = type(Config.location[i].ped.model) == "number" and Config.location[i].ped.model or joaat(Config.location[i].ped.model)
            if not HasModelLoaded(model) then
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait()
                end
            end
            exports["ox_target"]:addModel(model, options)

            function point:onEnter()
                if ped == nil or not DoesEntityExist(ped) then
                    ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                end
            end

            function point:onExit()
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end

            local textUI, content
            function point:nearby()
                local inVeh = GetVehiclePedIsIn(cache.ped) ~= 0
                local text = inVeh and labelText("return_vehicle") or labelText("rent")
                local style = inVeh and {icon = "e"} or {icon = "eye"}
                local distance = inVeh and 15.0 or 2.0
                if self.isClosest and self.currentDistance < distance then
                    if not textUI or content ~= inVeh then
                        textUI = true
                        content = inVeh
                        lib.showTextUI(text, style)
                    end
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("vehicle:return", { coords = coords })
                        Wait(1000)
                    end
                else
                    if textUI then
                        textUI = false
                        lib.hideTextUI()
                    end
                end
            end
        elseif Config.location[i].marker then
            local textUI, content
            function point:nearby()
                local inVeh = GetVehiclePedIsIn(cache.ped) ~= 0
                local text = inVeh and labelText("return_vehicle") or labelText("rent")
                local style = {icon = "e"}
                local distance = inVeh and 15.0 or 2.0
                if self.isClosest and self.currentDistance < distance then
                    if not textUI or content ~= inVeh then
                        textUI = true
                        lib.showTextUI(text, style)
                    end
                    if IsControlJustPressed(0, 38) then
                        if inVeh then
                            TriggerEvent("vehicle:return", { coords = coords })
                        else
                            openMenu(i)
                        end
                        Wait(1000)
                    end
                else
                    if textUI then
                        textUI = false
                        lib.hideTextUI()
                    end
                end
                DrawMarker(Config.location[i].marker.type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.location[i].marker.scale, Config.location[i].marker.scale, Config.location[i].marker.scale, 200, 20, 20, 150, false, true, 2, false, nil, nil, false)
            end
        end
    end

    if Config.target then
        local vehicle_options = {
            {
                name = "vehicle_return_",
                event = "vehicle:return",
                icon = "fa-solid fa-rotate-left",
                label = labelText("return_vehicle"),
                distance = 2.0,
                canInteract = function(entity, distance, coords, name, bone)
                    local plate = GetVehicleNumberPlateText(entity)
                    return registered[plate] ~= nil
                end,
            },
        }
        exports["ox_target"]:addModel(allvehicle, vehicle_options)
    end
end)