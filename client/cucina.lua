local ESX = exports["es_extended"]:getSharedObject()

-- Creazione Cucine
Citizen.CreateThread(function()
    for k, v in pairs(Config.Locali) do
        TriggerEvent('gridsystem:registerMarker', {
            name = 'cucina' .. k,
            pos = v.cucina.pos,
            type = v.cucina.marker.type,
            color = v.cucina.marker.color,
            scale = v.cucina.marker.scale,
            size = vector3(1.5, 1.5, 1.5),
            control = 'E',
            msg = '[E] - Cucina',
            permission = k,
            action = function()
                ApriCucina(k)
            end
        })
    end
end)

function ApriCucina(locale)
    lib.registerContext({
        id = 'cucina' .. locale,
        title = 'Cucina',
        options = {
            {
                title = 'Prepara cibi',
                icon = 'fa-solid fa-burger',
                onSelect = function()
                    ShowCibiMenu(locale)
                end
            },
            {
                title = 'Prepara bevande',
                icon = 'fa-solid fa-wine-glass',
                onSelect = function()
                    ShowBevandeMenu(locale)
                end
            }
        }
    })
    lib.showContext('cucina' .. locale)
end

function ShowCibiMenu(locale)
    local cibi = Config.Locali[locale].menu.cibi
    local options = {}
    
    for itemKey, itemData in pairs(cibi) do
        table.insert(options, {
            title = itemData.label,
            icon = itemData.icon,
            onSelect = function()
                ShowOpzioniMenu(locale, itemKey, itemData, 'cibi')
            end
        })
    end
    
    lib.registerContext({
        id = 'cibi' .. locale,
        title = 'Cibi',
        options = options
    })
    lib.showContext('cibi' .. locale)
end

function ShowBevandeMenu(locale)
    local bevande = Config.Locali[locale].menu.bevande
    local options = {}
    
    for itemKey, itemData in pairs(bevande) do
        table.insert(options, {
            title = itemData.label,
            icon = itemData.icon,
            onSelect = function()
                ShowOpzioniMenu(locale, itemKey, itemData, 'bevande')
            end
        })
    end
    
    lib.registerContext({
        id = 'bevande' .. locale,
        title = 'Bevande',
        options = options
    })
    lib.showContext('bevande' .. locale)
end

function ShowOpzioniMenu(locale, itemKey, itemData, tipo)
    lib.registerContext({
        id = "opzioni_" .. itemKey .. locale,
        title = "Opzioni " .. itemData.label,
        options = {
            {
                title = 'Cucina',
                icon = "fa-solid fa-utensils",
                onSelect = function()
                    ChiediQuantita(locale, itemKey, itemData)
                end
            },
            {
                title = 'Visualizza ingredienti',
                icon = "fa-solid fa-list",
                onSelect = function()
                    ShowIngredientiMenu(locale, itemKey, itemData)
                end
            }
        }
    })
    lib.showContext("opzioni_" .. itemKey .. locale)
end

function ShowIngredientiMenu(locale, itemKey, itemData)
    local ingOptions = {}
    
    table.insert(ingOptions, {
        title = "Indietro",
        icon = "fa-solid fa-arrow-left",
        onSelect = function()
            lib.showContext("opzioni_" .. itemKey .. locale)
        end
    })
    
    for _, ingredient in ipairs(itemData.ingredients) do
        local hasItem = exports.ox_inventory:Search("count", ingredient.item) >= 1
        local info = hasItem and "✅" or "❌"
        table.insert(ingOptions, {
            title = info .. " " .. ingredient.label
        })
    end
    
    lib.registerContext({
        id = "ingredienti_" .. itemKey .. locale,
        title = "Ingredienti " .. itemData.label,
        options = ingOptions
    })
    lib.showContext("ingredienti_" .. itemKey .. locale)
end

function ChiediQuantita(locale, itemKey, itemData)
    local input = lib.inputDialog('Cucina ' .. itemData.label, {
        {
            type = 'number', 
            label = 'Quantità', 
            description = 'Inserisci la quantità',
            required = true,
            min = 1,
            max = 10
        }
    })

    if not input or not input[1] then return end
    
    local quantity = tonumber(input[1])
    if not quantity or quantity < 1 then 
        ESX.ShowNotification("Quantità non valida")
        return 
    end

    for _, ingredient in pairs(itemData.ingredients) do
        local needed = quantity
        local has = exports.ox_inventory:Search('count', ingredient.item)
        if has < needed then
            ESX.ShowNotification("Non hai abbastanza " .. ingredient.label)
            return
        end
    end
    
    PreparaPiatto(locale, itemKey, itemData, quantity)
end

function PreparaPiatto(locale, itemKey, itemData, quantity)
    local ped = PlayerPedId()
    local fornelliPos = Config.Locali[locale].cucina.fornelliPos
    SetPedMoveRateOverride(ped, 0.5)
    TaskGoStraightToCoord(ped, fornelliPos.x, fornelliPos.y, fornelliPos.z, 1.0, -1, 0.0, 0.0)
    repeat
        Citizen.Wait(100)
        local pedPos = GetEntityCoords(ped)
        local distance = #(vec3(pedPos.x, pedPos.y, pedPos.z) - vec3(fornelliPos.x, fornelliPos.y, fornelliPos.z))
    until distance < 1.0
    
    SetPedMoveRateOverride(ped, 1.0)
    SetEntityHeading(ped, fornelliPos.w)
    Citizen.Wait(300)

    if lib.progressCircle({
        duration = 7000,
        label = 'Preparando ' .. quantity .. ' ' .. itemData.label,
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "anim@amb@business@coc@coc_unpack_cut@",
            clip = "fullcut_cycle_v1_cokecutter",
        },
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then 
        TriggerServerEvent("cucinato", itemKey, quantity, locale)
    else
        ESX.ShowNotification("Preparazione annullata")
    end
end