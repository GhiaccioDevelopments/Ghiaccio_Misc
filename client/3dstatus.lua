local pedDisplaying = {}
local displayTime = 1111100000000000000000000000000000000000000000000000000000000000 --qui è
local displayTime2 = 1 --qui è

local background = {
    enable = true,
    color = { r = 23, g = 20, b = 28, alpha = 50, negro = 90 }, -- Base: 35, 35, 35
}

Citizen.CreateThread(function()
    local strin = ""

	while true do
		local currentTime, html = GetGameTimer(), ""
		for k, v in pairs(pedDisplaying) do
            
			local player = GetPlayerFromServerId(k)
			if NetworkIsPlayerActive(player) then
			    local sourcePed, targetPed = GetPlayerPed(player), PlayerPedId()
        	    local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        	    local pedCoords = GetPedBoneCoords(sourcePed, 0x2e28, 0.0, 0.0, 0.0)
    
                if player == source or #(sourceCoords - targetCoords) < 25 then
			        if v.type == "status" then
                    	local onScreen, _x, _y = GetHudScreenPositionFromWorldPosition(pedCoords.x, pedCoords.y, pedCoords.z + 0.20)

                        if not onScreen then
							SetTextColour(255, 255, 255, 700) -- Base: 245, 245, 245
							SetTextScale(0.0, 0.4 * 1.0)
							SetTextFont(4)
							SetTextDropshadow(0, 0, 0, 0, 55)
							SetTextDropShadow()
							SetTextProportional(0.5)
							SetTextCentre(true)
				
							-- Calculate width and height
							BeginTextCommandWidth("STRING")
							AddTextComponentString(v.msg)
							local height = GetTextScaleHeight(0.50*1.0, 3)
							local width = EndTextCommandGetWidth(3)
				
							-- Diplay the text
							SetTextEntry("STRING")
							AddTextComponentString(v.msg)
							EndTextCommandDisplayText(_x, _y)
				
							DrawRect(_x, _y+0.7/45, width, height, background.color.r, background.color.g, background.color.b , background.color.negro)
                        end
        	        elseif v.type == "statusoff" then
                    	local onScreen, _x, _y = GetHudScreenPositionFromWorldPosition(pedCoords.x, pedCoords.y, pedCoords.z + 1.1)
                        if not onScreen then
							SetTextColour(255, 255, 255, 700) -- Base: 245, 245, 245
							SetTextScale(0.0, 0.4 * 1.0)
							SetTextFont(4)
							SetTextDropshadow(0, 0, 0, 0, 55)
							SetTextDropShadow()
							SetTextProportional(0.5)
							SetTextCentre(true)
				
							-- Calculate width and height
							BeginTextCommandWidth("STRING")
							AddTextComponentString(v.msg)
							local height = GetTextScaleHeight(0.50*1.0, 3)
							local width = EndTextCommandGetWidth(3)
				
							-- Diplay the text
							SetTextEntry("STRING")
							AddTextComponentString(v.msg)
							EndTextCommandDisplayText(_x, _y)
				
							DrawRect(_x, _y+0.7/45, width, height, background.color.r, background.color.g, background.color.b , background.color.negro)
                        end
        	        end
                end
        	end
        	if v.time <= currentTime then
        		pedDisplaying[k] = nil
        	end
        end

        if strin ~= html then
            SendNUIMessage({
                type = "txt", 
                html = html
            })
            strin = html
        end
        
		Wait(0)
    end
end)

RegisterNetEvent("status:client:triggerDisplay")
AddEventHandler("status:client:triggerDisplay", function(playerId, message, typ)
	pedDisplaying[tonumber(playerId)] = {type = typ, msg = message, time = GetGameTimer() + displayTime}
end)

RegisterNetEvent("status:client:triggerDisplayoff")
AddEventHandler("status:client:triggerDisplayoff", function(playerId, message, typ)
	pedDisplaying[tonumber(playerId)] = {type = typ, msg = message, time = GetGameTimer() + displayTime2}
end)