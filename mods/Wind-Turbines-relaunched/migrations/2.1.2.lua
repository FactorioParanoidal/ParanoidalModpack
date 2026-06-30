---
--- Created by xyzzycgn.
--- DateTime: 21.08.25 10:10
---
local wind_speed = require("scripts/wind_speed")

log("start migration to 2.1.2")

for si, _ in pairs(storage.wind_speed_on_surface or {}) do
    storage.wind_speed_on_surface[si] = wind_speed.init()
    log(serpent.line(storage.wind_speed_on_surface[si]))
end

log("migration to 2.1.2 finshed")
