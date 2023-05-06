fx_version "cerulean"
lua54 "yes"
game "gta5"

name "xc_rentals"
version "0.1.0"
description "Vehicle rentals"
author "wibowo#7184"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}

shared_script "config.lua"
client_script "**/cl_*.lua"
server_script "**/sv_*.lua"

dependencies {
    "es_extended",
    "ox_lib",
}