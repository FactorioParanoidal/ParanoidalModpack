local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("scripts.auto-ghost-cursor"),
  require("scripts.migrations"),
  require("scripts.quick-craft"),
  require("scripts.recall-last-item"),
  require("scripts.scroll-subgroup"),
})
