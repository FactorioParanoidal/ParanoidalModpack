local function updateDiscoScience()
    local interface = remote.interfaces["DiscoScience"]
    if interface and interface.setLabScale then
        remote.call("DiscoScience", "setLabScale", "big-lab", 5)
    end
end

script.on_init(updateDiscoScience)
script.on_configuration_changed(updateDiscoScience)