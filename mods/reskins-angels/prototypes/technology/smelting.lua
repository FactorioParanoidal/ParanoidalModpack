-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "smelting",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 2,
}

local technologies = {
    -- Metallurgy
    ["angels-metallurgy-1"] = {tier = 1, icon_name = "metallurgy"},
    ["angels-metallurgy-2"] = {tier = 2, icon_name = "metallurgy"},
    ["angels-metallurgy-3"] = {tier = 3, icon_name = "metallurgy"},
    ["angels-metallurgy-4"] = {tier = 4, icon_name = "metallurgy"},
    ["angels-metallurgy-5"] = {tier = 5, icon_name = "metallurgy"},

    -- Strand Casting
    ["strand-casting-1"] = {tier = 1, prog_tier = 2, icon_name = "strand-casting"},
    ["strand-casting-2"] = {tier = 2, prog_tier = 3, icon_name = "strand-casting"},
    ["strand-casting-3"] = {tier = 3, prog_tier = 4, icon_name = "strand-casting"},
    ["strand-casting-4"] = {tier = 4, prog_tier = 5, icon_name = "strand-casting"},

    -- Ore Processing
    ["ore-processing-1"] = {tier = 1, prog_tier = 2, icon_name = "ore-processing-machine"},
    ["ore-processing-2"] = {tier = 1, prog_tier = 3, icon_name = "pellet-press"},
    ["ore-processing-3"] = {tier = 2, prog_tier = 4, icon_name = "pellet-press"},
    ["ore-processing-4"] = {tier = 3, prog_tier = 5, icon_name = "pellet-press"},
    ["ore-processing-5"] = {tier = 4, prog_tier = 6, icon_name = "pellet-press"},

    -- Smelting
    ["angels-solder-smelting-basic"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-solder-technology-icon"},

    ["angels-copper-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-copper-technology-icon"},
    ["angels-copper-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-copper-technology-icon"},
    ["angels-copper-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-copper-technology-icon"},

    ["angels-iron-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-iron-technology-icon"},
    ["angels-iron-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-iron-technology-icon"},
    ["angels-iron-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-iron-technology-icon"},

    ["angels-lead-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-lead-technology-icon"},
    ["angels-lead-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-lead-technology-icon"},
    ["angels-lead-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-lead-technology-icon"},

    ["angels-nickel-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-nickel-technology-icon"},
    ["angels-nickel-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-nickel-technology-icon"},
    ["angels-nickel-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-nickel-technology-icon"},

    ["angels-silicon-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silicon-technology-icon"},
    ["angels-silicon-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silicon-technology-icon"},
    ["angels-silicon-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silicon-technology-icon"},

    ["angels-solder-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-solder-technology-icon"},
    ["angels-solder-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-solder-technology-icon"},
    ["angels-solder-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-solder-technology-icon"},

    ["angels-tin-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-tin-technology-icon"},
    ["angels-tin-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-tin-technology-icon"},
    ["angels-tin-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-tin-technology-icon"},

    ["angels-aluminium-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-aluminium-technology-icon"},
    ["angels-aluminium-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-aluminium-technology-icon"},
    ["angels-aluminium-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-aluminium-technology-icon"},

    ["angels-cobalt-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-cobalt-technology-icon"},
    ["angels-cobalt-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-cobalt-technology-icon"},
    ["angels-cobalt-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-cobalt-technology-icon"},

    ["angels-gold-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-gold-technology-icon"},
    ["angels-gold-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-gold-technology-icon"},
    ["angels-gold-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-gold-technology-icon"},

    ["angels-glass-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-glass-technology-icon"},
    ["angels-glass-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-glass-technology-icon"},
    ["angels-glass-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-glass-technology-icon"},

    ["angels-manganese-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-manganese-technology-icon"},
    ["angels-manganese-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-manganese-technology-icon"},
    ["angels-manganese-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-manganese-technology-icon"},

    ["angels-silver-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silver-technology-icon"},
    ["angels-silver-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silver-technology-icon"},
    ["angels-silver-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silver-technology-icon"},

    ["angels-steel-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-steel-technology-icon"},
    ["angels-steel-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-steel-technology-icon"},
    ["angels-steel-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-steel-technology-icon"},

    ["angels-zinc-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-zinc-technology-icon"},
    ["angels-zinc-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-zinc-technology-icon"},
    ["angels-zinc-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-zinc-technology-icon"},

    ["angels-chrome-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-chrome-technology-icon"},
    ["angels-chrome-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-chrome-technology-icon"},
    ["angels-chrome-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-chrome-technology-icon"},

    ["angels-platinum-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-platinum-technology-icon"},
    ["angels-platinum-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-platinum-technology-icon"},
    ["angels-platinum-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-platinum-technology-icon"},

    ["angels-titanium-smelting-1"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-titanium-technology-icon"},
    ["angels-titanium-smelting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-titanium-technology-icon"},
    ["angels-titanium-smelting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-titanium-technology-icon"},
}

-- Powder Metallurgy
if angelsmods.trigger.early_sintering_oven then
  technologies["powder-metallurgy-1"] = {tier = 1, prog_tier = 1, icon_name = "powder-metallurgy"}
  technologies["powder-metallurgy-2"] = {tier = 2, prog_tier = 2, icon_name = "powder-metallurgy"}
  technologies["powder-metallurgy-3"] = {tier = 3, prog_tier = 3, icon_name = "powder-metallurgy"}
  technologies["powder-metallurgy-4"] = {tier = 4, prog_tier = 4, icon_name = "powder-metallurgy"}
  technologies["powder-metallurgy-5"] = {tier = 5, prog_tier = 5, icon_name = "powder-metallurgy"}
else
  technologies["powder-metallurgy-2"] = {tier = 1, prog_tier = 2, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
  technologies["powder-metallurgy-3"] = {tier = 2, prog_tier = 3, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
  technologies["powder-metallurgy-4"] = {tier = 3, prog_tier = 4, icon_name = "powder-metallurgy"}
  technologies["powder-metallurgy-5"] = {tier = 4, prog_tier = 5, icon_name = "powder-metallurgy"}
end

-- For Angel's Smelting with new seprated casting/smelting technology rework
if reskins.lib.migration.is_newer_version(mods["angelssmelting"], "0.6.14") then
    technologies["angels-copper-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-copper-technology-icon"}
    technologies["angels-copper-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-copper-technology-icon"}
    technologies["angels-copper-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-copper-technology-icon"}
    technologies["angels-copper-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-copper-technology-icon"}

    technologies["angels-iron-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-iron-technology-icon"}
    technologies["angels-iron-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-iron-technology-icon"}
    technologies["angels-iron-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-iron-technology-icon"}
    technologies["angels-iron-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-iron-technology-icon"}

    technologies["angels-lead-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-lead-technology-icon"}
    technologies["angels-lead-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-lead-technology-icon"}
    technologies["angels-lead-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-lead-technology-icon"}
    technologies["angels-lead-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-lead-technology-icon"}

    technologies["angels-nickel-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-nickel-technology-icon"}
    technologies["angels-nickel-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-nickel-technology-icon"}
    technologies["angels-nickel-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-nickel-technology-icon"}
    technologies["angels-nickel-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-nickel-technology-icon"}

    technologies["angels-silicon-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-silicon-technology-icon"}
    technologies["angels-silicon-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silicon-technology-icon"}
    technologies["angels-silicon-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-silicon-technology-icon"}
    technologies["angels-silicon-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silicon-technology-icon"}

    technologies["angels-tin-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-tin-technology-icon"}
    technologies["angels-tin-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-tin-technology-icon"}
    technologies["angels-tin-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-tin-technology-icon"}
    technologies["angels-tin-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-tin-technology-icon"}

    technologies["angels-aluminium-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-aluminium-technology-icon"}
    technologies["angels-aluminium-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-aluminium-technology-icon"}
    technologies["angels-aluminium-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-aluminium-technology-icon"}
    technologies["angels-aluminium-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-aluminium-technology-icon"}

    technologies["angels-cobalt-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-cobalt-technology-icon"}
    technologies["angels-cobalt-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-cobalt-technology-icon"}
    technologies["angels-cobalt-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-cobalt-technology-icon"}
    technologies["angels-cobalt-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-cobalt-technology-icon"}

    technologies["angels-gold-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-gold-technology-icon"}
    technologies["angels-gold-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-gold-technology-icon"}
    technologies["angels-gold-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-gold-technology-icon"}
    technologies["angels-gold-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-gold-technology-icon"}

    technologies["angels-manganese-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-manganese-technology-icon"}
    technologies["angels-manganese-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-manganese-technology-icon"}
    technologies["angels-manganese-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-manganese-technology-icon"}
    technologies["angels-manganese-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-manganese-technology-icon"}

    technologies["angels-silver-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-silver-technology-icon"}
    technologies["angels-silver-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silver-technology-icon"}
    technologies["angels-silver-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-silver-technology-icon"}
    technologies["angels-silver-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-silver-technology-icon"}

    technologies["angels-zinc-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-zinc-technology-icon"}
    technologies["angels-zinc-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-zinc-technology-icon"}
    technologies["angels-zinc-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-zinc-technology-icon"}
    technologies["angels-zinc-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-zinc-technology-icon"}

    technologies["angels-chrome-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-chrome-technology-icon"}
    technologies["angels-chrome-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-chrome-technology-icon"}
    technologies["angels-chrome-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-chrome-technology-icon"}
    technologies["angels-chrome-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-chrome-technology-icon"}

    technologies["angels-platinum-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-platinum-technology-icon"}
    technologies["angels-platinum-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-platinum-technology-icon"}
    technologies["angels-platinum-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-platinum-technology-icon"}
    technologies["angels-platinum-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-platinum-technology-icon"}

    technologies["angels-titanium-smelting-2"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-titanium-technology-icon"}
    technologies["angels-titanium-casting-2"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-titanium-technology-icon"}
    technologies["angels-titanium-smelting-3"] = {subgroup = "smelting", flat_icon = true, technology_icon_mipmaps = 4, image = "smelting-titanium-technology-icon"}
    technologies["angels-titanium-casting-3"] = {subgroup = "casting", flat_icon = true, technology_icon_mipmaps = 4, image = "casting-titanium-technology-icon"}
end

-- Check for special vanilla and override the powder metallurgy technology icons
if angelsmods and angelsmods.functions.is_special_vanilla() then
    technologies["powder-metallurgy-2"] = {tier = 1, prog_tier = 2, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
    technologies["powder-metallurgy-3"] = {tier = 2, prog_tier = 3, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
    technologies["powder-metallurgy-4"] = {tier = 3, prog_tier = 4, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
    technologies["powder-metallurgy-5"] = {tier = 4, prog_tier = 5, icon_name = "powder-metallurgy-special-vanilla", technology_icon_mipmaps = 4}
end

-- Check if we're using Angel's material colors
if reskins.lib.setting("reskins-angels-use-angels-material-colors") then
    technologies["bob-armor-making-4"] = {subgroup = "armor", flat_icon = true, technology_icon_mipmaps = 4}
    technologies["bob-power-armor-4"] = {subgroup = "armor", flat_icon = true, technology_icon_mipmaps = 4}
    technologies["bob-power-armor-5"] = {subgroup = "armor", flat_icon = true, technology_icon_mipmaps = 4}
end

reskins.lib.create_icons_from_list(technologies, inputs)