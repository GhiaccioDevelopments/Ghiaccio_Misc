-- LOG INVENTARIO --
webhooks = {
    ['drop'] = 'https://discord.com/api/webhooks/1479912161793933576/7NBTC5TNYPwbkOVjZ-zR-9qKAtqofmdvvVsy_0Dqk_w790Y3D2KmmV7gk_C8jiRRGoUA',
    ['pickup'] = 'https://discord.com/api/webhooks/1479912416849563819/N4QgOyk7LbkEXBW5plLV43ZZUPGJQ4SoxMkDRK5FlcpCSj9cELz9GS8RpDUUoEdBAlIb',
    ['give'] = 'https://discord.com/api/webhooks/1479912726653567038/9ks17I3Fd-n8HC3jZyTRY2wsZpPd_YFTn91MQN-KRteXRkIM7kSLiZ8jiTgGjU1BOXGx',
    ['stash'] = 'https://discord.com/api/webhooks/1479912806328565893/WUum8PnsweYoOF-4UjHjoVMe0AILomeKDllkYRS2gvg5LzWz0SffZCI_wtuhIrcVY-E4',
    ['trunk'] = 'https://discord.com/api/webhooks/1479912882983407716/uBB5Ecf2eslwm_YkyXTNUlVpvRVMs5nntW0yV4iW2AOVv8oOjJta3Cv1WSvhsCbmK7gG',
    ['glovebox'] = 'https://discord.com/api/webhooks/1479912948490305556/UMpYl4DxgtAPSPKEj652kY7Pfr8TSyAWwNV_LRQ5uxF98IlwVG7qjVLxbCJ5rDeg0WW-',
}
hooks = {
    ['drop'] = {
        from = 'player',
        to = 'drop',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Loop through identifiers to find Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "") -- Remove 'discord:' prefix
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
            sendWebhook('drop', {
                {
                    title = 'Drop',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    ['pickup'] = {
        from = 'drop',
        to = 'player',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Loop through identifiers to find Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "") -- Remove 'discord:' prefix
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
            sendWebhook('pickup', {
                {
                    title = 'Pickup',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['give'] = {
        from = 'player',
        to = 'player',
        callback = function(payload)
            if payload.fromInventory == payload.toInventory then return end

            local playerName = GetPlayerName(payload.source)
            local targetSource = payload.toInventory
            local targetName = GetPlayerName(targetSource)

            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local targetIdentifiers = GetPlayerIdentifiers(targetSource)

            local playerDiscordID = 'N/A'
            local targetDiscordID = 'N/A'

            -- Get Discord for source
            for _, identifier in ipairs(playerIdentifiers) do
                if identifier:find("discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end

            -- Get Discord for target
            for _, identifier in ipairs(targetIdentifiers) do
                if identifier:find("discord:") then
                    targetDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end

            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local targetCoords = GetEntityCoords(GetPlayerPed(targetSource))

            local transferred = payload.amount or payload.count or 1

            sendWebhook('give', {
                {
                    title = 'Transfer of items between players',
                    description = (
                        '**From Player:**\n' ..
                        'Name: `%s`\n' ..
                        'Discord: `%s`\n' ..
                        'Player ID: `%s`\n\n' ..

                        '**To Player:**\n' ..
                        'Name: `%s`\n' ..
                        'Discord: `%s`\n' ..
                        'Player ID: `%s`\n\n' ..

                        '**Item Info:**\n' ..
                        'Item Name: `%s`\n' ..
                        'Count: `x%s`\n' ..     -- <<< FIXED HERE
                        'Metadata: `%s`\n\n' ..

                        '**Coordinates:**\n' ..
                        'From Player: `%s, %s, %s`\n' ..
                        'To Player: `%s, %s, %s`'
                    ):format(
                        playerName,
                        playerDiscordID,
                        payload.source,

                        targetName,
                        targetDiscordID,
                        targetSource,

                        payload.fromSlot.name,
                        transferred, 
                        json.encode(payload.fromSlot.metadata),

                        playerCoords.x, playerCoords.y, playerCoords.z,
                        targetCoords.x, targetCoords.y, targetCoords.z
                    ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['stash_pick'] = {
        from = 'player',
        to = 'stash',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('stash', {
                {
                    title = 'Stash Add Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.toInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['stash'] = {
        from = 'stash',
        to = 'player',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('stash', {
                {
                    title = 'Stash Remove Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.fromInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['trunk_add'] = {
        from = 'player',
        to = 'trunk',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('trunk', {
                {
                    title = 'Trunk Add Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Trunk ID:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.toInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['trunk_remove'] = {
        from = 'trunk',
        to = 'player',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('trunk', {
                {
                    title = 'Trunk Remove Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Trunk ID:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.fromInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['add'] = {
        from = 'player',
        to = 'glovebox',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('glovebox', {
                {
                    title = 'Glovebox Add Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Glovebox ID:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.toInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
    
    ['glovebox_remove'] = {
        from = 'glovebox',
        to = 'player',
        callback = function(payload)
            local playerName = GetPlayerName(payload.source)
            local playerIdentifiers = GetPlayerIdentifiers(payload.source)
            local playerDiscordID = 'N/A'
    
            -- Get Discord ID
            for _, identifier in ipairs(playerIdentifiers) do
                if string.find(identifier, "discord:") then
                    playerDiscordID = identifier:gsub("discord:", "")
                    break
                end
            end
    
            local playerCoords = GetEntityCoords(GetPlayerPed(payload.source))
            local transferred = payload.amount or payload.count or 1
    
            sendWebhook('glovebox', {
                {
                    title = 'Glovebox Remove Item',
                    description = ('**Player Name:** `%s` \n **Discord ID:** `%s` \n **Player ID:** `%s` \n **Item Name:** `%s` \n **Count:** `x%s` \n **Metadata:** `%s` \n **Glovebox ID:** `%s` \n **Coordinates:** `%s`')
                        :format(
                            playerName,
                            playerDiscordID,
                            payload.source,
                            payload.fromSlot.name,
                            transferred,
                            json.encode(payload.fromSlot.metadata),
                            payload.fromInventory,
                            ('%s, %s, %s'):format(playerCoords.x, playerCoords.y, playerCoords.z)
                        ),
                    color = 0x00ff00
                }
            })
        end
    },
}

types = {}

function addTypeHook(name, from, to, callback)
    types[name] = {
        from = from,
        to = to,
        callback = callback
    }
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if GetResourceState('ox_inventory') ~= 'started' then
        print('^1[logs] ^0ox_inventory is not started.')
        return
    end
    exports.ox_inventory:registerHook(
        'swapItems',
        function(payload)
            for name, data in pairs(types) do
                if payload.fromType == data.from and payload.toType == data.to then
                    --print('^3[logs] ^0' .. name .. ' type hook triggered.')
                    data.callback(payload)
                end
            end
            --print(json.encode(payload, { indent = true }))
        end,
        options
    )
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end
    exports.ox_inventory:removeHooks()
end)

for name, data in pairs(hooks) do
    addTypeHook(name, data.from, data.to, data.callback)
end

function sendWebhook(webhook, data)
    if webhooks[webhook] == nil then
        print('^1[logs] ^0Webhook ' .. webhook .. ' does not exist.')
        return
    end

    PerformHttpRequest(
        webhooks[webhook],
        function(err, text, headers)
        end,
        'POST',
        json.encode({ embeds = data }),
        { ['Content-Type'] = 'application/json' }
    )
end

--
