
dmeConfig = {
    language = 'en',
    color = { r = 230, g = 230, b = 230, a = 255 }, -- Text color
    font = 6, -- Text font
    time = 5000, -- Duration to display the text (in ms)
    scale = 0.5, -- Text scale
    scaleperm = 0.4, -- Text scale
    dist = 250, -- Min. distance to draw 
    distperm = 2500, --Distanza per me fisso
}

-- Languages available
Languages = {
    ['en'] = {
        commandName = 'me',
        commandDescription = 'Me.',
        commandSuggestion = {{ name = 'action', help = '"scratch his nose" for example.'}},
        prefix = ''
    },
}

local lang = Languages[dmeConfig.language] -- Pre-load the language
local peds = {}

local pedDisplaying = {}
local pedDisplaying_Status = {}
micOff = true
local GetGameTimer = GetGameTimer


local function draw3dText2(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    local scale = 200 / (GetGameplayCamFov() * dist)

    -- Format the text
    SetTextColour(dmeConfig.color.r, dmeConfig.color.g, dmeConfig.color.b, dmeConfig.color.a)
    SetTextScale(0.0, dmeConfig.scale * scale)
    SetTextFont(dmeConfig.font)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function displayText(ped, text)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(playerCoords - pedCoords)

    if dist <= dmeConfig.dist then
        pedDisplaying[ped] = (pedDisplaying[ped] or 1) + 1

        -- Timer
        local display = true

        Citizen.CreateThread(function()
            Citizen.Wait(dmeConfig.time)
            display = false
        end)

        -- Display
        local offset = 0.6 + pedDisplaying[ped] * 0.1
        while display do
            if HasEntityClearLosToEntity(playerPed, ped, 17) then
                local x, y, z = table.unpack(GetEntityCoords(ped))
                if micOff then z = z + 0.2 end
                z = z + offset
        
                draw3dText2(vector3(x, y, z), text)
            end
            Citizen.Wait(0)
        end

        pedDisplaying[ped] = pedDisplaying[ped] - 1
    end
end

local function onShareDisplay(text, target)
    local player = GetPlayerFromServerId(target)
    if player ~= -1 or target == GetPlayerServerId(PlayerId()) then
        local ped = GetPlayerPed(player)
        displayText(ped, text)
    end
end

-- Register the event
RegisterNetEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', onShareDisplay)

-- Add the chat suggestion
TriggerEvent('chat:addSuggestion', '/' .. lang.commandName, lang.commandDescription, lang.commandSuggestion)

RegisterNetEvent('3dme:manda')
AddEventHandler('3dme:manda', function(testo)
    ExecuteCommand('me ' .. testo)
end)

RegisterNetEvent('mePerma:manda')
AddEventHandler('mePerma:manda', function(testo)
    ExecuteCommand('desc ' .. testo) -- Corrected from "desk" to "desc"
end)
