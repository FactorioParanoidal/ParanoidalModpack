if not mods["space-exploration"] then
  return
end

data.raw["item"]["duct-small"].subgroup = "pipe"
if not settings.startup["fmf-enable-duct-auto-join"].value then
  data.raw["item"]["duct"].subgroup = "pipe"
  data.raw["item"]["duct-long"].subgroup = "pipe"
end
data.raw["item"]["duct-t-junction"].subgroup = "pipe"
data.raw["item"]["duct-curve"].subgroup = "pipe"
data.raw["item"]["duct-cross"].subgroup = "pipe"
data.raw["item"]["duct-underground"].subgroup = "pipe"
data.raw["item"]["non-return-duct"].subgroup = "pipe"
data.raw["item"]["duct-intake"].subgroup = "pipe"
data.raw["item"]["duct-exhaust"].subgroup = "pipe"
