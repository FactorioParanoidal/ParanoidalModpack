-- Generated from new-enemies 0.0.10 graphics (Wolfenstain) by repack_flyer_sheets.py; do not edit.
-- attack sheet: frames 1..landing_frames = landing, then attack_frames ground attack frames.
return {
  ["scale"] = 1.000260,
  ["landing_frames"] = 10,
  ["attack_frames"] = 11,
  ["states"] = {
    ["flying"] = {
      ["frame_count"] = 8,
      ["base"] = {
        ["files"] = {"flyer-flying-base-1.png"},
        ["width"] = 282,
        ["height"] = 238,
        ["line_length"] = 8,
        ["lines_per_file"] = 16,
        ["shift"] = {-0.015629, -3.360248}
      },
      ["mask"] = {
        ["files"] = {"flyer-flying-mask-1.png"},
        ["width"] = 258,
        ["height"] = 216,
        ["line_length"] = 8,
        ["lines_per_file"] = 16,
        ["shift"] = {-0.015629, -3.360248}
      },
      ["shadow"] = {
        ["files"] = {"flyer-flying-shadow-1.png"},
        ["width"] = 318,
        ["height"] = 194,
        ["line_length"] = 8,
        ["lines_per_file"] = 16,
        ["shift"] = {4.047927, 0.515759}
      }
    },
    ["death_air"] = {
      ["frame_count"] = 12,
      ["base"] = {
        ["files"] = {"flyer-death_air-base-1.png", "flyer-death_air-base-2.png"},
        ["width"] = 265,
        ["height"] = 293,
        ["line_length"] = 12,
        ["lines_per_file"] = 13,
        ["shift"] = {0.000000, -2.469392}
      },
      ["mask"] = {
        ["files"] = {"flyer-death_air-mask-1.png", "flyer-death_air-mask-2.png"},
        ["width"] = 244,
        ["height"] = 269,
        ["line_length"] = 12,
        ["lines_per_file"] = 15,
        ["shift"] = {0.015629, -2.500650}
      },
      ["shadow"] = {
        ["files"] = {"flyer-death_air-shadow-1.png"},
        ["width"] = 374,
        ["height"] = 191,
        ["line_length"] = 10,
        ["lines_per_file"] = 20,
        ["shift"] = {2.922635, 0.437614}
      }
    },
    ["attack"] = {
      ["frame_count"] = 21,
      ["base"] = {
        ["files"] = {"flyer-attack-base-1.png", "flyer-attack-base-2.png", "flyer-attack-base-3.png", "flyer-attack-base-4.png"},
        ["width"] = 250,
        ["height"] = 288,
        ["line_length"] = 7,
        ["lines_per_file"] = 14,
        ["shift"] = {-0.015629, -2.547537}
      },
      ["mask"] = {
        ["files"] = {"flyer-attack-mask-1.png", "flyer-attack-mask-2.png", "flyer-attack-mask-3.png", "flyer-attack-mask-4.png"},
        ["width"] = 230,
        ["height"] = 266,
        ["line_length"] = 7,
        ["lines_per_file"] = 15,
        ["shift"] = {0.015629, -2.578796}
      },
      ["shadow"] = {
        ["files"] = {"flyer-attack-shadow-1.png", "flyer-attack-shadow-2.png", "flyer-attack-shadow-3.png"},
        ["width"] = 356,
        ["height"] = 194,
        ["line_length"] = 7,
        ["lines_per_file"] = 21,
        ["shift"] = {3.485281, 0.421985}
      }
    }
  }
}
