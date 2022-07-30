fx_version 'cerulean'
game 'gta5'
description 'ak47 extendedcore'
version '1.0.0'

shared_scripts {
	'locale.lua',
	'locales/en.lua',
}

server_scripts {
	'config.lua',
	'server/qb.lua',
	'server/functions.lua',
	
	'common/functions.lua',
	'common/modules/math.lua',
	'common/modules/table.lua',

	'server/events.lua',
	'server/esx_addonaccount.lua',
}

client_scripts {
	'config.lua',
	'client/qb.lua',
	'client/entityiter.lua',
	'client/functions.lua',

	'common/functions.lua',
	'common/modules/math.lua',
	'common/modules/table.lua',

	'client/events.lua',
	'client/wrapper.lua',
	'client/esx_society.lua',
}

provides {
	'es_extended'
}