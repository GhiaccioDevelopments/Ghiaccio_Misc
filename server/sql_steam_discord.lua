local ESX = exports.es_extended:getSharedObject()

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Citizen.Wait(0)
    deferrals.update("Checking Discord link...")
    local hasDiscord = false
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, string.len("discord:")) == "discord:" then
            hasDiscord = true
            discordId = string.sub(id, 9)
            break
        end
    end

    local hasSteam = false
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, string.len("steam:")) == "steam:" then
            hasSteam = true
            steamId = string.sub(id, 7)
            break
        end
    end

    local hasLicense = false
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, string.len("rockstar:")) == "rockstar:" then
            hasLicense = true
            rockstarId = string.sub(id, 9)
            break
        end
    end

    --Uncomment the following lines if you want to enforce Discord linking
     if not hasDiscord then
         deferrals.done("You must have Discord linked to join this server. Please restart FiveM with Discord open.")
       return
    end

     if not hasSteam then
         deferrals.done("You must have Steam open to join this server. Please restart FiveM with Steam open.")
         return
     end
    Citizen.Wait(500)
    deferrals.done()
end)

local ESX = exports.es_extended:getSharedObject()

local function UpdateId(src)
    local discordId, steamId = nil, nil

    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,8) == "discord:" then
            discordId = id:sub(9)
        elseif id:sub(1,6) == "steam:" then
            steamId = id:sub(7)
        end
    end

    if not discordId or not steamId then
        print("[UpdateId] Missing Discord or Steam for player " .. tostring(src))
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        print("[UpdateId] xPlayer not found for player " .. tostring(src))
        return
    end

    MySQL.Async.execute('UPDATE users SET discordid = @discordid, steamhex = @steamhex WHERE identifier = @identifier', {
        ['@discordid'] = discordId,
        ['@steamhex'] = steamId,
        ['@identifier'] = xPlayer.identifier
    }, function(rowsChanged)
        print("[UpdateId] Updated Discord and Steam for player " .. tostring(src))
    end)
end

RegisterCommand("UpdateId", function(source, args, rawCommand)
    if source == 0 or source == nil then
        print("Devi eseguire il comando da un player in game, non dalla console.")
        return
    end
    UpdateId(source)
end)


exports("updateid", UpdateId)
