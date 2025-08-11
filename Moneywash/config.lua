Config = {}

Config.LaunderPoint = vector3(918.4657, -3198.8174, -98.2621) -- Die Coords wo Euer Wash stehen soll 
Config.MaxDistance = 1.2

Config.Rates = {
    {min = 0,     max = 1000,   rate = 0.80},
    {min = 1001,  max = 5000,   rate = 0.70},
    {min = 5001,  max = 10000,  rate = 0.60},
    {min = 10001, max = 999999, rate = 0.50},
}

Config.MinAmount = 50
Config.StepAmount = 50  -- Nicht verwendet, aber belassen
Config.Cooldown = 60    -- In Sekunden

Config.Webhook = "YOUR DISCORD WEBHOCK"

Config.BannerColor = {r = 10, g = 120, b = 200, a = 230}  -- Nicht verwendet, aber belassen

Config.WashTime = 35    -- In Sekunden

Config.AnimationDict = "amb@prop_human_bbq@male@base"
Config.AnimationName = "base"

Config.ProgressLabel = "💦 Geld wird gewaschen..."