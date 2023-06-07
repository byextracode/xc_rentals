if QBCore then
    function isAuthorized(authorizedJob)
        if type(authorizedJob) ~= "table" then
            authorizedJob = {authorizedJob}
        end
        local tabletype = table.type(authorizedJob)
        if tabletype == "hash" then
            local grade = authorizedJob[QBCore.PlayerData.job.name]
            if grade and grade <= QBCore.PlayerData.job.grade.level then
                return true
            end
        end
        if tabletype == "mixed" then
            if authorizedJob[QBCore.PlayerData.job.name] then
                return authorizedJob[QBCore.PlayerData.job.name] <= QBCore.PlayerData.job.grade.level
            end
            for index, value in pairs(authorizedJob) do
                if value == QBCore.PlayerData.job.name then
                    return true
                end
            end
        end
        if tabletype == "array" then
            for i = 1, #authorizedJob do
                if QBCore.PlayerData.job.name == authorizedJob[i] then
                    return true
                end
            end
        end
        return false
    end

    function spawnVehicle(model, coords)
        local entity = promise:new()
        QBCore.Functions.SpawnVehicle(model, function(veh)
            entity:resolve(veh)
        end, coords, true, true)
        return Citizen.Await(entity)
    end
else
    function isAuthorized(authorizedJob)
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

    function spawnVehicle(model, coords)
        local entity = promise:new()
        ESX.Game.SpawnVehicle(model, coords, coords.w, function(veh)
            entity:resolve(veh)
        end, true)
        return Citizen.Await(entity)
    end
end