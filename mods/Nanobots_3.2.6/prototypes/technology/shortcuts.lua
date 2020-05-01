-- Enable all construction-robotic shortcuts

for _, shortcut in pairs(data.raw['shortcut']) do
    if shortcut.technology_to_unlock == "construction-robotics" then
        shortcut.technology_to_unlock = "nanobots"
    end
end
