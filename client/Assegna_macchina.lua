local ESX = exports.es_extended:getSharedObject()

local JobsAllowed = {
    "concessionario",
}
local jobneeded = false

function TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

RegisterNetEvent("ghiaccio:AssegnaMacchina", function() 
    ESX.TriggerServerCallback("un_misc:assegnamacchinaData", function(data) 
        if not TableContains(JobsAllowed, data.job) and jobneeded then
            return ESX.ShowNotification("Non hai il lavoro necessario per accedere a questa funzione.")
        end
        local macchine = {}
        for i = 1, #data.cars do
            table.insert(macchine, { label = data.cars[i], value = data.cars[i] })
        end
        local input = lib.inputDialog('Assegna Macchina', {
            { type = 'select',
                label = 'Scegli una macchina da assegnare',
                options = macchine
            },
            {
                type = 'input',
                label = 'ID del giocatore',
                inputType = 'number'
            }
        })

        if not input then return end
        local plate = input[1]
        local targetId = tonumber(input[2])
        if not plate or not targetId then
            return
        end
        AssegnaMacchina(plate, targetId)
    end)
end)


function AssegnaMacchina(plate, targetId)
    TriggerServerEvent("un_misc:assegnaMacchina", plate, targetId)
end