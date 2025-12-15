local result_step_1 = 0
local result_step_2 = 0

local numbers = {}
local operations = {}
local numbers_s2 = {}
local operations_s2 = {}

for l in io.stdin:lines() do
    local last_char = l:sub(1, 1)
    if l:sub(1, 1) == "+" or l:sub(1, 1) == "*" then
        for operation in l:gmatch("[+*]") do
            table.insert(operations, operation)
        end
        for char in l:gmatch(".") do
            if char == " " then
                table.insert(operations_s2, last_char)
            else
                table.insert(operations_s2, char)
                last_char = char
            end
        end
        table.insert(operations_s2, " ")
    else
        local row = {}
        local row_s2 = {}
        for number in l:gmatch("%d+") do
            table.insert(row, number)
        end
        table.insert(numbers, row)

        for char in l:gmatch(".") do
            table.insert(row_s2, char)
        end
        table.insert(row_s2, " ")
        table.insert(numbers_s2, row_s2)
    end
end
-- print(operations_s2[1], numbers_s2[2][1])
-- print(operations_s2[2], numbers_s2[2][2])
-- print(operations_s2[6], numbers_s2[2][7], "x")

local results = {}
for i, row in ipairs(numbers) do
    if i == 1 then
        results = row
    else
        for column, operation in ipairs(operations) do
            if operation == "+" then
                results[column] = results[column] + row[column]
            elseif operation == "*" then
                results[column] = results[column] * row[column]
            else
                error("unknown operation '" .. operation .. "'")
            end
        end
    end
end

for _, result in ipairs(results) do
    result_step_1 = result_step_1 + result
end





local results_s2 = {}

local block_result = 0
for column = 1, #operations_s2 do
    -- prepare new block
    if block_result == 0 and operations_s2[column] == "*" then
        block_result = 1
    end

    local c_num = 0
    for row = 1, #numbers_s2 do
        local n = numbers_s2[row][column]
        if n ~= " " then
            c_num = c_num * 10 + tonumber(n)
        end
    end

    -- end of block
    if c_num == 0 then
        result_step_2 = result_step_2 + block_result
        block_result = 0
    else
        if operations_s2[column] == "+" then
            block_result = block_result + c_num
        elseif operations_s2[column] == "*" then
            block_result = block_result * c_num
        else
            error("unknown operation '" .. operations_s2[column] .. "'")
        end
    end
end

for _, result in ipairs(results_s2) do
    result_step_2 = result_step_2 + result
end

print("result step 1:", result_step_1)
print("result step 2:", string.format("%d", result_step_2))
