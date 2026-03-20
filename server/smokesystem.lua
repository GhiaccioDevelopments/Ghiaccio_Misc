ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("ghiaccio:server:usa-pacchetto-sigarette", function() 
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and exports.ox_inventory:CanCarryItem(source, 'sigaretta', 20) and exports.ox_inventory:GetItemCount(xPlayer.source, "pacchettodisigarette") > 0 then
        exports.ox_inventory:RemoveItem(xPlayer.source, "pacchettodisigarette", 1)
        exports.ox_inventory:AddItem(xPlayer.source, "sigaretta", 20)
    end
end)

RegisterServerEvent("server:sigaretta", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and exports.ox_inventory:GetItemCount(xPlayer.source, "sigaretta") > 0 then
        exports.ox_inventory:RemoveItem(xPlayer.source, "sigaretta", 1)
    end
end)

RegisterServerEvent("notSigaretta", function()
        local xPlayer = ESX.GetPlayerFromId(source)
        local ora = os.date("%H:%M:%S")
        local data = os.date("%d/%m/%Y")
        exports.un_misc:Log("https://discord.com/api/webhooks/1479936620995285155/W-hVHHZzl4QRxgwK_CR6yQZzgXsgZC7s_WoucTJ43ZB5rWXmcCREbtI_KPvtG_0xZOkZ",
     "**ANTICHEAT - Sigaretta**\n\nIl player: "..GetPlayerName(xPlayer.source).." ("..xPlayer.source..")\n\nHa usato una sigaretta in modo sospetto alle "..ora.." del "..data)
    DropPlayer(source, "Allora, volevi fumare senza sigarette?")
end)