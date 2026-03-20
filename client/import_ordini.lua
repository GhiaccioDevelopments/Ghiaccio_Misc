local ESX = exports['es_extended']:getSharedObject()
local requestedItems = {}
local requestedItemsByCategory = {}

local function CreateMarkerImportReq(k,v) 
    TriggerEvent('gridsystem:registerMarker', {
        name = 'importrequest_'..k,
        pos = v.pos,
        type = v.marker.type,
        color = v.marker.color,
        scale = v.marker.scale,
        size = vector3(0.7,0.7,0.7),
        control = 'E',
        msg = '[E] - Menu Import',
        permission = k,
        jobGrade = v.minGrade,
        action = function()
            OpenMenuImportReq(k,v)
        end
    })
end

Citizen.CreateThread(function() 
    for k,v in pairs(Config.ImportPos) do 
        if v.pos then
            CreateMarkerImportReq(k, v)
        end
    end
end)

function OpenMenuImportReq(k,v) 
    if not requestedItemsByCategory[k] then
        requestedItemsByCategory[k] = {}
    end
    
    local options = {}
    local totalPrice = 0
    for i = 1, #v.itemsRequest do 
        local isRequested = requestedItemsByCategory[k][i]
        if isRequested then
            totalPrice = totalPrice + (v.itemsRequest[i].price * isRequested)
        end
    end

    table.insert(options, {
        title = "Totale: ".. totalPrice .. "$",
        icon = "cash",
        disabled = true,
    })
    table.insert(options, {
        title = "Rimuovi tutte le richieste",
        icon = "trash",
        description = "Rimuovi tutte le richieste fatte in precedenza",
        onSelect = function()
            requestedItemsByCategory[k] = {}
            requestedItems = {}
            OpenMenuImportReq(k, v)
        end,
    })
    for i = 1, #v.itemsRequest do 
        local isRequested = requestedItemsByCategory[k][i]
        
        table.insert(options, {
            title = v.itemsRequest[i].label,
            icon = v.itemsRequest[i].icon,
            description = isRequested and ("Richiesto x" .. isRequested) or ("Richiedi " .. v.itemsRequest[i].label),
            onSelect = function()
                if isRequested then
                    return ESX.ShowNotification("Hai già richiesto questo item")
                end
                
                local input = lib.inputDialog('Quantità', {{type = 'number', label = 'Quantità', description = 'Inserisci la quantità di '..v.itemsRequest[i].label.. " da richiedere", icon = 'hashtag'},})
                if not input then return end
                local quantity = tonumber(input[1])
                if not quantity or quantity <= 0 then 
                    return lib.notify({
                        title = "Quantità non valida",
                        description = "Per favore inserisci una quantità valida per richiedere l'item.",
                        type = "error"
                    })
                end
                requestedItemsByCategory[k][i] = quantity
                table.insert(requestedItems, {item = v.itemsRequest[i].item, quantity = quantity})
                OpenMenuImportReq(k, v)
            end,
        })

    end
    table.insert(options, {
        title = "Invia ordine",
        icon = "paper-plane",
        description = "Invia l'ordine con gli item richiesti",
        onSelect = function()
            ESX.TriggerServerCallback("IsRequestPending", function(isPending) 
                if isPending then 
                    return ESX.ShowNotification("C'è già un ordine in corso, attendi che venga completato.")
                end
                TriggerServerEvent("add:request", k, requestedItems, totalPrice)
                requestedItemsByCategory[k] = {}
                requestedItems = {}
                ESX.ShowNotification("Ordine inviato con successo!")
            end, k)
        end
    })



    table.insert(options, {
        title = "Visualizza Ordine",
        icon = "eye",
        description = "Visualizza l'ordine con gli item richiesti",
        onSelect = function()
            ESX.TriggerServerCallback("get:requestbyjob", function(data) 
                if not data then 
                    return ESX.ShowNotification("Non hai ancora inviato nessun ordine.")
                end
                local itemsList = ""
                for j = 1, #data.items do 
                    local item = data.items[j]
                    itemsList = itemsList .. "- " .. item.quantity .. "x " .. item.item .. "\n"
                end
                lib.registerContext({
                    id = "order_details:"..k,
                    title = "Dettagli ordine",
                    options = {
                        {
                            title = "Torna Indietro",
                            icon = "arrow-left",
                            description = "Torna indietro al menu degli ordini",
                            onSelect = function()
                                lib.hideContext("order_details:"..k)
                                OpenMenuImportReq(k, v)
                            end,
                        },
                        {
                            title = "Ordine effettuato: " .. tostring(data.time),
                            icon = "cart-shopping",
                            description = itemsList .. "\nTotale: " .. data.price .. "$",
                            disabled = true,
                        },
                        {
                            title = "Annulla ordine",
                            icon = "times",
                            description = "Annulla l'ordine corrente",
                            onSelect = function()
                                TriggerServerEvent("annulla:ordine", k)
                                ESX.ShowNotification("Ordine annullato con successo!")
                                lib.hideContext("order_details:"..k)
                                OpenMenuImportReq(k, v)
                            end,
                        }
                    }
                })
                lib.showContext("order_details:"..k)
            end, k)
        end
    })
    
    lib.registerContext({
        id = "import_menu:"..k,
        title = "Menu ordini",
        options = options
    })
    lib.showContext("import_menu:"..k)
end

RegisterCommand("import", function() 

    ESX.TriggerServerCallback("get:allrequest", function(datas) 
        local options = {}
        for i = 1, #datas do 
            local req = datas[i]
            table.insert(options, {
                title = "Ordine di " .. req.job .. "(" .. req.time .. ")",
                icon = "cart-shopping",
                description = "Contiene " .. #req.items.items .. " item per un totale di " .. req.price .. "$",
                onSelect = function()
                    local itemsList = ""
                    for j = 1, #req.items.items do 
                        local item = req.items.items[j]
                        itemsList = itemsList .. "- " .. item.quantity .. "x " .. item.item .. "\n"
                    end
                    lib.registerContext({
                        id = "order_details:"..req.job,
                        title = "Dettagli ordine",
                        options = {
                            {
                                title = "Ordine di " .. req.job .. " (" .. req.time .. ")",
                                icon = "cart-shopping",
                                description = itemsList .. "\nTotale: " .. req.price .. "$",
                                disabled = true,
                            },
                            {
                                title = "Completa ordine",
                                icon = "check",
                                description = "Segna l'ordine come completato",
                                onSelect = function()
                                    TriggerServerEvent("complete:request", req.job)
                                    ESX.ShowNotification("Ordine completato con successo!")
                                end,
                            },
                            {
                                title = "Annulla ordine",
                                icon = "times",
                                description = "Annulla l'ordine corrente",
                                onSelect = function()
                                    TriggerServerEvent("annulla:ordine", req.job)
                                    ESX.ShowNotification("Ordine annullato con successo!")
                                end,
                            },
                        }
                    })
                    lib.showContext("order_details:"..req.job)
                end,
            })
        end
        if #options == 0 then 
            return ESX.ShowNotification("Non ci sono ordini in corso al momento.")
        end
        lib.registerContext({
            id = "import_orders",
            title = "Ordini in corso",
            options = options
        })
        lib.showContext("import_orders")
    end)

end)

-- CONTINUARE IL MENU IMPORT