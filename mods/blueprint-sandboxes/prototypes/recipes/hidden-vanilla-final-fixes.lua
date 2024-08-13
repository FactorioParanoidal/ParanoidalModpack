-- Move Loaders to our Tab (only if they exist)
if data.raw.recipe[BPSB.pfx .. "loader"] then
    data.raw.item["loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["loader"].order = "a-a"

    data.raw.item["fast-loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["fast-loader"].order = "a-b"

    data.raw.item["express-loader"].subgroup = BPSB.pfx .. "loaders"
    data.raw.item["express-loader"].order = "a-c"
end

-- Move Infinity Entities to our Tab
data.raw.item["electric-energy-interface"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["electric-energy-interface"].order = "a-a"

data.raw.item["infinity-chest"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["infinity-chest"].order = "a-b"

data.raw.item["infinity-pipe"].subgroup = BPSB.pfx .. "infinity"
data.raw.item["infinity-pipe"].order = "a-c"

-- Allow anyone to use Infinity Filters
data.raw["electric-energy-interface"]["electric-energy-interface"].gui_mode = "all"
data.raw["infinity-container"]["infinity-chest"].gui_mode = "all"
data.raw["infinity-pipe"]["infinity-pipe"].gui_mode = "all"
