ESX.RegisterServerCallback('esx_fishing:addFish', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('fish', 1)
end)

ESX.RegisterServerCallback('esx_fishing:sellFish', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local fishCount = xPlayer.getInventoryItem('fish').count

    if fishCount > 0 then
        local payment = fishCount * 50 -- $50 par poisson
        xPlayer.removeInventoryItem('fish', fishCount)
        xPlayer.addMoney(payment)
        TriggerClientEvent('esx:showNotification', source, "Vous avez vendu " .. fishCount .. " poissons pour $" .. payment)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas de poissons à vendre.")
    end
end)
