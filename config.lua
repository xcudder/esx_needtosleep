Config = {}

Config.Debug = false

Config.Items = {
	["junkfood"] = {
		type = "food",
		prop = "prop_donut_01",
		remove = true
	},
	
	["sugarydrink"] = {
		type = "drink",
		prop = "prop_orang_can_01",
		remove = true
	},
	
	["coffee"] = {
		type = "drink",
		prop = "p_amb_coffeecup_01",
		remove = true
	},

	["whisky"] = {
		type = "drink",
		prop = "prop_drink_whisky",
		remove = true
	},

	["cigarette"] = {
		type = "consume",
		prop = false,
		remove = true
	}
}

-- This is based on a 48min GTA day (default)
-- and 1000 tick time and 1000000 max status
-- on esx_status
Config.tickSleep = 185.18
Config.sleepRecoveryOnTick = 555.55 + 185.18
Config.stressRecoveryOnTick = 185.18
Config.hungerRecoveryOnTick = 50.00
Config.thirstRecoveryOnTick = 37.5
