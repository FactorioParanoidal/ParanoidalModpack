local library = require("__PlanetsLib__.lib.lib")

return {
    {
        name = "on_built",
        events = library.build_events,
        handlers = {}
    },
    {
        name = "on_removed",
        events = library.destroy_events,
        handlers = {}
    }
}
