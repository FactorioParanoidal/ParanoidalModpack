if not mods["squeak-through-2"] then
  return
end

--- @diagnostic disable:inject-field
data.raw["pipe-to-ground"]["duct-underground"].squeak_behaviour = false
data.raw.pump["duct-exhaust"].squeak_behaviour = false
data.raw.pump["duct-intake"].squeak_behaviour = false
data.raw.pump["non-return-duct"].squeak_behaviour = false
data.raw["storage-tank"]["duct-cross"].squeak_behaviour = false
data.raw["storage-tank"]["duct-curve"].squeak_behaviour = false
data.raw["storage-tank"]["duct-long"].squeak_behaviour = false
data.raw["storage-tank"]["duct-small"].squeak_behaviour = false
data.raw["storage-tank"]["duct"].squeak_behaviour = false
data.raw["storage-tank"]["duct-t-junction"].squeak_behaviour = false
