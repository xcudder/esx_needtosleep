local isInProperty = false
local sleeping = false
local wakeup_imminent = false
local xPlayer = false
local hasBlanket = false
local restQuality = 1
local isInPaletoComune = false

-- Hooks and callbacks
RegisterNetEvent('esx_needtosleep:enteredProperty')
AddEventHandler('esx_needtosleep:enteredProperty', function(pId)
	isInProperty = true
end)

RegisterNetEvent('esx_needtosleep:leftProperty')
AddEventHandler('esx_needtosleep:leftProperty', function(pId)
	isInProperty = false
end)

AddEventHandler('esx_needtosleep:enteredPaletoCommune', function()
	isInPaletoComune = true
end)

AddEventHandler('esx_needtosleep:leftPaletoCommune', function()
	isInPaletoComune = false
end)

RegisterCommand("sleep", function(source, args)
	goToSleep(source, args)
end)

RegisterCommand("wakeup", function(source, args)
	wakeup(source, args)
end)


function goToSleep(source, args)
	wakeup_imminent = false
	-- 8 in game hours should have you all rested, this takes into account
	-- the esx status tick that would be adding sleep even now... that should probably
	-- be fixed with some is_sleeping status or something... oh well
	if not canSleep() then return end

	sleeping = true
	local sleep_for = args[1] or 16 -- default sleep time, 16 IRL Minutes
	local wait_time = sleep_for * 60 * 1000
	local current_percentage = false
	local sleepMultiplier = 1

	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SUNBATHE_BACK", 0, true)
	Wait(1000)
	FreezeEntityPosition(PlayerPedId(), true)

	while sleeping do
		Wait(1000)
		sleepMultiplier = 1
		wait_time = wait_time - 1000
		ESX.ShowNotification("Sleeping... " .. (wait_time / 1000))

		TriggerEvent('esx_status:getStatus', 'sleepiness', function(status) current_percentage = status.getPercent() end)
		while not current_percentage do Wait(100) end

		if current_percentage > 40 then sleep_multiplier = 2 end

		TriggerEvent("esx_status:remove", 'sleepiness', (Config.sleepRecoveryOnTick * sleepMultiplier * restQuality))
		TriggerEvent("esx_status:remove", 'stress', (Config.stressRecoveryOnTick * sleepMultiplier * restQuality))

		sleeping = (wait_time > 0)

		if wakeup_imminent then
			sleeping = false
			wakeup_imminent = false
		end
	end

	wakeup()
end

function wakeup(source, args)
	wakeup_imminent = true
	FreezeEntityPosition(PlayerPedId(), false)
	ClearPedTasksImmediately(PlayerPedId())
end

function canSleep()
	-- can always sleep in own property
	if isInProperty then
		restQuality = 1.0
		return true
	end

	-- can always sleep in the commune
	if isInPaletoComune then
		restQuality = 0.85
		return true
	end

	-- Can sleep inside a stationary non-stolen car
	local vehicle = GetVehiclePedIsIn(PlayerPedId())
	if vehicle ~= 0 then
		vehicle_props = ESX.Game.GetVehicleProperties(vehicle)
		if IsThisModelACar(vehicle_props.model) then
		 	if not IsVehicleStolen(vehicle) then
			 	if IsVehicleStopped(vehicle) then
			 		restQuality = 0.85
					return true
				else
					Wait(1000)
					ESX.ShowHelpNotification("Can't sleep inside a moving vehicle")
					return false
				end
			else
				Wait(1000)
				ESX.ShowHelpNotification("Can't sleep inside a stolen car")
				return false
			end
		end
	end

	-- can sleep in any interior where you are "alone"
	local ppedv3 = GetEntityCoords(PlayerPedId())
	if GetInteriorFromEntity(PlayerPedId()) ~= 0 then
		if not GetClosestPed(ppedv3.x, ppedv3.y, ppedv3.z, 50) then
			restQuality = 0.7
			return true
		else
			ESX.ShowHelpNotification("Can't sleep in this interior when there are people nearby")
			return false
		end
	else
		ESX.TriggerServerCallback("esx_needtosleep:getitem", function(blanketCount) hasBlanket = blanketCount end)
		Wait(1000)
		if hasBlanket > 0 then
			ESX.ShowHelpNotification("When sleeping on the street you'll have a lower quality rest")
			Wait(2000)
			restQuality = 0.6
			return true
		else
			ESX.ShowHelpNotification("Can't sleep on the outside without a blanket item")
			return false
		end
	end

	return false
end