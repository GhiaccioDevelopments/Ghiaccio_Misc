RegisterServerEvent('un_misc:scambioBuonoPasto')
AddEventHandler('un_misc:scambioBuonoPasto', function(quantity, k)
    local xPlayer = ESX.GetPlayerFromId(source)
    local buoniPastoCount = xPlayer.getInventoryItem('buonopasto').count

    if buoniPastoCount < quantity then
        TriggerClientEvent('esx:showNotification', source, 'Non hai abbastanza buoni pasto.')
        return
    end
    xPlayer.removeInventoryItem('buonopasto', quantity)
    xPlayer.addMoney(quantity * Config.Locali[k].cambioBuonoPasto.moneyPerBuono)
    TriggerClientEvent('esx:showNotification', source, 'Hai scambiato ' .. quantity .. ' buoni pasto.')
end)