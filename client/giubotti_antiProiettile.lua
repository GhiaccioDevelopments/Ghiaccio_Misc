-- FUNCS CREA MARKER E OX_TARGET PER COMPRARE GIUBOTTO ANTIPROIETTILE
----------------------

local ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function() 
    for k,v in pairs(Config.Giubotti) do
        if v.blip.show then
            creablipmappa(v.pos, v.blip.sprite, v.blip.scale, v.blip.color, v.blip.name)
        end

        if v.method == "marker" then
            CreaMarkerGiubotto(k, v)
        else
            CreaTargetGiubotto(k, v)
        end
    end

end)


function CreaMarkerGiubotto(k, v)
    if v.permission.enabled then 
        TriggerEvent('gridsystem:registerMarker', {
            name = 'giubotto'..k,
            pos = v.pos,
            type = v.marker.type,
            color = v.marker.color,
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(0.9,0.9,0.9),
            control = 'E',
            msg = v.textUiLabel,
            permission = v.permission.jobPerms,
            action = function()
                if v.showMenu then
                    OpenMenuGiubotto(k, v)
                else
                    GiveGiubotto(100, v)
                end
            end
        })
    else
        TriggerEvent('gridsystem:registerMarker', {
            name = 'giubotto'..k,
            pos = v.pos,
            type = v.marker.type,
            color = v.marker.color,
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(0.9,0.9,0.9),
            control = 'E',
            msg = v.textUiLabel,
            action = function()
                if v.showMenu then
                    OpenMenuGiubotto(k, v)
                else
                    GiveGiubotto(100, v)
                end
            end
        })
    end
end

function CreaTargetGiubotto(k, v)
    local options = {
        {
            label = v.textUiLabel,
            icon = v.icon,
            onSelect = function()
                if v.showMenu then
                    OpenMenuGiubotto(k, v)
                else
                    GiveGiubotto(100, v)
                end
            end
        }
    }
    exports.ox_target:addBoxZone({
        coords = v.pos,
        size = vec3(1.5,1.5,1.5),
        groups = v.permission.enabled and {v.permission.jobPerms} or nil,
        options = options
    })
end




-- FUNCS CREA MARKER E OX_TARGET PER COMPRARE GIUBOTTO ANTIPROIETTILE


function GiveGiubotto(percent, v)
    if GetPedArmour(PlayerPedId()) >= percent then 
        ESX.ShowNotification("Hai già un giubotto addosso!")
        return
    end
    if v.haveToPay then
        if exports.ox_inventory:Search("count", "money") < v.menu[tostring(percent)].price then
            ESX.ShowNotification("Non hai abbastanza soldi contanti per comprare questo giubotto!")
            return
        end
    end
    if lib.progressCircle({
        position = v.progress.position,
        duration = v.progress.tempoIndossamento,
        label = v.progress.label,
        useWhileDead = v.progress.useWhileDead,
        canCancel = v.progress.canCancel,
        allowRagdoll = v.progress.allowRagdoll,
        allowSwimming = v.progress.allowSwimming,
        allowCuffed = v.progress.allowCuffed,
        allowFalling = v.progress.allowFalling,
        disable = {
            car = v.progress.disable.car,
            move = v.progress.disable.move,
            combat = v.progress.disable.combat,
            mouse = v.progress.disable.mouse
        },
        anim = {
            dict = v.progress.anim.dict,
            clip = v.progress.anim.clip,
        },
    }) then
        SettaArmatura(percent)
        TriggerServerEvent("Giubotto_Buyed", percent, v)
    end
end

function SettaArmatura(percent)
    local playerPed = PlayerPedId()
    newArmour = percent
    SetPedArmour(playerPed, newArmour)
    TriggerServerEvent("armour:logs", percent)
end

function OpenMenuGiubotto(k, v)
    local opt = {}
    for j,i in pairs(v.menu) do 
        table.insert(opt, {
            title = i.label  .. " - $" .. i.price,
            onSelect = function()
                GiveGiubotto(tonumber(j), v)
            end
        })
    end
    lib.registerContext({
        id = 'giubotto_menu'..k,
        title = 'Giubotto Antiproiettile',
        options = opt
    })
    lib.showContext('giubotto_menu'..k)
end