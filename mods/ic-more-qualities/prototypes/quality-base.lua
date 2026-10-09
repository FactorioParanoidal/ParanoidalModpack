require("chance-increment")
require("utils")

-- nahradi puvodni kvality

ic.quality_normal = data.raw.quality["normal"]
ic.update_quality_name(ic.quality_normal, { "default-quality-name.normal" })

ic.quality_uncommon = data.raw.quality["uncommon"]
ic.quality_uncommon.level = math.floor(2 * ic.conf.level_multiplier)
ic.quality_uncommon.order = "q-aa"
ic.quality_uncommon.next_probability = ic.get_chance()
ic.quality_uncommon.beacon_power_usage_multiplier = 0.85
ic.quality_uncommon.mining_drill_resource_drain_multiplier = 0.85
ic.quality_uncommon.science_pack_drain_multiplier = 0.99

ic.quality_rare = data.raw.quality["rare"]
ic.quality_rare.level = math.floor(3 * ic.conf.level_multiplier)
ic.quality_rare.order = "q-ab"
ic.quality_rare.next_probability = ic.get_chance()
ic.quality_rare.beacon_power_usage_multiplier = 0.80
ic.quality_rare.mining_drill_resource_drain_multiplier = 0.80
ic.quality_rare.science_pack_drain_multiplier = 0.98

ic.quality_epic = data.raw.quality["epic"]
ic.quality_epic.level = math.floor(4 * ic.conf.level_multiplier)
ic.quality_epic.order = "q-ac"
ic.quality_epic.next_probability = ic.get_chance()
ic.quality_epic.beacon_power_usage_multiplier = 0.75
ic.quality_epic.mining_drill_resource_drain_multiplier = 0.75
ic.quality_epic.science_pack_drain_multiplier = 0.97

ic.quality_legendary = data.raw.quality["legendary"]
ic.quality_legendary.level = math.floor(6 * ic.conf.level_multiplier)
ic.quality_legendary.order = "q-ad"
ic.quality_legendary.next_probability = ic.get_chance()
ic.quality_legendary.beacon_power_usage_multiplier = 0.70
ic.quality_legendary.mining_drill_resource_drain_multiplier = 0.70
ic.quality_legendary.science_pack_drain_multiplier = 0.96

-- moduly kvality

ic.quality_module_1 = data.raw.technology["quality-module"].effects
ic.quality_module_2 = data.raw.technology["quality-module-2"].effects
ic.quality_module_3 = data.raw.technology["quality-module-3"].effects
