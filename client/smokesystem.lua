local ESX = exports.es_extended:getSharedObject()

local Config = {
    propModel = `prop_cs_ciggy_01b`,
    handBone = 28422,
    offsetHand = vec3(0.02, 0.0, -0.02),
    rotationHand = vec3(90.0, 0.0, 0.0),
    maxPuffs = 10,
    smoke = { asset = "core", name = "exp_grd_bzgas_smoke", scale = 0.35, bone = 28422 },
    sparks = { asset = "core", name = "bul_glass", scale = 0.2, bone = 28422 }
}

local cigaretteProp = nil
local isSmoking = false
local isPuffing = false
local currentPuffs = 0

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

local function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

local function LoadPtfx(asset)
    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do Wait(10) end
end

local function AttachCigarette(ped)
    if not DoesEntityExist(cigaretteProp) then
        LoadModel(Config.propModel)
        cigaretteProp = CreateObject(Config.propModel, 0.0, 0.0, 0.0, true, true, false)
        SetEntityCollision(cigaretteProp, false, false)
        SetEntityCompletelyDisableCollision(cigaretteProp, true)
        SetEntityInvincible(cigaretteProp, true)
    end
    AttachEntityToEntity(cigaretteProp, ped, GetPedBoneIndex(ped, Config.handBone),
        Config.offsetHand.x, Config.offsetHand.y, Config.offsetHand.z,
        Config.rotationHand.x, Config.rotationHand.y, Config.rotationHand.z,
        true, true, false, true, 1, true)
end

local function RemoveCigarette()
    if DoesEntityExist(cigaretteProp) then
        DeleteEntity(cigaretteProp)
        cigaretteProp = nil
    end
end

local function PlayLighting(ped)
    LoadAnim("amb@world_human_smoking@male@male_a@enter")
    TaskPlayAnim(ped, "amb@world_human_smoking@male@male_a@enter", "enter", 8.0, -8.0, -1, 49, 0, false, false, false)
end

local function PlayIdle(ped)
    LoadAnim("amb@world_human_smoking@male@male_a@idle_a")
    TaskPlayAnim(ped, "amb@world_human_smoking@male@male_a@idle_a", "idle_a", 4.0, -4.0, -1, 49, 0, false, false, false)
end

local function PlaySparks(ped)
    LoadPtfx(Config.sparks.asset)
    UseParticleFxAssetNextCall(Config.sparks.asset)
    local fx = StartParticleFxLoopedOnPedBone(Config.sparks.name, ped, 0.03, 0.0, 0.0, 0.0, 0.0, 0.0, Config.sparks.bone, Config.sparks.scale, false, false, false)
    SetTimeout(1200, function() if fx then StopParticleFxLooped(fx, false) end end)
end

local function PlaySmoke(ped)
    LoadPtfx(Config.smoke.asset)
    UseParticleFxAssetNextCall(Config.smoke.asset)
    local fx = StartParticleFxLoopedOnPedBone(Config.smoke.name, ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.smoke.bone, Config.smoke.scale, false, false, false)
    SetTimeout(4000, function() if fx then StopParticleFxLooped(fx, false) end end)
end

local function PlayExit(ped)
    LoadAnim("timetable@gardener@smoking_joint")
    TaskPlayAnim(ped, "timetable@gardener@smoking_joint", "idle_cough", 8.0, -8.0, -1, 49, 0, false, false, false)
    FreezeEntityPosition(ped, true)
    Citizen.Wait(4500)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    exports["jg-textui"]:HideText()
end

local function PlayPuff(ped)
    LoadAnim("amb@world_human_aa_smoke@male@idle_a")
    TaskPlayAnim(ped, "amb@world_human_aa_smoke@male@idle_a", "idle_c", 3.0, -3.0, 5000, 49, 0, false, false, false)
    SetTimeout(1500, function() if isSmoking then PlaySmoke(ped) end end)
    SetTimeout(5000, function() if isSmoking then PlayIdle(ped) end end)
end

local function StopSmoking(msg)
    local ped = PlayerPedId()
    isSmoking = false
    isPuffing = false
    currentPuffs = 0
    RemoveCigarette()
    exports["jg-textui"]:HideText()
    PlayExit(ped)
    if msg then ESX.ShowNotification(msg) end
end

local function DoPuff(ped)
    if isPuffing or not isSmoking then return end
    isPuffing = true
    currentPuffs += 1
    if currentPuffs >= Config.maxPuffs then
        PlayPuff(ped)
        SetTimeout(5500, function()
            StopSmoking("Hai finito la sigaretta.")
        end)
    else
        PlayPuff(ped)
        exports.un_metabolism:RemoveToStatus("stress", 10)
        SetTimeout(5200, function()
            isPuffing = false
        end)
    end
end

RegisterNetEvent('ghiaccio:client:usa-sigaretta', function()
    local ped = PlayerPedId()
    if isSmoking then ESX.ShowNotification("Stai già fumando.") return end
    if exports.ox_inventory:Search("count", "accendino") < 1 then
        ESX.ShowNotification("Non hai un accendino.")
        return
    end
    if exports.ox_inventory:Search("count", "sigaretta") < 1 then
        TriggerServerEvent("notSigaretta")
        return
    end
    AttachCigarette(ped)
    PlayLighting(ped)
    local success = exports.ox_lib:progressCircle({
        duration = 15500,
        label = "Accendendo la sigaretta...",
        canCancel = true,
        position = "bottom",
        disable = { move = false, car = true, combat = true }
    })
    ClearPedTasks(ped)
    if not success then RemoveCigarette() return end
    TriggerServerEvent("server:sigaretta")
    isSmoking = true
    currentPuffs = 0
    PlayIdle(ped)
    CreateThread(function()
        while isSmoking do
            Wait(0)
            exports["jg-textui"]:DrawText("[E] Fuma | [G] Smetti")
            if IsControlJustPressed(0, 38) then DoPuff(ped)
            elseif IsControlJustPressed(0, 47) then StopSmoking("Hai smesso di fumare.") end
        end
    end)
end)

RegisterNetEvent('ghiaccio:client:usa-pacchetto-sigarette', function()
    local success = exports.ox_lib:progressCircle({
        duration = 3500,
        label = "Scartando pacchetto...",
        canCancel = true,
        position = "bottom",
        disable = { move = false, car = true, combat = true },
        anim = {
            dict = "missheistdockssetup1ig_4@end_idle",
            clip = "floyd_fellpackage_endidle_dockworker2",
        }
    })
    if not success then return end
    TriggerServerEvent("ghiaccio:server:usa-pacchetto-sigarette")
end)
