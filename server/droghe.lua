local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("raccolta_sv", function(i,c) 

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and exports.ox_inventory:CanCarryItem(xPlayer.source, i, c) then
        xPlayer.addInventoryItem(i, c)
    else
        TriggerClientEvent("esx:showNotification", xPlayer.source, "Non hai abbastanza spazio in inventario")
    end

end)

RegisterServerEvent("processo_sv", function(ricetta, itemname, count) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local canProcess = true
    for k,v in pairs(ricetta) do
        if exports.ox_inventory:GetItemCount(xPlayer.source, v.item) < v.count then
            canProcess = false
            break
        end
    end
    if canProcess then
        for k,v in pairs(ricetta) do
            xPlayer.removeInventoryItem(v.item, v.count)
        end
        xPlayer.addInventoryItem(itemname, count)
    else
        TriggerClientEvent("esx:showNotification", xPlayer.source, "Non hai gli ingredienti necessari")
    end
end)