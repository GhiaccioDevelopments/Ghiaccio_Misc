local ESX = exports.es_extended:getSharedObject()
local ImportRequests = {}

ESX.RegisterServerCallback("IsRequestPending", function(source, cb, job) 
    for k,v in pairs(ImportRequests) do 
        if k == job then 
            cb(true)
            return
        end
    end
    cb(false)
end)

RegisterNetEvent("add:request", function(job, itemsRequested, totalPrice)
    ImportRequests[job] = {items = itemsRequested, price = totalPrice, time = tostring(os.date("*t").hour) .. ":" .. tostring(os.date("*t").min) .. " " .. tostring(os.date("*t").day) .. "/" .. tostring(os.date("*t").month) .. "/" .. tostring(os.date("*t").year)}
    local xPlayers = ESX.GetPlayers()
    Wait(3000)
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.getJob().name == Config.importJobName and Config.SendNotifyToImportEmployee then
            TriggerClientEvent('esx:showNotification', xPlayer.source, "Nuovo ordine ricevuto da: ".. job)
        end
    end
    SetResourceKvp("requests", json.encode(ImportRequests))
end)

ESX.RegisterServerCallback("get:allrequest", function(source, cb)
    local datas = {}
    for k,v in pairs(ImportRequests) do 
        table.insert(datas, {job = k, items = v, price = v.price, time = v.time})
    end
    cb(datas)
end)

ESX.RegisterServerCallback("get:requestbyjob", function(source, cb, job) 
    local data = nil
    for k,v in pairs(ImportRequests) do 
        if k == job then 
            data = v
            break
        end
    end
    cb(data)
end)

RegisterServerEvent("complete:request", function(job) 
    ImportRequests[job] = nil
    SetResourceKvp("requests", json.encode(ImportRequests))
end)

RegisterServerEvent("annulla:ordine", function(job) 
    ImportRequests[job] = nil
    SetResourceKvp("requests", json.encode(ImportRequests))
end)

AddEventHandler("onResourceStart", function(resourceName) 
    if GetCurrentResourceName() ~= resourceName then return end
    local requests = GetResourceKvpString("requests")
    if requests then 
        ImportRequests = json.decode(requests)
    end
end)

AddEventHandler("onResourceStop", function(resourceName) 
    if GetCurrentResourceName() ~= resourceName then return end
    SetResourceKvp("requests", json.encode(ImportRequests))
end)

