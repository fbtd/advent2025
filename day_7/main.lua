local result_step_1 = 0
local result_step_2 = 0

Maze = require "maze"

local m = Maze.from_string(io.read("a"))
print(m.width, m.height, m.size)

local beams = {}
local ancestors = {}
for i = 1, m.size do
    local x, y = m:index_to_xy(i)
    local here = m:get(x, y)
    local n = m:get(m:xy_add(x, y, 0, -1))
    local beam_n = beams[m:xy_add_to_index(x, y, 0, -1)]
    local ancestors_n = ancestors[m:xy_add_to_index(x, y, 0, -1)]
    local beam_ne = beams[m:xy_add_to_index(x, y, 1, -1)]
    local ancestors_ne = ancestors[m:xy_add_to_index(x, y, 1, -1)]
    local e = m:get(m:xy_add(x, y, 1, 0))
    local beam_nw = beams[m:xy_add_to_index(x, y, -1, -1)]
    local ancestors_nw = ancestors[m:xy_add_to_index(x, y, -1, -1)]
    local w = m:get(m:xy_add(x, y, -1, 0))
    -- print(i,x,y,m:xy_to_index(x,y))
    if here == '.' then
        -- print(n, beam_n)
        if n == "S"
            or beam_n
            or (e == "^" and beam_ne)
            or (w == "^" and beam_nw) then
            beams[i] = true
            -- print(x,y,i, "ON")
            -- if y == m.height - 1 then
            --     result_step_1 = result_step_1 + 1
            -- end
        end
        if n == "S" then
            ancestors[i] = 1
        end
        if beam_n then
            ancestors[i] = ancestors_n
        end
        if e == "^" and beam_ne then
            ancestors[i] = (ancestors[i] or 0) + (ancestors_ne or 0)
        end
        if w == "^" and beam_nw then
            ancestors[i] = (ancestors[i] or 0) + (ancestors_nw or 0)
        end
    end
    if beam_n and here == "^" then
        result_step_1 = result_step_1 + 1
    end
end

for i = m.size - m.width + 1, m.size do
    result_step_2 = result_step_2 + (ancestors[i] or 0)
end

print("result step 1:", string.format("%d", result_step_1))
print("result step 2:", string.format("%d", result_step_2))
