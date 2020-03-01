local not_clampable_pipes = {
    ['4-to-4-pipe'] = true
}

return function(name)
    return (not_clampable_pipes[name] or name:find('dummy%-') or name:find('%[') or name:find('bpproxy'))
end
