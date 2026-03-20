local ReticuleSizeBase = 0.5
local ESX = exports['es_extended']:getSharedObject()
local alerts = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        playerReticule = GetConvar("profile_reticuleSize", "0")
        if playerReticule > "0" then
            ESX.ShowNotification("Hai il mirino troppo grande!\nMassimo: 0")
            alerts = alerts + 1
        end
        if alerts == 10 then
            TriggerServerEvent("token_misc:reticuleSizeTooBig")
            alerts = 0
        end
    end
end)
