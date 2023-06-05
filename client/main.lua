local movementSet = {
	"move_m@drunk@slightlydrunk",
	"move_m@drunk@moderatedrunk",
	"move_m@drunk@verydrunk"
}
local impairedStamina = false
local impairedMovement = {}

RegisterNetEvent('esx_status:loaded')
AddEventHandler('esx_status:loaded', function(status)
	TriggerEvent('esx_status:registerStatus', 'sleepiness', 0, '#e10000', function(status)
		return true
	end, function(status)
		handleSleepiness(status)
	end)
end)

function handleSleepiness(sleepiness)
	sleepiness.add(173.6)
	if(sleepiness.getPercent() < 40) then clearUpSleepinessEffects() end 
	if(sleepiness.getPercent() > 40 and not impairedStamina) then impairedStamina = SetPlayerStamina(PlayerId(), 0) end
	if(sleepiness.getPercent() > 50 and not impairedMovement[1]) then impairedMovement[1] = setImpairedMovement(1) end
	if(sleepiness.getPercent() > 80 and not impairedMovement[2]) then impairedMovement[2] = setImpairedMovement(2) end
	if(sleepiness.getPercent() > 90 and not impairedMovement[3]) then impairedMovement[3] = setImpairedMovement(3) end
	if(impairedMovement[3]) then sleepiness.remove(520.8) end
end

function setImpairedMovement(level)
	RequestAnimSet(movementSet[level])
	while not HasAnimSetLoaded(movementSet[level]) do Wait(0) end
	return SetPedMovementClipset(PlayerPedId(), movementSet[level], true)
end

function clearUpSleepinessEffects()
	impairedMovement = {}
	impairedStamina = false
	ResetPedMovementClipset(playerPed, 0)
end