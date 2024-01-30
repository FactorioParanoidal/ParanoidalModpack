-- create remote interface for the translation module
local retranslate_all_event = script.generate_event_name()
remote.add_interface("railualib_translation", {
  retranslate_all_event = function() return retranslate_all_event end,
})
commands.add_command(
  "retranslate-all-dictionaries",
  "- retranslates all of your personal dictionaries",
  function(e)
    script.raise_event(retranslate_all_event, {player_index=e.player_index})
  end
)

-- load tests
local tests = require("tests.tests")
for _,test in pairs(tests) do
  require("tests."..test..".control")
end
