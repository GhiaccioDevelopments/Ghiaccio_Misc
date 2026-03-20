local menuOpen = false
local ESX = exports.es_extended:getSharedObject()

CreateThread(function()
    playerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerData.job = job
end)

RegisterCommand('menuf5', function()
    toggleMenu()
end, false)

RegisterKeyMapping('menuf5', 'Apri Menu F5', 'keyboard', 'F5')

function toggleMenu()
    menuOpen = not menuOpen
    SetNuiFocus(menuOpen, false)
    SetNuiFocusKeepInput(menuOpen)
    SendNUIMessage({
        action = "toggleMenu",
        show = menuOpen
    })
end



RegisterNUICallback("un:personal_docs", function(_, cb)
    exports.un_misc:documenti_personali()
    toggleMenu()
end)

RegisterNUICallback("un:garage", function(_, cb)
    toggleMenu()
end)

RegisterNUICallback("un:banca", function(_, cb)   -- GESTIONE RADIO
    ExecuteCommand("radio")
    toggleMenu()
end)

RegisterNUICallback("un:gestione_attivita", function(_, cb) -- CALL TAXI
    ExecuteCommand("taxi")
    toggleMenu()
end)

RegisterNUICallback("un:editor", function(_, cb) -- JOBS
    exports["un_multiJobs"]:ShowJobMenu()
    toggleMenu()
end)

RegisterNUICallback("un:report", function(_, cb)
    ExecuteCommand("report")
    toggleMenu()
end)


RegisterNUICallback("un:rockstar_editor", function(_, cb)
    ExecuteCommand("rockstar")
    toggleMenu()
end)


RegisterNUICallback("un:closeMenu", function(_, cb)
    SendNUIMessage({
        action = "toggleMenu",
        show = false
    })
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    menuOpen = false
    cb({})
end)


RegisterNUICallback("closeMenu", function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    cb({})
end)