-- Vibecoded in ChatGPT
local vector = {}

-- Scalar multiplication: multiplies each element of the vector by a scalar
function vector.scalar_times(v, scalar)
    local result = {}
    for i = 1, #v do
        result[i] = v[i] * scalar
    end
    return result
end

-- Scalar addition: adds a scalar to each element of the vector
function vector.scalar_add(v, scalar)
    local result = {}
    for i = 1, #v do
        result[i] = v[i] + scalar
    end
    return result
end

-- Scalar addition: adds two vectors together elementwise
function vector.element_add(v, v2)
    assert(#v == #v2,"Vectors must have an equal length.")
    local result = {}
    for i = 1, #v do
        result[i] = v[i] + v2[i]
    end
    return result
end

-- Scalar addition: adds two vectors together
function vector.vector_average(v, v2)
    assert(#v == #v2,"Vectors must have an equal length.")
    local result = {}
    for i = 1, #v do
        result[i] = (v[i] + v2[i]) / 2
    end
    return result
end

-- Scalar addition: adds two vectors together, assertion skipped for performance
function vector.vector_average_unsafe(v, v2)
    local result = {}
    for i = 1, #v do
        result[i] = (v[i] + v2[i]) / 2
    end
    return result
end




-- Dot product: sum of element-wise multiplications
function vector.dot(v1, v2)
    assert(#v1 == #v2, "Vectors must be the same length")
    local sum = 0
    for i = 1, #v1 do
        sum = sum + v1[i] * v2[i]
    end
    return sum
end

-- Cross product: only defined for 3D vectors
function vector.cross(v1, v2)
    assert(#v1 == 3 and #v2 == 3, "Cross product only defined for 3D vectors")
    return {
        v1[2] * v2[3] - v1[3] * v2[2],
        v1[3] * v2[1] - v1[1] * v2[3],
        v1[1] * v2[2] - v1[2] * v2[1]
    }
end

return vector