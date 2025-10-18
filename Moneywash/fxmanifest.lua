fx_version 'cerulean'
game 'gta5'

author 'By Ryan'
description 'Geldwäsche System'
version '1.0.3'

files {
    'stream/newbanner.ytd'
}

shared_script 'config.lua'

client_scripts {
    '@NativeUI/NativeUI.lua',
    '@ox_lib/init.lua',
    '@es_extended/locale.lua',
    'client.lua',
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua',
}
