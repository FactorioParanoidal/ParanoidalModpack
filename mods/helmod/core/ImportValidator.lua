-- Shape checks for the fields consumed by ModelBuilder and ModelCompute.
-- Unknown extension fields and shared export indexes are allowed; no schema version lock.
local M = {}

local function check_type(value, kind, path, required)
  assert(value == nil and not required or type(value) == kind, path .. ": " .. kind .. " expected")
end
local function fields(value, names, kind, path)
  for _, name in ipairs(names) do check_type(value[name], kind, path .. "." .. name) end
end
local function named(value, path)
  check_type(value, "table", path, true)
  check_type(value.name, "string", path .. ".name", true)
  assert(value.name ~= "", path .. ".name: empty")
end
local function records(value, path, visit)
  if value == nil then return end
  check_type(value, "table", path, true)
  for _, entry in pairs(value) do
    check_type(entry, "table", path .. "[]", true)
    visit(entry, path .. "[]")
  end
end
local function modules(value, path)
  records(value, path, function(entry, p)
    named(entry, p)
    fields(entry, {"quality"}, "string", p)
    fields(entry, {"amount"}, "number", p)
  end)
end
local function machine(value, path, beacon)
  if value == nil then return end
  check_type(value, "table", path, true)
  fields(value, {"name", "quality", "fuel", "fuel_quality"}, "string", path)
  fields(value, {"limit", "input", "combo", "per_factory", "per_factory_constant"}, "number", path)
  modules(value.modules, path .. ".modules")
  modules(value.module_priority, path .. ".module_priority")
  -- Missing names are supported by Model.newFactory/newBeacon defaults.
  if beacon then check_type(value.class, "string", path .. ".class") end
end
local function elements(value, path)
  records(value, path, function(entry, p)
    fields(entry, {"name", "type", "quality"}, "string", p)
    fields(entry, {"input"}, "number", p)
  end)
end
local function constraints(value, path)
  records(value, path, function(entry, p)
    fields(entry, {"type"}, "string", p)
    check_type(entry.item, "table", p .. ".item")
  end)
end
local function infos(value, path)
  if value == nil then return end
  check_type(value, "table", path, true)
  fields(value, {"title", "note"}, "string", path)
  if value.location ~= nil then
    named(value.location, path .. ".location")
    fields(value.location, {"type"}, "string", path .. ".location")
  end
  for _, key in ipairs({"primary_icon", "secondary_icon"}) do
    local icon = value[key]
    if icon ~= nil then
      check_type(icon, "table", path .. "." .. key, true)
      named(icon.name, path .. "." .. key .. ".name")
      fields(icon, {"type", "quality"}, "string", path .. "." .. key)
      fields(icon.name, {"type", "quality"}, "string", path .. "." .. key .. ".name")
    end
  end
end

local function validate(data, model_only)
  check_type(data, "table", "import", true)
  -- Also protect direct callers and table.deepcopy's special LuaObject escape hatch.
  local visiting, done, count = {}, {}, 0
  local function plain(value, depth)
    count = count + 1
    assert(count <= 200000 and depth <= 64, "import: complexity limit")
    if type(value) == "table" then
      assert(not visiting[value], "import: cycle")
      if done[value] then return end
      assert(getmetatable(value) == nil and value.__self == nil, "import: plain data expected")
      visiting[value] = true
      for k, v in pairs(value) do
        assert(type(k) == "string" or type(k) == "number" or type(k) == "boolean", "import: invalid key")
        plain(k, depth + 1); plain(v, depth + 1)
      end
      visiting[value], done[value] = nil, true
    elseif type(value) == "number" then
      assert(value == value and value ~= math.huge and value ~= -math.huge, "import: finite number expected")
    else
      assert(type(value) == "string" or type(value) == "boolean", "import: data expected")
    end
  end
  plain(data, 0)

  local tree = {}
  local function block(value, path, depth)
    assert(depth <= 64 and not tree[value], path .. ": repeated tree node")
    named(value, path)
    tree[value] = true
    assert(value.class == nil or value.class == "Block", path .. ": block expected")
    fields(value, {"type"}, "string", path)
    fields(value, {"unlinked", "by_factory", "by_product", "by_limit", "solver", "consumer"}, "boolean", path)
    infos(value.infos, path .. ".infos")
    elements(value.products, path .. ".products")
    elements(value.ingredients, path .. ".ingredients")
    constraints(value.contraints, path .. ".contraints")
    if value.products_linked ~= nil then
      check_type(value.products_linked, "table", path .. ".products_linked", true)
      for _, linked in pairs(value.products_linked) do check_type(linked, "boolean", path .. ".products_linked[]", true) end
    end
    check_type(value.children, "table", path .. ".children", true)
    for _, child in pairs(value.children) do
      named(child, path .. ".children[]")
      check_type(child.index, "number", path .. ".children[].index", true)
      if child.class == "Block" or child.children ~= nil then
        block(child, path .. ".children[]", depth + 1)
      else
        assert(child.class == nil or child.class == "Recipe", path .. ": recipe expected")
        fields(child, {"type", "quality"}, "string", path .. ".recipe")
        fields(child, {"production"}, "number", path .. ".recipe")
        machine(child.factory, path .. ".recipe.factory")
        records(child.beacons, path .. ".recipe.beacons", function(v, p) machine(v, p, true) end)
        constraints(child.contraints, path .. ".recipe.contraints")
      end
    end
  end

  local is_block = data.class == "Block" or data.children ~= nil
  if is_block then
    assert(not model_only and data.block_root == nil, "import: model expected")
    block(data, "block", 0)
    return "block"
  end
  assert(data.class == nil or data.class == "Model", "import: model expected")
  check_type(data.time, "number", "model.time")
  assert(data.time == nil or data.time > 0, "model.time: positive value expected")
  fields(data, {"group"}, "string", "model")
  check_type(data.blocks, "table", "model.blocks") -- regenerated by copying, not trusted as the tree
  if data.parameters ~= nil then
    check_type(data.parameters, "table", "model.parameters", true)
    if data.parameters.effects ~= nil then
      check_type(data.parameters.effects, "table", "model.parameters.effects", true)
      fields(data.parameters.effects, {"speed", "productivity", "consumption", "pollution", "quality"}, "number", "model.parameters.effects")
    end
  end
  block(data.block_root, "model.block_root", 0)
  return "model"
end

function M.check(data, model_only)
  local ok, kind = pcall(validate, data, model_only)
  if ok then return kind end
  return nil
end

return M
