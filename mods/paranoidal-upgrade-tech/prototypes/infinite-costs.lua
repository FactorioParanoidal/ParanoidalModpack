-- Infinite technologies of other mods whose cost follows Beta 8 (InfiniteTech "normalize" option):
-- the cost doubles every level and the first infinite level costs 2000 units, as in Beta 8.
-- Fields: technology, count_formula, time (optional). Applied in data-final-fixes.lua.

return {
    -- Base 2.0: "2500*(L - 3)" (linear). Beta 8: "2^(L-3)*1000".
    {technology = "mining-productivity-4", count_formula = "2^(L-3)*1000"},
    -- Base 2.0 starts the infinite tier at level 5 ("1000*(L-4)", 30 s); Beta 8 at level 7 ("2^(L-6)*1000", 60 s).
    -- Same curve from the first infinite level: 2000, 4000, 8000...
    {technology = "follower-robot-count-5", count_formula = "2^(L-4)*1000", time = 60},
}
