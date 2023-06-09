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
	'client/sleep.lua',
	'client/stress.lua',
	'client/sleep_command.lua'
}

dependencies {
    'es_extended',
    'esx_status',
    'esx_basicneeds'
}