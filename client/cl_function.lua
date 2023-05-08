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

function openMenu(spawnIndex)
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
                TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
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
    
    lib.showContext("boat_rental")
end