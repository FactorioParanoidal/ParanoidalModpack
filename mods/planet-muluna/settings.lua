-- for key,func in pairs(_G) do
--   print(key,type(func) ~= "function" and func or nil)
-- end
--error(serpent.block(_G))
require("wood-gasification.settings")
data:extend{
    {
        type = "bool-setting",
        name = "override-space-connection",
        setting_type = "startup",
        default_value = false,
        order = "ya",
      },
      {
        type = "bool-setting",
        name = "disable-muluna-music",
        setting_type = "startup",
        default_value = false,
        order = "yb",
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-restrict-crusher",
        setting_type = "startup",
        default_value = false,
        order = "ab",
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-restrict-asteroid-collector",
        setting_type = "startup",
        default_value = false,
        order = "ac",
      },
      -- {
      --   type = "bool-setting",
      --   name = "muluna-hardcore-require-helium-3-in-fusion-cell",
      --   setting_type = "startup",
      --   default_value = false,
      --   order = "ad",
      -- },
      {
        type = "bool-setting",
        name = "muluna-hardcore-remove-steam-furnaces",
        setting_type = "startup",
        default_value = false,
        order = "ae",
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-remove-starting-cargo-pods",
        setting_type = "startup",
        default_value = false,
        order = "af",
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-classic-wood-gasification",
        setting_type = "startup",
        default_value = false,
        order = "ag",
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-lock-cargo-drops",
        setting_type = "startup",
        default_value = false,
        order = "ai",
        rocs_hard_mode = true,
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-lock-logistic-system-technology",
        localised_description={"mod-setting-description.muluna-hardcore-lock-recipe-x"},
        setting_type = "startup",
        default_value = false,
        order = "aj",
        rocs_hard_mode = true,
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-greenhouses-require-space-science",
        localised_description={"mod-setting-description.muluna-hardcore-lock-recipe-x"},
        setting_type = "startup",
        default_value = false,
        order = "ak",
        rocs_hard_mode = true,
      },
      {
        type = "bool-setting",
        name = "muluna-hardcore-silicon-requires-space-science",
        localised_description={"mod-setting-description.muluna-hardcore-lock-recipe-x"},
        setting_type = "startup",
        default_value = false,
        order = "al",
        rocs_hard_mode = true,
      },
      {
        type = "bool-setting",
        name = "muluna-easy-vanilla-rocket-part-costs",
        setting_type = "startup",
        default_value = false,
        hidden = true,
        forced_value = true,
        order = "ba",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-vanilla-advanced-thruster-fuel-costs",
        setting_type = "startup",
        default_value = false,
        order = "bb",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-wood-gasification-productivity",
        setting_type = "startup",
        default_value = false,
        order = "bc",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-simple-wood-gasification",
        setting_type = "startup",
        default_value = false,
        order = "bd",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-simple-nanofoamed-polymers",
        setting_type = "startup",
        default_value = false,
        order = "be",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-revert-changes-to-space-platform-technology",
        setting_type = "startup",
        default_value = true,
        -- Paranoidal fork: the build keeps the platform technologies of Space Age (space science on a platform).
        hidden = true,
        forced_value = true,
        order = "bf",
      },
      {
        type = "bool-setting",
        name = "muluna-alternative-automation-pack-recipe",
        --localised_name = {"mod-setting-name.muluna-alternative-automation-pack-recipe"},
        --localised_description={"mod-setting-des.muluna-alternative-automation-pack-recipe"},
        setting_type = "startup",
        default_value = false,
        order = "bg",
        rocs_hard_mode = true,
      },
      {
        type = "bool-setting",
        name = "muluna-easy-alternative-battery-recipe",
        --localised_name = {"mod-setting-name.muluna-alternative-automation-pack-recipe"},
        --localised_description={"mod-setting-des.muluna-alternative-automation-pack-recipe"},
        setting_type = "startup",
        default_value = false,
        order = "bga",
        hidden = true,
        forced_value = true,
      },
       {
        type = "bool-setting",
        name = "muluna-easy-interstellar-science-pack-compatibility-mode",
        setting_type = "startup",
        default_value = false,
        --maximum_value = 10,
        order = "bga",
      },
      {
        type = "bool-setting",
        name = "muluna-easy-electric-roboports-on-muluna",
        setting_type = "startup",
        default_value = false,
        order = "bh",
      },
      {
        type = "bool-setting",
        name = "muluna-change-quality-science-pack-drain",
        setting_type = "startup",
        default_value = false,
        -- Paranoidal fork: the qualities of the build (ic-more-qualities) keep their science pack drain.
        hidden = true,
        forced_value = false,
        order = "ee",
      },
      {
        type = "int-setting",
        name = "space-science-pack-output",
        setting_type = "startup",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 10,
        order = "ca",
      },
      {
        type = "double-setting",
        name = "space-science-pack-energy",
        setting_type = "startup",
        default_value = 7,
        minimum_value = 0.01,
        maximum_value = 60,
        order = "cb",
      },
      {
        type = "int-setting",
        name = "muluna-interstellar-science-pack-packs-required",
        setting_type = "startup",
        default_value = 2,
        minimum_value = 1,
        --maximum_value = 10,
        order = "cc",
      },
      {
        type = "bool-setting",
        name = "muluna-interstellar-science-pack-dynamic-packs-required",
        setting_type = "startup",
        default_value = false,
        --maximum_value = 10,
        order = "cca",
      },
      {
        type = "double-setting",
        name = "muluna-interstellar-science-pack-dynamic-packs-required-percentage-required",
        setting_type = "startup",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 100,
        --maximum_value = 10,
        order = "ccb",
      },
      {
        type = "double-setting",
        name = "muluna-balance-fulgoran-cargo-drop-radius",
        setting_type = "startup",
        default_value = 64,
        minimum_value = 16,
        maximum_value = 512,
        order = "cd"

      },
      {
        type = "double-setting",
        name = "muluna-balance-fulgoran-cargo-drop-item-multiplier",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0,
        maximum_value = 10,
        order = "ce"
      },
      {
        type = "double-setting",
        name = "muluna-balance-exploration-science-data-cost",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 100,
        order = "cf"

      },

    --   {
    --     type = "double-setting",
    --     name = "planet-power-consumption",
    --     setting_type = "startup",
    --     default_value = 300,
    --     minimum_value = 1,
    --     maximum_value = 1000,
    --     order = "a"
    -- },
    {
        type = "double-setting",
        name = "platform-power-consumption",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0.3,
        maximum_value = 1000,
        order = "db"
    },
    {
      type = "bool-setting",
      name = "enable-nav-beacon",
      localised_name = {"mod-setting-name.enable-muluna-satellite-radar"},
      setting_type = "startup",
      default_value = true,
      order = "fa"
    },
    {
      type = "bool-setting",
      name = "muluna-graphics-enable-footstep-animations",
      setting_type = "startup",
      default_value = true,
      order = "ea"
    },
    {
      type = "double-setting",
      name = "nav-beacon-update-ticks",
      setting_type="startup",
      default_value = 60,
      minimum_value = 1,
      maximum_value = 360,
      order = "eb",
    },
    {
      type = "double-setting",
      name = "muluna-telescope-combinator-update-ticks",
      setting_type="startup",
      default_value = 6,
      minimum_value = 1,
      maximum_value = 180,
      order = "ec",
    },
    {
      type = "bool-setting",
      name = "nav-beacon-display-alert",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "ba"
    },
    -- {
    --   type = "bool-setting",
    --   name = "muluna-new-interstellar-pack-recipe",
    --   setting_type = "startup",
    --   default_value = false,
    --   order = "za"
    -- },
    -- {
    --   type = "bool-setting",
    --   name = "muluna-old-interstellar-pack-recipe",
    --   setting_type = "startup",
    --   default_value = false,
    --   order = "za"
    -- },

}
--Space casinos are getting nerfed in 2.1, so this setting is obsolete when Factorio 2.1 comes out.
if helpers.compare_versions(helpers.game_version,"2.1.0") < 0 then 
  data:extend{{
        type = "bool-setting",
        name = "muluna-hardcore-remove-space-casino",
        setting_type = "startup",
        default_value = false,
        order = "ah",
  }} 
end


if mods["any-planet-start"] then
  APS.add_choice("muluna")
end

--Runtime entity replacement settings
data:extend{
  {
      type = "bool-setting",
      name = "muluna-runtime-vehicle-replacement",
      setting_type = "startup",
      default_value = true,
      order = "a",
      hidden = true,
      forced_value = true,
    },
    {
      type = "bool-setting",
      name = "muluna-runtime-locomotive-replacement",
      setting_type = "startup",
      default_value = true,
      order = "fb",
      hidden = false,
      --forced_value = true,
    },
}