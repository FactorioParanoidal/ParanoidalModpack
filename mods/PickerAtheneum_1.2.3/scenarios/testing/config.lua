local config = {}

config.width = (32 * 2) * 10
config.height = (32 * 2) * 10
config.starting_area = (32) * 4

config.items = {
    ['ee-infinity-chest'] = 50,
    ['ee-infinity-pipe'] = 50,
    ['ee-infinity-heat-interface'] = 50,
    ['ee-infinity-accumulator'] = 50,
    ['construction-robot'] = 50,
    ['pipe'] = 100,
    ['fast-inserter'] = 50,
    ['ammo-nano-constructors'] = 100,
    ['ammo-nano-termites'] = 100
}

config.weapons = {
    ['gun-nano-emitter'] = 1,
}

config.equipment = {
    'ee-infinity-fusion-reactor-equipment',
    'ee-super-personal-roboport-equipment',
    'belt-immunity-equipment'
}

config.bpstring =
    [[
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
]]

config.map_exchange_string =
    [[
>>>eNpjZEAAexDBwZKcn5gD44ForuT8goLUIt38olRkYc7kotKUV
N38TFTFqXmpuZW6SYnFSIob7Dkyi/Lz0E1gLS7Jz0MVKSlKTS1G1
shdWpSYl1mai66XgdHmVIhoAxNQDRD/r2dQ+P8fhIGsB0B5EGZgb
ACZwMAIFIMB1uSczLQ0BgYFRyB2AkkzMjJWi6xzf1g1xZ4RokbPA
cr4ABU5kAQT8YQx/BxwSqnAGCZI5hiDwWckBsTSEqAVUFUcDggGR
LIFJMnI2Pt264Lvxy7YMf5Z+fGSb1KCPaOhq8i7D0br7ICS7CB/M
sGJWTNBYCfMKwwwMx/YQ6Vu2jOePQMCb+wZWUE6RECEgwWQOODNz
MAowAdkLegBEgoyDDCn2cGMEXFgTAODbzCfPIYxLtuj+wMYEDYgw
+VAxAkQAbYQ7jJGCNOh34HRQR4mK4lQAtRvxIDshhSED0/CrD2MZ
D+aQzAjAtkfaCIqDliigQtkYQqceMEMdw0wPC+ww3gO8x0YmUEMk
KovQDEIDyQDMwpCCzgwI2W3D/YMuY/jpgEAnlyRYA==<<<
]]

return config
