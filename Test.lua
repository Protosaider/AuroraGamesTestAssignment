local N = 11 --width (> 0)
local M = 12 --height (>= 10)

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

local output = io.stdout

function printOut(s)
    output:write(s .. "\n") --\r because windows
    output:flush()
end

output:write("CHECK OUTPUT")
output:write("cls")
output:write("cls\n")

printOut("OUt OUT")
printOut("CHECK OUTPUT2")
printOut("cls")
printOut("CHECK OUTPUT3")



local rowHeaders = {}
itemSeparator = ' '

for i = 1, M do
    rowHeaders[i] = ""
    if (i / 10) <= 1 then
        rowHeaders[i] = rowHeaders[i] .. space
    end
    rowHeaders[i] = rowHeaders[i] .. (i - 1) .. itemSeparator .. " " .. "A"
end

print(rowHeaders[11])



local Crystal = require("Crystal")
local ECrystalColor = require("ECrystalColor")
local ECrystalType = require("ECrystalType")


local crys1 = Crystal:new(ECrystalType.Base, ECrystalColor.A)
print(crys1)

local crys2 = Crystal:new({"tuk"}, {"cook"})
print(crys2)

local crys = {ECrystalColor.A}
crys[ECrystalColor.A] = 1
print(crys[ECrystalColor.A])

print(type(ECrystalColor.A) .. " " .. type(ECrystalType.Base) .. " " .. type(ECrystalColor))
print(type(ECrystalType) == type(ECrystalColor))

print(tostring(ECrystalColor.A) .. tostring(ECrystalColor.B[1]))

print(tostring(ECrystalColor[1]) .. tostring(ECrystalColor[2]))

ECrystalColor.B[1] = 2
print(ECrystalColor.B[1])

-- cannot modify
-- ECrystalColor.B = 2
-- print(ECrystalColor.B)

print("\n")

print()
print(ECrystalColor[1][1])
print(ECrystalColor.A.A)
ECrystalColor.A[1] = 20
print(ECrystalColor.A.value)
print(ECrystalColor.A[1])
print(ECrystalColor.A.A)

print(ECrystalColor.A.value)
ECrystalColor.A.value = "kek"

print()
print(tostring(ECrystalColor.A))
print(tostring(ECrystalColor[1]))
-- ECrystalColor.A = 10
print(tostring(ECrystalColor.A))
print(tostring(ECrystalColor[1]))

print()
-- print(ECrystalColor.B.A.A)

local cryst = Crystal:new(ECrystalType.Base, ECrystalColor[math.random(#ECrystalColor)])

print(cryst.color)


local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")


print()
local dir = EDirectionHelper.opposite(EDirection.Up)
print(dir)

local gameField = require("GameField")
local field = gameField:new(N, M, ' ', '|', '-', '\n', '*')
field:dump()

repeat
    local res = input:read("l")

    local commandQuit = string.match(res, "^(%s*[q]%s*)$")

    if commandQuit then break end

    local cellX, cellY, moveToDirection = string.match(res, "^%s*[m]%s+(%d+)%s+(%d+)%s+([lrud])%s*$")

    if cellX ~= nil then
        print("duh")
    else
        print("Wrong input")
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

-- local function Cell.onCrystalCombined(gameField, crystalType)
    -- check crystal type
    -- if crystal type == normal - just delete, otherwise call another method from gameField
-- end

-- local Crystal = {
--     color = "A",
--     type,
-- }

-- local function Crystal.onCombined(gameField)

-- end

