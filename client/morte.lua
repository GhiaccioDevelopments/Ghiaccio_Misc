local deathFlag = false
local isDead = false
local deathCoords = nil
local deathHeading = nil
local ESX = exports.es_extended:getSharedObject()
local dottoriChiamati = false
local DeathTimer = 300
local stopAnim = false

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


local OptionsRevive = {
    {
        label = "Rianima",
        name = "revive",
        icon = "fa-solid fa-heart-pulse",
        distance = 2.0,
        groups = "ambulance",
        onSelect = function(data)
            --print(json.encode(data))
            TriggerEvent("un_misc:revivePlayerTarget", data.entity, data.coords, GetEntityCoords(PlayerPedId()), GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId())))
        end
    }

}

local OptionsHeal = {
    {
        label = "Cura",
        name = "heal",
        icon = "fa-solid fa-hand-holding-medical",
        distance = 3.0,
        groups = "ambulance",
        onSelect = function(data)
            TriggerEvent("un_misc:request_heal", data.entity)
        end
    },

}

function loadDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
        RequestAnimDict(dict)
    end
end

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local isDeadNow = IsEntityDead(ped)
        if isDeadNow and not deathFlag then
            deathFlag = true
            deathCoords = GetEntityCoords(ped, true)
            deathHeading = GetEntityHeading(ped)
            OnDeath()
        elseif not isDeadNow and deathFlag then
            deathFlag = false
        end
    end 
end)

CreateThread(function()
    while true do
        Wait(0)
        if isDead then
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, "dead", "dead_a", 3) and not stopAnim then
                TaskPlayAnim(ped, "dead", "dead_a", 1.0, -1.0, -1, 1, 0, false, false, false)
            end
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 200, true)
            EnableControlAction(0, 21, true)
            EnableControlAction(0, 22, true)
            EnableControlAction(0, 38, true)
            AnimpostfxPlay('RampageOut', 100000000, true)
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
            if (IsControlPressed(0, 21) and IsControlJustPressed(0, 22)) and not dottoriChiamati then
                ExecuteCommand("911ems Ferito in zona, serve assistenza medica!")
                SendNUIMessage({
                    action = 'callMedics'
                })
                ESX.ShowNotification("Hai chiamato i medici!")
                dottoriChiamati = true
            end

            if DeathTimer == 0 then
                if (IsControlPressed(0, 21) and IsControlJustPressed(0, 38)) then
                    RespawnPlayer()
                end
            end
        else
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    exports.ox_target:addGlobalPlayer(OptionsHeal)
    exports.ox_target:addGlobalPlayer(OptionsRevive)
end)

function OnDeath()
    if isDead then return end
    Citizen.Wait(900)
    dottoriChiamati = false
    isDead = true
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    SetEntityInvincible(ped, true)
    SetPlayerInvincible(PlayerId(), true)

    Citizen.CreateThread(function()
        while isDead do
            Wait(1000)
            if DeathTimer > 0 then
                DeathTimer = DeathTimer - 1
            else
                SendNUIMessage({
                    action = 'endtimer'
                })
            end
        end
    end)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, heading)
    ClearPedBloodDamage(ped)

    RequestAnimDict("dead")
    while not HasAnimDictLoaded("dead") do
        Wait(10)
    end

    exports['pma-voice']:overrideProximityCheck(function(player)
        return false
    end)

    SendNUIMessage({
        action = 'showDeath',
        duration = DeathTimer
    })
    TriggerServerEvent("update:death", true)
end

-- RegisterCommand("r", function()
--     RevivePlayer()
-- end)

function RevivePlayer()
    --if not isDead then return end
    isDead = false
    DeathTimer = 300
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    AnimpostfxStop("RampageOut")
    StopAnimTask(ped, "dead", "dead_a", 4.0)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, true)

    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityHealth(ped, GetPedMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    
    Wait(100)
    DoScreenFadeIn(400)

    ESX.SetPlayerData('dead', false)
    TriggerServerEvent("update:death", false)

    exports['pma-voice']:overrideProximityCheck(function(player)
        return true
    end)

    SendNUIMessage({
        action = 'hideDeath'
    })
end

RegisterNetEvent('un_misc:revive', function()
    RevivePlayer()
end)

exports('isDead', function()
    return isDead
end)

RegisterNetEvent("un_misc:revivePlayerTarget", function(entity, victimCoords, doctorCoords, doctorId) 
    local targetPlayerId = NetworkGetPlayerIndexFromPed(entity)
    local targetServerId = GetPlayerServerId(targetPlayerId)
    local victimHeading = GetEntityHeading(entity)
    TriggerServerEvent("RequestRevive", targetServerId, victimCoords, victimHeading ,doctorCoords, doctorId)
end)

RegisterNetEvent("animation:victim")
AddEventHandler("animation:victim", function(playercoords, playerheading)
    stopAnim = true
    playerPed = GetPlayerPed(-1)

    local x, y, z = table.unpack(playercoords)

    SetEntityCoords(GetPlayerPed(-1), x, y, z - 0.50)
    SetEntityHeading(GetPlayerPed(-1), playerheading - 180)

    ClearPedTasksImmediately(playerPed)

    Citizen.Wait(200)

    loadDict("mini@cpr@char_b@cpr_str")
    loadDict("mini@cpr@char_b@cpr_def")

    TaskPlayAnim(playerPed, "mini@cpr@char_b@cpr_def", "cpr_intro", 8.0, 8.0, -1, 0, 0, false, false, false)
    Citizen.Wait(15800 - 900)

    for i = 1, 15, 1 do
        Citizen.Wait(900)
        TaskPlayAnim(playerPed, "mini@cpr@char_b@cpr_str", "cpr_pumpchest", 8.0, 8.0, -1, 0, 0, false, false, false)
    end

    TaskPlayAnim(playerPed, "mini@cpr@char_b@cpr_str", "cpr_success", 8.0, 8.0, 30590, 0, 0, false, false, false)
    Citizen.Wait(30590)
    RevivePlayer()
    stopAnim = false
end)

RegisterNetEvent("animation:doctor")
AddEventHandler(
    "animation:doctor",
    function()
        stopAnim = true

        playerPed = GetPlayerPed(-1)
        ClearPedTasksImmediately(playerPed)

        Citizen.Wait(200)

        loadDict("mini@cpr@char_a@cpr_def")
        loadDict("mini@cpr@char_a@cpr_str")

        TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_def", "cpr_intro", 8.0, 8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(15800 - 900)

        for i = 1, 15, 1 do
            Citizen.Wait(900)
            TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, 8.0, -1, 0, 0, false, false, false)
        end

        TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_str", "cpr_success", 8.0, 8.0, 30590, 0, 0, false, false, false)
        Citizen.Wait(33590 - 3000)

        stopAnim = false
    end
)

-- RegisterNetEvent("un_misc:reviveArea", function(area)
--     local playerPed = PlayerPedId()
--     local playerCoords = GetEntityCoords(playerPed)
--     local players = ESX.Game.GetPlayersInArea(playerCoords, area)
--     for i=1, #players, 1 do
--         RevivePlayer()
--     end
-- end)

RegisterNetEvent("un_misc:request_heal", function(entity)
    local targetPlayerId = NetworkGetPlayerIndexFromPed(entity)
    local victimId = GetPlayerServerId(targetPlayerId)
    local victimHeading = GetEntityHeading(entity)
    if lib.progressCircle({
        duration = 5000,
        label = "Curando giocatore...",
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
            sprint = true,
        },
        anim = {
            dict = "amb@medic@standing@kneel@idle_a",
            clip = "idle_b"
        },
    }) then 
       TriggerServerEvent("RequestHeal", victimId)
    end
end)

RegisterNetEvent("un_misc:heal", function()
    local ped = PlayerPedId()
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local newHealth = math.min(currentHealth + 70, maxHealth)
    SetEntityHealth(ped, newHealth)
    ESX.ShowNotification("Sei stato curato!")
end)


RegisterNetEvent("giveg", function() 
    SetPedArmour(PlayerPedId(), 100)
end)

local show3DText = true

RegisterNetEvent("ghiaccio:show")
AddEventHandler("ghiaccio:show", function()
    if show3DText then
        show3DText = false
    else
        show3DText = true
        Citizen.Wait(15000)
        show3DText = false
    end
end)


function DisplayRespawn(crds, job, steam, id, steamhex)
    local displaying = true
    --print("funzione DisplayRespawn")
    
    Citizen.CreateThread(function()
        Wait(30 * 1000)
        displaying = false
    end)
	
    Citizen.CreateThread(function()
        while displaying do
            Wait(5)
            local pcoords = GetEntityCoords(PlayerPedId())
            if GetDistanceBetweenCoords(crds.x, crds.y, crds.z, pcoords.x, pcoords.y, pcoords.z, true) < 15.0 and show3DText then
                local textSteam = steam or "Undefined"
                if job == "police" then
                    DrawText3DSecondSlog(crds.x, crds.y, crds.z+0.15, "~b~Player Respawnato")
                    DrawText3DSlog(crds.x, crds.y, crds.z, textSteam .. " - ID: " .. id .. " ("..steamhex..")")
                else
                    DrawText3DSecondSlog(crds.x, crds.y, crds.z+0.15, "~r~Player Respawnato")
                    DrawText3DSlog(crds.x, crds.y, crds.z, textSteam .. " - ID: " .. id .. " ("..steamhex..")")
                end
            else
                Citizen.Wait(1)
            end
        end
    end)
end

function DrawText3DSecondSlog(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.45, 0.45)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 0, 0, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

function DrawText3DSlog(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.45, 0.45)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end



function RespawnPlayer()
    local RespawnPlayerCoords = vec3(316.3998, -583.8218, 43.2840)
    local RespawnPoliceCoords = vec3(486.3571, -985.9583, 30.6898)
    local resp = RespawnPlayerCoords
    if playerData.job.name == "police" then
        resp = RespawnPoliceCoords
    end
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("scritta:respawnSV", playerData, coords, false)
    SetEntityCoords(PlayerPedId(), resp.x, resp.y, resp.z, false, false, false, true)
    RevivePlayer()
end

RegisterNetEvent("scritta:respawnCL", function(data) 
    if data.slog then
        DisplaySlog(data.coords, data.steam, data.id, data.steamhex)
        return
    end
    DisplayRespawn(data.coords, data.job, data.steam, data.id, data.steamhex)
end)


function DisplaySlog(crds, steam, id, steamhex)
    local displaying = true
    
    Citizen.CreateThread(function()
        Wait(60 * 1000) -- 1 minuto
        displaying = false
    end)
	
    Citizen.CreateThread(function()
        while displaying do
            Wait(5)
            local pcoords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(crds.x, crds.y, crds.z, pcoords.x, pcoords.y, pcoords.z, true)
            
            if distance < 15.0 and show3DText then
                local textSteam = steam or "Undefined"
                DrawText3DSecondSlog(crds.x, crds.y, crds.z+0.15, "~r~Player Uscito")
                DrawText3DSlog(crds.x, crds.y, crds.z, textSteam .. " - ID: " .. id .. " ("..steamhex..")")
            else
                Citizen.Wait(500)
            end
        end
    end)
end
