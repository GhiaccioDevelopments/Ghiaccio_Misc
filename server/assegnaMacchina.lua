local ESX = exports.es_extended:getSharedObject()

function GetPlayerCars(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local macchine = {}
    local result = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE owner = ?', { xPlayer.identifier })
    for i = 1, #result do
        table.insert(macchine, result[i].plate)
    end
    return macchine
end

ESX.RegisterServerCallback("un_misc:assegnamacchinaData", function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {
        job = xPlayer.job.name,
        cars = GetPlayerCars(source)
    }
    cb(data)
end)

RegisterServerEvent("un_misc:assegnaMacchina", function(plate, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if xPlayer.source == xTarget.source then
        return TriggerClientEvent('esx:showNotification', source, 'Non puoi assegnare una macchina a te stesso!')
    end
    if not xTarget then
        return
    end
    MySQL.update('UPDATE owned_vehicles SET owner = ? WHERE plate = ?', { xTarget.identifier, plate })
    TriggerClientEvent('esx:showNotification', source, 'Hai assegnato la macchina con targa ~b~' .. plate .. '~s~ a ~b~' .. xTarget.name .. '~s~.')
    TriggerClientEvent('esx:showNotification', targetId, 'Ti è stata assegnata una macchina con targa ~b~' .. plate .. '~s~ da ~b~' .. xPlayer.name .. '~s~.')
    -- INSERISCI LOG
    exports.un_misc:Log("https://discord.com/api/webhooks/1479920822348021892/clM0NFCY8pWOMwf_9oDriT_7I4GNZtjhHDhhe72O8QsceEtfD2HSLK2WMmYqBjnJEy4v",
     "**ASSEGNAZIONE MACCHINA**\n\nIl player: "..GetPlayerName(xPlayer.source).."\n\nHa assegnato la macchina con targa: "..plate.."\n\nDestinatario: "..GetPlayerName(xTarget.source).. "(ID: "..xTarget.source..")")
end)