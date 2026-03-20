local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("Giubotto_Buyed")
AddEventHandler("Giubotto_Buyed", function(percent, v)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeMoney(v.menu[tostring(percent)].price)
        if not v.jobPayment.enabled then return end
        exports["codem-bossmenuv2"]:AddMoneyJob(v.jobPayment.jobName, tonumber(v.menu[tostring(percent)].price))
    end
end)