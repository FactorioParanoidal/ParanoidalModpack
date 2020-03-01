local style = data.raw['gui-style'].default

--[Smaller gui borders] --
--Tweak by "Ion's UI Tweaks: Smaller Borders", by "KingIonTrueLove"
-- TODO Fix and re-enable for .17
if settings.startup['picker-smaller-gui-borders'].value and false then
    local quickbar = style.switch_quickbar_button
    quickbar.default_graphical_set.monolith_image.width = 20
    quickbar.default_graphical_set.monolith_image.height = 21

    quickbar.hovered_graphical_set.monolith_image.width = 20
    quickbar.hovered_graphical_set.monolith_image.height = 21
    quickbar.hovered_graphical_set.monolith_image.x = 25

    quickbar.clicked_graphical_set.monolith_image.width = 20
    quickbar.clicked_graphical_set.monolith_image.height = 21
    quickbar.clicked_graphical_set.monolith_image.x = 25

    local qbf = style.quick_bar_frame
    qbf.top_padding = 2

    local tbf = style.tool_bar_frame
    tbf.top_padding = 2

    local flow = style.flow
    flow.horizontal_spacing = 2
    flow.vertical_spacing = 4

    local frame = style.frame
    frame.top_padding = 2
    frame.right_padding = 3
    frame.bottom_padding = 3
    frame.left_padding = 2

    local scroll = style.scroll_pane
    scroll.horizontal_scroll_bar_spacing = 5
    scroll.vertical_scroll_bar_spacing = 3
end

--(( Brighten Cells ))--
-- "name": "Brighten cells",
-- "title": "[Z] Brighten cells",
-- "author": "ZlovreD",
-- "homepage": "https://forums.factorio.com/viewtopic.php?f=144&t=45154",
-- "description": "Makes gui cells for inventory, technology, toolbars a little lighter (like as before)"
if settings.startup['picker-brighter-cell-background'].value then
    local function bluebuttongraphcialset(state)
        local offset = nil
        if state == 'default' then
            offset = {x = 0, y = 0}
        elseif state == 'hovered' then
            offset = {x = 0, y = 36}
        elseif state == 'clicked' then
            offset = {x = 0, y = 72}
        end

        return {
            border = 1,
            filename = '__PickerTweaks__/graphics/lighter_cell.png',
            position = {offset.x, offset.y},
            size = 36,
            scale = 1
        }
    end

    local filter_bg = style['slot_with_filter_button']
    filter_bg.default_graphical_set = bluebuttongraphcialset('default')
    filter_bg.hovered_graphical_set = bluebuttongraphcialset('hovered')
    filter_bg.clicked_graphical_set = bluebuttongraphcialset('clicked')
end
