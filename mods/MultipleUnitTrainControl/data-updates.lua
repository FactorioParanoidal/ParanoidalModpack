--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: data-updates.lua
 * Description: Add the MU locomotives
--]]

flib = require('__flib__.data-util')

-- Copied from Optera's Train Overhaul, because their library is deprecated now
function multiply_energy_value(energy_string, factor)
  if type(energy_string) == "string" then
    local value, unit = flib.get_energy_value(energy_string)
    if value then
      value = value * factor
      return value..unit
    end
  end
  return ""
end

require ("data.createMuLoco")

-- Special code: Run this first so that auto-gen doesn't attempt to handle them
require ("prototypes.ret_add_mu")

-- Generate procedurally
require ("data.generate_all_mu")
