CreateThread(function()
	for k,v in pairs(Config.Items) do
		-- TODO: Rewrite this so the usableitem
		-- callback doesnt have to check key
		ESX.RegisterUsableItem(k, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)

			if v.remove then
				xPlayer.removeInventoryItem(k,1)
			end

			if k == "junkfood" then
				TriggerClientEvent("esx_status:add", source, "hunger", 80000)
				TriggerClientEvent("esx_status:add", source, "sleepiness", 100000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "stress", 30000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "suggarydrink" then
				TriggerClientEvent("esx_status:add", source, "thirst", 80000)
				TriggerClientEvent("esx_status:add", source, "sleepiness", 100000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "stress", 30000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "coffee" then
				TriggerClientEvent("esx_status:add", source, "stress", 20000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "sleepiness", 50000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "whisky" then
				TriggerClientEvent("esx_status:remove", source, "stress", 100000) -- benign remove
				TriggerClientEvent("esx_status:add", source, "sleepiness", 5000) -- detrimental add
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "cigarette" then
				TriggerClientEvent("esx_status:remove", source, "stress", 50000) -- benign remove
				TriggerClientEvent("esx_needtosleep:cigaretteUsed", source)
			else
				print(string.format('^1[ERROR]^0 %s has no correct type defined.', k))
			end
		end)
	end 
end)
