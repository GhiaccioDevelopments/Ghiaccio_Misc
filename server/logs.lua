function sendToDiscord(webhook, messaggio)
    local contenuto = {{
        author = {
            name = "Underground | Logs",
            icon_url = ""
        },
        description = messaggio,
        color = 255,
        footer = {
            text = "UNDERGROUND LOG | "..os.date("%x | %X %p"),
        }
    }}
    PerformHttpRequest(webhook , function(err, text, headers) end, 'POST', json.encode({username = name, embeds = contenuto}), { ['Content-Type'] = 'application/json' })
end

SendLog = function(webhook, messaggio)
    sendToDiscord(webhook, messaggio)
end


RegisterNetEvent("un_misc:LogLogged", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local steamId = ""
    
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:sub(1,6) == "steam:" then
            steamId = id:sub(7)
            break
        end
    end

    local messaggio = "**LOGIN**\n\nPlayer: "..GetPlayerName(xPlayer.source).."\n\nJOB: "..xPlayer.getJob().label.."\nCoords: "..json.encode(GetEntityCoords(GetPlayerPed(source)))
    exports.un_misc:Log("https://discord.com/api/webhooks/1479928704388956281/Rpk7mgpaIoAWxp-H4uQiJDLtfoFrvFKDABxi0NwtAXMq10N6LT22sfKDH8M9-qHZvKp2", messaggio)
end)    

exports('Log', SendLog)