-- [[ Initialize Menu ]] --
Config_Rockstar = {}

Config_Rockstar.command = "rockstar" -- Change this to whatever you want the command to be


-- [[ Logs ]] --
Config_Rockstar.enableLogs = false -- Change this to false if you want to disable logs
-- Config_Rockstar.logToFile = true -- Server-side only, not used in client
-- Config_Rockstar.printToConsole = true -- Server-side only, not used in client
-- [[ Logs ]] -- 


-- [[ Locale ]] --
-- Menu Slider Buttons
Config_Rockstar.buttonRecord = "Avvia Registrazione"
Config_Rockstar.buttonSaveClip = "Salva Registrazione"
Config_Rockstar.buttonDelClip = "Elimina Registrazione"
Config_Rockstar.buttonEditor = "Apri Editor"

-- Notifications
Config_Rockstar.record = "Registrazione avviata"
Config_Rockstar.saveclip = "Registrazione salvata"
Config_Rockstar.delclip = "Registrazione eliminata"
Config_Rockstar.editor = "Apertura Rockstar Editor"

-- Logs
Config_Rockstar.logRecord = " ha iniziato la registrazione"
Config_Rockstar.logSaveClip = " ha salvato una registrazione"
Config_Rockstar.logDelClip = " ha eliminato una registrazione"
Config_Rockstar.logEditor = " ha aperto Rockstar Editor"
-- [[ Locale ]] --
local function openRockstarMenu()
    exports.ox_lib:registerContext({
        id = 'rockstar_menu',
        title = 'Rockstar Editor',
        options = {
            {
                title = Config_Rockstar.buttonRecord,
                icon = 'video',
                onSelect = function()
                    TriggerEvent("nad_rockstar:record")
                    if Config_Rockstar.enableLogs == true then
                        TriggerServerEvent('nad_rockstar:log', GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())), 'record')
                    end
                end
            },
            {
                title = Config_Rockstar.buttonSaveClip,
                icon = 'floppy-disk',
                onSelect = function()
                    TriggerEvent("nad_rockstar:saveclip")
                    if Config_Rockstar.enableLogs == true then
                        TriggerServerEvent('nad_rockstar:log', GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())), 'saveclip')
                    end
                end
            },
            {
                title = Config_Rockstar.buttonDelClip,
                icon = 'trash',
                onSelect = function()
                    TriggerEvent("nad_rockstar:delclip")
                    if Config_Rockstar.enableLogs == true then
                        TriggerServerEvent('nad_rockstar:log', GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())), 'delclip')
                    end
                end
            },
            {
                title = Config_Rockstar.buttonEditor,
                icon = 'film',
                onSelect = function()
                    local isShure = exports.ox_lib:alertDialog({
                        header = 'Attenzione',
                        content = 'Sei sicuro di voler aprire l\'editor? Questo chiuderà la sessione di gioco e potrebbe causare perdita di dati non salvati.',
                        centered = true,
                        cancel = true,
                        size = "md",
                        overflow = true,
                        labels = {
                            confirm = "Sì, apri l'editor",
                            cancel = "No, annulla"
                        }
                    })
                    if isShure == "confirm" then
                        TriggerEvent("nad_rockstar:editor")
                    else return end
                    if Config_Rockstar.enableLogs == true then
                        TriggerServerEvent('nad_rockstar:log', GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())), 'editor')
                    end
                end
            },
        }
    })
    lib.showContext('rockstar_menu')
end


-- [[ Register Events ]] --
RegisterNetEvent("nad_rockstar:record")
AddEventHandler("nad_rockstar:record", function()
    StartRecording(1) -- https://docs.fivem.net/natives/?_0xC3AC2FFF9612AC81
    notify(Config_Rockstar.record)
end)

RegisterNetEvent("nad_rockstar:saveclip")
AddEventHandler("nad_rockstar:saveclip", function()
    StartRecording(0) -- https://docs.fivem.net/natives/?_0xC3AC2FFF9612AC81
    StopRecordingAndSaveClip() -- https://docs.fivem.net/natives/?_0x071A5197D6AFC8B3
    notify(Config_Rockstar.saveclip)
end)

RegisterNetEvent("nad_rockstar:delclip")
AddEventHandler("nad_rockstar:delclip", function()
    StopRecordingAndDiscardClip() -- https://docs.fivem.net/natives/?_0x88BB3507ED41A240
    notify(Config_Rockstar.delclip)
end)

RegisterNetEvent("nad_rockstar:editor")
AddEventHandler("nad_rockstar:editor", function()
    notify(Config_Rockstar.editor)
    NetworkSessionLeaveSinglePlayer() -- https://docs.fivem.net/natives/?_0x3442775428FD2DAA
    ActivateRockstarEditor() -- https://docs.fivem.net/natives/?_0x49DA8145672B2725
end)

-- [[ Register Command ]] --
RegisterCommand(Config_Rockstar.command, function(source)
    openRockstarMenu()
end, false)


-- [[ Functions ]] --
function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end