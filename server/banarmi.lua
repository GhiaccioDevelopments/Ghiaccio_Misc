local BanArmiAttivo = {}
local ESX = exports.es_extended:getSharedObject()

RegisterCommand("banarmi", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and (xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "mod") then
        local targetId = tonumber(args[1])
        local timeInMinutes = tonumber(args[2])
        local reason = table.concat(args, " ", 3)

        if targetId and timeInMinutes and reason and reason ~= "" then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            
            if targetPlayer then
                local identifier = targetPlayer.identifier
                
                BanArmiAttivo[identifier] = {
                    timeRemaining = timeInMinutes,
                    reason = reason,
                }
                
                SaveBansToKVP()
                
                TriggerClientEvent("un_misc:BanArmi:Apply", targetId, timeInMinutes, reason)
                
                TriggerClientEvent("esx:showNotification", source, 
                    "Ban armi applicato a " .. GetPlayerName(targetId) .. 
                    " per " .. timeInMinutes .. " minuti. Motivo: " .. reason)
            else
                TriggerClientEvent("esx:showNotification", source, "Player non trovato", "error")
            end
        else
            TriggerClientEvent("esx:showNotification", source, 
                "Uso: /banarmi [ID] [Minuti] [Motivo]", "error")
        end
    else
        TriggerClientEvent("esx:showNotification", source, 
            "Non hai i permessi per questo comando", "error")
    end
end)

RegisterServerEvent("un_misc:BanArmi:Check")
AddEventHandler("un_misc:BanArmi:Check", function()
    local source = source
    
    Citizen.Wait(500)
    
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local identifier = xPlayer.identifier
        local banInfo = BanArmiAttivo[identifier]
        
        if banInfo and banInfo.timeRemaining > 0 then
            TriggerClientEvent("un_misc:BanArmi:Apply", source, banInfo.timeRemaining, banInfo.reason, true)
        end
    else
        Citizen.Wait(2000)
        xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local identifier = xPlayer.identifier
            local banInfo = BanArmiAttivo[identifier]
            
            if banInfo and banInfo.timeRemaining > 0 then
                TriggerClientEvent("un_misc:BanArmi:Apply", source, banInfo.timeRemaining, banInfo.reason, true)
            end
        end
    end
end)

RegisterServerEvent("un_misc:BanArmi:Update")
AddEventHandler("un_misc:BanArmi:Update", function(timeRemainingMinutes)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local identifier = xPlayer.identifier
        local banInfo = BanArmiAttivo[identifier]
        
        if banInfo then
            if timeRemainingMinutes <= 0 then
                BanArmiAttivo[identifier] = nil
                SaveBansToKVP()
            else
                BanArmiAttivo[identifier].timeRemaining = timeRemainingMinutes
                SaveBansToKVP()
            end
        end
    end
end)

-- Comando per rimuovere un ban armi
RegisterCommand("unbanarmi", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and (xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "mod") then
        local targetId = tonumber(args[1])
        
        if targetId then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            
            if targetPlayer then
                local identifier = targetPlayer.identifier
                
                if BanArmiAttivo[identifier] then
                    BanArmiAttivo[identifier] = nil
                    SaveBansToKVP()
                    
                    TriggerClientEvent("un_misc:BanArmi:Remove", targetId)
                    
                    TriggerClientEvent("esx:showNotification", source, 
                        "Ban armi rimosso da " .. GetPlayerName(targetId))
                    TriggerClientEvent("esx:showNotification", targetId, 
                        "Il tuo ban armi è stato rimosso")
                else
                    TriggerClientEvent("esx:showNotification", source, 
                        "Questo player non ha un ban armi attivo", "error")
                end
            else
                TriggerClientEvent("esx:showNotification", source, "Player non trovato", "error")
            end
        else
            TriggerClientEvent("esx:showNotification", source, 
                "Uso: /unbanarmi [ID]", "error")
        end
    else
        TriggerClientEvent("esx:showNotification", source, 
            "Non hai i permessi per questo comando", "error")
    end
end)

function SaveBansToKVP()
    SetResourceKvp("BanArmiAttivo", json.encode(BanArmiAttivo))
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local savedData = GetResourceKvpString("BanArmiAttivo")
        if savedData then
            BanArmiAttivo = json.decode(savedData)
        end
        
        Citizen.CreateThread(function()
            Citizen.Wait(2000)
            
            local xPlayers = ESX.GetExtendedPlayers()
            for _, xPlayer in pairs(xPlayers) do
                local identifier = xPlayer.identifier
                local banInfo = BanArmiAttivo[identifier]
                
                if banInfo and banInfo.timeRemaining > 0 then
                    TriggerClientEvent("un_misc:BanArmi:Apply", xPlayer.source, banInfo.timeRemaining, banInfo.reason, true)
                end
            end
        end)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveBansToKVP()
    end
end)

function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local identifier = xPlayer.identifier
        if BanArmiAttivo[identifier] then
            SaveBansToKVP()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000)
        SaveBansToKVP()
    end
end)