ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local PlayerData = {}
local PlayerLoaded = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
    local farDistance = 10
    while true do
        local wait, show = 500, true
        if PlayerLoaded and PlayerData.job ~= nil then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for k, v in pairs(Jobs) do
                for i=1, #v.location do
                    if v.jobRequired then 
                        if PlayerData.job.name ~= v.jobName then
                            show = false
                            wait = 500
                        end
                    end                    
                    if show then
                        local distance = #(coords - v.location[i]["coords"])
                        if v.location[i].marker["enable"] then
                            farDistance = 50
                        end
                        if distance <= farDistance then  
                            wait = 5
                            DrawMarker(v.location[i].marker["type"], v.location[i]["coords"], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.location[i].marker["size"].x, v.location[i].marker["size"].y, v.location[i].marker["size"].z, v.location[i].marker["color"].r, v.location[i].marker["color"].g, v.location[i].marker["color"].b, 100, false, true, 2, false, nil, nil, false)                          
                            if distance <= 5 then
                                if v.location[i].draw3dtext["enable"] then
                                    DrawText3D(v.location[i]["coords"], v.location[i].draw3dtext["text"])
                                end
                                if IsControlJustPressed(0, 38) and distance <= 1.5 then
                                    ESX.TriggerServerCallback('cylex_jobs:checkCount', function(count)
                                        if v.location[i].item["process"] == "pickup" or count > v.location[i].item["removeCount"]-1 then
                                            if v.location[i].animation["enable"] then
                                                v.location[i].animation["animationFunction"](ped)
                                            end
                                            if v.location[i].progressbar["enable"] then
                                                TriggerEvent("mythic_progbar:client:progress", {
                                                    name = k.."-"..v.location[i].item["process"],
                                                    duration = v.location[i].progressbar["duration"],
                                                    label = v.location[i].progressbar["progText"],
                                                    useWhileDead = false,
                                                    canCancel = true,
                                                    controlDisables = {
                                                        disableMovement = true,
                                                        disableCarMovement = false,
                                                        disableMouse = false,
                                                        disableCombat = true,
                                                    },
                                                    }, function(status)
                                                    if not status then
                                                        TriggerServerEvent("cylex_jobs:server:process", v.location[i].item)
                                                    else
                                                        exports["mythic_notify"]:SendAlert("error", "Cancelled.")
                                                    end
                                                    ClearPedTasksImmediately(ped)
                                                end)
                                            else
                                                Citizen.CreateThread(function()
                                                    Citizen.Wait(v.location[i].progressbar["duration"])
                                                    TriggerServerEvent("cylex_jobs:server:process", v.location[i].item)
                                                end)
                                            end
                                        else
                                            exports["mythic_notify"]:SendAlert("error", "You don't have enough item!")
                                        end
                                    end, v.location[i].item["requiredItem"])
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function DrawText3D(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z+0.5)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
    local blips = {}
    for k, v in pairs(Jobs) do
        for i = 1, #v.location do
            if v.location[i].blip["showBlip"] then
                JobBlip = AddBlipForCoord(v.location[i]["coords"])
                SetBlipSprite(JobBlip, v.location[i].blip["sprite"])
                SetBlipColour(JobBlip, v.location[i].blip["color"])
                SetBlipScale(JobBlip, v.location[i].blip["scale"])
                SetBlipAsShortRange(JobBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.location[i].blip["blipName"])
                EndTextCommandSetBlipName(JobBlip)
                table.insert(blips, JobBlip)
            end
        end
    end
end)
