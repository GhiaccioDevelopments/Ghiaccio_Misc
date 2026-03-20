local ESX = exports.es_extended:getSharedObject()
local piani = {}
Citizen.CreateThread(function() 
    for nomeAscensore, ascensore in pairs(Config.Elevators) do
        for k, v in pairs(ascensore.coordinateAscensori) do
            table.insert(piani, {
                title = v.piano,
                icon = "elevator",
                onSelect = function() 
                    DoScreenFadeOut(Config.BlackScreentime)
                    Citizen.Wait(Config.BlackScreentime)
                    DoScreenFadeIn(Config.FadeInTrans)
                    SetEntityCoords(PlayerPedId(), v.coords.x, v.coords.y, v.coords.z, 0, 0, 0, 0)
                end
            })
            if Config.UseMarker then
                TriggerEvent('gridsystem:registerMarker', {
                    name = nomeAscensore..'_ascensore'..k,
                    pos = v.coords,
                    type = 2,
                    color = { r = 0, g = 0, b = 0, a = 100 },
                    scale = vector3(0.50, 0.50, 0.50),
                    size = vector3(0.7, 0.7, 0.7),
                    control = 'E',
                    msg = '[E] - Accedi all\'ascensore: '..v.piano,
                    action = function()
                        if Config.NeedToBeAlive then
                            if not exports.un_misc:isDead() then
                                ApriElevatorMenu(v.piano)
                            else
                                ESX.ShowNotification("Sei morto, non puoi usare l'ascensore")
                            end
                        else
                            ApriElevatorMenu(v.piano)
                        end
                    end
                })
            elseif Config.UseTarget then
                exports.ox_target:addBoxZone({
                    coords = v.coords,
                    size = vec3(2, 2, 2),
                    rotation = 45,
                    options = {
                        {
                            event = "ghiaccio:openElevatorMenu",
                            icon = "fa-solid fa-elevator",
                            label = "Accedi all'ascensore",
                            store = v.piano
                        }
                    }
                })
            end
        end
    end
end)


RegisterNetEvent("ghiaccio:openElevatorMenu", function(data) 
    if Config.NeedToBeAlive then
        if not exports.un_misc:isDead() then
            ApriElevatorMenu(data.store)
        else
            ESX.ShowNotification("Sei morto, non puoi usare l'ascensore")
        end
    else
        ApriElevatorMenu(data.store)
    end
end)


function ApriElevatorMenu(pianoCorrente) 
    lib.registerContext({
        id = "Ascensore",
        title = "Ascensore - "..pianoCorrente,
        options = piani
    })
    lib.showContext("Ascensore")
end


