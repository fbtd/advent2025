Maze = require("maze")

local result_step_1 = 0
local result_step_2 = 0

local m = Maze.from_string(io.read("a"))

local function remove_rolls(m, recurse)
    local n_removed = 0
    local rerun = true
    while rerun do
        rerun = false
        for i, v in ipairs(m.sequence_chars) do
            if v == '@' then
                local neighbors = 0
                local nt = m:get_8n(m:index_to_xy(i))
                for j = 1, 8 do
                    -- print(i, nt[j])
                    if nt[j] == '@' then
                        neighbors = neighbors + 1
                    end
                end
                if neighbors < 4 then
                    n_removed = n_removed + 1
                    if recurse then
                        rerun = true
                        local x, y = m:index_to_xy(i)
                        m:set_char(x, y, '.')
                    end
                end
            end
        end
    end
    return n_removed
end

result_step_1 = remove_rolls(m, false)
result_step_2 = remove_rolls(m, true)

print("result step 1:", result_step_1)
print("result step 2:", result_step_2)
