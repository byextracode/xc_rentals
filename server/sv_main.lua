local registered = {}

lib.callback.register("vehicleRentals:checkMoney", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return "error"
    end
    if data?.index == nil then
        return "error #2"
    end
    if data?.modelIndex == nil then
        return "error #3"
    end
    if Config.location[data.index] == nil then
        return "error #4"
    end
    if Config.location[data.index].vehicle[data.modelIndex] == nil then
        return "error #5"
    end
    local fee = Config.location[data.index].vehicle[data.modelIndex].fee
    return xPlayer.getMoney() >= fee
end)

lib.callback.register("vehicleRentals:spawnRequest", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return "error #1"
    end
    if data?.index == nil then
        return "error #2"
    end
    if data?.modelIndex == nil then
        return "error #3"
    end
    if Config.location[data.index] == nil then
        return "error #4"
    end
    if Config.location[data.index].vehicle[data.modelIndex] == nil then
        return "error #5"
    end

    local fee = Config.location[data.index].vehicle[data.modelIndex].fee
    if xPlayer.getMoney() < fee then
        return "error #6"
    end

    local plate = ("RENT %s"):format(math.random(100, 999))
    while registered[plate] ~= nil do
		plate = ("RENT %s"):format(math.random(100, 999))
	end
    registered[plate] = {
        identifier = xPlayer.identifier
    }
    xPlayer.removeMoney(fee)
    return true, plate
end)

lib.callback.register("vehicleRentals:vehicleReturn", function(source, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return false
	end

	local plate = data?.plate
    if plate == nil then
        return false
    end

    local vehicle = registered[plate]
	if not vehicle then
		return false
	end
	if vehicle.identifier ~= xPlayer.identifier then
		return false
	end

	registered[plate] = nil
	return true
end)

lib.callback.register("vehicleRentals:getRegisteredVehicles", function(source)
    local vehicles = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return vehicles
    end
    for k, v in pairs(registered) do
        if v.identifier == xPlayer.identifier then
            vehicles[k] = true
        end
    end
    return vehicles
end)