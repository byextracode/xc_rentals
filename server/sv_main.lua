local registered = {}

lib.callback.register("boatRentals:checkMoney", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return "error"
    end
    return xPlayer.getMoney() >= Config.caution
end)

lib.callback.register("boatRentals:spawnRequest", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return "error #1"
    end
    if xPlayer.getMoney() < Config.caution then
        return "error #2"
    end
    local spawnIndex = data?.spawnIndex
    if spawnIndex == nil then
        return "error #3"
    end
    local boatIndex = data?.boatIndex
    if boatIndex == nil then
        return "error #4"
    end
    local modelIndex = data?.modelIndex
    if modelIndex == nil then
        return "error #5"
    end
    local coords = Config.spawn[spawnIndex]
    if coords == nil then
        return "error #6"
    end
    local boat = Config.boat[boatIndex]
    if boat == nil then
        return "error #7"
    end
    local model = boat.model[modelIndex]
    if model == nil then
        return "error #8"
    end
    xPlayer.removeMoney(Config.caution)
    model = type(model) == "number" and model or joaat(model)
    local plate = ("SEA %s"):format(math.random(1000, 9999))
    while registered[plate] ~= nil do
		plate = ("SEA %s"):format(math.random(1000, 9999))
	end
    registered[plate] = {
        identifier = xPlayer.identifier
    }
    return true, plate
end)

lib.callback.register("boatRentals:vehicleReturn", function(source, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return false
	end

	local plate = data?.plate
	local vehicle = registered[plate]
	if not vehicle then
		return false
	end

	if vehicle.identifier ~= xPlayer.identifier then
		return false
	end

	registered[plate] = nil
    if Config.returnmoney then
	    xPlayer.addMoney(Config.caution)
    end
	return true
end)

lib.callback.register("boatRentals:getRegisteredVehicles", function(source)
    local vehicles = {}
    for k, v in pairs(registered) do
        if v.identifier == GetPlayerIdentifiers(source)[1] then
            vehicles[k] = true
        end
    end
    return vehicles
end)