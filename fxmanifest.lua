fx_version 'adamant'

game 'gta5'

description 'ESX NeedToSleep'

shared_script '@es_extended/imports.lua'

server_scripts {
	'config.lua',
	'server/main.lua',
	'server/commands.lua',
}

client_scripts {
	'config.lua',
	'client/functions.lua',
	'client/sleepiness_logic.lua',
	'client/stress_logic.lua',
	'client/sleep_command.lua',
	'client/commune.lua',
}

dependencies {
    'es_extended',
    'esx_status',
    'esx_basicneeds'
}