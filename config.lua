Config  = {}
Config.translation = {}

Config.versionCheck = true -- check for updates

Config.Locale = "en"

Config.target = true -- only ox_target compatible

Config.location = {
    {
        menu = vector4(-721.22, -1325.84, 1.6, 321.43), -- menu access location
        spawn = vector4(-711.79, -1336.29, -0.31, 132.96), -- spawned vehicle location
        distance = 50.0,
        blip = { -- blip in location (optional)
            label = "Boat Rental",
            sprite = 427, -- blip configuration for current location
            scale = 0.6,
            color = 4
        },
        ped = { -- if Config.target = true
            model = "cs_beverly" -- ped model
        },
        marker = { -- if Config.target = false
            type = 24,
            scale = 0.5
        },
        vehicle = {
            {
                model = "seashark", -- vehicle model
                image = "https://gtacars.net/images/da9ab09a97da964b5fc2e94bf8388ce5", -- image url (optional)
                fee = 1000 -- rental fee
            },
            {
                model = "speeder",
                image = "https://gtacars.net/images/463f92dc32f7b83b0580f80f060ba903",
                fee = 1000
            },
            {
                model = "seashark2",
                image = "https://gtacars.net/images/99289d92396eda3d66da8696e81da36e",
                fee = 2000,
                job = "mechanic" -- job restriction (optional) could be string or table (array, hash or mixed).
            },
            {
                model = "seashark3",
                image = "https://gtacars.net/images/b07e397ea05f349daa543485db7b4dd8",
                fee = 3000,
                job = { -- table array example
                    "mechanic",
                    "ambulance"
                }
            },
            {
                model = "longfin",
                fee = 5000,
                job = { -- table hash example, value is job grade.
                    ["mechanic"] = 1,
                    ["ambulance"] = 2,
                }
            },
            {
                model = "squalo",
                fee = 5000,
                job = { -- table mixed example
                    ["mechanic"] = 0,
                    "ambulance"
                }
            },
        }
    },
    {
        menu = vector4(-721.34, -1301.31, 5.1, 50.91),
        spawn = vector4(-724.73, -1294.29, 5.0, 49.63),
        distance = 50.0,
        blip = { -- blip in location (optional)
            label = "Public Rental",
            sprite = 185, -- blip configuration for current location
            scale = 0.6,
            color = 5
        },
        ped = { -- if Config.target = true
            model = "cs_beverly"
        },
        marker = { -- if Config.target = false
            type = 3,
            scale = 1.0
        },
        vehicle = {
            {
                model = "bmx",
                image = "https://gtacars.net/images/4596bd7f7aab3d7e1d537ea929b239e4",
                fee = 1000
            },
            {
                model = "scorcher",
                fee = 2000
            },
            {
                model = "tribike3",
                fee = 3000
            },
            {
                model = "double",
                image = "https://gtacars.net/images/389fcc1d7919c02d204d768234e67c34",
                fee = 30000
            },
            {
                model = "asea",
                image = "https://gtacars.net/images/9be5429b46e633feaed1d00d2bed6aa6",
                fee = 100000
            }
        }
    },
    -- could add more locations
}