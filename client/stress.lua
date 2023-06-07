local StoredDidPedTriggerVehicleAlarmWhileStealing 	= false
local StoredIsPedJacking 							= false
local StoredIsPedBeingJacked 						= false
local StoredIsPedRunning 							= false
local StoredIsPedSprinting 							= false
local StoredIsAnyHostilePedNearPoint 				= false
local StoredIsPedInsideStolenCar					= false

RegisterNetEvent('esx_status:loaded')
AddEventHandler('esx_status:loaded', function(status)
	TriggerEvent('esx_status:registerStatus', 'stress', 0, '#FF0000', function(status)
		return true
	end, function(status)
		if(status.getPercent() >= 90) then suicide() end
		
		if StoredDidPedTriggerVehicleAlarmWhileStealing then
			if(Config.debug == true) then ESX.ShowNotification("StoredDidPedTriggerVehicleAlarmWhileStealing") end
			TriggerEvent("esx_status:add", 'stress', 25000)
			StoredDidPedTriggerVehicleAlarmWhileStealing = false
		end
		if StoredIsPedJacking then
			if(Config.debug == true) then ESX.ShowNotification("StoredIsPedJacking") end
			TriggerEvent("esx_status:add", 'stress', 25000)
			StoredIsPedJacking = false
		end
		if StoredIsPedBeingJacked then
			if(Config.debug == true) then ESX.ShowNotification("StoredIsPedBeingJacked") end
			TriggerEvent("esx_status:add", 'stress', 50000)
			StoredIsPedBeingJacked = false
		end
		if StoredIsPedRunning then
			if(Config.debug == true) then ESX.ShowNotification("StoredIsPedRunning") end
			TriggerEvent("esx_status:add", 'stress', 1000)
			StoredIsPedRunning = false
		end
		if StoredIsPedSprinting then
			if(Config.debug == true) then ESX.ShowNotification("StoredIsPedSprinting") end
			TriggerEvent("esx_status:add", 'stress', 1000)
			StoredIsPedSprinting = false
		end
		if StoredIsPedInsideStolenCar then
			if(Config.debug == true) then ESX.ShowNotification("StoredIsPedInsideStolenCar") end
			TriggerEvent("esx_status:add", 'stress', 1000)
			StoredIsPedInsideStolenCar = false
		end
	end)
end)

AddEventHandler('gameEventTriggered', function (name, args)
	if(name ~= 'CEventNetworkEntityDamage') then return end
	if (args[1] == PlayerPedId() or args[2] == PlayerPedId()) then
		TriggerEvent("esx_status:add", 'stress', 10000)
	end
end)

Citizen.CreateThread(function()
	while true do
		ped = PlayerPedId()
		v3 = GetEntityCoords(ped)
		Wait(0)
		
		if(IsPedRunning(ped) and not StoredIsPedRunning) then StoredIsPedRunning = true end
		
		if(IsPedSprinting(ped) and not StoredIsPedSprinting) then StoredIsPedSprinting = true end
			
		if(DidPedTriggerVehicleAlarmWhileStealing(ped) and not StoredDidPedTriggerVehicleAlarmWhileStealing) then StoredDidPedTriggerVehicleAlarmWhileStealing = true end
		
		if(IsPedJacking(ped) and not StoredIsPedJacking) then StoredIsPedJacking = true end
		
		if(IsPedBeingJacked(ped) and not StoredIsPedBeingJacked) then StoredIsPedBeingJacked = true end

		if(IsPedInsideStolenCar(ped) and not StoredIsPedInsideStolenCar) then StoredIsPedInsideStolenCar = true end
	end
end)

function suicide()
	if not HasAnimDictLoaded('mp_suicide') then
		RequestAnimDict('mp_suicide')
		while not HasAnimDictLoaded('mp_suicide') do Wait(1) end
	end
	SetCurrentPedWeapon(PlayerPedId(), GetHashKey('weapon_unarmed'), true)
	TaskPlayAnim(PlayerPedId(), "mp_suicide", "pistol", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
	Wait(750)
	SetEntityHealth(PlayerPedId(), 0)
	TriggerEvent("esx_status:set", 'stress', 0)
end

function DidPedTriggerVehicleAlarmWhileStealing(ped)
	return IsVehicleAlarmActivated(GetVehiclePedIsEntering(ped))
end

function IsPedInsideStolenCar(ped)
	return IsVehicleStolen(GetVehiclePedIsEntering(ped)) or IsVehicleStolen(GetVehiclePedIsIn(ped))
end