ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("money_launder:process")
AddEventHandler("money_launder:process", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount("black_money").money

    if blackMoney >= amount then
        local rate = 0.50
        for _, data in ipairs(Config.Rates) do
            if amount >= data.min and amount <= data.max then
                rate = data.rate
                break
            end
        end

        local cleanMoney = math.floor(amount * rate)

        xPlayer.removeAccountMoney("black_money", amount)
        xPlayer.addMoney(cleanMoney)

        if Config.Webhook ~= "" then
            PerformHttpRequest(Config.Webhook, function() end, "POST", json.encode({
                username = "Geldwäsche-Log",
                embeds = {{
                    title = "💸 Geld gewaschen",
                    description = "**Spieler:** " .. xPlayer.getName() ..
                                  "\n**Vorher:** " .. amount .. "$ Schwarzgeld" ..
                                  "\n**Nachher:** " .. cleanMoney .. "$ Sauberes Geld",
                    color = 3447003
                }}
            }), {["Content-Type"] = "application/json"})
        end

        TriggerClientEvent("esx:showNotification", source, ("~g~Geldwäsche erfolgreich! ~s~Du hast %d sauberes Geld erhalten."):format(cleanMoney))
    else
        TriggerClientEvent("esx:showNotification", source, "~r~Du hast nicht genug Schwarzgeld.")
    end
end)