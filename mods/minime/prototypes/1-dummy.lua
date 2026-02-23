minime.entered_file()
------------------------------------------------------------------------------------
-- Define dummy character
-- The character needs an insane inventory size so we can store inventories even of
-- characters with a huge inventory created by other mods.

local dummy = table.deepcopy(data.raw.character["character"])
dummy.name = minime.dummy_character_name
--~ dummy.inventory_size = 1000
dummy.inventory_size = 500

dummy.hidden = true
dummy.hidden_in_factoriopedia = true

-- We don't need a jetpack version of the dummy!
dummy.prevent_jetpack = true

-- Don't scale character, and don't make variations of it (e.g. for Bob's classes)!
dummy.minime_ignore_me = true

data:extend({dummy})
minime.created_msg(dummy)

------------------------------------------------------------------------------------
minime.entered_file("leave")
