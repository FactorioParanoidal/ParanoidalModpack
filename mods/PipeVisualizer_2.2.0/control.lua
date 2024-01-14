local handler = require("__core__/lualib/event_handler")

handler.add_libraries({
  require("__PipeVisualizer__/scripts/migrations"),

  require("__PipeVisualizer__/scripts/colors"),
  require("__PipeVisualizer__/scripts/iterator"),
  require("__PipeVisualizer__/scripts/mouseover"),
  require("__PipeVisualizer__/scripts/order"),
  require("__PipeVisualizer__/scripts/overlay"),
  require("__PipeVisualizer__/scripts/renderer"),
})
