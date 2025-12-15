local bit = require("bit")
local MAX_BUTTONS = 13
local MAX_DEPTH = 1000

local function lights_str_to_int(str)
    local result = 0
    local as_bytes = { str:byte(1, #str) }
    for i, b in ipairs(as_bytes) do
        if b == string.byte("#") then
            result = result + 2 ^ (i - 1)
        end
    end
    return result
end

local function parse_input()
    local result = {}
    for line in io.lines() do
        local lights = line:match("([.#]+)")
        lights = lights_str_to_int(lights)

        local buttons = {}
        local raw_buttons = {}
        for button in line:gmatch("%(([%d,]*)%)") do
            local raw_digits = {}
            local button_int = 0
            for digit in button:gmatch("(%d+)") do
                table.insert(raw_digits, tonumber(digit))
                button_int = button_int + 2 ^ digit
            end
            table.insert(raw_buttons, raw_digits)
            table.insert(buttons, button_int)
        end

        local joltages = {}
        local joltages_str = line:match("{([%d,]*)}")
        for digit in joltages_str:gmatch("(%d+)") do
            table.insert(joltages, tonumber(digit))
        end

        -- print(lights, buttons[6], raw_buttons[1][2], joltages[2])
        table.insert(result, {
            lights = lights,
            buttons = buttons,
            buttons_raw = raw_buttons,
            joltages = joltages
        })
    end
    return result
end

local permutations = {}
for s = 1, MAX_BUTTONS do
    permutations[s] = {}
    for i = 1, 2 ^ s - 1 do
        local size = 0
        local ii = i
        while ii > 0 do
            size = size + ii % 2
            ii = bit.rshift(ii, 1)
        end
        if permutations[s][size] == nil then
            permutations[s][size] = {}
        end
        table.insert(permutations[s][size], i)
        -- print(i, s, size)
    end
end

local function solve_1(lines)
    local result = 0
    for _, line in ipairs(lines) do
        local found = false
        for size = 1, #line.buttons do
            if found then break end
            for _, permutation in ipairs(permutations[#line.buttons][size]) do
                local this_lights = 0
                for i_button, button in ipairs(line.buttons) do
                    local i = 2 ^ (i_button - 1)
                    if bit.band(i, permutation) > 0 then
                        this_lights = bit.bxor(this_lights, button)
                    end
                end
                if this_lights == line.lights then
                    result = result + size
                    found = true
                    break
                end
            end
        end
    end
    return result
end

-----------------------------------
-----------------------------------
-----------------------------------

local function make_zeroes(t)
    local zeroes = {}
    for _, _ in pairs(t) do
        table.insert(zeroes, 0)
    end
    return zeroes
end

local function joltages_from_clicks(clicks, buttons)
    local joltages = {}
    for buttons_i, c in pairs(clicks) do
        for _, j_i in pairs(buttons[buttons_i]) do
            joltages[j_i + 1] = (joltages[j_i + 1] or 0) + c
        end
    end
    return joltages
end

-- maximum amout of time a button can be pressed before exceeding joltages
local function make_clicks_max(button, j_from, j_to, max)
    max = max or math.huge
    for i = 1, #button do
        local j = j_to[button[i] + 1] - j_from[button[i] + 1]
        if j < max then
            max = j
        end
    end
    return max
end

local Candidate = {}
function Candidate:new(c)
    local length = 0
    local longest_i = 0
    for i = 1, #c.clicks_min do
        local l = c.clicks_max[i] - c.clicks_min[i]
        -- if l > 0 then
        --     length = l
        --     longest_i = i
        --     break
        -- end
        if l > length then
            length = l
            longest_i = i
        end
    end
    c.length = length
    c.longest_i = longest_i

    c.joltages_min = joltages_from_clicks(c.clicks_min, c.buttons)
    c.joltages_max = joltages_from_clicks(c.clicks_max, c.buttons)

    self.__index = self
    setmetatable(c, self)
    return c
end

function Candidate:as_str()
    return string.format(
        "candidate: [clicks {%s}-{%s}, len %d (at %d), joltages {%s}-{%s}]",
        table.concat(self.clicks_min, " "),
        table.concat(self.clicks_max, " "),
        self.length,
        self.longest_i,
        table.concat(self.joltages_min, " "),
        table.concat(self.joltages_max, " ")
    )
end

function Candidate:get_total_clicks()
    local total = 0
    for _, c in pairs(self.clicks_min) do
        total = total + c
    end
    return total
end

function Candidate:split()
    local bottom_clicks_max = { unpack(self.clicks_max) }
    local mid = math.floor((self.clicks_max[self.longest_i] + self.clicks_min[self.longest_i]) / 2)
    -- print(mid, self.longest_i)
    bottom_clicks_max[self.longest_i] = mid
    local top_clicks_min = { unpack(self.clicks_min) }
    top_clicks_min[self.longest_i] = mid + 1

    local bottom = Candidate:new {
        clicks_min = self.clicks_min,
        clicks_max = bottom_clicks_max,
        buttons = self.buttons
    }
    local top = Candidate:new {
        clicks_min = top_clicks_min,
        clicks_max = self.clicks_max,
        buttons = self.buttons
    }
    self = nil
    return bottom, top
end

function Candidate:is_valid(joltages)
    for i, j in ipairs(joltages) do
        if self.joltages_min[i] > j or self.joltages_max[i] < j then
            return false
        end
    end
    for i = 1, #self.clicks_min do
        if self.clicks_min[i] > self.clicks_max[i] then
            return false
        end
    end
    return true
end

function Candidate:is_solution(joltages)
    for i, j in ipairs(joltages) do
        if self.joltages_min[i] ~= j then
            return false
        end
        if self.joltages_max[i] ~= j then
            return false
        end
    end
    return true
end

local function get_longest_candidate(candidates)
    local longest_i = 1
    local longest = 0
    for i, c in pairs(candidates) do
        if c.length > longest then
            longest = c.length
            longest_i = i
        end
    end
    return table.remove(candidates, longest_i)
end

local function solve_line_2(buttons, joltages)
    local clicks_max = {}
    for _, button in ipairs(buttons) do
        table.insert(clicks_max, make_clicks_max(button, make_zeroes(joltages), joltages))
    end
    local root = Candidate:new {
        clicks_min = make_zeroes(buttons),
        clicks_max = clicks_max,
        buttons = buttons,
    }

    local candidates = { root }
    local solutions = {}

    local iter = 0
    while #candidates > 0 do
        -- iter = iter + 1
        -- if iter > 10 then
        --     break
        -- end
        -- print(#candidates)
        local candidate = get_longest_candidate(candidates)
        if candidate:is_valid(joltages) then
            if candidate:is_solution(joltages) then
                print("solution: ", candidate:as_str())
                table.insert(solutions, candidate)
            else
                local bottom, top = candidate:split()
                print("c", candidate:as_str())
                print("b", bottom:as_str())
                print("t", top:as_str())
                print()
                table.insert(candidates, bottom)
                table.insert(candidates, top)
            end
            -- else
            --     print("invalid: ", candidate:as_str())
        end
    end

    local result = math.huge
    for _, s in pairs(solutions) do
        if s:get_total_clicks() < result then
            result = s:get_total_clicks()
        end
    end
    return result
end


local function solve_2(lines)
    local result = 0
    for _, line in ipairs(lines) do
        local r = solve_line_2(line.buttons_raw, line.joltages)
        print(r)
        result = result + r
    end
    return result
end

local lines = parse_input()
print("result step 1:", string.format("%d", solve_1(lines)))
print("result step 2:", string.format("%d", solve_2(lines)))
