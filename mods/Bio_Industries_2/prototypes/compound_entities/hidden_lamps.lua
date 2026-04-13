-- Add functions that are also used in other files (debugging output etc.)
local BioInd = require('common')('Bio_Industries_2')
BioInd.writeDebug("Entered prototypes.hidden_lamps.lua of \"%s\".", {BioInd.modName})

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

------------------------------------------------------------------------------------
--  Create the main prototype for hidden lamps. All others will be based on this! --
------------------------------------------------------------------------------------
-- The short name of the hidden entity (e.g. "lamp" or "pole")
local h_key = "lamp"
-- The actual prototype type, identified by h_key
local h_type = BioInd.HE_map[h_key]
local h_entity = table.deepcopy(data.raw[h_type]["small-lamp"])

BI.set_common_properties(h_entity)

------------------------------------------------------------------------------------
-- Lamp specific attributes!
h_entity.energy_source.type = "void"
h_entity.energy_source.usage_priority = "lamp"

h_entity.energy_usage_per_tick = "100kW"
h_entity.light = {intensity = 1, size = 45}
h_entity.light_when_colored= {intensity = 0, size = 0}
h_entity.signal_to_color_mapping = {}

h_entity.circuit_connector_sprites = {}
for l, led in ipairs({"red", "green", "blue", "light"}) do
  h_entity.circuit_connector_sprites["led_" .. led] = BI.hidden_entities.picture
  h_entity.circuit_connector_sprites["led_" .. led].intensity = 0
end

h_entity.picture_off = BI.hidden_entities.picture

h_entity.picture_on = BI.hidden_entities.picture


------------------------------------------------------------------------------------
--      Make a copy of the hidden-entity prototype for each compound entity!      --
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- Compile a list of the hidden entities we'll need
BI.make_hidden_entity_list(h_key)

------------------------------------------------------------------------------------
-- Make the copies!
local lamp
local c_entities = BioInd.compound_entities

for lamp_name, locale_name in pairs(BI.hidden_entities.types[h_key]) do
  lamp = table.deepcopy(h_entity)
  lamp.name = lamp_name
  lamp.localised_name = {"entity-name." .. locale_name}
  lamp.localised_description = {"entity-description." .. locale_name}
  lamp.collision_mask = { layers = {} }
  lamp.collision_box = {{0,0},{0,0}}

  -- Adjust properties for hidden lamp of Bio farm
  if c_entities["bi-bio-farm"] and
      lamp_name == c_entities["bi-bio-farm"].hidden[h_type].name then

    lamp.icon = ICONPATH_E .. "bio_Farm_Lamp.png"
    lamp.icon_size = 64
    lamp.BI_add_icon = true
    BioInd.show("Adjusted properties of", lamp_name)
  end
  data:extend({lamp})

  BioInd.show("Created", lamp_name)
end


------------------------------------------------------------------------------------
-- Testing
