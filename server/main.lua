local registered = {}

lib.callback.register("vehicleRentals:checkMoney", function(source, data)
    local Player = GetPlayerData(source)
    if not Player then
        return labelText("player_error")
    end
    if data?.index == nil then
        return labelText("data_error")
    end
    if data?.modelIndex == nil then
        return labelText("data_error")
    end
    if Config.location[data.index] == nil then
        return labelText("data_error")
    end
    if Config.location[data.index].vehicle[data.modelIndex] == nil then
        return labelText("data_error")
    end
    local fee = Config.location[data.index].vehicle[data.modelIndex].fee
    return Player.GetMoney("money") >= fee
end)

lib.callback.register("vehicleRentals:spawnRequest", function(source, data)
    local Player = GetPlayerData(source)
    if not Player then
        return labelText("player_error")
    end
    if data?.index == nil then
        return labelText("data_error")
    end
    if data?.modelIndex == nil then
        return labelText("data_error")
    end
    if Config.location[data.index] == nil then
        return labelText("data_error")
    end
    if Config.location[data.index].vehicle[data.modelIndex] == nil then
        return labelText("data_error")
    end

    local fee = Config.location[data.index].vehicle[data.modelIndex].fee
    if Player.GetMoney("money") < fee then
        return labelText("not_enough_money")
    end

    local plate = ("RENT %s"):format(math.random(100, 999))
    while registered[plate] ~= nil do
		plate = ("RENT %s"):format(math.random(100, 999))
	end
    registered[plate] = {
        identifier = Player.identifier
    }
    Player.RemoveMoney("money", fee)
    return true, plate
end)

lib.callback.register("vehicleRentals:vehicleReturn", function(source, data)
	local Player = GetPlayerData(source)
	if not Player then
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
	if vehicle.identifier ~= Player.identifier then
		return false
	end

	registered[plate] = nil
	return true
end)

lib.callback.register("vehicleRentals:getRegisteredVehicles", function(source)
    local vehicles = {}
    local Player = GetPlayerData(source)
    if not Player then
        return vehicles
    end
    for k, v in pairs(registered) do
        if v.identifier == Player.identifier then
            vehicles[k] = true
        end
    end
    return vehicles
end)