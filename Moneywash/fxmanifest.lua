fx_version 'cerulean'
game 'gta5'

author 'BrattanStudios'
description 'Blackwash System – Clean your dirty money with an intuitive NativeUI menu and progress bar. Configurable settings including webhooks and wash duration.'
version '1.0.0'  

shared_script 'config.lua'

client_scripts {
    '@NativeUI/NativeUI.lua',  -- Stelle sicher, dass NativeUI installiert ist
    '@ox_lib/init.lua',        -- ox_lib für Progressbar (installiere ox_lib als Resource)
    '@es_extended/locale.lua',
    'client.lua',
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua',
}