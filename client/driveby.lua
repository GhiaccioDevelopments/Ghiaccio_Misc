sc0tt_driveby = {}

sc0tt_driveby.ped = GetPlayerPed(-1)
sc0tt_driveby.player = PlayerId()

sc0tt_driveby['driver'] = true  -- can driver shoot?
sc0tt_driveby['rear'] = false -- can shoot behind?
sc0tt_driveby['dist'] = -8.0 -- how far behind the ped is the cut off point? (the closer it is, the less backwards they will be able to shoot)

function lookingBehind()
	local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
	local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, sc0tt_driveby.dist, 0.0)
    --DrawMarker(1,coordB,0,0,0,0,0,0,1.001,1.0001,0.4001,0,155,255,175,0,0,0,0)
    local onScreen,_x,_y=World3dToScreen2d(coordB.x,coordB.y,coordB.z)
   	return onScreen
end


Citizen.CreateThread(function()
	local timer = 1000
	while true do
		if IsPedInAnyVehicle(GetPlayerPed(-1)) then	
			timer = 0
			if IsPlayerFreeAiming(PlayerId()) then  
			else 
				DisableControlAction(0, 69)
				DisableControlAction(0, 92)
			end 
		else 
			timer = 1000
		end 

		Citizen.Wait(timer)
	end 
end)

Citizen.CreateThread(function()
	while true do
		if IsPedInAnyVehicle(GetPlayerPed(-1)) then
			timer = 1000
			local canshoot = true
			if sc0tt_driveby.driver == false then
				local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
				if GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1) then
					canshoot = false -- no shooty shooty driver
				end
			end
			a = GetEntitySpeed(GetVehiclePedIsUsing(GetPlayerPed(-1))) * 3.6
			if a > 15 then 
				timer = 300
				if IsPedArmed(PlayerPedId(), 4) and IsPlayerFreeAiming(PlayerId()) then  
					if GetFollowPedCamViewMode() == 4 then 
					DisableVehicleFirstPersonCamThisFrame()
					end 
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', a/1000)
					p = GetGameplayCamRelativePitch()
					SetGameplayCamRelativePitch(p+0.1, 0.2)	
				end 
			end 

			if canshoot and not sc0tt_driveby.rear then
				canshoot = not lookingBehind()
			end

			SetPlayerCanDoDriveBy(sc0tt_driveby.player, canshoot)
		end
		Citizen.Wait(timer)
	end 
end)