local showing = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyPed = PlayerPedId()
        if IsPedInAnyHeli(plyPed) and not showing then
            if GetIsVehicleEngineRunning(GetVehiclePedIsIn(plyPed)) then
                SetVehicleEngineOn(GetVehiclePedIsIn(plyPed), false, true, false)
                SetHeliBladesSpeed(GetVehiclePedIsIn(plyPed), 0)
                Wait(10)
            end
            showing = true
            SendNUIMessage({
                type = 'show'
            })
            heliTick()
        elseif not IsPedInAnyHeli(plyPed) and showing then
            showing = false
            SendNUIMessage({
                type = 'hide'
            })
            SendNUIMessage({
                type = 'resetState'
            })
        end
    end
end)

local engineon, cautionon = false, false
function heliTick()
    Citizen.CreateThread(function()
        while showing do
            Citizen.Wait(0)
            local plyPed = PlayerPedId()
            local heli = GetVehiclePedIsIn(plyPed)
            if heli == 0 then return; end
            if IsVehicleEngineStarting(heli) and not engineon then
                SendNUIMessage({
                    type = 'updateState',
                    update = {
                        control = 'start',
                        state = 'ready'
                    }
                })
                rotorTick(heli)
                Wait(3000)
                manageButtons()
                SendNUIMessage({
                    type = 'updateState',
                    update = {
                        control = 'start',
                        state = "",
                    }
                })
                while not GetIsVehicleEngineRunning(heli) do Citizen.Wait(0); end
                engineon = true
            end
            if engineon then
                if not GetIsVehicleEngineRunning(heli) then
                    SendNUIMessage({
                        type = 'updateState',
                        update = {
                            control = 'stop',
                            state = 'ready'
                        }
                    })
                    Wait(3000)
                    SendNUIMessage({
                        type = 'updateState',
                        update = {
                            control = 'stop',
                            state = "",
                        }
                    })
                    SendNUIMessage({
                        type = 'resetState'
                    })
                    engineon = false
                end
            end
            if engineon then
                if not healthCheck(heli) then
                    if not cautionon then
                        cautionon = true
                        SendNUIMessage({
                            type = 'updateState',
                            update = {
                                control = 'master',
                                state = 'off'
                            }
                        })
                    end
                elseif healthCheck(heli) and cautionon then
                    cautionon = false
                    SendNUIMessage({
                        type = 'updateState',
                        update = {
                            control = 'master',
                            state = ''
                        }
                    })
                end
            end
        end
    end)
end

local rotorSpeed = 0
function rotorTick(heli)
    SendNUIMessage({
        type = 'updateState',
        update = {
            control = 'rpm',
            state = 'off'
        }
    })
    Citizen.CreateThread(function()
        SendNUIMessage({
            type = 'updateState',
            update = {
                control = 'rpm',
                state = 'warning'
            }
        })
        for i = 1, 100, 1 do
            SetHeliBladesSpeed(heli, i/100)
            rotorSpeed = i
            Wait(250)
        end
        SendNUIMessage({
            type = 'updateState',
            update = {
                control = 'rpm',
                state = 'ready'
            }
        })
    end)
end

function healthCheck(heli)
    local ret = true
    if GetHeliMainRotorHealth(heli) < 500 then
        ret = false
    elseif GetHeliTailBoomHealth(heli) < 500 then
        ret = false
    elseif GetHeliTailRotorHealth(heli) < 500 then
        ret = false
    elseif GetVehicleEngineHealth(heli) < 500 then
        ret = false
    elseif GetVehicleBodyHealth(heli) < 500 then
        ret = false
    end
    return ret
end

function manageButtons()
    Citizen.CreateThread(function()
        SendNUIMessage({
            type = 'updateState',
            update = {
                control = 'bat',
                state = 'on'
            }
        })
        Wait(800)
        SendNUIMessage({
            type = 'updateState',
            update = {
                control = 'hyd',
                state = 'on'
            }
        })
        Wait(800)
        SendNUIMessage({
            type = 'updateState',
            update = {
                control = 'fuel',
                state = 'on'
            }
        })
        Wait(800)
        SendNUIMessage({
            type = 'updateState',
            update = {
                {
                    control = 'bat',
                    state = 'ready'
                },
                {
                    control = 'hyd',
                    state = 'ready'
                },
                {
                    control = 'fuel',
                    state = 'ready'
                },
                {
                    control = 'lt',
                    state = 'ready'
                },
            }
        })
    end)
end