---Table of specific LTN Combinators open indexed by player.
---@class PlayerTable
---@field uis {main: LTNC, netui: NetUI} @ Custom UIs for the mod
---@field settings table @ State of settings
---@field unit_number? uint
---@field main_elems? table<string, LuaGuiElement> @ GuiElemDef Elems of LtncUI
---@field working_slot? WorkingSlot @ Current miscellaneous signal slot player is working with
---@field original_reach_bonus? uint

---@class WorkingSlot
---@field index uint
---@field panel LuaGuiElement
---@field stack_size integer
---@field confirm LuaGuiElement
---@field cancel LuaGuiElement
---@field items LuaGuiElement
---@field slider LuaGuiElement
---@field stacks LuaGuiElement

local player_data = {}

---@param player LuaPlayer
function player_data.init(player)
  ---@type PlayerTable
  local player_table = {
    uis = {},
    settings = {},
  }
  local settings = settings.get_player_settings(player.index)
  player_table.settings["ltnc-use-stacks"] = settings["ltnc-use-stacks"].value
  player_table.settings["ltnc-negative-signals"] = settings["ltnc-negative-signals"].value

  storage.players[player.index] = player_table
end

return player_data