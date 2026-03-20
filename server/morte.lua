local ESX = exports.es_extended:getSharedObject()
local groupAllowed = {
    "admin",
    "mod",
    "helper"
}

local groupAllowedGiveg = {
    "admin",
}

RegisterServerEvent("update:death", function(isDead)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.set('dead', isDead)
    end
end)

RegisterServerEvent("RequestRevive", function(victimId, victimCoords, victimHeading, doctorCoords, doctorId)
    local xVictim = ESX.GetPlayerFromId(victimId)
    local xDoctor = ESX.GetPlayerFromId(doctorId)
    if not xVictim.get('dead') then
        return TriggerClientEvent('esx:showNotification', doctorId, "Il giocatore non è morto.")
    end
    if xVictim and xDoctor then
        TriggerClientEvent("animation:victim", xVictim.source, victimCoords, victimHeading)
        TriggerClientEvent("animation:doctor", xDoctor.source)
    end
end)

RegisterServerEvent("RequestHeal", function(victimId)
    local xVictim = ESX.GetPlayerFromId(victimId)
    if not xVictim then
        return TriggerClientEvent('esx:showNotification', source, "Giocatore non trovato.")
    end
    if xVictim.get('dead') then
        return TriggerClientEvent('esx:showNotification', source, "Il giocatore è morto. Rianimalo!")
    end 
    TriggerClientEvent("un_misc:heal", xVictim.source)
    TriggerClientEvent('esx:showNotification', source, "Giocatore curato!")
end)

function contains(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end

RegisterCommand("revive", function(source, args) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetId = args[1]
    if targetId == "me" then
        TriggerClientEvent("un_misc:revive", source)
            exports.un_misc:Log("https://discord.com/api/webhooks/1479910099513507890/VmcPa1LwX_dnotKfK18hRVsv0efFmWpb4GpZ3tS0b5JiaZHJMKaO5MqZY61UiylepAL1",
        "**REVIVE**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nSi è rianimato.")
        return
    end
    if not args[1] then TriggerClientEvent("un_misc:revive", source) 
                    exports.un_misc:Log("https://discord.com/api/webhooks/1479910099513507890/VmcPa1LwX_dnotKfK18hRVsv0efFmWpb4GpZ3tS0b5JiaZHJMKaO5MqZY61UiylepAL1",
        "**REVIVE**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nSi è rianimato.")
        return 
    end
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        if playerGroup and contains(groupAllowed, playerGroup) then
            TriggerClientEvent("un_misc:revive", targetId)
            -- INSERISCI LOG
            exports.un_misc:Log("https://discord.com/api/webhooks/1479910099513507890/VmcPa1LwX_dnotKfK18hRVsv0efFmWpb4GpZ3tS0b5JiaZHJMKaO5MqZY61UiylepAL1",
             "**REVIVE**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nHa rianimato il player: "..GetPlayerName(targetId))
        else
            TriggerClientEvent('esx:showNotification', source, "Non hai il permesso di usare questo comando.")
        end
    end
end, true)

RegisterCommand("giveg", function(source, args) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetId = args[1]
    if targetId == "me" then
        TriggerClientEvent("giveg", source)
                            exports.un_misc:Log("https://discord.com/api/webhooks/1479909911273013399/MhZA0ub5NJ_nL3aPkKjBNpjKYYlDYiB4lr-R37JavGTq9MH3tn6aPSVBQr8eVS8HJBs0",
             "**GIVE G**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nHa givvato un giubotto a se stesso.")
        return
    end
    if not args[1] then TriggerClientEvent("giveg", source) 
                    exports.un_misc:Log("https://discord.com/api/webhooks/1479909911273013399/MhZA0ub5NJ_nL3aPkKjBNpjKYYlDYiB4lr-R37JavGTq9MH3tn6aPSVBQr8eVS8HJBs0",
             "**GIVE G**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nHa givvato un giubotto a se stesso.")
        return 
    end
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        if playerGroup and contains(groupAllowedGiveg, playerGroup) then
            TriggerClientEvent("giveg", targetId)
            -- INSERISCI LOG
            exports.un_misc:Log("https://discord.com/api/webhooks/1479909911273013399/MhZA0ub5NJ_nL3aPkKjBNpjKYYlDYiB4lr-R37JavGTq9MH3tn6aPSVBQr8eVS8HJBs0",
             "**GIVE G**\n\nLo staffer: "..GetPlayerName(xPlayer.source).."\n\nHa givvato un giubotto al player: "..GetPlayerName(targetId))
        else
            TriggerClientEvent('esx:showNotification', source, "Non hai il permesso di usare questo comando.")
        end
    end
end, true)


-- RESPAWN

RegisterServerEvent("scritta:respawnSV", function(plData, plcoords, drop) 
    local xPlayer = ESX.GetPlayerFromId(source)

    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:sub(1,6) == "steam:" then
            steamId = id:sub(7)
        end
    end

    local datas = {
        coords = plcoords,
        job = xPlayer.getJob().name,
        steam = GetPlayerName(source),
        id = xPlayer.source,
        slog = drop,
        steamhex = steamId
    }
    exports.un_misc:Log("https://discord.com/api/webhooks/1479919738619695328/O7OTWwi845xdJjgR5KAZ-XzpQPXFS3e_bw1CxUuXmp97kdfnX7tFB2GT7cgcTn3imuZc",
        "**RESPAWN**\n\nIl player: "..GetPlayerName(xPlayer.source).."\n\nSi è appena respawnato.\n\nJOB: "..xPlayer.getJob().label.."\n\nCoords: "..json.encode(plcoords))
    TriggerClientEvent("scritta:respawnCL", -1, datas)
end)

-- Evento quando il player si disconnette
AddEventHandler('playerDropped', function(reason)
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local steamId = ""
        
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if id:sub(1,6) == "steam:" then
                steamId = id:sub(7)
                break
            end
        end
        
        local datas = {
            coords = coords,
            job = xPlayer.getJob().name,
            steam = GetPlayerName(src),
            id = src,
            slog = true,
            steamhex = steamId
        }
            exports.un_misc:Log("https://discord.com/api/webhooks/1479919587397996634/MVo5fQnr2qQHXuSdYQQ8sAJujL_P7nzqoN83Y7hEfaxD2Bcmqtgt5_kRwxfOULD7oPZo",
        "**QUIT**\n\nIl player: "..GetPlayerName(xPlayer.source).."\n\nHa quittato il server.\n\nMotivo: "..reason.."\n\nJOB: "..xPlayer.getJob().label.."\n\nCoords: "..json.encode(coords))
        
        TriggerClientEvent("scritta:respawnCL", -1, datas)
    end
end)

-- -- Comando di test per lo slog
-- RegisterCommand("testslog", function(source, args)
--     local src = source
--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local xPlayer = ESX.GetPlayerFromId(src)
    
--     if xPlayer then
--         local steamId = ""
        
--         for _, id in ipairs(GetPlayerIdentifiers(src)) do
--             if id:sub(1,6) == "steam:" then
--                 steamId = id:sub(7)
--                 break
--             end
--         end
        
--         local datas = {
--             coords = coords,
--             job = xPlayer.getJob().name,
--             steam = GetPlayerName(src),
--             id = src,
--             slog = true,
--             steamhex = steamId
--         }
        
--         TriggerClientEvent("scritta:respawnCL", -1, datas)
--         TriggerClientEvent('esx:showNotification', src, "Test slog attivato!")
--     end
-- end, false)