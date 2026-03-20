-----------------------------------------------------------------------------------
local LastZone, CurrentAction, hasAlreadyEnteredMarker, job = nil, nil, false, nil
local xSound = exports.xsound
local ox_target = exports.ox_target
local ESX = exports['es_extended']:getSharedObject()
-----------------------------------------------------------------------------------

RegisterNetEvent('dj_baspel:createMusicMenu', function()
    lib.registerContext({
        id = 'music_menu',
        title = ConfigDJ.Language['titleMenu'],
        options = {
            {
                title = ConfigDJ.Language['playSong'],
                description = ConfigDJ.Language['playSongDesc'],
                arrow = false,
                event = 'dj_baspel:playMusicMenu',
            },
                                {
                title = ConfigDJ.Language['playlistMenu'],
                description = ConfigDJ.Language['playlistDesc'],
                arrow = true,
                menu = 'playlist_menu',
            },
            {
                title = ConfigDJ.Language['pauseMusic'],
                description = ConfigDJ.Language['pauseMusicDesc'],
                arrow = false,
                serverEvent = 'dj_baspel:pauseMusic',
            },
            {
                title = ConfigDJ.Language['resumeMusic'],
                description = ConfigDJ.Language['resumeMusicDesc'],
                arrow = false,
                serverEvent = 'dj_baspel:resumeMusic',
            },
            {
                title = ConfigDJ.Language['changeVolume'],
                description = ConfigDJ.Language['changeVolumeDesc'],
                arrow = false,
                event = 'dj_baspel:changeVolumeMenu',
            },
            {
                title = ConfigDJ.Language['stopMusic'],
                description = ConfigDJ.Language['stopMusicDesc'],
                arrow = false,
                serverEvent = 'dj_baspel:stopMusic',
            },
        },
        {
            id = 'playlist_menu',
            title = ConfigDJ.Language['playlistMenuTitle'],
            options = {
                {
                    title = ConfigDJ.Playlist['first'],
                    description = ConfigDJ.Playlist['desc_first'],
                    args = {music = ConfigDJ.Playlist['music_first_id']},
                    event = 'dj_baspel:playMusicFromPlaylist'
                },
                {
                    title = ConfigDJ.Playlist['second'],
                    description = ConfigDJ.Playlist['desc_second'],
                    args = {music = ConfigDJ.Playlist['music_second_id']},
                    event = 'dj_baspel:playMusicFromPlaylist'
                },
                {
                    title = ConfigDJ.Playlist['third'],
                    description = ConfigDJ.Playlist['desc_third'],
                    args = {music = ConfigDJ.Playlist['music_third_id']},
                    event = 'dj_baspel:playMusicFromPlaylist'
                },
                {
                    title = ConfigDJ.Playlist['fourth'],
                    description = ConfigDJ.Playlist['desc_fourth'],
                    args = {music = ConfigDJ.Playlist['music_fourth_id']},
                    event = 'dj_baspel:playMusicFromPlaylist'
                },
                {
                    title = ConfigDJ.Playlist['fifth'],
                    description = ConfigDJ.Playlist['desc_fifth'],
                    args = {music = ConfigDJ.Playlist['music_fifth_id']},
                    event = 'dj_baspel:playMusicFromPlaylist'
                }
            }
        }
    })
    lib.showContext('music_menu')
end)

RegisterNetEvent('dj_baspel:playMusicFromPlaylist', function (data)
    local input = data.music
    if input then
        TriggerServerEvent('dj_baspel:playMusic', input)
    end
end)

RegisterNetEvent('dj_baspel:playMusicMenu', function (YoutubeURL)
    local input = lib.inputDialog(ConfigDJ.Language['songSel'], {ConfigDJ.Language['url']})
    if input then
        local YoutubeURL = input[1]
        TriggerServerEvent('dj_baspel:playMusic', YoutubeURL)
    end
end)

RegisterNetEvent('dj_baspel:changeVolumeMenu', function ()
    local input = lib.inputDialog(ConfigDJ.Language['musicVolume'], {ConfigDJ.Language['musicVolumeNm']})
    if input then
        local volume = input[1]
        TriggerServerEvent('dj_baspel:changeVolume', volume)
    end
end)

CreateThread(function()
    if not ConfigDJ.ox_target then
        while true do
            local sleep = 1500
            local playerCoords, inLocation, currentZone = GetEntityCoords(PlayerPedId()), false, false

            for i=1, #ConfigDJ.Locations do
                local dist = #(playerCoords - ConfigDJ.Locations[i].coords)
                if dist <= ConfigDJ.Distance then
                    sleep = 0
                    if dist <= ConfigDJ.Locations[i].distance and ConfigDJ.Locations[i].onlyJob then
                        inLocation, currentZone, job = true, i, ConfigDJ.Locations[i].job
                    elseif dist <= ConfigDJ.Locations[i].distance and not ConfigDJ.Locations[i].onlyJob then
                        inLocation, currentZone, job = true, i, nil
                    end
                end
            end

            if (inLocation and not hasAlreadyEnteredMarker and ESX.PlayerData.job.name == job) or (inLocation and LastZone ~= currentZone and ESX.PlayerData.job.name == job) then
                hasAlreadyEnteredMarker, LastZone = true, currentZone
                CurrentAction = 'musicMenu'
                lib.showTextUI(ConfigDJ.Language['openMenu'])
            elseif (inLocation and not hasAlreadyEnteredMarker and job == nil) or (inLocation and LastZone ~= currentZone and job == nil) then
                hasAlreadyEnteredMarker, LastZone = true, currentZone
                CurrentAction = 'musicMenu'
                lib.showTextUI(ConfigDJ.Language['openMenu'])
            end

            if not inLocation and hasAlreadyEnteredMarker then
                hasAlreadyEnteredMarker = false
                sleep = 1000
                CurrentAction = nil
                lib.hideTextUI()
            end
            Wait(sleep)
        end
    else
        for k, v in pairs(ConfigDJ.Locations) do
            if v.onlyJob then
                ox_target:addSphereZone({
                    coords = v.coords,
                    radius = 1,
                    debug = drawZones,
                    options = {
                        {
                            name = 'sphere:dj',
                            event = 'dj_baspel:createMusicMenu',
                            icon = 'fa fa-music',
                            label = 'DJ Pult',
                            canInteract = function(entity, distance, coords, name)
                                if v.onlyJob and ESX.PlayerData.job.name == v.job then
                                    return true
                                end
                            end
                        }
                    }
                })
            elseif not v.onlyJob then
                ox_target:addSphereZone({
                    coords = v.coords,
                    radius = 1,
                    debug = drawZones,
                    options = {
                        {
                            name = 'sphere:dj',
                            event = 'dj_baspel:createMusicMenu',
                            icon = 'fa fa-music',
                            label = 'DJ Pult',
                            canInteract = function(entity, distance, coords, name)
                                return true
                            end
                        }
                    }
                })
            end
        end
    end
end)

if not ConfigDJ.ox_target then
    CreateThread(function ()
        while true do
            local sleep = 1500
            if CurrentAction ~= nil then
                sleep = 0
                if IsControlPressed(1, 38) then
                    Wait(500)
                    if CurrentAction == 'musicMenu' then
                        TriggerEvent('dj_baspel:createMusicMenu')
                    end
                end
            end
            Wait(sleep)
        end
    end)
end
