-- replaces artillery shooting and explosion sounds by awesome TA ARM Big Bertha ones
--
data.raw.item["artillery-turret"].sound =
{
	filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
	volume = 1
}

data.raw.gun["artillery-wagon-cannon"].attack_parameters.sound =
{
	filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
	volume = 1
}

data.raw.explosion["big-artillery-explosion"].sound.variations = 
{
  {
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK1.ogg",
    volume = 1.5
  }
}

-- insert sound triggers in artillery-projectile explosion creation and artillery ammo shooting muzzle creation
-- 
function ensure_table_is_list(tab)
    local k
    k,_ = next(tab)
    if k ~= 1 then
      local t = {}
      for k,v in pairs(tab) do
        t[k] = v
        tab[k] = nil
      end
      table.insert(tab, t)
    end
end

local effect_trigger_explosion = {
type = "create-entity",
entity_name = "vtk-artillery-at-distance-sound-trigger-explosion",
trigger_created_entity = "true"
}

local effect_trigger_shooting = {
type = "create-entity",
entity_name = "vtk-artillery-at-distance-sound-trigger-shooting",
trigger_created_entity = "true"
}

local target_effects = data.raw["artillery-projectile"]["artillery-projectile"].action.action_delivery.target_effects
ensure_table_is_list(target_effects)
table.insert(target_effects, effect_trigger_explosion)

local source_effects = data.raw["ammo"]["artillery-shell"]["ammo_type"].action.action_delivery.source_effects
ensure_table_is_list(source_effects)
table.insert(source_effects, effect_trigger_shooting)
