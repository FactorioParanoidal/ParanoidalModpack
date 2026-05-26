
---@class NetworkData
---@field icon? SpritePath
---@field tip? string 

---@class CombinatorData
---@field provider boolean
---@field requester boolean
---@field ltn-provider-threshold number?
---@field ltn-provider-stack_threshold number?
---@field ltn-requester-threshold number?
---@field ltn-requester-stack-threshold number?

---@class Replacement
---@field combinator_data CombinatorData
---@field no_auto_disable boolean
---@field pos MapPosition
---@field tick uint
---@field name string

---@class PreviousBlueprint
---@field tick uint32
---@field blueprint LuaItemStack

local storage_data = {}

function storage_data.init()
  ---@type PlayerTable[]
  storage.players = {}
  ---@type NetworkData[]
  storage.network_descriptions = {}
  ---@type CombinatorData[]
  storage.combinators = {}
  ---@type Replacement[][]
  storage.replacements = {}
  ---@type PreviousBlueprint[]
  storage.previous_opened_blueprint_for = {}
end

return storage_data