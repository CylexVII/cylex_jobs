ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    print("^7[^1cylex_jobs^7] - ^2ACTIVE! ^0") 
end)

RegisterServerEvent("cylex_jobs:server:process")
AddEventHandler("cylex_jobs:server:process", function(location)
    local player = ESX.GetPlayerFromId(source)
    if not player or location == nil then return TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "An error occurred. Please try again."}) end
    local item = player.getInventoryItem(location.itemName)
    local requiredItem = player.getInventoryItem(location.requiredItem)
    if item or location.process == "sell" then
        if location.process == "pickup" then
            if player.canCarryItem(location.itemName, location.addCount) then
                player.addInventoryItem(location.itemName, location.addCount)
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "You reached the weight limit!"})
            end
        elseif location.process == "exchange" then
            if requiredItem.count >= location.removeCount then
                if player.canCarryItem(location.itemName, location.addCount) then
                    player.removeInventoryItem(location.requiredItem, location.removeCount)
                    player.addInventoryItem(location.itemName, location.addCount)
                else
                    TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "You reached the weight limit!"})
                end
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "You don't have enough item!"})
            end
        elseif location.process == "package" then
            if requiredItem.count >= location.removeCount then
                if player.canCarryItem(location.itemName, location.addCount) then
                    player.removeInventoryItem(location.requiredItem, location.removeCount)
                    player.addInventoryItem(location.itemName, location.addCount)
                end
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "You don't have enough item!"})
            end
        elseif location.process == "sell" then
            if requiredItem.count >= location.removeCount then
                player.removeInventoryItem(location.requiredItem, location.removeCount)
                player.addMoney(location.price)
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "You don't have enough item!"})
            end
        end
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "An error occurred."})
        print("[cylex_jobs] - ERROR - cylex_jobs:server:process Tried to query an item that isn't included in the 'items' table.") 
        print("[cylex_jobs] Item must be "..location.itemName)
    end
end)

ESX.RegisterServerCallback('cylex_jobs:checkCount', function(source, cb, itemName) 
    local player = ESX.GetPlayerFromId(source)
    local item = player.getInventoryItem(itemName)
    if item then
        cb(item.count)
    else
        cb(0)
    end
end)