local M = {}

local patterns = {
  ore = {
    -- generic
    "crushed",
    "dust",
    "nugget",
    "ore",
    "pebble",
    "powder",
    "rock%-",
    "rock$",
    "%-rock%-",
    "sand",
    "slag",
    -- angelsrefining
    "^geode%-",
    -- angelssmelting
    "^processed%-",
    -- angelspetrochem
    "^solid%-",
    -- Fluidless_Mining_and_Ore_Washing
    "%-gangue$",
    -- pyrawores
    "^(low%-|high%-)grade%-",
    "^reduced%-",
    "^sintered%-",
    "%-rejects$",
    -- pyalienlife
    "biomass",
    "%-seeds",
    "%-spore",
    "%-leaves$",
    -- pyalternative-energy
    "^am%-",
    "^cm%-",
    "^pu%-",
    "^u%-",
  },
  plates = {
    "plate",
    "ingot",
    -- pymods
    "%-alloy$",
  }
}

-- bulk items that don't fit the above patterns
local items = {
  -- base
  "coal", "landfill", "plastic-bar", "stone", "sulfur",
  -- bobores
  "quartz",
  -- bobplates
  "carbon", "salt", "lithium-chloride", "lithium-perchlorate",
  "sodium-hydroxide", "calcium-chloride", "lead-oxide", "alumina",
  "tungsten-oxide", "silicon-nitride", "cobalt-oxide", "silicon-carbide",
  "silver-nitrate", "silver-oxide",
  -- bzcarbon
  "flake-graphite", "rough-diamond", "fullerenes", "nanotubes", "graphene",
  -- bzlead
  "enriched-lead", 
  -- bzsilicon
  "silica",
  -- bztitanium
  "enriched-titanium",
  -- bztungsten
  "enriched-tungsten", 
  -- bzzirconium
  "zircon", "zirconia", "enriched-zircon", "zirconium-tungstate",  
  -- hardCrafting
  "dirt",
  -- Krastorio
  "enriched-copper", "enriched-iron", "imersite", "k-coke", "k-lithium",
  "k-lithium-chloride", "k-quartz", "k-raw-chunk", "k-silicon",
  "k-tantalum", "k-titanium", "menarite", "raw-imersite", "raw-menarite",
  "raw-minerals", "steel-billet",
  -- Krastorio2
  "raw-rare-metals", "lithium", "lithium-chloride", "silicon", "enriched-rare-metals",
  -- omnimatter
  "omnite",
  -- pycoalprocessing
  "active-carbon", "ash", "bonemeal", "borax", "boron-trioxide",
  "calcium-carbide", "coal-briquette", "coarse", "coke", "dry-ralesia",
  "fawogae", "fawogae-substrate", "gravel", "iron-oxide", "lime", "limestone",
  "lithium-peroxide", "niobium-concentrate", "niobium-oxide", "organics",
  "ppd", "ralesias", "raw-borax", "rich-clay", "soil",
  "zinc-chloride",
  -- pyrawores
  "ammonium-chloride", "clean-nexelit", "coarse-coal", "concentrated-ti",
  "concentrated-zinc", "crystalized-sodium-aluminate",
  "gold-concentrate", "gold-precipitate", "gold-precipitate-2",
  "high-chromite", "high-tin-concentrate", "high-tin-mix",
  "iron-concentrate", "p2s5", "processed-chromite", "purified-gold",
  "purified-quartz", "purified-zinc", "pyrite", "raw-coal", "redhot-coke",
  "salt", "sl-concentrate", "sodium-aluminate", "sodium-bisulfate",
  "sodium-carbonate", "sodium-hydroxide", "sodium-sulfate", "sponge-iron",
  "starch", "tin-concentrate", "ti-residue", "unslimed-iron", "yellow-cake",
  -- pyfusionenergy
  "calcinates", "boron-carbide", "molybdenum-oxide",
  -- pypetroleumhandling
  "carbon-black", "guar", "soot",
  -- pyhightech
  "cadaveric-arum", "clay", "moondrop", "urea", "ree-concentrate", "reo",
  "phenol", "raw-fiber", "lithium-niobate", "zinc-acetate",
  "lard", "skin", "meat",
  -- pyalienlife
  "bonemeal", "bones", "brain", "cellulose", "chitin", "cobalt-extract",
  "cobalt-fluoride", "cobalt-oxide", "dingrit-spike", "dried-grod", "grod",
  "guts", "keratin", "lignin", "manure",
  "moondrop-diesel", "moondrop-fueloil", "moondrop-gas", "moondrop-kerosene",
  "moss", "rennea", "saps", "sea-sponge", "seaweed", "shell", "sporopollenin",
  "sugar", "yaedols", "nisi", "sic", "green-sic",
  -- pyalternativeenergy
  "americium-oxide", "ammonium-mixture", "animal-eye", "arsenic",
  "citric-acid", "crmoni", "crude-salt", "czts-slab",
  "eg-si", "erbium", "ernico", "er-oxalate", "er-oxide", "eva",
  "gaas", "lead-acetate", "lithium", "high-energy-waste-1",
  "impure-er-oxide", "intermetallics", "inverse-opal",
  "lithium-niobate-nano", "mositial-nx", "nbalti", "neodymium-oxide",
  "nickel-nitrate", "nxzngd", "oxidized-pan-fiber", "plutonium-oxide",
  "rhodamine-b", "self-assembly-monolayer", "sodium-citrate",
  "sodium-cyanate", "ti-n", "uranium-oxide", "vitreloy", "yellow-dextrine",
  -- space-exploration
  "vulcanite", "cryonite", "vitamelange", "water-ice", "methane-ice",
  -- Rich Rocks Requiem
  "rrr-rich-rocks", "rrr-raw-minerals",
}

for i, item in ipairs(items) do
  items[item] = true
  items[i] = nil
end

-- runtime variables

local allowed_items_setting = settings.global["railloader-allowed-items"].value

local function item_matches_patterns(item_name, group)
  for _, pat in ipairs(patterns[group]) do
    if string.find(item_name, pat) then
      return true
    end
  end
  return false
end

local acceptable_item_cache = {}

local function is_acceptable_item(item_name)
  if allowed_items_setting == "any" then
    return true
  end

  local from_cache = acceptable_item_cache[item_name]
  if from_cache ~= nil then
    return from_cache
  end
  acceptable_item_cache[item_name] = items[item_name] or
    item_matches_patterns(item_name, "ore") or
    (allowed_items_setting == "ore, plates" and item_matches_patterns(item_name, "plates"))
  return acceptable_item_cache[item_name]
end

function M.acceptable_items(inventory, limit)
  local out = {}
  for name in pairs(inventory.get_contents()) do
    if is_acceptable_item(name) then
      out[#out+1] = name
      if #out >= limit then
        return out
      end
    end
  end
  return out
end

function M.on_setting_changed()
  allowed_items_setting = settings.global["railloader-allowed-items"].value
  acceptable_item_cache = {}
end

return M
