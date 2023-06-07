-- 8 in game hours (16 IRL minutes) should have you all rested, this takes into account
-- the esx status tick that would be adding sleep even now... that should probably
-- be fixed with some is_sleeping status or something... oh well
RegisterCommand("sleep", function(source, a)
	local sleeping = true
	local sleep_for = a[1] or 16 -- IRL Minutes
	local wait_time = sleep_for * 2 * 60 * 1000 

	DoScreenFadeOut(1000)

	while sleeping do
		Wait(1000)
		wait_time = wait_time - 1000
		ESX.ShowNotification("Sleeping... " .. (wait_time / 1000))
		
		-- This is breaking... idk y yet...
		-- TriggerClientEvent("esx_status:remove", source, 'sleepiness', 1215.3)

		sleeping = (wait_time > 0)
	end

	DoScreenFadeIn(1000)
end, false)