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