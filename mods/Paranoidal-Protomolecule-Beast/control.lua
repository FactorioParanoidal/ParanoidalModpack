local handler = require("__core__.lualib.event_handler")

handler.add_libraries
{
  require("script.config"),
  require("script.the_beast"),
  require("script.infection"),
  require("script.outbreak"),
  require("script.seed"),
  require("script.lair_rails"),
  require("script.lair_arms"),
  require("script.arrival"),
  require("script.train"),
  require("script.units")
}
