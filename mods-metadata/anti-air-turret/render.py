"""Build and render the anti-air turret in Blender 4.5 (no external model).

blender --background --threads 6 --python render.py -- --output DIR [--preview]
World +Y is north; the turret turns clockwise, matching Factorio directions.
"""
import argparse
import math
from pathlib import Path
import random
import sys

import bpy
from mathutils import Vector


parser = argparse.ArgumentParser()
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--preview", action="store_true")
args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:])
args.output.mkdir(parents=True, exist_ok=True)
random.seed(12)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 32
scene.cycles.use_denoising = True
scene.render.threads_mode = "FIXED"
scene.render.threads = 6
scene.render.resolution_x = scene.render.resolution_y = 320
scene.render.resolution_percentage = 100
scene.render.film_transparent = True
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.render.image_settings.color_depth = "8"
scene.render.image_settings.compression = 85
scene.view_settings.view_transform = "AgX"
scene.view_settings.look = "AgX - Medium High Contrast"
scene.world.color = (0.42, 0.42, 0.42)
scene.use_nodes = True
nodes = scene.node_tree.nodes
nodes.clear()
layers = nodes.new("CompositorNodeRLayers")
composite = nodes.new("CompositorNodeComposite")
scene.node_tree.links.new(layers.outputs["Image"], composite.inputs[0])
scene.view_layers[0].use_pass_material_index = True
index_mask = nodes.new("CompositorNodeIDMask")
index_mask.index = 1
index_mask.use_antialiasing = True
scene.node_tree.links.new(layers.outputs["IndexMA"], index_mask.inputs[0])
set_alpha = nodes.new("CompositorNodeSetAlpha")
scene.node_tree.links.new(layers.outputs["Image"], set_alpha.inputs[0])
scene.node_tree.links.new(index_mask.outputs[0], set_alpha.inputs[1])
mask_output = nodes.new("CompositorNodeOutputFile")
mask_output.base_path = str(args.output)
mask_output.format.file_format = "PNG"
mask_output.format.color_mode = "RGBA"
scene.node_tree.links.new(set_alpha.outputs[0], mask_output.inputs[0])


def material(name, color, metallic=0.4, roughness=0.5):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    noise = mat.node_tree.nodes.new("ShaderNodeTexNoise")
    noise.inputs["Scale"].default_value = 75
    variation = mat.node_tree.nodes.new("ShaderNodeMixRGB")
    variation.blend_type = "MULTIPLY"
    variation.inputs[0].default_value = 0.24
    variation.inputs[1].default_value = (*color, 1)
    mat.node_tree.links.new(noise.outputs["Fac"], variation.inputs[2])
    mat.node_tree.links.new(variation.outputs[0], shader.inputs["Base Color"])
    bump = mat.node_tree.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.15
    bump.inputs["Distance"].default_value = 0.012
    mat.node_tree.links.new(noise.outputs["Fac"], bump.inputs["Height"])
    mat.node_tree.links.new(bump.outputs["Normal"], shader.inputs["Normal"])
    return mat


steel = material("Light cast steel", (0.44, 0.48, 0.47), 0.65, 0.4)
olive = material("Pale olive paint", (0.34, 0.37, 0.25), 0.25, 0.55)
edge = material("Machined edges", (0.61, 0.64, 0.62), 0.8, 0.3)
dark = material("Gunmetal", (0.12, 0.15, 0.16), 0.7, 0.4)
black = material("Recesses", (0.018, 0.023, 0.025), 0.2, 0.7)
brass = material("Brass", (0.46, 0.28, 0.08), 0.7, 0.45)
accent = material("Tier panels", (0.82, 0.82, 0.82), 0.15, 0.5)
# Tier color is changed for icons; sprite masks use neutral paint.
accent.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (0.82, 0.82, 0.82, 1)
for link in list(accent.node_tree.links):
    if link.to_socket == accent.node_tree.nodes.get("Principled BSDF").inputs["Base Color"]:
        accent.node_tree.links.remove(link)
accent.pass_index = 1
shadow_mat = bpy.data.materials.new("Projected shadow")
shadow_mat.use_nodes = True
shadow_nodes = shadow_mat.node_tree.nodes
shadow_nodes.clear()
shadow_out = shadow_nodes.new("ShaderNodeOutputMaterial")
shadow_emission = shadow_nodes.new("ShaderNodeEmission")
shadow_emission.inputs["Color"].default_value = (0, 0, 0, 1)
shadow_mat.node_tree.links.new(shadow_emission.outputs[0], shadow_out.inputs[0])
palette = [(0.9, 0.60, 0.055), (0.73, 0.095, 0.07), (0.065, 0.36, 0.78)]
base_objects, upper_objects = [], []


def empty(name, location=(0, 0, 0), parent=None):
    obj = bpy.data.objects.new(name, None)
    scene.collection.objects.link(obj)
    obj.location = location
    obj.parent = parent
    return obj


yaw = empty("Azimuth")
pitch = empty("Elevation", (0, 0, 0.94), yaw)
recoil = empty("Recoil", parent=pitch)


def finish(obj, name, mat, parent, group, bevel=0):
    obj.name = name
    obj.parent = parent
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Rounded machining", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        normals = obj.modifiers.new("Face normals", "WEIGHTED_NORMAL")
        normals.keep_sharp = True
    for face in obj.data.polygons:
        face.use_smooth = len(face.vertices) == 4 and obj.type == "MESH" and name.startswith("Round")
    group.append(obj)
    return obj


def box(name, location, size, mat=steel, parent=yaw, group=upper_objects, bevel=0.018):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, mat, parent, group, bevel)


def cylinder(name, location, radius, depth, mat=steel, parent=yaw, group=upper_objects, axis="Z", vertices=40):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    if axis == "X":
        obj.rotation_euler[1] = math.pi / 2
    elif axis == "Y":
        obj.rotation_euler[0] = math.pi / 2
    return finish(obj, "Round " + name, mat, parent, group, min(0.012, radius * 0.15))


def tube(name, start, end, radius, mat=dark, parent=yaw, group=upper_objects):
    delta = Vector(end) - Vector(start)
    obj = cylinder(name, (Vector(start) + Vector(end)) / 2, radius, delta.length, mat, parent, group)
    obj.rotation_euler = delta.to_track_quat("Z", "Y").to_euler()
    return obj


def ring(name, location, radius, thickness, depth, mat, parent, group, axis="Z"):
    # Open bores remain actual holes in every view.
    vertices, faces = [], []
    count = 48
    for z in (-depth / 2, depth / 2):
        for r in (radius, radius - thickness):
            vertices.extend((r * math.cos(i * math.tau / count), r * math.sin(i * math.tau / count), z) for i in range(count))
    for i in range(count):
        j = (i + 1) % count
        faces.extend([(i, j, 2 * count + j, 2 * count + i),
                      (count + j, count + i, 3 * count + i, 3 * count + j),
                      (i, count + i, count + j, j),
                      (2 * count + j, 3 * count + j, 3 * count + i, 2 * count + i)])
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    obj.location = location
    if axis == "Y":
        obj.rotation_euler[0] = math.pi / 2
    return finish(obj, name, mat, parent, group, 0.004)


# Grounded circular plinth, ribs, service plates and anchor bolts.
cylinder("Foot", (0, 0, 0.055), 0.92, 0.11, dark, None, base_objects, vertices=64)
cylinder("Foundation", (0, 0, 0.19), 0.86, 0.25, steel, None, base_objects, vertices=64)
cylinder("Deck", (0, 0, 0.34), 0.83, 0.09, edge, None, base_objects, vertices=64)
ring("Deck tier ring", (0, 0, 0.395), 0.78, 0.13, 0.035, accent, None, base_objects)
cylinder("Traverse race", (0, 0, 0.405), 0.58, 0.08, dark, None, base_objects, vertices=64)
for i in range(24):
    angle = i * math.tau / 24
    rib = box("Foundation rib", (0.85 * math.cos(angle), 0.85 * math.sin(angle), 0.20), (0.13, 0.055, 0.27), steel, None, base_objects, 0.009)
    rib.rotation_euler[2] = angle
    cylinder("Deck bolt", (0.73 * math.cos(angle), 0.73 * math.sin(angle), 0.425), 0.023, 0.025, dark, None, base_objects, vertices=6)

# Open traversing platform and two trunnion supports.
cylinder("Traverse plate", (0, 0, 0.47), 0.56, 0.09, olive)
for x in (-0.43, 0.43):
    box("Support foot", (x, 0, 0.53), (0.17, 0.67, 0.11), accent)
    support = box("Trunnion support", (x, -0.075, 0.73), (0.115, 0.21, 0.45), olive)
    support.rotation_euler[0] = -0.16
    cylinder("Elevation bearing", (x, 0, 0.94), 0.16, 0.16, accent, axis="X")
    cylinder("Bearing cap", (x * 1.22, 0, 0.94), 0.105, 0.055, edge, axis="X")
    cylinder("Bearing bolt", (x * 1.30, 0, 0.94), 0.045, 0.026, dark, axis="X", vertices=6)
    tube("Lift cylinder", (x, -0.37, 0.55), (x, -0.09, 0.86), 0.045, dark)
    tube("Lift piston", (x, -0.09, 0.86), (x, 0, 0.94), 0.023, edge)

cylinder("Main axle", (0, 0, 0), 0.105, 1.03, dark, pitch, axis="X")
box("Cradle", (0, -0.08, 0), (0.74, 0.42, 0.14), olive, pitch)
for x in (-0.25, 0.25):
    for z in (-0.19, 0.19):
        box("Receiver", (x, 0.02, z), (0.24, 0.59, 0.23), steel, recoil)
        box("Receiver top cover", (x, 0.025, z + 0.125), (0.195, 0.40, 0.035), olive, recoil, bevel=0.008)
        for y in (-0.13, 0.18):
            cylinder("Cover screw", (x, y, z + 0.15), 0.018, 0.015, edge, recoil, vertices=6)
        tube("Breech", (x, -0.40, z), (x, -0.25, z), 0.065, dark, recoil)
        tube("Barrel jacket", (x, 0.29, z), (x, 0.69, z), 0.063, dark, recoil)
        tube("Barrel", (x, 0.64, z), (x, 1.77, z), 0.038, dark, recoil)
        for y in (0.34, 0.57, 0.70, 1.65):
            cylinder("Barrel collar", (x, y, z), 0.051, 0.06, edge, recoil, axis="Y")
        ring("Open muzzle", (x, 1.795, z), 0.058, 0.018, 0.12, dark, recoil, upper_objects, "Y")
        # A recessed black disk makes the bore readable at inventory size.
        cylinder("Bore", (x, 1.755, z), 0.037, 0.005, black, recoil, axis="Y")

for x in (-0.56, 0.56):
    shield = box("Side shield", (x, 0.15, 0.11), (0.055, 0.62, 0.51), olive, pitch)
    shield.rotation_euler[1] = -math.copysign(0.12, x)
    box("Shield tier stripe", (x * 1.04, 0.13, 0.22), (0.018, 0.55, 0.16), accent, pitch, bevel=0.006)
    box("Shield bright rim", (x, 0.15, 0.38), (0.065, 0.65, 0.035), edge, pitch, bevel=0.008)
    box("Ammo box", (x * 0.82, -0.43, 0.66), (0.28, 0.30, 0.31), olive)
    box("Ammo tier lid", (x * 0.82, -0.43, 0.83), (0.30, 0.32, 0.045), accent)
    for y in (-0.51, -0.36):
        box("Ammo latch", (x * 0.82, y, 0.86), (0.11, 0.024, 0.028), edge, bevel=0.005)
    for offset in range(5):
        tube("Feed cartridge", (x * 0.75, -0.30 + offset * 0.045, 0.74), (x * 0.75 + 0.08, -0.30 + offset * 0.045, 0.74), 0.017, brass)

# Recessed panels, exposed drives and feed hardware break up large flat surfaces.
for x in (-0.25, 0.25):
    for z in (-0.19, 0.19):
        box("Receiver dark seam", (x, -0.085, z + 0.123), (0.19, 0.018, 0.012), black, recoil, bevel=0.003)
        box("Receiver latch", (x, -0.085, z + 0.149), (0.055, 0.043, 0.025), edge, recoil, bevel=0.004)
        for y in (0.06, 0.11, 0.16):
            box("Receiver cooling slot", (x + math.copysign(0.122, x), y, z), (0.006, 0.023, 0.11), black, recoil, bevel=0.002)
    for y in (-0.45, -0.40):
        box("Ammo box band", (x * 1.84, y, 0.66), (0.285, 0.024, 0.31), steel, bevel=0.005)
    tube("Rear cradle brace", (x * 1.7, -0.36, 0.56), (x * 1.7, -0.10, 0.88), 0.025, edge)
    for y in (-0.05, 0.32):
        cylinder("Shield corner bolt", (x * 2.24, y, 0.35), 0.019, 0.04, dark, pitch, axis="X", vertices=6)

box("Traverse motor", (0, -0.40, 0.64), (0.27, 0.26, 0.25), dark)
box("Motor service cover", (0, -0.54, 0.66), (0.24, 0.035, 0.20), steel)
for x in (-0.07, -0.035, 0, 0.035, 0.07):
    box("Motor cooling slot", (x, -0.562, 0.66), (0.013, 0.01, 0.12), black, bevel=0.002)
for i in range(36):
    a = i * math.tau / 36
    tooth = box("Traverse gear tooth", (0.57 * math.cos(a), 0.57 * math.sin(a), 0.445), (0.042, 0.042, 0.035), dark, None, base_objects, 0.003)
    tooth.rotation_euler[2] = a

for side in (-1, 1):
    points = [(side * 0.29, -0.36, 0.68), (side * 0.32, -0.45, 0.72),
              (side * 0.28, -0.48, 0.87), (side * 0.22, -0.40, 0.98)]
    for start, end in zip(points, points[1:]):
        tube("Flexible feed conduit", start, end, 0.027, black)
        for step in range(4):
            p = Vector(start).lerp(Vector(end), step / 4)
            q = Vector(start).lerp(Vector(end), (step + 0.30) / 4)
            tube("Conduit rib", p, q, 0.032, dark)

camera_data = bpy.data.cameras.new("Orthographic camera")
camera = bpy.data.objects.new("Orthographic camera", camera_data)
scene.collection.objects.link(camera)
camera.location = (0, -10, 10)
camera.rotation_euler = (Vector((0, 0, 0)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera_data.type = "ORTHO"
camera_data.ortho_scale = 5.6
scene.camera = camera


def area_light(name, location, energy, size):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = energy
    data.shape = "DISK"
    data.size = size
    obj = bpy.data.objects.new(name, data)
    scene.collection.objects.link(obj)
    obj.location = location
    obj.rotation_euler = (-obj.location).to_track_quat("-Z", "Y").to_euler()


area_light("Key upper left", (-3, -4, 8), 1150, 4)
area_light("Soft fill", (4, 1, 5), 650, 5)
area_light("Back edge", (-1, 5, 5), 450, 4)


def show(group, visible):
    for obj in group:
        obj.hide_render = not visible


def render(name, mask=False):
    scene.render.filepath = str(args.output / (name + ".png"))
    mask_output.mute = not mask
    mask_output.file_slots[0].path = name + "-mask-"
    bpy.ops.render.render(write_still=True)
    if mask:
        (args.output / (name + "-mask-0001.png")).rename(args.output / (name + "-mask.png"))
    print("AA_RENDER " + name, flush=True)


def elevation(degrees):
    pitch.rotation_euler[0] = math.radians(degrees)


def tier_color(tier):
    accent.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (*palette[tier - 1], 1)


def shadow(group, name):
    show(base_objects + upper_objects, False)
    bpy.context.view_layer.update()
    depsgraph = bpy.context.evaluated_depsgraph_get()
    projected = []
    for source in group:
        evaluated = source.evaluated_get(depsgraph)
        mesh = bpy.data.meshes.new_from_object(evaluated)
        for vertex in mesh.vertices:
            world = source.matrix_world @ vertex.co
            vertex.co = (world.x + world.z * 0.42, world.y + world.z * 0.48, 0)
        obj = bpy.data.objects.new("Shadow projection", mesh)
        scene.collection.objects.link(obj)
        mesh.materials.clear()
        mesh.materials.append(shadow_mat)
        projected.append(obj)
    old_samples = scene.cycles.samples
    scene.cycles.samples = 1
    scene.cycles.use_denoising = False
    render(name)
    scene.cycles.samples = old_samples
    scene.cycles.use_denoising = True
    for obj in projected:
        bpy.data.objects.remove(obj, do_unlink=True)


elevation(27)
yaw.rotation_euler[2] = -math.pi / 4
if args.preview:
    scene.render.resolution_x = scene.render.resolution_y = 768
    scene.cycles.samples = 48
    tier_color(1)
    render("preview")
else:
    # The blend file is editable source, not a dependency of the game.
    bpy.ops.wm.save_as_mainfile(filepath=str(args.output / "anti-air-turret.blend"))
    for tier in range(1, 4):
        tier_color(tier)
        show(upper_objects, False)
        render(f"base-{tier}")
    shadow(base_objects, "base-shadow")
    accent.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (0.82, 0.82, 0.82, 1)
    for direction in range(64):
        yaw.rotation_euler[2] = -math.tau * direction / 64
        elevation(27)
        for frame in range(2):
            recoil.location.y = -0.065 * frame
            show(base_objects, False)
            show(upper_objects, True)
            render(f"shoot-{direction * 2 + frame:03}", mask=True)
            shadow(upper_objects, f"shoot-shadow-{direction * 2 + frame:03}")
    recoil.location.y = 0
    for direction in range(4):
        yaw.rotation_euler[2] = -math.tau * direction / 4
        for frame in range(6):
            elevation(8 + 19 * frame / 5)
            show(base_objects, False)
            show(upper_objects, True)
            render(f"raise-{direction * 6 + frame:02}", mask=True)
            shadow(upper_objects, f"raise-shadow-{direction * 6 + frame:02}")
    show(base_objects + upper_objects, True)
    yaw.rotation_euler[2] = -math.pi / 4
    elevation(27)
    scene.render.resolution_x = scene.render.resolution_y = 512
    camera_data.ortho_scale = 3.35
    camera.location = (0, -10, 10.7)
    camera.rotation_euler = (Vector((0.25, 0.28, 0.9)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.cycles.samples = 96
    for tier in range(1, 4):
        tier_color(tier)
        render(f"icon-{tier}")
