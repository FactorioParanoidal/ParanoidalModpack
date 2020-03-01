-- "name": "belt-legacy",
-- "title": "Belt Legacy",
-- "author": "fishycat",
-- "description": "Tired of accidentally replacing underground-belts and splitters with transport-belts? Then this small mod is for you. When activated they can't fast-replace each other anymore. For a safer bus building. For Vanilla and for Bob's basic, green and purple belt stuff.",

if settings.startup['picker-legacy-belt-fast-replace'].value then
    for _, splitter in pairs(data.raw['splitter']) do
        splitter.fast_replaceable_group = 'splitter'
    end
    for _, ug in pairs(data.raw['underground-belt']) do
        ug.fast_replaceable_group = 'underground-belt'
    end
end
