local handler = require("scripts/handler")

script.on_load(handler.register_callbacks)
script.on_init(handler.register_callbacks_init)
