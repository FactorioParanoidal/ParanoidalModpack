--add modules to bombs
if mods["bobmodules"] then
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "bob-speed-module-5", amount = 3 })
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "bob-productivity-module-5", amount = 3 })
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "bob-efficiency-module-5", amount = 3 })
else
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "speed-module-3", amount = 3 })
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "productivity-module-3", amount = 3 })
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "item", name = "efficiency-module-3", amount = 3 })
end
--fusion cores
if data.raw.item["fusion-reactor-equipment-2"] then
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "name", name = "fusion-reactor-equipment-2", amount = 1 })
else
  table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients,
    { type = "name", name = "fission-reactor-equipment", amount = 1 })
end
---------------------------------------
-- ANGELS NUCLEAR UPDATES --
---------------------------------------
-- move angels cells to this location
-- location of actual cells is
Ordering_fix = {
  --centrifuging/raw processing
  --[[
  ["depleted-uranium-reprocessing"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-a"},
  ["clowns-centrifuging-20pc-ore"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-b"},
  ["clowns-centrifuging-20pc-hexafluoride"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-c"},
  ["clowns-centrifuging-35pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-d"},
  ["clowns-centrifuging-45pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-e"},
  ["clowns-centrifuging-55pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-f"},
  ["clowns-centrifuging-65pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-g"},
  ["clowns-centrifuging-70pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-h"},
  ["clowns-centrifuging-75pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-i"},
  ["clowns-centrifuging-80pc"]={subgroup="clowns-uranium-centrifuging",order="a[uranium]-j"},]]
  ["uranium-processing"] = { subgroup = "clowns-uranium-centrifuging", order = "a[uranium]-l" },        --enabled for nukes only
  ["angels-thorium-processing"] = { subgroup = "clowns-uranium-centrifuging", order = "c[thorium]-a" }, --disabled
  --cells
  ["uranium-fuel-cell"] = { subgroup = "clowns-nuclear-cells", order = "a[U]-a" },
  ["angels-uranium-fuel-cell"] = { subgroup = "clowns-nuclear-cells", order = "a[U]-b" },
  ["mixed-oxide"] = { subgroup = "clowns-nuclear-cells", order = "b[Pu]-a" },
  ["angels-mixed-oxide-cell"] = { subgroup = "clowns-nuclear-cells", order = "b[Pu]-b" },
  ["angels-thorium-fuel-cell"] = { subgroup = "clowns-nuclear-cells", order = "c[Th]-a" },
  ["angels-deuterium-fuel-cell"] = { subgroup = "clowns-nuclear-cells", order = "d[D2O]-a" },
  --reprocessing
  ["nuclear-fuel-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "a[uranium]-b" },
  ["angels-advanced-uranium-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "a[uranium]-c" },
  ["angels-plutonium-synthesis"] = { subgroup = "clowns-nuclear-reprocessing", order = "a[uranium]-d" },
  ["angels-mixed-oxide-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "b[plutonium]-a" },
  ["angels-advanced-mixed-oxide-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "b[plutonium]-c" },
  ["angels-plutonium-breeding"] = { subgroup = "clowns-nuclear-reprocessing", order = "b[plutonium]-b" },
  ["angels-americium-regeneration"] = { subgroup = "clowns-nuclear-reprocessing", order = "b[plutonium]-d" },
  ["angels-thorium-fuel-cell-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "c[thorium]-c" },
  ["angels-advanced-thorium-fuel-cell-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "c[thorium]-d" },
  ["angels-deuterium-fuel-cell-reprocessing"] = { subgroup = "clowns-nuclear-reprocessing", order = "d[D2O]-a" },
  --fuels
}
for name, props in pairs(Ordering_fix) do
  --if data.raw["recipe"][name] then --need to always check they exist
  data.raw["recipe"][name].subgroup = props.subgroup
  data.raw["recipe"][name].order = props.order
  --end
end
--Recipe Plate updates - cells
if mods["bobplates"] then
  clowns.functions.replace_ing("mixed-oxide", "iron-plate", "bob-lead-plate", "ing")
  clowns.functions.replace_ing("angels-thorium-fuel-cell", "bob-zinc-plate", "bob-aluminium-plate", "ing")
else
  clowns.functions.replace_ing("mixed-oxide", "iron-plate", "angels-plate-lead", "ing")
  clowns.functions.replace_ing("angels-thorium-fuel-cell", "angels-plate-zinc", "angels-plate-aluminium", "ing")
end
--Recipe Plate updates - reprocessing
if mods["bobplates"] then
  clowns.functions.replace_ing("angels-mixed-oxide-reprocessing", "angels-slag",
    { type = "item", name = "bob-lead-oxide", amount = 10, ignored_by_productivity = 10 }, "res")
  clowns.functions.replace_ing("angels-thorium-fuel-cell-reprocessing", "angels-slag",
    { type = "item", name = "bob-alumina", amount = 5, ignored_by_productivity = 5 }, "res")
else
  clowns.functions.replace_ing("angels-mixed-oxide-reprocessing", "angels-slag",
    { type = "item", name = "angels-solid-lead-oxide", amount = 10, ignored_by_productivity = 10 }, "res")
  clowns.functions.replace_ing("angels-thorium-fuel-cell-reprocessing", "angels-slag",
    { type = "item", name = "angels-solid-aluminium-oxide", amount = 5, ignored_by_productivity = 5 }, "res")
end
