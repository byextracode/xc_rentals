Config  = {}

Config.Locale = "en"

Config.caution = 5000

Config.menu = {
    vector4(-721.22, -1325.84, 1.6, 321.43),
    vector4(833.93, -3349.9, 5.9, 4.75),
    vector4(-1608.58, 5260.5, 3.97, 116.41),
    vector4(-278.37, 6620.32, 7.54, 39.82),
    vector4(3373.35, 5183.66, 1.46, 81.89),
    vector4(2818.99, -671.68, 1.18, 259.84),
    vector4(-1799.56, -1224.81, 1.59, 143.14),
    vector4(1301.27, 4216.7, 33.91, 76.78),
    vector4(4898.38, -5168.95, 2.46, 155.64),
    vector4(3835.75, -43.96, 2.28, 268.74),
}

Config.spawn = {
    vector4(-711.79, -1336.29, -0.31, 132.96),
    vector4(833.7, -3362.4, -0.08, 103.3),
    vector4(-1596.16, 5269.42, -0.24, 39.88),
    vector4(-298.93, 6620.16, -0.51, 30.26),
    vector4(3387.61, 5198.89, -0.76, 321.66),
    vector4(2857.12, -675.11, -0.47, 251.41),
    vector4(-1786.14, -1246.84, -0.52, 121.1),
    vector4(1275.89, 4214.15, 29.11, 180.42),
    vector4(4900.5, -5150.76, -0.25, 82.2),
    vector4(3833.93, -61.08, 0.1, 85.74),
}

Config.ped = {
    enable = true,
    model = "cs_beverly"
}

Config.blip = {
    enable = true,
    sprite = 427,
    scale = 0.6,
    color = 4
}

Config.boat = {
    {
        model = {
            "dinghy4",
            "marquis",
            "seashark",
            "seashark3",
            "speeder",
        }
    },
    {
        job = "police",
        model = {
            "seashark2"
        }
    },
    {
        job = "ambulance",
        model = {
            "longfin"
        }
    },
    {
        job = "mechanic",
        model = {
            "longfin"
        }
    },
}

Config.returnmoney = false

Config.translation = {
    ["en"] = {
        ["someone_veh"] = "Someone vehicle!",
        ["err"] = "Error",
        ["caution"] = "Fee: $%s",
        ["not_enough_money"] = "Not enough money",
        ["rent"] = "Rent",
        ["blip_label"] = "Rentals",
        ["return_vehicle"] = "Return vehicle",
    }
}