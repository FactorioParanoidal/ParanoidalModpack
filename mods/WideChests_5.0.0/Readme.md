# Merging chests Factorio mod

Since 5.0.0 the mod has support for other contributors to create merged variants of chests they created. This readme is trying to explain this process.

## Adding support for another chest

Create a mod which is dependant on "WideChests >= 5.0.0" and mod with the chest which should be mergable.

### Settings stage

#### MergingChests.create_mergeable_chest_setting

Call `MergingChests.create_mergeable_chest_setting` to register new chest to create mod settings to make the chest mergable.

This function has two arguments:
- `chest_name` (type `string`) - `name` of the chest entity prototype
- `options` (type `object`) - Object for modifying default behaviour. Has following properties
  - `disable_chest` (type `boolean`) - Removes possibility to merge 1xN and Nx1 chests. Defaults to `false`.
  - `disable_warehouse` (type `boolean`) - Removes possibility to merge chests into warehouses. Defaults to `false`.
  - `disable_chest` (type `boolean`) - Removes possibility to merge chests into trashdumps. Defaults to `false`.
  - `default_value` (type `string`) - Default value for the created mod setting. Defaults to maximum not disabled option. Possible values:
    - `none`
    - `chest`
    - `warehouse`
    - `chest-warehouse`
    - `trashdump`
    - `chest-trashdump`
    - `warehouse-trashdump`
    - `chest-warehouse-trashdump`
  - `order` (type `string`) - Used to allow sorting the created mod settings. Final mod setting's `order` will be either `01-{order}-01` or `99-{order}-01` (if there are some custom settings enabled, see below). Defaults to `chest_name` parameter.
  - `size_settings` (type `boolean`) - Creates additional mod settings for setting maximum width, height, area and whitelist specifically for this mergable chest. Defaults to `false`.
  - `inventory_settings` (type `boolean`) - Creates additional mod settings for setting inventory size multiplier and inventory size limit specifically for this mergable chest. Defaults to `false`.
  - `threshold_setting` (type `boolean`) - Creates additional mod setting for warehouse threshold specifically for this mergable chest. Defaults to `false`.
  - `circuit_connection_setting` (type `boolean`) - Creates additional mod setting for circuit connector position specifically for this mergable chest. Defaults to `false`.

Following translations should be provided:
 - [chest-name] WideChests_wide-`chest-name`
   - If `options.disable_chest` was not set
 - [chest-name] WideChests_high-`chest-name`
   - If `options.disable_chest` was not set
 - [chest-name] WideChests_`chest-name`-warehouse
   - If `options.disable_warehouse` was not set
 - [chest-name] WideChests_`chest-name`-trashdump
   - If `options.disable_trashdump` was not set
 - [mod-setting-name] WideChests_mergeable-chest-`chest-name`
 - [mod-setting-name] WideChests_max-chest-width-`chest-name`
   - If `options.size_settings` was set
 - [mod-setting-name] WideChests_max-chest-height-`chest-name`
   - If `options.size_settings` was set
 - [mod-setting-name] WideChests_max-chest-area-`chest-name`
   - If `options.size_settings` was set
 - [mod-setting-name] WideChests_max-chest-area-`chest-name`
   - If `options.size_settings` was set
 - [mod-setting-name] WideChests_whitelist-chest-sizes-`chest-name`
   - If `options.size_settings` was set
 - [mod-setting-name] WideChests_inventory-size-multiplier-`chest-name`
   - If `options.inventory_settings` was set
 - [mod-setting-name] WideChests_inventory-size-limit-`chest-name`
   - If `options.inventory_settings` was set
 - [mod-setting-name] WideChests_warehouse-threshold-`chest-name`
   - If `options.threshold_setting` was set
 - [mod-setting-name] WideChests_circuit-connector-position-`chest-name`
   - If `options.circuit_connection_setting` was set
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-none
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-chest
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-warehouse
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-trashdump
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-chest-warehouse
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-chest-trashdump
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-warehouse-trashdump
 - [string-mod-setting] WideChests_mergeable-chest-`chest-name`-chest-warehouse-trashdump
 - [string-mod-setting] 
 
 And these if `options.circuit_connection_setting` was set:
 WideChests_circuit-connector-position-center-center-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-right-top-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-right-middle-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-right-bottom-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-left-top-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-left-middle-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-left-bottom-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-bottom-right-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-bottom-middle-`chest_name`
 - [string-mod-setting] WideChests_circuit-connector-position-bottom-left-`chest_name`

#### MergingChests.delete_chest_name_settings

Call `MergingChests.delete_chest_name_settings` if your mod removes some vanilla chest.

For example:
```lua
MergingChests.delete_chest_name_settings('wooden-chest')
MergingChests.delete_chest_name_settings('iron-chest')
MergingChests.delete_chest_name_settings('steel-chest')
```

### Data stage

Call `MergingChests.create_mergeable_chest` to create merged chest prototypes.

This function has two arguments:
- `entity_data` (type `object`) - Has following properties:
  - `chest_name` (type `string`) - `name` of the chest entity prototype. Have to be same as one called during setting stage
  - `override_prototype_properties` (type `object`) - Object which will be appended to all merged chest prototypes of this mergable chest. Used to override default properties. Defaults to empty object.
- `segments_data` (type `object`) - Object describing individual segments of the merged chest sprites. See below for more details.

#### Segments data

Segments data object has following properties:

- `wide_segments`
- `high_segments`
- `warehouse_segments`
- `trashdump_segments`

All of them have following properties:

- `entity` - required
- `shadow` - optional

Merged chest sprite is created from individual segments drawn next to each other. This is basic 9-sliced sprite. There are these segments:

- `top_left` - One put into top left corner
- `top` - Many put along top edge
- `top_right` - One put into top right corner
- `left` - Many put along left edge
- `middle` - Many put to fill in the middle of the chest
- `right`- etc.
- `bottom_left`
- `bottom`
- `bottom_right`

There are also these special segments

- `top_center` - One put in the middle of the top edge
- `left_center` - One put in the middle of the left edge
- `center` - One put in the middle of the chest
- `right_center` - etc.
- `bottom_center`

Each segment has following properties:
- `filename` - Required
- `width` - Required
- `height` - Required
- `x`
- `y`
- `frame_count`
- `scale`
- `shift`
- `tint`

To reduce redudancy it is also possible to move required properties from individual segments to the segments collection. The data in individual segments takes precedence.

The properties are the same except `width` and `height`. They are replaced with `widths` (object of `left`, `middle` and `right` properties) and `heights` (object of `top`, `middle` and `bottom`).

Each sprite segment can also be a list of segments instead. Random segment from the list will be taken every time a segment is placed into final sprite.

```lua
local segments = {
    wide_segments = {
        entity = {
            top_left = {
                y = 12
            },
            top = {
                x = 45
                y = 12,
                filename = 'override filename'
            },
            middle = {
                {
                    x = 85,
                    y = 96
                },
                {
                    x = 185,
                    y = 196
                }
            },
            -- other segments

            filename = 'filename used for all segments except "top"',
            widths = {
                left = 45,
                middle = 64,
                right = 85
            },
            heights = {
                top = 81,
                middle = 64,
                bottom = 34
            }
        }
    }
}
```

For more info I'd suggest taking a look at types at the start of `/scripts/sprite_generation.lua`

#### Prepared segment data

There is `MergingChests.steel_chest_segments` which has default segment data for steel chest. Use these if you don't want to bother with custom segment data.

There are also variants for logistic chests in WideChestsLogistic mod:

- `MergingChestsLogistic.passive_provider_chest_segments`
- `MergingChestsLogistic.active_provider_chest_segments`
- `MergingChestsLogistic.storage_chest_segments`
- `MergingChestsLogistic.buffer_chest_segments`
- `MergingChestsLogistic.requester_chest_segments`
