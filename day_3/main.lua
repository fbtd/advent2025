local result_step_1 = 0
local result_step_2 = 0

-- return the index and value of the leftmost max element of `t` between `left` and `right`
local function max_between(t, left, right)
    local max, max_i = t[left], left
    while left <= right do
        if t[left] > max then
            max = t[left]
            max_i = left
        end
        left = left + 1
    end
    return max_i, max
end

local function get_joltage(t, n)
    local result = 0
    local left_i = 1
    for right_i = n, 1, -1 do
        local max = 0
        left_i, max = max_between(t, left_i, #t - right_i + 1)
        result = result + max * 10 ^ (right_i - 1)
        left_i = left_i + 1
    end
    return math.tointeger(result)
end

for l in io.stdin:lines() do
    -- TODO use iterator magic :3
    local line = table.pack(l:byte(1, #l))
    for index, value in ipairs(line) do
        line[index] = string.char(value)
    end

    result_step_1 = result_step_1 + get_joltage(line, 2)
    result_step_2 = result_step_2 + get_joltage(line, 12)
end



print("result step 1:", result_step_1)
print("result step 2:", result_step_2)
