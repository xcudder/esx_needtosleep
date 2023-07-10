local createdCommunePeds = false
local ov3 = vector3(-102.1, 6345.04, 31.58)
local iv3 = vector3(151.41, -1007.96, -99.0)

-- Keep commune running
CreateThread(function()
	if Config.CommuneDisabled then return end
	setupBlip({ title="Paleto Commune", colour=1, id=492 , v3=ov3 })
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
				DisplayRadar(false)
				DoScreenFadeIn(1000)
				createCommunePeds()
				TriggerEvent("esx_needtosleep:enteredPaletoCommune")
			end
		end

		if coordinates_close_enough(iv3) then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to exit the ~y~commune")
			if(IsControlJustReleased(1, 38)) then
				DoScreenFadeOut(1000)
				Wait(1000)
				SetEntityCoords(PlayerPedId(), -102.1, 6345.04, 30.58)
				DisplayRadar(true)
				DoScreenFadeIn(1000)
				TriggerEvent("esx_needtosleep:leftPaletoCommune")
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