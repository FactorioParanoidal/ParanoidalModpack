#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "tempfile"

mod_dir = File.expand_path("..", __dir__)
info_path = File.join(mod_dir, "info.json")
data_path = File.join(mod_dir, "data.lua")
internal_path = File.join(mod_dir, "internal.lua")

def assert(condition, message)
  raise message unless condition
end

assert(File.exist?(info_path), "missing info.json")
assert(File.exist?(data_path), "missing data.lua")
assert(File.exist?(internal_path), "missing internal.lua")

info = JSON.parse(File.read(info_path))
assert(info["name"] == "MxlChievements2", "info.json name must be MxlChievements2")
assert(info["title"].include?("MxlChievements"), "title should preserve upstream mod name")
assert(info["factorio_version"] == "2.0", "factorio_version must stay 2.0")
assert(info["dependencies"].include?("! MxlChievements"), "must conflict with upstream MxlChievements")
assert(info["dependencies"].include?("? quality"), "must load after quality when it is enabled")
assert(info["dependencies"].include?("? space-age"), "must load after space-age when it is enabled")

data_lua = File.read(data_path)
assert(data_lua.include?('require("internal")'), "data.lua should load internal.lua")

internal_lua = File.read(internal_path)
assert(internal_lua.include?("local function mxl_should_extend"), "missing achievement guard helper")
assert(internal_lua.include?("local function mxl_extend"), "missing guarded data extender")
assert(internal_lua.include?("local mxl_extended_names"), "missing duplicate achievement-name guard")
assert(!internal_lua.include?("__MxlChievements__/"), "icons must use MxlChievements2 namespace")
assert(!internal_lua.include?("data:extend{"), "raw data:extend calls must go through mxl_extend")
assert(internal_lua.include?('item_product = "agricultural-science-pack"'), "test fixture expects SA-only achievement to remain guarded")

lua_harness = <<~LUA
  package.path = #{File.join(mod_dir, "?.lua").inspect} .. ";" .. package.path

  local function deepcopy(value)
    if type(value) ~= "table" then
      return value
    end

    local copy = {}
    for key, child in pairs(value) do
      copy[deepcopy(key)] = deepcopy(child)
    end
    return copy
  end

  table.deepcopy = deepcopy

  local extended = {}
  data = {
    raw = {
      item = {
        ["iron-gear-wheel"] = { icon = "__base__/graphics/icons/iron-gear-wheel.png", icon_size = 64 },
        ["spidertron"] = { icon = "__base__/graphics/icons/spidertron.png", icon_size = 64 },
        ["selector-combinator"] = { icon = "__base__/graphics/icons/selector-combinator.png", icon_size = 64 },
        ["cliff-explosives"] = { icon = "__base__/graphics/icons/cliff-explosives.png", icon_size = 64 },
        ["underground-belt"] = { icon = "__base__/graphics/icons/underground-belt.png", icon_size = 64 },
        ["express-underground-belt"] = { icon = "__base__/graphics/icons/express-underground-belt.png", icon_size = 64 },
        ["transport-belt"] = { icon = "__base__/graphics/icons/transport-belt.png", icon_size = 64 },
      },
      fluid = {},
      quality = {
        normal = {},
      },
    },
  }

  function data:extend(prototypes)
    for _, prototype in ipairs(prototypes) do
      table.insert(extended, prototype)
    end
  end

  dofile(#{data_path.inspect})

  local by_name = {}
  local underground_belt_1_count = 0
  for _, prototype in ipairs(extended) do
    by_name[prototype.name] = prototype
    if prototype.name == "underground-belt-1" then
      underground_belt_1_count = underground_belt_1_count + 1
    end
  end

  assert(by_name["gear-production-1"], "existing item achievement should be extended")
  assert(not by_name["agricultural-science-pack-1"], "missing SA item achievement should be filtered")
  assert(underground_belt_1_count == 1, "duplicate achievement names should be filtered")
  assert(by_name["spidertron-1"], "spidertron achievement should be extended")
  assert(by_name["spidertron-1"].icon == "__base__/graphics/icons/spidertron.png", "blank placeholder achievement icon should use item icon")
LUA

Tempfile.create(["mxl_chievements2_guard_test", ".lua"]) do |file|
  file.write(lua_harness)
  file.flush

  stdout, stderr, status = Open3.capture3("lua", file.path)
  assert(status.success?, "Lua behavior harness failed:\nSTDOUT:\n#{stdout}\nSTDERR:\n#{stderr}")
end

puts "MxlChievements2 fork checks passed"
