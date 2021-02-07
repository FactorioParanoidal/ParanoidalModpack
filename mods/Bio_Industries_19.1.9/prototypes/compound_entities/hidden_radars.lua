-- Add functions that are also used in other files (debugging output etc.)
local BioInd = require('common')('Bio_Industries')
BioInd.writeDebug("Entered prototypes.hidden_radars.lua of \"%s\".", {BioInd.modName})

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

require ("util")


------------------------------------------------------------------------------------
--  Create the main prototype for hidden radars. All others will be based on this! --
------------------------------------------------------------------------------------
--~ local h_type = "radar"
--~ local h_entity = table.deepcopy(data.raw[h_type]["radar"])
-- The short name of the hidden entity (e.g. "lamp" or "pole")
local h_key = "radar"
-- The actual prototype type, identified by h_key
local h_type = BioInd.HE_map[h_key]
local h_entity = table.deepcopy(data.raw[h_type]["radar"])

BI.set_common_properties(h_entity)

------------------------------------------------------------------------------------
-- Lamp specific attributes!
h_entity.energy_source.type = "electric"
h_entity.energy_source.usage_priority = "secondary-input"


------------------------------------------------------------------------------------
--      Make a copy of the hidden-entity prototype for each compound entity!      --
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- Compile a list of the hidden entities we'll need
BI.make_hidden_entity_list(h_key)


------------------------------------------------------------------------------------
-- Make the copies!
local radar
local c_entities = BioInd.compound_entities

for radar_name, locale_name in pairs(BI.hidden_entities.types[h_key]) do
  radar = table.deepcopy(h_entity)

BioInd.show("radar_name", radar_name)
BioInd.show("locale_name", locale_name)
  radar.name = radar_name
  radar.localised_name = {"entity-name." .. locale_name}
  radar.localised_description = {"entity-description." .. locale_name}

BioInd.show("radar_name", radar_name)
BioInd.show("radar.name", c_entities["bi-arboretum"].hidden[h_key].name)
  -- Adjust properties for hidden radar of Bio cannon
  if c_entities["bi-bio-cannon"] and
      radar_name == c_entities["bi-bio-cannon"].hidden[h_key].name then
    radar.icon = ICONPATH .. "biocannon_icon.png"
    radar.icon_size = 64
    radar.BI_add_icon = true

    radar.energy_per_sector = "22MJ"
    radar.energy_per_nearby_scan = "400kW"
    radar.energy_usage = "6kW"
    radar.max_distance_of_nearby_sector_revealed = 5
    radar.max_distance_of_sector_revealed = 5
    BioInd.show("Adjusted properties of", radar_name)

  -- Adjust properties for hidden radar of Terraformer
  elseif c_entities["bi-arboretum"] and
            radar_name == c_entities["bi-arboretum"].hidden[h_key].name then

    radar.localised_name = {"entity-name." .. radar.name}

    radar.icon = ICONPATH .. "Arboretum_Icon.png"
    radar.icon_size = 64
    radar.BI_add_icon = true

    -- We want to be able to see the scanning progress of this radar!
    for f, flag in pairs(radar.flags) do
      if flag == "not-selectable-in-game" then
        radar.flags[f] = nil
      end
    end
    radar.selectable_in_game = true
    -- For some reason, the default collision_mask (unset properties will be
    -- set to the default value automatically at the end of the data stage)
    -- must be set to make the radar selectable!
    radar.collision_mask = nil
    radar.collision_box = {{-0.70, -0.70}, {0.70, 0.70}}
    radar.selection_box = {{-0.75, -0.75}, {0.75, 0.75}}

    radar.energy_per_sector = "2MJ"
    radar.energy_per_nearby_scan = "200kW"
    radar.energy_source.emissions_per_minute = 0
    radar.energy_usage = "150kW"
    radar.max_distance_of_nearby_sector_revealed = 2
    radar.max_distance_of_sector_revealed = 5

    radar.max_health = 250
    radar.pictures = {
      layers = {
        {
          filename = "__base__/graphics/entity/radar/radar.png",
          priority = "extra-high",
          width = 98,
          height = 128,
          apply_projection = false,
          direction_count = 64,
          line_length = 8,
          shift = util.by_pixel(1, -16),
          scale = 0.5,
          hr_version = {
            filename = "__base__/graphics/entity/radar/hr-radar.png",
            priority = "extra-high",
            width = 196,
            height = 254,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(1, -16),
            scale = 0.25
          }
        }
      }
    }
    BioInd.show("Adjusted properties of", radar_name)
  end

  data:extend({radar})

  BioInd.show("Created", radar_name)
end


------------------------------------------------------------------------------------
--~ -- Testing
--~ for k, v in pairs(data.raw[h_entity.type]) do
  --~ BioInd.writeDebug("%s: %s", {k, v})
--~ end
