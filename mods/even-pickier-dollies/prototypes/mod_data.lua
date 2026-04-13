--
-- add a mod-data object to manage the blacklist
--

data:extend({
    {
        type = 'mod-data',
        name = 'even-pickier-dollies',
        data_type = 'even-pickier-dollies',
        data = {
            blacklist_names = {},
        },
    }
})
