if MagnusDCSScripting.eventHandler then
    world.removeEventHandler(MagnusDCSScripting.eventHandler)
end

MagnusDCSScripting.eventHandler = {}

function MagnusDCSScripting.eventHandler:onEvent(event)
    -- Fail silently for unhandled frames to protect CPU performance
    if not event or not event.id then
        return
    end

    if not MagnusDCSScripting.damageHandler or not MagnusDCSScripting.damageHandler.onEvent then
        env.info("[MagnusDCSScripting Damage Tracker Handler]: ERROR - Damage handler not loaded.")
        return
    end
    MagnusDCSScripting.damageHandler:onEvent(event)
end

world.addEventHandler(MagnusDCSScripting.eventHandler)
