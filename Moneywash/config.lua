Config = {}

--  Geldwäsche Punkte 
Config.LaunderPoints = {
    vector3(918.4657, -3198.8174, -98.2621),
    vector3(108.1526, -1980.1936, 20.9626)
}

--  Maximale Distanz zum Interagieren
Config.MaxDistance = 1.2

--  Geldwäsche-Raten
Config.Rates = {
    {min = 0,     max = 1000,   rate = 0.80},
    {min = 1001,  max = 5000,   rate = 0.70},
    {min = 5001,  max = 10000,  rate = 0.60},
    {min = 10001, max = 999999, rate = 0.50},
}

-- Weitere Einstellungen
Config.MinAmount = 50
Config.StepAmount = 50
Config.Cooldown = 60

Config.Webhook = "DEINE WEBHOOK"

Config.BannerColor = {r = 10, g = 120, b = 200, a = 230}

Config.WashTime = 35
Config.AnimationDict = "mini@repair"
Config.AnimationName = "fixing_a_player" 
Config.ProgressLabel = "Geld wird gewaschen..."

