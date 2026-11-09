-- Geology by soil colour (Paranoidal ПР-062): which resources suit which soil colour. Shared by the
-- data stage (noise expressions alien-biomes-geology-<resource>, prototypes/reforged/geology.lua)
-- and the control stage (remote geology_bias, scripts/reforged-geology.lua).
return {
  MULTIPLIER = 2,
  -- soil colour -> resource
  BY_COLOUR = {
    -- sapphirite
    blue = "angels-ore1", purple = "angels-ore1", aubergine = "angels-ore1", violet = "angels-ore1", mauve = "angels-ore1",
    -- jivolite
    cream = "angels-ore2", yellow = "angels-ore2", tan = "angels-ore2",
    -- stiratite
    green = "angels-ore3", olive = "angels-ore3", turquoise = "angels-ore3",
    -- crotinnium
    grey = "angels-ore4", white = "angels-ore4",
    -- rubyte
    red = "angels-ore5", dustyrose = "angels-ore5", orange = "angels-ore5",
    -- bobmonium
    brown = "angels-ore6", beige = "angels-ore6",
    black = "coal",
  },
  -- infinite variants follow their ore
  INFINITE = {
    ["angels-ore1"] = "infinite-angels-ore1", ["angels-ore2"] = "infinite-angels-ore2",
    ["angels-ore3"] = "infinite-angels-ore3", ["angels-ore4"] = "infinite-angels-ore4",
    ["angels-ore5"] = "infinite-angels-ore5", ["angels-ore6"] = "infinite-angels-ore6",
    coal = "infinite-coal",
  },
  VOLCANIC = {"crude-oil", "angels-natural-gas", "angels-fissure"},
  -- tie-break order of soil categories when tiles are counted (most specific first)
  ORDER = {"volcanic", "black", "red", "dustyrose", "orange", "cream", "yellow", "tan", "blue", "purple",
           "aubergine", "violet", "mauve", "green", "olive", "turquoise", "grey", "white", "brown", "beige"},
}
