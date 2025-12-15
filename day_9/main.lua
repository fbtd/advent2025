local result_step_1 = 1
local result_step_2 = 0

local red_tiles = {}
for line in io.lines() do
    local x, y = line:match("(%d+),(%d+)")
    x, y = tonumber(x), tonumber(y)
    table.insert(red_tiles, { x, y })
end

local function abs(n)
    if n < 0 then
        return n * -1
    end
    return n
end

for i = 1, #red_tiles do
    for j = i + 1, #red_tiles do
        local area =
            (abs(red_tiles[i][1] - red_tiles[j][1]) + 1) *
            (abs(red_tiles[i][2] - red_tiles[j][2]) + 1)
        if result_step_1 < area then
            result_step_1 = area
        end
    end
end

-- step 1
print("result step 1:", string.format("%d", result_step_1))




local spikes = {}
local h_beams = {}
local v_beams = {}

for i = 1, #red_tiles do
    --TODO-- modulo
    local p = i - 1
    if p == 0 then p = #red_tiles end
    local n = i + 1
    if n == #red_tiles + 1 then n = 1 end

    -- p,n=n,p
    local xp, yp = red_tiles[p][1], red_tiles[p][2]
    local xt, yt = red_tiles[i][1], red_tiles[i][2]
    local xn, yn = red_tiles[n][1], red_tiles[n][2]

    if xp == xt and yt > yp and xn < xt then -- south to west
        table.insert(spikes, { xt, yt + 1 })
        table.insert(spikes, { xt + 1, yt })
    elseif xp == xt and yt > yp and xn > xt then -- south to east
        table.insert(spikes, { xt + 1, yt - 1 })
    elseif xp == xt and yt < yp and xn < xt then -- nort to west
        table.insert(spikes, { xt - 1, yt + 1 })
    elseif xp == xt and yt < yp and xn > xt then -- nort to east
        table.insert(spikes, { xt, yt - 1 })
        table.insert(spikes, { xt - 1, yt })
    elseif yp == yt and xt > xp and yn < yt then -- east to north
        table.insert(spikes, { xt - 1, yt - 1 })
    elseif yp == yt and xt > xp and yn > yt then -- east to south
        table.insert(spikes, { xt + 1, yt })
        table.insert(spikes, { xt, yt - 1 })
    elseif yp == yt and xt < xp and yn < yt then -- west to north
        table.insert(spikes, { xt - 1, yt })
        table.insert(spikes, { xt, yt + 1 })
    elseif yp == yt and xt < xp and yn > yt then -- west to south
        table.insert(spikes, { xt + 1, yt + 1 })
    end

    if xp == xt then
        table.insert(v_beams, { xp, math.min(yp, yt), math.max(yp, yt) })
    elseif yp == yt then
        table.insert(h_beams, { yp, math.min(xp, xt), math.max(xp, xt) })
    end
end

-- for _, s in ipairs(spikes) do print(s[1], s[2]) end

local function is_valid(x1, y1, x2, y2, spikes, tiles)
    for _, s in pairs(spikes) do
        local xs, ys = s[1], s[2]
        if (x1 < xs and xs < x2 and (ys == y1 or ys == y2))
            or (y1 < ys and ys < y2 and (xs == x1 or xs == x2))
            or (x1 <= xs and xs <= x2 and y1 <= ys and ys <= y2) then
            return false
        end
    end
    for _, t in pairs(tiles) do
        local xt, yt = t[1], t[2]
        -- if not (xt == x1 and yt == y1)
        --     and not (xt == x2 and yt == y2)
        if x1 < xt and xt < x2 and y1 < yt and yt < y2 then
            return false
        end
    end

    -- check for holes
    for _, b in pairs(h_beams) do
        local y_beam, first, last = b[1], b[2], b[3]
        if first < x1 and x1 < last and y1 < y_beam and y_beam < y2 then
            return false
        end
    end
    for _, b in pairs(v_beams) do
        local x_beam, first, last = b[1], b[2], b[3]
        if first < y1 and y1 < last and x1 < x_beam and x_beam < x2 then
            return false
        end
    end


    -- print("valid", x1,y1,x2,y2, (x2 - x1 + 1) * (y2 - y1 + 1))
    return true
end

local largest_rectangle = {}
for i = 1, #red_tiles do
    for j = i + 1, #red_tiles do
        local x1 = math.min(red_tiles[i][1], red_tiles[j][1])
        local x2 = math.max(red_tiles[i][1], red_tiles[j][1])
        local y1 = math.min(red_tiles[i][2], red_tiles[j][2])
        local y2 = math.max(red_tiles[i][2], red_tiles[j][2])
        if is_valid(x1, y1, x2, y2, spikes, red_tiles) then
            local area = (x2 - x1 + 1) * (y2 - y1 + 1)
            if result_step_2 < area then
                largest_rectangle = {
                    red_tiles[i][1], red_tiles[i][2],
                    red_tiles[j][1], red_tiles[j][2]
                }
                result_step_2 = area
            end
        end
    end
end

print(unpack(largest_rectangle))

-- step 2
print("result step 2:", string.format("%d", result_step_2))
