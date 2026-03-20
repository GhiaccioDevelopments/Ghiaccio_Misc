local ESX = exports.es_extended:getSharedObject()


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



Citizen.CreateThread(function()
    for k,v in pairs(Config.MarkerCibi) do 
        creablipmappa(v.pos, 605, 0.8, 1, "Cotto e Mangiato")
        TriggerEvent('gridsystem:registerMarker', {
            name = 'markerCibo'..k,
            pos = v.pos,
            type = 29,
            color = { r = 0, g = 255, b = 0 },
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(1.5,1.5,1.5),
            control = 'E',
            msg = '[E] - Acquista Cibo ',
            action = function()
                TriggerEvent('un:fullstatus')
            end
        })
    end
end)

RegisterNetEvent("un:fullstatus", function()
    ESX.TriggerServerCallback("getMoney", function(data)
        lib.registerContext({
            id = 'sceltaPagamentoCibo',
            title = 'Scegli Pagamento',
            options = {
                {
                    title = 'Paga ' .. Config.PrezzoFullStats .. '$ con la banca',
                    icon = 'vault',
                    onSelect = function() 
                        if data.soldiBanca >= Config.PrezzoFullStats then
                            TriggerServerEvent("RemoveMoneyFromBank", Config.PrezzoFullStats)
                            ESX.ShowNotification("Ti sei saziato correttamente!")
                            exports["un_metabolism"]:SetStatus('hunger', 100)
                            exports["un_metabolism"]:SetStatus('thirst', 100)
                        else
                            ESX.ShowNotification("Non hai abbastanza soldi in banca!", 'error')
                        end
                    end
                },
                {
                    title = "Paga " .. Config.PrezzoFullStats .. "$ con i contanti",
                    icon = "money-bill", 
                    onSelect = function() 

                        if data.soldiContanti >= Config.PrezzoFullStats then
                            TriggerServerEvent("RemoveMoneyContanti", Config.PrezzoFullStats)
                            ESX.ShowNotification("Ti sei saziato correttamente!")
                            exports["un_metabolism"]:SetStatus('hunger', 100)
                            exports["un_metabolism"]:SetStatus('thirst', 100)
                        else
                            ESX.ShowNotification("Non hai abbastanza soldi in contanti!")
                        end

                    end
                }
            }
        })
        lib.showContext("sceltaPagamentoCibo")
    end)
end)