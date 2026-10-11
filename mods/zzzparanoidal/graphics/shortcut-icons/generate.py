#!/usr/bin/env python3
"""Build shortcut PNGs with Pillow; run this file from any directory.

Kux: extract the enabled (bottom) row of the original 32/24-pixel sheets
without resizing. Todo: draw simple checklist glyphs on the native pixel grid,
with a 56-pixel toolbar resource (like base shortcuts) and a separate 24-pixel
menu resource. Coordinates are the editable vector source; no enlarged bitmap
or runtime dependency is used. PNGs are committed alongside this generator.
"""

from pathlib import Path

from PIL import Image, ImageDraw


DESTINATION = Path(__file__).resolve().parent
MODS = DESTINATION.parents[2]
KUX_ACTIONS = (
    "flip-h",
    "flip-v",
    "rotate-clockwise",
    "clone-blueprint",
    "wireswap",
    "landfill",
    "remove-landfill",
)


def extract_kux():
    for size in (32, 24):
        source = MODS / "Kux-BlueprintExtensions" / "graphics" / f"shortcut-bar-buttons-{size}.png"
        with Image.open(source) as sheet:
            assert sheet.size == (7 * size, 2 * size), "Kux sheet layout changed"
            for column, action in enumerate(KUX_ACTIONS):
                glyph = sheet.crop((column * size, size, (column + 1) * size, 2 * size))
                glyph.save(DESTINATION / f"kux-{action}-{size}.png", optimize=True)


def draw_todo(size, add_task):
    # The 56px resource is drawn at 2x on a 28px design grid. The menu's 24px
    # resource has its own integer coordinates to keep two-pixel strokes sharp.
    grid = 28 if size == 56 else 24
    scale = size // grid
    image = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(image)
    ink = (27, 27, 27, 255)

    def rectangle(left, top, right, bottom, color=ink):
        draw.rectangle((left * scale, top * scale, right * scale - 1, bottom * scale - 1), fill=color)

    def check(y):
        points = ((5, y), (7, y + 2), (10, y - 2), (11, y - 1), (7, y + 4), (4, y + 1))
        draw.polygon([(x * scale, v * scale) for x, v in points], fill=ink)

    edge = grid - 3
    rectangle(2, 2, edge, 4)
    rectangle(2, 4, 4, edge - 2)
    rectangle(edge - 2, 4, edge, edge - 2)
    rectangle(2, edge - 2, edge, edge)
    for y in ((8, 14, 20) if grid == 28 else (7, 12, 17)):
        check(y)
        rectangle(12, y, edge - 4, y + 2)

    if add_task:
        # Leave a transparent gap around the plus so it stays distinct at 24px.
        start, end, centre = (16, 27, 20) if grid == 28 else (13, 23, 17)
        rectangle(start - 2, start - 2, grid, grid, (0, 0, 0, 0))
        rectangle(centre, start, centre + 3, end)
        rectangle(start, centre, end, centre + 3)

    asset = "todo-add-task" if add_task else "todo-list"
    image.save(DESTINATION / f"{asset}-{size}.png", optimize=True)


if __name__ == "__main__":
    extract_kux()
    for icon_size in (56, 24):
        for is_add_task in (False, True):
            draw_todo(icon_size, is_add_task)
