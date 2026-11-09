local function get_submarine_list()
    return maraxsis_constants.SUBMARINES
end

local function get_storage()
    return storage
end

remote.add_interface("maraxsis", {
    get_submarine_list = get_submarine_list,
    get_storage = get_storage
})
