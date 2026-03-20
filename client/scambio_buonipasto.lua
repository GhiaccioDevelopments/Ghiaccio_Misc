local ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
        for k,v in pairs(Config.Locali) do 
            TriggerEvent('gridsystem:registerMarker', {
                name = 'scambio_buonipasto_'..k,
                pos = v.cambioBuonoPasto.pos,
                type = v.cambioBuonoPasto.marker.type,
                color = v.cambioBuonoPasto.marker.color,
                scale = v.cambioBuonoPasto.marker.scale,
                size = vector3(0.2,0.2,0.2),
                control = 'E',
                msg = '[E] - Buoni pasto',
                permission = k,
                jobGrade = v.cambioBuonoPasto.minGrade,
                action = function()
                    BuonoPastoMenu(k)
                end
            })
        end
    end)


function BuonoPastoMenu(localeIndex)
    local buonipasti = exports.ox_inventory:Search('count', 'buonopasto')
    if buonipasti <= 0 then
        lib.notify({ title = 'Buoni pasto', description = 'Non hai buoni pasto.', type = 'error' })
        return
    end

    local input = lib.inputDialog('Scambio buoni pasto', {
        {type = 'select', label = 'Quantità da scambiare', icon = 'fa-solid fa-utensils', required = true, options = {
            {value = buonipasti, label = 'Tutti i buoni pasto ('..buonipasti..')'},
            {value = -1,         label = 'Quantità personalizzata'}
        }}
    })
    if not input then return end

    local quantity = tonumber(input[1])
    if quantity == -1 then
        local customInput = lib.inputDialog('Quantità personalizzata', {
            {type = 'slider', label = 'Inserisci la quantità da scambiare', icon = 'fa-solid fa-utensils', required = true, min = 1, max = buonipasti, step = 1}
        })
        if not customInput then return end
        quantity = tonumber(customInput[1])
    end

    TriggerServerEvent('un_misc:scambioBuonoPasto', quantity, localeIndex )
end