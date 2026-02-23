data:extend {
    {
        type = 'bool-setting',
        name = 'picker-tool-tape-measure',
        setting_type = 'startup',
        default_value = true,
        order = 'a-a'
    },
    {
        type = "bool-setting",
        name = "picker-planner-sorter",
        setting_type = "startup",
        default_value = true,
        order = "a-b"
    },
    {
        type = "int-setting",
        name = "picker-planner-height",
        setting_type = "runtime-per-user",
        default_value = 220,	-- this value is in pixels
        minimum_value = 110,	-- the old default, way too small
        maximum_value = 1080,	-- not sure if this should technically be reduced
        order = "a-c-a"
    },
    {
        type = "int-setting",
        name = "picker-planner-width",
        setting_type = "runtime-per-user",
        default_value = 8,		-- this value is in columns
        minimum_value = 6,		-- the old default, way too small
        maximum_value = 32,		-- not sure if this should technically be reduced
        order = "a-c-b"
    },
    {
        type = 'bool-setting',
        name = 'picker-remember-planner',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a[Picker]-d[Planner]-a'
    },
    {
        type = 'int-setting',
        name = 'picker-tape-measure-clamp',
        setting_type = 'runtime-per-user',
        default_value = 4,
        minimum_value = 0,
        maximum_value = 10,
        order = 'a[Picker]-d[Planner]-c'
    },
}
