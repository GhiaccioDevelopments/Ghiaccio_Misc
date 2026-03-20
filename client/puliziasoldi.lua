local ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    exports.ox_target:addModel(Config.PuliziaProp, {
        {
            label = Config.Puliziasoldi.label,
            icon = Config.Puliziasoldi.icon,
            distance = 3.0,
            groups = Config.Puliziasoldi.JobAllowed,
            onSelect = function(data)
                OpenPuliziaMenu()
            end
        }
    })
end)

function OpenPuliziaMenu()
    playerMoney = exports["ox_inventory"]:Search("count", "black_money")
    local input = lib.inputDialog('Pulizia Soldi', {
    {type = 'slider', label = 'Percentuale', placeholder = 'Percentuale di pulizia', icon = 'hashtag', min = 1, max = 100, step = 1, default = 50},
    {type = "select", label = "Quantità di soldi da pulire", options = {
        {value = playerMoney, label = "Pulisci tutto ("..playerMoney.."$)"},
        {value = "custom", label = "Pulisci quantità personalizzata"}
    }, icon = 'money-bill-wave'}
    })

    if not input then return end
    if input[2] == "custom" then
        local customAmount = lib.inputDialog('Quantità Personalizzata', {
            {type = 'slider', label = 'Quantità di soldi da pulire', placeholder = 'Inserisci la quantità', icon = 'money-bill-wave', min = 1, max = playerMoney, step = 1, default = playerMoney}
        })
        if not customAmount then return end
        input[2] = customAmount[1]
    end
    percentuale = input[1]
    quantita = input[2]
    if playerMoney < quantita or playerMoney == 0 then
        return lib.notify({
            title = 'Errore',
            description = 'Non hai abbastanza soldi sporchi.',
            type = 'error'
        })
    end
    StartTimer(percentuale, quantita)
end

function StartTimer(percentuale, quantita)
    local timer = 5
    local startTime = GetGameTimer()
    while GetGameTimer() - startTime < timer * 1000 do
        local remainingTime = math.ceil((timer * 1000 - (GetGameTimer() - startTime)) / 1000)
        lib.showTextUI('Pulizia in corso... Tempo rimanente: ' .. remainingTime .. ' secondi')
        Citizen.Wait(1000)
    end
    lib.hideTextUI()
    TriggerServerEvent('puliziasoldi:cleanMoney', percentuale, quantita)
end