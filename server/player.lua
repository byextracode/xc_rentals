if QBCore then
    function GetPlayerData(playerId)
        local self = {}
        local Player = QBCore.Functions.GetPlayer(playerId)
        if not Player then
            return nil
        end

        self.source = Player.PlayerData.source
        self.identifier = Player.PlayerData.citizenid
        self.name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname

        function self.RemoveMoney(moneyType, amount, reason)
            if moneyType == 'money' then
                moneyType = 'cash'
            end
            return Player.Functions.RemoveMoney(moneyType, amount, reason)
        end

        function self.AddMoney(moneyType, amount, reason)
            if moneyType == 'money' then
                moneyType = 'cash'
            end
            return Player.Functions.AddMoney(moneyType, amount, reason)
        end

        function self.GetMoney(moneyType)
            if moneyType == 'money' then
                moneyType = 'cash'
            end
            return Player.Functions.GetMoney(moneyType)
        end

        function self.GetIdentifier()
            return Player.PlayerData.citizenid
        end

        function self.AddItem(item, count, slot, metadata)
            return Player.Functions.AddItem(item, count, slot, metadata)
        end

        function self.RemoveItem(item, count, slot, metadata)
            return Player.Functions.RemoveItem(item, count, slot, metadata)
        end

        function self.HasItem(item)
            local items = Player.Functions.GetItemsByName(item)
            local count = 0
            local ox = GetResourceState('ox_inventory') == 'started'
            for i = 1, #items do
                local add = ox and items[i].count or items[i].amount
                count += add
            end

            return count
        end

        function self.GetName()
            return Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
        end

        function self.ValidateRequirements(requirements)
            if not next(requirements) then
                return true
            end
            for i = 1, #requirements do
                if self.HasItem(requirements[i].item) < requirements[i].count then
                    return false
                end
            end
            return true
        end

        function self.triggerEvent(eventName, ...)
            TriggerClientEvent(eventName, self.source, ...)
        end

        return self
    end

    function GetPlayerFromIdentity(identity)
        return QBCore.Functions.GetPlayerByCitizenId(identity)
    end

    QBCore.Functions.CreateCallback("xc_biz:HasItem", function(source, cb, item)
        local Player = GetPlayerData(source)
        cb(Player.HasItem(item))
    end)
else
    function GetPlayerData(playerId)
        local self = {}
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if not xPlayer then
            return nil
        end

        self.identifier = xPlayer.identifier
        self.name = xPlayer.name

        function self.RemoveMoney(moneyType, amount, reason)
            if moneyType == 'cash' then
                moneyType = 'money'
            end
            return xPlayer.removeAccountMoney(moneyType, amount)
        end

        function self.AddMoney(moneyType, amount, reason)
            if moneyType == 'cash' then
                moneyType = 'money'
            end
            return xPlayer.addAccountMoney(moneyType, amount)
        end

        function self.GetMoney(moneyType)
            if moneyType == 'cash' then
                moneyType = 'money'
            end
            return xPlayer.getAccount(moneyType).money
        end

        function self.GetIdentifier()
            return xPlayer.identifier
        end

        function self.AddItem(item, count, slot, metadata)
            return xPlayer.addInventoryItem(item, count, metadata, slot)
        end

        function self.RemoveItem(item, count, slot, metadata)
            return xPlayer.removeInventoryItem(item, count, metadata, slot)
        end

        function self.HasItem(item)
            local item = xPlayer.getInventoryItem(item)

            return item?.count or 0
        end

        function self.GetName()
            return xPlayer.name
        end

        function self.ValidateRequirements(requirements)
            if not next(requirements) then
                return true
            end
            for i = 1, #requirements do
                if self.HasItem(requirements[i].item) < requirements[i].count then
                    return false
                end
            end
            return true
        end

        function self.triggerEvent(eventName, ...)
            TriggerClientEvent(eventName, self.source, ...)
        end

        return self
    end

    function GetPlayerFromIdentity(identity)
        return ESX.GetPlayerFromIdentifier(identity)
    end
end