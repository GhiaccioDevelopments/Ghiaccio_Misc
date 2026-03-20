fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Ghiaccio'

shared_scripts {
    'config/*.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua'
}


ui_page 'html/index.html'


data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' 'metas/**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'metas/**/weaponanimations.meta'
data_file 'WEAPONINFO_FILE' 'metas/**/weapons.meta'
data_file 'PED_METADATA_FILE' 'metas/**/peds.meta'


files {
    'html/index.html',
    'html/assets/*.js',
    'html/assets/*.css',
    'metas/**/*.meta',
    'metas/**/weaponcomponents.meta',
    'metas/**/peds.meta'
}
