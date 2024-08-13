_table.each(data.raw["train-stop"],
    function(train_stop_prototype)
        train_stop_prototype.collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } }
        train_stop_prototype.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
    end)
_table.each(data.raw["locomotive"], function(rolling_stock)
    rolling_stock.connection_distance = 4.9
    rolling_stock.joint_distance = 2.75
    rolling_stock.collision_box = { { -1, -2 }, { 1, 1.7 } }
    rolling_stock.selection_box = { { -1, -2.5 }, { 1, 3 } }
    rolling_stock.drawing_box = { { -1, -4 }, { 1, 2.5 } }
end)
_table.each(data.raw["cargo-wagon"], function(rolling_stock)
    rolling_stock.connection_distance = 4.6
    rolling_stock.joint_distance = 3
    rolling_stock.collision_box = { { -1, -2.3 }, { 1, 2.3 } }
    rolling_stock.selection_box = { { -1, -2.5 }, { 1, 3.5 } }
    rolling_stock.drawing_box = { { -1, -4 }, { 1, 2.5 } }
end)
_table.each(data.raw["fluid-wagon"], function(rolling_stock)
    rolling_stock.connection_distance = 4.6
    rolling_stock.joint_distance = 3
    rolling_stock.collision_box = { { -1, -2.3 }, { 1, 2.3 } }
    rolling_stock.selection_box = { { -1, -2.5 }, { 1, 3.5 } }
    rolling_stock.drawing_box = { { -1, -4 }, { 1, 2.5 } }
end)
_table.each(data.raw["artillery-wagon"], function(rolling_stock)
    rolling_stock.connection_distance = 4.6
    rolling_stock.joint_distance = 3
    rolling_stock.collision_box = { { -1, -2.3 }, { 1, 2.3 } }
    rolling_stock.selection_box = { { -1, -2.5 }, { 1, 3.5 } }
    rolling_stock.drawing_box = { { -1, -4 }, { 1, 2.5 } }
end)
_table.each(data.raw["gate"], function(gate)
    gate.activation_distance = 0.15
end)
