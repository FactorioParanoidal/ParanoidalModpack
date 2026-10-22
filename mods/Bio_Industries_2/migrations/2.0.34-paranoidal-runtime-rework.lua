-- Paranoidal: runtime rework of Bio Industries.
-- * Bio farm MK2/MK3 became compound entities like MK1: existing tier farms get the
--   hidden connector pole (it joins the poles in reach), solar panel and lamp of MK1.
-- * Musk floor is tracked per surface: the table is rebuilt from the hidden panels.
-- * Growing trees are processed every 60 ticks; entries of deleted surfaces or removed
--   tree prototypes are dropped.
-- BioInd.setup_storage (control.lua) also runs in on_configuration_changed; it is
-- idempotent, so the second run finds nothing left to do.
local stats = BioInd.setup_storage()

local registered = {}
for name, count in pairs(stats.registered) do
    registered[#registered + 1] = name .. " " .. count
end
table.sort(registered)
log(string.format(
    "Bio Industries runtime rework: registered %s; hidden entities restored %d; stale entries removed %d; growing-tree entries dropped %d",
    registered[1] and table.concat(registered, ", ") or "nothing", stats.restored, stats.removed, stats.dropped_trees))
