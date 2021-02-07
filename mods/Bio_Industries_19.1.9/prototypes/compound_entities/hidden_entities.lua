-- Add functions that are also used in other files (debugging output etc.)
local BioInd = require('common')('Bio_Industries')
--~ local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH = "__core__/graphics/"

local HIDDENPATH = BioInd.modRoot .. "/prototypes/compound_entities/"
BioInd.writeDebug("Entered prototypes.hidden_entities.lua of \"%s\".", {BioInd.modName})

------------------------------------------------------------------------------------
-- Keep a list of all hidden entities we create, so we can modify them easily in  --
-- data-updates.lua or data-final-fixes.lua.                                      --
------------------------------------------------------------------------------------
BI.hidden_entities = {}
BI.hidden_entities.types = {}

local no_sound = {
  filename = "__base__/sound/silence-1sec.ogg",

}
------------------------------------------------------------------------------------
-- Some common properties that should be used by all hidden entity types          --
------------------------------------------------------------------------------------
BI.hidden_entities.flags = {
  "hidden",
  "hide-alt-info",
  "no-copy-paste",
  "not-blueprintable",
  "not-deconstructable",
  "not-flammable",
  "not-in-kill-statistics",
  "not-on-map",
  "not-repairable",
  --~ "not-selectable-in-game",
  "not-upgradable",
  "placeable-off-grid",
}
if not BioInd.is_debug then
  table.insert(BI.hidden_entities.flags, "not-selectable-in-game")
end

BI.hidden_entities.collision_mask = BioInd.is_debug and {"ground-tile"} or {}
BI.hidden_entities.collision_box = {{0, 0}, {0, 0}}
BI.hidden_entities.selection_box = BioInd.is_debug and
                                    {{-0.5, -0.5}, {0.5, 0.5}} or
                                    {{0, 0}, {0, 0}}
BI.hidden_entities.selectable_in_game = BioInd.is_debug
BI.hidden_entities.max_health = 1

--~ BI.hidden_entities.icon = ICONPATH .. "blank.png"
BI.hidden_entities.icon = ICONPATH .. "empty.png"
--~ BI.hidden_entities.icon_size = 32
BI.hidden_entities.icon_size = 1
BI.hidden_entities.icon_mipmaps = 0

BI.hidden_entities.icons = {
  {
    icon = BI.hidden_entities.icon,
    icon_size = BI.hidden_entities.icon_size,
    icon_mipmaps = BI.hidden_entities.icon_mipmaps
  }
}
BI.hidden_entities.picture = {
  --~ filename = ICONPATH .. "blank.png",
  filename = ICONPATH .. "empty.png",
  priority = "low",
  size = 1,
  frame_count = 1,
  axially_symmetrical = false,
  direction_count = 1,
}
BI.hidden_entities.overlay = BI.hidden_entities.picture

-- The resistances will be set in data-updates.lua, when all mods have had
-- a chance to create their damage types!
BI.hidden_entities.hide_resistances = true

BI.hidden_entities.sounds = {
  build_sound = no_sound,
  close_sound = no_sound,
  mined_sound = no_sound,
  open_sound = no_sound,
  repair_sound = no_sound,
  rotated_sound = no_sound,
  vehicle_impact_sound = no_sound,
  working_sound = no_sound,
}

BI.hidden_entities.misc = {
  active_picture = BI.hidden_entities.picture,
  circuit_wire_max_distance = 0,
  corpse = "",
  created_effect = nil,
  created_smoke = nil,
  --~ damaged_trigger_effect = {
    --~ {
      --~ type = "damage",
      --~ damage = {
        --~ type = "fire",
        --~ amount = 0
      --~ }
    --~ }
  --~ },
  damaged_trigger_effect = nil,
  --~ dying_explosion = nil,
  energy_source = {
    render_no_network_icon = false,
    render_no_power_icon = false,
  },
  fast_replaceable_group = "",
  light = nil,
  --~ minable = nil,
  next_upgrade = "",
  remove_decoratives = "false",
  water_reflection = {pictures = BI.hidden_entities.picture},
}


------------------------------------------------------------------------------------
--          Apply the common properties to this hidden-entity prototype!          --
------------------------------------------------------------------------------------
BI.set_common_properties = function(h_entity)
  for s, sound in pairs(BI.hidden_entities.sounds) do
    h_entity[s] = sound
  end

  for s, setting in pairs(BI.hidden_entities.misc) do
    h_entity[s] = setting
  end

  h_entity.icon = BI.hidden_entities.icon
  h_entity.icon_size = BI.hidden_entities.icon_size
  h_entity.icon_mipmaps = BI.hidden_entities.icon_mipmaps

  if BioInd.is_debug then
    h_entity.icons = h_entity.icons or {
      {
        icon = h_entity.icon,
        icon_size = h_entity.icon_size or 1,
        --~ icon_mipmaps = h_entity.icon_mipmaps or 1
        icon_mipmaps = h_entity.icon_mipmaps
      }
    }
  else
    h_entity.icons = BI.hidden_entities.icons
  end

  h_entity.picture = BioInd.is_debug and h_entity.picture or BI.hidden_entities.picture
  h_entity.pictures = BioInd.is_debug and h_entity.pictures or BI.hidden_entities.picture
  --~ h_entity.pictures = BI.hidden_entities.picture
  h_entity.overlay = BioInd.is_debug and h_entity.overlay or BI.hidden_entities.overlay
  h_entity.flags = BI.hidden_entities.flags
  h_entity.selectable_in_game = BI.hidden_entities.selectable_in_game
  h_entity.max_health = BI.hidden_entities.max_health

  --~ h_entity.resistances = {{type = "fire", percent = 100}}
  h_entity.collision_mask = BI.hidden_entities.collision_mask
  h_entity.collision_box = BI.hidden_entities.collision_box
  h_entity.selection_box = BI.hidden_entities.selection_box
end


------------------------------------------------------------------------------------
--     Compile a list of the hidden-entity prototype of this compound entity!     --
------------------------------------------------------------------------------------
-- The list of compound entities contains duplicate data for related entities (e.g.
-- curved and straight rails, or entities where an overlay is placed first). So, we
-- should look for the tables instead: They are guaranteed to be unique!
BI.make_hidden_entity_list = function(hidden_type)
  BioInd.check_args(hidden_type, "string", "valid handle for hidden entities")

  local name, entity_locale
  for c_name, c_data in pairs(BioInd.compound_entities) do
    BioInd.writeDebug("Checking %s for hidden %ss", {c_name, hidden_type})
--~ BioInd.show("c_name", c_name)
--~ BioInd.show("c_data", c_data)
    local h_type = c_data.hidden[hidden_type]
    if h_type then
      --~ name = c_data.tab:gsub("_table$", ""):gsub("_", "-") .. "-hidden-" .. hidden_type
      name = h_type and h_type.name or c_data.base and c_data.base.name .. "-hidden-" .. hidden_type
      -- Store the name of the compound entity -- we'll need it for the localization!
      BI.hidden_entities.types[hidden_type] = BI.hidden_entities.types[hidden_type] or {}
      -- If the base entity is just an overlay, it won't have its own localization key
      -- but use the same localizations as the final entity. So, we'll check for the
      -- "new_base_name" property first and use the base entity's name if it hasn't been
      -- set.
      BI.hidden_entities.types[hidden_type][name] = h_type.localize_entity or
                                                    c_data.new_base_name or
                                                    c_name
      BioInd.writeDebug("Must create %s!", {name})
    end
  end
end


------------------------------------------------------------------------------------
--                            Add a layer to a picture                            --
------------------------------------------------------------------------------------
-- The hidden entities DO need to have images, so that they can be identified in the
-- production tab!
BI.add_layer = function(layers, data)
  --~ BioInd.check_args(layers, "table", "layer")
  BioInd.check_args(data, "table", "layer data")
  layers = layers or {}

  local name = data.name
  local hr_name = data.hr_name
  local priority = data.priority
  local height = data.height
  local width = data.width
  local size = data.size
  local shadow = data.shadow

  --~ size = size or
          --~ (height and width and height == width) and height
  layers[#layers + 1] = {
    filename = name,
    priority = priority or "low",
    width = width,
    height = height,
    size = size,
    draw_as_shadow = shadow,
    hr_version = hr_name and {
      filename = hr_name,
      priority = priority or "low",
      width = width and width * 2,
      height = height and height * 2,
      size = size and size * 2,
      draw_as_shadow = shadow,
      scale = 0.5,
    }
  }
  return layers
end

require(HIDDENPATH .. "hidden_lamps")
require(HIDDENPATH .. "hidden_panels")
require(HIDDENPATH .. "hidden_poles")
require(HIDDENPATH .. "hidden_radars")

--~ BioInd.show("BI.hidden_entities.types", BI.hidden_entities.types)
--~ error("Break!")
