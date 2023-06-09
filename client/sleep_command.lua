local isInProperty = false
local sleeping = false
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

RegisterCommand("sleep", function(source, args)
	sleepCommand(source, args)
end)


-- Keep commune running
CreateThread(function()
	local v3 = vector3(-102.1, 6345.04, 31.58)
	local lv3 = vector3(151.41, -1007.96, -99.0)
	setupBlip({title="Paleto Commune", colour=1, id=492 }, v3)
	while true do
		Wait(0)
		DrawMarker(0, v3.x, v3.y, v3.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 244, 244, 23, 100, true, true, 2, true, false, false, false)	
		DrawMarker(0, lv3.x, lv3.y, lv3.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 244, 244, 23, 100, true, true, 2, true, false, false, false)	
		
		-- if coordinates_close_enough(v3) then
		-- 	DisplayHelpText("Press ~INPUT_CONTEXT~ to enter the ~y~commune")
		-- 	if(IsControlJustReleased(1, 38)) then
		-- 		SetEntityCoords(PlayerPedId(), lv3.x, lv3.y, lv3.z)
		-- 		isInPaletoComune = true
		-- 	end
		-- end

		-- if coordinates_close_enough(lv3) then
		-- 	DisplayHelpText("Press ~INPUT_CONTEXT~ to exit the ~y~commune")
		-- 	if(IsControlJustReleased(1, 38)) then
		-- 		SetEntityCoords(PlayerPedId(), v3.x, v3.y, v3.z)
		-- 		isInPaletoComune = false
		-- 	end
		-- end
	end
end)

-- Silly logic abstractions
function sleepCommand(source, args)
	-- 8 in game hours (16 IRL minutes) should have you all rested, this takes into account
	-- the esx status tick that would be adding sleep even now... that should probably
	-- be fixed with some is_sleeping status or something... oh well
	if not canSleep() then return end

	sleeping = true
	local sleep_for = args[1] or 16 -- IRL Minutes
	local wait_time = sleep_for * 2 * 60 * 1000 

	DoScreenFadeOut(1000)

	while sleeping do
		Wait(1000)
		wait_time = wait_time - 1000
		ESX.ShowNotification("Sleeping... " .. (wait_time / 1000))

		TriggerEvent("esx_status:remove", 'sleepiness', (1215.3 * restQuality))
		TriggerEvent("esx_status:remove", 'stress', (1215.3 * restQuality))

		sleeping = (wait_time > 0)
	end

	DoScreenFadeIn(1000)
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