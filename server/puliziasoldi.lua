local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('puliziasoldi:cleanMoney')
AddEventHandler('puliziasoldi:cleanMoney', function(percentuale, quantita)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount('black_money').money

    if quantita > blackMoney then
        return TriggerClientEvent('esx:showNotification', source, 'Non hai abbastanza soldi sporchi.')
    end

    local cleanedAmount = math.floor(quantita * (percentuale / 100))
    xPlayer.removeAccountMoney('black_money', quantita)
    xPlayer.addMoney(cleanedAmount)

    TriggerClientEvent('esx:showNotification', source, 'Hai pulito ' .. cleanedAmount .. '$ da ' .. quantita .. '$ di soldi sporchi.')
end)