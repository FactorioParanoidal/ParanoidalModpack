if not liborio then liborio = {} end
if not liborio.defines then liborio.defines = {} end
if not liborio.defines.data_stages then liborio.defines.data_stages = {} end
if not liborio.defines.names then liborio.defines.names = {} end
if not liborio.defines.defaults then liborio.defines.defaults = {} end
if not liborio.events then liborio.events = {} end

--[[stages]]
liborio.defines.data_stages.data = "data"
liborio.defines.data_stages.data_final_fixes = "data-final-fixes"
liborio.defines.data_stages.data_updates = "data-updates"
liborio.defines.data_stages.control = "control"

--[[name]]
liborio.defines.names.force_player = "player"
liborio.defines.names.force_enemy = "enemy"
liborio.defines.names.force_neutral = "neutral"
--[[events]]
liborio.events.on_build = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
liborio.events.on_remove = {defines.events.on_entity_died,defines.events.on_robot_pre_mined,defines.events.on_robot_mined_entity,defines.events.on_player_mined_entity}
liborio.events.on_pick_up_item = {defines.events.on_picked_up_item,defines.events.on_player_mined_item,defines.events.on_robot_mined}
--[[priorites]]
liborio.events.low_priority = 44
liborio.events.medium_priority = 30
liborio.events.high_priority = 9