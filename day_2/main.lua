local input = io.read()
local result_step_1 = 0
local result_step_2 = 0

local function is_valid_step_1(n)
    local s = string.format("%d", n)
    if #s % 2 ~= 0 then return false end
    return string.sub(s, 1, #s / 2) == string.sub(s, #s / 2 + 1)
end

local function is_valid_step_2(n)
    local s = string.format("%d", n)
    for rep_len = 1, #s // 2 do
        local n_reps = #s / rep_len
        if n_reps % 1 == 0 then
            local sub = string.sub(s, 1, rep_len)
            if string.rep(sub, n_reps) == s then
                return true
            end
        end
    end
    return false
end

for l, r in string.gmatch(input, "(%d+)-(%d+),?") do
    for i = math.tointeger(l), math.tointeger(r) do
        if is_valid_step_1(i) then
            result_step_1 = result_step_1 + i
        end
        if is_valid_step_2(i) then
            result_step_2 = result_step_2 + i
        end
    end
end

print("result step 1:", result_step_1)
print("result step 2:", result_step_2)
