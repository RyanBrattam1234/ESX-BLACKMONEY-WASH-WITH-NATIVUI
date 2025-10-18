local ESX = exports["es_extended"]:getSharedObject()
local MenuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu(nil, "~b~Geldwäsche Menü")
MenuPool:Add(mainMenu)

local background = Sprite.New("newbanner", "moneywashbanner1", 0, 0, 512, 128)
mainMenu:SetBannerSprite(background)

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

    
    local nearPoint = false
    for _, point in ipairs(Config.LaunderPoints or {}) do
        if #(coords - point) <= (Config.MaxDistance or 1.5) then
            nearPoint = true
            break
        end
    end

    if not nearPoint then
        ESX.ShowNotification("~r~Du bist nicht am Geldwäschepunkt.")
        return
    end

   
    if (GetGameTimer() - lastWash) < (Config.Cooldown or 60) * 1000 then
        ESX.ShowNotification("~y~Bitte warte bevor du erneut wäschst.")
        return
    end

    
    local playerData = ESX.GetPlayerData()
    local accounts = playerData and playerData.accounts or {}
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

    
    if Config.AnimationDict then
        RequestAnimDict(Config.AnimationDict)
        local tries = 0
        while not HasAnimDictLoaded(Config.AnimationDict) and tries < 50 do
            Citizen.Wait(50)
            tries = tries + 1
        end
        if HasAnimDictLoaded(Config.AnimationDict) then
            TaskPlayAnim(playerPed, Config.AnimationDict, Config.AnimationName or "base", 8.0, -8.0, -1, 49, 0, false, false, false)
        end
    end

   
    local success = true
    if lib and lib.progressBar then
        success = lib.progressBar({
            duration = (Config.WashTime or 30) * 1000,
            label = Config.ProgressLabel or "Geld wird gewaschen...",
            useWhileDead = false,
            canCancel = true,
            disable = {move = true, car = true, combat = true},
            anim = (Config.AnimationDict and {dict = Config.AnimationDict, clip = Config.AnimationName, flag = 49}) or nil,
        })
    else
      
        local waitTime = (Config.WashTime or 30) * 1000
        local start = GetGameTimer()
        while (GetGameTimer() - start) < waitTime do
            Citizen.Wait(500)
        end
    end

    ClearPedTasks(playerPed)

    if success then
        --te
        local rate = GetRate(amount) or 0.5
        local received = math.floor(amount * rate)

       
        TriggerServerEvent("money_launder:process", amount, received)

        ESX.ShowNotification(("~g~Geldwäsche abgeschlossen! Erhalten: $%d"):format(received))
    else
        ESX.ShowNotification("~r~Geldwäsche abgebrochen.")
    end
end


local washItem = NativeUI.CreateItem("💸 Geld waschen", "Gib den Betrag ein")
mainMenu:AddItem(washItem)

washItem.Activated = function(sender, item)
    AddTextEntry("FMMC_KEY_TIP1", "Betrag eingeben:")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 10)

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    local result = GetOnscreenKeyboardResult()
    if result and tonumber(result) then
        local amount = tonumber(result)
        if amount >= (Config.MinAmount or 50) then
            StartWashing(amount)
        else
            ESX.ShowNotification(("~r~Mindestbetrag: %d$"):format(Config.MinAmount or 50))
        end
    else
        ESX.ShowNotification("~r~Ungültiger Betrag.")
    end
end


Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local nearPoint = false

        if Config.LaunderPoints and #Config.LaunderPoints > 0 then
            for _, point in ipairs(Config.LaunderPoints) do
                if #(coords - point) <= (Config.MaxDistance or 1.5) then
                    nearPoint = true
                    sleep = 0
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um das Geldwäsche-Menü zu öffnen")

                    if IsControlJustReleased(0, 38) then
                        mainMenu:Visible(not mainMenu:Visible())
                        MenuPool:MouseControlsEnabled(false)
                        MenuPool:MouseEdgeEnabled(false)
                        MenuPool:ControlDisablingEnabled(false)
                    end
                    break
                end
            end
        end

        if not nearPoint and mainMenu:Visible() then
            mainMenu:Visible(false)
        end

        MenuPool:ProcessMenus()
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        if Config.LaunderPoints and #Config.LaunderPoints > 0 then
            for _, markerCoords in ipairs(Config.LaunderPoints) do
                local distance = #(playerCoords - markerCoords)
                if distance < 50.0 then
                    DrawMarker(
                        22,
                        markerCoords.x, markerCoords.y, markerCoords.z - 0.5,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        1.0, 1.0, 1.0,
                        255, 0, 0, 150,
                        false, true, 2, true, nil, nil, false
                    )
                end
            end
        end
    end
end)
