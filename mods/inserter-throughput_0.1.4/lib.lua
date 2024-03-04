local function get_stack_size(inserter, prototype)
    local stack_size = inserter.inserter_stack_size_override
    if stack_size > 0 then
        return stack_size
    end
    if prototype.stack then
        return 1 + prototype.inserter_stack_size_bonus + inserter.force.stack_inserter_capacity_bonus
    end
    return 1 + prototype.inserter_stack_size_bonus + inserter.force.inserter_stack_size_bonus
end

return {
    get_stack_size = get_stack_size,
}
