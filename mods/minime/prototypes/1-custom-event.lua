minime.entered_file()

if not minime.character_selector then
  minime.entered_file("leave", "character selector is not active")
  return
end


--~ ------------------------------------------------------------------------------------
--~ -- Custom event that is raised when we have exchanged a character. The player may or
--~ -- may not have a new character (e.g. when switching to god/editor mode). If we must
--~ -- destroy the old character, we will do this only after raising the event.
--~ local exchanged_char = {
  --~ type = "custom-event",
  --~ name = "minime_exchanged_characters",
--~ }
--~ data:extend({exchanged_char})
--~ minime.created_msg(exchanged_char)
------------------------------------------------------------------------------------
-- Create custom events
local event
for e, e_name in pairs(minime.custom_events) do
  event = {
    type = "custom-event",
    name = e_name,
  }
  data:extend({event})
  minime.created_msg(event)
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
