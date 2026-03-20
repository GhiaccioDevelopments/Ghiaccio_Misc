local ESX = exports.es_extended:getSharedObject()

ESX.RegisterServerCallback("documentiPersonali", function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    cb({
        nome = xPlayer.getName(),
        numerodiTelefono = exports["lb-phone"]:GetEquippedPhoneNumber(source),
        lavoroAttivo = xPlayer.getJob().label,
        lavoroGrado = xPlayer.getJob().grade_label,
        soldiContanti = xPlayer.getMoney(),
        soldiBanca = xPlayer.getAccount("bank").money,
    })
end)