local rotation
local position = 50
local result = 0

local function abs(n)
    if n < 0 then
        return n * -1
    end
    return n
end


local function addwithoverflow(current_position, direction, turns)
    if direction == "L" then
        turns = turns * -1
    else
        turns = turns * 1
    end

    if (turns % 100 == 0) then
        return { position = current_position, overflow = abs(turns) // 100 }
    end

    local new_position = (current_position + turns) % 100
    local overflow = abs(turns) // 100
    if
        (new_position > current_position and current_position ~= 0 and direction == "L")
        or (new_position < current_position and direction == "R")
        or new_position == 0
    then
        overflow = overflow + 1
    end

    return { position = new_position, overflow = overflow }
end


repeat
    rotation = io.read()
    if not rotation then break end
    local direction = string.sub(rotation, 1, 1)
    local turns = string.sub(rotation, 2)
    local overflow
    local t = addwithoverflow(position, direction, turns)
    position, overflow = t.position, t.overflow
    result = result + overflow
until not rotation

print(result)
