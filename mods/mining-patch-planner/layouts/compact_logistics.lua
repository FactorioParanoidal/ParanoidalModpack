local super_compact = require("layouts.super_compact")
local logistics =require("layouts.logistics")

---@class CompactLogisticsLayout: SuperCompactLayout
local layout = table.deepcopy(super_compact)

layout.name = "compact_logistics"
layout.translation = {"", "[entity=passive-provider-chest] ", {"mpp.settings_layout_choice_compact_logistics"}}

layout.restrictions.lamp_available = false
layout.restrictions.belt_available = false
layout.restrictions.logistics_available = true
layout.restrictions.lane_filling_info_available = false
layout.restrictions.belt_merging_available = false
layout.restrictions.belt_planner_available = false

layout.do_power_pole_joiners = false

layout.prepare_belt_layout = logistics.prepare_belt_layout
layout.finish = logistics.finish

return layout
