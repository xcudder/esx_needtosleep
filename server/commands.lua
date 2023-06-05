RegisterCommand("add_to_status", function(source, a)
	TriggerClientEvent("esx_status:add", source, a[1], a[2])
end, true)

RegisterCommand("remove_from_status", function(source, a)
	TriggerClientEvent("esx_status:remove", source, a[1], a[2])
end, true)