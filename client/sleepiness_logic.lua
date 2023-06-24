local movementSet = {
	"move_m@drunk@slightlydrunk",
	"move_m@drunk@moderatedrunk",
	"move_m@drunk@verydrunk"
}

RegisterNetEvent('esx_status:loaded')
AddEventHandler('esx_status:loaded', function(status)
	TriggerEvent('esx_status:registerStatus', 'sleepiness', 0, '#e10000', function(status)
		return true
	end, function(status)
		if(status.getPercent() >= 95) then				--pass out and sleep a little
			status.remove(200000)
			SetEntityHealth(PlayerPedId(), 0)
		elseif(status.getPercent() > 90) then
			SetCamEffect(2)								--distorted vision
			setImpairedMovement(3)						--worst drunken movemnet
		elseif(status.getPercent() > 80) then
			SetCamEffect(1)								--distorted vision
			setImpairedMovement(3)						--worst drunken movemnet
		elseif(status.getPercent() > 70) then
			SetCamEffect(1)
			setImpairedMovement(3)						--worst drunken movemnet
		elseif(status.getPercent() > 60) then
			SetCamEffect(1)
			setImpairedMovement(3)						--worst drunken movement
		elseif(status.getPercent() > 55) then
			SetCamEffect(1)
			setImpairedMovement(2)						--drunken movement worsens
		elseif(status.getPercent() > 50) then
			SetCamEffect(1)
			setImpairedMovement(1) 						--drunken movement
		elseif(status.getPercent() > 40) then
			SetCamEffect(1)
			ResetPedMovementClipset(PlayerPedId(), 0)
		elseif(status.getPercent() <= 40) then 			--clean up ailments
			SetCamEffect(0)
			ResetPedMovementClipset(PlayerPedId(), 0)
		end

		slowedMovement 	= (status.getPercent() > 80)
		noRunning 		= (status.getPercent() > 65)
		noStamina 		= (status.getPercent() > 45)

		status.add(Config.tickSleep)
	end)
end)

function setImpairedMovement(level)
	if not HasAnimSetLoaded(movementSet[level]) then RequestAnimSet(movementSet[level]) end
	while not HasAnimSetLoaded(movementSet[level]) do Wait(0) end
	return SetPedMovementClipset(PlayerPedId(), movementSet[level], true)
end

-- Control no running and other
-- ills that run on every frame
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if noRunning then
			DisableControlAction(0,21,true)
		end
		if noStamina then
			SetPlayerStamina(PlayerId(), 0.0)
		end
		if slowedMovement then
			SetPedMoveRateOverride(PlayerPedId(), 0.7)
		end
	end
end)