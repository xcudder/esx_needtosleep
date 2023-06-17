local isInProperty = false
local sleeping = false
local wakeup_imminent = false
local xPlayer = false
local hasBlanket = false
local restQuality = 1
local isInPaletoComune = false
local ov3 = vector3(-102.1, 6345.04, 31.58)
local iv3 = vector3(151.41, -1007.96, -99.0)
createdCommunePeds = false

-- Hooks and callbacks
RegisterNetEvent('esx_needtosleep:enteredProperty')
AddEventHandler('esx_needtosleep:enteredProperty', function(pId)
	isInProperty = true
end)

RegisterNetEvent('esx_needtosleep:leftProperty')
AddEventHandler('esx_needtosleep:leftProperty', function(pId)
	isInProperty = false
end)

RegisterCommand("sleep", function(source, args)
	sleepCommand(source, args)
end)

RegisterCommand("wakeup", function(source, args)
	wakeup(source, args)
end)


-- Keep commune running
CreateThread(function()
	setupBlip({title="Paleto Commune", colour=1, id=492 }, ov3)
	while true do
		Citizen.Wait(0)
		DrawMarker(0, ov3.x, ov3.y, ov3.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 244, 244, 23, 100, true, true, 2, true, false, false, false)
		DrawMarker(0, iv3.x, iv3.y, iv3.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 244, 244, 23, 100, true, true, 2, true, false, false, false)

		if coordinates_close_enough(ov3) then
		DisplayHelpText("Press ~INPUT_CONTEXT~ to enter the ~y~commune")
			if(IsControlJustReleased(1, 38)) then
				DoScreenFadeOut(1000)
				Wait(1000)
				SetEntityCoords(PlayerPedId(), 151.41, -1007.96, -100.0)
				DoScreenFadeIn(1000)
				createCommunePeds()
				isInPaletoComune = true
			end
		end

		if coordinates_close_enough(iv3) then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to exit the ~y~commune")
			if(IsControlJustReleased(1, 38)) then
				DoScreenFadeOut(1000)
				Wait(1000)
				SetEntityCoords(PlayerPedId(), -102.1, 6345.04, 30.58)
				DoScreenFadeIn(1000)
				isInPaletoComune = false
			end
		end
	end
end)

-- Silly logic abstractions
function createCommunePeds()
	if createdCommunePeds then return end
	createSingleCommunePed(0x4705974A, vector3(154.90, -1002.50, -100.50), "PROP_HUMAN_SEAT_CHAIR", 110.0)
	createSingleCommunePed(0x6A8F1F9B, vector3(152.36, -1000.14, -100.0), "WORLD_HUMAN_MUSCLE_FLEX", 0.0)
	createSingleCommunePed(0x48F96F5B, vector3(154.36, -1004.50, -99.42), "WORLD_HUMAN_BUM_SLUMPED", 80.0)
	createSingleCommunePed(0x1EC93FD0, vector3(154.32, -1006.46, -100.0), "WORLD_HUMAN_SMOKING_POT", 80.0)
	createSingleCommunePed(0x174D4245, vector3(153.56, -1007.63, -100.50), "PROP_HUMAN_SEAT_CHAIR", 0.0)
	createSingleCommunePed(0x8CA0C266, vector3(150.65, -1006.45, -100.0), "WORLD_HUMAN_LEANING", 240.0)
	createSingleCommunePed(0x53B57EB0, vector3(153.44, -1005.26, -100.50), "PROP_HUMAN_SEAT_CHAIR", 80.0)
	createdCommunePeds = true
end

function createSingleCommunePed(hash, v3, ped_scenario, heading)
	RequestModel(hash)

	while not HasModelLoaded(hash) do
		Wait(1)
	end

	local ped = CreatePed(1, hash,v3.x,v3.y,v3.z, 60, false, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	SetPedDiesWhenInjured(ped, false)
	SetPedCanPlayAmbientAnims(ped, true)
	SetPedCanRagdollFromPlayerImpact(ped, false)
	SetEntityInvincible(ped, true)
	SetEntityHeading(ped, heading)
	FreezeEntityPosition(ped, true)
	TaskStartScenarioInPlace(ped, ped_scenario, 0, true);
	return ped
end

function sleepCommand(source, args)
	-- 8 in game hours (16 IRL minutes) should have you all rested, this takes into account
	-- the esx status tick that would be adding sleep even now... that should probably
	-- be fixed with some is_sleeping status or something... oh well
	if not canSleep() then return end

	sleeping = true
	local sleep_for = args[1] or 16 -- IRL Minutes
	local wait_time = sleep_for * 2 * 60 * 1000 

	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SUNBATHE_BACK", 0, true)
	Wait(1000)
	FreezeEntityPosition(PlayerPedId(), true)

	while sleeping do
		Wait(1000)
		wait_time = wait_time - 1000
		ESX.ShowNotification("Sleeping... " .. (wait_time / 1000))

		TriggerEvent("esx_status:remove", 'sleepiness', (1215.3 * restQuality))
		TriggerEvent("esx_status:remove", 'stress', (1215.3 * restQuality))

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

function setupBlip(info, v3)
	info.blip = AddBlipForCoord(v3.x, v3.y, v3.z)
	SetBlipSprite(info.blip, info.id)
	SetBlipDisplay(info.blip, 4)
	SetBlipScale(info.blip, 0.9)
	SetBlipColour(info.blip, info.colour)
	SetBlipAsShortRange(info.blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(info.title)
	EndTextCommandSetBlipName(info.blip)
end

function coordinates_close_enough(arg)
	local A = GetEntityCoords(PlayerPedId(), false)
	return Vdist(arg.x, arg.y, arg.z, A.x, A.y, A.z) < 1.5
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end