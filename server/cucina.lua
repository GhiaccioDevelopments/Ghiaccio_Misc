local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("cucinato", function(itemKey, quantity, locale)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    if not itemKey or not quantity or not locale then return end
    
    local localeData = Config.Locali[locale]
    if not localeData then return end

    local itemData = localeData.menu.cibi[itemKey]
    if not itemData then
        itemData = localeData.menu.bevande[itemKey]
    end
    
    if not itemData then return end

    for _, ingredient in ipairs(itemData.ingredients) do
        xPlayer.removeInventoryItem(ingredient.item, quantity)
    end
    
    xPlayer.addInventoryItem(itemKey, quantity)
    
    TriggerClientEvent('esx:showNotification', source, 'Hai preparato: ' .. quantity .. 'x ' .. itemData.label)
end)