

ESX = nil
local isFishing = false
local fishSpot = nil
local fishingRod = nil
local fishLocations = {
    vector3(-1590.0, 5200.0, 4.0), -- Point 1
    vector3(1300.0, 4220.0, 33.9), -- Point 2
    vector3(-1800.0, 4000.0, 1.0)  -- Point 3
}
local sellLocation = vector3(-1037.0, -1396.0, 5.5) -- Marchand de poissons

-- Initialisation ESX
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(500)
    end
end)

-- Commande pour commencer la pêche
RegisterCommand("peche", function()
    if isFishing then
        StopFishing()
    else
        StartFishing()
    end
end, false)

-- Démarrer la pêche
function StartFishing()
    ESX.ShowNotification("Dirigez-vous vers un point de pêche indiqué sur votre GPS.")
    fishSpot = fishLocations[math.random(1, #fishLocations)]
    SetNewWaypoint(fishSpot.x, fishSpot.y)
    ESX.ShowNotification("Allez au point de pêche et utilisez votre canne à pêche.")
end

-- Arrêter la pêche
function StopFishing()
    isFishing = false
    ESX.ShowNotification("Vous avez arrêté de pêcher.")
    if DoesEntityExist(fishingRod) then
        DeleteObject(fishingRod)
    end
end

-- Points de pêche et interaction
CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)

        if fishSpot and not isFishing then
            local distance = #(playerCoords - fishSpot)
            if distance < 20.0 then
                DrawMarker(1, fishSpot.x, fishSpot.y, fishSpot.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, nil, nil, false)
                if distance < 2.0 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour commencer à pêcher.")
                    if IsControlJustReleased(0, 38) then -- Touche "E"
                        BeginFishing()
                    end
                end
            end
        end

        Wait(0)
    end
end)

-- Commencer l'animation de pêche
function BeginFishing()
    isFishing = true
    ESX.ShowNotification("Vous commencez à pêcher...")
    RequestAnimDict("amb@world_human_stand_fishing@idle_a")
    while not HasAnimDictLoaded("amb@world_human_stand_fishing@idle_a") do
        Wait(10)
    end

    fishingRod = CreateObject(GetHashKey("prop_fishing_rod_01"), playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
    AttachEntityToEntity(fishingRod, playerPed, GetPedBoneIndex(playerPed, 60309), 0.1, 0.0, 0.0, 0.0, 270.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(playerPed, "amb@world_human_stand_fishing@idle_a", "idle_c", 8.0, 8.0, -1, 1, 0, false, false, false)

    Wait(10000) -- Temps pour attraper un poisson
    CatchFish()
end

-- Attraper un poisson
function CatchFish()
    if math.random(1, 100) <= 75 then -- 75% de chances de succès
        ESX.ShowNotification("Vous avez attrapé un poisson !")
        TriggerServerEvent('esx_fishing:addFish') -- Ajout de poisson à l'inventaire
    else
        ESX.ShowNotification("Le poisson s'est échappé.")
    end

    StopFishing()
end

-- Vente de poissons au marchand
CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - sellLocation)

        if distance < 20.0 then
            DrawMarker(1, sellLocation.x, sellLocation.y, sellLocation.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
            if distance < 2.0 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour vendre vos poissons.")
                if IsControlJustReleased(0, 38) then -- Touche "E"
                    TriggerServerEvent('esx_fishing:sellFish') -- Vente de poissons
                end
            end
        end

        Wait(0)
    end
end)
