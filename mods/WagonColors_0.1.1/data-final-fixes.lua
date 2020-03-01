--[[
-- Author: Mooncat
-- Refactored: Optera 2019
--]]

-- Make locomotive, train stop, cargo wagon and fluid wagon pasteble to each other.
local locomotive_names = {}
local train_stop_names = {}
local cargo_wagon_names = {}
local fluid_wagon_names = {}
-- Get all names of the locomotives, train stops, cargo wagons and fluid wagons.
for _, prototype in pairs(data.raw["locomotive"]) do
  table.insert(locomotive_names, prototype.name)
end
for _, prototype in pairs(data.raw["train-stop"]) do
  table.insert(train_stop_names, prototype.name)
end
for _, prototype in pairs(data.raw["cargo-wagon"]) do
  table.insert(cargo_wagon_names, prototype.name)
end
for _, prototype in pairs(data.raw["fluid-wagon"]) do
  table.insert(fluid_wagon_names, prototype.name)
end

-- Add cargo wagons and fluid wagons to locomotives.
for _, prototype in pairs(data.raw["locomotive"]) do
  local additional_pastable_entities = prototype.additional_pastable_entities or {}
  for _, name in ipairs(cargo_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(fluid_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  prototype.additional_pastable_entities = additional_pastable_entities
end
-- Add cargo wagons and fluid wagons to train-stops.
for _, prototype in pairs(data.raw["train-stop"]) do
  local additional_pastable_entities = prototype.additional_pastable_entities or {}
  for _, name in ipairs(cargo_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(fluid_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  prototype.additional_pastable_entities = additional_pastable_entities
end
-- Add locomotives, train-stops and fluid wagons to cargo wagons.
for _, prototype in pairs(data.raw["cargo-wagon"]) do
  local additional_pastable_entities = prototype.additional_pastable_entities or {}
  for _, name in ipairs(locomotive_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(train_stop_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(fluid_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  prototype.additional_pastable_entities = additional_pastable_entities
end
-- Add locomotives, train-stops and cargo wagons to fluid wagons.
for _, prototype in pairs(data.raw["fluid-wagon"]) do
  local additional_pastable_entities = prototype.additional_pastable_entities or {}
  for _, name in ipairs(locomotive_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(train_stop_names) do
    table.insert(additional_pastable_entities, name)
  end
  for _, name in ipairs(cargo_wagon_names) do
    table.insert(additional_pastable_entities, name)
  end
  prototype.additional_pastable_entities = additional_pastable_entities
end
