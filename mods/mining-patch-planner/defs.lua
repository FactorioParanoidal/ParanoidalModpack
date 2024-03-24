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
---@field uses_underground_belts boolean
---@field pole_available boolean
---@field pole_omittable boolean Allow a no electric pole option
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

---@class DeconstructSpecification
---@field x number
---@field y number
---@field width number
---@field height number

---@class BeltSpecification
---@field x1 number Start
---@field x2 number End
---@field y number
---@field built boolean? Do miners exist on this belt
---@field lane1 MinerPlacement[]
---@field lane2 MinerPlacement[]

---@alias LuaRenderingFunction fun(RendererParams): uint64

---@class MppRendering
---@field draw_line LuaRenderingFunction
---@field draw_circle LuaRenderingFunction
---@field draw_rectangle LuaRenderingFunction
---@field draw_text LuaRenderingFunction

table.deepcopy = function(t) end
