local config = {}

config.width = (32 * 6) * 2
config.height = (32 * 6) * 2
config.starting_area = (32) * 2

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

config.weapons = {['gun-nano-emitter'] = 1}

config.equipment = {
    'ee-infinity-fusion-reactor-equipment', 'ee-super-personal-roboport-equipment', 'belt-immunity-equipment'
}

config.bpstring = [[
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
K0yNKHh/8B08zmxw==
]]

config.map_exchange_string = [[
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
