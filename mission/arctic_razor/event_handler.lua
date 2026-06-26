if MagnusDCSScripting.eventHandler then
    world.removeEventHandler(MagnusDCSScripting.eventHandler)
end

MagnusDCSScripting.eventHandler = {}

function MagnusDCSScripting.eventHandler:onEvent(event)
    -- Fail silently for unhandled frames to protect CPU performance
    if not event or not event.id then
        return
    end
end

world.addEventHandler(MagnusDCSScripting.eventHandler)
