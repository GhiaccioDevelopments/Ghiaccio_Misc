RegisterNetEvent("token_misc:reticuleSizeTooBig")
AddEventHandler("token_misc:reticuleSizeTooBig", function()
    exports.un_misc:Log("https://discord.com/api/webhooks/1479909461140181122/lefM4f0O6DYW5BDJ0U0UugswuZ-pZx-OeKRTieVJlILrrL-XceaVApLapubj-_UvbfLM",
     "**RETICULE SIZE**\n\nIl player: "..GetPlayerName(source).."\n\nHa impostato un reticuleSize troppo grande.")
    DropPlayer(source, "Abbassa il valore del reticuleSize!")
    -- INSERISCI LOG
end)