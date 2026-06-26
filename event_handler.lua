--- MagnusDCSCustomEventHandler is a global event handler class that listens for DCS World events and processes them according to the defined logic. It includes methods for handling damage events, calculating final mission scores based on user flags, and managing configuration settings for missions. The class is designed to be flexible and extensible, allowing for the addition of new event types and processing logic as needed. It relies on a global configuration object to determine how to evaluate mission success and partial success based on user-defined flags.
--- @class MagnusDCSCustomEventHandler
MagnusDCSCustomEventHandler = {}

function MagnusDCSCustomEventHandler:onEvent(event)
    -- Fail silently for unhandled frames to protect CPU performance
    if not event or not event.id then
        return
    end

    MagnusDCSScripting.damageHandler:onEvent(event)
end

world.addEventHandler(MagnusDCSCustomEventHandler)
