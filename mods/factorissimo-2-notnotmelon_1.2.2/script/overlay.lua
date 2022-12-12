Overlay = {}

local function build_display_upgrade(factory)
	if not factory.force.technologies['factory-interior-upgrade-display'].researched then return end
	if factory.inside_overlay_controller and factory.inside_overlay_controller.valid then return end

	local pos = factory.layout.overlays
	local controller = factory.inside_surface.create_entity{
		name = 'factory-overlay-controller',
		position = {
			factory.inside_x + pos.inside_x,
			factory.inside_y + pos.inside_y
		},
		force = factory.force
	}
	controller.minable = false
	controller.destructible = false
	controller.rotatable = false
	factory.inside_overlay_controller = controller
end
Overlay.build_display_upgrade = build_display_upgrade

local sprite_path_translation = {
	item = 'item',
	fluid = 'fluid',
	virtual = 'virtual-signal',
}
local function draw_overlay_sprite(signal, target_entity, offset, scale, id_table)
	local sprite_name = sprite_path_translation[signal.type] .. '/' .. signal.name
	if target_entity.valid then
		local sprite_data = {
			sprite = sprite_name,
			x_scale = scale,
			y_scale = scale,
			target = target_entity,
			surface = target_entity.surface,
			only_in_alt_mode = true,
			render_layer = 'entity-info-icon',
		}
		-- Fake shadows
		local shadow_radius = 0.07 * scale
		for _, shadow_offset in pairs({{0,shadow_radius}, {0, -shadow_radius}, {shadow_radius, 0}, {-shadow_radius, 0}}) do
			sprite_data.tint = {0, 0, 0, 0.5} -- Transparent black
			sprite_data.target_offset = {offset[1] + shadow_offset[1], offset[2] + shadow_offset[2]}
			table.insert(id_table, rendering.draw_sprite(sprite_data))
		end
		-- Proper sprite
		sprite_data.tint = nil
		sprite_data.target_offset = offset
		table.insert(id_table, rendering.draw_sprite(sprite_data))
	end
end

local function get_nice_overlay_arrangement(width, height, amount)
	-- Computes a nice arrangement of square sprites within a rectangle of given size
	-- Returned coordinates are relative to the center of the rectangle
	if amount <= 0 then return {} end
	local opt_rows = 1
	local opt_cols = 1
	local opt_scale = 0
	-- Determine the optimal number of rows to use
	-- This assumes width >= height
	for rows = 1, math.ceil(math.sqrt(amount)) do
		local cols = math.ceil(amount/rows)
		local scale = math.min(width/cols, height/rows)
		if scale > opt_scale then
			opt_rows = rows
			opt_cols = cols
			opt_scale = scale
		end
	end
	-- Adjust scale to ensure that sprites do not become too big
	opt_scale = (opt_scale ^ 0.8) * (1.5 ^ (0.8 - 1))
	-- Create evenly spaced coordinates
	local result = {}
	for i = 0, amount-1 do
		local col = i % opt_cols
		local row = math.floor(i / opt_cols)
		local cols_in_row = (row < opt_rows - 1 and opt_cols or (amount - 1) % opt_cols + 1)
		table.insert(result, {
			x = (2 * col + 1 - cols_in_row) * width / (2 * opt_cols),
			y = (2 * row + 1 - opt_rows) * height / (2 * opt_rows),
			scale = opt_scale
		})
	end
	return result
end

local function update_overlay(factory)
	for _, id in pairs(factory.outside_overlay_displays) do
		rendering.destroy(id)
	end
	factory.outside_overlay_displays = {}
	if factory.built and factory.inside_overlay_controller and factory.inside_overlay_controller.valid then
		local params = factory.inside_overlay_controller.get_or_create_control_behavior().parameters
		local nonempty_params = {}
		for _, param in pairs(params) do
			if param and param.signal and param.signal.name then
				table.insert(nonempty_params, param)
			end
		end
		local sprite_positions = get_nice_overlay_arrangement(
			factory.layout.overlays.outside_w,
			factory.layout.overlays.outside_h,
			#nonempty_params
		)
		local i = 0
		for _, param in pairs(nonempty_params) do
			i = i + 1
			draw_overlay_sprite(
				param.signal,
				factory.building,
				{sprite_positions[i].x + factory.layout.overlays.outside_x, sprite_positions[i].y + factory.layout.overlays.outside_y},
				sprite_positions[i].scale,
				factory.outside_overlay_displays
			)
		end
	end
end
Overlay.update_overlay = update_overlay
