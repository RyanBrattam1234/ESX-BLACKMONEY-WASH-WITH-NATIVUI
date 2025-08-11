local ESX = exports["es_extended"]:getSharedObject()
local MenuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("Geldwäsche", "~b~Geldwäsche Menü")
MenuPool:Add(mainMenu)

local lastWash = 0

local function GetRate(amount)
    for _, rateData in ipairs(Config.Rates) do
        if amount >= rateData.min and amount <= rateData.max then
            return rateData.rate
        end
    end
    return 0.5
end

local function StartWashing(amount)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if #(coords - Config.LaunderPoint) > Config.MaxDistance then
        ESX.ShowNotification("~r~Du bist nicht am Geldwäschepunkt.")
        return
    end

    if (GetGameTimer() - lastWash) < Config.Cooldown * 1000 then
        ESX.ShowNotification("~y~Bitte warte bevor du erneut wäschst.")
        return
    end

    -- Black money als Account prüfen (konsistent mit Server)
    local accounts = ESX.GetPlayerData().accounts
    local blackMoney = 0
    for _, account in ipairs(accounts) do
        if account.name == "black_money" then
            blackMoney = account.money
            break
        end
    end

    if blackMoney < amount then
        ESX.ShowNotification("~r~Du hast nicht genug Schwarzgeld.")
        return
    end

    lastWash = GetGameTimer()

    -- Animation aus Config laden und starten
    RequestAnimDict(Config.AnimationDict)
    while not HasAnimDictLoaded(Config.AnimationDict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, Config.AnimationDict, Config.AnimationName, 8.0, -8.0, -1, 49, 0, false, false, false)

    -- Kamera während Animation sperren
    DisableControlAction(0, 44, true)  -- Kamera (Maus X)
    DisableControlAction(0, 45, true)  -- Kamera (Maus Y)
    DisableControlAction(0, 24, true)  -- Maus Links-Klick
    DisableControlAction(0, 25, true)  -- Maus Rechts-Klick

    -- ox_lib Progressbar (angenommen ox_lib ist installiert)
    local success = lib.progressBar({
        duration = Config.WashTime * 1000,
        label = Config.ProgressLabel,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = true,  -- Maus explizit deaktivieren
        },
        anim = {
            dict = Config.AnimationDict,
            clip = Config.AnimationName,
            flag = 49,
        },
    })

    ClearPedTasks(playerPed)
    -- Kamera und Maus nach Animation freigeben
    DisableControlAction(0, 44, false)
    DisableControlAction(0, 45, false)
    DisableControlAction(0, 24, false)
    DisableControlAction(0, 25, false)

    if success then
        TriggerServerEvent("money_launder:process", amount)
    else
        ESX.ShowNotification("~r~Geldwäsche abgebrochen.")
    end
end

-- Menu aufbauen (statisch, kein Clear/Refresh nötig)
local washItem = NativeUI.CreateItem("💸 Geld waschen", "Gib den Betrag ein")
mainMenu:AddItem(washItem)

washItem.Activated = function(sender, item)
    -- Maussteuerung für Menü deaktivieren
    MenuPool:MouseControlsEnabled(false)
    MenuPool:MouseEdgeEnabled(false)
    MenuPool:ControlDisablingEnabled(false)

    AddTextEntry("FMMC_KEY_TIP1", "Betrag eingeben:")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 10)

    -- Kamera und Maus während Eingabe deaktivieren
    DisableControlAction(0, 30, true)  -- Bewegung (WASD)
    DisableControlAction(0, 31, true)  -- Bewegung (Joystick)
    DisableControlAction(0, 44, true)  -- Kamera (Maus X)
    DisableControlAction(0, 45, true)  -- Kamera (Maus Y)
    DisableControlAction(0, 24, true)  -- Maus Links-Klick
    DisableControlAction(0, 25, true)  -- Maus Rechts-Klick

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
        -- Maussteuerung während Eingabe deaktivieren
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 45, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
    end

    -- Controls nach Eingabe wieder freigeben
    DisableControlAction(0, 30, false)
    DisableControlAction(0, 31, false)
    DisableControlAction(0, 44, false)
    DisableControlAction(0, 45, false)
    DisableControlAction(0, 24, false)
    DisableControlAction(0, 25, false)

    -- Maussteuerung für Menü wieder aktivieren
    MenuPool:MouseControlsEnabled(true)
    MenuPool:MouseEdgeEnabled(true)
    MenuPool:ControlDisablingEnabled(true)

    local result = GetOnscreenKeyboardResult()
    if result and tonumber(result) then
        local amount = tonumber(result)
        if amount >= Config.MinAmount then
            StartWashing(amount)
        else
            ESX.ShowNotification(("~r~Mindestbetrag: %d$"):format(Config.MinAmount))
        end
    else
        ESX.ShowNotification("~r~Ungültiger Betrag.")
    end
end

-- Menu-Handling-Schleife
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if #(coords - Config.LaunderPoint) < Config.MaxDistance then
            sleep = 0
            ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um Geldwäsche Menü zu öffnen")
            if IsControlJustReleased(0, 38) then
                mainMenu:Visible(not mainMenu:Visible())
                if mainMenu:Visible() then
                    -- Kamera und Maus deaktivieren, wenn Menü geöffnet
                    DisableControlAction(0, 30, true)  -- Bewegung (WASD)
                    DisableControlAction(0, 31, true)  -- Bewegung (Joystick)
                    DisableControlAction(0, 44, true)  -- Kamera (Maus X)
                    DisableControlAction(0, 45, true)  -- Kamera (Maus Y)
                    DisableControlAction(0, 24, true)  -- Maus Links-Klick
                    DisableControlAction(0, 25, true)  -- Maus Rechts-Klick
                    MenuPool:MouseControlsEnabled(false)
                    MenuPool:MouseEdgeEnabled(false)
                    MenuPool:ControlDisablingEnabled(false)
                else
                    -- Controls wieder freigeben, wenn Menü geschlossen
                    DisableControlAction(0, 30, false)
                    DisableControlAction(0, 31, false)
                    DisableControlAction(0, 44, false)
                    DisableControlAction(0, 45, false)
                    DisableControlAction(0, 24, false)
                    DisableControlAction(0, 25, false)
                    MenuPool:MouseControlsEnabled(true)
                    MenuPool:MouseEdgeEnabled(true)
                    MenuPool:ControlDisablingEnabled(true)
                end
            end
        else
            if mainMenu:Visible() then
                mainMenu:Visible(false)
                -- Controls freigeben, wenn Menü geschlossen wird
                DisableControlAction(0, 30, false)
                DisableControlAction(0, 31, false)
                DisableControlAction(0, 44, false)
                DisableControlAction(0, 45, false)
                DisableControlAction(0, 24, false)
                DisableControlAction(0, 25, false)
                MenuPool:MouseControlsEnabled(true)
                MenuPool:MouseEdgeEnabled(true)
                MenuPool:ControlDisablingEnabled(true)
            end
        end

        MenuPool:ProcessMenus()
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Verhindert, dass die Schleife die CPU überlastet

        -- Koordinaten für den Marker (x, y, z)
        local markerCoords = vector3(918.4657, -3198.8174, -98.2621) -- Beispielkoordinaten, passe diese an
        local playerCoords = GetEntityCoords(PlayerPedId()) -- Position des Spielers
        local distance = #(playerCoords - markerCoords) -- Entfernung zwischen Spieler und Marker

        -- Marker nur rendern, wenn der Spieler in der Nähe ist (z. B. < 50 Einheiten)
        if distance < 50.0 then
            DrawMarker(
                22, -- Marker-Typ (1 ist ein vertikaler Zylinder)
                markerCoords.x, markerCoords.y, markerCoords.z - 0.5, -- Position (z-1.0, damit der Marker auf dem Boden liegt)
                0.0, 0.0, 0.0, -- Richtung (nicht benötigt für Typ 1)
                0.0, 0.0, 0.0, -- Rotation (nicht benötigt für Typ 1)
                1.0, 1.0, 1.0, -- Skalierung (Größe des Markers)
                255, 0, 0, 150, -- Farbe (Rot, Grün, Blau, Alpha/Transparenz)
                false, -- Bobbing-Effekt (auf und ab schweben)
                true, -- Face Camera
                2, -- P19 (meist 2 für Standardverhalten)
                true, -- Rotate
                nil, -- Texture Dict (nicht benötigt)
                nil, -- Texture Name (nicht benötigt)
                false -- Draw on ents (nicht benötigt)
            )
        end
    end
end)