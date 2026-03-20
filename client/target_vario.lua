local ESX = exports["es_extended"]:getSharedObject()

local options = {
    {
        label = "Controlla ID",
        icon = "fa-solid fa-id-card",
        onSelect = function(data) 
            local targetPlayerId = NetworkGetPlayerIndexFromPed(data.entity)
            local targetServerId = GetPlayerServerId(targetPlayerId)
            ESX.ShowNotification("ID: " .. targetServerId)
        end
    },
    {
        label = "Perquisisci",
        icon = "fa-solid fa-people-robbery",
        onSelect = function(data)
            --print(json.encode(data))
            
            TriggerEvent("un_misc:Loot:Client", data)
        end
    },
}

Citizen.CreateThread(function() 
    exports.ox_target:addGlobalPlayer(options)
end)

function isdeadorhandsup(ped) 
    if IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3) 
    or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) 
    or IsEntityPlayingAnim(ped, 'dead', 'dead_b', 3) 
    or IsEntityPlayingAnim(ped, 'dead', 'dead_c', 3) 
    or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3) 
    or IsEntityPlayingAnim(ped, 'random@arrests@busted', 'enter', 3) 
    or IsEntityPlayingAnim(ped, 'random@arrests', 'kneeling_arrest_idle', 3) 
    or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) 
    or IsEntityPlayingAnim(ped, 'random@arrests@busted', 'idle_c', 3) 
    or IsEntityPlayingAnim(ped, 'random@burial', 'b_burial', 3) then
    return true
    else
        return false
    end
end

AddEventHandler('un_misc:Loot:Client', function(data)
    --print(json.encode(data))
    local targetId = NetworkGetPlayerIndexFromPed(data.entity)
    local tPed = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    local targetName = GetPlayerName(GetPlayerFromServerId(tPed))
    local playerIdx = GetPlayerFromServerId(tonumber(tPed))
    local ped = GetPlayerPed(playerIdx)
    if isdeadorhandsup(ped) then
        TriggerServerEvent('un_misc:Loot:Server', tPed)
        ExecuteCommand('me Sta tentando una ~p~perquisizione...~w~')
        TriggerEvent("ox_inventory:openInventory", "player", tPed)
    else
        ESX.ShowNotification('Il giocatore non ha le mani alzate o non è morto', 'error')
    end
end)
