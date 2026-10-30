-- Shared by the settings, data and control stages.
-- `type` is the old internal name: graphics folder and startup setting suffix (kept for saved settings).
-- `threshold` is the default threshold setting in percent (overflow and top-up only).
-- `tint` is the mask colour of the "reskins" look, the same as reskins-angels gives the Angels valves.
return {
    { name = "valves-overflow", type = "overflow", mode = "overflow", threshold = 80, tint = "689ed3" },
    { name = "valves-top_up",   type = "top_up",   mode = "top-up",   threshold = 50, tint = "fcfcfc" },
    { name = "valves-one_way",  type = "one_way",  mode = "one-way",                  tint = "d4933f" },
}
