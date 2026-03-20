ESX = exports["es_extended"]:getSharedObject()

local Config = {
    TaxiPrice = 1500,           
    PricePerKM = 10,         
    MaxDistance = 5000,      
    PaymentAccount = 'cash'  -- cash or bank
}

ESX.RegisterServerCallback('taxisystem:checkPlayerMoney', function(source, cb, isPaying)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        cb(false)
        return
    end
    
    if isPaying then
        local finalPrice = Config.TaxiPrice
        
        if Config.PaymentAccount == 'bank' then
            if xPlayer.getAccount('bank').money >= finalPrice then
                xPlayer.removeAccountMoney('bank', finalPrice)
                xPlayer.showNotification('Hai pagato €' .. finalPrice .. ' per la corsa in taxi.', 'success')
                cb(true)
            else
                xPlayer.showNotification('Non hai abbastanza soldi in banca per pagare il taxi!', 'error')
                cb(false)
            end
        else
            if xPlayer.getMoney() >= finalPrice then
                xPlayer.removeMoney(finalPrice)
                xPlayer.showNotification('Hai pagato €' .. finalPrice .. ' per la corsa in taxi.', 'success')
                cb(true)
            else
                xPlayer.showNotification('Non hai abbastanza contanti per pagare il taxi!', 'error')
                cb(false)
            end
        end
    else
        if Config.PaymentAccount == 'bank' then
            cb(xPlayer.getAccount('bank').money >= Config.TaxiPrice)
        else
            cb(xPlayer.getMoney() >= Config.TaxiPrice)
        end
    end
end)

ESX.RegisterServerCallback('taxisystem:calculatePrice', function(source, cb, distance)
    local basePrice = Config.TaxiPrice
    local distancePrice = math.floor((distance / 1000) * Config.PricePerKM) 
    local totalPrice = basePrice + distancePrice
    
    cb(totalPrice)
end)

ESX.RegisterCommand('taxi', 'user', function(xPlayer, args, showError)
    if not xPlayer then return end
    
    TriggerClientEvent('callTaxi', xPlayer.source)
end, false, {help = 'Chiama un taxi'})

RegisterNetEvent('taxisystem:callTaxi', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    TriggerClientEvent('callTaxi', source)
end)

RegisterNetEvent('taxisystem:logTaxiRide', function(startCoords, endCoords, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local identifier = xPlayer.identifier
    local name = xPlayer.getName()
    -- INSERISCI LOG 
    --print('^2[TAXI SYSTEM]^7 ' .. name .. ' (ID: ' .. source .. ', Identifier: ' .. identifier .. ') ha completato una corsa taxi per €' .. price)
        exports.un_misc:Log("https://discord.com/api/webhooks/1479908939733667931/ZIWK50Be1hgs1BLcDQfs70FIEOdI-z2x90sEKU1LhnojrvFY8xWRgbK8SO5rthyj1E4x",
     "**TAXI RIDE**\n\nIl player: "..xPlayer.getName().."\n\nHa completato una corsa taxi per €" .. price)
end)

RegisterNetEvent('taxisystem:updateConfig', function(newConfig)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end

    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        if newConfig.TaxiPrice then Config.TaxiPrice = newConfig.TaxiPrice end
        if newConfig.PricePerKM then Config.PricePerKM = newConfig.PricePerKM end
        if newConfig.MaxDistance then Config.MaxDistance = newConfig.MaxDistance end
        if newConfig.PaymentAccount then Config.PaymentAccount = newConfig.PaymentAccount end
        
        xPlayer.showNotification('Configurazione taxi aggiornata con successo!', 'success')
        print('^2[TAXI SYSTEM]^7 Configurazione aggiornata da ' .. xPlayer.getName())
    else
        xPlayer.showNotification('Non hai i permessi per modificare la configurazione!', 'error')
    end
end)

ESX.RegisterServerCallback('taxisystem:getConfig', function(source, cb)
    cb(Config)
end)


ESX.RegisterCommand('taxistats', 'admin', function(xPlayer, args, showError)
    if not xPlayer then return end
    
    xPlayer.showNotification('Config Taxi - Prezzo base: €' .. Config.TaxiPrice .. ' | Prezzo per KM: €' .. Config.PricePerKM, 'info')
end, false, {help = 'Mostra statistiche sistema taxi (Solo Admin)'})