fx_version "cerulean"
lua54 "yes"
game "gta5"

name "xc_rentals"
version "2.0.0"
description "Simple vehicle rentals"
author "wibowo#7184"

shared_script "@ox_lib/init.lua"
shared_script "config.lua"
shared_script "shared.lua"
shared_script "locales/*.lua"

client_script "bridge/**/client.lua"
server_script "bridge/**/server.lua"

client_script "client/playerdata.lua"
client_script "client/*.lua"

server_script "server/player.lua"
server_script "server/*.lua"

dependencies {
    "ox_lib",
    -- "ox_target", -- optional
}