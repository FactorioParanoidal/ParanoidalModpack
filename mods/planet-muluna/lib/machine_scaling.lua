local Public = {}

function Public.scale_entity(objects,ratio)
    --Scale up all of the graphics fields(There are many of them)
    for _,scalar_field in pairs({"scale","rocket_render_layer_switch_distance","full_render_layer_switch_distance","rocket_above_wires_slice_offset_from_center","rocket_air_object_slice_offset_from_center","rocket_visible_distance_from_center"}) do
        Muluna.rro.deep_replace_field(objects,scalar_field,function(old_scale) return old_scale * ratio end)
    end
    for _,vector_field in pairs({"shift","rocket_rise_offset","rocket_initial_offset","rocket_launch_offset","door_back_open_offset","door_front_open_offset","position","alt_position"}) do
        Muluna.rro.deep_replace_field(objects,vector_field,function(old_shift) return {(old_shift[1] or old_shift.x )*ratio,(old_shift[2] or old_shift.y)*ratio} end)
    end
    for _,box_field in pairs({"hole_clipping_box"}) do
        Muluna.rro.deep_replace_field(objects,box_field,function(old) return {left_top = {old[1][1]*ratio,old[1][2]*ratio}, right_bottom = {old[2][1]*ratio,old[2][2]*ratio}, orientation = old.orientation} end)
    end
    
end

return Public