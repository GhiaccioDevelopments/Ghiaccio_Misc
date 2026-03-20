local ESX = exports.es_extended:getSharedObject()

local banAttivo = false
local SecondiDiUpdate = 0
local banTimeRemaining = 0

local function ApplyBanArmi(durationInMinutes, reason, isTest, isReload)
    if banAttivo then
        return
    end
    
    banAttivo = true
    banTimeRemaining = durationInMinutes * 60
    local timeRemaining = banTimeRemaining
    
    SendNUIMessage({
        action = 'ShowBanUI',
        time = durationInMinutes,
        reason = reason or 'Ban Armi'
    })

    Citizen.CreateThread(function()
        while banAttivo do
            Citizen.Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisablePlayerFiring(PlayerId(), true)
        end
    end)

    Citizen.CreateThread(function()
        while banAttivo and timeRemaining > 0 do
            Citizen.Wait(1000)
            timeRemaining = timeRemaining - 1
            banTimeRemaining = timeRemaining
            
            local minutesRemaining = timeRemaining / 60
            
            if not isTest then
                SecondiDiUpdate = SecondiDiUpdate + 1
                if SecondiDiUpdate >= 60 then
                    SecondiDiUpdate = 0
                    TriggerServerEvent("un_misc:BanArmi:Update", math.ceil(minutesRemaining))
                end
            end
            
            SendNUIMessage({
                action = 'UpdateBanTime',
                time = minutesRemaining
            })
        end
        
        SendNUIMessage({
            action = 'HideBanUI'
        })
        
        if not isTest then
            TriggerServerEvent("un_misc:BanArmi:Update", 0)
        end
        
        banAttivo = false
        SecondiDiUpdate = 0
        
        if not isTest and not isReload then
            ESX.ShowNotification('Il ban armi è terminato')
        end
    end)
end

RegisterNetEvent("check:ban:loadRes", function()
    TriggerServerEvent("un_misc:BanArmi:Check")
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function() 
    Citizen.Wait(3000)
    TriggerServerEvent("un_misc:BanArmi:Check")
end)

RegisterNetEvent("un_misc:BanArmi:Apply", function(timeInMinutes, reason, isReload) 
    ApplyBanArmi(timeInMinutes, reason, false, isReload)
end)

RegisterNetEvent("un_misc:BanArmi:Remove", function()
    if banAttivo then
        SendNUIMessage({
            action = 'HideBanUI'
        })
        banAttivo = false
        SecondiDiUpdate = 0
        ESX.ShowNotification('Il ban armi è stato rimosso')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if banAttivo then
            local minutesRemaining = (banTimeRemaining or 0) / 60
            TriggerServerEvent("un_misc:BanArmi:Update", math.ceil(minutesRemaining))
        end
    end
end)