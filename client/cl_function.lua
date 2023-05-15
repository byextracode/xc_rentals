function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function labelText(text, ...)
    local library = Config.translation[Config.Locale]
    if library == nil then
        return ("Translation [%s] does not exist"):format(Config.Locale)
    end
    if library[text] == nil then
        return ("Translation [%s][%s] does not exist"):format(Config.Locale, text)
    end
    return library[text]:format(...) 
end

function isAuthorized(authorizedJob)
    while ESX == nil do
        Wait()
    end
    while not ESX.PlayerLoaded do
        Wait()
    end
    if type(authorizedJob) ~= "table" then
        authorizedJob = {authorizedJob}
    end
    local tabletype = table.type(authorizedJob)
    if tabletype == "hash" then
        local grade = authorizedJob[ESX.PlayerData.job.name]
        if grade and grade <= ESX.PlayerData.job.grade then
            return true
        end
    end
    if tabletype == "mixed" then
        if authorizedJob[ESX.PlayerData.job.name] then
            return authorizedJob[ESX.PlayerData.job.name] <= ESX.PlayerData.job.grade
        end
        for index, value in pairs(authorizedJob) do
            if value == ESX.PlayerData.job.name then
                return true
            end
        end
    end
    if tabletype == "array" then
        for i = 1, #authorizedJob do
            if ESX.PlayerData.job.name == authorizedJob[i] then
                return true
            end
        end
    end
    return false
end

function openMenu(index)
    local vehicleList = {}
    local library = Config.location[index]
    for i = 1, #library.vehicle do
        if library.vehicle[i].job then
            if isAuthorized(library.vehicle[i].job) then
                vehicleList[#vehicleList+1] = {
                    index = index,
                    model = library.vehicle[i].model,
                    modelIndex = i,
                    fee = library.vehicle[i].fee,
                    image = library.vehicle[i].image
                }
            end
        else
            vehicleList[#vehicleList+1] = {
                index = index,
                model = library.vehicle[i].model,
                modelIndex = i,
                fee = library.vehicle[i].fee,
                image = library.vehicle[i].image
            }
        end
    end
    
    local options = {}
    for i = 1, #vehicleList do
        local model = joaat(vehicleList[i].model)
        local carname = GetDisplayNameFromVehicleModel(model)
        local vehicleName = GetLabelText(carname)
        local seats = GetVehicleModelNumberOfSeats(model)
        options[#options+1] = {
            title = (#options+1).." - "..vehicleName,
            description = labelText("caution", comma_value(vehicleList[i].fee)),
            image = vehicleList[i].image,
            metadata = vehicleList[i].image and { ("Seats: %s"):format(seats) } or { "No preview", ("Seats: %s"):format(seats) },
            onSelect = function()
                local data = {
                    index = vehicleList[i].index,
                    modelIndex = vehicleList[i].modelIndex
                }
                local money = lib.callback.await("vehicleRentals:checkMoney", false, data)
                if type(money) == "string" then
                    return ESX.ShowNotification(money, "error")
                end
                if not money then
                    return ESX.ShowNotification(labelText("not_enough_money"), "error")
                end

                local result, plate = lib.callback.await("vehicleRentals:spawnRequest", false, data)
                if type(result) == "string" then
                    return ESX.ShowNotification(result, "error")
                end

                local entity = promise:new()
                local coords = Config.location[index].spawn
                ESX.Game.SpawnVehicle(model, coords, coords.w, function(veh)
                    entity:resolve(veh)
                end, true)

                local vehicle = Citizen.Await(entity)
                TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
                SetVehicleNumberPlateText(vehicle, plate)
                SetVehicleFuelLevel(vehicle, 100.0)
                registered[plate] = true
            end
        }
    end

    lib.registerContext({
        id = "vehicle_rental",
        title = labelText("rent"),
        options = options
    })
    
    lib.showContext("vehicle_rental")
end