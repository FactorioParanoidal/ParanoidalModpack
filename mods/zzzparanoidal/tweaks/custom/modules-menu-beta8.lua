-- Rows and recipe icons already match Beta 8; only restore the tab position.
local group = data.raw["item-group"].bobmodules
if group then
    group.order = "b-m"
end
