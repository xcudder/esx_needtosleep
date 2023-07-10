RegisterNetEvent('esx_property:enter', function(PropertyId)
	TriggerClientEvent("esx_needtosleep:enteredProperty", source)
end)

RegisterNetEvent('esx_property:leave', function(PropertyId)
	TriggerClientEvent("esx_needtosleep:leftProperty", source)
end)

ESX.RegisterServerCallback("esx_needtosleep:getitem", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	hasItem = xPlayer.getInventoryItem('blanket').count
	if GetResourceState('ox_inventory') == 'started' then
		hasItems = exports.ox_inventory:GetItem(source, 'blanket', nil, true)
	end 
	cb(hasItem)
end)

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
				TriggerClientEvent("esx_status:add", source, "hunger", 100000)
				TriggerClientEvent("esx_status:add", source, "sleepiness", 50000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "stress", 30000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "suggarydrink" then
				TriggerClientEvent("esx_status:add", source, "thirst", 100000)
				TriggerClientEvent("esx_status:add", source, "sleepiness", 50000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "stress", 30000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "coffee" then
				TriggerClientEvent("esx_status:add", source, "stress", 40000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "sleepiness", 100000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "coffee" then
				TriggerClientEvent("esx_status:add", source, "stress", 20000) -- detrimental add
				TriggerClientEvent("esx_status:remove", source, "sleepiness", 120000) -- benign remove
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "whisky" then
				TriggerClientEvent("esx_status:remove", source, "stress", 200000) -- benign remove
				TriggerClientEvent("esx_status:add", source, "sleepiness", 50000) -- detrimental add
				TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop)
			elseif k == "cigarette" then
				TriggerClientEvent("esx_status:remove", source, "stress", 200000) -- benign remove
				TriggerClientEvent("esx_status:remove", source, "thirst", 50000)
				TriggerClientEvent("esx_needtosleep:cigaretteUsed", source)
			end
		end)
	end 
end)