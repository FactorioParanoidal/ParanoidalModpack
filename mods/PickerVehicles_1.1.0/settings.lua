data:extend {
    {
        type = 'bool-setting',
        name = 'picker-naked-rails',
        setting_type = 'startup',
        default_value = true,
        order = '[startup]-z-[naked-rails]'
    },
    {
        type = 'bool-setting',
        name = 'picker-better-lights-cars',
        setting_type = 'startup',
        default_value = true,
        order = '[startup]-z-[better-car-lights]'
    },
    {
        type = 'bool-setting',
        name = 'picker-better-lights-trains',
        setting_type = 'startup',
        default_value = true,
        order = '[startup]-z-[better-train-lights]'
    },
    {
        type = 'bool-setting',
        name = 'picker-unstoppable-trains',
        setting_type = 'startup',
        default_value = false,
        order = '[startup]-z-[unstoppable-trains]'
    }
}

data:extend {
     {
        type = "int-setting",
        name = "picker-manual-withplayer-penalty",
        setting_type = "startup",
        default_value = 2000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-a'
     },
     {
        type = "int-setting",
        name = "picker-manual-noplayer-penalty",
        setting_type = "startup",
        default_value = 7000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-b'
     },
     {
        type = "int-setting",
        name = "picker-circuit-penalty",
        setting_type = "startup",
        default_value = 1000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-c'
     },
     {
        type = "int-setting",
        name = "picker-trainstop-penalty",
        setting_type = "startup",
        default_value = 2000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-d'
     },
     {
        type = "int-setting",
        name = "picker-arriving-stop-penalty",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-e'
     },
     {
        type = "int-setting",
        name = "picker-train-waitstation-penalty",
        setting_type = "startup",
        default_value = 500,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-f'
     },
     {
        type = "int-setting",
        name = "picker-train-waitstation-nostops-penalty",
        setting_type = "startup",
        default_value = 1000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-g'
     },

     {
        type = "int-setting",
        name = "picker-arriving-signal-penalty",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-h'
     },
     {
        type = "int-setting",
        name = "picker-waiting-signal-penalty",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-i'
     },
     {
        type = "double-setting",
        name = "picker-waiting-at-signal-multiplier",
        setting_type = "startup",
        default_value = 0.1,
        minimum_value = 0,
        maximum_value = 100,
        order = '[startup]-a-[penalty]-j'
      },
     {
        type = "int-setting",
        name = "picker-no-path-penalty",
        setting_type = "startup",
        default_value = 1000,
        minimum_value = 0,
        maximum_value = 60000,
        order = '[startup]-a-[penalty]-k'
      },
      {
        type = "double-setting",
        name = "picker-temporary-stop-wait-time",
        setting_type = "startup",
        default_value = 60 * 5,
        minimum_value = 0,
        maximum_value = 100000000,
        order = '[startup]-b-[conditon]-a'
      },
      {
        type = "double-setting",
        name = "picker-wait-condition-default",
        setting_type = "startup",
        default_value = 60 * 30,
        minimum_value = 0,
        maximum_value = 100000000,
        order = '[startup]-b-[conditon]-b'
      },
      {
        type = "double-setting",
        name = "picker-inactivity-wait-condition-default",
        setting_type = "startup",
        default_value = 60 * 5,
        minimum_value = 0,
        maximum_value = 100000000,
        order = '[startup]-b-[conditon]-c'
      },
}

data:extend {
    {
        type = 'bool-setting',
        name = 'picker-train-honk',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'picker-honk-a'
    },
    {
        type = 'string-setting',
        name = 'picker-train-honk-type',
        setting_type = 'runtime-global',
        default_value = 'deltic',
        allowed_values = {'deltic', 'train'},
        order = 'picker-honk-ab'
    },
    {
        type = 'bool-setting',
        name = 'picker-train-honk-attract',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'picker-honk-ac'
    }
}

data:extend {
    {
        type = 'bool-setting',
        name = 'picker-auto-manual-train',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-e[automatic-trains]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-manual-train-keys',
        setting_type = 'startup',
        default_value = true,
        order = '[startup]-e-[automatic-trains]-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-get-out-of-the-way',
        setting_type = 'runtime-global',
        default_value = false,
        order = '[startup]-e-[automatic-trains]-c'
    }
}
