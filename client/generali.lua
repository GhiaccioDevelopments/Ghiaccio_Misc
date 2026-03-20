Citizen.CreateThread(function() 
    DisableIdleCamera(true)
    DisableVehiclePassengerIdleCamera(true)
end)

CreateThread(function()
    local stealthKills = {
        "ACT_stealth_kill_a",
        "ACT_stealth_kill_weapon",
        "ACT_stealth_kill_b",
        "ACT_stealth_kill_c",
        "ACT_stealth_kill_d",
        "ACT_stealth_kill_a_gardener"
    }

    for _, killName in ipairs(stealthKills) do
        local hash = GetHashKey(killName)
        RemoveStealthKill(hash, true)
    end
end)

Citizen.CreateThread(function() -- WAYPOINT COLOR
ReplaceHudColourWithRgba(
    142, -- PARAM
    56,  -- R
    178, -- G
    255, -- B
    255  -- A
)
end)

-- Density values from 0.0 to 1.0.
DensityMultiplier = 0.3
Citizen.CreateThread(function()
	while true do
	    Citizen.Wait(0)
	    SetVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetPedDensityMultiplierThisFrame(DensityMultiplier)
	    SetRandomVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetParkedVehicleDensityMultiplierThisFrame(DensityMultiplier)
	    SetScenarioPedDensityMultiplierThisFrame(DensityMultiplier, DensityMultiplier)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 36, true) -- Disabilita accovacciamento per evitare blocco in mira
        local ped = PlayerPedId()
        SetPedStealthMovement(ped, false, "DEFAULT_ACTION")
	end
end)


-------------------- FIX TEXUTURE --------------------

RegisterCommand("fixt", function()
    ESX.ShowNotification("Fix delle texture in corso..")
    CreateThread(function()
        local targetPed = GetPlayerPed(-1)
        local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))
        RequestCollisionAtCoord(targetx, targety, targetz)
        RequestCollisionAtCoord(GetEntityCoords(targetPed))
        ClearAllBrokenGlass()
        ClearAllHelpMessages()
        LeaderboardsReadClearAll()
        ClearBrief()
        ClearGpsFlags()
        ClearPrints()
        ClearSmallPrints()
        ClearReplayStats()
        LeaderboardsClearCacheData()
        ClearFocus()
        ClearHdArea()
        ClearPedBloodDamage(PlayerPedId())
        ClearPedWetness(PlayerPedId())
        ClearPedEnvDirt(PlayerPedId())
        ResetPedVisibleDamage(PlayerPedId())
        while true do
        Wait(0)
        SetNoisinessoveride(0.0)
        SuppressFrontendRenderingThisFrame()
        OverrideLodscaleThisFrame(0.0)
        Wait(1)
        OverrideLodscaleThisFrame(0.0)
        Wait(1)
        OverrideLodscaleThisFrame(0.1)
        Wait(1)
        OverrideLodscaleThisFrame(0.2)
        Wait(1)
        OverrideLodscaleThisFrame(0.3)
        Wait(1)
        OverrideLodscaleThisFrame(0.4)
        Wait(1)
        OverrideLodscaleThisFrame(0.5)
        Wait(1)
        OverrideLodscaleThisFrame(0.6)
        Wait(1)
        OverrideLodscaleThisFrame(0.7)
        Wait(1)
        OverrideLodscaleThisFrame(0.8)
        Wait(1)
        OverrideLodscaleThisFrame(0.9)
        Wait(1)
        OverrideLodscaleThisFrame(1.0)
        break
        end
    end)
end)

-------------------- FIX MENU --------------------

RegisterCommand('fixmenu', function()
    ESX.UI.Menu.CloseAll()
end)

-------------------- FIX NUI --------------------

RegisterCommand('fixnui', function(source, args)
	SetNuiFocus(false, false)
end)

RegisterCommand("propfix", function(source, args, rawCommand)
    local xPlayer = PlayerPedId()
    
   
    function RemoveAttachedObjects(ped)
      

        local handle, object = FindFirstObject()
        local finished = false
        local count = 0

        repeat
            if DoesEntityExist(object) then
                if IsEntityAttachedToEntity(object, ped) then
                    DetachEntity(object, true, true) 
                    SetEntityAsMissionEntity(object, true, true) 
                    DeleteObject(object) 
                    Wait(0) 
                    if not DoesEntityExist(object) then
                        count = count + 1
                       
                    else
                       
                    end
                end
            end
            finished, object = FindNextObject(handle)
        until not finished

        EndFindObject(handle)
        
    end

    RemoveAttachedObjects(xPlayer)
end)

--------------------- CROUCH --------------------

ESX = exports["es_extended"]:getSharedObject()

isDead = false
AddEventHandler('esx:onPlayerDeath', function(data)
    isDead  = true
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
    isDead = false
end)

Player = {
    isDead = false,
    inAnim = false,
    crouched = false,
    pointing = false,
    noclip = false,
    godmode = false,
    ghostmode = false,
    showCoords = false,
    showName = false,
    showDetails = false,
    superVision = false,
    gamerTags = {},
}

RegisterKeyMapping('+crouch', 'Abbassati', 'keyboard', "LCONTROL")
RegisterCommand('+crouch', function()
    Player.crouched = not Player.crouched
    local plyPed = PlayerPedId()
    if Player.crouched then 
        ESX.Streaming.RequestAnimSet('move_ped_crouched', function()
            SetPedMovementClipset(plyPed, 'move_ped_crouched', 0.38)
            RemoveAnimSet('move_ped_crouched')
        end)
        while Player.crouched do
            Wait(1)
            local plyPed2 = PlayerPedId()
            SetPedStealthMovement(plyPed2, false, "")
        end
    else
        ResetPedMovementClipset(plyPed, 0.38)
    end
end, false)

function crouchMovement()
    local plyPed = PlayerPedId()
    ESX.Streaming.RequestAnimSet('move_ped_crouched', function()
        SetPedMovementClipset(plyPed, 'move_ped_crouched', 0.38)
        RemoveAnimSet('move_ped_crouched')
    end)
end

RegisterKeyMapping('+incrocia', 'Incrocia le braccia', 'keyboard', "H")

RegisterCommand('+incrocia', function()
    local playerPed = PlayerPedId()
    if exports.un_misc:isDead() then return end

    if IsPedOnFoot(playerPed) and not IsPedSwimming(playerPed) and not IsPedDeadOrDying(playerPed) then
        local dict = "anim@amb@nightclub@peds@"

        if IsEntityPlayingAnim(PlayerPedId(), dict, 'rcmme_amanda1_stand_loop_cop', 49) then
            ClearPedSecondaryTask(playerPed)
        elseif not IsPlayingAnimation then
            ESX.Streaming.RequestAnimDict(dict, function()
                TaskPlayAnim(playerPed, dict, 'rcmme_amanda1_stand_loop_cop', 8.0, 8.0, -1, 50, 0, false, false, false)
                RemoveAnimDict(dict)
            end)
        end
    end
end, false)
RegisterCommand('-incrocia', function()
end, false)




function loadAnim( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end