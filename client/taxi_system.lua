ESX = exports["es_extended"]:getSharedObject()

IsDestinationSet = false
parking = false

drivingStyle = 786468

taxiBlip = nil
taxiVeh = nil
taxiPed = nil
PlayerEntersTaxi = false

z= nil

function CreateTaxiPed(vehicle)
	local model = GetHashKey("a_m_y_stlat_01")

	if DoesEntityExist(vehicle) then
		if IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(1)
			end

			local ped = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)
			SetAmbientVoiceName(ped, "A_M_M_EASTSA_02_LATINO_FULL_01")	
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetEntityAsMissionEntity(ped, true, true)

			SetModelAsNoLongerNeeded(model)
			return ped
		end
	end
end

function CreateTaxi(x, y, z)
	local taxiModel = GetHashKey("taxi")

	if IsModelValid(taxiModel) then
		RequestModel(taxiModel)
		while not HasModelLoaded(taxiModel) do
			Wait(1)
		end
		
		if DoesEntityExist(taxiVeh) == false then
			local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(50, 70), 0, 0, 0)
			local sX, sY, sZ = table.unpack(vector)

			TriggerEvent('phoneNotify', 'Taxi', 'Il taxi sta arrivando', 'taxi', 3)

			PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)

			taxiVeh = CreateVehicle(taxiModel, sX, sY, sZ, 0, true, false)

			SetEntityAsMissionEntity(taxiVeh, true, true)
			SetVehicleEngineOn(taxiVeh, true, true, false)
			
			SetModelAsNoLongerNeeded(taxiModel)

			SetHornEnabled(taxiVeh, true)
			StartVehicleHorn(taxiVeh, 1000, GetHashKey("NORMAL"), false)
			

			local blip = AddBlipForEntity(taxiVeh)
			SetBlipSprite(blip, 198)
			SetBlipFlashes(blip, true)
			SetBlipFlashTimer(blip, 5000)


			return taxiVeh
		else
			TriggerEvent('phoneNotify', 'Taxi', 'Tutti i nostri autisti sono attualmente occupati', 'taxi', 3)
			
		end
	end	
end

function DeleteTaxi(vehicle, driver)
	Citizen.CreateThread(function ()
		local _, vector = GetNthClosestVehicleNode(x, y, z, math.random(50, 70), 0, 0, 0)
		local sX, sY, sZ = table.unpack(vector)
	
		if DoesEntityExist(vehicle) then
			TaskLeaveVehicle(PlayerPedId(), vehicle, 4160)
			Wait(2000)
			if(IsPedInAnyVehicle(PlayerPedId(), false)) then
				TaskLeaveVehicle(PlayerPedId(), vehicle, 4160)
			end
			SetVehicleEngineOn(vehicle, true, true, false)
			TaskVehicleDriveToCoord(taxiPed, vehicle,  sX, sY, sZ, 26.0, 0, GetEntityModel(vehicle), drivingStyle, 10.0)
			Wait(20000)
	
			local blip = GetBlipFromEntity(vehicle)
	
			if DoesBlipExist(blip) then
				RemoveBlip(blip)
			end
	
			DeleteEntity(driver)
			DeleteEntity(vehicle)
		end
	
		if not DoesEntityExist(vehicle) and DoesEntityExist(driver) then
			DeleteEntity(driver)
			DeleteEntity(driver)
		end
		PlayerEntersTaxi = false
		parking = false
	end)
end


function DisplayHelpMsg(text)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentScaleform(text)
	EndTextCommandDisplayHelp(0, false, 1, -1)
end

function getGroundZ(x, y, z)
  local result, groundZ = GetGroundZFor_3dCoord(x+0.0, y+0.0, z+0.0, Citizen.ReturnResultAnyway())
  return groundZ
end


local delay = false 
RegisterNetEvent(
    "callTaxi",
    function()
	local playerPed = PlayerPedId()

	ESX.TriggerServerCallback('taxisystem:checkPlayerMoney', function (ok)
		if(not ok) then ESX.ShowNotification('Non hai abbastanza soldi per chiamare un taxi!') return end
		if not DoesEntityExist(taxiVeh) and not delay then 
			delay = true
			ESX.ShowNotification('Hai chiamato un taxi, presto arriverà da te!')	
			if not IsPedInAnyVehicle(playerPed, false) or not IsPedInAnyTaxi(playerPed) then
				Px, Py, Pz = table.unpack(GetEntityCoords(playerPed))
	
				taxiVeh = CreateTaxi(Px, Py, Pz)
				while not DoesEntityExist(taxiVeh) do
					Wait(1)
				end
	
				taxiPed = CreateTaxiPed(taxiVeh)
				while not DoesEntityExist(taxiPed) do
					Wait(1)
				end
				delay = false
				TaskVehicleDriveToCoord(taxiPed, taxiVeh, Px, Py, Pz, 26.0, 0, GetEntityModel(taxiVeh), drivingStyle, 10.0)
				SetPedKeepTask(taxiPed, true)
				PlayerEntersTaxi = false
				IsDestinationSet = false

				
				TaxiLoop(taxiVeh)
			end
		else
			ESX.ShowNotification('Hai già chiamato un taxi, attendi che arrivi!', 'error')
		end
	end, nil)


end)

function TaxiLoop(tax)
	local taxiPreso = false
	Citizen.CreateThread(function()
		local t = 60
		while not PlayerEntersTaxi and t > 0 do
			if(GetEntitySpeed(tax) < 1) then
				t = t - 1
			end
			Wait(1000)
		end

		if(t <=0) then
			DeleteTaxi(taxiVeh, taxiPed)
			ESX.ShowNotification('Il taxi ha aspettato troppo tempo e se n\'è andato.')
		end
	end)
	Citizen.CreateThread(function()
		local timer = 1000
		local dx, dy, dz, z
		while DoesEntityExist(taxiVeh) do
			player = PlayerId()
			playerPed = PlayerPedId()

			if NetworkIsGameInProgress() and IsPlayerPlaying(player) then
				timer = 1000
				local Px, Py, Pz = table.unpack(GetEntityCoords(playerPed))
				local vehX, vehY, vehZ = table.unpack(GetEntityCoords(taxiVeh))
				DistanceBetweenTaxi = GetDistanceBetweenCoords(Px, Py, Pz, vehX, vehY, vehZ, true)
				if IsVehicleStuckOnRoof(taxiVeh) or IsEntityUpsidedown(taxiVeh) or IsEntityDead(taxiVeh) or IsEntityDead(taxiPed) then	
					return DeleteTaxi(taxiVeh, taxiPed)
				end

				if DistanceBetweenTaxi <= 20.0 then
					timer = 5
					if not IsPedInAnyVehicle(playerPed, false) then
						if not IsPedInVehicle(taxiPed, taxiVeh, false) and PlayerEntersTaxi then
							PlayerEntersTaxi = false
							DeleteTaxi(taxiVeh, taxiPed)
							if IsDestinationSet then
								ESX.TriggerServerCallback('taxisystem:checkPlayerMoney', function(ok) end, true)
							end
						end
						
						if IsDestinationSet then
							IsDestinationSet = false
							DeleteTaxi(taxiVeh, taxiPed)
							ESX.ShowNotification('Sei uscito dal taxi, la corsa è stata annullata.', 'error')
							ESX.TriggerServerCallback('taxisystem:checkPlayerMoney', function(ok) end, true)
							return
						end
						
						if IsControlJustPressed(0, 23) and not PlayerEntersTaxi then
							TaskEnterVehicle(playerPed, taxiVeh, -1, 2, 1.0, 1, 0)
							
							TaxiInfoTimer = GetGameTimer()
							Citizen.CreateThread(function()
								while not IsPedInVehicle(playerPed, taxiVeh, false) do
									Wait(500)
								end
								PlayerEntersTaxi = true
							end)
						end
					else
						if IsPedInVehicle(playerPed, taxiVeh, false) then
							local blip = GetBlipFromEntity(taxiVeh)
							if DoesBlipExist(blip) then
								RemoveBlip(blip)
							end

							if not DoesBlipExist(GetFirstBlipInfoId(8)) and not IsDestinationSet then

								if GetGameTimer() > TaxiInfoTimer + 1000 and GetGameTimer() < TaxiInfoTimer + 10000 then
									DisplayHelpMsg("Seleziona la tua destinazione sulla mappa, quindi premi ~INPUT_PICKUP~ per iniziare.")
								end
							elseif DoesBlipExist(GetFirstBlipInfoId(8)) or IsDestinationSet then

								if IsControlJustPressed(1, 51) then
									if not IsDestinationSet then

										dx, dy, dz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, GetFirstBlipInfoId(8), Citizen.ResultAsVector()))
										z = getGroundZ(dx, dy, dz)
										IsDestinationSet = true
									end

									PlayAmbientSpeech1(taxiPed, "TAXID_BEGIN_JOURNEY", "SPEECH_PARAMS_FORCE_NORMAL")
									
									TaskVehicleDriveToCoord(taxiPed, taxiVeh, dx, dy, z, 26.0, 0, GetEntityModel(taxiVeh), drivingStyle, 10.0)
									SetPedKeepTask(taxiPed, true)
								end
								local distance = GetDistanceBetweenCoords(Px,Py, 0, dx, dy, 0, true) - 50

								if distance <= 50.0 then
									if not parking and GetEntitySpeed(taxiVeh)<=1 then
										IsDestinationSet = false
										ESX.TriggerServerCallback('taxisystem:checkPlayerMoney', function(ok) end, true)
										ClearPedTasks(taxiPed)
										PlayAmbientSpeech1(taxiPed, "TAXID_CLOSE_AS_POSS", "SPEECH_PARAMS_FORCE_NORMAL")
										TaskVehicleTempAction(taxiPed, taxiVeh, 6, 2000)
										SetVehicleHandbrake(taxiVeh, true)
										SetVehicleEngineOn(taxiVeh, false, true, true)
										SetPedKeepTask(taxiPed, true)
										parking = true
										DeleteTaxi(taxiVeh, taxiPed)	
									end
								end
							end
						
						end
					
					end
				end
			end
			Citizen.Wait(timer)		
		end
	end)
end

