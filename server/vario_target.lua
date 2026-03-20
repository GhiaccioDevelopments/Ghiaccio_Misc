RegisterServerEvent("un_misc:Loot:Server", function(targetServerId) 
    local xTarget = ESX.GetPlayerFromId(targetServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ora = os.date("%H:%M:%S")
    local data = os.date("%d/%m/%Y")
    -- INSERISCI LOG
    exports.un_misc:Log("https://discord.com/api/webhooks/1479907623360004106/VaYiXLJ1G5D7zg60v_H1o04IHUcL_Yjnkk1phP0s3xItsHEcUNr8o3CnAfG1EV8rHqx3",
     "**PERQUISIZIONE**\n\nIl player: "..xPlayer.getName().."\n\nHa perquisito "..xTarget.getName().." alle "..ora.." del "..data)
end)