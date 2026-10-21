local handler = require("__core__.lualib.event_handler")
compatibility = {}

handler.add_libraries({
  require("scripts.migrations"),

  require("scripts.restrictions"),
  require("scripts.colors"),
  require("scripts.iterator"),
  require("scripts.mouseover"),
  require("scripts.order"),
  require("scripts.overlay"),
  require("scripts.renderer"),
  require("compatibility.fmf_ducts"),
})
