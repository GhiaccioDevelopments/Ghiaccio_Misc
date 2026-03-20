local ESX = exports.es_extended:getSharedObject()
local prezzo = 3500


ESX.RegisterServerCallback("getMoney", function(source, cb)
    
    local xPlayer = ESX.GetPlayerFromId(source)
    local moneyContanti = xPlayer.getMoney()
    local moneyBanca = xPlayer.getAccount('bank').money
    cb({
        soldiBanca = moneyBanca,
        soldiContanti = moneyContanti
    })

end)

RegisterServerEvent("RemoveMoneyFromBank", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeAccountMoney('bank', amount)
end)

RegisterServerEvent("RemoveMoneyContanti", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeMoney(amount)
end)