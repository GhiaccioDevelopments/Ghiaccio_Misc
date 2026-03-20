local ESX = exports["es_extended"]:getSharedObject()

-- FUNCTIONS

function CreateMarker(k,v, tipo)
    if tipo == "raccolta" then
        TriggerEvent('gridsystem:registerMarker', {
            name = 'raccolta_'..k,
            pos = v.markerPos,
            type = v.marker.type,
            color = v.marker.color,
            scale = vec3(0.2,0.2,0.2),
            size = vector3(0.6,0.6,0.6),
            control = 'E',
            msg = v.label,
            action = function()
                Raccolta(v)
            end
        })
    else
        TriggerEvent('gridsystem:registerMarker', {
            name = 'processo_'..k,
            pos = v.pos,
            type = v.marker.type,
            color = v.marker.color,
            scale = vec3(0.2,0.2,0.2),
            size = vector3(0.6,0.6,0.6),
            control = 'E',
            msg = v.label,
            action = function()
                Processo(v)
            end
        })
    end
end

function CreateTarget(k,v, tipo)
    local options = {
        {
            label = v.label,
            icon = v.icon,
            onSelect = function()
                if tipo == "raccolta" then
                    Raccolta(v)
                else
                    Processo(v)
                end
            end
        }
    }
    if tipo == "raccolta" then
        pos = v.markerPos
    else
        pos = v.pos
    end
    exports.ox_target:addBoxZone({
        coords = pos,
        size = vec3(1.5,1.5,1.5),
        options = options
    })
end

----------------------

function creablipmappa(coords, sprite, scale, color, name)
    local blip = AddBlipForCoord(coords.x, coords.y, 130.51)
    SetBlipSprite (blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour (blip, color)
    SetBlipAsShortRange(blip, true)
    AddTextEntry('b'..coords.x, name)
    BeginTextCommandSetBlipName("b"..coords.x)
    EndTextCommandSetBlipName(blip)
end

function Raccolta(v) 
    if lib.progressCircle({
    duration = v.progress.tempodiraccolta,
    label = v.progress.label,
    position = v.progress.position,
    useWhileDead = v.progress.useWhileDead,
    canCancel = v.progress.canCancel,
    disable = v.progress.disable,
    anim = v.progress.anim,
    prop = v.progress.prop,
    }) then 
        if v.raccoltaLoop then
            RaccoltaComplete(v)
            Raccolta(v)
        else
            RaccoltaComplete(v)
        end
    end
end

function Processo(v) 
    if lib.progressCircle({
    duration = v.progress.tempodiprocesso,
    label = v.progress.label,
    position = v.progress.position,
    useWhileDead = v.progress.useWhileDead,
    canCancel = v.progress.canCancel,
    disable = v.progress.disable,
    anim = v.progress.anim,
    prop = v.progress.prop,
    }) then 
        if v.processoLoop then
            ProcessoComplete(v)
            Processo(v)
        else
            ProcessoComplete(v)
        end
    end
end

function RaccoltaComplete(v)
    if v.count.num == "random" then
        local random = math.random(v.count.min, v.count.max)
        v.count.val = random
    else
        v.count.val = v.count.num
    end
    TriggerServerEvent("raccolta_sv", v.itemname, v.count.val)
end

function ProcessoComplete(v)
    TriggerServerEvent("processo_sv", v.ricetta, v.itemname, v.count)
end

function creaPed(model, coordx, coordy, coordz, coordw)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    local ped = CreatePed(4, model, coordx, coordy, coordz, coordw, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    return ped
end

function creaTargetPed(k,v)
    local ped = creaPed(v.pedmodel, v.pos.x, v.pos.y, v.pos.z, v.pos.w - 1.0)
    local options = {
        {
            label = v.label,
            icon = v.icon,
            onSelect = function()
                Raccolta(v)
            end
        }
    }
    exports.ox_target:addLocalEntity(ped, options)
end

-- FUNCTIONS

-- Raccolta

Citizen.CreateThread(function() 
    for k,v in pairs(Config.Droghe.Raccolta) do
        if v.blip.show then
            creablipmappa(v.markerPos or v.pos, v.blip.sprite, v.blip.scale, v.blip.color, v.label)
        end
        if v.method == "marker" then
            CreateMarker(k,v, "raccolta")
        elseif v.method == "ox_target" then
            CreateTarget(k,v, "raccolta")
        else
            creaTargetPed(k,v)
        end
    end
end)




-- Processo


Citizen.CreateThread(function()  -- Crea processi
    for k,v in pairs(Config.Droghe.Processo) do
        if v.blip.show then
            creablipmappa(v.markerPos, v.blip.sprite, v.blip.scale, v.blip.color, v.label)
        end

        if v.method == "ox_target" then
            CreateTarget(k,v, "processo")
        else
            CreateMarker(k,v, "processo")
        end

    end
end)

