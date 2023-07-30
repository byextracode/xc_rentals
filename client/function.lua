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
        local carlabel = GetLabelText(carname)
        local vehicleName = carlabel ~= "NULL" and carlabel or carname
        local seats = GetVehicleModelNumberOfSeats(model)
        options[#options+1] = {
            title = (#options+1).." - "..vehicleName,
            description = labelText("caution", comma_value(vehicleList[i].fee)),
            image = vehicleList[i].image,
            metadata = vehicleList[i].image and { labelText("seat", seats) } or { labelText("no_preview"), labelText("seat", seats) },
            onSelect = function()
                local data = {
                    index = vehicleList[i].index,
                    modelIndex = vehicleList[i].modelIndex
                }
                local money = lib.callback.await("vehicleRentals:checkMoney", false, data)
                if type(money) == "string" then
                    lib.notify({
                        title = labelText("err"),
                        description = money,
                        position = 'top',
                        style = {
                            backgroundColor = '#141517',
                            color = '#909296'
                        },
                        icon = 'ban',
                        iconColor = '#C53030'
                    })
                    return
                end
                if not money then
                    lib.notify({
                        title = labelText("err"),
                        description = labelText("not_enough_money"),
                        position = 'top',
                        style = {
                            backgroundColor = '#141517',
                            color = '#909296'
                        },
                        icon = 'ban',
                        iconColor = '#C53030'
                    })
                    return
                end

                local result, plate = lib.callback.await("vehicleRentals:spawnRequest", false, data)
                if type(result) == "string" then
                    lib.notify({
                        title = labelText("err"),
                        description = result,
                        position = 'top',
                        style = {
                            backgroundColor = '#141517',
                            color = '#909296'
                        },
                        icon = 'ban',
                        iconColor = '#C53030'
                    })
                    return
                end

                local coords = Config.location[index].spawn
                local vehicle = spawnVehicle(model, coords)
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