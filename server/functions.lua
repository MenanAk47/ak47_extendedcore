ESX = {}
ESX.TimeoutCount = -1
ESX.CancelledTimeouts = {}

ESX.RegisterServerCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

ESX.GetItemLabel = function(item)
    if QBCore.Shared.Items[item] then    
        return QBCore.Shared.Items[item].label
    else
        return nil
    end
end

ESX.GetPlayerFromId = function(source)
    return extendedPlayer(source)
end

ESX.GetPlayerFromIdentifier = function(identifier)
    for src, _ in pairs(ESX.GetPlayers()) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return extendedPlayer(src)
            end
        end
    end
    return 0
end

ESX.GetIdentifier = function(playerId, idtype)
    local xPlayer = extendedPlayer(playerId)
    return xPlayer.identifier
end

ESX.RegisterUsableItem = function(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
end

ESX.UseItem = function(source, item)
    QBCore.Functions.UseItem(source, item)
end

ESX.SetTimeout = function(msec, cb)
    local id = ESX.TimeoutCount + 1
    SetTimeout(msec, function()
        if ESX.CancelledTimeouts[id] then
            ESX.CancelledTimeouts[id] = nil
        else
            cb()
        end
    end)
    ESX.TimeoutCount = id
    return id
end

ESX.ClearTimeout = function(id)
    ESX.CancelledTimeouts[id] = true
end

ESX.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
    if type(name) == 'table' then
        for k, v in ipairs(name) do
            ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
        end
        return
    end
    if ESX.RegisteredCommands[name] then
        print(('[^3WARNING^7] Command ^5"%s" already registered, overriding command'):format(name))
        if ESX.RegisteredCommands[name].suggestion then
            TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
        end
    end
    if suggestion then
        if not suggestion.arguments then suggestion.arguments = {} end
        if not suggestion.help then suggestion.help = '' end
        TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
    end
    ESX.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}
    RegisterCommand(name, function(playerId, args, rawCommand)
        local command = ESX.RegisteredCommands[name]
        if not command.allowConsole and playerId == 0 then
            print(('[^3WARNING^7] ^5%s'):format(_U('commanderror_console')))
        else
            local xPlayer, error = ESX.GetPlayerFromId(playerId), nil
            if command.suggestion then
                if command.suggestion.validate then
                    if #args ~= #command.suggestion.arguments then
                        error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
                    end
                end
                if not error and command.suggestion.arguments then
                    local newArgs = {}
                    for k, v in ipairs(command.suggestion.arguments) do
                        if v.type then
                            if v.type == 'number' then
                                local newArg = tonumber(args[k])
                                if newArg then
                                    newArgs[v.name] = newArg
                                else
                                    error = _U('commanderror_argumentmismatch_number', k)
                                end
                            elseif v.type == 'player' or v.type == 'playerId' then
                                local targetPlayer = tonumber(args[k])
                                if args[k] == 'me' then targetPlayer = playerId end
                                if targetPlayer then
                                    local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)
                                    if xTargetPlayer then
                                        if v.type == 'player' then
                                            newArgs[v.name] = xTargetPlayer
                                        else
                                            newArgs[v.name] = targetPlayer
                                        end
                                    else
                                        error = _U('commanderror_invalidplayerid')
                                    end
                                else
                                    error = _U('commanderror_argumentmismatch_number', k)
                                end
                            elseif v.type == 'string' then
                                newArgs[v.name] = args[k]
                            elseif v.type == 'item' then
                                local tItem = args[k]
                                if QBCore.Shared.Items[tItem:lower()] then
                                    newArgs[v.name] = args[k]
                                else
                                    error = _U('commanderror_invaliditem')
                                end
                            elseif v.type == 'weapon' then
                                local tItem = args[k]
                                local itemInfo = QBCore.Shared.Items[tItem:lower()]
                                if itemInfo then
                                    newArgs[v.name] = string.upper(tItem)
                                else
                                    error = _U('commanderror_invalidweapon')
                                end
                            elseif v.type == 'any' then
                                newArgs[v.name] = args[k]
                            end
                        end
                        if error then break end
                    end
                    args = newArgs
                end
            end
            if error then
                if playerId == 0 then
                    print(('[^3WARNING^7] %s^7'):format(error))
                else
                    xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
                end
            else
                cb(xPlayer or false, args, function(msg)
                    if playerId == 0 then
                        print(('[^3WARNING^7] %s^7'):format(msg))
                    else
                        xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
                    end
                end)
            end
        end
    end, true)
    if type(group) == 'table' then
        for k, v in ipairs(group) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
        end
    else
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
    end
end

ESX.GetPlayers = function()
    return QBCore.Functions.GetPlayers()
end

function extendedPlayer(source)
    local self = {}
    local xPlayer = QBCore.Functions.GetPlayer(source)

    self.source = source
    self.identifier = xPlayer.PlayerData.citizenid
    self.job = xPlayer.PlayerData.job
    self.job.grade = self.job.grade.level

    self.triggerEvent = function(eventName, ...)
        TriggerClientEvent(eventName, self.source, ...)
    end

    self.setAccountMoney = function(accountName, money)
        if money >= 0 then
            if accountName == 'money' then
                xPlayer.Functions.SetMoney('cash', money)
            elseif accountName == 'black_money' then
                xPlayer.Functions.AddItem('markedbills', money)
            elseif accountName == 'bank' then
                xPlayer.Functions.SetMoney('bank', money)
            end
        end
    end

    self.addAccountMoney = function(accountName, money, ignoreInventory)
        if money >= 0 then
            if accountName == 'money' then
                xPlayer.Functions.AddMoney('cash', money)
            elseif accountName == 'black_money' then
                xPlayer.Functions.AddItem('markedbills', money)
            elseif accountName == 'bank' then
                xPlayer.Functions.AddMoney('bank', money)
            end
        end
    end

    self.removeAccountMoney = function(accountName, money, ignoreInventory)
        if money > 0 then
            if accountName == 'money' then
                xPlayer.Functions.RemoveMoney('cash', money)
            elseif accountName == 'black_money' then
                xPlayer.Functions.AddItem('markedbills', money)
            elseif accountName == 'bank' then
                xPlayer.Functions.RemoveMoney('bank', money)
            end
        end
    end

    self.setMoney = function(money)
        money = math.ceil(money)
        self.setAccountMoney('money', money)
    end

    self.getMoney = function()
        return xPlayer.Functions.GetMoney('cash')
    end

    self.addMoney = function(money)
        money = math.ceil(money)
        xPlayer.Functions.AddMoney('cash', money)
    end

    self.removeMoney = function(money)
        money = math.ceil(money)
        xPlayer.Functions.RemoveMoney('cash', money)
    end

    self.getIdentifier = function()
        return self.identifier
    end

    self.addInventoryItem = function(name, count)
        xPlayer.Functions.AddItem(name, count)
    end

    self.removeInventoryItem = function(name, count)
        xPlayer.Functions.RemoveItem(name, count)
    end

    self.getInventoryItem = function(name)
        local item = xPlayer.Functions.GetItemByName(name)
        if item then
            item.count = item.amount
        else
            item = {}
            item.name = name
            item.count = 0
        end
        return item
    end

    self.setInventory = function(inv)
        xPlayer.Functions.SetInventory(inv, false)
    end

    self.setInventoryItem = function(name, count)
        local item = self.getInventoryItem(name)

        if item and count >= 0 then
            count = math.ceil(count)

            if count > item.count then
                self.addInventoryItem(item.name, count - item.count)
            else
                self.removeInventoryItem(item.name, item.count - count)
            end
        end
    end

    self.getWeight = function()
        return QBCore.Player.GetTotalWeight(xPlayer.PlayerData.items)
    end

    self.getMaxWeight = function()
        return QBCore.Config.Player.MaxWeight
    end

    self.canCarryItem = function(item, amount)
        local totalWeight = self.getWeight()
        local itemInfo = QBCore.Shared.Items[item:lower()]
        if (totalWeight + (itemInfo['weight'] * amount)) <= self.getMaxWeight() then
            return true
        else
            return false
        end
    end

    self.canSwapItem = function(item1, item1Count, item, amount)
        local totalWeight = self.getWeight()
        local itemInfo = QBCore.Shared.Items[item:lower()]
        if (totalWeight + (itemInfo['weight'] * amount)) <= self.getMaxWeight() then
            return true
        else
            return false
        end
    end

    self.setJob = function(job, grade)
        xPlayer.Functions.SetJob(job, grade)
    end

    self.getJob = function()
        return self.job
    end

    self.addWeapon = function(weaponName, ammo)
        xPlayer.Functions.AddItem(weaponName, ammo or 1)
    end

    self.removeWeapon = function(weaponName, amount)
        xPlayer.Functions.RemoveItem(weaponName, amount or 1)
    end

    self.showNotification = function(msg)
        TriggerClientEvent('QBCore:Notify', self.source, msg)
    end

    return self
end