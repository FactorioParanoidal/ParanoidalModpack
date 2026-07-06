local compat = {}

if not (script.active_mods["FluidMustFlow"]) then
  return compat
end

local function setup() 
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct")
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct-cross")
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct-curve")
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct-long")
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct-small")
  remote.call("PipeVisualizer", "pipelist_add", "storage-tank", "duct-t-junction")
end

compat.on_init = setup
compat.on_configuration_changed = setup

return compat