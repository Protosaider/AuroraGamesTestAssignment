local N = 11
local M = 12

local input = io.stdin

local space = ' '
local columnsHeader = "   "

for i = 1, N  do
    columnsHeader = columnsHeader .. (i - 1)
    if (i / 10) <= 1 then
        columnsHeader = columnsHeader .. space
    end
end

local headerSeparator = ""
local itemSeparator = '-'

for i = 1, #columnsHeader do
    headerSeparator = headerSeparator .. itemSeparator
end

print(columnsHeader)
print(headerSeparator)

local rowHeaders = {}
itemSeparator = ' '

for i = 1, M do
    rowHeaders[i] = ""
    if (i / 10) <= 1 then
        rowHeaders[i] = rowHeaders[i] .. space
    end
    rowHeaders[i] = rowHeaders[i] .. (i - 1) .. itemSeparator .. " " .. "A"
end

repeat
    local res = input:read("l")

    local commandQuit = string.match(res, "^(%s*[q]%s*)$")

    if commandQuit then break end

    local cellX, cellY, moveToDirection = string.match(res, "^%s*[m]%s+(%d+)%s+(%d+)%s+([lrud])%s*$")

    --clear console
    if not os.execute("clear") then
        os.execute("cls")
    end

    --print header
    print(columnsHeader)
    print(headerSeparator)

    if cellX ~= nil then
        print("duh")
    else
        print("Wrong input")
    end

    --print row's headers
    for _, value in ipairs(rowHeaders) do
        print(value)
    end

until false




-- local GameField = {
--     Width = 1, --N - columns
--     Height = 10 --M - rows
-- handles combinations (add\remove cell, add cell in destruction list)
-- }

local Cell = {
    previousVertical = {},
    nextHorizontal = {}
}

local function Cell.onCrystalCombined(gameField, crystalType)
    -- check crystal crystal
    -- if crystal type == normal - just delete, otherwise call another method from gameField
end

-- local Crystal = {
--     color = "A",
--     type,
-- }

-- local function Crystal.onCombined(gameField)

-- end

