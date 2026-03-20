local ESX = exports['es_extended']:getSharedObject()

RegisterCommand('me', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local text = "" .. table.concat(args, " ") .. ""
    local sourcePlayer = source
    local playerName = GetPlayerName(sourcePlayer)
    TriggerClientEvent('3dme:shareDisplay', -1, table.concat(args, " "), source)
    -- ESX.Log(
    --     "https://discord.com/api/webhooks/1409294146157416600/x_FgxFqTAzrq8QVXBOIrYmYjurnaFCWxczP_Y4_Uy7DbHFwyGxFttbRwtDUXRDRUF6aT",
    --     "Il player " .. playerName .. " [ID: " .. sourcePlayer .. "] ha scritto in /me \n \n Messaggio: *" .. text .. "*")
    -- end)
end)
