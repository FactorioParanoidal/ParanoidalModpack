---@meta
---@diagnostic disable

---@class EventDataPlayerSelectedArea : EventData
---@field item string
---@field player_index uint
---@field entities LuaEntity[]
---@field tiles LuaTile[]
---@field surface LuaSurface

---@class EventDataPlayerCreated : EventData
---@field player_index uint

---@class EventDataGuiCheckedStateChanged : EventData
---@field player_index uint
---@field element LuaGuiElement

---@class EventDataGuiClick : EventData
---@field player_index uint
---@field element LuaGuiElement
---@field button defines.mouse_button_type
---@field alt boolean
---@field control boolean
---@field shift boolean

---@class EventDataGuiSelectionStateChanged : EventData
---@field player_index uint
---@field element LuaGuiElement

---@class PoleCharacteristics
---@field width number The entity width
---@field reach number Wire connection reach
---@field area number Supply area width

---@class Layout
---@field name string
---@field defaults LayoutDefaults
---@field restrictions Restrictions
---@field on_load fun(self, state: State)
---@field validate fun(self, state: State): boolean
---@field initialize fun(self, state: State)
---@field tick fun(self, state: State): TickResult
---@field belt_merging_strategies BeltMergingStrategies
---@field belts_and_power_inline boolean
---@field do_power_pole_joiners boolean

---@alias TickResult string | boolean | nil

---@class LayoutDefaults
---@field miner string
---@field belt string
---@field pole string
---@field logistics string
---@field pipe string

---@class Restrictions
---@field miner_available boolean
---@field miner_size number[] Supported size of a mining drill
---@field miner_radius number[] Supported radius of mining drill
---@field belt_available boolean
---@field belt_underground_length number
---@field uses_underground_belts boolean
---@field pole_available boolean
---@field pole_omittable boolean Allow a no electric pole option
---@field pole_zero_gap boolean Allow a zero gap pole option
---@field pole_width number[]
---@field pole_length number[]
---@field pole_supply_area number[]
---@field logistics_available boolean
---@field lamp_available boolean Enable lamp placement option
---@field coverage_tuning boolean
---@field landfill_omit_available boolean
---@field start_alignment_tuning boolean
---@field deconstruction_omit_available boolean
---@field module_available boolean
---@field pipe_available boolean
---@field placement_info_available boolean
---@field lane_filling_info_available boolean
---@field belt_merging_available boolean
---@field belt_planner_available boolean

---@class BeltMergingStrategies
---@field back_merging boolean
---@field side_merging_front boolean
---@field side_merging_back boolean

---@class DeconstructSpecification
---@field x number
---@field y number
---@field width number
---@field height number

---@alias BeltMergeStrategy
---| "target" Belt blocked from being merge target (already a target)
---| "target-back-merge"
---| "side-merge" Routes belt into side of another belt
---| "back-merge" Routes belt into back of another belt
---| "splitter-merge" Merges at the front using a splitter

---@class BaseBeltSpecification
---@field x1 number Output x of first mining drill in either lane
---@field x2 number Output y of last mining drill in either lane
---@field x_start number Start of belt bounds
---@field x_entry number Start of mining drill bounds
---@field x_end number End of mining drill bounds
---@field y number
---@field has_drills boolean? Do miners exist on this belt
---@field is_output boolean? Does belt output normally
---@field merge_strategy BeltMergeStrategy?
---@field merge_direction defines.direction.north | defines.direction.south | nil Merge direction
---@field merge_slave true? The belt does not build itself
---@field merge_target BaseBeltSpecification?
---@field lane1 MinerPlacement[] Top lane of belt
---@field lane2 MinerPlacement[] Bottom lane of belt
---@field throughput1 number Throughput of top lane of belt
---@field throughput2 number Throughput of bottom lane of belt
---@field merged_throughput1 number Throughput of top lane of belt
---@field merged_throughput2 number Throughput of bottom lane of belt
---@field has_obstacles true? Is belt underground interleaved
---@field overlay_line {[1]:number, [2]:number, curve: defines.direction?}[]? Line for overlay rendering

---@class BeltSpecification : BaseBeltSpecification
---@field index number Belt index for belt planner

---@alias BeltMergeDetail
---| "source"

---@class BeltPlannerSpecification
---@field [number] BeltSpecification
---@field player LuaPlayer
---@field surface LuaSurface
---@field coords Coords
---@field direction_choice DirectionString
---@field belt_choice string
---@field count number Belt count
---@field ungrouped boolean Is first step when belts are spaced out?
---@field _renderables LuaRenderObject[]

---@alias LuaRenderingFunction fun(RendererParams): uint64

---@class MppRendering
---@field draw_line LuaRenderingFunction
---@field draw_circle LuaRenderingFunction
---@field draw_rectangle LuaRenderingFunction
---@field draw_text LuaRenderingFunction

table.deepcopy = function(t) end
