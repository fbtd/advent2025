local result_step_1 = 0
local result_step_2 = 0

local fresh_ranges = {}

for l in io.stdin:lines() do
    if l == "" then break end
    local left, right = l:match("(%d+)-(%d+)")
    table.insert(fresh_ranges, { tonumber(left), tonumber(right) })
end



for l in io.stdin:lines() do
    l = tonumber(l)
    for _, lr in pairs(fresh_ranges) do
        local left, right = unpack(lr)
        if l <= right and l >= left then
            result_step_1 = result_step_1 + 1
            break
        end
    end
end


local function first_elem(a, b)
    return a[1] < b[1]
end
table.sort(fresh_ranges, first_elem)

local left = fresh_ranges[1][1]
local right = fresh_ranges[1][2]
table.insert(fresh_ranges, {math.huge, math.huge})
for _, lr in pairs(fresh_ranges) do
    local this_left, this_right = unpack(lr)
    if this_left > right then -- gap
        result_step_2 = result_step_2 + right - left + 1
        left = this_left
        right = this_right
    elseif this_right > right then -- extend
        right = this_right
    end                            -- ignore if contained
end


print("result step 1:", result_step_1)
print("result step 2:", string.format("%d",result_step_2))
