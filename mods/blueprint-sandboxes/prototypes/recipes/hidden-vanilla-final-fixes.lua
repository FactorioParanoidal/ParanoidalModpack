-- Move Loaders to our Tab (only if they exist)
if data.raw.recipe[BPSB.pfx .. "loader"] then
    data.raw.item["loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["loader"].order = "a-a"
end

if data.raw.recipe[BPSB.pfx .. "fast-loader"] then
    data.raw.item["fast-loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["fast-loader"].order = "a-b"
end

if data.raw.recipe[BPSB.pfx .. "express-loader"] then
    data.raw.item["express-loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["express-loader"].order = "a-c"
end

if data.raw.recipe[BPSB.pfx .. "turbo-loader"] then
    data.raw.item["turbo-loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["turbo-loader"].order = "a-d"
end

-- Move Infinity Entities to our Tab
data.raw.item["electric-energy-interface"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["electric-energy-interface"].order = "a-a"

data.raw.item["heat-interface"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["heat-interface"].order = "a-b"

data.raw.item["infinity-chest"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["infinity-chest"].order = "a-c"

data.raw.item["infinity-pipe"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["infinity-pipe"].order = "a-d"

data.raw.item["infinity-cargo-wagon"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["infinity-cargo-wagon"].order = "a-e"

-- Allow anyone to use Infinity Filters
data.raw["electric-energy-interface"]["electric-energy-interface"].gui_mode = "all"
data.raw["heat-interface"]["heat-interface"].gui_mode = "all"
data.raw["infinity-container"]["infinity-chest"].gui_mode = "all"
data.raw["infinity-pipe"]["infinity-pipe"].gui_mode = "all"
data.raw["infinity-cargo-wagon"]["infinity-cargo-wagon"].gui_mode = "all"