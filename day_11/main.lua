MAX_LEN = 1000000
local function parse_input()
    local devices = {}
    for line in io.lines() do
        local matches = string.gmatch(line, "(%w+)")
        local device = matches()
        devices[device] = {}
        for d in matches do
            table.insert(devices[device], d)
        end
    end
    return devices
end

local function sorted_devices(devices, first)
    local to_sort_set = {}
    for d, _ in pairs(devices) do
        if d ~= first then
            to_sort_set[d] = true
        end
    end

    local sorted = { first }
    local sorted_set = {}
    sorted_set[first] = true

    local sort_me = next(to_sort_set)
    while sort_me do
        local found = true

        -- are all parents of this device in the list?
        for potential_parent, children in pairs(devices) do
            for _, child in pairs(children) do
                if child == sort_me and sorted_set[potential_parent] == nil then
                    found = false
                    break
                end
            end
            if found == false then break end
        end

        if found then
            sorted_set[sort_me] = true
            to_sort_set[sort_me] = nil
            table.insert(sorted, sort_me)
            sort_me = next(to_sort_set)
        else
            sort_me = next(to_sort_set, sort_me)
        end
        if sort_me == nil then
            sort_me = next(to_sort_set)
        end
    end
    return sorted
end

local function depth(leaf)
    local d = 0
    local parent = leaf.parent
    while parent do
        d = d + 1
        parent = parent.parent
    end
    return d
end

local function already_visited(leaf)
    local r = false
    local parent = leaf.parent
    while parent do
        -- print(parent.device, leaf.device)
        if parent.device == leaf.device then
            print("RECURSIONNNNNNNNNNN")
            return true
        end
        parent = parent.parent
    end
    return r
end

local function path_as_str(leaf)
    local s = leaf.device
    local parent = leaf.parent
    while parent do
        s = s .. " " .. parent.device
        parent = parent.parent
    end
    return s
end


-- TODO: varargs
local function solve_1(devices, from, to, must_1, must_2)
    local result = 0
    local paths = {}
    local leafs = {
        { device = from, parent = nil, visited_1 = false, visited_2 = false }
    }

    local i = 0
    while #leafs > 0 do
        i = i + 1
        local leaf = table.remove(leafs)
        -- print("d: " .. depth(leaf) .. "  #leafs: " .. #leafs .. "   #paths: " .. #paths)
        -- print(path_as_str(leaf))
        for _, connection in pairs(devices[leaf.device]) do
            if must_1 and connection == must_1 then
                leaf.visited_1 = true
            elseif must_2 and connection == must_2 then
                leaf.visited_2 = true
            end
            if connection == to then
                if not must_1 or (leaf.visited_1 and leaf.visited_2) then
                    result = result + 1
                    -- print(result)
                else
                    -- print("i")
                end
                -- elseif not already_visited(leaf) then
            elseif connection == "out" then
                -- print("o")
                -- ignore
            else
                table.insert(leafs, {
                    device = connection,
                    parent = leaf,
                    visited_1 = leaf.visited_1,
                    visited_2 = leaf.visited_2
                })
            end
        end
        -- table.insert(paths, leaf)
    end
    return result
end

local function solve_2(sorted_devices, devices, from, to)
    local incoming_paths = {}
    incoming_paths[from] = 1
    local state = "PRE"
    for i, device in ipairs(sorted_devices) do
        if state == "PRE" and device == from then
            state ="IN"
        end
        if state == "IN" then
            for _, child in pairs(devices[device]) do
                -- print(device, child)
                incoming_paths[child] = (incoming_paths[child] or 0) + (incoming_paths[device] or 0)
            end
            if device == to then
                break
            end
        end
    end
    return incoming_paths[to]
end

local devices = parse_input()

print("result step 1:", string.format("%d", solve_1(devices, "you", "out")))
-- print("result step 2:", string.format("%d", solve(devices, "fft", "out")))
-- print("result step 2:", string.format("%d", solve(devices, "svr", "fft")))
-- print("result step 2:", string.format("%d", solve(devices, "svr", "out", "dac", "fft")))


local sorted = sorted_devices(devices, "svr")
-- for k,v in ipairs(sorted) do print(k,v) end
local svr_fft_paths = solve_2(sorted, devices, "svr", "fft")
local fft_dac_paths = solve_2(sorted, devices, "fft", "dac")
local dac_out_paths = solve_2(sorted, devices, "dac", "out")
print(svr_fft_paths, fft_dac_paths, dac_out_paths)
print("result step 2:", string.format("%d", svr_fft_paths * fft_dac_paths * dac_out_paths))
