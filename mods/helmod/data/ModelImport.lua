-- Import into a temporary model first. Neither a malformed payload nor a solver error
-- may leave a half-imported model or append half a block to the player's destination.
local Validator = require("core.ImportValidator")
local M = {}

function M.read(text, model_only)
  local data = Converter.read(text)
  if data == nil then return nil, "helmod_error.import-data" end
  if not Validator.check(data, model_only) then return nil, "helmod_error.import-structure" end
  return data
end

local function failed(err)
  log("[helmod] import failed: " .. tostring(err):sub(1, 1000))
  return nil, "helmod_error.import-failed"
end

function M.newModel(data)
  if Validator.check(data, true) ~= "model" then return nil, "helmod_error.import-structure" end
  local previous_id, previous_models = storage.model_id, storage.models
  local model
  local ok, err = pcall(function()
    model = Model.newModel()
    model.time = data.time or 1
    ModelBuilder.copyModel(model, data)
    ModelCompute.update(model)
  end)
  if not ok then
    if model and storage.models then storage.models[model.id] = nil end
    storage.model_id, storage.models = previous_id, previous_models
    return failed(err)
  end
  return model
end

function M.paste(model, block, data)
  if not Validator.check(data, false) then return nil, "helmod_error.import-structure" end
  local staged
  local ok, err = pcall(function()
    assert(type(model) == "table" and type(block) == "table", "destination missing")
    staged = table.deepcopy(model)
    local staged_block = block == model.block_root and staged.block_root or staged.blocks[block.id]
    assert(staged_block, "destination block missing")
    -- Do not apply the source model's time when pasting into an existing model.
    ModelBuilder.pastModel(staged, staged_block, data)
    ModelCompute.update(staged)
  end)
  if not ok then return failed(err) end
  -- Keep the public model table identity and its id/owner; commit only after computation.
  for k in pairs(model) do model[k] = nil end
  for k, v in pairs(staged) do model[k] = v end
  return model
end

function M.report(reason)
  local player = Player.native()
  if player then player.print({"helmod_error.import-rejected", {reason}}) end
end

return M
